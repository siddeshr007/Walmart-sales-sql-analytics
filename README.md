## Walmart Sales SQL Analytics (MySQL)



This project analyzes \*\*Walmart weekly store sales\*\* using pure \*\*SQL on MySQL\*\*.

It focuses on answering business questions about:



\- Which stores drive the most revenue?

\- How volatile are store sales week-to-week?

\- How do \*\*holiday weeks\*\* compare to normal weeks?

\- How do sales vary by \*\*month\*\* and \*\*half-year\*\*?

\- How do macro factors like \*\*temperature\*\* and \*\*unemployment\*\* relate to sales?



The project is designed to showcase SQL skills and business analysis for

Data/Business Analyst roles.



---



\### 🔧 Tech Stack



\- \*\*MySQL\*\* (with MySQL Workbench)

\- SQL features:

&nbsp; - Aggregations, GROUP BY

&nbsp; - Window functions (LAG)

&nbsp; - CTEs (WITH)

&nbsp; - Date functions, CASE expressions

\- Git \& GitHub

\- Markdown for documentation



---



\### 📊 Dataset



\- Name: \*\*Walmart Store Sales\*\* (`Walmart\_Store\_sales.csv`)

\- Grain: 1 row = weekly sales for one store

\- Database: `walmart\_sql\_db`

\- Base table: `walmart\_store\_sales`

\- Analysis view: `walmart\_store\_sales\_v` (converts date text to a proper DATE)



Key columns:



\- `Store` – store ID

\- `Date` – week of sales (in the view)

\- `Weekly\_Sales` – store’s weekly sales

\- `Holiday\_Flag` – 1 = holiday week, 0 = non-holiday

\- `Temperature` – local temperature

\- `Fuel\_Price` – local fuel price

\- `CPI` – consumer price index

\- `Unemployment` – local unemployment rate



---



\### ❓ Business Questions Answered



1\. Top stores by \*\*total sales\*\*.

2\. Stores with \*\*most volatile\*\* weekly sales (standard deviation \& coefficient of variation).

3\. Stores with strongest \*\*QoQ growth\*\* in Q3 2012.

4\. Comparison of \*\*holiday vs non-holiday\*\* week performance.

5\. Identification of holiday weeks that truly \*\*outperform normal weeks\*\*.

6\. Monthly and half-year (\*\*H1/H2\*\*) sales patterns.

7\. Relationship between \*\*Weekly\_Sales\*\* and:

&nbsp;  - Temperature bands

&nbsp;  - Unemployment bands

8\. Top 10 \*\*highest-sales weeks\*\* across the whole dataset.



All SQL is stored in:



\- `sql/01\_exploration.sql`

\- `sql/02\_business\_questions.sql`

---

### 📊 Dashboard Preview

Below is a Tableau dashboard built from the SQL outputs
(top stores, monthly trend, and holiday vs non-holiday performance):

![Walmart Sales SQL Dashboard](docs/walmart_sql_dashboard.png)

---

The business narrative and recommendations are in:



\- `docs/walmart\_sql\_case\_study.md`



---



\### 📂 Project Structure



```text

walmart-sales-sql-analytics/

├── data/

│   ├── raw/

│   │   └── Walmart\_Store\_sales.csv

│   └── processed/           # (reserved for any future exports)

├── docs/

│   └── walmart\_sql\_case\_study.md

├── sql/

│   ├── 01\_exploration.sql

│   └── 02\_business\_questions.sql

└── README.md

🚀 How to Reproduce the Analysis

Create MySQL schema \& table



Create database walmart\_sql\_db.



Create table walmart\_store\_sales with Date\_str (VARCHAR) for the date field.



Import the CSV file



Use MySQL Workbench’s Table Data Import Wizard to load

data/raw/Walmart\_Store\_sales.csv into walmart\_store\_sales, mapping:



Date (CSV) → Date\_str (table).



Create analysis view



sql

Copy code

CREATE OR REPLACE VIEW walmart\_store\_sales\_v AS

SELECT

&nbsp;   Store,

&nbsp;   STR\_TO\_DATE(Date\_str, '%d-%m-%Y') AS Date,

&nbsp;   Weekly\_Sales,

&nbsp;   Holiday\_Flag,

&nbsp;   Temperature,

&nbsp;   Fuel\_Price,

&nbsp;   CPI,

&nbsp;   Unemployment

FROM walmart\_store\_sales;

Run exploration queries



Execute sql/01\_exploration.sql in MySQL Workbench to verify row counts,

date range, and basic stats.



Run business analysis queries



Execute sql/02\_business\_questions.sql to answer all business questions

and export result sets if needed for reporting.



💼 Relevance for BA / DA Roles

This project demonstrates:



Comfort with real-world retail sales data.



Ability to write clear, performant SQL queries using:



aggregations, window functions, CTEs, and date logic.



Translating query results into actionable insights and recommendations

in a business-friendly narrative.





