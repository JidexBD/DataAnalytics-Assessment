WITH customer_transactions AS (
    SELECT 
        u.id AS owner_id,
        u.first_name,
        u.last_name,
        COUNT(*) AS transaction_count,
        GREATEST(1, TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1 AS months_active
    FROM 
        users_customuser u
    JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        s.transaction_status = 'successful'
        AND s.transaction_date IS NOT NULL
    GROUP BY 
        u.id, u.first_name, u.last_name
    HAVING 
        COUNT(*) > 0
),

frequency_calculation AS (
    SELECT 
        owner_id,
        TRIM(CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, ''))) AS customer_name,
        transaction_count,
        months_active,
        transaction_count/months_active AS transactions_per_month,
        CASE 
            WHEN (transaction_count/months_active) >= 10 THEN 'High Frequency'
            WHEN (transaction_count/months_active) >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM 
        customer_transactions
)

SELECT 
    frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(transactions_per_month), 1) AS avg_transactions_per_month
FROM 
    frequency_calculation
WHERE 
    customer_name IS NOT NULL
    AND customer_name != ''
GROUP BY 
    frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;