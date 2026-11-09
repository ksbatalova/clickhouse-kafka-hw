

with __dbt__cte__fraud__transactions as (

-- Fixture for transactions
select CAST('2024-01-01 10:00:00' AS DateTime) as "transaction_time", CAST(' Shop A ' AS String) as "merch", CAST('food' AS String) as "cat_id", CAST(20.0 AS Float64) as "amount", CAST('Ann' AS String) as "name_1", CAST('Lee' AS String) as "name_2", CAST('f' AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "street", CAST(defaultValueOfTypeName('String') AS String) as "one_city", CAST('TX' AS String) as "us_state", CAST(defaultValueOfTypeName('String') AS String) as "post_code", CAST(30.0 AS Float64) as "lat", CAST(-97.0 AS Float64) as "lon", CAST(defaultValueOfTypeName('UInt32') AS UInt32) as "population_city", CAST(defaultValueOfTypeName('String') AS String) as "jobs", CAST(30.1 AS Float64) as "merchant_lat", CAST(-97.1 AS Float64) as "merchant_lon", CAST(0 AS UInt8) as "target"
union all
select CAST('2024-01-01 11:00:00' AS DateTime) as "transaction_time", CAST('Shop B' AS String) as "merch", CAST('travel' AS String) as "cat_id", CAST(120.0 AS Float64) as "amount", CAST('Bob' AS String) as "name_1", CAST('Ray' AS String) as "name_2", CAST('m' AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "street", CAST(defaultValueOfTypeName('String') AS String) as "one_city", CAST('CA' AS String) as "us_state", CAST(defaultValueOfTypeName('String') AS String) as "post_code", CAST(34.0 AS Float64) as "lat", CAST(-118.0 AS Float64) as "lon", CAST(defaultValueOfTypeName('UInt32') AS UInt32) as "population_city", CAST(defaultValueOfTypeName('String') AS String) as "jobs", CAST(34.1 AS Float64) as "merchant_lat", CAST(-118.1 AS Float64) as "merchant_lon", CAST(1 AS UInt8) as "target"
union all
select CAST('2024-01-01 12:00:00' AS DateTime) as "transaction_time", CAST('Shop C' AS String) as "merch", CAST('travel' AS String) as "cat_id", CAST(600.0 AS Float64) as "amount", CAST('Cy' AS String) as "name_1", CAST('Day' AS String) as "name_2", CAST('m' AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "street", CAST(defaultValueOfTypeName('String') AS String) as "one_city", CAST('NY' AS String) as "us_state", CAST(defaultValueOfTypeName('String') AS String) as "post_code", CAST(40.0 AS Float64) as "lat", CAST(-74.0 AS Float64) as "lon", CAST(defaultValueOfTypeName('UInt32') AS UInt32) as "population_city", CAST(defaultValueOfTypeName('String') AS String) as "jobs", CAST(40.1 AS Float64) as "merchant_lat", CAST(-74.1 AS Float64) as "merchant_lon", CAST(0 AS UInt8) as "target"
) select
    transaction_time,
    toDate(transaction_time) as transaction_date,
    toHour(transaction_time) as transaction_hour,
    toDayOfWeek(transaction_time) as day_of_week,
    trim(merch) as merchant_name,
    trim(cat_id) as category,
    amount,
    
    case
        when amount < 50 then 'small'
        when amount < 200 then 'medium'
        when amount < 1000 then 'large'
        else 'very_large'
    end
 as amount_segment,
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
from `__dbt__cte__fraud__transactions`