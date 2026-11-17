--1.1
-- 1. Create database university_main
CREATE DATABASE university_main
 --   WITH OWNER = CURRENT_USER (causes an error because it is the default parameter
    TEMPLATE = template0
    ENCODING = 'UTF8';

-- 2. Create database university_archive
CREATE DATABASE university_archive
    WITH CONNECTION LIMIT = 50
    TEMPLATE = template0;

-- 3. Create database university_test
CREATE DATABASE university_test
    WITH IS_TEMPLATE = true
    CONNECTION LIMIT = 10;

--1.2
-- 1 Create	tablespace	student_data
CREATE TABLESPACE student_data LOCATION 'C:/data/students';

-- 2. Create tablespace course_data
CREATE TABLESPACE course_data LOCATION 'C:/data/courses';

-- 3. Create database university_distributed
CREATE DATABASE university_distributed
    WITH TABLESPACE = student_data
    TEMPLATE = template0
    ENCODING = 'LATIN9'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C';


--2.1
CREATE TABLE students (
    student_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone CHAR(15),
    date_of_birth DATE,
    enrollment_date DATE,
    gpa NUMERIC(3, 2),
    is_active BOOLEAN,
    graduation_year SMALLINT
);

CREATE TABLE professors (
    professor_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    office_number VARCHAR(20),
    hire_date DATE,
    salary NUMERIC(12, 2),
    is_tenured BOOLEAN,
    years_experience INTEGER
);

CREATE TABLE courses (
    course_id SERIAL PRIMARY KEY,
    course_code CHAR(8),
    course_title VARCHAR(100),
    description TEXT,
    credits SMALLINT,
    max_enrollment INTEGER,
    course_fee NUMERIC(10, 2),
    is_online BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

--2.2
CREATE TABLE class_schedule (
    schedule_id SERIAL PRIMARY KEY,
    course_id INTEGER,
    professor_id INTEGER,
    classroom VARCHAR(20),
    class_date DATE,
    start_time TIME WITHOUT TIME ZONE,
    end_time TIME WITHOUT TIME ZONE,
    duration INTERVAL
);

CREATE TABLE student_records (
    record_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    course_id INTEGER,
    semester VARCHAR(20),
    year INTEGER,
    grade CHAR(2),
    attendance_percentage NUMERIC(4, 1),
    submission_timestamp TIMESTAMP WITH TIME ZONE,
    last_updated TIMESTAMP WITH TIME ZONE
);

--3.1
-- Modify students table
ALTER TABLE students ADD COLUMN middle_name VARCHAR(30);
ALTER TABLE students ADD COLUMN student_status VARCHAR(20);
ALTER TABLE students ALTER COLUMN phone TYPE VARCHAR(20);
ALTER TABLE students ALTER COLUMN student_status SET DEFAULT 'ACTIVE';
ALTER TABLE students ALTER COLUMN gpa SET DEFAULT 0.00;

-- Modify professors table
ALTER TABLE professors ADD COLUMN department_code CHAR(5);
ALTER TABLE professors ADD COLUMN research_area TEXT;
ALTER TABLE professors ALTER COLUMN years_experience TYPE SMALLINT;
ALTER TABLE professors ALTER COLUMN is_tenured SET DEFAULT false;
ALTER TABLE professors ADD COLUMN last_promotion_date DATE;

-- Modify courses table
ALTER TABLE courses ADD COLUMN prerequisite_course_id INTEGER;
ALTER TABLE courses ADD COLUMN difficulty_level SMALLINT;
ALTER TABLE courses ALTER COLUMN course_code TYPE VARCHAR(10);
ALTER TABLE courses ALTER COLUMN credits SET DEFAULT 3;
ALTER TABLE courses ADD COLUMN lab_required BOOLEAN DEFAULT false;

--3.2
-- For class_schedule table
ALTER TABLE class_schedule ADD COLUMN room_capacity INTEGER;
ALTER TABLE class_schedule DROP COLUMN duration;
ALTER TABLE class_schedule ADD COLUMN session_type VARCHAR(15);
ALTER TABLE class_schedule ALTER COLUMN classroom TYPE VARCHAR(30);
ALTER TABLE class_schedule ADD COLUMN equipment_needed TEXT;

-- For student_records table
ALTER TABLE student_records ADD COLUMN extra_credit_points NUMERIC(3, 1);
ALTER TABLE student_records ALTER COLUMN grade TYPE VARCHAR(5);
ALTER TABLE student_records ALTER COLUMN extra_credit_points SET DEFAULT 0.0;
ALTER TABLE student_records ADD COLUMN final_exam_date DATE;
ALTER TABLE student_records DROP COLUMN last_updated;

--4.1
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100),
    department_code CHAR(5),
    building VARCHAR(50),
    phone VARCHAR(15),
    budget NUMERIC(15, 2),
    established_year INTEGER
);

