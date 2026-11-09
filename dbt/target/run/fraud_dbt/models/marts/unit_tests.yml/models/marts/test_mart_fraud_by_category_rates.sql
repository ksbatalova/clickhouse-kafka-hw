-- Build actual result given inputs
with dbt_internal_unit_test_actual as (
  select
    "category","total_transactions","fraud_transactions","fraud_rate","total_amount","fraud_amount", 'actual' as "actual_or_expected"
  from (
    

with  __dbt__cte__stg_transactions as (

-- Fixture for stg_transactions
select CAST(defaultValueOfTypeName('DateTime') AS DateTime) as "transaction_time", CAST(defaultValueOfTypeName('Date') AS Date) as "transaction_date", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "transaction_hour", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "day_of_week", CAST(defaultValueOfTypeName('String') AS String) as "merchant_name", CAST('A' AS String) as "category", CAST(100.0 AS Float64) as "amount", CAST(defaultValueOfTypeName('String') AS String) as "amount_segment", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "is_large_transaction", CAST(defaultValueOfTypeName('String') AS String) as "customer_id", CAST(defaultValueOfTypeName('String') AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "us_state", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "distance_km", CAST(1 AS UInt8) as "is_fraud"
union all
select CAST(defaultValueOfTypeName('DateTime') AS DateTime) as "transaction_time", CAST(defaultValueOfTypeName('Date') AS Date) as "transaction_date", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "transaction_hour", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "day_of_week", CAST(defaultValueOfTypeName('String') AS String) as "merchant_name", CAST('A' AS String) as "category", CAST(50.0 AS Float64) as "amount", CAST(defaultValueOfTypeName('String') AS String) as "amount_segment", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "is_large_transaction", CAST(defaultValueOfTypeName('String') AS String) as "customer_id", CAST(defaultValueOfTypeName('String') AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "us_state", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "distance_km", CAST(0 AS UInt8) as "is_fraud"
union all
select CAST(defaultValueOfTypeName('DateTime') AS DateTime) as "transaction_time", CAST(defaultValueOfTypeName('Date') AS Date) as "transaction_date", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "transaction_hour", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "day_of_week", CAST(defaultValueOfTypeName('String') AS String) as "merchant_name", CAST('B' AS String) as "category", CAST(10.0 AS Float64) as "amount", CAST(defaultValueOfTypeName('String') AS String) as "amount_segment", CAST(defaultValueOfTypeName('UInt8') AS UInt8) as "is_large_transaction", CAST(defaultValueOfTypeName('String') AS String) as "customer_id", CAST(defaultValueOfTypeName('String') AS String) as "gender", CAST(defaultValueOfTypeName('String') AS String) as "us_state", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lat", CAST(defaultValueOfTypeName('Float64') AS Float64) as "merchant_lon", CAST(defaultValueOfTypeName('Float64') AS Float64) as "distance_km", CAST(0 AS UInt8) as "is_fraud"
), agg as (
    select
        category,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount
    from `__dbt__cte__stg_transactions`
    group by category
)

select
    category,
    total_transactions,
    fraud_transactions,
    round(100 * fraud_transactions / total_transactions, 4) as fraud_rate,
    total_amount,
    fraud_amount
from agg
  ) _dbt_internal_unit_test_actual
),
-- Build expected result
dbt_internal_unit_test_expected as (
  select
    "category", "total_transactions", "fraud_transactions", "fraud_rate", "total_amount", "fraud_amount", 'expected' as "actual_or_expected"
  from (
    select CAST('A' AS String) as "category", CAST(2 AS UInt64) as "total_transactions", CAST(1 AS UInt64) as "fraud_transactions", CAST(50.0 AS Float64) as "fraud_rate", CAST(150.0 AS Float64) as "total_amount", CAST(100.0 AS Float64) as "fraud_amount"
union all
select CAST('B' AS String) as "category", CAST(1 AS UInt64) as "total_transactions", CAST(0 AS UInt64) as "fraud_transactions", CAST(0.0 AS Float64) as "fraud_rate", CAST(10.0 AS Float64) as "total_amount", CAST(0.0 AS Float64) as "fraud_amount"
  ) _dbt_internal_unit_test_expected
)
-- Union actual and expected results
select * from dbt_internal_unit_test_actual
union all
select * from dbt_internal_unit_test_expected