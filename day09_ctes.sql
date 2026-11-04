-- =====================================================
-- DAY 9: CTEs (WITH), chained CTEs, and Recursive CTEs
-- =====================================================
-- A CTE is a named temporary result you define at the top with WITH and
-- then use like a table in the query below it. It exists only for that
-- one statement.
-- A recursive CTE has three parts:
--   1. an ANCHOR query (the starting rows)
--   2. UNION ALL
--   3. a RECURSIVE query that refers to the CTE's own name and builds the
--      next level of rows from the previous level
-- It stops by itself when the recursive part returns no new rows.
-- (MySQL also stops with an error after 1000 levels by default.)

-- =========================================
-- SETUP (run once, used by all problems)
-- =========================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

CREATE TABLE orders (
    order_id    INT,
    customer_id INT,
    amount      INT
);

INSERT INTO orders (order_id, customer_id, amount) VALUES
(1, 101,  500),
(2, 101,  700),
(3, 102,  300),
(4, 103, 1500),
(5, 103,  500),
(6, 104,  200);

CREATE TABLE employees (
    emp_id     INT,
    emp_name   VARCHAR(50),
    manager_id INT,          -- NULL for the CEO
    salary     INT
);

INSERT INTO employees (emp_id, emp_name, manager_id, salary) VALUES
(1, 'Neha',    NULL, 150000),
(2, 'Arjun',   1,    100000),
(3, 'Priya',   1,     95000),
(4, 'Rahul',   2,     80000),
(5, 'Sneha',   2,    105000),
(6, 'Vikram',  3,     70000),
(7, 'Divya',   3,     60000),
(8, 'Karthik', 4,     55000);


-- =========================================
-- Problem 1: Customers Who Spend More Than the Average Customer
-- =========================================
-- Task: Find customers whose TOTAL spend is above the average of all
-- customers' totals. Show customer_id and total_spent.
-- Order by total_spent DESC.
-- Think: you need to aggregate twice (a total per customer, then an
-- average of those totals). Put the first step in a CTE, then query it.
-- Note: this is the average of the per-customer totals, not AVG(amount).

-- Expected output:
-- +-------------+-------------+
-- | customer_id | total_spent |
-- +-------------+-------------+
-- |         103 |        2000 |
-- |         101 |        1200 |
-- +-------------+-------------+
-- (customer totals: 101 = 1200, 102 = 300, 103 = 2000, 104 = 200;
--  their average = 925)

--Solutions:
WITH total_amount AS(
SELECT customer_id,SUM(amount) AS total_spent
FROM orders
GROUP BY customer_id)

SELECT customer_id,total_spent
FROM total_amount
WHERE total_spent >(SELECT AVG(total_spent) FROM total_amount)
ORDER BY total_spent DESC;

-- =========================================
-- Problem 2: Each Customer's Share of Total Revenue (two CTEs)
-- =========================================
-- Task: For every customer show customer_id, total_spent, and
-- pct_of_revenue = their total as a percentage of ALL revenue,
-- rounded to 2 decimals. Order by customer_id.
-- Use TWO CTEs in one WITH: one for per-customer totals, one for the
-- overall total. Then combine them.
-- Think: the overall-total CTE returns exactly one row. How do you attach
-- that one value to every customer row?

-- Expected output:
-- +-------------+-------------+----------------+
-- | customer_id | total_spent | pct_of_revenue |
-- +-------------+-------------+----------------+
-- |         101 |        1200 |          32.43 |
-- |         102 |         300 |           8.11 |
-- |         103 |        2000 |          54.05 |
-- |         104 |         200 |           5.41 |
-- +-------------+-------------+----------------+
-- (overall revenue = 3700)

--Solutions:

WITH total_amount AS(
SELECT customer_id,SUM(amount) AS total_spent
FROM orders
GROUP BY customer_id)

SELECT customer_id,
       total_spent,
       CAST((total_spent *100)/(SELECT SUM(total_spent) FROM total_amount) AS DECIMAL(10,2)) AS pct_of_revenue
FROM total_amount;

-- =========================================
-- Problem 3: Generate a Number Series (first recursive CTE)
-- =========================================
-- Task: Without using any table, produce the numbers 1 to 5 together
-- with their squares. Show n and n_squared.
-- Think: the anchor row is just 1. The recursive part adds 1 to the
-- previous row's n. What condition stops it at 5?

-- Expected output:
-- +---+-----------+
-- | n | n_squared |
-- +---+-----------+
-- | 1 |         1 |
-- | 2 |         4 |
-- | 3 |         9 |
-- | 4 |        16 |
-- | 5 |        25 |
-- +---+-----------+


-- =========================================
-- Problem 4: Everyone Under a Manager (hierarchy walk)
-- =========================================
-- Task: List Arjun (emp_id 2) and EVERYONE below him, at any depth.
-- Show emp_id, emp_name, level, where Arjun is level 0, his direct
-- reports are level 1, their reports are level 2, and so on.
-- Order by level, then emp_id.
-- Think: Day 5's self-join only reached one level. A recursive CTE walks
-- as deep as the data goes. The anchor is Arjun's row. The recursive part
-- joins the employees table to the rows found so far on manager_id.

-- Expected output:
-- +--------+----------+-------+
-- | emp_id | emp_name | level |
-- +--------+----------+-------+
-- |      2 | Arjun    |     0 |
-- |      4 | Rahul    |     1 |
-- |      5 | Sneha    |     1 |
-- |      8 | Karthik  |     2 |
-- +--------+----------+-------+


-- =========================================
-- Problem 5: Reporting Chain for Every Employee
-- =========================================
-- Task: For every employee show emp_id, emp_name, level (CEO = 0), and
-- chain: the path from the CEO down to them, written like
-- 'Neha > Arjun > Rahul'. Order by emp_id.
-- Think: the anchor is the CEO (the row with no manager). Each recursive
-- step appends ' > ' and the next employee's name to the previous chain.
-- MySQL gotcha: a recursive CTE's column types come from the ANCHOR row.
-- If the chain column starts out as a short string, longer values later
-- get cut off or cause an error. How do you make the anchor's chain
-- column wide enough up front? (Look up CAST ... AS CHAR(n).)

-- Expected output:
-- +--------+----------+-------+--------------------------------+
-- | emp_id | emp_name | level | chain                          |
-- +--------+----------+-------+--------------------------------+
-- |      1 | Neha     |     0 | Neha                           |
-- |      2 | Arjun    |     1 | Neha > Arjun                   |
-- |      3 | Priya    |     1 | Neha > Priya                   |
-- |      4 | Rahul    |     2 | Neha > Arjun > Rahul           |
-- |      5 | Sneha    |     2 | Neha > Arjun > Sneha           |
-- |      6 | Vikram   |     2 | Neha > Priya > Vikram          |
-- |      7 | Divya    |     2 | Neha > Priya > Divya           |
-- |      8 | Karthik  |     3 | Neha > Arjun > Rahul > Karthik |
-- +--------+----------+-------+--------------------------------+