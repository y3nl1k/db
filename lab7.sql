--part 1
CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);
CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);

INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id,
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

--part 2
--ex.2.1
create view employee_details as
    select e.emp_name, e.salary, d.dept_name, d.location
from employees e
join departments d on e.dept_id=d.dept_id;

select * from employee_details;
--4 rows appeared he has dept_id null, inner join skipped this val, null is equal to nothing

--ex.2.2
create view dept_statistics as
SELECT d.dept_name,
       COUNT(e.emp_id)              AS employee_count,
       ROUND(AVG(e.salary), 2)      AS avg_salary,
       MAX(e.salary)                AS max_salary,
       MIN(e.salary)                AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

--ex.2.3
CREATE VIEW project_overview AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       d.location,
       (SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id;

SELECT * FROM project_overview;

--ex.2.4
CREATE VIEW high_earners AS
SELECT e.emp_name,
       e.salary,
       d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;
--it returns only employees with salary>55000 and existing department, not all

--part 3
--ex.3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name,
       e.salary,
       d.dept_name,
       d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
       END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;

--ex.3.2
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

--ex.3.3
CREATE VIEW temp_view AS
SELECT emp_name, salary
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;

--part 4
--ex.4.1
CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;

--ex.4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
--view does not store data, thats why e underlying table got updated

--ex.4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees WHERE emp_id = 6;
--it was inserted successfully

--ex.4.4
CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000)

--"новая строка нарушает ограничение-проверку для представления it_employees"
--check option requires the condition dept_id=101 to be true, bob willson has dept_id 103

--part 5
--ex.5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COALESCE(e.total_employees, 0) AS total_employees,
       COALESCE(e.total_salaries, 0)  AS total_salaries,
       COALESCE(p.total_projects, 0)  AS total_projects,
       COALESCE(p.total_budget, 0)    AS total_budget
FROM departments d
LEFT JOIN (SELECT dept_id,
                  COUNT(*)    AS total_employees,
                  SUM(salary) AS total_salaries
           FROM employees
           GROUP BY dept_id) e ON e.dept_id = d.dept_id
LEFT JOIN (SELECT dept_id,
                  COUNT(*)    AS total_projects,
                  SUM(budget) AS total_budget
           FROM projects
           GROUP BY dept_id) p ON p.dept_id = d.dept_id
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

--ex.5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

REFRESH MATERIALIZED VIEW dept_summary_mv;
--before refresh tot empl of it was 2, after its 3 because charlie is inserted

--ex.5.3
CREATE UNIQUE INDEX idx_dept_summary_mv_dept_id ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
--without concurrent, all views are blocked while refreshing, with it we can run queries while refreshing

--ex.5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       (SELECT COUNT(*)
        FROM employees e
        WHERE e.dept_id = p.dept_id) AS assigned_employees
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WITH NO DATA;

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

--part 6
--ex.6.1
CREATE ROLE analyst NOLOGIN;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user PASSWORD 'report456';

SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

--ex.6.2
CREATE ROLE db_creator   LOGIN CREATEDB   PASSWORD 'creator789';
CREATE ROLE user_manager LOGIN CREATEROLE PASSWORD 'manager101';
CREATE ROLE admin_user   LOGIN SUPERUSER  PASSWORD 'admin999';

--ex.6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

--ex.6.4
--1
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

--2
CREATE USER hr_user1      PASSWORD 'hr001';
CREATE USER hr_user2      PASSWORD 'hr002';
CREATE USER finance_user1 PASSWORD 'fin001';

--3
GRANT hr_team      TO hr_user1;
GRANT hr_team      TO hr_user2;

--4
GRANT finance_team TO finance_user1;

--5
GRANT SELECT, UPDATE ON employees TO hr_team;

--6
GRANT SELECT ON dept_statistics TO finance_team;

--ex.6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

--ex.6.6
ALTER ROLE analyst LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manager SUPERUSER;
ALTER ROLE analyst PASSWORD NULL;
ALTER ROLE data_viewer CONNECTION LIMIT 5;

--part 7
--ex.7.1
--1
CREATE ROLE read_only;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

--2
CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

--3
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

--4
GRANT INSERT, UPDATE ON employees TO senior_analyst;

--ex.7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

--ex.7.3
CREATE ROLE temp_owner LOGIN;

CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;

--ex.7.4
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

--part 8
--ex.8.1
CREATE VIEW dept_dashboard AS
SELECT d.dept_name,
       d.location,
       COALESCE(e.emp_count, 0)                     AS employee_count,
       COALESCE(ROUND(e.avg_salary::numeric, 2), 0) AS avg_salary,
       COALESCE(p.project_count, 0)                 AS active_projects,
       COALESCE(p.total_budget, 0)                  AS total_project_budget,
       CASE
           WHEN COALESCE(e.emp_count, 0) = 0 THEN 0
           ELSE ROUND(COALESCE(p.total_budget, 0)::numeric / e.emp_count, 2)
       END                                          AS budget_per_employee
FROM departments d
LEFT JOIN (SELECT dept_id,
                  COUNT(*)    AS emp_count,
                  AVG(salary) AS avg_salary
           FROM employees
           GROUP BY dept_id) e ON e.dept_id = d.dept_id
LEFT JOIN (SELECT dept_id,
                  COUNT(*)    AS project_count,
                  SUM(budget) AS total_budget
           FROM projects
           GROUP BY dept_id) p ON p.dept_id = d.dept_id;

SELECT * FROM dept_dashboard;

--ex.8.2
--1
ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

--2-4
CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
       END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;

--ex.8.3
--lvl1
CREATE ROLE viewer_role;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;   -- таблицы и views

--lvl2
CREATE ROLE entry_role;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

--lvl3
CREATE ROLE analyst_role;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

--lvl4
CREATE ROLE manager_role;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;


CREATE USER alice   PASSWORD 'alice123';
CREATE USER bob     PASSWORD 'bob123';
CREATE USER charlie PASSWORD 'charlie123';

GRANT viewer_role  TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
