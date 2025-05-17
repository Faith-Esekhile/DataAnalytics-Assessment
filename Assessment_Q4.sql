WITH customer_stats AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
        COUNT(s.id) AS total_transactions,
        SUM(s.confirmed_amount)/100 AS total_deposit_value  -- Convert from kobo to currency
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.confirmed_amount > 0
        AND s.transaction_status = 'success'
    GROUP BY 
        u.id, u.first_name, u.last_name, u.date_joined
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    ROUND(
        (total_transactions / NULLIF(tenure_months, 0)) * 12 * 
        (0.001 * (total_deposit_value / NULLIF(total_transactions, 0))),
        2
    ) AS estimated_clv
FROM 
    customer_stats
WHERE 
    tenure_months > 0
    AND total_transactions > 0
ORDER BY 
    estimated_clv DESC;
