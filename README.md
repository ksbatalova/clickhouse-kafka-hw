# Kafka → ClickHouse: анализ транзакций

Пайплайн загрузки транзакций из CSV в Kafka и далее в ClickHouse,
аналитический запрос по данным и оптимизация хранения таблицы.

## Стек

- Apache Kafka 3.9 (KRaft, без ZooKeeper)
- ClickHouse 24.8
- Python 3.12 + confluent-kafka

## Структура проекта
```
data/                        CSV-файлы (не в репозитории, см. «Данные»)
scripts/producer.py          отправка CSV в топик Kafka
sql/01_ddl.sql               базовая схема: Kafka → MergeTree → MV
sql/02_ddl_optimized.sql     оптимизированная схема
sql/03_query.sql             целевой запрос
sql/04_benchmark.sql         таблица для сравнения «до/после»
sql/05_query_projection.sql  вариант запроса под проекцию
results/                     результат выгрузки
docker-compose.yml           Kafka + ClickHouse
requirements.txt             зависимости Python
```

## Данные

Датасет не хранится в репозитории: train.csv весит 138 МБ,
что превышает лимит GitHub на размер файла.

Скачайте файлы с Kaggle и положите в папку data/:

- data/train.csv — 786 431 строка
- data/test.csv — 262 144 строки

Структура колонок:

```
transaction_time, merch, cat_id, amount, name_1, name_2, gender,
street, one_city, us_state, post_code, lat, lon, population_city,
jobs, merchant_lat, merchant_lon, target
```

В test.csv колонка target отсутствует.

## Запуск

### 1. Поднять контейнеры

```bash
docker compose up -d
docker compose ps
curl http://localhost:8123/ping
```

### 2. Создать топик

```bash
docker compose exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic transactions --partitions 3 --replication-factor 1
```

### 3. Подготовить окружение Python

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 4. Создать таблицы

```bash
docker compose exec -T clickhouse clickhouse-client \
  --user analyst --password analyst --multiquery < sql/01_ddl.sql
```

### 5. Загрузить данные

```bash
python scripts/producer.py --file data/train.csv
python scripts/producer.py --file data/test.csv
```

```bash
docker compose exec clickhouse clickhouse-client \
  --user analyst --password analyst --database fraud \
  --query "SELECT count() FROM transactions"
```

Для быстрой проверки пайплайна можно ограничить объём:

```bash
python scripts/producer.py --file data/train.csv --limit 100
```

### 6. Выполнить запрос и выгрузить результат

```bash
docker compose exec -T clickhouse clickhouse-client \
  --user analyst --password analyst --format CSVWithNames \
  --multiquery < sql/03_query.sql > results/top_category_by_state.csv
```

## Архитектура загрузки

Связка из трёх объектов ClickHouse:

1. `transactions_queue`, движок Kafka — читает топик. Данные
   не хранит, каждая строка доступна для чтения один раз.
2. `transactions`, движок MergeTree — постоянное хранилище.
3. `transactions_mv`, материализованное представление — срабатывает
   на новые сообщения в очереди и вставляет их в хранилище.

Поле transaction_time приходит в формате YYYY-MM-DD HH:MM без секунд,
который ClickHouse не приводит к DateTime автоматически. Поэтому
в Kafka-таблице оно объявлено как String, а конвертация выполняется
в материализованном представлении через parseDateTimeBestEffort.

Настройка kafka_skip_broken_messages = 100 не даёт пайплайну
остановиться на единичных некорректных сообщениях.

Сеть Docker требует двух listener'ов у Kafka: ClickHouse подключается
внутри сети по kafka:9092, producer с хост-машины — по localhost:29092.

## Целевой запрос

Категория наибольшей транзакции по каждому штату:

```sql
SELECT
    us_state                AS state,
    argMax(cat_id, amount)  AS top_category,
    max(amount)             AS max_amount
FROM fraud.transactions
GROUP BY us_state
ORDER BY us_state;
```

argMax(cat_id, amount) возвращает значение cat_id из той строки,
где amount максимален — без самосоединения или оконных функций.

Фрагмент результата:

| state | top_category | max_amount |
|---|---|---|
| AK | travel | 3178.51 |
| AL | travel | 10525.07 |
| AR | travel | 13536.84 |
| AZ | shopping_pos | 2393.29 |

## Оптимизация хранения

