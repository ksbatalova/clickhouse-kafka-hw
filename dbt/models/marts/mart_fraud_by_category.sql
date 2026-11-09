{{ config(order_by='category') }}

with agg as (
    select
        category,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount
    from {{ ref('stg_transactions') }}
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
