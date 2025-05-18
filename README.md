# DataAnalytics-Assessment
Cowrywise Assesment 

# SQL Analysis Solutions for Financial Data


### This README.md:
1. Contains all four solutions in one file
2. Uses proper Markdown formatting for GitHub
3. Includes both SQL code and human-readable explanations
4. Highlights specific challenges and solutions
5. Maintains consistent structure throughout

## Business Analytics SQL Queries

### 1. High-Value Customers with Multiple Products
**Objective:** Identify customers with both savings and investment plans.

```sql
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
```
## Approach:

Joined user, savings, and plan tables to get complete customer profiles

Used conditional counting to separate savings vs investment products

Implemented COALESCE to handle missing first/last names

Converted kobo to naira by dividing amounts by 100

Challenge Solved:
Initially got NULL names until I added both first_name and last_name to the GROUP BY clause.


### 2. Transaction Frequency Analysis
**Objective:** Categorize customers by transaction frequency.
``` sql
  WITH customer_transactions AS (
    SELECT 
        u.id AS owner_id,
        u.first_name,
        u.last_name,
        COUNT(*) AS transaction_count,
        GREATEST(1, TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), MAX(s.transaction_date)) + 1) AS months_active
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
)
SELECT 
    CASE 
        WHEN (transaction_count/months_active) >= 10 THEN 'High Frequency'
        WHEN (transaction_count/months_active) >= 3 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(*) AS customer_count,
    ROUND(AVG(transaction_count/months_active), 1) AS avg_transactions_per_month
FROM 
    customer_transactions
GROUP BY 
    frequency_category
ORDER BY 
    CASE frequency_category
        WHEN 'High Frequency' THEN 1
        WHEN 'Medium Frequency' THEN 2
        ELSE 3
    END;
```
## Approach:
Created activity windows using date differences

Used GREATEST() to ensure minimum 1 month activity

Established clear frequency thresholds

Added NULL checks for data quality

Challenge Solved:
First version undercounted months - fixed by adding +1 to include partial months.


###  Account Inactivity Alert
**Objective: Flag dormant accounts with no transactions in 1 year.** 
```sql
SELECT 
    p.id AS plan_id,
    p.owner_id,
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
GROUP BY 
    p.id, p.owner_id, type
HAVING 
    MAX(s.transaction_date) IS NULL
    OR DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) > 365
ORDER BY 
    inactivity_days DESC;
```
## Approach:
Classified accounts by product type

Calculated precise inactivity periods

Excluded deleted/archived accounts

Handled never-transacted accounts separately

Challenge Solved:
Had to verify whether NULL dates meant no transactions or missing data.


### 4. Customer Lifetime Value Estimation
**Objective:** Calculate customer value based on transaction history.
```sql
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
```
## Approach:
Combined first/last names with proper NULL handling

Calculated precise customer tenure

Implemented NULLIF to prevent division by zero

Formatted currency output clearly

Challenge Solved:
Early versions showed messy decimal amounts until I added ROUND().

## Note 
Currency Handling: All amounts divided by 100 to convert kobo to naira
Name Formatting: Used CONCAT with COALESCE for consistent naming
Data Quality: Added NULL checks throughout all queries
Performance: Optimized JOINs and WHERE clauses


