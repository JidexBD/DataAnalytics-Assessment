SELECT 
    u.id AS owner_id,
    CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS name,
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) AS savings_count,
    COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) AS investment_count,
    SUM(s.confirmed_amount)/100 AS total_deposits
FROM 
    users_customuser u
JOIN 
    savings_savingsaccount s ON u.id = s.owner_id
JOIN 
    plans_plan p ON s.plan_id = p.id
WHERE 
    s.confirmed_amount > 0
GROUP BY 
    u.id, u.first_name, u.last_name
HAVING 
    COUNT(DISTINCT CASE WHEN p.is_regular_savings = 1 THEN s.id END) > 0
    AND COUNT(DISTINCT CASE WHEN p.is_a_fund = 1 THEN s.id END) > 0
ORDER BY 
    total_deposits DESC;