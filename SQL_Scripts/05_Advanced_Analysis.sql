
-- =====================================================
-- SCRIPT: 05_Advanced_Analysis.sql
-- PURPOSE: Perform advanced analysis using ranking,
--          cumulative revenue, and growth calculations.
-- =====================================================

-- =========================================
-- Q10: Product Ranking by Category
-- =========================================

-- Business Question:
-- Which products perform best within each product
-- category based on their total revenue?

WITH 
Product_revenue AS (
SELECT p.category,
       p.product_id,
       p.product_name,
       Round(SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)), 2) AS Total_revenue
FROM products AS p 
JOIN order_items AS oi 
  ON p.product_id = oi.product_id 
JOIN orders AS o 
  ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY p.category,
         p.product_id,
         p.product_name
) , 
product_ranking AS(
SELECT category,
       product_id,
       product_name,
       total_revenue,
       DENSE_RANK () over(
               PARTITION BY category
               ORDER BY total_revenue desc) AS Product_rank
FROM product_revenue                  
)
SELECT * 
FROM product_ranking
WHERE product_rank <= 3
ORDER BY 
     category ASC,
     product_rank ASC,
     total_revenue DESC;
       
 -- =========================================
-- Q11: Cumulative Monthly Revenue
-- =========================================

-- Business Question:
-- How does the business's revenue accumulate
-- month by month over time?
       
WITH 
monthly_revenue AS (
SELECT year(o.order_date) AS YEAR,
       DATE_FORMAT(o.order_date, '%M') AS MONTH,
       month(o.order_date) AS month_number,
       ROUND(SUM(p.net_order_amount), 2) AS Monthly_revenue
FROM orders AS o
JOIN payments AS p 
   ON p.order_id = o.order_id
WHERE (o.order_status = 'Delivered')
AND (o.order_date >= '2024-01-01'
    AND o.order_date < '2026-01-01')
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date),
    DATE_FORMAT(o.order_date, '%M')  
) ,
running_revenue AS (
SELECT YEAR,
       month,
       month_number,
       monthly_revenue,
       Round(SUM(monthly_revenue) OVER(
                              ORDER BY YEAR, month_number ASC
                              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ),2) AS cumulative_revenue
FROM monthly_revenue        
)
SELECT YEAR,
       MONTH,
       monthly_revenue,
       cumulative_revenue
FROM running_revenue
ORDER BY
   YEAR, month_number ASC;

-- =========================================
-- Q12: Month-over-Month Revenue Growth
-- =========================================

-- Business Question:
-- How does the business's monthly revenue change
-- compared with the previous month, and what is
-- the percentage growth or decline?

WITH 
monthly_revenue AS (
SELECT YEAR(o.order_date) AS Year,
       MONTH(o.order_date) AS Month,
       SUM(p.net_order_amount) AS current_month_revenue
FROM orders AS o
JOIN payments AS p 
  ON p.order_id = o.order_id
WHERE (o.order_status = 'Delivered')
   AND (o.order_date >= '2024-01-01'
        AND o.order_date < '2026-01-01') 
GROUP BY YEAR, MONTH    
) ,
monthly_comparison AS (
SELECT YEAR,
       MONTH,
       current_month_revenue,
       LAG(current_month_revenue) OVER (
                    ORDER BY YEAR, MONTH ASC ) AS previous_month_revenue
FROM monthly_revenue           
)
SELECT YEAR,
       MONTH,
       current_month_revenue AS Monthly_revenue,
       previous_month_revenue,
ROUND(((current_month_revenue - previous_month_revenue) 
     / nullif(previous_month_revenue , 0))* 100 , 2) AS MoM_Growth
FROM monthly_comparison
ORDER BY YEAR, MONTH ASC ;







USE retail_analytics;

SELECT COUNT(*) FROM customers;







































