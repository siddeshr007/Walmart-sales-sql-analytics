-- 01_exploration.sql
-- Basic exploration of Walmart store sales data

-- 1. Row count
SELECT COUNT(*) AS row_count
FROM walmart_store_sales_v;

-- 2. Date range of data
SELECT
    MIN(Date) AS first_date,
    MAX(Date) AS last_date
FROM walmart_store_sales_v;

-- 3. Number of stores
SELECT COUNT(DISTINCT Store) AS num_stores
FROM walmart_store_sales_v;

-- 4. Basic stats: total and average weekly sales (all records)
SELECT
    ROUND(SUM(Weekly_Sales), 2) AS total_weekly_sales,
    ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales
FROM walmart_store_sales_v;

-- 5. Holiday vs non-holiday record counts
SELECT
    Holiday_Flag,
    COUNT(*) AS num_weeks
FROM walmart_store_sales_v
GROUP BY Holiday_Flag;
