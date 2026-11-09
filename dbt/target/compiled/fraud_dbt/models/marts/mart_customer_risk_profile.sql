

with customers as (
    select
        customer_id,
        count() as transactions_count,
        sum(amount) as total_amount,
        avg(amount) as avg_amount,
        sum(is_fraud) as fraud_transactions,
        uniqExact(merchant_name) as unique_merchants,
        min(transaction_time) as first_transaction_at,
        max(transaction_time) as last_transaction_at
    from `fraud`.`stg_transactions`
    group by customer_id
),

rated as (
    select
        *,
        round(100 * fraud_transactions / transactions_count, 4) as fraud_rate
    from customers
)

select
    *,
    case
        when fraud_rate >= 5 then 'HIGH'
        when fraud_transactions > 0 then 'MEDIUM'
        else 'LOW'
    end as risk_segment
from rated