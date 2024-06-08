-- temporary tables
CREATE TEMP TABLE temp_users (
    id INTEGER,
    username VARCHAR,
    email VARCHAR,
    password VARCHAR,
    role VARCHAR,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_washing_machines (
    id INTEGER,
    brand VARCHAR,
    model VARCHAR,
    price DECIMAL,
    energy_rating VARCHAR,
    capacity INTEGER,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_orders (
    id INTEGER,
    user_id INTEGER,
    total_amount DECIMAL,
    order_status VARCHAR,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_order_items (
    id INTEGER,
    order_id INTEGER,
    washing_machine_id INTEGER,
    quantity INTEGER,
    unit_price DECIMAL,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_reviews (
    id INTEGER,
    user_id INTEGER,
    washing_machine_id INTEGER,
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_addresses (
    id INTEGER,
    user_id INTEGER,
    address_line1 VARCHAR,
    address_line2 VARCHAR,
    city VARCHAR,
    state VARCHAR,
    postal_code VARCHAR,
    country VARCHAR,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_payment_methods (
    id INTEGER,
    user_id INTEGER,
    card_number VARCHAR,
    card_expiry_date DATE,
    card_cvc VARCHAR,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_categories (
    id INTEGER,
    name VARCHAR,
    description TEXT,
    created_at TIMESTAMP
);

CREATE TEMP TABLE temp_washing_machine_categories (
    washing_machine_id INTEGER,
    category_id INTEGER,
    created_at TIMESTAMP
);

-- load data into temporary tables
COPY temp_users(id, username, email, password, role, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\users.csv'
DELIMITER ','
CSV HEADER;

COPY temp_washing_machines(id, brand, model, price, energy_rating, capacity, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\washing_machines.csv'
DELIMITER ','
CSV HEADER;

COPY temp_orders(id, user_id, total_amount, order_status, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\orders.csv'
DELIMITER ','
CSV HEADER;

COPY temp_order_items(id, order_id, washing_machine_id, quantity, unit_price, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\order_items.csv'
DELIMITER ','
CSV HEADER;

COPY temp_reviews(id, user_id, washing_machine_id, rating, comment, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\reviews.csv'
DELIMITER ','
CSV HEADER;

COPY temp_addresses(id, user_id, address_line1, address_line2, city, state, postal_code, country, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\addresses.csv'
DELIMITER ','
CSV HEADER;

COPY temp_payment_methods(id, user_id, card_number, card_expiry_date, card_cvc, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\payment_methods.csv'
DELIMITER ','
CSV HEADER;

COPY temp_categories(id, name, description, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\categories.csv'
DELIMITER ','
CSV HEADER;

COPY temp_washing_machine_categories(washing_machine_id, category_id, created_at)
FROM 'D:\Subjects\2course\2 sem\DB\SQL\Data\washing_machine_categories.csv'
DELIMITER ','
CSV HEADER;

-- insert data into main tables
-- users
INSERT INTO users (id, username, email, password, role, created_at)
SELECT t.id, t.username, t.email, t.password, t.role, t.created_at
FROM temp_users t
LEFT JOIN users u ON t.id = u.id
WHERE u.id IS NULL;

-- washing machines
INSERT INTO washing_machines (id, brand, model, price, energy_rating, capacity, created_at)
SELECT t.id, t.brand, t.model, t.price, t.energy_rating, t.capacity, t.created_at
FROM temp_washing_machines t
LEFT JOIN washing_machines w ON t.id = w.id
WHERE w.id IS NULL;

-- orders
INSERT INTO orders (id, user_id, total_amount, order_status, created_at)
SELECT t.id, t.user_id, t.total_amount, t.order_status, t.created_at
FROM temp_orders t
LEFT JOIN orders o ON t.id = o.id
WHERE o.id IS NULL;

-- order items
INSERT INTO order_items (id, order_id, washing_machine_id, quantity, unit_price, created_at)
SELECT t.id, t.order_id, t.washing_machine_id, t.quantity, t.unit_price, t.created_at
FROM temp_order_items t
LEFT JOIN order_items oi ON t.id = oi.id
WHERE oi.id IS NULL;

-- reviews
INSERT INTO reviews (id, user_id, washing_machine_id, rating, comment, created_at)
SELECT t.id, t.user_id, t.washing_machine_id, t.rating, t.comment, t.created_at
FROM temp_reviews t
LEFT JOIN reviews r ON t.id = r.id
WHERE r.id IS NULL;

-- addresses
INSERT INTO addresses (id, user_id, address_line1, address_line2, city, state, postal_code, country, created_at)
SELECT t.id, t.user_id, t.address_line1, t.address_line2, t.city, t.state, t.postal_code, t.country, t.created_at
FROM temp_addresses t
LEFT JOIN addresses a ON t.id = a.id
WHERE a.id IS NULL;

-- payment methods
INSERT INTO payment_methods (id, user_id, card_number, card_expiry_date, card_cvc, created_at)
SELECT t.id, t.user_id, t.card_number, t.card_expiry_date, t.card_cvc, t.created_at
FROM temp_payment_methods t
LEFT JOIN payment_methods pm ON t.id = pm.id
WHERE pm.id IS NULL;

-- categories
INSERT INTO categories (id, name, description, created_at)
SELECT t.id, t.name, t.description, t.created_at
FROM temp_categories t
LEFT JOIN categories c ON t.id = c.id
WHERE c.id IS NULL;

-- washing machine categories
INSERT INTO washing_machine_categories (washing_machine_id, category_id, created_at)
SELECT t.washing_machine_id, t.category_id, t.created_at
FROM temp_washing_machine_categories t
LEFT JOIN washing_machine_categories wmc ON t.washing_machine_id = wmc.washing_machine_id AND t.category_id = wmc.category_id
WHERE wmc.washing_machine_id IS NULL AND wmc.category_id IS NULL;

-- update serial sequences
SELECT setval(pg_get_serial_sequence('users', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM users;
SELECT setval(pg_get_serial_sequence('washing_machines', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM washing_machines;
SELECT setval(pg_get_serial_sequence('orders', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM orders;
SELECT setval(pg_get_serial_sequence('order_items', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM order_items;
SELECT setval(pg_get_serial_sequence('reviews', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM reviews;
SELECT setval(pg_get_serial_sequence('addresses', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM addresses;
SELECT setval(pg_get_serial_sequence('payment_methods', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM payment_methods;
SELECT setval(pg_get_serial_sequence('categories', 'id'), COALESCE(MAX(id), 1) + 1, FALSE) FROM categories;

-- drop temporary tables
DROP TABLE temp_users;
DROP TABLE temp_washing_machines;
DROP TABLE temp_orders;
DROP TABLE temp_order_items;
DROP TABLE temp_reviews;
DROP TABLE temp_addresses;
DROP TABLE temp_payment_methods;
DROP TABLE temp_categories;
DROP TABLE temp_washing_machine_categories;
