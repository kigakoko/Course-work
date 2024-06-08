-- dim tables
CREATE TABLE dim_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255),
    email VARCHAR(255),
    role VARCHAR(10),
    created_at TIMESTAMP
);

CREATE TABLE dim_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP
);

CREATE TABLE dim_washing_machines (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(255),
    model VARCHAR(255),
    price DECIMAL(10, 2),
    energy_rating VARCHAR(10),
    capacity INTEGER,
    created_at TIMESTAMP
);

CREATE TABLE dim_washing_machine_categories (
    washing_machine_id INTEGER UNIQUE REFERENCES dim_washing_machines(id),
    category_id INTEGER REFERENCES dim_categories(id),
    created_at TIMESTAMP,
    PRIMARY KEY (washing_machine_id, category_id)
);

CREATE TABLE dim_addresses (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES dim_users(id)
);

-- fact tables
CREATE TABLE fact_reviews (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    washing_machine_id INTEGER,
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES dim_users(id),
    FOREIGN KEY (washing_machine_id) REFERENCES dim_washing_machines(id)
);

CREATE TABLE fact_orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    order_id INTEGER UNIQUE,
    washing_machine_id INTEGER,
    total_amount DECIMAL(10, 2),
    quantity INTEGER,
    unit_price DECIMAL(10, 2),
    created_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES dim_users(id),
    FOREIGN KEY (washing_machine_id) REFERENCES dim_washing_machines(id)
);

-- indexes
CREATE INDEX idx_dim_washing_machine_categories ON dim_washing_machine_categories(washing_machine_id);
CREATE INDEX idx_dim_categories ON dim_categories(id);
CREATE INDEX idx_fact_orders_user_id ON fact_orders(user_id);
CREATE INDEX idx_fact_orders_order_id ON fact_orders(order_id);
CREATE INDEX idx_fact_orders_washing_machine_id ON fact_orders(washing_machine_id);
CREATE INDEX idx_dim_users_id ON dim_users(id);
CREATE INDEX idx_dim_washing_machines_id ON dim_washing_machines(id);
CREATE INDEX idx_fact_reviews_user_id ON fact_reviews(user_id);
CREATE INDEX idx_fact_reviews_washing_machine_id ON fact_reviews(washing_machine_id);
CREATE INDEX idx_dim_addresses_user_id ON dim_addresses(user_id);

-- grant privileges!
GRANT CONNECT ON DATABASE "DWH_database" TO user_role;
GRANT USAGE ON SCHEMA public TO user_role;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO user_role;
GRANT CONNECT ON DATABASE "DWH_database" TO admin_role;
GRANT USAGE ON SCHEMA public TO admin_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin_role;
GRANT USAGE, SELECT ON SEQUENCE fact_orders_id_seq TO admin_user;
