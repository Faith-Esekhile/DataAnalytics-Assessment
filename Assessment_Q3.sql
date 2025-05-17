-- Find active accounts with no transactions in the last year
WITH last_transactions AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        p.created_on AS plan_created_date,
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        MAX(s.transaction_date) AS last_transaction_date,
        DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days
    FROM 
        plans_plan p
    LEFT JOIN 
        savings_savingsaccount s ON p.id = s.plan_id
    WHERE 
        p.is_deleted = 0 
        AND p.is_archived = 0
        AND p.status_id = 1      -- Assuming 1 means active status
        AND (s.id IS NULL OR s.transaction_status = 'success')
    GROUP BY 
        p.id, p.owner_id, p.created_on, type
)
SELECT 
    plan_id,
    owner_id,
    type,
    last_transaction_date,
    inactivity_days
FROM 
    last_transactions
WHERE 
    (last_transaction_date IS NULL AND DATEDIFF(CURRENT_DATE, plan_created_date) > 365)
    OR inactivity_days > 365
ORDER BY 
    inactivity_days DESC;
