--part 2
--ex.2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
--there are 2 ind on the table employees, employees_pkey and emp_salary_idx

--ex.2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;
--because indexes can significantly speed up join searches

--ex.2.3
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

/* assignments_pkey books_pkey cars_pkey
cars_plate_number_key
class_schedule_pkey
courses_pkey
customers_email_key
customers_pkey
departments_pkey
emp_dept_idx
emp_salary_idx
employees_pkey
grade_scale_pkey
groups_name_key
groups_pkey
loans_pkey
menu_items_pkey
phonebook_phone_number_key
phonebook_pkey
phones_pkey
professors_pkey
projects_pkey
semester_calendar_pkey
staff_pkey
student_records_pkey
students_pkey

   all the pkey check indexes were created automatically
   */
--part 3
--ex.3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
--it wont be efficient, it uses only salary column, index sorts by dept_id and it will have to check all of the dept_id to get the salary, which is not optimized

--ex.3.2.
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
--column order in a multicolumn index matters crucially.
--If an index is defined as (salary, dept_id), it will work efficiently if your query filters by salary first (or by both salary and dept_id).
-- It cannot be efficiently used if your query filters only by dept_id (skipping the leading column), because the index data isn't sorted by dept_id at the top level.

--part 4
--ex.4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
--emp_id=6 already exists, it violates the uniqueness restriction of the employees_pkey

--ex.4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
--employees_phone_key index was created. PostgreSQL automatically creates a unique B-tree index to enforce UNIQUE constraints and primary keys

--part 5
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;
--index (b-tree) is always sorted, it will help to reduce the time of order by query

--ex.5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT project_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

--part 6
--ex.6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

--Without this index, PostgreSQL would have to perform a Sequential Scan, reading every row in the employees table and applying the lower() to every emp_name value to check for a match

--ex.6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;-- Create index on the year extracted from hire_date
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

--part 7
--ex.7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

--ex.7.2
DROP INDEX emp_salary_dept_idx;
--we used on;y salary column, it is not optimized to use it separetely as we did

--ex.7.3
REINDEX INDEX employees_salary_index;

--part 8
--ex.8.1
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

--ex.8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT project_name, budget
FROM projects
WHERE budget > 80000;

--the advantage of a partial index is that it only indexes a subset of rows based on a condition, which significantly reduces disk space usage and lowers the maintenance overhead during data modifications

-- part 9
--ex.9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
--if the query is only to compare with the const value, not requiering a sorting or range

--ex.9.2
CREATE INDEX proj_name_btree_idx ON projects(project_name);

CREATE INDEX proj_name_hash_idx ON projects USING HASH (project_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

--part 10
--ex.10.1
SELECT
    schemaname,
    tablename,
    indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
--pkey indexes are the largest ones because pkey stores every row of the table

--ex.10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

--ex.10.3
CREATE VIEW index_documentation AS
SELECT
    tablename,
    indexname,
    indexdef,
'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;


/*q1 def index type is b-tree which covers almost every basic operations
  q2 1. columns frequently filtered by WHERE clause, 2.join searches, 3. Indexes can also benefit UPDATE and DELETE
commands with search conditions
  q3 1. when number of rows is low, 3. the system will update the index when the table is modified, if the table is frequently updated
  q4 they must be kept synchronized with the table data. An INSERT adds a new key-pointer entry; a DELETE removes the entry; an UPDATE removes the old entry and inserts a new one if the indexed column value changes, introducing write amplification and overhead.
  q5 By prefixing the query with EXPLAIN or EXPLAIN ANALYZE to inspect the execution plan for an Index Scan or Bitmap Index Scan rather than a Seq Scan
*/