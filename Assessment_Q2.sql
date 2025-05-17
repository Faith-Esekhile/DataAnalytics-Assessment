-- Categorize customers by transaction frequency
WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        COUNT(s.id) AS transaction_count,
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months
    FROM 
        users_customuser u
    JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.confirmed_amount > 0
        AND s.transaction_status = 'success'
    GROUP BY 
        u.id, u.date_joined
),
monthly_frequency AS (
    SELECT 
        customer_id,
        transaction_count,
        tenure_months,
        CASE 
            WHEN tenure_months = 0 THEN transaction_count
            ELSE transaction_count / tenure_months
        END AS transactions_per_month
    FROM 
        customer_transactions
)
SELECT 
    CASE 
        WHEN transactions_per_month >= 10 THEN 'High Frequency'
        WHEN transactions_per_month >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    monthly_frequency
GROUP BY 
    frequency_category
ORDER BY 
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;
