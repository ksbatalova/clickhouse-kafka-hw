
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select merchant_name
from `fraud`.`mart_merchant_analytics`
where merchant_name is null



  
  
    ) dbt_internal_test