
    
    

with all_values as (

    select
        is_large_transaction as value_field,
        count(*) as n_records

    from `fraud`.`stg_transactions`
    group by is_large_transaction

)

select *
from all_values
where value_field not in (
    0,1
)


