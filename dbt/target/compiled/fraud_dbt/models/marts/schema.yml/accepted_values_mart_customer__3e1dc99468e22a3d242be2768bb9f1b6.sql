
    
    

with all_values as (

    select
        risk_segment as value_field,
        count(*) as n_records

    from `fraud`.`mart_customer_risk_profile`
    group by risk_segment

)

select *
from all_values
where value_field not in (
    'HIGH','MEDIUM','LOW'
)


