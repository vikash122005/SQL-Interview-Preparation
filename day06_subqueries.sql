-- =====================================================
-- DAY 6: Subqueries (non-correlated vs correlated, EXISTS vs IN)
-- =====================================================

-- =========================================
-- SETUP (run once, used by all problems)
-- =========================================

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    dept_id   INT,
    dept_name VARCHAR(50)
);

CREATE TABLE employees (
    emp_id   INT,
    emp_name VARCHAR(50),
    dept_id  INT,          -- NULL means "not assigned to a department"
    salary   INT
);

INSERT INTO departments (dept_id, dept_name) VALUES
(10, 'Engineering'),
(20, 'Sales'),
(30, 'Marketing'),
(40, 'HR');

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'Asha',   10,   90000),
(2, 'Ravi',   10,   80000),
(3, 'Meena',  20,   60000),
(4, 'Karan',  20,   70000),
(5, 'Divya',  30,   50000),
(6, 'Arjun',  NULL, 65000),   -- no department
(7, 'Neha',   10,   95000);


-- =========================================
-- Problem 1: Employees Earning More Than the Company Average
-- =========================================
-- Task: Find employees whose salary is above the average salary of ALL
-- employees. Show emp_name and salary. Order by salary DESC.
-- Think: the inner query doesn't depend on the outer row at all.
-- It runs once and returns a single value (a non-correlated scalar subquery).
-- Where does it go in the outer query?

-- Expected output:
-- +----------+--------+
-- | emp_name | salary |
-- +----------+--------+
-- | Neha     |  95000 |
-- | Asha     |  90000 |
-- | Ravi     |  80000 |
-- +----------+--------+
-- (company average = 72857.14)

--Solutions:
SELECT emp_name,salary
FROM employees
WHERE salary >(SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;


-- =========================================
-- Problem 2: Employees Earning More Than Their Own Department's Average
-- =========================================
-- Task: Find employees whose salary is above the average salary of THEIR
-- OWN department. Show emp_name, dept_id, salary. Order by emp_id.
-- Think: now the inner query depends on the outer row (a correlated
-- subquery). It must be re-evaluated for each employee, using that
-- employee's dept_id.
-- Also think: what happens to Arjun, whose dept_id is NULL?

-- Expected output:
-- +----------+---------+--------+
-- | emp_name | dept_id | salary |
-- +----------+---------+--------+
-- | Asha     |      10 |  90000 |
-- | Karan    |      20 |  70000 |
-- | Neha     |      10 |  95000 |
-- +----------+---------+--------+
-- (dept averages: 10 = 88333.33, 20 = 65000, 30 = 50000)

--Solutions:
SELECT e1.emp_name, e1.dept_id, e1.salary
FROM employees e1
WHERE salary >(SELECT AVG(salary) FROM employees e2 WHERE e1.dept_id = e2.dept_id)
ORDER BY e1.emp_id;


-- =========================================
-- Problem 3: Departments That Have at Least One Employee
-- =========================================
-- Task: Find departments that have at least one employee.
-- Show dept_id and dept_name. Order by dept_id.
-- Write it TWICE: once with IN, once with EXISTS.
-- Both should return the same rows here.

-- Expected output:
-- +---------+-------------+
-- | dept_id | dept_name   |
-- +---------+-------------+
-- |      10 | Engineering |
-- |      20 | Sales       |
-- |      30 | Marketing   |
-- +---------+-------------+

--Solution1:(IN)

SELECT dept_id,dept_name
FROM departments
WHERE dept_id IN (SELECT dept_id FROM employees GROUP BY dept_id)
ORDER BY dept_id;

--Solution2:(EXISTS)

SELECT d.dept_id,d.dept_name
FROM departments d
WHERE EXISTS (SELECT 1 FROM employees e WHERE d.dept_id = e.dept_id)
ORDER BY d.dept_id;


-- =========================================
-- Problem 4: Departments With No Employees (and the NOT IN trap)
-- =========================================
-- Task A: Find departments with no employees, using NOT EXISTS.
-- Show dept_id and dept_name.
-- Task B: Now write the same thing using NOT IN (a subquery that selects
-- employees.dept_id). Run it and look at the result.
-- Question: why does Task B not return the same rows as Task A?
-- Hint: look at Arjun's dept_id, and remember what NULL does in comparisons.

-- Expected output for Task A:
-- +---------+-----------+
-- | dept_id | dept_name |
-- +---------+-----------+
-- |      40 | HR        |
-- +---------+-----------+
-- Task B (the naive NOT IN) will return an EMPTY result. Explain why,
-- then fix it so NOT IN works.

--Solutions(Task A):
SELECT d.dept_id,d.dept_name
FROM departments d
WHERE NOT EXISTS(SELECT 1 FROM employees e WHERE d.dept_id = e.dept_id);

--Solutions(Task B):(NOT IN will take NULL into account and will return empty result, so we need to filter out NULLs in the subquery)
SELECT dept_id,dept_name
FROM departments
WHERE dept_id NOT IN(SELECT dept_id FROM employees WHERE dept_id IS NOT NULL);

--Solutions(Just tried with ANTI JOINS):
SELECT d.dept_id,d.dept_name
FROM departments d
LEFT JOIN employees e on d.dept_id = e.dept_id
WHERE e.emp_id IS NULL;


-- =========================================
-- Problem 5: Highest Earner in Each Department
-- =========================================
-- Task: Find the employee(s) who earn the highest salary in their own
-- department. Show emp_name, dept_id, salary. Order by emp_id.
-- Use a correlated subquery with MAX.
-- Think: Arjun has no department. Should he appear? What does your query do
-- with him, and why?

-- Expected output:
-- +----------+---------+--------+
-- | emp_name | dept_id | salary |
-- +----------+---------+--------+
-- | Karan    |      20 |  70000 |
-- | Divya    |      30 |  50000 |
-- | Neha     |      10 |  95000 |
-- +----------+---------+--------+

--Solutions:
SELECT e1.emp_name,e1.dept_id,e1.salary
FROM employees e1
WHERE salary = (SELECT MAX(salary) FROM employees e2 WHERE e1.dept_id = e2.dept_id)
ORDER BY e1.emp_id;

--Solutions(Just tried with DENSE_RANK() function):
SELECT emp_name,dept_id,salary
FROM (SELECT *,DENSE_RANK() OVER(PARTITION BY dept_id ORDER BY salary DESC) AS ranking 
FROM employees WHERE dept_id IS NOT NULL) AS ranked
WHERE ranking =1
ORDER BY emp_id;

