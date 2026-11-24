
-- 1. ROLES
CREATE TABLE ROLES (
    role_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

-- 2. USERS
CREATE TABLE USERS (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_id INTEGER NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active INTEGER DEFAULT 1
        CHECK (is_active IN (0, 1)),
    FOREIGN KEY (role_id) REFERENCES ROLES(role_id)
);

-- 3. CUSTOMERS
CREATE TABLE CUSTOMERS (
    customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(50),
    postal_code VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES USERS(user_id)
);

-- 4. RESTAURANTS
CREATE TABLE RESTAURANTS (
    restaurant_id INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    description TEXT,
    address TEXT NOT NULL,
    city VARCHAR(50),
    phone VARCHAR(20),
    email VARCHAR(100),
    opening_time TIME,
    closing_time TIME,
    is_active INTEGER DEFAULT 1
        CHECK (is_active IN (0, 1))
);

-- 5. MENU_ITEMS
CREATE TABLE MENU_ITEMS (
    item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    restaurant_id INTEGER NOT NULL,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL
        CHECK (price >= 0),
    category VARCHAR(50),
    is_available INTEGER DEFAULT 1
        CHECK (is_available IN (0, 1)),
    FOREIGN KEY (restaurant_id)
        REFERENCES RESTAURANTS(restaurant_id)
);

-- 6. ORDERS
CREATE TABLE ORDERS (
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    order_status VARCHAR(30) DEFAULT 'Pending'
        CHECK (order_status IN (
            'Pending',
            'Confirmed',
            'Preparing',
            'Out for Delivery',
            'Delivered',
            'Cancelled'
        )),
    delivery_address TEXT NOT NULL,
    notes TEXT,
    FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (restaurant_id)
        REFERENCES RESTAURANTS(restaurant_id)
);

-- 7. ORDER_ITEMS
CREATE TABLE ORDER_ITEMS (
    order_item_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    item_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL
        CHECK (unit_price >= 0),
    FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id),
    FOREIGN KEY (item_id)
        REFERENCES MENU_ITEMS(item_id)
);

-- 8. PAYMENTS
CREATE TABLE PAYMENTS (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL UNIQUE,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL
        CHECK (amount >= 0),
    payment_method VARCHAR(30) NOT NULL
        CHECK (payment_method IN (
            'Cash',
            'Credit Card',
            'Debit Card'
        )),
    payment_status VARCHAR(30) DEFAULT 'Pending'
        CHECK (payment_status IN (
            'Pending',
            'Paid',
            'Failed',
            'Refunded'
        )),
    FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id)
);

-- 9. DELIVERIES
CREATE TABLE DELIVERIES (
    delivery_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL UNIQUE,
    driver_id INTEGER,
    delivery_date DATETIME,
    delivery_status VARCHAR(30) DEFAULT 'Pending'
        CHECK (delivery_status IN (
            'Pending',
            'Assigned',
            'Picked Up',
            'Delivered',
            'Failed'
        )),
    delivery_fee DECIMAL(10,2) DEFAULT 0
        CHECK (delivery_fee >= 0),
    FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id),
    FOREIGN KEY (driver_id)
        REFERENCES USERS(user_id)
);

-- 10. ORDER_STATUS_HISTORY
CREATE TABLE ORDER_STATUS_HISTORY (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    changed_by INTEGER,
    old_status VARCHAR(30),
    new_status VARCHAR(30) NOT NULL,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id),
    FOREIGN KEY (changed_by)
        REFERENCES USERS(user_id)
);

-- 11. REVIEWS
CREATE TABLE REVIEWS (
    review_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    rating INTEGER NOT NULL
        CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id)
        REFERENCES CUSTOMERS(customer_id),
    FOREIGN KEY (restaurant_id)
        REFERENCES RESTAURANTS(restaurant_id),
    FOREIGN KEY (order_id)
        REFERENCES ORDERS(order_id),
    UNIQUE (customer_id, order_id)
);

-- VERIFY ALL TABLES
SELECT name
FROM sqlite_master
WHERE type = 'table'
AND name NOT LIKE 'sqlite_%'
ORDER BY name;
