
    
    

select
    state_code as unique_field,
    count(*) as n_records

from `fraud`.`states`
where state_code is not null
group by state_code
having count(*) > 1


