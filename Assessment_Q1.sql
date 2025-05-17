SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    -- Count savings plans (is_regular_savings = 1)
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN p.id END) AS savings_count,
    -- Count investment plans (is_a_fund = 1)
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN p.id END) AS investment_count,
    -- Sum all deposits (convert from kobo to currency)
    SUM(s.confirmed_amount)/100 AS total_deposits
FROM 
    users_customuser u
JOIN 
    plans_plan p ON u.id = p.owner_id
JOIN 
    savings_savingsaccount s ON p.id = s.plan_id
WHERE 
    p.is_deleted = 0  -- Only active plans
    AND p.is_archived = 0  -- Not archived
    AND s.confirmed_amount > 0  -- Only successful deposits
    AND s.transaction_status = 'success'  -- Only successful transactions
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    savings_count > 0 AND investment_count > 0  -- Must have both types
ORDER BY 
    total_deposits DESC;  -- Show biggest depositors first
