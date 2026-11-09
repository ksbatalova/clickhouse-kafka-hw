
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_hour
from `fraud`.`mart_hourly_fraud_pattern`
where transaction_hour is null



  
  
    ) dbt_internal_test