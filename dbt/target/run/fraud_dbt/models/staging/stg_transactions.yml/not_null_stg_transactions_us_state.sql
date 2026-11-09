
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select us_state
from `fraud`.`stg_transactions`
where us_state is null



  
  
    ) dbt_internal_test