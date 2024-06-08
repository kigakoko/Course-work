-- tables
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(10) CHECK (role IN ('user', 'admin')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE washing_machines (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(255) NOT NULL,
    model VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    energy_rating VARCHAR(10),
    capacity INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    washing_machine_id INTEGER REFERENCES washing_machines(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    washing_machine_id INTEGER REFERENCES washing_machines(id),
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    address_line1 VARCHAR(255) NOT NULL,
    address_line2 VARCHAR(255),
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE payment_methods (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    card_number VARCHAR(20) NOT NULL,
    card_expiry_date DATE NOT NULL,
    card_cvc VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE washing_machine_categories (
    washing_machine_id INTEGER REFERENCES washing_machines(id),
    category_id INTEGER REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (washing_machine_id, category_id)
);

-- indexes
CREATE INDEX idx_user_id ON orders(user_id);
CREATE INDEX idx_order_id ON order_items(order_id);
CREATE INDEX idx_washing_machine_id ON order_items(washing_machine_id);
CREATE INDEX idx_user_id_reviews ON reviews(user_id);
CREATE INDEX idx_washing_machine_id_reviews ON reviews(washing_machine_id);
CREATE INDEX idx_user_id_addresses ON addresses(user_id);
CREATE INDEX idx_user_id_payment_methods ON payment_methods(user_id);
CREATE INDEX idx_washing_machine_id_categories ON washing_machine_categories(washing_machine_id);
CREATE INDEX idx_category_id_categories ON washing_machine_categories(category_id);

-- functions
CREATE OR REPLACE FUNCTION add_user(
    p_username VARCHAR,
    p_email VARCHAR,
    p_password VARCHAR,
    p_role VARCHAR
) RETURNS VOID AS $$
BEGIN
    INSERT INTO users (username, email, password, role) 
    VALUES (p_username, p_email, p_password, p_role);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION place_order(
    p_user_id INTEGER,
    p_total_amount DECIMAL,
    p_order_status VARCHAR,
    p_items JSON
) RETURNS VOID AS $$
DECLARE
    v_order_id INTEGER;
    v_item JSON;
BEGIN
    INSERT INTO orders (user_id, total_amount, order_status) 
    VALUES (p_user_id, p_total_amount, p_order_status)
    RETURNING id INTO v_order_id;

    FOR v_item IN SELECT * FROM json_array_elements(p_items) LOOP
        INSERT INTO order_items (order_id, washing_machine_id, quantity, unit_price)
        VALUES (v_order_id, (v_item->>'washing_machine_id')::INTEGER, (v_item->>'quantity')::INTEGER, (v_item->>'unit_price')::DECIMAL);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_category(
    p_name VARCHAR,
    p_description TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO categories (name, description) 
    VALUES (p_name, p_description);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_washing_machine(
    p_brand VARCHAR,
    p_model VARCHAR,
    p_price DECIMAL,
    p_energy_rating VARCHAR,
    p_capacity INTEGER
) RETURNS VOID AS $$
BEGIN
    INSERT INTO washing_machines (brand, model, price, energy_rating, capacity) 
    VALUES (p_brand, p_model, p_price, p_energy_rating, p_capacity);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_order_status(
    p_order_id INTEGER,
    p_order_status VARCHAR
) RETURNS VOID AS $$
BEGIN
    UPDATE orders 
    SET order_status = p_order_status 
    WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql;


-- roles! and privileges!
CREATE ROLE user_role;
GRANT CONNECT ON DATABASE "OLTP_database" TO user_role;
GRANT USAGE ON SCHEMA public TO user_role;
GRANT SELECT, INSERT, UPDATE ON users, washing_machines, orders, order_items, reviews, addresses, payment_methods TO user_role;
GRANT SELECT ON categories, washing_machine_categories TO user_role;

CREATE ROLE admin_role;
GRANT CONNECT ON DATABASE "OLTP_database" TO admin_role;
GRANT USAGE ON SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;

--------------------------------------------------------------------------------------------------
CREATE USER normal_user WITH PASSWORD 'userpassword';
GRANT user_role TO normal_user;

CREATE USER admin_user WITH PASSWORD 'adminpassword';
GRANT admin_role TO admin_user;
--------------------------------------------------------------------------------------------------

DROP TABLE temp_users;
DROP TABLE temp_washing_machines;
