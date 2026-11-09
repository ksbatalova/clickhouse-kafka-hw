-- Тест падает, если есть транзакции с отрицательной суммой
select *
from `fraud`.`stg_transactions`
where amount < 0