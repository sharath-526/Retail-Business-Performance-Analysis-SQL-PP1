

-- Creating a seperate Database

CREATE DATABASE
retail_analytics ;

USE retail_analytics;

-- checking total records (58,884)

SELECT 'customers' AS table_name, COUNT(*) AS total_rows FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'stores', COUNT(*) FROM stores
UNION ALL
SELECT 'orders', COUNT(*) FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'payments', COUNT(*) FROM payments;

-- correcting column data types

-- Date columns
ALTER TABLE customers
MODIFY signup_date DATE;

ALTER TABLE orders
MODIFY order_date DATE;

ALTER TABLE products
MODIFY launch_date DATE;

-- Product prices and costs
ALTER TABLE products
MODIFY unit_cost DECIMAL(12,2),
MODIFY unit_price DECIMAL(12,2);

-- Order item values
ALTER TABLE order_items
MODIFY unit_price DECIMAL(12,2),
MODIFY unit_cost DECIMAL(12,2),
MODIFY discount_pct DECIMAL(5,2);

-- Payment values
ALTER TABLE payments
MODIFY gross_amount DECIMAL(12,2),
MODIFY net_order_amount DECIMAL(12,2),
MODIFY amount_paid DECIMAL(12,2);

-- Verifying the DATA conversions

DESCRIBE customers;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE payments;

-- verifying sample records
SELECT * FROM customers LIMIT 5;
SELECT * FROM orders LIMIT 5;
SELECT * FROM order_items LIMIT 5;

-- Data Quality checks ;
-- 1) Duplicate IDs
SELECT 'customers' AS table_name, COUNT(*) - COUNT(DISTINCT customer_id) AS duplicate_ids
FROM customers

UNION ALL

SELECT 'products', COUNT(*) - COUNT(DISTINCT product_id)
FROM products

UNION ALL

SELECT 'stores', COUNT(*) - COUNT(DISTINCT store_id)
FROM stores

UNION ALL

SELECT 'orders', COUNT(*) - COUNT(DISTINCT order_id)
FROM orders

UNION ALL

SELECT 'order_items', COUNT(*) - COUNT(DISTINCT order_item_id)
FROM order_items

UNION ALL

SELECT 'payments', COUNT(*) - COUNT(DISTINCT order_id)
FROM payments;

-- 2) Missing values (nulls)
SELECT 'customers' AS table_name,
       SUM(customer_name IS NULL) AS missing_names,
       SUM(email IS NULL) AS missing_emails,
       SUM(city IS NULL) AS missing_cities
FROM customers

UNION ALL

SELECT 'products',
       SUM(product_name IS NULL),
       SUM(category IS NULL),
       SUM(unit_price IS NULL)
FROM products

UNION ALL

SELECT 'orders',
       SUM(customer_id IS NULL),
       SUM(order_date IS NULL),
       SUM(order_status IS NULL)
FROM orders

UNION ALL

SELECT 'order_items',
       SUM(order_id IS NULL),
       SUM(product_id IS NULL),
       SUM(quantity IS NULL)
FROM order_items

UNION ALL

SELECT 'payments',
       SUM(order_id IS NULL),
       SUM(payment_method IS NULL),
       SUM(payment_status IS NULL)
FROM payments;

-- 3) Referential Integrity
SELECT
    'Orders - Customers' AS relationship,
    COUNT(*) AS invalid_records
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL

UNION ALL

SELECT
    'Orders - Stores',
    COUNT(*)
FROM orders o
LEFT JOIN stores s
    ON o.store_id = s.store_id
WHERE s.store_id IS NULL

UNION ALL

SELECT
    'Order Items - Orders',
    COUNT(*)
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL

UNION ALL

SELECT
    'Order Items - Products',
    COUNT(*)
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL

UNION ALL

SELECT
    'Payments - Orders',
    COUNT(*)
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Business Consistency
-- 1. Invalid quantities or prices
SELECT
    SUM(quantity <= 0) AS invalid_quantities,
    SUM(unit_price <= 0) AS invalid_selling_prices,
    SUM(unit_cost <= 0) AS invalid_costs,
    SUM(discount_pct < 0 OR discount_pct > 1) AS invalid_discounts
FROM order_items;


-- 2. Invalid order statuses
SELECT order_status, COUNT(*) AS total_orders
FROM orders
GROUP BY order_status;


-- 3. Invalid payment statuses
SELECT payment_status, COUNT(*) AS total_payments
FROM payments
GROUP BY payment_status;


-- 4. Check whether each order has exactly one payment record
SELECT order_id, COUNT(*) AS payment_records
FROM payments
GROUP BY order_id
HAVING COUNT(*) <> 1;