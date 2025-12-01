-- 02_business_questions.sql
-- Business-focused analysis on Walmart store sales

-- Q1. Top 10 stores by total sales
SELECT
    Store,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY Store
ORDER BY total_sales DESC
LIMIT 10;

-- Q2. Stores with the most volatile weekly sales (highest standard deviation)
SELECT
    Store,
    ROUND(AVG(Weekly_Sales), 2) AS avg_sales,
    ROUND(STDDEV(Weekly_Sales), 2) AS sd_sales,
    ROUND(STDDEV(Weekly_Sales) / NULLIF(AVG(Weekly_Sales), 0), 3) AS coeff_variation
FROM walmart_store_sales_v
GROUP BY Store
ORDER BY sd_sales DESC
LIMIT 10;

-- Q3. Quarterly sales by store, then Q3 2012 growth vs previous quarter
WITH sales_by_store_quarter AS (
    SELECT
        Store,
        YEAR(Date) AS year,
        QUARTER(Date) AS quarter,
        SUM(Weekly_Sales) AS total_sales
    FROM walmart_store_sales_v
    GROUP BY Store, YEAR(Date), QUARTER(Date)
)
SELECT
    Store,
    total_sales AS q3_2012_sales,
    LAG(total_sales) OVER (PARTITION BY Store ORDER BY year, quarter) AS previous_quarter_sales,
    ROUND(
        (total_sales - LAG(total_sales) OVER (PARTITION BY Store ORDER BY year, quarter))
        / NULLIF(LAG(total_sales) OVER (PARTITION BY Store ORDER BY year, quarter), 0) * 100,
        2
    ) AS qoq_growth_percent
FROM sales_by_store_quarter
WHERE year = 2012 AND quarter = 3
ORDER BY qoq_growth_percent DESC;

-- Q4. Holiday weeks vs non-holiday weeks: average weekly sales
SELECT
    CASE WHEN Holiday_Flag = 1 THEN 'Holiday week' ELSE 'Non-holiday week' END AS week_type,
    ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales,
    COUNT(*) AS num_weeks
FROM walmart_store_sales_v
GROUP BY week_type;

-- Q5. Holiday weeks that outperform the non-holiday average
WITH non_holiday_mean AS (
    SELECT AVG(Weekly_Sales) AS avg_non_holiday_sales
    FROM walmart_store_sales_v
    WHERE Holiday_Flag = 0
)
SELECT
    Date,
    Store,
    Weekly_Sales
FROM walmart_store_sales_v, non_holiday_mean
WHERE Holiday_Flag = 1
  AND Weekly_Sales > avg_non_holiday_sales
ORDER BY Weekly_Sales DESC;

-- Q6. Monthly total sales (all stores)
SELECT
    YEAR(Date) AS year,
    MONTH(Date) AS month,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY year, month;

-- Q7. Half-year (H1/H2) total sales
SELECT
    YEAR(Date) AS year,
    CASE
        WHEN MONTH(Date) BETWEEN 1 AND 6 THEN 'H1'
        ELSE 'H2'
    END AS half_year,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY YEAR(Date), half_year
ORDER BY year, half_year;

-- Q8. Sales by temperature band
SELECT
    CASE
        WHEN Temperature < 40 THEN '< 40°F'
        WHEN Temperature BETWEEN 40 AND 60 THEN '40–60°F'
        WHEN Temperature BETWEEN 60 AND 80 THEN '60–80°F'
        ELSE '> 80°F'
    END AS temp_band,
    ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales,
    COUNT(*) AS num_records
FROM walmart_store_sales_v
GROUP BY temp_band
ORDER BY temp_band;

-- Q9. Sales by unemployment band
SELECT
    CASE
        WHEN Unemployment < 6 THEN '< 6%'
        WHEN Unemployment BETWEEN 6 AND 8 THEN '6–8%'
        ELSE '> 8%'
    END AS unemployment_band,
    ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales,
    COUNT(*) AS num_records
FROM walmart_store_sales_v
GROUP BY unemployment_band
ORDER BY unemployment_band;

-- Q10. Top 10 weeks (dates) by total sales across all stores
SELECT
    Date,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY Date
ORDER BY total_sales DESC
LIMIT 10;
