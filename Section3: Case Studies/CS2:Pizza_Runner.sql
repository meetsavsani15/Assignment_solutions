DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
SELECT * FROM customer_orders;
SELECT * FROM pizza_names;
SELECT * FROM pizza_recipes;
SELECT * FROM pizza_toppings;
SELECT * FROM runner_orders;
SELECT * FROM runners;

-- Clean customer_order table
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions = ''

-- Clean runners_order table

SELECT * FROM runner_orders;

UPDATE runner_orders
SET distance = NULL
WHERE distance = 'null'

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null'

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null'

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = 'null'

UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation = ''

										/* A. Pizza Metrics */

/* 1) How many pizzas were ordered? */

SELECT count(pizza_id) AS total_pizza_ordered FROM customer_orders;

/* 2) How many unique customer orders were made? */

SELECT count(DISTINCT customer_id) AS unique_customer_orders FROM customer_orders;

/* 3) How many successful orders were delivered by each runner? */

SELECT (count(*) - count(cancellation))  AS successfull_deliveries , runner_id
FROM runner_orders
GROUP BY runner_id;

/* 4) How many of each type of pizza was delivered? */

WITH pizza_runner AS
(
	SELECT
	co.pizza_id,
	co.order_id,
	ro.runner_id,
	ro.cancellation
	FROM customer_orders co
	JOIN runner_orders ro
	ON ro.order_id = co.order_id
	WHERE ro.cancellation is NULL		
)
SELECT count(pizza_id), pizza_id
FROM pizza_runner
GROUP BY pizza_id

/* 5) How many Vegetarian and Meatlovers were ordered by each customer? */

SELECT 
	co.customer_id,
	SUM(CASE WHEN pn.pizza_name = 'Meatlovers' THEN 1 ELSE 0 END) AS meatlovers,
	SUM(CASE WHEN pn.pizza_name = 'Vegetarian' THEN 1 ELSE 0 END) AS Vegetarian
FROM customer_orders co
JOIN pizza_names pn
ON co.pizza_id = pn.pizza_id
GROUP BY co.customer_id
ORDER BY co.customer_id

/* 6) What was the maximum number of pizzas delivered in a single order? */


SELECT
	co.order_id,
	count(co.pizza_id) as total_delivered_pizza,
	ro.cancellation
FROM customer_orders co
JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE ro.cancellation is null
GROUP BY co.order_id, ro.cancellation
ORDER BY count(co.pizza_id) DESC

/* 7) For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */

SELECT 
	co.customer_id,
	SUM(
		CASE 
			WHEN co.exclusions is NULL THEN 1 
			WHEN co.extras is NULL THEN 1
			ELSE 0
		END) as no_change,
		
	SUM(
		CASE 
			WHEN co.exclusions is NOT NULL THEN 1 
			WHEN co.extras is NOT NULL THEN 1	
			ELSE 0 
		END) as change
FROM customer_orders co
JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE ro.cancellation is null
GROUP BY co.customer_id


/* 8) How many pizzas were delivered that had both exclusions and extras? */

SELECT
	co.order_id,
	co.customer_id,
	co.pizza_id,
	co.extras,
	co.exclusions,
	ro.cancellation
FROM customer_orders co
JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE co.exclusions is NOT NULL
AND co.extras is NOT NULL
AND ro.cancellation is NULL

/* 9) What was the total volume of pizzas ordered for each hour of the day? */

select * from customer_orders;

SELECT EXTRACT(hour from order_time) as hour_of_day,
	   COUNT(pizza_id) as total_pizza
FROM customer_orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

/* 10) What was the volume of orders for each day of the week? */

SELECT EXTRACT(dow from order_time) as day_of_week,
	   COUNT(order_id) as total_orders
FROM customer_orders
GROUP BY day_of_week
ORDER BY day_of_week;



							/* B. Runner and Customer Experience */
							
/* 1) How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) */

		doubt: why this weird answer
		
SELECT 
	EXTRACT(week from registration_date) as total_week,
	count(runner_id) as total_registrations
FROM runners
GROUP BY total_week
ORDER BY total_week

/* 2) What was the average time in minutes it took for each runner to arrive 
		at the Pizza Runner HQ to pickup the order? */		

