-- =====================================================
-- DAY 4: Multi-Table JOINs (INNER / LEFT / anti-joins, 3+ tables)
-- =====================================================

-- =========================================
-- SETUP (run once, used by all problems)
-- =========================================

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id   INT,
    customer_name VARCHAR(50),
    city          VARCHAR(50)
);

CREATE TABLE orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE,
    status      VARCHAR(20)
);

CREATE TABLE products (
    product_id   INT,
    product_name VARCHAR(50),
    price        INT
);

CREATE TABLE order_items (
    item_id    INT,
    order_id   INT,
    product_id INT,
    quantity   INT
);

INSERT INTO customers (customer_id, customer_name, city) VALUES
(1, 'Asha',  'Chennai'),
(2, 'Ravi',  'Mumbai'),
(3, 'Meena', 'Delhi'),
(4, 'Karan', 'Chennai');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(101, 1, '2024-01-10', 'DELIVERED'),
(102, 1, '2024-02-15', 'DELIVERED'),
(103, 2, '2024-01-20', 'CANCELLED'),
(104, 3, '2024-03-05', 'DELIVERED');

INSERT INTO products (product_id, product_name, price) VALUES
(1, 'Laptop',   50000),
(2, 'Mouse',      500),
(3, 'Keyboard',  1500),
(4, 'Monitor',  12000);

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
(1, 101, 1, 1),
(2, 101, 2, 2),
(3, 102, 3, 1),
(4, 103, 1, 1),
(5, 104, 2, 3),
(6, 104, 3, 2);


-- =========================================
-- Problem 1: Customers Who Never Placed an Order
-- =========================================
-- Task: Find all customers who have no orders at all.
-- Show customer_id and customer_name.
-- Think: which join type keeps unmatched left rows, and how do you
-- then isolate ONLY the unmatched ones?

-- Expected output:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- |           4 | Karan         |
-- +-------------+---------------+

--Solutions:
SELECT c.customer_id,c.customer_name
FROM customers c
LEFT JOIN orders o on c.customer_id = o.customer_id
WHERE o.status IS NULL;


-- =========================================
-- Problem 2: Order Count per Customer (Including Zero)
-- =========================================
-- Task: Show every customer with the number of orders they placed.
-- Customers with no orders must show 0.
-- Trap: COUNT(*) vs COUNT(column) behave differently after a LEFT JOIN.
-- Which one gives Karan a 0 instead of a 1?

-- Expected output (order by customer_id):
-- +-------------+---------------+-------------+
-- | customer_id | customer_name | order_count |
-- +-------------+---------------+-------------+
-- |           1 | Asha          |           2 |
-- |           2 | Ravi          |           1 |
-- |           3 | Meena         |           1 |
-- |           4 | Karan         |           0 |
-- +-------------+---------------+-------------+

--Solutions:
SELECT c.customer_id,c.customer_name,COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id,c.customer_name;


-- =========================================
-- Problem 3: Total Spend per Customer (3-4 Table JOIN)
-- =========================================
-- Task: For DELIVERED orders only, find the total amount each customer
-- spent (SUM of quantity * price). Show only customers who have spend.
-- Tables involved: customers, orders, order_items, products.
-- Sort by total_spent DESC.

-- Expected output:
-- +---------------+-------------+
-- | customer_name | total_spent |
-- +---------------+-------------+
-- | Asha          |       52500 |
-- | Meena         |        4500 |
-- +---------------+-------------+
-- (Ravi's only order was CANCELLED, Karan has no orders)


-- =========================================
-- Problem 4: Total Spend per Customer, Keeping Everyone
-- =========================================
-- Task: Same as Problem 3, but now show ALL customers.
-- Customers with no delivered spend must show 0 (not NULL).
-- Think: where does the status = 'DELIVERED' filter need to live so the
-- LEFT JOINs don't get silently turned into INNER JOINs?
-- (You've seen this trap before.) Which function turns NULL into 0?
-- Sort by total_spent DESC, then customer_name.

-- Expected output:
-- +---------------+-------------+
-- | customer_name | total_spent |
-- +---------------+-------------+
-- | Asha          |       52500 |
-- | Meena         |        4500 |
-- | Karan         |           0 |
-- | Ravi          |           0 |
-- +---------------+-------------+


-- =========================================
-- Problem 5: Products That Were Never Ordered
-- =========================================
-- Task: Find all products that do not appear in any order_items row.
-- Show product_id and product_name.

-- Expected output:
-- +------------+--------------+
-- | product_id | product_name |
-- +------------+--------------+
-- |          4 | Monitor      |
-- +------------+--------------+