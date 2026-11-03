
-- =====================================================
-- SCRIPT: 04_Customer_Analysis.sql
-- PURPOSE: Analyse customer behaviour, spending patterns,
--          and customer value.
-- =====================================================
-- -------------------------------------------------------------------------------------------------------------------
-- =========================================
-- Q7: Highest-Value Customers
-- =========================================

-- Business Question:
-- Who are the highest-value customers based on their
-- total spending, and how much revenue does each contribute?

SELECT o.customer_id,
       c.customer_name,
       c.city,
       c.region,
       COUNT(o.order_id) AS Total_orders,
       ROUND(SUM(p.net_order_amount), 2) AS total_spending
FROM customers as c
JOIN orders AS o 
   ON c.customer_id = o.customer_id
JOIN payments AS p
   ON p.order_id = o.order_id
WHERE o.order_status = 'Delivered'   
GROUP BY o.customer_id,
         c.customer_name,
         c.city,
         c.region 
ORDER BY total_spending desc         
LIMIT 10 ;        

-- =========================================
-- Q8: Repeat Customer Analysis
-- =========================================

-- Business Question:
-- How many customers have made repeat purchases,
-- and what percentage of the customer base consists
-- of repeat customers?
WITH 
Delivered_orders AS (
SELECT o.customer_id,
       c.customer_name,
       COUNT(o.order_status) AS delivered_orders
FROM orders AS o   
JOIN customers AS c 
   ON c.customer_id = o.customer_id
WHERE o.order_status = 'Delivered'
GROUP BY o.customer_id,
         c.customer_name    
  ) ,
customers_details AS (
SELECT SUM(CASE 
          WHEN delivered_orders >= 1 THEN 1 ELSE 0
       END) AS Total_customers,
       SUM(CASE 
          WHEN delivered_orders >= 2 THEN 1 ELSE 0
       END) AS Repeat_customers,
       SUM(CASE 
          WHEN delivered_orders = 1 THEN 1 ELSE 0
       END) AS One_Time_customers
FROM Delivered_orders       
)
SELECT *,
       Round((repeat_customers / NULLIF(total_customers, 0)) * 100, 2 ) AS Repeat_customer_percentage
FROM customers_details;       

-- =========================================
-- Q9: Customer Segmentation
-- =========================================

-- Business Question:
-- How can customers be segmented based on their total
-- spending, and how many customers belong to each
-- spending category?

WITH 
spendings AS (
SELECT c.customer_id,
       c.customer_name,
       round(SUM(p.net_order_amount), 2 ) AS total_spending
FROM customers AS c 
JOIN orders AS o 
  ON c.customer_id = o.customer_id
JOIN payments AS p 
  ON p.order_id = o.order_id
WHERE o.order_status = 'Delivered'
GROUP BY c.customer_id,
         c.customer_name
) , 
segmentation AS (
SELECT *,
       (CASE
          WHEN total_spending < 5000 THEN 'Low Value'
          WHEN total_spending >= 5000 AND total_spending <= 15000  THEN 'Medium Value'
          ELSE 'High Value' 
         END
        ) AS customer_segment
FROM spendings        
) , 
segment_summary AS (
SELECT customer_segment,
       count(*) AS Total_customers,
       ROUND(SUM(total_spending), 2) AS total_spending   
FROM segmentation
GROUP BY customer_segment
)
SELECT customer_segment,
       total_customers, 
       total_spending,
       round(((total_customers / NULLIF(sum(total_customers) OVER(), 0)) ) * 100 , 2) AS customer_percentage
FROM segment_summary 
ORDER BY 
  CASE customer_segment 
    WHEN 'Low value' THEN 1
    WHEN 'Medium value' THEN 2
    WHEN 'High value' THEN 3 
   end;

       




































































































































































































