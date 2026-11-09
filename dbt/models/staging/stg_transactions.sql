{{ config(materialized='view') }}

select
    transaction_time,
    toDate(transaction_time) as transaction_date,
    toHour(transaction_time) as transaction_hour,
    toDayOfWeek(transaction_time) as day_of_week,
    trim(merch) as merchant_name,
    trim(cat_id) as category,
    amount,
    {{ amount_bucket('amount') }} as amount_segment,
    toUInt8(amount >= 500) as is_large_transaction,
    concat(trim(name_1), ' ', trim(name_2)) as customer_id,
    upper(gender) as gender,
    us_state,
    lat,
    lon,
    merchant_lat,
    merchant_lon,
    round(greatCircleDistance(lon, lat, merchant_lon, merchant_lat) / 1000, 2) as distance_km,
    target as is_fraud
from {{ source('fraud', 'transactions') }}
