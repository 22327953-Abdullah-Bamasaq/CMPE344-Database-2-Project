
import sqlite3



# DATABASE CONNECTION


def get_connection(database_path):

    connection = sqlite3.connect(database_path)

    connection.execute("PRAGMA foreign_keys = ON")

    connection.row_factory = sqlite3.Row

    return connection


# =========================================
# PROCEDURE 1: CREATE ORDER
# =========================================

def create_order(
    database_path,
    customer_id,
    restaurant_id,
    delivery_address,
    items,
    notes=None
):

    connection = get_connection(database_path)

    try:

        with connection:

            cursor = connection.execute(
                """
                INSERT INTO ORDERS
                (customer_id, restaurant_id,
                 delivery_address, notes)
                VALUES (?, ?, ?, ?)
                """,
                (
                    customer_id,
                    restaurant_id,
                    delivery_address,
                    notes
                )
            )

            order_id = cursor.lastrowid

            for item_id, quantity in items:

                if quantity <= 0:
                    raise ValueError(
                        "Quantity must be greater than zero"
                    )

                item = connection.execute(
                    """
                    SELECT price, is_available
                    FROM MENU_ITEMS
                    WHERE item_id = ?
                    AND restaurant_id = ?
                    """,
                    (item_id, restaurant_id)
                ).fetchone()

                if item is None:
                    raise ValueError(
                        "Item does not belong to this restaurant"
                    )

                if item["is_available"] != 1:
                    raise ValueError(
                        "Menu item is unavailable"
                    )

                connection.execute(
                    """
                    INSERT INTO ORDER_ITEMS
                    (order_id, item_id, quantity, unit_price)
                    VALUES (?, ?, ?, ?)
                    """,
                    (
                        order_id,
                        item_id,
                        quantity,
                        item["price"]
                    )
                )

        return order_id

    finally:
        connection.close()


# =========================================
# PROCEDURE 2: UPDATE ORDER STATUS
# =========================================

def update_order_status(
    database_path,
    order_id,
    new_status
):

    allowed_statuses = [
        "Pending",
        "Confirmed",
        "Preparing",
        "Out for Delivery",
        "Delivered",
        "Cancelled"
    ]

    if new_status not in allowed_statuses:
        raise ValueError("Invalid order status")

    connection = get_connection(database_path)

    try:

        with connection:

            cursor = connection.execute(
                """
                UPDATE ORDERS
                SET order_status = ?
                WHERE order_id = ?
                """,
                (new_status, order_id)
            )

            if cursor.rowcount == 0:
                raise ValueError("Order not found")

    finally:
        connection.close()


# =========================================
# FUNCTION 1: CALCULATE ORDER TOTAL
# =========================================

def calculate_order_total(database_path, order_id):

    connection = get_connection(database_path)

    try:

        result = connection.execute(
            """
            SELECT COALESCE(
                SUM(quantity * unit_price), 0
            ) AS total
            FROM ORDER_ITEMS
            WHERE order_id = ?
            """,
            (order_id,)
        ).fetchone()

        return result["total"]

    finally:
        connection.close()


# =========================================
# FUNCTION 2: RESTAURANT AVERAGE RATING
# =========================================

def restaurant_average_rating(
    database_path,
    restaurant_id
):

    connection = get_connection(database_path)

    try:

        result = connection.execute(
            """
            SELECT AVG(rating) AS average_rating
            FROM REVIEWS
            WHERE restaurant_id = ?
            """,
            (restaurant_id,)
        ).fetchone()

        return result["average_rating"]

    finally:
        connection.close()


# =========================================
# TEST FUNCTIONS
# =========================================

if __name__ == "__main__":

    DATABASE_PATH = "food_delivery.db"

    total = calculate_order_total(
        DATABASE_PATH,
        1
    )

    print("Order Total:", total)

    rating = restaurant_average_rating(
        DATABASE_PATH,
        1
    )

    print("Restaurant Average Rating:", rating)

