
PRAGMA foreign_keys = ON;

-- first 1: SELECT QUERIES

-- QUERY 1: Complete Order Details

SELECT
    o.order_id,
    c.full_name AS customer_name,
    r.restaurant_name,
    mi.item_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS item_total,
    o.order_status,
    o.order_date
FROM ORDERS o
JOIN CUSTOMERS c
    ON o.customer_id = c.customer_id
JOIN RESTAURANTS r
    ON o.restaurant_id = r.restaurant_id
JOIN ORDER_ITEMS oi
    ON o.order_id = oi.order_id
JOIN MENU_ITEMS mi
    ON oi.item_id = mi.item_id
ORDER BY o.order_date DESC;


-- QUERY 2: Restaurant Sales Statistics

SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    AVG(oi.unit_price) AS average_item_price
FROM RESTAURANTS r
JOIN ORDERS o
    ON r.restaurant_id = o.restaurant_id
JOIN ORDER_ITEMS oi
    ON o.order_id = oi.order_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY total_sales DESC;


-- QUERY 3: Best Selling Menu Items

SELECT
    mi.item_id,
    mi.item_name,
    r.restaurant_name,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM MENU_ITEMS mi
JOIN ORDER_ITEMS oi
    ON mi.item_id = oi.item_id
JOIN ORDERS o
    ON oi.order_id = o.order_id
JOIN RESTAURANTS r
    ON mi.restaurant_id = r.restaurant_id
GROUP BY mi.item_id, mi.item_name, r.restaurant_name
HAVING SUM(oi.quantity) >= 5
ORDER BY total_quantity_sold DESC;


-- QUERY 4: Customer Spending Analysis

SELECT
    c.customer_id,
    c.full_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity * oi.unit_price) AS total_spent
FROM CUSTOMERS c
JOIN ORDERS o
    ON c.customer_id = o.customer_id
JOIN ORDER_ITEMS oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.full_name
HAVING SUM(oi.quantity * oi.unit_price) >= 100
ORDER BY total_spent DESC;


-- QUERY 5: Restaurant Ratings

SELECT
    r.restaurant_id,
    r.restaurant_name,
    COUNT(rv.review_id) AS total_reviews,
    AVG(rv.rating) AS average_rating,
    MAX(rv.rating) AS highest_rating,
    MIN(rv.rating) AS lowest_rating
FROM RESTAURANTS r
JOIN REVIEWS rv
    ON r.restaurant_id = rv.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
ORDER BY average_rating DESC;


-- QUERY 6: Orders Above Average Order Value

SELECT
    o.order_id,
    c.full_name AS customer_name,
    r.restaurant_name,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM ORDERS o
JOIN CUSTOMERS c
    ON o.customer_id = c.customer_id
JOIN RESTAURANTS r
    ON o.restaurant_id = r.restaurant_id
JOIN ORDER_ITEMS oi
    ON o.order_id = oi.order_id
GROUP BY o.order_id, c.full_name, r.restaurant_name
HAVING SUM(oi.quantity * oi.unit_price) >
(
    SELECT AVG(order_total)
    FROM
    (
        SELECT
            SUM(quantity * unit_price) AS order_total
        FROM ORDER_ITEMS
        GROUP BY order_id
    ) AS order_totals
)
ORDER BY order_total DESC;


-- QUERY 7: Customers Without Orders

SELECT
    c.customer_id,
    c.full_name,
    c.city,
    c.address
FROM CUSTOMERS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM ORDERS o
    WHERE o.customer_id = c.customer_id
)
ORDER BY c.full_name ASC;



--  sec : SQLITE TRIGGERS

-- TRIGGER 1: Record New Orders

CREATE TRIGGER IF NOT EXISTS trg_order_created
AFTER INSERT ON ORDERS
FOR EACH ROW
BEGIN
    INSERT INTO ORDER_STATUS_HISTORY
    (
        order_id,
        changed_by,
        old_status,
        new_status,
        notes
    )
    VALUES
    (
        NEW.order_id,
        NULL,
        NULL,
        NEW.order_status,
        'Order created automatically'
    );
END;


-- TRIGGER 2: Record Order Status Changes

CREATE TRIGGER IF NOT EXISTS trg_order_status_update
AFTER UPDATE OF order_status ON ORDERS
FOR EACH ROW
WHEN OLD.order_status <> NEW.order_status
BEGIN
    INSERT INTO ORDER_STATUS_HISTORY
    (
        order_id,
        changed_by,
        old_status,
        new_status,
        notes
    )
    VALUES
    (
        NEW.order_id,
        NULL,
        OLD.order_status,
        NEW.order_status,
        'Order status changed automatically'
    );
END;


-- TRIGGER 3: Validate Order Items

CREATE TRIGGER IF NOT EXISTS trg_validate_order_item
BEFORE INSERT ON ORDER_ITEMS
FOR EACH ROW
WHEN NOT EXISTS
(
    SELECT 1
    FROM ORDERS o
    JOIN MENU_ITEMS m
        ON m.item_id = NEW.item_id
    WHERE o.order_id = NEW.order_id
      AND o.restaurant_id = m.restaurant_id
)
BEGIN
    SELECT RAISE(
        ABORT,
        'Menu item does not belong to the order restaurant'
    );
END;


-- TRIGGER 4: Validate Reviews

CREATE TRIGGER IF NOT EXISTS trg_validate_review
BEFORE INSERT ON REVIEWS
FOR EACH ROW
WHEN NOT EXISTS
(
    SELECT 1
    FROM ORDERS o
    WHERE o.order_id = NEW.order_id
      AND o.customer_id = NEW.customer_id
      AND o.restaurant_id = NEW.restaurant_id
)
BEGIN
    SELECT RAISE(
        ABORT,
        'Review does not match the order customer or restaurant'
    );
END;


-- TRIGGER 5: Validate Order Quantity

CREATE TRIGGER IF NOT EXISTS trg_validate_quantity
BEFORE INSERT ON ORDER_ITEMS
FOR EACH ROW
WHEN NEW.quantity <= 0
BEGIN
    SELECT RAISE(
        ABORT,
        'Quantity must be greater than zero'
    );
END;

-- third : VERIFY TRIGGERS

SELECT name
FROM sqlite_master
WHERE type = 'trigger'
ORDER BY name;

