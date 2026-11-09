
  
    
    
    
        


        
  

  insert into `fraud`.`mart_daily_state_metrics`
        ("transaction_date", "us_state", "transactions_count", "total_amount", "avg_amount", "p95_amount", "large_transactions_share")

select
    transaction_date,
    us_state,
    count() as transactions_count,
    sum(amount) as total_amount,
    avg(amount) as avg_amount,
    quantile(0.95)(amount) as p95_amount,
    avg(is_large_transaction) as large_transactions_share
from `fraud`.`stg_transactions`
group by transaction_date, us_state
  