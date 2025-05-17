WITH last_transactions AS (
    SELECT 
        p.id AS plan_id,
        p.owner_id,
        p.created_on AS plan_created_date,
        -- Classify account type
        CASE 
            WHEN p.is_regular_savings = 1 THEN 'Savings'
            WHEN p.is_a_fund = 1 THEN 'Investment'
            ELSE 'Other'
        END AS type,
        -- Find most recent transaction date
        MAX(s.transaction_date) AS last_transaction_date,
        -- Calculate days since last transaction
        DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days
    FROM 
        plans_plan p
    LEFT JOIN 
        savings_savingsaccount s ON p.id = s.plan_id
    WHERE 
        p.is_deleted = 0  -- Not deleted
        AND p.is_archived = 0  -- Not archived
        AND p.status_id = 1  -- Active status
        AND (s.id IS NULL OR s.transaction_status = 'success')  -- Only successful or no transactions
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
    -- No transactions AND created over a year ago
    (last_transaction_date IS NULL AND DATEDIFF(CURRENT_DATE, plan_created_date) > 365)
    -- OR last transaction was over a year ago
    OR inactivity_days > 365
ORDER BY 
    inactivity_days DESC;  -- Show longest inactive first
