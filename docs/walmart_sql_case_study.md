# Walmart Sales SQL Analytics – Case Study

This project analyzes Walmart weekly store sales using **MySQL** and pure **SQL**.
The goal is to answer key business questions about store performance, holiday
impact, and macroeconomic factors such as temperature and unemployment.

---

## 1. Dataset & Setup

- Source: Walmart Store Sales dataset (`Walmart_Store_sales.csv`) – weekly sales by store
- DBMS: MySQL (accessed via MySQL Workbench)
- Database: `walmart_sql_db`
- Raw table: `walmart_store_sales` (date stored as text column `Date_str`)
- Analysis view: `walmart_store_sales_v`  
  - Uses `STR_TO_DATE(Date_str, '%d-%m-%Y')` to expose a proper `Date` column.

Main fields:

- `Store` – store ID (integer)
- `Date` – week of sales (in the view)
- `Weekly_Sales` – sales for that store-week
- `Holiday_Flag` – 1 = holiday week, 0 = non-holiday
- `Temperature` – temperature at the store’s location
- `Fuel_Price` – local fuel price
- `CPI` – consumer price index
- `Unemployment` – local unemployment rate

Basic stats (from `sql/01_exploration.sql`):

- Total rows: **[fill in COUNT(*) result, e.g., 6435]**
- Date range: **[first_date] to [last_date]** (e.g., 2010-02-05 to 2012-11-01)
- Number of stores: **[num_stores]**
- Total Weekly_Sales: **[total_weekly_sales]**
- Average Weekly_Sales: **[avg_weekly_sales]**

> Replace the placeholders above with the exact numbers you see when you run
> the exploration queries in MySQL.

---

## 2. Business Questions & SQL

The analysis is driven by the queries in `sql/02_business_questions.sql`, all
executed against the view `walmart_store_sales_v`.

### Q1. Which stores generate the highest total sales?

**SQL**

```sql
SELECT
    Store,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY Store
ORDER BY total_sales DESC
LIMIT 10;
Findings (example)

The top store (e.g., Store 20) has the highest total sales.

There is a noticeable drop after the top few stores, showing revenue is concentrated.

Business interpretation

Top stores are critical for overall revenue.

They are good candidates for:

extra operational protection (inventory, staffing)

deeper study to understand what drives their performance (location, store size, assortment).

Q2. Which stores have the most volatile weekly sales?
SQL

sql
Copy code
SELECT
    Store,
    ROUND(AVG(Weekly_Sales), 2) AS avg_sales,
    ROUND(STDDEV(Weekly_Sales), 2) AS sd_sales,
    ROUND(STDDEV(Weekly_Sales) / NULLIF(AVG(Weekly_Sales), 0), 3) AS coeff_variation
FROM walmart_store_sales_v
GROUP BY Store
ORDER BY sd_sales DESC
LIMIT 10;
Findings (example)

Some stores show very high standard deviation and coefficient of variation.

Others have similar average sales but much more stable week to week.

Business interpretation

Highly volatile stores are riskier for forecasting and staffing.

They may depend heavily on holidays, local events, or inconsistent execution.

More stable stores can be benchmarks for planning and best practices.

Q3. Which stores grew the most in Q3 2012?
SQL

sql
Copy code
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
Business interpretation

Identifies stores with the strongest QoQ growth in Q3 2012.

These stores might have:

strong local marketing

effective store managers

successful promotions.

They are good candidates for case studies and cross-store learning.

Q4. Do holiday weeks really boost sales?
SQL

sql
Copy code
SELECT
    CASE WHEN Holiday_Flag = 1 THEN 'Holiday week' ELSE 'Non-holiday week' END AS week_type,
    ROUND(AVG(Weekly_Sales), 2) AS avg_weekly_sales,
    COUNT(*) AS num_weeks
FROM walmart_store_sales_v
GROUP BY week_type;
Findings (example)

Holiday weeks show [higher / slightly higher / similar] average weekly sales vs non-holiday weeks.

Business interpretation

If holiday weeks clearly outperform:

holidays are key revenue events that should get special planning.

If the difference is small:

there may be an opportunity to strengthen holiday campaigns or pricing.

Q5. Which holiday weeks truly outperform a “normal” week?
SQL

sql
Copy code
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
Business interpretation

This isolates holiday weeks that beat the average non-holiday week.

Helps marketing focus on:

the holidays with strongest ROI,

underperforming holidays that may need better promotions.

Q6. How do sales change over months and half-years?
Monthly sales

sql
Copy code
SELECT
    YEAR(Date) AS year,
    MONTH(Date) AS month,
    ROUND(SUM(Weekly_Sales), 2) AS total_sales
FROM walmart_store_sales_v
GROUP BY YEAR(Date), MONTH(Date)
ORDER BY year, month;
Half-year (H1/H2) sales

sql
Copy code
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
Business interpretation

Highlights peak months (often late Q4) and whether H2 outperforms H1.

Supports:

capacity planning

inventory ramp-up,

seasonal marketing.

Q7. How do macro factors relate to sales?
By temperature band

sql
Copy code
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
By unemployment band

sql
Copy code
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
Business interpretation

Temperature bands:

Show whether extreme hot/cold periods are linked to higher or lower sales.

Unemployment bands:

Indicate whether stores are sensitive to local economic conditions
(e.g., lower sales at higher unemployment).

3. Recommendations
Based on the SQL analysis:

Protect high-volume stores

Ensure strong inventory and staffing where total sales are highest.

Use these stores as best-practice references.

Manage volatile stores more closely

Volatile stores require tighter forecasting and monitoring.

Investigate causes (events, promotions, supply issues).

Optimize holiday strategy

Double down on holidays that significantly outperform non-holiday weeks.

For weaker holidays, test different promotions or assortment.

Plan for seasonality

Use monthly and half-year trends to align marketing and inventory with demand peaks.

Monitor macroeconomic sensitivity

If sales are weaker in high-unemployment areas, consider tailored pricing or value-focused offers.

4. Project Files
sql/01_exploration.sql – row counts, date range, basic stats

sql/02_business_questions.sql – all business-focused SQL queries

docs/walmart_sql_case_study.md – this case study document

data/raw/Walmart_Store_sales.csv – original dataset

This project demonstrates practical SQL skills (aggregations, window functions,
CTEs, date handling) and the ability to translate technical outputs into
clear, business-oriented insights.

yaml
Copy code
