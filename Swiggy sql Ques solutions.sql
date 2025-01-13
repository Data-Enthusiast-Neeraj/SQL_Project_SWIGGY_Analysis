1. Find customers who have never ordered


SELECT * FROM users
WHERE 
user_id NOT IN (SELECT DISTINCT(user_id) from orders)



2. Average Price/dish

SELECT f.f_name, ROUND(AVG(price), 2) AS avg_price 
FROM menu AS m
JOIN food AS f
ON f.f_id = m.f_id
GROUP BY  f.f_name
ORDER BY f_name; 

3. Display average rating of all the Restaurants.

SELECT
    r.r_name AS restaurant_name,
    ROUND(AVG(o.restaurant_rating), 2) AS average_rating
FROM
    orders o
JOIN
    restaurants r ON o.r_id = r.r_id
GROUP BY
    r.r_id, r.r_name
ORDER BY
    average_rating DESC;

MODERATE LEVEL

1. To find the top 3 month in terms of the number of orders

SELECT 
    TO_CHAR(DATE_TRUNC('month', date), 'Month') AS order_month, 
    COUNT(order_id) AS total_orders 
FROM 
    orders 
GROUP BY 
    order_month 
ORDER BY 
    total_orders DESC 
LIMIT 3;


2. Find the top restaurant in terms of the number of orders for a given month (eg. JULY)

SELECT r.r_name, COUNT(*) 
FROM orders AS o
JOIN restaurants AS r
ON o.r_id = r.r_id
WHERE TRIM(TO_CHAR(date, 'Month')) = 'July'
GROUP BY o.r_id, r.r_name
ORDER BY COUNT(*) DESC 
LIMIT 3;


3. restaurants with monthly sales greater than x for can any threshold value 
(eg. month is june and threshold value-amount is 500)

SELECT 
  r.r_name, 
  SUM(o.amount) AS revenue 
FROM 
  orders AS o 
  JOIN restaurants AS r ON o.r_id = r.r_id 
WHERE 
  TRIM(TO_CHAR(date, 'Month')) = 'June' 
GROUP BY 
  o.r_id, 
  r.r_name 
HAVING 
  SUM(o.amount) > 500;



4. Show all orders with order details for a particular customer in a particular date range
eg. ("What all did Ankit order from 10th June 2022 to 10th July 2022?")

SELECT 
  o.order_id, 
  r.r_name, 
  f.f_name 
FROM 
  orders o 
  JOIN restaurants r ON r.r_id = o.r_id 
  JOIN order_details od ON o.order_id = od.order_id 
  JOIN food f ON f.f_id = od.f_id 
WHERE 
  user_id = (
    SELECT 
      user_id 
    FROM 
      users 
    WHERE 
      name LIKE 'Ankit'
  ) 
  AND date > '2022-06-10' 
  AND date < '2022-07-10';

ADAVANCE LEVEL
1. Find restaurants with max repeated customers 

SELECT r.r_name, COUNT(*) AS "loyal_customers"
FROM (
    SELECT r_id, user_id, COUNT(*) AS "visits"
    FROM orders
    GROUP BY r_id, user_id
    HAVING COUNT(*) > 1
) t
JOIN restaurants AS r
ON r.r_id = t.r_id
GROUP BY t.r_id, r.r_name
ORDER BY "loyal_customers" DESC
LIMIT 1;

2. Month over month revenue growth of swiggy

SELECT month, ROUND(( (revenue - prev) / prev ) * 100, 2) AS "percentage_change"
FROM (
    WITH sales AS (
        SELECT TO_CHAR(date, 'Month') AS "month", SUM(amount) AS "revenue"
        FROM orders
        GROUP BY TO_CHAR(date, 'Month')
        ORDER BY TO_DATE(TO_CHAR(date, 'Month'), 'Month')
    )
    SELECT month, revenue, LAG(revenue, 1) OVER (ORDER BY TO_DATE(month, 'Month')) AS prev
    FROM sales
) AS t;


3. Customer - favorite food

WITH fav_food AS ( select t2.user_id, name, f_name , count(*) as frequency   from users as t1
                   join orders        as t2        on t1.user_id = t2.user_id
                   join order_details as t3        on t2.order_id = t3.order_id
                   join food          as t4        on t3.f_id = t4.f_id
                   group by t1.name, t4.f_name ,t2.user_id )

SELECT * FROM fav_food as f1 
where  frequency = (select MAX(frequency) from fav_food as f2 
                                          where f2.user_id= f1.user_id )
order by user_id

4. Find the most loyal customers for all restaurant

WITH customer_order_counts AS (
    SELECT
        r_id,
        user_id,
        COUNT(order_id) AS total_orders
    FROM
        orders
    GROUP BY
        r_id, user_id
),
most_loyal_customers AS (
    SELECT
        r_id,
        user_id,
        total_orders,
        RANK() OVER (PARTITION BY r_id ORDER BY total_orders DESC) AS rank
    FROM
        customer_order_counts
)
SELECT
    r.r_name AS restaurant_name,
    u.name AS customer_name,
    mlc.total_ordersS
FROM
    most_loyal_customers mlc
JOIN
    restaurants r ON r.r_id = mlc.r_id
JOIN
    users AS u ON u.user_id = mlc.user_id
WHERE
    mlc.rank = 1;


5.Month over month revenue growth of a restaurant

WITH monthly_revenue AS (
    SELECT
        r_id,
        DATE_TRUNC('month', date) AS month,
        SUM(amount) AS total_revenue
    FROM
        orders
    GROUP BY
        r_id, DATE_TRUNC('month', date)
),
revenue_with_growth AS (
    SELECT
        r_id,
        month,
        total_revenue,
        LAG(total_revenue) OVER (PARTITION BY r_id ORDER BY month) AS previous_revenue,
        CASE
            WHEN LAG(total_revenue) OVER (PARTITION BY r_id ORDER BY month) IS NOT NULL THEN
                ROUND((total_revenue - LAG(total_revenue) OVER (PARTITION BY r_id ORDER BY month)) * 100.0
                / LAG(total_revenue) OVER (PARTITION BY r_id ORDER BY month), 2)
            ELSE
                NULL
        END AS revenue_growth_percentage
    FROM
        monthly_revenue
)
SELECT
    r.r_name AS restaurant_name,
    rwg.month,
    rwg.total_revenue,
    rwg.previous_revenue,S
    rwg.revenue_growth_percentage
FROM
    revenue_with_growth rwg
JOIN
    restaurants r ON rwg.r_id = r.r_id
ORDER BY
    r.r_name, rwg.month;


6.Most Paired Products

WITH product_pairs AS (
    SELECT
        od1.f_id AS product_1,
        od2.f_id AS product_2,
        COUNT(*) AS pair_count
    FROM
        order_details od1
    JOIN
        order_details od2
    ON
        od1.order_id = od2.order_id
        AND od1.f_id < od2.f_id -- Avoid self-joins and duplicate pairs
    GROUP BY
        od1.f_id, od2.f_id
),
most_paired_products AS (
    SELECT
        p1.f_name AS product_1_name,
        p2.f_name AS product_2_name,
        pp.pair_count
    FROM
        product_pairs pp
    JOIN
        food p1 ON pp.product_1 = p1.f_id
    JOIN
        food p2 ON pp.product_2 = p2.f_id
    ORDER BY
        pp.pair_count DESC
    LIMIT 10
)
SELECT
    product_1_name,
    product_2_name,
    pair_count
FROM
    most_paired_products;
