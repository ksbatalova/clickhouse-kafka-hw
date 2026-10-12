DROP TABLE IF EXISTS fraud.transactions_opt;
CREATE TABLE fraud.transactions_opt
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

INSERT INTO fraud.transactions_opt SELECT * FROM fraud.transactions;