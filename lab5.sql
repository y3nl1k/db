-- Task 1.1
CREATE TABLE employees ( --basic check
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

-- Task 1.2
CREATE TABLE products_catalog ( --named check
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0 AND
        discount_price > 0 AND
        discount_price < regular_price
    )
);

-- Task 1.3
CREATE TABLE bookings ( --multiple col check
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT check_dates CHECK (check_out_date > check_in_date)
);

-- Task 1.4: Testing CHECK Constraints

-- 1. employees
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (1, 'John', 'Doe', 30, 5000);

INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (2, 'Jane', 'Smith', 45, 7500);

-- Violates age (must be 18-65)
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (3, 'Bob', 'Brown', 17, 3000);

-- Violates salary (must be > 0)
INSERT INTO employees (employee_id, first_name, last_name, age, salary)
VALUES (4, 'Alice', 'White', 25, 0);


-- 2. products_catalog
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (1, 'Laptop', 1000, 800);

INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (2, 'Phone', 500, 450);

-- Violates valid_discount (discount_price < regular_price)
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (3, 'Tablet', 300, 350);

-- Violates valid_discount (regular_price > 0)
INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price)
VALUES (4, 'Monitor', 0, 100);


-- 3. bookings
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (1, '2026-06-01', '2026-06-07', 2);

INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (2, '2026-07-10', '2026-07-15', 5);

-- Violates num_guests (must be 1-10)
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (3, '2026-08-01', '2026-08-05', 12);

-- Violates check_dates (check_out_date > check_in_date)
INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests)
VALUES (4, '2026-09-10', '2026-09-05', 2);


-- Task 2.1
CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

-- Task 2.2
CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);


-- Task 2.3: Testing NOT NULL

-- Insert complete records successfully
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (1, 'john@example.com', '+123456789', '2026-01-10');

INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (2, 'jane@example.com', NULL, '2026-02-15');

-- Insert record with NULL in a nullable column (phone can be NULL)
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (3, 'bob@example.com', NULL, '2026-03-01');

-- Violates customer_id (NOT NULL)
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (NULL, 'test1@example.com', '+987654321', '2026-03-05');

-- Violates email (NOT NULL)
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (4, NULL, '+987654321', '2026-03-05');

-- Violates registration_date (NOT NULL)
INSERT INTO customers (customer_id, email, phone, registration_date)
VALUES (5, 'test2@example.com', '+987654321', NULL);


-- Also for inventory table (Task 2.2):
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (1, 'Laptop', 10, 999.99, CURRENT_TIMESTAMP);

-- Violates item_name (NOT NULL)
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (2, NULL, 5, 49.99, CURRENT_TIMESTAMP);

-- Violates quantity (NOT NULL)
INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated)
VALUES (3, 'Mouse', NULL, 19.99, CURRENT_TIMESTAMP);

-- Part 3: UNIQUE Constraints

-- Task 3.1: Single Column UNIQUE
CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);


-- Task 3.2: Multi-Column UNIQUE
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);


-- Task 3.3: Named UNIQUE Constraints
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INTEGER,
    username TEXT,
    email TEXT,
    created_at TIMESTAMP,
    CONSTRAINT unique_username UNIQUE (username),
    CONSTRAINT unique_email UNIQUE (email)
);

-- Successful insert
INSERT INTO users (user_id, username, email, created_at)
VALUES (1, 'alice', 'alice@mail.com', CURRENT_TIMESTAMP);

-- Violates unique_username
INSERT INTO users (user_id, username, email, created_at)
VALUES (2, 'alice', 'other@mail.com', CURRENT_TIMESTAMP);

-- Violates unique_email
INSERT INTO users (user_id, username, email, created_at)
VALUES (3, 'bob', 'alice@mail.com', CURRENT_TIMESTAMP);



-- Task 4.1
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

-- Task 4.2
CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- Task 4.3: Comparison Exercise Documentation

/*
1. Difference between UNIQUE and PRIMARY KEY:
   - PRIMARY KEY uniquely identifies each row, cannot be NULL, and a table can have only one PRIMARY KEY.
   - UNIQUE ensures all values in a column are distinct, but it allows one NULL value (depending on the SQL dialect), and a table can have multiple UNIQUE constraints.

2. When to use a single-column vs. composite PRIMARY KEY:
   - Use a single-column PRIMARY KEY when a single attribute (like id or uuid) uniquely identifies a row.
   - Use a composite PRIMARY KEY when uniqueness requires a combination of two or more columns (e.g., student_id + course_id in a junction table).

3. Why a table can have only one PRIMARY KEY but multiple UNIQUE constraints:
   - A PRIMARY KEY represents the main identity (the primary logical clustering/row identifier) of a table.
     You can have many alternative unique keys (like email, phone, username), but there can only be one primary identity per table.
*/

