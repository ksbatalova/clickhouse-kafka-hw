-- Тест падает, если фродовых транзакций по штату больше, чем всех
select *
from `fraud`.`mart_fraud_by_state`
where fraud_transactions > total_transactions