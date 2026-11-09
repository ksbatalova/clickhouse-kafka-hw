
  
    
    
    
        


        
  

  insert into `fraud`.`mart_fraud_by_state`
        ("us_state", "state_name", "region", "total_transactions", "fraud_transactions", "fraud_rate", "unique_customers", "unique_merchants", "total_amount", "fraud_amount")

with agg as (
    select
        us_state,
        count() as total_transactions,
        sum(is_fraud) as fraud_transactions,
        uniqExact(customer_id) as unique_customers,
        uniqExact(merchant_name) as unique_merchants,
        sum(amount) as total_amount,
        sumIf(amount, is_fraud = 1) as fraud_amount
    from `fraud`.`stg_transactions`
    group by us_state
)

select
    agg.us_state as us_state,
    states.state_name as state_name,
    states.region as region,
    agg.total_transactions as total_transactions,
    agg.fraud_transactions as fraud_transactions,
    round(100 * agg.fraud_transactions / agg.total_transactions, 4) as fraud_rate,
    agg.unique_customers as unique_customers,
    agg.unique_merchants as unique_merchants,
    agg.total_amount as total_amount,
    agg.fraud_amount as fraud_amount
from agg
left join `fraud`.`states` as states
    on agg.us_state = states.state_code
  