CREATE TABLE library_books (
    book_id SERIAL PRIMARY KEY,
    isbn CHAR(13),
    title VARCHAR(200),
    author VARCHAR(100),
    publisher VARCHAR(100),
    publication_date DATE,
    price NUMERIC(10, 2),
    is_available BOOLEAN,
    acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE
);

CREATE TABLE student_book_loans (
    loan_id SERIAL PRIMARY KEY,
    student_id INTEGER,
    book_id INTEGER,
    loan_date DATE,
    due_date DATE,
    return_date DATE,
    fine_amount NUMERIC(10, 2),
    loan_status VARCHAR(20)
);

--4.2
-- 1. Add foreign key columns
ALTER TABLE professors ADD COLUMN department_id INTEGER;
ALTER TABLE students ADD COLUMN advisor_id INTEGER;
ALTER TABLE courses ADD COLUMN department_id INTEGER;

-- 2. Create lookup tables
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4, 1),
    max_percentage NUMERIC(4, 1),
    gpa_points NUMERIC(3, 2)
);

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);

--5.1
-- 1. Drop tables if they exist
DROP TABLE IF EXISTS student_book_loans;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

-- 2. Recreate grade_scale table with additional column description
CREATE TABLE grade_scale (
    grade_id SERIAL PRIMARY KEY,
    letter_grade CHAR(2),
    min_percentage NUMERIC(4, 1),
    max_percentage NUMERIC(4, 1),
    gpa_points NUMERIC(3, 2),
    description TEXT
);

-- 3. Drop and recreate with CASCADE
DROP TABLE IF EXISTS semester_calendar CASCADE;

CREATE TABLE semester_calendar (
    semester_id SERIAL PRIMARY KEY,
    semester_name VARCHAR(20),
    academic_year INTEGER,
    start_date DATE,
    end_date DATE,
    registration_deadline TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN
);


--5.2

ALTER DATABASE university_test IS_TEMPLATE = false;
-- 1. Drop databases if they exist
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;

-- 2. Create new database university_backup using university_main as template
CREATE DATABASE university_backup
    WITH TEMPLATE = university_main;
\



-- ===========================================================================
--  Indexes in Practice -- live lecture script
--  Database Systems
--
--  Usage:   createdb indexdemo
--           psql -d indexdemo -f index_demos.sql        (runs everything)
--  or open this file and run it block by block in psql / DBeaver / pgAdmin.
--
--  Every demo runs its query TWICE and you read the SECOND plan: the first
--  run pays for reading cold pages from disk and makes the comparison
--  meaningless.
-- ===========================================================================

\pset pager off
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
-- SETUP  (~20 seconds)
-- ---------------------------------------------------------------------------
\echo '>>> SETUP: building 200k customers and 3M orders'

DROP TABLE IF EXISTS orders_noidx, orders_idx, orders, customers;

CREATE TABLE customers (
    customer_id   int PRIMARY KEY,
    full_name     text NOT NULL,
    email         text NOT NULL,
    city          text NOT NULL,
    signup_date   date NOT NULL
);

