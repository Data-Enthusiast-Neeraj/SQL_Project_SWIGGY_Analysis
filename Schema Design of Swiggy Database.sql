-- Table 1: Users
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password TEXT NOT NULL
);

-- Table 2: Orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    r_id INT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    date DATE NOT NULL,
    partner_id INT,
    delivery_time INT,
    delivery_rating INT CHECK (delivery_rating BETWEEN 1 AND 5),
    restaurant_rating INT CHECK (restaurant_rating BETWEEN 1 AND 5),
	FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE,
    FOREIGN KEY (r_id) REFERENCES restaurants (r_id) ON DELETE CASCADE,
    FOREIGN KEY (partner_id) REFERENCES delivery_partners (partner_id) ON DELETE SET NULL
);


-- Table 3: Order Details
CREATE TABLE order_details (
    id INT PRIMARY KEY,
    order_id INTEGER NOT NULL,
    f_id INTEGER NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders (order_id) ON DELETE CASCADE,
    FOREIGN KEY (f_id) REFERENCES food (f_id) ON DELETE CASCADE
);

-- Table 4: Food
CREATE TABLE food (
    f_id SERIAL PRIMARY KEY,
    f_name VARCHAR(100) NOT NULL,
    food_type VARCHAR(50) NOT NULL
);


-- Table  5: Menu
CREATE TABLE menu (
    menu_id SERIAL PRIMARY KEY,
    r_id INTEGER NOT NULL,
    f_id INTEGER NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price > 0),
    FOREIGN KEY (r_id) REFERENCES restaurants (r_id) ON DELETE CASCADE,
    FOREIGN KEY (f_id) REFERENCES food (f_id) ON DELETE CASCADE
);

-- Table 6: Restaurants
CREATE TABLE restaurants (
    r_id SERIAL PRIMARY KEY,
    r_name VARCHAR(100) NOT NULL,
    cuisine VARCHAR(50) NOT NULL
);

-- Table 7: Delivery Partners
CREATE TABLE delivery_partners (
    partner_id SERIAL PRIMARY KEY,
    partner_name VARCHAR(100) NOT NULL
);



