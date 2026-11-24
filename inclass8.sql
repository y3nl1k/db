-- ============================================================
-- In-Class Task: Does the Index Actually Get Used?
-- Laboratory Work 8 - SQL Indexes.  PostgreSQL 12+ (tested on 16).
-- Run this setup first, then work through steps 1-5 on the handout.
-- ============================================================

DROP TABLE IF EXISTS staff;

CREATE TABLE staff (
    staff_id  INT PRIMARY KEY,
    full_name VARCHAR(60)   NOT NULL,
    dept_id   INT           NOT NULL,
    city      VARCHAR(30)   NOT NULL,
    salary    NUMERIC(10,2) NOT NULL,
    hired_on  DATE          NOT NULL,
    active    BOOLEAN       NOT NULL
);

INSERT INTO staff
SELECT g,
       'Employee ' || g,
       1 + g % 12,
       (ARRAY['Almaty','Astana','Shymkent','Aktobe'])[1 + g % 4],
       40000 + (g * 37) % 60000,
       DATE '2015-01-01' + (g % 3800),
       (g % 50 <> 0)
  FROM generate_series(1, 200000) g;

ANALYZE staff;

--1
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on = DATE '2021-06-15';
--Seq Scan on staff (actual time=0.514..37.184 rows=53.00 loops=1)
CREATE INDEX staff_hired_idx ON staff(hired_on);
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on = DATE '2021-06-15';
--Bitmap Heap Scan on staff (actual time=0.144..0.240 rows=53.00 loops=1)

--2
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on >= DATE '2016-01-01';
EXPLAIN (ANALYZE, COSTS OFF) SELECT * FROM staff WHERE hired_on >= DATE '2025-01-01';

--3
CREATE INDEX staff_dept_salary_idx ON staff(dept_id, salary);
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE dept_id = 7 AND salary > 90000; --uses this index
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE salary > 90000; -- is not using this index because dept_id col is sorted first, not salary
create index staff_salary_ind on staff(salary);

--4
CREATE INDEX staff_lower_name_idx ON staff(LOWER(full_name));

EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE LOWER(full_name) = 'employee 4242';
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE full_name = 'Employee 4242';
--index stores only the lowercase fullname values;

--5
CREATE INDEX staff_inactive_idx ON staff(hired_on) WHERE NOT active;
SELECT indexname, pg_size_pretty(pg_relation_size(indexname::regclass)) AS size
FROM pg_indexes WHERE tablename = 'staff' ORDER BY indexname;
EXPLAIN (COSTS OFF) SELECT * FROM staff WHERE NOT active AND hired_on < DATE '2016-01-01';

--staff_hired_idx's size 1376 kB stores each staff's hired date, bigger one

--staff_inactive_idx's size 48 kB stores only the ones whos not active, where clause reduces the num of rows. query must use the same logic condition like in index condition

--6
--KEEP staff_lower_name_idx: the most frequently used column imo is staff full name, and to make this more convinient to use, put it in the func lowercase to compare and find every employee fast.
--KEEP staff_hired_idx: the same reason as 1, frequency of usage
--delete staff_dept_salary_idx: on our case, we can use this index only with the column dept_id, if we need a salary sorted list or etc, it wont be efficient
--delete staff_inactive_idx: col is not used as frequently as the first one, no need to create a ind for that

