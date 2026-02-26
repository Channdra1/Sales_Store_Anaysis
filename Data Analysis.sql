/* DATA ANALYSIS INSIDE stg_Sales */

--- Q1 What are the TOP 5 most selling products by quantity ?
--- Business Problem: We don't know which products are most in demand?

--- Business Impact: Helps priortize stock and boost sales though targeted promotions.

SELECT
	TOP 5
	product_name,
	SUM(quantity) "Total_QuantitY_Sold"
FROM stg_sales WHERE status = 'delivered' GROUP BY product_name
ORDER BY Total_QuantitY_Sold desc

--- Q2 Which product are most frequently cancelled?
--- Business Problem: Frequent cancellations affect revenue and customer trust.

--- Business Impact: Identify poor-performing products to improve quality or remove from catalog.
SELECT
	TOP 5
	product_name , count(*) "Total_Cancelled_Products"
FROM stg_sales WHERE status = 'Cancelled' 
GROUP BY product_name
ORDER BY Total_Cancelled_Products DESC

---Q3 What time of the day has the highest number of Purchase?
--- Business Problem Solved: Find Peak Sales Times 

--- Business Impact: Optimize Staffing, promotions and server loads.

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

---Q4 Who are the TOP 5 spending customers
--- Business Problem Solved: Identify VIP customers

--- Business Impact: Personlized offers, loyalty rewards, and retention.

SELECT
	TOP 5
	customer_name,
	FORMAT(Total_Spend , 'C0' , 'en-IN') as "Total_Spending"
FROM (
SELECT
	customer_name,
	SUM(price * quantity) AS "Total_Spend"
FROM stg_sales
GROUP BY customer_name  ) T 
ORDER BY Total_Spend DESC

---Q5 Which product categories generate the highest revenue.
--- Business Problem Solved: Identify TOP performing product categories.

--- Business Impact: Allowing the busines to invest more in high margin or high demand category.

SELECT
	TOP 1
	product_category,
	FORMAT(Total_Revenue , 'C0' , 'en-IN') as "Format"
FROM (
SELECT 
product_category , 
SUM(price * quantity) "Total_Revenue" 
FROM stg_sales
GROUP BY product_category ) t
ORDER BY Total_Revenue desc

---Q5 What is the return/Cancellation rate per category?
--- Business Problem: Monitor Dissatisfaction trend per category

--- Business Impact: Reduce returns, improve product description/expectations. 
--- Helps identify and fix product or logistics issue.

--- % For both 'returned' , 'cancelled'
;with cte as (
SELECT
	product_category,
	COUNT(*) AS "Total_Count",
	SUM(CASE WHEN status IN ('returned' , 'cancelled') THEN 1 ELSE 0 END  ) AS "Total_Return/Cancelled"
FROM stg_sales
GROUP BY product_category )
SELECT *, FORMAT(CAST([Total_Return/Cancelled] AS DECIMAL(10,4))/Total_Count,'P2') AS "Difference_%" FROM cte

--- ONLY % 'cancelled'
;with cte as (
SELECT
	product_category,
	COUNT(*) AS "Total_Count",
	SUM(CASE WHEN status IN ('cancelled') THEN 1 ELSE 0 END  ) AS "Total_Cancelled"
FROM stg_sales
GROUP BY product_category )
SELECT *, FORMAT(CAST([Total_Cancelled] AS DECIMAL(10,4))/Total_Count,'P2') AS "Difference_Value" FROM cte

--- ONLY % 'returned'

;with cte as (
SELECT
	product_category,
	COUNT(*) AS "Total_Count",
	SUM(CASE WHEN status IN ('returned') THEN 1 ELSE 0 END  ) AS "Total_Returned"
FROM stg_sales
GROUP BY product_category )
SELECT *, FORMAT(CAST([Total_Returned] AS DECIMAL(10,4))/Total_Count,'P2') AS "Difference_Value" FROM cte

--- IN DIFFERENT WAY

-- Cancellation
SELECT
	product_category,
	FORMAT(COUNT(CASE WHEN status ='Cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS "Total_%_Cancelled"
FROM stg_sales
GROUP BY product_category
ORDER BY [Total_%_Cancelled] dESC

-- Return
SELECT
	product_category,
	FORMAT(COUNT(CASE WHEN status ='returned' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS "Total_%_Returned"
FROM stg_sales
GROUP BY product_category
ORDER BY [Total_%_Returned] dESC

---Q6 what is the most prefered payment mode?
--- Business Problem Solved: Known which payment method customer prefers the most

--- Business Impact: Streamline payment processing, prioritize popular modes.

SELECT 
	payment_mode,
	count(*) AS "Total_Payment"
FROM stg_sales 
GROUP BY payment_mode
ORDER BY Total_Payment desc

---Q6 How does age_group affect purchasing behaviour.
--- Business Problem Solved: Understand Customer Demographic

--- Business Impact: Targeted marketing and product recommendations by age_group

SELECT 
MIN(customer_age) , MAX(customer_age)
FROM stg_sales

SELECT 
	CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+' END AS "Customer_Age",
		FORMAT(SUM(price*quantity), 'C0' , 'en-IN') AS "Total_Purchase"
FROM stg_sales
GROUP BY 
CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+' END
ORDER BY Total_Purchase DESC

---Q7 What's the montly sales trend?
--- Business Problem Solved: Sales fluctuation go unnoticed

--- Business Impact: Plan inventory and marketing according to seasonal trends.

SELECT
	FORMAT(purchase_date , 'yyyy-MM') as Month_Year,
	DATENAME(MONTH, purchase_date) AS "Month_Name",
	FORMAT(SUM(price * quantity), 'C0' , 'en-IN') AS Total_Sales,
	SUM(quantity) AS Total_Quantity
FROM stg_sales
GROUP BY FORMAT(purchase_date , 'yyyy-MM') , DATENAME(MONTH, purchase_date)
ORDER BY FORMAT(purchase_date , 'yyyy-MM') , DATENAME(MONTH, purchase_date)

---Q8 Are certain genders buying more specific product categories?
--- Business Problem: Gender Based Product Prefrences

--- Business Impact: Personalized ads, gender-focused campaigns.

--- Method 1
SELECT 
	gender ,
	product_category,
	COUNT(product_category) AS "Total_Product"
FROM stg_sales
GROUP BY gender , product_category
ORDER BY gender

--- Method 2

SELECT * FROM (
SELECT 
	gender,
	product_category
FROM stg_sales ) AS Source_Table
PIVOT (
	COUNT(gender)
	FOR gender IN ([M],[F])
	) AS Pivot_Table
ORDER BY product_category