INSERT INTO customers (customer_id, full_name, email, city, signup_date)
SELECT g, 'Customer ' || g,
       'user' || g || '@' || (ARRAY['mail.kz','gmail.com','kbtu.kz','yandex.ru'])[1 + g % 4],
       (ARRAY['Almaty','Astana','Shymkent','Aktobe','Karaganda','Atyrau'])[1 + g % 6],
       DATE '2020-01-01' + (g % 2000)
FROM generate_series(1, 200000) g;

CREATE TABLE orders (
    order_id     bigint PRIMARY KEY,
    customer_id  int NOT NULL,
    order_date   date NOT NULL,
    status       text NOT NULL,
    amount       numeric(10,2) NOT NULL,
    note         text
);

SELECT setseed(0.42);          -- same data every time you run the lecture

INSERT INTO orders (order_id, customer_id, order_date, status, amount, note)
SELECT g,
       1 + (random() * 199999)::int,
       DATE '2023-01-01' + (random() * 1000)::int,
       CASE WHEN random() < 0.85 THEN 'shipped'
            WHEN random() < 0.67 THEN 'pending'
            ELSE 'cancelled' END,
       round((10 + random() * 9990)::numeric, 2),
       'order note ' || g
FROM generate_series(1, 3000000) g;

VACUUM ANALYZE customers;
VACUUM ANALYZE orders;

-- Show the class what they are working with: no indexes but the two PKs.
SELECT status, count(*),
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM orders GROUP BY status ORDER BY 2 DESC;

SELECT pg_size_pretty(pg_table_size('orders')) AS heap_size,
       pg_size_pretty(pg_indexes_size('orders')) AS indexes_size;


-- ---------------------------------------------------------------------------
-- DEMO 1 -- The baseline: one row out of three million
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 1: sequential scan vs index scan'

SELECT order_id, order_date, amount FROM orders WHERE customer_id = 142857;  -- warm up

\echo '--- BEFORE (no index) ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, amount FROM orders WHERE customer_id = 142857;

CREATE INDEX idx_orders_customer ON orders (customer_id);

\echo '--- AFTER ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, amount FROM orders WHERE customer_id = 142857;

-- Talking points: "Rows Removed by Filter: 2999980" is the cost of the missing
-- index. Seq Scan -> Bitmap Heap Scan + Bitmap Index Scan. Compare Buffers.


-- ---------------------------------------------------------------------------
-- DEMO 2 -- Index-only scan: never touch the table
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 2: covering index (INCLUDE) and Heap Fetches: 0'

\echo '--- BEFORE (index on customer_id only) ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, sum(amount) FROM orders
 WHERE customer_id BETWEEN 1000 AND 1100 GROUP BY customer_id;

CREATE INDEX idx_orders_cust_amount ON orders (customer_id) INCLUDE (amount);

\echo '--- AFTER (covering index) ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, sum(amount) FROM orders
 WHERE customer_id BETWEEN 1000 AND 1100 GROUP BY customer_id;

-- Talking points: Heap Blocks: exact=1493 -> Heap Fetches: 0.
-- Caveat worth saying out loud: index-only scans need a current visibility map,
-- so after a heavy write burst and before VACUUM the gain shrinks.


-- ---------------------------------------------------------------------------
-- DEMO 3 -- Composite indexes: the leading-column rule
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 3: (status, order_date) -- which queries can use it?'

CREATE INDEX idx_orders_status_date ON orders (status, order_date);

\echo '--- A: both columns -> a real seek ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, amount FROM orders
 WHERE status = 'cancelled' AND order_date = DATE '2024-03-15';

\echo '--- B: second column only -> index present but cannot seek ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, amount FROM orders WHERE order_date = DATE '2024-03-15';

CREATE INDEX idx_orders_date ON orders (order_date);

\echo '--- C: after an index that LEADS with order_date ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, amount FROM orders WHERE order_date = DATE '2024-03-15';

-- Talking points: in B PostgreSQL still used the index -- by reading ALL of it.
-- Compare the cost estimates (442 vs 41091) and the Buffers counts.
-- Phone book sorted by (surname, first name): a first name alone is no help.


-- ---------------------------------------------------------------------------
-- DEMO 4 -- Selectivity: when an index is the wrong answer
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 4: 0.15% of rows vs 85% of rows'

