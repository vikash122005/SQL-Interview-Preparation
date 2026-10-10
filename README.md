# SQL Interview Preparation (Data Engineer)

A 14-day hands-on SQL practice log for Data Engineer interviews. Each day has a `.sql` file with the table setup, the problem statements, expected outputs, and my solutions. All queries are written and tested in **MySQL 8**.

## Progress

| Day | Topic | File | Status |
|-----|-------|------|--------|
| 1 | Window functions: `RANK`, `DENSE_RANK`, `ROW_NUMBER`, `LAG`, `LEAD` | `day01_window_functions.sql` | Done |
| 2 | Advanced window functions: `NTILE`, `FIRST_VALUE`/`LAST_VALUE`, running totals, frames | `day02_window_functions_advanced.sql` | Done |
| 3 | Aggregations: `GROUP BY`, `HAVING` | `day03_group_by_having.sql` | Done |
| 4 | Multi-table JOINs, anti-joins, counting including zero | `day04_multi_table_joins.sql`, `day04_extra_practice.sql` | Done |
| 5 | Self-joins | | Upcoming |
| 6 | Subqueries: correlated, `EXISTS` vs `IN` | | Upcoming |
| 7 | Set operations and review | | Upcoming |
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

## How to run

```bash
mysql -u <username> -p <database_name> < day01_window_functions.sql
```

Or inside the MySQL client:

```sql
SOURCE /full/path/to/day01_window_functions.sql;
```

## Tools
- MySQL 8
- Git and GitHub