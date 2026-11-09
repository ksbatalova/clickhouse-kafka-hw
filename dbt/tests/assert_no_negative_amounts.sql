-- Тест падает, если есть транзакции с отрицательной суммой
select *
from {{ ref('stg_transactions') }}
where amount < 0
