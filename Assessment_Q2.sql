WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        -- Count all successful transactions
        COUNT(s.id) AS transaction_count,
        -- Calculate months since customer joined
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months
    FROM 
        users_customuser u
    JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.confirmed_amount > 0  -- Only deposits
        AND s.transaction_status = 'success'  -- Only successful
    GROUP BY 
        u.id, u.date_joined
),
monthly_frequency AS (
    SELECT 
        customer_id,
        transaction_count,
        tenure_months,
        -- Calculate transactions per month
        CASE 
            WHEN tenure_months = 0 THEN transaction_count
            ELSE transaction_count / tenure_months
        END AS transactions_per_month
    FROM 
        customer_transactions
)
SELECT 
    -- Categorize customers
    CASE 
        WHEN transactions_per_month >= 10 THEN 'High Frequency'
        WHEN transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,  -- How many in each category
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    monthly_frequency
GROUP BY 
    frequency_category
ORDER BY 
    -- Order categories logically
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