WITH time_interval AS 
(
	   SELECT ro.order_id, EXTRACT(minute from ro.pickup_time :: timestamp) :: int AS pickup_minutes,
	   EXTRACT(minute from co.order_time :: timestamp) :: int AS order_minutes,
	   ABS(EXTRACT(minute from ro.pickup_time :: timestamp) :: int - EXTRACT(minute from co.order_time :: timestamp) :: int) as time_diff
	   FROM runner_orders ro
       INNER JOIN customer_orders co
       ON ro.order_id = co.order_id		
)
SELECT ROUND(avg(ti.time_diff),2), ro.runner_id
FROM time_interval ti
JOIN runner_orders ro
ON ti.order_id = ro.order_id
GROUP BY ro.runner_id



/* 3) Is there any relationship between the number of pizzas and how long the order takes to prepare? */

	DOUBT: is this right?

select COUNT(pizza_id), order_id
from customer_orders
group by order_id
order by order_id


	SELECT 
		co.order_id,
		count(co.pizza_id) AS no_of_pizza,
		EXTRACT(minute from co.order_time :: timestamp) :: int AS order_minute,
		EXTRACT(minute from ro.pickup_time :: timestamp) :: int AS pickup_minute,
		ABS(EXTRACT(minute from co.order_time :: timestamp) :: int -
		    EXTRACT(minute from ro.pickup_time :: timestamp) :: int) AS time_diff
	FROM customer_orders co
	JOIN runner_orders ro
	ON co.order_id = ro.order_id
	GROUP BY co.order_id, co.order_time, ro.pickup_time
	ORDER BY co.order_id

	
/* 4) What was the average distance travelled for each customer? */

SELECT
	co.customer_id,
	ROUND(AVG(ro.distance :: DEC(4,2)), 2) AS avg_distance
FROM customer_orders co
JOIN runner_orders ro
ON co.order_id = ro.order_id
WHERE ro.cancellation is NULL
GROUP BY co.customer_id
ORDER BY co.customer_id


/* 5) What was the difference between the longest and shortest delivery times for all orders? */

SELECT
	(MAX(duration :: int) - MIN(duration :: int)) AS time_diff
FROM runner_orders
WHERE cancellation IS NULL;

/* 6) What was the average speed for each runner 
	  for each delivery and do you notice any trend for these values? */

	SELECT
		runner_id,
		order_id,
		ROUND(DISTANCE :: DEC(4,2)/(DURATION :: DEC(4,2)/60),2) AS speed_km_hr
	FROM runner_orders
	WHERE cancellation is NULL
	ORDER BY runner_id, order_id

/* 7) What is the successful delivery percentage for each runner? */

SELECT
	runner_id,
	COUNT(*) AS total_deliveries,
	COUNT(pickup_time) AS successful_deliveries,
	CONCAT(COUNT(pickup_time) * 100 / COUNT(*), '%') as percentage
FROM runner_orders
GROUP BY runner_id
ORDER BY runner_id


								/* C. Ingredient Optimization */
								
/* 1) What are the standard ingredients for each pizza? */


WITH top_id AS
(
	SELECT
	pizza_id,
	regexp_split_to_table(toppings, ',') AS toppings_id
	FROM pizza_recipes
)
SELECT
	pt.topping_name,
	td.pizza_id
FROM top_id td
JOIN pizza_toppings pt
ON td.toppings_id :: int = pt.topping_id
ORDER BY td.pizza_id


/* 2) What was the most commonly added extra? */

WITH extras_split AS
(
	SELECT
		regexp_split_to_table(extras, ',') AS toppings_choosen
	FROM customer_orders
)
SELECT
	COUNT(es.toppings_choosen) AS count_of_toppings,
	pt.topping_name
FROM extras_split es
JOIN pizza_toppings pt
ON es.toppings_choosen :: int = pt.topping_id
GROUP BY topping_name
ORDER BY COUNT(es.toppings_choosen) DESC


/* 3) What was the most common exclusion? */

WITH extras_split AS
(
	SELECT
		regexp_split_to_table(exclusions, ',') AS exclusions_choosen
	FROM customer_orders
)
SELECT
	COUNT(es.exclusions_choosen) AS count_of_exclusions,
	pt.topping_name
FROM extras_split es
JOIN pizza_toppings pt
ON es.exclusions_choosen :: int = pt.topping_id
GROUP BY topping_name
ORDER BY COUNT(es.exclusions_choosen) DESC


/* 4) Generate an order item for each record in the customers_orders table in the format 
of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers */


