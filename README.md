# Sales Store Analysis – Business Insights Dashboard
A comprehensive end-to-end analytics project showcasing data analysis and visualization using SQL and Power BI to provide business insights for a retail sales dataset.

## Project Overview
This project demonstrates the full life cycle of data analytics:

1.Data exploration and business problem framing
2.SQL based data analysis and metric creation
3.Translation of business logic into DAX measures
4.Interactive Power BI dashboard design
5.Storytelling with insights — not just charts
6.Interpretation for informed business decisions

📌 Goal: Identify meaningful trends in sales, customer behavior, product performance, and operational issues such as cancellations and returns.

## Dataset Description
| Column            | Description                                      |
|-------------------|--------------------------------------------------|
| transaction_id    | Unique order identifier                          |
| customer_id       | Unique customer identifier                       |
| customer_name     | Customer name                                    |
| customer_age      | Age of the customer                              |
| gender            | Customer gender                                  |
| product_id        | Product identifier                               |
| product_name      | Product name                                     |
| product_category  | Category of the product                          |
| quantity          | Units sold                                       |
| price             | Price per unit                                   |
| payment_mode      | e.g., UPI, Card                                  |
| purchase_date     | Date of purchase                                 |
| time_of_purchase  | Time transaction occurred                        |
| status            | Order status (delivered/cancelled/returned)      |

## Business Questions (SQL + Power BI)

Each SQL query below answers a strategic business question. These were then translated to dynamic Power BI visuals using DAX.

Q1: Which products sell the most?

Business Insight:
Top selling products help identify customer demand and inventory priorities.

SELECT TOP 5 product_name, SUM(quantity) AS Total_Quantity
FROM stg_sales
WHERE status = 'delivered'
GROUP BY product_name
ORDER BY Total_Quantity DESC;

Q2: Which products have the most cancellations?

Business Insight:
High cancellation rates can signal quality or expectation mismatch.

SELECT TOP 5 product_name, COUNT(*) AS Total_Cancelled
FROM stg_sales
WHERE status = 'Cancelled'
GROUP BY product_name
ORDER BY Total_Cancelled DESC;

Q3: What time of day has the most purchases?

Business Insight:
Determines peak order times for operational planning.

SELECT
	CASE	
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) AS total_orders
FROM stg_sales
GROUP BY
	CASE	
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
		WHEN DATEPART(HOUR, time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
ORDER BY total_orders DESC

Q4: Who are the top 5 spending customers?

Business Insight:
Identifies high-ROI customers for loyalty and targeting programs.

SELECT TOP 5 customer_name,
FORMAT(SUM(price*quantity), 'C0', 'en-IN') AS Total_Spending
FROM stg_sales
GROUP BY customer_name
ORDER BY Total_Spending DESC;

Q5: Return / Cancellation Rate by Category

Business Insight:
Monitors product dissatisfaction by category.

Sample snippet:

SELECT product_category,
FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*), 'N3') + ' %' AS Total_%_Cancelled
FROM stg_sales
GROUP BY product_category;

Q6: Preferred Payment Mode
SELECT payment_mode, COUNT(*) AS Total_Payment
FROM stg_sales
GROUP BY payment_mode
ORDER BY Total_Payment DESC;

Q7: Monthly Sales Trend
SELECT FORMAT(purchase_date, 'yyyy-MM') AS Month_Year,
DATENAME(MONTH, purchase_date) AS Month_Name,
FORMAT(SUM(price*quantity), 'C0', 'en-IN') AS Total_Sales
FROM stg_sales
GROUP BY ...;

Q8: Gender vs Category Preference
SELECT gender, product_category, COUNT(*) AS Total_Product
FROM stg_sales
GROUP BY gender, product_category;

📊 Power BI Dashboard

The Power BI report implements the above SQL insights using dynamic DAX measures, ensuring:

✔ Filter-responsive analytics
✔ Ranking logic (TOP 5 / TOP 1)
✔ Conditional highlighting
✔ Time segmentation
✔ Cohesive narrative flow

DAX Measure Highlights
Example: Delivered Spend
Delivered Spend =
CALCULATE(
    SUMX(stg_sales, stg_sales[price]*stg_sales[quantity]),
    stg_sales[status] = "delivered"
)

Example: Category Rank
Category Rank =
RANKX(
    ALL(stg_sales[product_category]),
    [Delivered Revenue by Category],
    ,
    DESC
)

Example: Cancellation %
Cancellation % =
DIVIDE([Total Cancelled], [Total Orders], 0)

## Key Learnings

This project demonstrates analytical skills including:

✔ Data cleaning and type correction
✔ Translating SQL logic to DAX
✔ Dynamic ranking and percentage measures
✔ Interactive storytelling via visual design
✔ Business interpretation, not just visualization

📌 Business Impact Summary
| Insight                  | Value to Business                              |
|---------------------------|-----------------------------------------------|
| Top selling products      | Inventory & promotion prioritization          |
| Cancellation rates        | Quality & logistics improvement               |
| Peak purchase times       | Operational staffing optimization             |
| High-spending customers   | Loyalty & retention focus                     |
| Monthly trends            | Seasonal planning                             |

### Screenshots / Demos

![Dashboard Preview](Dashboard.png)
