





with validation_errors as (

    select
        day_of_week, transaction_hour
    from `fraud`.`mart_hourly_fraud_pattern`
    group by day_of_week, transaction_hour
    having count(*) > 1

)

select *
from validation_errors


