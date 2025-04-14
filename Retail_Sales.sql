--CREATING TABLE--

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
		(
			transactions_id	INT PRIMARY KEY,
			sale_date DATE,	
			sale_time TIME,
			customer_id INT,	
			gender VARCHAR(15),	
			age	INT,
			category VARCHAR(15),	
			quantiy	INT,
			price_per_unit FLOAT,	
			cogs FLOAT,	
			total_sale FLOAT
		);

SELECT * FROM retail_sales	
LIMIT 10

SELECT 
	COUNT(*) 
FROM retail_sales

----Data Cleaning----

SELECT * FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL

--------

DELETE FROM retail_sales
WHERE
	transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	age IS NULL
	OR
	category IS NULL
	OR
	quantiy IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL

----Data Exploration-------

--How many Sales we have?
SELECT COUNT(*) AS total_sale FROM retail_sales

--How many Customers we have?
SELECT COUNT(DISTINCT customer_id) AS total_customers FROM retail_sales  ----FOR DISTINCT CUSTOMERS---

--Number of Categories
SELECT COUNT(DISTINCT category) AS total_categories FROM retail_sales

SELECT DISTINCT category AS category_name FROM retail_sales ---FOR NAME OF CATEGORIES

----Data Analysis----

-- 1. Write a SQL query to retrieve all columns for sales made on '2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- 2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022

SELECT
	CATEGORY,
	SUM(QUANTIY)               ----TO Check Number of Categories in this case----
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Clothing'
	AND TO_CHAR(SALE_DATE, 'YYYY-MM') = '2022-11'
GROUP BY	1


SELECT *            
FROM
	RETAIL_SALES
WHERE
	CATEGORY = 'Clothing'
	AND TO_CHAR(SALE_DATE, 'YYYY-MM') = '2022-11'
	AND quantiy >= 4
	
---3. Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
    category,
    SUM(total_sale) as net_sale,
    COUNT(*) as total_orders
FROM retail_sales
GROUP BY 1


--4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT
    ROUND(AVG(age), 2) as avg_age
FROM retail_sales
WHERE category = 'Beauty'


---5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales
WHERE total_sale > 1000


----6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT 
    category,
    gender,
    COUNT(*) as total_trans
FROM retail_sales
GROUP 
    BY 
    category,
    gender
ORDER BY 1


----7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
SELECT 
       year,
       month,
    avg_sale
FROM 
(    
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    EXTRACT(MONTH FROM sale_date) as month,
    AVG(total_sale) as avg_sale,
    RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank
FROM retail_sales
GROUP BY 1, 2
) as t1
WHERE rank = 1


--8. Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT 
    customer_id,
    SUM(total_sale) as total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5


--9. Write a SQL query to find the number of unique customers who purchased items from each category
SELECT 
    category,    
    COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category


----10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)
WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift


----------------------------------
------Queries Created By Me------

--11. Sales Performance by Gender and Age Group
SELECT 
    gender,
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 24 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        WHEN age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender, age_group
ORDER BY gender, age_group;

-- 12. Top-Selling Products by Category
SELECT 
    category, 
    SUM(total_sale) AS total_sales,
    COUNT(*) AS number_of_orders
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;

--13. Customer Purchase Behavior Analysis (Repeat Purchases)
SELECT 
    customer_id,
    COUNT(DISTINCT transactions_id) AS total_transactions,
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(DISTINCT transactions_id) > 1
ORDER BY total_spent DESC;

--14. Find Most Popular Time of Day for Purchases
SELECT 
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(*) AS number_of_orders
FROM retail_sales
GROUP BY time_of_day
ORDER BY number_of_orders DESC;

--15. Monthly Sales Growth
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS total_sales,
    LAG(SUM(total_sale)) OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY EXTRACT(MONTH FROM sale_date)) AS previous_month_sales,
    SUM(total_sale) - LAG(SUM(total_sale)) OVER (PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY EXTRACT(MONTH FROM sale_date)) AS month_growth
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

--16. Find Most Profitable Categories
SELECT 
    category,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;

--17. Find the Best Month for Each Category (Highest Sales)
SELECT 
    category,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS total_sales,
    RANK() OVER(PARTITION BY category ORDER BY SUM(total_sale) DESC) AS rank
FROM retail_sales
GROUP BY category, month
HAVING rank = 1
ORDER BY category, total_sales DESC;

--18. Customers with the Highest Frequency of Purchases
SELECT 
    customer_id,
    COUNT(*) AS transaction_count,
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY transaction_count DESC
LIMIT 5;

--19. Find Peak Hours for Each Day of the Week
SELECT 
    TO_CHAR(sale_date, 'Day') AS day_of_week,
    EXTRACT(HOUR FROM sale_time) AS hour,
    COUNT(*) AS number_of_sales
FROM retail_sales
GROUP BY day_of_week, hour
ORDER BY day_of_week, hour;

--20. Comparison of Sales by Gender
SELECT 
    gender,
    SUM(total_sale) AS total_sales,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY gender
ORDER BY total_sales DESC;



------Findings----

--Customer Demographics: The dataset reveals a diverse customer base across various age groups, with significant sales across categories like Clothing and Beauty.

--Premium Purchases: A notable portion of transactions exceeded 1000 in total sale value, highlighting the presence of high-value purchases.

--Sales Trends: Monthly sales data demonstrates fluctuations, allowing us to pinpoint peak sales periods and seasonal trends.

--Customer Insights: The analysis identifies top-spending customers and reveals the most popular product categories, offering valuable insights into purchasing behavior.


---------------------------------------------------------
-------------Customer Behavior Insights:----------------


--Identified top-spending customers based on their total purchase value.

--Highlighted the most popular and profitable product categories.

--Analyzed repeat purchases to understand customer loyalty.

--Explored time-of-day and day-of-week trends to optimize operational hours.




