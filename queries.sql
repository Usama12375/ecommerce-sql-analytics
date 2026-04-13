-- Query 1: Total revenue by month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
       SUM(unit_price * quantity) AS total_revenue
FROM orders AS o
JOIN order_items AS oi ON o.order_id = oi.order_id
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Query 2: Top 5 best-selling products by quantity sold
SELECT p.name, SUM(oi.quantity) AS total_quantity_sold
FROM order_items AS oi
JOIN orders AS o ON oi.order_id = o.order_id
JOIN products AS p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY total_quantity_sold DESC
LIMIT 5;

-- Query 3: Customers who placed more than one order
SELECT c.name, c.city, COUNT(*) AS orders_placed
FROM customers AS c
JOIN orders AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.city
HAVING orders_placed > 1;

-- Query 4: Revenue rank per product category
SELECT p.name,
       p.category,
       SUM(oi.unit_price * oi.quantity) AS total_revenue,
       RANK() OVER (PARTITION BY p.category ORDER BY SUM(oi.unit_price * oi.quantity) DESC) AS revenue_rank
FROM products AS p
JOIN order_items AS oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.name, p.category;

-- Query 5: Month-over-month revenue growth
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(unit_price * quantity) AS total_revenue
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month,
       total_revenue,
       LAG(total_revenue) OVER (ORDER BY month) AS prev_month_revenue,
       total_revenue - LAG(total_revenue) OVER (ORDER BY month) AS difference
FROM monthly_revenue;

-- Query 6: Running total of revenue over time
WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month,
           SUM(unit_price * quantity) AS total_revenue
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT month,
       total_revenue,
       SUM(total_revenue) OVER (ORDER BY month) AS running_total
FROM monthly_revenue;

-- Query 7: Return rate by product category
SELECT p.category,
       ROUND(COUNT(r.return_id) / COUNT(o.order_id) * 100, 2) AS return_rate_pct
FROM returns AS r
JOIN orders AS o ON r.order_id = o.order_id
JOIN order_items AS oi ON o.order_id = oi.order_id
JOIN products AS p ON oi.product_id = p.product_id
GROUP BY p.category;

-- Query 8: Top 25% customers by total spend
WITH total_spent AS (
    SELECT o.customer_id, SUM(unit_price * quantity) AS total
    FROM orders AS o
    JOIN order_items AS oi ON o.order_id = oi.order_id
    WHERE status = 'completed'
    GROUP BY o.customer_id
),
segments AS (
    SELECT customer_id,
           NTILE(4) OVER (ORDER BY total DESC) AS group_4
    FROM total_spent
)
SELECT c.name, s.group_4
FROM segments AS s
JOIN customers AS c ON s.customer_id = c.customer_id
WHERE s.group_4 = 1;

-- Query 9: First vs repeat orders per customer
WITH order_sequence AS (
    SELECT customer_id, order_id, order_date,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS row_num
    FROM orders
)
SELECT customer_id,
       order_id,
       order_date,
       CASE WHEN row_num = 1 THEN 'first' ELSE 'repeat' END AS order_type
FROM order_sequence;

-- Query 10: Average days between orders per customer
WITH previous_d AS (
    SELECT customer_id, order_date,
           LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_date
    FROM orders
),
more_than_one AS (
    SELECT c.customer_id
    FROM customers AS c
    JOIN orders AS o ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
    HAVING COUNT(*) > 1
)
SELECT pd.customer_id,
       ROUND(AVG(DATEDIFF(order_date, previous_date)), 2) AS avg_days_between_orders
FROM previous_d AS pd
JOIN more_than_one AS mt ON pd.customer_id = mt.customer_id
GROUP BY pd.customer_id;