| Метрика | Базовая схема | Оптимизированная | С проекцией | Выигрыш |
|---|---|---|---|---|
| Размер на диске | 72.33 MiB | 24.64 MiB | — | 2.9x |
| Прочитано на запрос | 38.53 MiB | 10.00 MiB | 35.67 KiB | до 1100x |
| Прочитано строк | 1 048 575 | 1 048 575 | 1 405 | 746x |
| Время запроса | 0.010 с | 0.007 с | 0.004 с | — |

Что изменено в sql/02_ddl_optimized.sql относительно sql/01_ddl.sql:

- `LowCardinality(String)` для колонок с малым числом уникальных
  значений (`us_state` ~50, cat_id ~14, gender, one_city, jobs,
  post_code, имена). Вместо повторяющихся строк на диске хранятся
  числовые ключи словаря.
- `ORDER BY (us_state, cat_id, transaction_time)` вместо сортировки
  по времени — ключ выстроен под целевой запрос, данные лежат
  сгруппированными по штату и категории.
- `Decimal(10, 2)` для суммы вместо Float64: корректная точность
  денежных значений и лучшая сжимаемость.
- `Float32` для координат вместо Float64 — четырёх байт достаточно
  для имеющейся точности.
- Кодеки сжатия: Delta + ZSTD для времени (хранятся разницы между
  соседними значениями), T64 + ZSTD для population_city,
  ZSTD для остальных числовых колонок.
- `PARTITION BY toYear(transaction_time)` — данные охватывают
  2019–2020 годы, получается две партиции. Месячное партиционирование
  дало бы 24 куска без выигрыша, так как в запросе нет фильтра по дате.
- `PROJECTION proj_state_category` — предагрегат max(amount)
  по паре штат/категория.

Время выполнения на миллионе строк упирается в нижнюю границу движка
(единицы миллисекунд), поэтому показательными метриками выбраны размер
на диске и объём прочитанных данных из system.query_log.

Проекция не подставляется в запрос с argMax автоматически: ClickHouse
не сводит эту функцию к агрегатной проекции. В sql/05_query_projection.sql
запрос переписан через подзапрос, структура которого совпадает
с определением проекции — агрегация по (us_state, cat_id) выполняется
во вложенном SELECT, а выбор категории-максимума во внешнем.
Результат идентичен базовому запросу.

## Сравнение «до/после»

sql/04_benchmark.sql создаёт таблицу transactions_opt
с оптимизированной схемой и копирует в неё данные из transactions,
что позволяет сравнить обе схемы на одном наборе строк без перезаливки
топика.

```bash
docker compose exec -T clickhouse clickhouse-client \
  --user analyst --password analyst --multiquery < sql/04_benchmark.sql
Размер на диске:

docker compose exec clickhouse clickhouse-client \
  --user analyst --password analyst --database fraud \
  --query "SELECT table, formatReadableSize(sum(bytes_on_disk)) AS disk
           FROM system.parts
           WHERE table IN ('transactions','transactions_opt') AND active
           GROUP BY table"
```
    
Время и объём чтения:

```bash
docker compose exec clickhouse clickhouse-client \
  --user analyst --password analyst --database fraud \
  --query "SELECT tables[1] AS t, query_duration_ms,
                  formatReadableSize(read_bytes) AS read, read_rows
           FROM system.query_log
           WHERE type = 'QueryFinish'
             AND query LIKE '%GROUP BY us_state%'
             AND query NOT LIKE '%query_log%'
           ORDER BY event_time DESC LIMIT 6"
```

## Применение оптимизированной схемы с нуля

`sql/02_ddl_optimized.sql` пересоздаёт таблицы, поэтому данные нужно
загрузить заново. Порядок: пересоздать топик, применить DDL,
запустить producer.

```bash
docker compose exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 --delete --topic transactions

docker compose exec kafka /opt/kafka/bin/kafka-topics.sh \
  --bootstrap-server localhost:9092 \
  --create --topic transactions --partitions 3 --replication-factor 1

docker compose exec -T clickhouse clickhouse-client \
  --user analyst --password analyst --multiquery < sql/02_ddl_optimized.sql

python scripts/producer.py --file data/train.csv
python scripts/producer.py --file data/test.csv
```

## Остановка

```bash
docker compose down        # остановить контейнеры
docker compose down -v     # вместе с данными ClickHouse
```
