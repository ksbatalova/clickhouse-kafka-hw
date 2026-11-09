

with agg as (
    select
        merchant_name,
        count() as total_transactions,
        sum(amount) as turnover,
        avg(amount) as avg_amount,
        sum(is_fraud) as fraud_transactions,
        uniqExact(customer_id) as unique_customers
    from `fraud`.`stg_transactions`
    group by merchant_name
),

rated as (
    select
        *,
        round(100 * fraud_transactions / total_transactions, 4) as fraud_rate
    from agg
)

select
    *,
    toUInt8(total_transactions >= 20 and fraud_rate >= 2) as is_suspicious
from rated