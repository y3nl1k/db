--task 1
create table customers (
    customer_id integer primary key,
    full_name text not null,
    email text not null unique
);
--task 2
create table orders(
    order_id integer primary key ,
    customer_id integer references customers(customer_id) on delete  cascade ,
    order_date date not null,
    status text not null default 'pending', constraint valid_status check (status in ('pending', 'processing',
'shipped', 'delivered', 'cancelled'))
);
--task 3

create table order_items (
    item_id integer primary key,
    order_id integer references orders(order_id) on delete restrict,
    product text not null ,
    quantity integer not null default 0, check (quantity>=0)
);

-- Sample rows for In-Class Task: Online Shop, constraints (run after Task 3)
INSERT INTO customers (customer_id, full_name, email) VALUES
    (1, 'Aliya Nurova',  'aliya@mail.kz'),
    (2, 'Bauyrzhan Kim', 'baur@mail.kz'),
    (3, 'Dana Seitova',  'dana@mail.kz');

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
    (101, 1, '2026-10-01', 'shipped'),
    (102, 2, '2026-10-03', 'pending'),
    (103, 3, '2026-10-05', 'delivered');

INSERT INTO order_items (item_id, order_id, product, quantity) VALUES
    (1, 101, 'Keyboard', 2),
    (2, 101, 'Mouse',    1),
    (3, 103, 'Monitor',  1);

--task 4

INSERT INTO orders (order_id, customer_id, order_date,
status) VALUES (104, 2, '2026-10-06', NULL);
--status is required, cannot be null

INSERT INTO orders (order_id, customer_id, order_date,
status) VALUES (105, 3, '2026-10-07', 'Shipped');
--'shipped'!='Shipped' 'Shipped' is not in the set of valid status

INSERT INTO order_items (item_id, order_id, product) VALUES
(4, 102, 'Laptop');
--quantity is required, in the statement it is not given and null

DELETE FROM customers WHERE customer_id = 2;
--ok because of on delete cascade constraint

DELETE FROM customers WHERE customer_id = 1;
--violates the restrict of deletion

UPDATE customers SET customer_id = 30 WHERE customer_id = 3;
--already has the data where the customer id = 3

DROP TABLE orders CASCADE;
--ok, table was deleted because of the cascade constr in the statement even if the consrt was on delete restrict