WITH cust_orders AS
(
	SELECT
		customer_id,
		order_id,
		pizza_id,
		regexp_split_to_table(exclusions, ',') AS exclusions_choosen,
		regexp_split_to_table(extras, ',') AS extras_choosen
	FROM customer_orders
),
exclusions_name AS
(
	SELECT
		co.customer_id,
		pt.topping_name AS exclusions
	FROM pizza_toppings pt
	JOIN cust_orders co
	ON pt.topping_id = co.exclusions_choosen :: int
),
extras_name AS
(
	SELECT
		co.customer_id,
		pt.topping_name AS extras
	FROM pizza_toppings pt
	JOIN cust_orders co
	ON pt.topping_id = co.extras_choosen :: int
),
pizza_name AS
(
	SELECT
		co.customer_id,
		pn.pizza_name AS pizza
	FROM pizza_names pn
	JOIN cust_orders co
	ON co.pizza_id = pn.pizza_id
)
SELECT
	co.customer_id,
	co.order_id,
	CONCAT('Pizza: ', pn.pizza, ',    ' ,'Exclude- ' , en.exclusions, ',   ', 'Extras- ', exn.extras)
FROM cust_orders co
JOIN pizza_name pn
ON pn.customer_id = co.customer_id
JOIN exclusions_name en
ON en.customer_id = pn.customer_id
JOIN extras_name exn
ON exn.customer_id = en.customer_id
GROUP BY co.customer_id, co.order_id,pn.pizza, en.exclusions, exn.extras
ORDER BY co.customer_id


/* 5) Generate an alphabetically ordered comma separated ingredient list for 
each pizza order from the customer_orders table 
and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami" */


WITH ingredients AS
(
	SELECT
		co.order_id,
		pr.pizza_id,
		regexp_split_to_table(toppings, ',') AS ing_id
	FROM pizza_recipes pr
	JOIN customer_orders co
	ON pr.pizza_id = co.pizza_id
),
ingredients_name AS
(
		SELECT
 		co.order_id,
		ing.pizza_id,
 		pt.topping_name
 		FROM pizza_toppings pt
 		JOIN ingredients ing
 		ON pt.topping_id = ing.ing_id :: int
 		JOIN customer_orders co
 		ON co.order_id = ing.order_id
		GROUP BY co.order_id, ing.pizza_id, pt.topping_name
)
-- count_exclusions_extras AS
-- (
-- 	SELECT
-- 		inn.order_id,
-- 		en.extras,
-- 		exn.exclusions
-- 	FROM ingredients_name inn
-- 	JOIN customer_orders co
-- 	ON co.order_id = inn.order_id
-- 	JOIN extras_name en
-- 	ON inn.order_id = en.order_id
-- 	JOIN exclusion_name exn
-- 	ON en.order_id = exn.order_id
-- 	GROUP BY inn.order_id, exn.exclusions, en.extras
-- ),
-- count_extras AS
-- (
-- 	SELECT
-- 	order_id,
-- 	string_agg(extras, ', ') AS extras
-- 	FROM count_exclusions_extras
-- 	GROUP BY order_id
-- ),
-- count_exclusions AS
-- (
-- 	SELECT
-- 	order_id,
-- 	string_agg(exclusions, ', ') AS exclusions
-- 	FROM count_exclusions_extras
-- 	GROUP BY order_id
-- ),
--topping_name AS
--(
	SELECT
	inn.order_id,
	pn.pizza_name,
	string_agg(inn.topping_name, ', ' ORDER BY inn.topping_name) AS topping_name
	FROM pizza_names pn
	JOIN ingredients_name inn
	ON pn.pizza_id = inn.pizza_id
	GROUP BY pn.pizza_name, inn.order_id
)





DROP TABLE IF EXISTS exclusion_name
CREATE TEMP TABLE exclusion_name AS
(
	WITH cust_orders AS
	(
	SELECT
		customer_id,
		order_id,
		pizza_id,
		regexp_split_to_table(exclusions, ',') AS exclusions_choosen,
		regexp_split_to_table(extras, ',') AS extras_choosen
	FROM customer_orders
	)
	SELECT
		co.customer_id,
		co.order_id,
		pt.topping_name AS exclusions
	FROM pizza_toppings pt
	JOIN cust_orders co
	ON pt.topping_id = co.exclusions_choosen :: int
);

DROP TABLE IF EXISTS extras_name
CREATE TEMP TABLE extras_name AS
(
	WITH cust_orders AS
	(
	SELECT
		customer_id,
		order_id,
		pizza_id,
		regexp_split_to_table(exclusions, ',') AS exclusions_choosen,
		regexp_split_to_table(extras, ',') AS extras_choosen
	FROM customer_orders
	)
	SELECT
		co.customer_id,
		co.order_id,
		pt.topping_name AS extras
	FROM pizza_toppings pt
	JOIN cust_orders co
	ON pt.topping_id = co.extras_choosen :: int
);

















	
	













