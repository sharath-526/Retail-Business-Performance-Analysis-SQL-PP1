

-- ---------------------------------------------------------------------------------------------------
-- =========================================
-- Q1: Overall Sales Performance
-- =========================================

-- Business Question:
-- What is the overall sales performance of the business?

-- SQL Query:
WITH 
order_details AS (
SELECT COUNT(o.order_id) AS Total_orders,

       SUM(CASE 
           WHEN o.order_status = 'Delivered' THEN 1 else 0
       END) AS Delivered_orders,
       
       SUM(CASE 
           WHEN o.order_status = 'Delivered' THEN p.net_order_amount else 0
       END) AS Total_revenue
       
FROM orders AS o 
JOIN payments AS p 
   ON o.order_id = p.order_id 
),
Average_order AS (
SELECT * ,
       round(
        (total_revenue / NULLIF(delivered_orders,0)),2 ) AS Average_order_value
FROM order_details       
)
SELECT *
FROM Average_order ;

-- =========================================
-- Q2: Monthly Revenue Trends
-- =========================================

-- Business Question:
-- How does the business's revenue change month by month during 2024–2025?

-- SQL Query:
SELECT YEAR(o.order_date) AS YEAR,
       date_format(o.order_date, '%M') AS MONTH,
       ROUND( sum(p.net_order_amount) , 2 )AS Monthly_revenue
FROM orders AS o 
JOIN payments AS p
   ON p.order_id = o.order_id
WHERE (o.order_status = 'Delivered')
  AND (o.order_date >= '2024-01-01' 
  AND  o.order_date < '2026-01-01')
GROUP BY
    YEAR(o.order_date),
    MONTH(o.order_date),
    DATE_FORMAT(o.order_date, '%M')
ORDER BY
    YEAR(o.order_date),
    MONTH(o.order_date) ASC;

-- =========================================
-- Q3: Sales Channel & Order Status Analysis
-- =========================================

-- Business Question:
-- How do different sales channels contribute to business performance,
-- and what is the order status distribution across each channel?

SELECT o.sales_channel,
       COUNT(o.order_id) AS Total_orders,   
       SUM(CASE 
              WHEN o.order_status = 'Delivered' THEN 1
              ELSE 0
            END) AS Delivered_orders,         
       SUM(CASE 
              WHEN o.order_status = 'Cancelled' THEN 1
              ELSE 0
            END) AS Cancelled_orders,
       SUM(CASE 
              WHEN o.order_status = 'Shipped' THEN 1
              ELSE 0
            END) AS Shipped_orders,    
       SUM(CASE 
              WHEN o.order_status = 'Processing' THEN 1
              ELSE 0
            END) AS Processing_orders, 
       SUM(CASE 
              WHEN o.order_status = 'Returned' THEN 1
              ELSE 0
            END) AS Returned_orders,
       sum(CASE 
              WHEN o.order_status = 'Delivered' THEN p.net_order_amount
              ELSE 0
            END) AS Delivered_revenue    
FROM orders AS o 
JOIN payments AS p 
  ON p.order_id = o.order_id
WHERE o.order_date >= '2024-01-01'
  AND o.order_date <  '2026-01-01'
GROUP BY o.sales_channel 
ORDER BY delivered_revenue Desc;



















































































































































































































