-- =====================================================
-- DAY 8: String and Date Functions (common in ETL / data cleaning)
-- =====================================================
-- Functions you will likely need (look up the syntax in the MySQL docs):
--   Strings: SUBSTRING_INDEX, CONCAT, LOWER, UPPER, TRIM, REPLACE, RIGHT
--   Dates:   DATE_FORMAT, DATEDIFF
-- Remember: any function applied to NULL usually returns NULL.

-- =========================================
-- SETUP (run once, used by all problems)
-- =========================================

DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS deliveries;

CREATE TABLE users (
    user_id     INT,
    full_name   VARCHAR(50),
    email       VARCHAR(50),
    phone       VARCHAR(20),
    signup_date DATE
);

INSERT INTO users (user_id, full_name, email, phone, signup_date) VALUES
(1, 'Asha Raman',  'Asha.Raman@Gmail.com', '98765 43210',     '2024-01-15'),
(2, 'Ravi Kumar',  'ravi.kumar@yahoo.com', '+91-98765-43211', '2024-02-20'),
(3, 'Meena Iyer',  'meena@gmail.com',      '98765-43212',     '2024-03-05'),
(4, 'Karan Shah',  'KARAN.S@outlook.com',  ' 98765 43213 ',   '2024-03-28'),
(5, 'Divya Nair',  'divya_n@yahoo.com',    '+91 98765 43214', '2024-04-10');

CREATE TABLE deliveries (
    order_id      INT,
    order_date    DATE,
    delivery_date DATE      -- NULL means not delivered yet
);

INSERT INTO deliveries (order_id, order_date, delivery_date) VALUES
(1, '2024-05-01', '2024-05-03'),
(2, '2024-05-02', '2024-05-07'),
(3, '2024-05-10', '2024-05-13'),
(4, '2024-05-15', '2024-05-22'),
(5, '2024-05-20', NULL);


-- =========================================
-- Problem 1: Extract the Email Domain
-- =========================================
-- Task: For each user, show user_id and the email domain in lowercase
-- (the part after the @). Order by user_id.
-- Note: user 1's domain is written 'Gmail.com' in the data.

-- Expected output:
-- +---------+-------------+
-- | user_id | domain      |
-- +---------+-------------+
-- |       1 | gmail.com   |
-- |       2 | yahoo.com   |
-- |       3 | gmail.com   |
-- |       4 | outlook.com |
-- |       5 | yahoo.com   |
-- +---------+-------------+

--Solutions:
SELECT user_id,SUBSTRING_INDEX(LOWER(email),'@',-1) AS domain
FROM users
ORDER BY user_id;


-- =========================================
-- Problem 2: Users per Email Domain
-- =========================================
-- Task: Count the users for each email domain (lowercase).
-- Order by user_count DESC, then domain.
-- Think: you just wrote the domain expression in Problem 1. Where can you
-- reuse it, and what do you GROUP BY?

-- Expected output:
-- +-------------+------------+
-- | domain      | user_count |
-- +-------------+------------+
-- | gmail.com   |          2 |
-- | yahoo.com   |          2 |
-- | outlook.com |          1 |
-- +-------------+------------+

--Solutions:
SELECT SUBSTRING_INDEX(LOWER(email),'@',-1) AS domain,COUNT(*) AS user_count
FROM users
GROUP BY domain
ORDER BY user_count DESC , domain;


-- =========================================
-- Problem 3: Format Names as "Last, First"
-- =========================================
-- Task: Split full_name into first and last name, and show user_id and
-- display_name in the format 'Last, First'. Order by user_id.

-- Expected output:
-- +---------+--------------+
-- | user_id | display_name |
-- +---------+--------------+
-- |       1 | Raman, Asha  |
-- |       2 | Kumar, Ravi  |
-- |       3 | Iyer, Meena  |
-- |       4 | Shah, Karan  |
-- |       5 | Nair, Divya  |
-- +---------+--------------+

--Solutions:
SELECT user_id,CONCAT(SUBSTRING_INDEX(full_name,' ',-1),", ",SUBSTRING_INDEX(full_name,' ',1)) AS display_name
FROM users
ORDER BY user_id;


-- =========================================
-- Problem 4: Clean Phone Numbers
-- =========================================
-- Task: The phone column is messy (spaces, hyphens, a +91 prefix, and
-- leading/trailing spaces). Return user_id and a clean 10-digit phone number.
-- Order by user_id.
-- Think: some functions remove characters, one removes edge spaces, and one
-- keeps only the last N characters. In which order should you apply them?

-- Expected output:
-- +---------+------------+
-- | user_id | clean_phone|
-- +---------+------------+
-- |       1 | 9876543210 |
-- |       2 | 9876543211 |
-- |       3 | 9876543212 |
-- |       4 | 9876543213 |
-- |       5 | 9876543214 |
-- +---------+------------+

--Solutions:
SELECT user_id,RIGHT(REPLACE(REPLACE(TRIM(phone),'-',''),' ',''),10) AS clean_phone
FROM users
ORDER BY user_id;


-- =========================================
-- Problem 5: Signups per Month
-- =========================================
-- Task: Count how many users signed up in each month. Show the month as
-- 'YYYY-MM' and the count. Order by month.
-- Think: a month label that includes the year avoids the MONTH()-ignores-the-year
-- problem from Day 3.

-- Expected output:
-- +---------+--------+
-- | month   | signups|
-- +---------+--------+
-- | 2024-01 |      1 |
-- | 2024-02 |      1 |
-- | 2024-03 |      2 |
-- | 2024-04 |      1 |
-- +---------+--------+

--Solutions:
SELECT DATE_FORMAT(signup_date, '%Y-%m') AS month,COUNT(*) AS signups
FROM users
GROUP BY DATE_FORMAT(signup_date, '%Y-%m')
ORDER BY DATE_FORMAT(signup_date, '%Y-%m');


-- =========================================
-- Problem 6: Late Deliveries (date differences + NULL handling)
-- =========================================
-- Task A: Find orders that took MORE than 3 days to deliver.
-- Show order_id, order_date, delivery_date, days_taken. Order by order_id.
-- Think: what happens to order 5 (not delivered)? What happens to order 3
-- (exactly 3 days)? Is that what the task asks for?
--
-- Task B: Show ALL orders with a delivery_status column:
--   'ON TIME' if days_taken <= 3, 'LATE' if more than 3,
--   'PENDING' if not delivered yet.
-- Order by order_id. (Day 1 reminder: handle NULL explicitly in CASE.)

-- Expected output for Task A:
-- +----------+------------+---------------+------------+
-- | order_id | order_date | delivery_date | days_taken |
-- +----------+------------+---------------+------------+
-- |        2 | 2024-05-02 | 2024-05-07    |          5 |
-- |        4 | 2024-05-15 | 2024-05-22    |          7 |
-- +----------+------------+---------------+------------+
--
-- Expected output for Task B:
-- +----------+-----------------+
-- | order_id | delivery_status |
-- +----------+-----------------+
-- |        1 | ON TIME         |
-- |        2 | LATE            |
-- |        3 | ON TIME         |
-- |        4 | LATE            |
-- |        5 | PENDING         |
-- +----------+-----------------+