-- =====================================================
-- DAY 1: Window Functions - RANK, DENSE_RANK, ROW_NUMBER, LAG, LEAD
-- =====================================================

-- =========================================
-- Problem 1: Second Highest Salary per Department
-- =========================================
-- Task: For each department, find the second highest DISTINCT salary.
-- If no second highest exists, show NULL (don't drop the department).
USE dp;

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees (emp_id, emp_name, department, salary) VALUES
(1, 'Alice',   'Engineering', 90000),
(2, 'Bob',     'Engineering', 85000),
(3, 'Carol',   'Engineering', 90000),
(4, 'Dave',    'Engineering', 70000),
(5, 'Eve',     'Sales',       60000),
(6, 'Frank',   'Sales',       60000),
(7, 'Grace',   'Marketing',   50000),
(8, 'Heidi',   'HR',          40000);

-- Expected output:
-- +-------------+-----------------------+
-- | department  | second_highest_salary |
-- +-------------+-----------------------+
-- | Engineering |                  85000 |
-- | Sales       |                   NULL |
-- | Marketing   |                   NULL |
-- | HR          |                   NULL |
-- +-------------+-----------------------+
--Solution:

SELECT DISTINCT l.department,r.salary
FROM employees l
LEFT JOIN (SELECT *,DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS ranked FROM employees) AS r 
ON l.department = r.department AND r.ranked = 2;


-- =========================================
-- Problem 2: Top 2 Earners per Department
-- =========================================
-- Task: Write it 3 times - once each with ROW_NUMBER(), RANK(), DENSE_RANK().
-- Compare row counts per department for each version.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees (emp_id, emp_name, department, salary) VALUES
(1, 'Alice',   'Engineering', 90000),
(2, 'Bob',     'Engineering', 85000),
(3, 'Carol',   'Engineering', 90000),
(4, 'Dave',    'Engineering', 70000),
(5, 'Eve',     'Sales',       60000),
(6, 'Frank',   'Sales',       60000),
(7, 'Grace',   'Sales',       55000),
(8, 'Heidi',   'Marketing',   50000),
(9, 'Ivan',    'Marketing',   50000),
(10,'Judy',    'Marketing',   50000);

-- Expected row counts (top 2 filter):
-- ROW_NUMBER()  -> 6 rows total  (exactly 2 per department, always)
-- RANK()        -> 7 rows total  (Marketing gets 3 - all tied at rank 1)
-- DENSE_RANK()  -> 9 rows total  (Marketing gets 3, Sales gets 3, Engineering gets 3)


-- =========================================
-- Problem 3: Month-over-Month Change (LAG)
-- =========================================
-- Task: Show revenue, previous month's revenue, and the change (current - previous).
-- First month per product should show NULL for prev_revenue and revenue_change.

CREATE TABLE monthly_sales (
    product     VARCHAR(50),
    sale_month  DATE,
    revenue     INT
);

INSERT INTO monthly_sales (product, sale_month, revenue) VALUES
('Widget A', '2024-01-01', 1000),
('Widget A', '2024-02-01', 1200),
('Widget A', '2024-03-01', 900),
('Widget A', '2024-04-01', 1500),
('Widget B', '2024-01-01', 500),
('Widget B', '2024-02-01', 700),
('Widget B', '2024-03-01', 650),
('Widget B', '2024-04-01', 800);

-- Expected output:
-- +----------+------------+---------+--------------+----------------+
-- | product  | sale_month | revenue | prev_revenue | revenue_change |
-- +----------+------------+---------+--------------+----------------+
-- | Widget A | 2024-01-01 |    1000 |         NULL |           NULL |
-- | Widget A | 2024-02-01 |    1200 |         1000 |            200 |
-- | Widget A | 2024-03-01 |     900 |         1200 |           -300 |
-- | Widget A | 2024-04-01 |    1500 |          900 |            600 |
-- | Widget B | 2024-01-01 |     500 |         NULL |           NULL |
-- | Widget B | 2024-02-01 |     700 |          500 |            200 |
-- | Widget B | 2024-03-01 |     650 |          700 |            -50 |
-- | Widget B | 2024-04-01 |     800 |          650 |            150 |
-- +----------+------------+---------+--------------+----------------+


-- =========================================
-- Problem 4: Next Month Price Drop Detection (LEAD)
-- =========================================
-- Task: Using the same monthly_sales table, find next month's revenue.
-- will_drop = 'YES' if next month's revenue is LOWER than current, 'NO' if
-- higher or equal, and NULL if there is no next month.
-- Watch out: NULL comparisons need an explicit CASE branch, not a fallthrough ELSE.

-- Expected output:
-- +----------+------------+---------+--------------+-----------+
-- | product  | sale_month | revenue | next_revenue | will_drop |
-- +----------+------------+---------+--------------+-----------+
-- | Widget A | 2024-01-01 |    1000 |         1200 | NO        |
-- | Widget A | 2024-02-01 |    1200 |          900 | YES       |
-- | Widget A | 2024-03-01 |     900 |         1500 | NO        |
-- | Widget A | 2024-04-01 |    1500 |         NULL | NULL      |
-- | Widget B | 2024-01-01 |     500 |          700 | NO        |
-- | Widget B | 2024-02-01 |     700 |          650 | YES       |
-- | Widget B | 2024-03-01 |     650 |          800 | NO        |
-- | Widget B | 2024-04-01 |     800 |         NULL | NULL      |
-- +----------+------------+---------+--------------+-----------+


-- =========================================
-- Problem 5: De-duplicate Logins (First Login Per User Per Day)
-- =========================================
-- Task: Return one row per user per calendar day - the EARLIEST login of that day.
-- Watch for: exact timestamp ties (user 102) need a deterministic pick.

CREATE TABLE user_logins (
    login_id    INT,
    user_id     INT,
    login_time  DATETIME
);

INSERT INTO user_logins (login_id, user_id, login_time) VALUES
(1, 101, '2024-01-01 09:00:00'),
(2, 101, '2024-01-01 09:05:00'),
(3, 101, '2024-01-02 10:00:00'),
(4, 102, '2024-01-01 08:00:00'),
(5, 102, '2024-01-01 08:00:00'),
(6, 103, '2024-01-03 11:00:00');

-- Expected output (4 rows):
-- +---------+------------+--------------+
-- | user_id | login_date | login_timing |
-- +---------+------------+--------------+
-- |     101 | 2024-01-01 | 09:00:00     |
-- |     101 | 2024-01-02 | 10:00:00     |
-- |     102 | 2024-01-01 | 08:00:00     |
-- |     103 | 2024-01-03 | 11:00:00     |
-- +---------+------------+--------------+


-- =========================================
-- Problem 6: Most Recent Ticket Status (Deterministic Tiebreaker)
-- =========================================
-- Task: For each ticket_id, return the current (most recent) status.
-- Ticket 5002 has an exact timestamp tie (log_id 5 and 6) -> use log_id as
-- an explicit tiebreaker in ORDER BY for determinism.

CREATE TABLE ticket_status_log (
    log_id      INT,
    ticket_id   INT,
    status      VARCHAR(20),
    updated_at  DATETIME
);

INSERT INTO ticket_status_log (log_id, ticket_id, status, updated_at) VALUES
(1, 5001, 'OPEN',        '2024-03-01 09:00:00'),
(2, 5001, 'IN_PROGRESS', '2024-03-02 10:00:00'),
(3, 5001, 'CLOSED',      '2024-03-03 14:00:00'),
(4, 5002, 'OPEN',        '2024-03-01 08:00:00'),
(5, 5002, 'IN_PROGRESS', '2024-03-05 12:00:00'),
(6, 5002, 'IN_PROGRESS', '2024-03-05 12:00:00'),
(7, 5003, 'OPEN',        '2024-03-04 07:00:00');

-- Expected output (3 rows):
-- +-----------+-------------+---------------------+
-- | ticket_id | status      | updated_at          |
-- +-----------+-------------+---------------------+
-- |      5001 | CLOSED      | 2024-03-03 14:00:00 |
-- |      5002 | IN_PROGRESS | 2024-03-05 12:00:00 |
-- |      5003 | OPEN        | 2024-03-04 07:00:00 |
-- +-----------+-------------+---------------------+


-- =========================================
-- Problem 7: Peak Months (LAG + LEAD combined)
-- =========================================
-- Task: Find every "peak month" per product - revenue strictly HIGHER than
-- BOTH the previous month AND the next month.
-- Note: first/last month of each product can NEVER be a peak (no comparison
-- possible on one side -> NULL -> excluded automatically).

DROP TABLE IF EXISTS monthly_sales;

CREATE TABLE monthly_sales (
    product     VARCHAR(50),
    sale_month  DATE,
    revenue     INT
);

INSERT INTO monthly_sales (product, sale_month, revenue) VALUES
('Widget A', '2024-01-01', 1000),
('Widget A', '2024-02-01', 1200),
('Widget A', '2024-03-01', 900),
('Widget A', '2024-04-01', 1500),
('Widget A', '2024-05-01', 1100),
('Widget B', '2024-01-01', 500),
('Widget B', '2024-02-01', 700),
('Widget B', '2024-03-01', 650),
('Widget B', '2024-04-01', 800);

-- Expected output (3 rows):
-- +----------+------------+---------+
-- | product  | sale_month | revenue |
-- +----------+------------+---------+
-- | Widget A | 2024-02-01 |    1200 |
-- | Widget A | 2024-04-01 |    1500 |
-- | Widget B | 2024-02-01 |     700 |
-- +----------+------------+---------+