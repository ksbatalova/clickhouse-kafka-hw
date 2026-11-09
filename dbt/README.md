# dbt-проект: аналитика фрод-транзакций (ClickHouse)

Слои: `source (fraud.transactions) -> staging (stg_transactions) -> marts (6 витрин)`.

## Версии
- dbt-core 1.12.6
- dbt-clickhouse 1.10.3

## Запуск
1. Поднять ClickHouse и загрузить данные (см. README корня репозитория): `docker compose up -d`, затем `python scripts/producer.py --file data/train.csv`.
2. Установить dbt: `pip install dbt-core dbt-clickhouse`.
3. Из каталога `dbt/`:
```bash
dbt deps && dbt seed && dbt run && dbt test
dbt docs generate && dbt docs serve
```
Или через Makefile: `make all`, `make docs`, `make lint`.

Подключение настроено в `profiles.yml` (хост localhost, порт 8123, база `fraud`, пользователь `analyst`).

## Что реализовано
- Макрос `amount_bucket` (сегментация суммы), используется в `stg_transactions`.
- Витрины: `mart_daily_state_metrics`, `mart_fraud_by_category`, `mart_fraud_by_state`, `mart_customer_risk_profile`, `mart_hourly_fraud_pattern`, `mart_merchant_analytics`.
- Seed `states.csv` (справочник штатов), используется в `mart_fraud_by_state`.
- `schema.yml` с описаниями и тестами: `not_null`, `unique`, `accepted_values`, `dbt_utils.unique_combination_of_columns`, `dbt_utils.accepted_range`, `dbt_expectations.expect_column_values_to_be_between`.
- Singular tests в `tests/`: `assert_no_negative_amounts`, `assert_fraud_rate_bounds`, `assert_fraud_not_exceeds_total`.
- Unit tests (dbt 1.8+): `models/staging/unit_tests.yml`, `models/marts/unit_tests.yml`.
- `sqlfluff` (`.sqlfluff`, диалект clickhouse), `.pre-commit-config.yaml`, `Makefile`.

## Допущения
- ID клиента в данных нет, поэтому `customer_id` = имя + фамилия.
- Порог крупной транзакции: сумма от 500. Сегмент риска клиента: HIGH при доле фрода от 5%, MEDIUM при наличии фрода, иначе LOW.
- Рискованное временное окно: доля фрода больше чем вдвое выше средней.
- Пакет `dbt_date` устанавливается как зависимость `dbt_expectations`.
