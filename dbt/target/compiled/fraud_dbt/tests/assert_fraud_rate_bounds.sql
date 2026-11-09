-- Тест падает, если fraud_rate выходит за границы 0-100
select *
from `fraud`.`mart_fraud_by_category`
where fraud_rate > 100 or fraud_rate < 0