
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        is_high_risk_window as value_field,
        count(*) as n_records

    from `fraud`.`mart_hourly_fraud_pattern`
    group by is_high_risk_window

)

select *
from all_values
where value_field not in (
    0,1
)



  
  
    ) dbt_internal_test