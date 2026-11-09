

  create or replace view `fraud`.`stg_transactions` 
  
    
  
  
    
    
  as (
    

select
    transaction_time,
    toDate(transaction_time) as transaction_date,
    toHour(transaction_time) as transaction_hour,
    toDayOfWeek(transaction_time) as day_of_week,
    trim(merch) as merchant_name,
    trim(cat_id) as category,
    amount,
    
    case
        when amount < 50 then 'small'
        when amount < 200 then 'medium'
        when amount < 1000 then 'large'
        else 'very_large'
    end
 as amount_segment,
    toUInt8(amount >= 500) as is_large_transaction,
    concat(trim(name_1), ' ', trim(name_2)) as customer_id,
    upper(gender) as gender,
    us_state,
    lat,
    lon,
    merchant_lat,
    merchant_lon,
    round(greatCircleDistance(lon, lat, merchant_lon, merchant_lat) / 1000, 2) as distance_km,
    target as is_fraud
from `fraud`.`transactions`
    
  )
      
      
                    -- end_of_sql
                    
                    