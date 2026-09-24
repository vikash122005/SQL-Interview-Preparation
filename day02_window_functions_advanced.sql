-- =====================================================
-- DAY 2: Window Functions - NTILE, FIRST_VALUE/LAST_VALUE, Running Totals, Frames
-- =====================================================

-- =========================================
-- Problem 1: Salary Buckets with NTILE
-- =========================================
-- Task: Split employees into 3 salary "buckets" (tiers) PER DEPARTMENT,
-- based on salary rank (NTILE(3)). Bucket 1 = highest earners, Bucket 3 = lowest.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(50),
    salary INT
);

INSERT INTO employees (emp_id, emp_name, department, salary) VALUES
(1, 'Alice',   'Engineering', 95000),
(2, 'Bob',     'Engineering', 88000),
(3, 'Carol',   'Engineering', 82000),
(4, 'Dave',    'Engineering', 75000),
(5, 'Eve',     'Engineering', 70000),
(6, 'Frank',   'Engineering', 65000),
(7, 'Grace',   'Sales',       60000),
(8, 'Heidi',   'Sales',       55000),
(9, 'Ivan',    'Sales',       50000);

-- Expected output (Engineering split into 3 buckets of 2, Sales into buckets since 9/3=3 uneven):
-- +---------+-------------+--------+--------+
-- | emp_name| department  | salary | bucket |
-- +---------+-------------+--------+--------+
-- | Alice   | Engineering |  95000 |      1 |
-- | Bob     | Engineering |  88000 |      1 |
-- | Carol   | Engineering |  82000 |      2 |
-- | Dave    | Engineering |  75000 |      2 |
-- | Eve     | Engineering |  70000 |      3 |
-- | Frank   | Engineering |  65000 |      3 |
-- | Grace   | Sales       |  60000 |      1 |
-- | Heidi   | Sales       |  55000 |      2 |
-- | Ivan    | Sales       |  50000 |      3 |
-- +---------+-------------+--------+--------+
-- (order by department, salary DESC)

--Solutions:
SELECT emp_name, department, salary,
NTILE(3) OVER(PARTITION BY department ORDER BY salary DESC)AS bucket
FROM employees;


-- =========================================
-- Problem 2: Highest & Lowest Salary Alongside Each Employee (FIRST_VALUE / LAST_VALUE)
-- =========================================
-- Task: For each employee, show their own salary, plus the highest salary
-- and lowest salary in their department (as extra columns) - without using GROUP BY.
-- Careful: LAST_VALUE needs the right frame clause, or it won't behave as expected -
-- look up what frame FIRST_VALUE/LAST_VALUE use by default and why that trips people up.

-- (reuse employees table from Problem 1)

-- Expected output columns: emp_name, department, salary, dept_highest, dept_lowest
-- Expected: dept_highest and dept_lowest should be the SAME value for every row
-- within a department (95000/65000 for Engineering, 60000/50000 for Sales).

--Solutions:
SELECT emp_name, department, salary,
FIRST_VALUE(salary) OVER(PARTITION BY department ORDER BY salary DESC) AS dept_highest,
LAST_VALUE(salary) OVER(PARTITION BY department ORDER BY salary DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS dept_lowest
FROM employees;

-- =========================================
-- Problem 3: Running Total of Revenue (SUM() OVER with frame clause)
-- =========================================
-- Task: Show a running (cumulative) total of revenue per product, ordered by month.

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
('Widget B', '2024-01-01', 500),
('Widget B', '2024-02-01', 700),
('Widget B', '2024-03-01', 650);

-- Expected output:
-- +----------+------------+---------+---------------+
-- | product  | sale_month | revenue | running_total |
-- +----------+------------+---------+---------------+
-- | Widget A | 2024-01-01 |    1000 |          1000 |
-- | Widget A | 2024-02-01 |    1200 |          2200 |
-- | Widget A | 2024-03-01 |     900 |          3100 |
-- | Widget A | 2024-04-01 |    1500 |          4600 |
-- | Widget B | 2024-01-01 |     500 |           500 |
-- | Widget B | 2024-02-01 |     700 |          1200 |
-- | Widget B | 2024-03-01 |     650 |          1850 |
-- +----------+------------+---------+---------------+

--Solutions:
SELECT *,
SUM(revenue) OVER(PARTITION BY product ORDER BY sale_month)AS running_total
FROM monthly_sales;

-- =========================================
-- Problem 4: 3-Month Moving Average (Frame: ROWS BETWEEN)
-- =========================================
-- Task: Using the same monthly_sales table, calculate a 3-month moving average
-- of revenue per product (current month + 2 previous months). For months with
-- fewer than 2 prior months available, average over however many exist.

-- Expected output:
-- +----------+------------+---------+------------------+
-- | product  | sale_month | revenue | moving_avg_3mo   |
-- +----------+------------+---------+------------------+
-- | Widget A | 2024-01-01 |    1000 |          1000.00 |
-- | Widget A | 2024-02-01 |    1200 |          1100.00 |
-- | Widget A | 2024-03-01 |     900 |          1033.33 |
-- | Widget A | 2024-04-01 |    1500 |          1200.00 |
-- | Widget B | 2024-01-01 |     500 |           500.00 |
-- | Widget B | 2024-02-01 |     700 |           600.00 |
-- | Widget B | 2024-03-01 |     650 |           616.67 |
-- +----------+------------+---------+------------------+

--Solutions:
SELECT *,
AVG(revenue) OVER(PARTITION BY product ORDER BY sale_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)AS moving_avg_3mo
FROM monthly_sales;