# SQL Interview Preparation (Data Engineer)

A 14-day hands-on SQL practice log for Data Engineer interviews. Each day has a `.sql` file with the table setup, the problem statements, expected outputs, and my solutions. All queries are written and tested in **MySQL 8**.

## Progress

| Day | Topic | File | Status |
|-----|-------|------|--------|
| 1 | Window functions: `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD` | `day01_window_functions.sql` | Done |
| 2 | Advanced window functions: `NTILE`, `FIRST_VALUE`/`LAST_VALUE`, running totals, frames | `day02_window_functions_advanced.sql` | In progress |
| 3 | Aggregations: `GROUP BY`, `HAVING` | `day03_group_by_having.sql` | Done |
| 4 | Multi-table JOINs, anti-joins, counting including zero | `day04_multi_table_joins.sql`, `day04_extra_practice.sql` | Done |
| 5 | Self-joins | `day05_self_joins.sql` | Done |
| 6 | Subqueries: correlated vs non-correlated, `EXISTS` vs `IN` | `day06_subqueries.sql` | Done |
| 7 | Set operations: `UNION`, `INTERSECT`, `EXCEPT` + review | `day07_set_operations.sql` | Done |
| 8 | String and date functions | | Upcoming |
| 9 | CTEs and recursive CTEs | | Upcoming |
| 10 | Running totals and moving averages | | Upcoming |
| 11 | Gaps and islands | | Upcoming |
| 12 | Pivot / unpivot, `CASE` transformations | | Upcoming |
| 13 | Query optimization: indexes, `EXPLAIN` | | Upcoming |
| 14 | Mock interview | | Upcoming |

## What I learned so far

### Day 1: Window functions
- `ROW_NUMBER` always returns one row per rank. `RANK` skips numbers after ties. `DENSE_RANK` does not skip.
- Nth highest distinct value per group, and top-N per group.
- `LAG` and `LEAD` return `NULL` at the start and end of a partition.
- Window function results can't be filtered in the same query level, so wrap them in a subquery.
- Always add a tiebreaker column to `ORDER BY` so results are deterministic.
- In `CASE`, handle `NULL` explicitly before the `ELSE`.
- Don't name an alias the same as an existing column.

### Day 3: GROUP BY and HAVING
- `WHERE` filters rows before grouping. `HAVING` filters groups after aggregation.
- `COUNT(DISTINCT ...)` counts unique values.
- `ROUND()` or `CAST(... AS DECIMAL)` for formatting averages.
- An empty result set can be the correct answer. Verify against the raw data before rewriting a query.

### Day 4: JOINs
- Multi-table joins are chained one at a time, each `ON` connecting to a table already in the chain.
- Anti-join: `LEFT JOIN` then `WHERE right_primary_key IS NULL`.
- `COUNT(*)` counts rows (it counts the NULL-padded row). `COUNT(column)` skips NULLs.
- Group by the unique ID plus any other selected non-aggregated columns.
- In an outer join, a filter in `WHERE` removes the NULL-padded rows and turns it into an inner join. Put the filter in `ON` to keep them.
- `COALESCE(SUM(...), 0)` turns a NULL total into 0.
- Multiply inside the aggregate: `SUM(quantity * price)`, not `SUM(quantity) * price`.

### Day 5: Self-joins
- A self-join is a normal join where both sides are the same table, told apart with two aliases (for example `e` for employee, `m` for manager).
- Employee-to-manager: `LEFT JOIN employees m ON e.manager_id = m.emp_id`. `LEFT` keeps the top of the hierarchy (no manager).
- Compare two rows of the same table, such as "earns more than their manager".
- Direct reports: group by the manager's unique `emp_id`, and count from the report side.
- No direct reports: anti-join with the table joined to itself.
- Pairs that share a value: join on the shared column and add `a.emp_id < b.emp_id`. This removes self-pairs and mirrored duplicates in one condition.
- `NULL = NULL` is never true, so rows with a NULL key never match each other.

### Day 6: Subqueries
- A non-correlated subquery runs once. A correlated subquery depends on the outer row and is evaluated per row.
- A scalar subquery used with `>` or `=` must return exactly one value.
- `IN` handles NULLs safely. `NOT IN` returns nothing if the list contains a NULL.
- Safe alternatives for "no match": `NOT EXISTS`, `LEFT JOIN ... IS NULL`, or `NOT IN` with `WHERE col IS NOT NULL`.
- `EXISTS` has no column on its left. The link between tables lives inside the subquery.
- "Top 1 per group" can be a window function or a correlated `MAX`. For top N, use the window function.
- Qualify column names inside correlated subqueries (`e1.salary`, `e2.salary`).

### Day 7: Set operations
- `UNION` stacks rows and removes duplicate rows. `UNION ALL` keeps everything and is faster.
- Each `SELECT` needs the same number of columns, matched by position. Column names come from the first `SELECT`.
- `ORDER BY` goes once, at the very end.
- `INTERSECT` returns rows in both results. `EXCEPT` returns rows in the first but not the second, and the order of the two queries matters.
- Wrap each part in parentheses when combining several set operations.
- Use `UNION ALL` when adding up values from two sources. `UNION` silently drops legitimate repeated values and gives the wrong total.
- `LEFT JOIN ... UNION ... RIGHT JOIN` emulates a `FULL OUTER JOIN` in MySQL.
- Add a literal label column (`'online' AS channel`) to tell the sources apart after stacking.

## Common mistakes I'm working on
1. Putting an outer-join filter in `WHERE` when it belongs in `ON`.
2. Using `COUNT(*)` after a `LEFT JOIN` when I need `COUNT(right_pk)`.
3. Forgetting `ORDER BY`, aliases on calculated columns, or a tiebreaker.
4. Using `>=` when the problem says strictly higher.
5. Trusting an expected output without checking it against the raw data.

## How to run

```bash
mysql -u <username> -p <database_name> < day01_window_functions.sql
```

Or inside the MySQL client:

```sql
SOURCE /full/path/to/day01_window_functions.sql;
```

## Tools
- MySQL 8.0.31+ (needed for `INTERSECT` and `EXCEPT`)
- Git and GitHub