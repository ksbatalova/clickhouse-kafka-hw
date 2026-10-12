SELECT
    us_state AS state,
    argMax(cat_id, cat_max) AS top_category,
    max(cat_max) AS max_amount
FROM
(
    SELECT us_state, cat_id, max(amount) AS cat_max
    FROM fraud.transactions_opt
    GROUP BY us_state, cat_id
)
GROUP BY us_state
ORDER BY us_state;