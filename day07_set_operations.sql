-- =====================================================
-- DAY 7: Set Operations (UNION, UNION ALL, INTERSECT, EXCEPT) + Review
-- =====================================================
-- Rules for every set operation:
--   * Both SELECTs must return the SAME number of columns
--   * Column types must be compatible, matched by position (not by name)
--   * Column names in the result come from the FIRST SELECT
--   * ORDER BY goes once, at the very end, and applies to the whole result

-- =========================================
-- SETUP (run once, used by Problems 1-4)
-- =========================================

DROP TABLE IF EXISTS online_customers;
DROP TABLE IF EXISTS store_customers;

CREATE TABLE online_customers (
    customer_id   INT,
    customer_name VARCHAR(50)
);

CREATE TABLE store_customers (
    customer_id   INT,
    customer_name VARCHAR(50)
);

INSERT INTO online_customers (customer_id, customer_name) VALUES
(1, 'Asha'),
(2, 'Ravi'),
(3, 'Meena'),
(4, 'Karan');

INSERT INTO store_customers (customer_id, customer_name) VALUES
(3, 'Meena'),
(4, 'Karan'),
(5, 'Divya'),
(6, 'Arjun');


-- =========================================
-- Problem 1: All Customers From Either Channel (UNION vs UNION ALL)
-- =========================================
-- Task A: List every customer who appears in online_customers OR
-- store_customers, with no duplicate rows. Order by customer_id.
-- Task B: Run the same query with UNION ALL instead and compare the
-- row counts. Why are they different?

-- Expected output for Task A (UNION, 6 rows):
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- |           1 | Asha          |
-- |           2 | Ravi          |
-- |           3 | Meena         |
-- |           4 | Karan         |
-- |           5 | Divya         |
-- |           6 | Arjun         |
-- +-------------+---------------+
-- Task B (UNION ALL) returns 8 rows: Meena and Karan appear twice.

--Solution(Task A):
SELECT * FROM online_customers
UNION
SELECT * FROM store_customers
ORDER BY customer_id;

--Solution(Task B):
SELECT * FROM online_customers
UNION ALL
SELECT * FROM store_customers
ORDER BY customer_id;


-- =========================================
-- Problem 2: Customers Who Use Both Channels
-- =========================================
-- Task: Find customers who appear in BOTH tables.
-- Show customer_id and customer_name. Order by customer_id.
-- Use INTERSECT. If your MySQL is older than 8.0.31, use an INNER JOIN
-- or EXISTS instead.

-- Expected output:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- |           3 | Meena         |
-- |           4 | Karan         |
-- +-------------+---------------+

--Solution(Using INTERSECT):
SELECT * FROM online_customers
INTERSECT
SELECT * FROM store_customers
ORDER BY customer_id;

--Solution(Just tried with JOINS):
SELECT t1.customer_id,t1.customer_name
FROM online_customers t1
JOIN store_customers t2 on t1.customer_id = t2.customer_id
ORDER BY t1.customer_id;



-- =========================================
-- Problem 3: Customers Who Are Online-Only
-- =========================================
-- Task: Find customers in online_customers who are NOT in store_customers.
-- Show customer_id and customer_name. Order by customer_id.
-- Use EXCEPT. If your MySQL is older, use NOT EXISTS (not NOT IN, you
-- know why).
-- Think: does EXCEPT give the same result if you swap the two tables?

-- Expected output:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- |           1 | Asha          |
-- |           2 | Ravi          |
-- +-------------+---------------+

--Solution(Using EXCEPT):
SELECT *
FROM online_customers
EXCEPT
SELECT *
FROM store_customers
ORDER BY customer_id;


-- =========================================
-- Problem 4: Customers in Exactly One Channel
-- =========================================
-- Task: Find customers who appear in exactly ONE of the two tables
-- (online-only OR store-only, never both). Order by customer_id.
-- Think: build it from the pieces you already wrote in Problem 3
-- (one in each direction). Where does ORDER BY go when the whole
-- thing is combined?

-- Expected output:
-- +-------------+---------------+
-- | customer_id | customer_name |
-- +-------------+---------------+
-- |           1 | Asha          |
-- |           2 | Ravi          |
-- |           5 | Divya         |
-- |           6 | Arjun         |
-- +-------------+---------------+

--Solution:
(SELECT *
FROM online_customers
EXCEPT
SELECT *
FROM store_customers)
UNION ALL
(SELECT *
FROM store_customers
EXCEPT
SELECT *
FROM online_customers)
ORDER BY customer_id;


-- =========================================
-- Problem 5: Total Revenue Across Two Order Tables (the UNION trap)
-- =========================================

DROP TABLE IF EXISTS online_orders;
DROP TABLE IF EXISTS store_orders;

CREATE TABLE online_orders (
    order_id INT,
    amount   INT
);

CREATE TABLE store_orders (
    order_id INT,
    amount   INT
);

INSERT INTO online_orders (order_id, amount) VALUES
(1, 500),
(2, 700),
(3, 300);

INSERT INTO store_orders (order_id, amount) VALUES
(1, 400),
(2, 600),
(3, 300);

-- Task A: Find the total revenue across BOTH tables.
-- Combine the rows first (in a derived table), then SUM the amount.
-- Task B: Do it again using UNION instead of UNION ALL. Compare the totals.
-- Question: why is the UNION total wrong here?
-- Hint: look at online order 3 and store order 3.
-- Task C: Now show revenue per channel. You'll need to add a literal
-- label column ('online' / 'store') in each SELECT before combining.
-- Order by channel.

-- Expected output for Task A (UNION ALL):
-- +---------------+
-- | total_revenue |
-- +---------------+
-- |          2800 |
-- +---------------+

--Solution(Task A):

SELECT SUM(amount) AS total_revenue FROM
(SELECT * FROM online_orders
UNION ALL
SELECT * FROM store_orders) AS merged;

-- Task B (UNION) returns 2500, which is wrong.

--Solution(Task B):

SELECT SUM(amount) AS total_revenue FROM
(SELECT * FROM online_orders
UNION
SELECT * FROM store_orders) AS merged;
+---------------+
| total_revenue |
+---------------+
|        2500   |
+---------------+
--

--Solution(Task C):
SELECT 'online' AS channel, SUM(amount) AS total_revenue
FROM online_orders
UNION ALL
SELECT 'store', SUM(amount)
FROM store_orders
ORDER BY channel;
-- Expected output for Task C:
-- +---------+---------------+
-- | channel | total_revenue |
-- +---------+---------------+
-- | online  |          1500 |
-- | store   |          1300 |
-- +---------+---------------+


-- =====================================================
-- REVIEW CHECKLIST (Days 1-6): the mistakes to stop making
-- =====================================================
-- Write one query from each line below from memory (use any earlier
-- day's tables) and check yourself:
--
-- 1. Outer join + filter on the right table -> filter belongs in ON,
--    not WHERE (unless you WANT the NULL rows removed).
-- 2. Count including zero -> LEFT JOIN + COUNT(right_pk), never COUNT(*).
-- 3. GROUP BY the unique ID, plus any other selected plain columns.
-- 4. NOT IN with a NULL in the subquery returns nothing -> use NOT EXISTS
--    or filter the NULLs.
-- 5. "Strictly higher" means >, not >=.
-- 6. Sorting by a non-unique column -> add a tiebreaker.
-- 7. Add aliases to calculated columns, and ORDER BY when the task asks.
-- 8. Qualify columns (e1.salary) inside correlated subqueries.
-- 9. Verify the expected output against the raw data yourself.