-- =====================================================
-- DAY 4 EXTRA PRACTICE: LEFT JOIN anti-join + COUNT including zero
-- =====================================================

DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
    author_id   INT,
    author_name VARCHAR(50)
);

CREATE TABLE books (
    book_id   INT,
    author_id INT,
    title     VARCHAR(50),
    pages     INT
);

INSERT INTO authors (author_id, author_name) VALUES
(1, 'Orwell'),
(2, 'Austen'),
(3, 'Rowling'),
(4, 'Tolkien'),
(5, 'Christie');

INSERT INTO books (book_id, author_id, title, pages) VALUES
(1, 1, '1984',           328),
(2, 1, 'Animal Farm',    112),
(3, 2, 'Emma',           474),
(4, 3, 'Harry Potter 1', 223),
(5, 3, 'Harry Potter 2', 251),
(6, 3, 'Harry Potter 3', 317);


-- =========================================
-- Problem 1: Authors Who Have Not Written Any Book
-- =========================================
-- Task: Find all authors with no rows in the books table.
-- Show author_id and author_name.
-- Reminder: anti-join on the right table's primary key (book_id).

-- Expected output:
-- +-----------+-------------+
-- | author_id | author_name |
-- +-----------+-------------+
-- |         4 | Tolkien     |
-- |         5 | Christie    |
-- +-----------+-------------+

--Solutions:
SELECT a.author_id,a.author_name
FROM authors a
LEFT JOIN books b on a.author_id = b.author_id
WHERE b.book_id IS NULL;


-- =========================================
-- Problem 2: Number of Books per Author (Including Zero)
-- =========================================
-- Task: Show every author with the number of books they wrote.
-- Authors with no books must show 0.
-- Order by author_id.

-- Expected output:
-- +-----------+-------------+------------+
-- | author_id | author_name | book_count |
-- +-----------+-------------+------------+
-- |         1 | Orwell      |          2 |
-- |         2 | Austen      |          1 |
-- |         3 | Rowling     |          3 |
-- |         4 | Tolkien     |          0 |
-- |         5 | Christie    |          0 |
-- +-----------+-------------+------------+

--Solutions:
SELECT a.author_id,a.author_name,COUNT(b.book_id)
FROM authors a
LEFT JOIN books b on a.author_id = b.author_id
GROUP BY a.author_id,a.author_name;