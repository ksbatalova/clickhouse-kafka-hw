{{ config(order_by='(transaction_date, us_state)') }}

select
    transaction_date,
    us_state,
    count() as transactions_count,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    quantile(0.95)(amount) as p95_amount,
    avg(is_large_transaction) as large_transactions_share
from {{ ref('stg_transactions') }}
group by transaction_date, us_state
