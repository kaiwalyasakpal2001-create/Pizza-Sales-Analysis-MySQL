-- Retrieve the total number of orders placed. 
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(o.quantity * p.price)) AS total_revenue
FROM
    order_details o
        JOIN
    pizzas p ON o.pizzaid = p.pizzaid;

-- Identify the highest-priced pizza.
SELECT 
    t.name, p.price
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
ORDER BY price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    COUNT(o.order_id) AS order_count, p.size
FROM
    order_details o
        JOIN
    pizzas p ON o.pizzaid = p.pizzaid
GROUP BY p.size
ORDER BY COUNT(o.order_id) DESC;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    t.name, SUM(o.quantity) quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizzaid = o.pizzaid
GROUP BY t.name
ORDER BY SUM(o.quantity) DESC
LIMIT 5; 

-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    t.category, SUM(o.quantity) quantity
FROM
    pizza_types t
        JOIN
    pizzas p ON t.pizza_type_id = p.pizza_type_id
        JOIN
    order_details o ON p.pizzaid = o.pizzaid
GROUP BY t.category
ORDER BY SUM(o.quantity) DESC;
-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(ordertime) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(ordertime);
-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(quantity)
FROM
    (SELECT 
        o.orderdate, SUM(od.quantity) AS quantity
    FROM
        order_details od
    JOIN orders o ON o.order_id = od.order_id
    GROUP BY o.orderdate) AS daily_summary;
-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name, sum(od.quantity*p.price) revenue from order_details od join pizzas p
on od.pizzaid=p.pizzaid join pizza_types pt on pt.pizza_type_id=p.pizza_type_id
group by pt.name order by revenue desc limit 3;
-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category,
    SUM(od.quantity * p.price) AS revenue,
    SUM(od.quantity * p.price) / (SELECT 
            SUM(od.quantity * p.price)
        FROM
            order_details od
                JOIN
            pizzas p ON p.pizzaid = od.pizzaid) * 100 AS revenue_percentage
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizzaid = p.pizzaid
GROUP BY pt.category
ORDER BY SUM(od.quantity * p.price) DESC; 

-- Analyze the cumulative revenue generated over time.
SELECT
    order_date,
    SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(
    SELECT
        orders.orderdate AS order_date,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM order_details

    JOIN pizzas
        ON order_details.pizzaid = pizzas.pizzaid

    JOIN orders
        ON orders.order_id = order_details.order_id

    GROUP BY orders.orderdate
) AS sales;
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
-- Determine the top 3 most ordered pizza types
-- based on revenue for each pizza category.

SELECT
    name,
    revenue
FROM
(
    SELECT
        category,
        name,
        revenue,
        RANK() OVER(
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS rn
    FROM
    (
        SELECT
            pt.category,
            pt.name,
            SUM(od.quantity * p.price) AS revenue
        FROM pizza_types pt

        JOIN pizzas p
            ON pt.pizza_type_id = p.pizza_type_id

        JOIN order_details od
            ON od.pizzaid = p.pizzaid

        GROUP BY pt.category, pt.name
    ) AS a
) AS b

WHERE rn <= 3;


