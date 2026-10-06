-- =====================================================
-- DAY 3: Aggregations - GROUP BY, HAVING, Multi-Condition Aggregates
-- =====================================================

-- =========================================
-- Problem 1: Departments with Average Salary Above a Threshold
-- =========================================
-- Task: Find all departments where the AVERAGE salary is greater than 70000.
-- Show department and its average salary, rounded to 2 decimal places.

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
(4, 'Dave',    'Sales',       60000),
(5, 'Eve',     'Sales',       55000),
(6, 'Frank',   'Sales',       50000),
(7, 'Grace',   'Marketing',   72000),
(8, 'Heidi',   'Marketing',   68000),
(9, 'Ivan',    'HR',          40000);

-- Expected output:
-- +-------------+-------------+
-- | department  | avg_salary  |
-- +-------------+-------------+
-- | Engineering |    88333.33 |
-- | Marketing   |    70000.00 |
-- +-------------+-------------+

--Solutions:

--Method1:
SELECT department, CAST(AVG(salary) AS DECIMAL(10,2)) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) >= 70000;

--Method2:
SELECT department, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) >= 70000;


-- =========================================
-- Problem 2: Departments with More Than 2 Employees
-- =========================================
-- Task: Find departments that have MORE THAN 2 employees. Show department
-- and employee count.
-- Think: should this filter go in WHERE or HAVING? Why?

-- (reuse employees table from Problem 1)

-- Expected output:
-- +-------------+----------------+
-- | department  | employee_count |
-- +-------------+----------------+
-- | Engineering |              3 |
-- | Sales       |              3 |
-- +-------------+----------------+

--Solutions:
SELECT department,COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 2;


-- =========================================
-- Problem 3: Products with Total Revenue Over 2000, Excluding a Specific Month
-- =========================================
-- Task: Find products whose TOTAL revenue (summed across all months EXCEPT
-- March 2024) exceeds 2000. Show product and total revenue.
-- Think: do you filter out March in WHERE, or in HAVING? What's the difference
-- in correctness if you get this wrong?

DROP TABLE IF EXISTS monthly_sales;

CREATE TABLE monthly_sales (
    product     VARCHAR(50),
    sale_month  DATE,
    revenue     INT
);

INSERT INTO monthly_sales (product, sale_month, revenue) VALUES
('Widget A', '2024-01-01', 1000),
('Widget A', '2024-02-01', 1200),
('Widget A', '2024-03-01', 5000),   -- outlier month, should be excluded
('Widget A', '2024-04-01', 300),
('Widget B', '2024-01-01', 500),
('Widget B', '2024-02-01', 700),
('Widget B', '2024-03-01', 4000),   -- outlier month, should be excluded
('Widget B', '2024-04-01', 400),
('Widget C', '2024-01-01', 100),
('Widget C', '2024-02-01', 150);

-- Expected output:
-- +----------+---------------+
-- | product  | total_revenue |
-- +----------+---------------+
-- | Widget A |          2500 |
-- | Widget B |          1600 |
-- +----------+---------------+
-- (Widget C excluded - total only 250; Widget A/B totals exclude the March spike)

--Solutions:

SELECT product,SUM(revenue) AS total_revenue
FROM monthly_sales
WHERE sale_month != '2024-03-01'
GROUP BY product
HAVING SUM(revenue) >= 2000;


-- =========================================
-- Problem 4: Customers Who Placed Orders in at Least 2 Different Months
-- =========================================
-- Task: Find customers who placed orders in 2 OR MORE distinct calendar months.
-- Show customer_id and the count of distinct months they ordered in.
-- Think: what aggregate function helps you count UNIQUE months, not just
-- total order rows?

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id    INT,
    customer_id INT,
    order_date  DATE,
    amount      INT
);

INSERT INTO orders (order_id, customer_id, order_date, amount) VALUES
(1, 201, '2024-01-05', 100),
(2, 201, '2024-01-20', 150),   -- same month as order 1
(3, 201, '2024-02-10', 200),
(4, 202, '2024-01-15', 300),
(5, 202, '2024-03-01', 250),
(6, 203, '2024-01-01', 500),
(7, 204, '2024-01-01', 50),
(8, 204, '2024-02-01', 75),
(9, 204, '2024-03-01', 90);

-- Expected output:
-- +-------------+----------------+
-- | customer_id | distinct_months|
-- +-------------+----------------+
-- |         201 |              2 |
-- |         202 |              2 |
-- |         204 |              3 |
-- +-------------+----------------+
-- (customer 203 excluded - only ordered in 1 distinct month)

--Solutions:
SELECT customer_id,COUNT(DISTINCT MONTH(order_date)) AS distinct_months
FROM orders
GROUP BY customer_id
HAVING COUNT(DISTINCT MONTH(order_date)) >=2;


-- =========================================
-- Problem 5: Department Salary Range (MAX - MIN) Above a Threshold
-- =========================================
-- Task: Find departments where the DIFFERENCE between the highest and lowest
-- salary (salary range/spread) is greater than 20000. Show department,
-- max_salary, min_salary, and the difference.

-- (reuse employees table from Problem 1)

-- Expected output:
-- +-------------+------------+------------+------------+
-- | department  | max_salary | min_salary | salary_gap |
-- +-------------+------------+------------+------------+
-- | Engineering |      95000 |      82000 |      13000 |   -- should NOT appear (gap <= 20000)
-- | Sales       |      60000 |      50000 |      10000 |   -- should NOT appear
-- +-------------+------------+------------+------------+
-- Wait - re-check this one carefully once you run it. What's the ACTUAL
-- expected output given the threshold of 20000? (Hint: none of the
-- departments above may actually qualify - verify by computing it yourself
-- before writing the query, then compare.)

--Solutions:
SELECT department,MAX(salary),MIN(salary),MAX(salary)-MIN(salary) AS salary_gap
FROM employees
GROUP BY department
HAVING MAX(salary)-MIN(salary) > 20000;