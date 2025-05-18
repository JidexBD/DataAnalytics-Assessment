SELECT 
    u.id AS customer_id,
    CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS name,
    TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,
    COUNT(s.id) AS total_transactions,
    ROUND(
        (COUNT(s.id) / NULLIF(TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE), 0)) * 12 * 
        (SUM(s.confirmed_amount)/100 * 0.001), 
    2
    ) AS estimated_clv
FROM 
    users_customuser u
LEFT JOIN 
    savings_savingsaccount s ON u.id = s.owner_id
WHERE 
    s.transaction_status = 'successful'
    AND s.confirmed_amount > 0
GROUP BY 
    u.id, u.first_name, u.last_name, u.date_joined
HAVING 
    TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) > 0
ORDER BY 
    estimated_clv DESC;