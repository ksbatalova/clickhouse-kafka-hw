
    
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  -- Тест падает, если есть транзакции с отрицательной суммой
select *
from `fraud`.`stg_transactions`
where amount < 0
  
  
    ) dbt_internal_test