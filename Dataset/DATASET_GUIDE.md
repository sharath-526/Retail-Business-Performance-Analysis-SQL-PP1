# Retail Business Performance & Customer Analytics — Dataset

Synthetic retail dataset created for SQL portfolio practice. All names, transactions and contact details are fictional.

## Files and approximate row counts
- customers.csv — 3,000 customers
- products.csv — 300 products
- stores.csv — 12 stores
- orders.csv — 15,000 orders
- order_items.csv — approximately 25,000–30,000 order lines
- payments.csv — 15,000 payment records (one per order)

## Relationships
- customers.customer_id = orders.customer_id
- stores.store_id = orders.store_id
- orders.order_id = order_items.order_id
- products.product_id = order_items.product_id
- orders.order_id = payments.order_id

## Important business definitions
- Gross line sales = quantity * unit_price
- Discount amount = quantity * unit_price * discount_pct
- Net line sales = quantity * unit_price * (1 - discount_pct)
- Net order amount = sum of net line sales for an order
- `amount_paid` is populated for Shipped and Delivered orders; it is zero for Processing, Cancelled and Returned orders.
- For a conservative realised-sales analysis, use orders with `order_status = 'Delivered'`. For a broader fulfilled-sales view, include `Delivered` and `Shipped`.
- Product cost is included at line level. Estimated gross profit = net line sales - (quantity * unit_cost). This is a simplified product-level gross profit and excludes operating costs, shipping, taxes and overheads.
- Date range: 2024-01-01 to 2025-12-31.
- All currency values are synthetic INR amounts.

## Suggested SQL import order
1. customers
2. products
3. stores
4. orders
5. order_items
6. payments

## Suggested primary/foreign keys
- customers: PK customer_id
- products: PK product_id
- stores: PK store_id
- orders: PK order_id; FK customer_id -> customers; FK store_id -> stores
- order_items: PK order_item_id; FK order_id -> orders; FK product_id -> products
- payments: PK order_id; FK order_id -> orders

## Notes
This dataset is generated for learning and portfolio demonstration. It is not real company data.
