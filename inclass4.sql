-- Task 1: table cars
CREATE TABLE cars (
    car_id INTEGER PRIMARY KEY,
    plate_number TEXT NOT NULL UNIQUE,
    brand TEXT NOT NULL,
    year INTEGER CHECK (year BETWEEN 2010 AND 2026),
    daily_rate NUMERIC NOT NULL CHECK (daily_rate > 0)
);

-- Task 2: table clients
CREATE TABLE clients (
    client_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT CONSTRAINT unique_client_email UNIQUE,
    age INTEGER CHECK (age >= 21)
);

-- Task 3: table rentals
CREATE TABLE rentals (
    rental_id INTEGER PRIMARY KEY,
    car_id INTEGER NOT NULL REFERENCES cars(car_id) ON DELETE RESTRICT,
    client_id INTEGER REFERENCES clients(client_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    CONSTRAINT valid_period CHECK (end_date > start_date),
    CONSTRAINT unique_car_start UNIQUE (car_id, start_date)
);

-- Task 4: modify rentals
ALTER TABLE rentals ADD COLUMN status TEXT NOT NULL DEFAULT 'active';
ALTER TABLE rentals ADD CONSTRAINT valid_status CHECK (status IN ('active', 'returned', 'cancelled'));