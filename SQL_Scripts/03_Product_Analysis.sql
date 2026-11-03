
-- =====================================================
-- SCRIPT: 03_Product_Analysis.sql
-- PURPOSE: Analyse product performance, category revenue,
--          discount patterns, and estimated profitability.
-- =====================================================
-- ---------------------------------------------------------------------------------------------------------------
-- =========================================
-- Q4: Top Performing Products
-- =========================================

-- Business Question:
-- Which products generate the highest revenue for the retail business?

SELECT p.product_id,
       p.product_name,
       p.category,
       sum(oi.quantity) AS Units_sold,
       sum(oi.quantity * oi.unit_price * (1 - oi.discount_pct)) AS Total_revenue
FROM products AS p
JOIN order_items AS oi 
  ON p.product_id = oi.product_id
JOIN orders AS o 
  ON o.order_id = oi.order_id
where o.order_status = 'delivered'
GROUP BY p.product_id,
         p.product_name,
         p.category
ORDER BY total_revenue DESC 
LIMIT 10 ;

-- =========================================
-- Q5: Product Category Performance
-- =========================================

-- Business Question:
-- Which product categories generate the highest revenue,
-- and what percentage does each category contribute to total sales?

WITH 
category_details AS (
SELECT p.category AS category,
       ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)),
            2
        ) AS category_revenue      
FROM products AS p
JOIN order_items AS oi 
  ON p.product_id = oi.product_id
JOIN orders AS o
  ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered'
GROUP BY category  
) ,
Revenue_contribution AS (
SELECT category,
       category_revenue,
       sum(category_revenue) over() AS total_revenue
FROM category_details
)
SELECT category,
       category_revenue AS total_revenue,
       ROUND((category_revenue/NULLIF(total_revenue, 0)) * 100 , 2) AS revenue_contribution
FROM revenue_contribution ;

-- =========================================
-- Q6: Discount and Estimated Profitability Analysis
-- =========================================

-- Business Question:
-- How do different discount levels affect sales revenue
-- and estimated gross profitability?

WITH 
discount_details AS (
SELECT (CASE 
        WHEN oi.discount_pct = 0 THEN 'No Discount'  
        WHEN oi.discount_pct > 0 AND oi.discount_pct <= 0.10 THEN 'Low Discount' 
        WHEN oi.discount_pct > 0.10 AND oi.discount_pct <= 0.20 THEN 'Medium Discount'  
        WHEN oi.discount_pct > 0.20 THEN 'High Discount' ELSE 'Out_range'   
       END) AS Discount_level,
       sum(oi.quantity) AS units_sold,       
       ROUND(
            SUM(oi.quantity * oi.unit_price * (1 - oi.discount_pct)),
            2) AS Net_revenue,          
       sum(oi.quantity * oi.unit_cost) AS Estimated_cost  
FROM order_items AS oi
JOIN orders AS o
   ON o.order_id = oi.order_id
WHERE o.order_status = 'Delivered' 
GROUP BY discount_level
) ,
revenue_details AS (
SELECT discount_level,
       units_sold,
       net_revenue,
       round((net_revenue - estimated_cost), 2) AS Estimated_gross_profit
FROM discount_details       
)
SELECT discount_level,
       units_sold,
       net_revenue,
       estimated_gross_profit,
      round((estimated_gross_profit / NULLIF(net_revenue, 0)) * 100, 2 ) AS Gross_profit_margin
FROM revenue_details 
ORDER BY CASE discount_level
    WHEN 'No Discount' THEN 1
    WHEN 'Low Discount' THEN 2
    WHEN 'Medium Discount' THEN 3
    WHEN 'High Discount' THEN 4
    ELSE 5
END;      























































































































































