\echo '--- A: selective (about 4,500 rows) ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT sum(amount) FROM orders
 WHERE status = 'cancelled' AND order_date BETWEEN DATE '2024-01-01' AND DATE '2024-01-31';

\echo '--- B: unselective (85% of rows) -- index exists and is IGNORED ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT sum(amount) FROM orders WHERE status = 'shipped';

\echo '--- C: force the index and watch it lose ---'
SET enable_seqscan = off;
EXPLAIN (ANALYZE, BUFFERS)
SELECT sum(amount) FROM orders WHERE status = 'shipped';
RESET enable_seqscan;

-- Talking points: rule of thumb, an index pays off below roughly 5-10%
-- selectivity. enable_seqscan=off is a diagnosis tool, never a production
-- setting. Ask why count(*) would behave differently here.


-- ---------------------------------------------------------------------------
-- DEMO 5 -- ORDER BY ... LIMIT: indexes as pre-sorted data
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 5: top-N queries'

\echo '--- BEFORE ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, amount FROM orders ORDER BY amount DESC LIMIT 10;

CREATE INDEX idx_orders_amount ON orders (amount DESC);

\echo '--- AFTER ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, customer_id, amount FROM orders ORDER BY amount DESC LIMIT 10;

\echo '--- same trick inside a filter: latest 5 orders of one customer ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, amount FROM orders
 WHERE customer_id = 142857 ORDER BY order_date DESC LIMIT 5;

CREATE INDEX idx_orders_cust_date ON orders (customer_id, order_date DESC);

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id, order_date, amount FROM orders
 WHERE customer_id = 142857 ORDER BY order_date DESC LIMIT 5;

-- Talking points: "Sort Method: top-N heapsort" above a Seq Scan disappears.
-- Removing the Sort node IS the win, even when the millisecond gain is small.


-- ---------------------------------------------------------------------------
-- DEMO 6 -- Expression indexes and LIKE
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 6: functions, expressions and patterns'

\echo '--- A: exact match, no index ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name FROM customers WHERE email = 'user150000@mail.kz';

CREATE INDEX idx_customers_email ON customers (email);

\echo '--- A: after a plain b-tree ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name FROM customers WHERE email = 'user150000@mail.kz';

\echo '--- B: lower(email) -- the index is dead ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name FROM customers WHERE lower(email) = 'user150000@mail.kz';

CREATE INDEX idx_customers_email_lower ON customers (lower(email));

\echo '--- C: index the expression itself ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT customer_id, full_name FROM customers WHERE lower(email) = 'user150000@mail.kz';

\echo '--- D: prefix LIKE, before the right operator class ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM customers WHERE email LIKE 'user1500%';

CREATE INDEX idx_customers_email_pat ON customers (email text_pattern_ops);

\echo '--- D: prefix LIKE, after text_pattern_ops ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM customers WHERE email LIKE 'user1500%';

\echo '--- E: leading wildcard -- no b-tree can help ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM customers WHERE email LIKE '%150000@mail.kz';

-- Talking points: in D the planner rewrites LIKE 'user1500%' into the range
-- email >= 'user1500' AND email < 'user1501'. That is exactly why a prefix is
-- searchable and a suffix is not. For '%...' you need pg_trgm + GIN.


-- ---------------------------------------------------------------------------
-- DEMO 7 -- Partial indexes
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 7: index only the 5% of rows you query'

CREATE INDEX idx_orders_status_full ON orders (status);
CREATE INDEX idx_orders_cancelled   ON orders (order_date) WHERE status = 'cancelled';

SELECT indexrelname AS index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
FROM pg_stat_user_indexes
WHERE relname = 'orders'
  AND indexrelname IN ('idx_orders_status_full','idx_orders_cancelled','idx_orders_status_date');

EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM orders
 WHERE status = 'cancelled' AND order_date > DATE '2025-06-01';

-- Do this live: delete "status = 'cancelled'" from the query above and show
-- that the partial index is no longer considered at all.


