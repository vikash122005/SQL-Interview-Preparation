-- =====================================================
-- DAY 5: Self-JOINs (hierarchies, comparisons within the same table)
-- =====================================================

-- =========================================
-- SETUP (run once, used by all problems)
-- =========================================

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id     INT,
    emp_name   VARCHAR(50),
    manager_id INT,          -- points to emp_id of this employee's manager
    salary     INT
);

INSERT INTO employees (emp_id, emp_name, manager_id, salary) VALUES
(1, 'Neha',    NULL, 150000),   -- CEO, no manager
(2, 'Arjun',   1,    100000),
(3, 'Priya',   1,     95000),
(4, 'Rahul',   2,     80000),
(5, 'Sneha',   2,    105000),
(6, 'Vikram',  3,     70000),
(7, 'Divya',   3,     60000),
(8, 'Karthik', 4,     55000);


-- =========================================
-- Problem 1: Employee and Their Manager's Name
-- =========================================
-- Task: Show every employee with their manager's name.
-- The CEO has no manager, but must still appear (manager_name = NULL).
-- Order by emp_id.
-- Think: you need the SAME table twice in one query. How do you tell the
-- two copies apart? And which join type keeps the CEO?

-- Expected output:
-- +----------+--------------+
-- | emp_name | manager_name |
-- +----------+--------------+
-- | Neha     | NULL         |
-- | Arjun    | Neha         |
-- | Priya    | Neha         |
-- | Rahul    | Arjun        |
-- | Sneha    | Arjun        |
-- | Vikram   | Priya        |
-- | Divya    | Priya        |
-- | Karthik  | Rahul        |
-- +----------+--------------+

--Solutions:
SELECT e.emp_name,m.emp_name AS manager_name
FROM employees e
LEFT JOIN employees m on e.manager_id = m.emp_id;



-- =========================================
-- Problem 2: Employees Who Earn More Than Their Manager
-- =========================================
-- Task: Find employees whose salary is higher than their manager's salary.
-- Show emp_name, salary, manager_name, manager_salary.
-- Think: this is a comparison between two columns from two copies of
-- the same table.

-- Expected output:
-- +----------+--------+--------------+----------------+
-- | emp_name | salary | manager_name | manager_salary |
-- +----------+--------+--------------+----------------+
-- | Sneha    | 105000 | Arjun        |         100000 |
-- +----------+--------+--------------+----------------+

--Solutions:
SELECT e.emp_name,e.salary,m.emp_name AS manager_name,m.salary AS manager_salary
FROM employees e
LEFT JOIN employees m on e.manager_id = m.emp_id
WHERE e.salary > m.salary;


-- =========================================
-- Problem 3: Number of Direct Reports per Manager
-- =========================================
-- Task: For each manager, count how many employees report directly to them.
-- Show only people who have at least one direct report.
-- Show manager name and direct_reports.
-- Order by direct_reports DESC, then manager name.

-- Expected output:
-- +--------------+----------------+
-- | manager_name | direct_reports |
-- +--------------+----------------+
-- | Arjun        |              2 |
-- | Neha         |              2 |
-- | Priya        |              2 |
-- | Rahul        |              1 |
-- +--------------+----------------+

--Solutions:
SELECT m.emp_name AS manager_name,COUNT(e.emp_id) AS direct_reports
FROM employees e
JOIN employees m on e.manager_id = m.emp_id
GROUP BY m.emp_name,m.emp_id
ORDER BY direct_reports DESC,m.emp_name;


-- =========================================
-- Problem 4: Employees with No Direct Reports
-- =========================================
-- Task: Find employees who do not manage anyone.
-- Show emp_id and emp_name. Order by emp_id.
-- Think: this is the anti-join pattern from Day 4, but the table is
-- joined to itself.

-- Expected output:
-- +--------+----------+
-- | emp_id | emp_name |
-- +--------+----------+
-- |      5 | Sneha    |
-- |      6 | Vikram   |
-- |      7 | Divya    |
-- |      8 | Karthik  |
-- +--------+----------+

--Solutions:
SELECT e.emp_id,e.emp_name
FROM employees e
LEFT JOIN employees m on e.emp_id = m.manager_id
WHERE m.manager_id IS NULL;

-- =========================================
-- Problem 5: Pairs of Employees Who Share the Same Manager
-- =========================================
-- Task: List every pair of employees who report to the same manager.
-- Each pair must appear only ONCE (not as both A-B and B-A), and an
-- employee must not be paired with themselves.
-- Show emp1, emp2, manager_id. Order by manager_id, then emp1's emp_id.
-- Think: what join condition removes self-pairs AND mirrored duplicates
-- in one step? What happens to the CEO, whose manager_id is NULL?

-- Expected output:
-- +--------+--------+------------+
-- | emp1   | emp2   | manager_id |
-- +--------+--------+------------+
-- | Arjun  | Priya  |          1 |
-- | Rahul  | Sneha  |          2 |
-- | Vikram | Divya  |          3 |
-- +--------+--------+------------+

--Solutions:
SELECT a.emp_name AS emp1, b.emp_name AS emp2, a.manager_id
FROM employees a
JOIN employees b ON a.manager_id = b.manager_id
WHERE a.emp_id < b.emp_id
ORDER BY a.manager_id, a.emp_id;