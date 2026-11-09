{{ config(order_by='(day_of_week, transaction_hour)') }}

with hourly as (
    select
        day_of_week,
        transaction_hour,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        round(100 * sum(is_fraud) / count(), 4) as fraud_rate
    from {{ ref('stg_transactions') }}
    group by day_of_week, transaction_hour
),

overall as (
    select round(100 * sum(is_fraud) / count(), 4) as overall_fraud_rate
    from {{ ref('stg_transactions') }}
)

select
    hourly.day_of_week as day_of_week,
    hourly.transaction_hour as transaction_hour,
    hourly.total_transactions as total_transactions,
    hourly.fraud_transactions as fraud_transactions,
    hourly.fraud_rate as fraud_rate,
    overall.overall_fraud_rate as overall_fraud_rate,
    toUInt8(hourly.fraud_rate > 2 * overall.overall_fraud_rate) as is_high_risk_window
from hourly
cross join overall
