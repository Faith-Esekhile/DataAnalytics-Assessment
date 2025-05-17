WITH customer_stats AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(u.first_name, ' ', u.last_name) AS name,
        -- Months since customer joined
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
        -- Count of all transactions
        COUNT(s.id) AS total_transactions,
        -- Total deposit value (converted from kobo)
        SUM(s.confirmed_amount)/100 AS total_deposit_value
    FROM 
        users_customuser u
    LEFT JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.confirmed_amount > 0  -- Only deposits
        AND s.transaction_status = 'success'  -- Only successful
    GROUP BY 
        u.id, u.first_name, u.last_name, u.date_joined
)
SELECT 
    customer_id,
    name,
    tenure_months,
    total_transactions,
    -- CLV calculation:
    -- (transactions per month) * 12 months * (0.1% of average transaction value)
    ROUND(
        (total_transactions / NULLIF(tenure_months, 0)) * 12 * 
        (0.001 * (total_deposit_value / NULLIF(total_transactions, 0))),
        2
    ) AS estimated_clv
FROM 
    customer_stats
WHERE 
    tenure_months > 0  -- Exclude brand new customers
    AND total_transactions > 0  -- Must have at least one transaction
ORDER BY 
    estimated_clv DESC;  -- Show most valuable first
