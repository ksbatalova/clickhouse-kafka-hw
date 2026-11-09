
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_hour
from `fraud`.`stg_transactions`
where transaction_hour is null



  
  
    ) dbt_internal_test