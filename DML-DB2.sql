
PRAGMA foreign_keys = ON;

-- =========================================
-- PART 1: INSERT
-- =========================================

-- 1. Insert a new role
INSERT INTO ROLES (role_name, description)
VALUES ('Restaurant Manager', 'Manages restaurant operations');

-- 2. Insert a new user
INSERT INTO USERS
(role_id, username, email, password, phone)
VALUES
(2, 'khaled', 'khaled@example.com', 'demo_hash_khaled', '0500000009');

-- 3. Insert a new customer
INSERT INTO CUSTOMERS
(user_id, full_name, address, city, postal_code)
VALUES
(9, 'Khaled Hassan', 'Street 30', 'Nicosia', '99040');

-- 4. Insert a new restaurant
INSERT INTO RESTAURANTS
(restaurant_name, description, address, city, phone, email)
VALUES
('Italian Kitchen', 'Traditional Italian food',
 'Main Road 40', 'Nicosia', '0392000004',
 'italian@example.com');

-- 5. Insert a new menu item
INSERT INTO MENU_ITEMS
(restaurant_id, item_name, description, price, category)
VALUES
(4, 'Lasagna', 'Italian beef lasagna', 28.00, 'Pasta');

-- 6. Insert a new order
INSERT INTO ORDERS
(customer_id, restaurant_id, delivery_address, notes)
VALUES
(6, 4, 'Nicosia, Street 30', 'Please deliver quickly');

-- 7. Insert order item
INSERT INTO ORDER_ITEMS
(order_id, item_id, quantity, unit_price)
VALUES
(6, 10, 2, 28.00);

-- 8. Insert payment
INSERT INTO PAYMENTS
(order_id, amount, payment_method, payment_status)
VALUES
(6, 56.00, 'Cash', 'Pending');

-- 9. Insert delivery
INSERT INTO DELIVERIES
(order_id, driver_id, delivery_status, delivery_fee)
VALUES
(6, 7, 'Assigned', 5.00);

-- 10. Insert order status history
INSERT INTO ORDER_STATUS_HISTORY
(order_id, changed_by, old_status, new_status, notes)
VALUES
(6, 1, NULL, 'Pending', 'New order created');

-- 11. Insert review
INSERT INTO REVIEWS
(customer_id, restaurant_id, order_id, rating, comment)
VALUES
(1, 1, 1, 5, 'Excellent restaurant');


-- =========================================
-- PART 2: UPDATE
-- =========================================

BEGIN TRANSACTION;

-- 1. Update customer information
UPDATE CUSTOMERS
SET address = 'New Street 50',
    city = 'Kyrenia'
WHERE customer_id = 1;

-- 2. Update user email
UPDATE USERS
SET email = 'ahmed.new@example.com'
WHERE user_id = 2;

-- 3. Update restaurant phone
UPDATE RESTAURANTS
SET phone = '0392999999'
WHERE restaurant_id = 1;

-- 4. Update menu item price
UPDATE MENU_ITEMS
SET price = 32.00
WHERE item_id = 2;

-- 5. Update menu item availability
UPDATE MENU_ITEMS
SET is_available = 0
WHERE item_id = 3;

-- 6. Update order status
UPDATE ORDERS
SET order_status = 'Confirmed'
WHERE order_id = 3;

-- 7. Update order item quantity
UPDATE ORDER_ITEMS
SET quantity = 3
WHERE order_item_id = 1;

-- 8. Update payment status
UPDATE PAYMENTS
SET payment_status = 'Paid'
WHERE payment_id = 3;

-- 9. Update delivery status
UPDATE DELIVERIES
SET delivery_status = 'Delivered',
    delivery_date = CURRENT_TIMESTAMP
WHERE delivery_id = 3;

-- 10. Update review comment
UPDATE REVIEWS
SET comment = 'Excellent food and service'
WHERE review_id = 1;

-- Undo demonstration updates
ROLLBACK;


-- =========================================
-- PART 3: DELETE
-- =========================================

BEGIN TRANSACTION;

-- 1. Delete a review
DELETE FROM REVIEWS
WHERE review_id = 2;

-- 2. Delete an order status history record
DELETE FROM ORDER_STATUS_HISTORY
WHERE history_id = 19;

-- 3. Delete a delivery
DELETE FROM DELIVERIES
WHERE delivery_id = 5;

-- 4. Delete a payment
DELETE FROM PAYMENTS
WHERE payment_id = 5;

-- 5. Delete an order item
DELETE FROM ORDER_ITEMS
WHERE order_item_id = 9;

-- 6. Delete an order
DELETE FROM ORDERS
WHERE order_id = 5;

-- 7. Delete a menu item
DELETE FROM MENU_ITEMS
WHERE item_id = 9;

-- 8. Delete a restaurant
DELETE FROM RESTAURANTS
WHERE restaurant_id = 3;

-- 9. Delete a customer
DELETE FROM CUSTOMERS
WHERE customer_id = 5;

-- 10. Delete a user
DELETE FROM USERS
WHERE user_id = 6;

-- Undo demonstration deletes
ROLLBACK;


-- =========================================
-- PART 4: VERIFY DATA
-- =========================================

SELECT * FROM ROLES;
SELECT * FROM USERS;
SELECT * FROM CUSTOMERS;
SELECT * FROM RESTAURANTS;
SELECT * FROM MENU_ITEMS;
SELECT * FROM ORDERS;
SELECT * FROM ORDER_ITEMS;
SELECT * FROM PAYMENTS;
SELECT * FROM DELIVERIES;
SELECT * FROM ORDER_STATUS_HISTORY;
SELECT * FROM REVIEWS;