-- Task 5.1
CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

-- Successful insert (valid dept_id)
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (1, 'Alice Smith', 1, '2026-01-15');

-- Violates foreign key (non-existent dept_id)
INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date)
VALUES (2, 'Bob Jones', 99, '2026-02-20');

-- Task 5.2
CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors (author_id, author_name, country) VALUES (1, 'J.K. Rowling', 'UK');
INSERT INTO authors (author_id, author_name, country) VALUES (2, 'George Orwell', 'UK');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES (1, 'Bloomsbury', 'London');
INSERT INTO publishers (publisher_id, publisher_name, city) VALUES (2, 'Secker & Warburg', 'London');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES (1, 'Harry Potter', 1, 1, 1997, '978-0747532743');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn)
VALUES (2, '1984', 2, 2, 1949, '978-0451524935');

-- Task 5.3
CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories (category_id, category_name) VALUES (1, 'Electronics');
INSERT INTO products_fk (product_id, product_name, category_id) VALUES (101, 'Smartphone', 1);

-- 1. Violates RESTRICT (tries to delete category that has linked products)
DELETE FROM categories WHERE category_id = 1;

INSERT INTO orders (order_id, order_date) VALUES (500, '2026-10-01');
INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES (1001, 500, 101, 2);

-- 2. Tests CASCADE (deleting order automatically deletes its order_items)
DELETE FROM orders WHERE order_id = 500;


-- Task 6.1
CREATE TABLE ecommerce_customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecommerce_products (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecommerce_orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER REFERENCES ecommerce_customers(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE ecommerce_order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES ecommerce_orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES ecommerce_products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (1, 'Alice Johnson', 'alice@example.com', '+111222333', '2026-01-10');

INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (2, 'Bob Smith', 'bob@example.com', '+444555666', '2026-02-15');

INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (3, 'Charlie Brown', 'charlie@example.com', NULL, '2026-03-01');

INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (4, 'Diana Prince', 'diana@example.com', '+777888999', '2026-03-10');

INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (5, 'Ethan Hunt', 'ethan@example.com', '+000111222', '2026-03-12');

-- Violates email UNIQUE constraint
INSERT INTO ecommerce_customers (customer_id, name, email, phone, registration_date)
VALUES (6, 'Fake Alice', 'alice@example.com', '+123456789', '2026-03-15');

INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (101, 'Laptop', 'High performance laptop', 1200.00, 15);

INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (102, 'Wireless Mouse', 'Ergonomic mouse', 25.50, 100);

INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (103, 'Mechanical Keyboard', 'RGB gaming keyboard', 75.00, 50);

INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (104, 'Monitor', '27-inch 4K monitor', 300.00, 20);

INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (105, 'USB-C Hub', 'Multiport adapter', 40.00, 75);

-- Violates price CHECK (price >= 0)
INSERT INTO ecommerce_products (product_id, name, description, price, stock_quantity)
VALUES (106, 'Broken Item', 'Invalid price', -10.00, 10);


-- 3. Insert records into ecommerce_orders
INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1001, 1, '2026-04-01', 1225.50, 'delivered');

INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1002, 2, '2026-04-02', 300.00, 'shipped');

INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1003, 3, '2026-04-03', 75.00, 'processing');

INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1004, 4, '2026-04-04', 40.00, 'pending');

INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1005, 5, '2026-04-05', 375.00, 'cancelled');

-- Violates status CHECK (status must be valid)
INSERT INTO ecommerce_orders (order_id, customer_id, order_date, total_amount, status)
VALUES (1006, 1, '2026-04-06', 50.00, 'unknown_status');


-- 4. Insert records into ecommerce_order_details
INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5001, 1001, 101, 1, 1200.00);

INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5002, 1001, 102, 1, 25.50);

INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5003, 1002, 104, 1, 300.00);

INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5004, 1003, 103, 1, 75.00);

INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5005, 1004, 105, 1, 40.00);

-- Violates quantity CHECK (quantity > 0)
INSERT INTO ecommerce_order_details (order_detail_id, order_id, product_id, quantity, unit_price)
VALUES (5006, 1005, 102, 0, 25.50);