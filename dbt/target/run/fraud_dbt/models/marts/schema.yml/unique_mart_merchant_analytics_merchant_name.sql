
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    merchant_name as unique_field,
    count(*) as n_records

from `fraud`.`mart_merchant_analytics`
where merchant_name is not null
group by merchant_name
having count(*) > 1



  
  
    ) dbt_internal_test