CREATE DATABASE IF NOT EXISTS fraud;

DROP TABLE IF EXISTS fraud.transactions_queue;
CREATE TABLE fraud.transactions_queue
(
    transaction_time String,
    merch            String,
    cat_id           String,
    amount           Float64,
    name_1           String,
    name_2           String,
    gender           String,
    street           String,
    one_city         String,
    us_state         String,
    post_code        String,
    lat              Float64,
    lon              Float64,
    population_city  UInt32,
    jobs             String,
    merchant_lat     Float64,
    merchant_lon     Float64,
    target           UInt8
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'clickhouse_transactions',
    kafka_format = 'JSONEachRow',
    kafka_num_consumers = 1,
    kafka_skip_broken_messages = 100;

DROP TABLE IF EXISTS fraud.transactions;
CREATE TABLE fraud.transactions
(
    transaction_time DateTime CODEC(Delta, ZSTD(3)),
    merch            LowCardinality(String),
    cat_id           LowCardinality(String),
    amount           Decimal(10, 2) CODEC(ZSTD(3)),
    name_1           LowCardinality(String),
    name_2           LowCardinality(String),
    gender           LowCardinality(String),
    street           String CODEC(ZSTD(3)),
    one_city         LowCardinality(String),
    us_state         LowCardinality(String),
    post_code        LowCardinality(String),
    lat              Float32 CODEC(ZSTD(3)),
    lon              Float32 CODEC(ZSTD(3)),
    population_city  UInt32 CODEC(T64, ZSTD(3)),
    jobs             LowCardinality(String),
    merchant_lat     Float32 CODEC(ZSTD(3)),
    merchant_lon     Float32 CODEC(ZSTD(3)),
    target           UInt8 CODEC(ZSTD(3)),

    PROJECTION proj_state_category
    (
        SELECT us_state, cat_id, max(amount)
        GROUP BY us_state, cat_id
    )
)
ENGINE = MergeTree
PARTITION BY toYear(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

DROP VIEW IF EXISTS fraud.transactions_mv;
CREATE MATERIALIZED VIEW fraud.transactions_mv TO fraud.transactions AS
SELECT
    parseDateTimeBestEffort(transaction_time) AS transaction_time,
    merch, cat_id, amount, name_1, name_2, gender, street,
    one_city, us_state, post_code, lat, lon,
    population_city, jobs, merchant_lat, merchant_lon, target
FROM fraud.transactions_queue;