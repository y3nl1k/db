-- part A
CREATE DATABASE "advanced_Lab";

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER DEFAULT 40000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50),
    budget INTEGER,
    manager_id INTEGER
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER
);

--part B
INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (3, 'John', 'Doe', 'IT');

INSERT INTO employees (emp_id, first_name, last_name, department, salary, hire_date, status)
VALUES (2, 'Jane', 'Doe ', 'HR', DEFAULT, '2022-03-15', DEFAULT);


INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, 1),
    ('HR', 80000, 2),
    ('Sales', 120000, 3);


INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Alex', 'Brown', 'IT', 50000 * 1.1, CURRENT_DATE, 'Active');

--create a table that has the structure of the query but does not copy data because of where condition
CREATE TABLE temp_employees AS
SELECT * FROM employees WHERE 1=0;
INSERT INTO temp_employees
SELECT * FROM employees
WHERE department = 'IT';

--part C
UPDATE employees
SET salary = salary * 1.10;

--insert employee with salary greater than 60000 and hire date before 2020
--and salary greater than 80000
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('Michael', 'Scott', 'Sales', 65000, '2019-05-' ||
                                     '10', 'Active');
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('Dwight', 'Schrute', 'Sales', 85000, '2021-01-15', 'Active');

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';


UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
    ELSE 'Junior'
END;


UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


UPDATE departments d
SET budget = (
    SELECT COALESCE(AVG(e.salary) * 1.20, d.budget)
    FROM employees e
    WHERE e.department = d.dept_name
);


UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

--part D
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES
('Kevin', 'Malone', NULL, 30000, '2023-05-01', 'Terminated');

INSERT INTO projects (project_name, dept_id, start_date, end_date, budget) VALUES
('Legacy Migration', 1, '2021-01-01', '2022-12-31', 40000),
('Cloud Portal', 2, '2024-01-01', '2025-12-31', 80000);

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);


DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

--part E
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Ryan', 'Howard', NULL, NULL, '2023-02-01', 'Active');

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

--part F
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Stanley', 'Hudson', 'Sales', 52000, '2017-04-12', 'Active')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, (salary - 5000) AS old_salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;

--part G
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT 'Kelly', 'Kapoor', 'Customer Service', 45000, CURRENT_DATE, 'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM employees WHERE first_name = 'Kelly' AND last_name = 'Kapoor'
);

UPDATE employees e
SET salary = CASE
    WHEN (SELECT budget FROM departments d WHERE d.dept_name = e.department) > 100000
        THEN salary * 1.10
    ELSE salary * 1.05
END
WHERE EXISTS (
    SELECT 1 FROM departments d WHERE d.dept_name = e.department
);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Emp1', 'Test', 'IT', 40000, CURRENT_DATE, 'Active'),
    ('Emp2', 'Test', 'IT', 42000, CURRENT_DATE, 'Active'),
    ('Emp3', 'Test', 'HR', 38000, CURRENT_DATE, 'Active'),
    ('Emp4', 'Test', 'HR', 39000, CURRENT_DATE, 'Active'),
    ('Emp5', 'Test', 'Sales', 45000, CURRENT_DATE, 'Active');

UPDATE employees
SET salary = salary * 1.10
WHERE last_name = 'Test';

CREATE TABLE employee_archive (LIKE employees INCLUDING ALL);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Old', 'Staff', 'Junior', 30000, '2015-01-01', 'Inactive');

WITH moved_rows AS (
    DELETE FROM employees
    WHERE status = 'Inactive'
    RETURNING *
)
INSERT INTO employee_archive
SELECT * FROM moved_rows;

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      JOIN departments d ON e.department = d.dept_name
      WHERE d.dept_id = p.dept_id
  ) > 3;