-- ---------------------------------------------------------------------------
-- DEMO 8 -- The missing foreign-key index
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 8: a foreign key does NOT create an index on the child side'

DROP INDEX idx_orders_customer, idx_orders_cust_amount, idx_orders_cust_date;

\echo '--- BEFORE (nothing on orders.customer_id) ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.city, count(*), round(sum(o.amount),2)
  FROM customers c JOIN orders o ON o.customer_id = c.customer_id
 WHERE c.signup_date = DATE '2021-05-20'
 GROUP BY c.city;

CREATE INDEX idx_orders_customer ON orders (customer_id);

\echo '--- AFTER ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.city, count(*), round(sum(o.amount),2)
  FROM customers c JOIN orders o ON o.customer_id = c.customer_id
 WHERE c.signup_date = DATE '2021-05-20'
 GROUP BY c.city;

-- Talking points: Hash Join over 3,000,000 rows becomes a Nested Loop with
-- loops=100 on the inner Index Scan. This is where "loops" finally matters.


-- ---------------------------------------------------------------------------
-- DEMO 9 -- What indexes cost you
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 9: the bill -- write time and storage'

SELECT pg_size_pretty(pg_table_size('orders'))   AS table_size,
       pg_size_pretty(pg_indexes_size('orders')) AS indexes_size,
       (SELECT count(*) FROM pg_indexes WHERE tablename = 'orders') AS index_count;

CREATE TABLE orders_noidx (LIKE orders);
CREATE TABLE orders_idx   (LIKE orders INCLUDING INDEXES);

\timing on
INSERT INTO orders_noidx SELECT * FROM orders WHERE order_id <= 200000;
INSERT INTO orders_idx   SELECT * FROM orders WHERE order_id <= 200000;
\timing off

SELECT pg_size_pretty(pg_total_relation_size('orders_noidx')) AS no_index_total,
       pg_size_pretty(pg_total_relation_size('orders_idx'))   AS with_index_total;

-- Talking points: same rows, same table definition. The only difference is the
-- indexes. This is the honest answer to "why not index every column?"


-- ---------------------------------------------------------------------------
-- DEMO 10 -- Statistics decide, not indexes
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 10: a planner working from stale statistics'

INSERT INTO customers (customer_id, full_name, email, city, signup_date)
SELECT 200000 + g, 'Bulk ' || g, 'bulk' || g || '@mail.kz', 'Turkestan', DATE '2026-01-01'
FROM generate_series(1, 400000) g;

\echo '--- BEFORE ANALYZE: look at the rows= estimate ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM customers WHERE city = 'Turkestan';

ANALYZE customers;

\echo '--- AFTER ANALYZE ---'
EXPLAIN (ANALYZE, BUFFERS)
SELECT count(*) FROM customers WHERE city = 'Turkestan';

-- Talking points: estimated 1 row, actual 400,000. When a query that was fast
-- yesterday is slow today, find the LOWEST node where estimated and actual
-- diverge -- everything above it is built on a lie.


-- ---------------------------------------------------------------------------
-- DEMO 11 -- Auditing: which indexes earn their keep
-- ---------------------------------------------------------------------------
\echo ''
\echo '>>> DEMO 11: index usage audit'

SELECT indexrelname AS index_name,
       idx_scan     AS times_used,
       pg_size_pretty(pg_relation_size(indexrelid)) AS size
  FROM pg_stat_user_indexes
 WHERE relname = 'orders'
 ORDER BY idx_scan, 3 DESC;

-- Talking points: idx_orders_status_full has 0 scans and costs 20 MB. It is
-- redundant because (status, order_date) already covers everything (status)
-- could serve -- Demo 3 read backwards.
-- Before dropping any index: is it enforcing a constraint? Is it for a report
-- that runs once a quarter? Counters reset on pg_stat_reset().


-- ---------------------------------------------------------------------------
-- CLEANUP
-- ---------------------------------------------------------------------------
-- DROP TABLE orders_noidx, orders_idx, orders, customers;
-- DROP DATABASE indexdemo;   -- run from another database
