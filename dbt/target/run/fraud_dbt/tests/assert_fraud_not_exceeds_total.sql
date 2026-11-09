
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Тест падает, если фродовых транзакций по штату больше, чем всех
select *
from `fraud`.`mart_fraud_by_state`
where fraud_transactions > total_transactions
  
  
    ) dbt_internal_test