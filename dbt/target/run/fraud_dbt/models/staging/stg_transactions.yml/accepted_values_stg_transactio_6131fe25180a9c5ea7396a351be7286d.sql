
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        amount_segment as value_field,
        count(*) as n_records

    from `fraud`.`stg_transactions`
    group by amount_segment

)

select *
from all_values
where value_field not in (
    'small','medium','large','very_large'
)



  
  
    ) dbt_internal_test