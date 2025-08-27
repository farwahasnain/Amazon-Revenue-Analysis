-- Total Revenue (in dollars)

SELECT SUM(price) AS total_revenue
FROM amazon_data;

-- Revenue by Product Category

SELECT 
    product_category,
    SUM(price) AS category_total_revenue,
    SUM(SUM(price)) OVER () AS total_revenue
FROM amazon_data
GROUP BY product_category
ORDER BY 2 desc;

-- Revenue contribution by category

SELECT product_category,
       SUM(price) AS total_revenue,
       100.0 * SUM(price) / SUM(SUM(price)) OVER() AS pct_of_total_revenue
FROM amazon_data
GROUP BY product_category
ORDER BY product_category;
    
-- Number of Orders Per Category. 
-- The higher number of orders, the more popular the category is.

SELECT product_category, COUNT(*) AS number_of_orders
FROM amazon_data
GROUP BY product_category
ORDER BY 2 desc;

-- TOP 5 Products by Sales

SELECT product_description, SUM(price) AS total_sales
FROM amazon_data
GROUP BY product_description
ORDER BY total_sales DESC
LIMIT 5;

-- Analyzing Customer Behaviour and Engagement 
-- Engagement after Purchase
-- Review to Sales Ratio

SELECT product_category,
       SUM(number_of_reviews) / NULLIF(SUM(price), 0) AS reviews_to_sales_ratio
FROM amazon_data
GROUP BY product_category
ORDER BY 2 desc;

-- Monthly Sales Trend

SELECT 
    DATE_FORMAT(order_date, '%Y-%m-01') AS month,
    SUM(price) AS monthly_sales
FROM 
    amazon_data
GROUP BY 
    month
ORDER BY 
    month;
    
-- Analyze the Count of Orders on Weekdays and Weekends

SELECT 
  CASE 
    WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'  -- Sunday=1, Saturday=7
    ELSE 'Weekday'
  END AS day_type,
  COUNT(*) AS number_of_orders
FROM amazon_data
GROUP BY day_type;

-- Analyze the Revenue on Weekdays and Weekends

SELECT 
  CASE 
    WHEN DAYOFWEEK(order_date) IN (1, 7) THEN 'Weekend'  -- Sunday=1, Saturday=7
    ELSE 'Weekday'
  END AS day_type,
  SUM(price) AS Total_Revenue
FROM amazon_data
GROUP BY day_type;

-- Sales by Month

SELECT 
	DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    SUM(price) AS total_revenue
FROM amazon_data
GROUP BY sales_month
ORDER BY sales_month DESC;

-- Using CTE to get Month-Over-Month Sales Growth Percentage

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(price) AS total_revenue
    FROM amazon_data
    GROUP BY sales_month
),
with_lag AS (
    SELECT 
        sales_month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY sales_month) AS last_month_revenue
    FROM monthly_sales
)
SELECT 
    sales_month,
    total_revenue,
    last_month_revenue,
    ROUND(
        (total_revenue - last_month_revenue) / NULLIF(last_month_revenue, 0) * 100, 
        2
    ) AS mom_growth_percent
FROM with_lag;