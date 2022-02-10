CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  
select * from members;
select * from menu;
select * from sales;


/* 1) What is the total amount each customer spent at the restaurant? */

SELECT
	s.customer_id,
	SUM(m.price) as amount_spent
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

/* 2) How many days has each customer visited the restaurant? */

SELECT 
	customer_id,
	COUNT(DISTINCT order_date) as total_days
FROM sales
GROUP BY customer_id;

/* 3) What was the first item from the menu purchased by each customer? */

SELECT *
FROM
(
	SELECT
	s.customer_id,
	s.order_date,
	s.product_id,
-- 	m.product_name,
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as r
FROM sales s
-- JOIN menu m
-- ON m.product_id = s.product_id
) as T
WHERE r = 1

/* 4) What is the most purchased item on the menu and how many times was it purchased by all customers? */

SELECT 
	count(s.product_id) as most_purchased, 
	s.product_id,
	m.product_name
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name

/* 5) Which item was the most popular for each customer? */

SELECT
	customer_id,
	product_id,
	count(product_id)
FROM sales
GROUP BY 
	GROUPING SETS (
	(customer_id, product_id),
	product_id,
	customer_id,
	()
);
							
-- OR

WITH purchases AS
(
	SELECT 
		s.customer_id,
		m.product_name,
		count(*) as times_purchased
		FROM sales s
		JOIN menu m
		ON s.product_id = m.product_id
		GROUP BY s.customer_id,  m.product_name
		ORDER BY s.customer_id, COUNT(*) DESC
),
ranked AS
(
	SELECT *,
	RANK() OVER(PARTITION BY customer_id ORDER BY times_purchased DESC) as most_pop
	from purchases
)
SELECT 
	customer_id,
	product_name,
	times_purchased
FROM ranked
where most_pop = 1


/* 6) Which item was purchased first by the customer after they became a member? */

SELECT *
FROM
(
	SELECT
	s.product_id,
	m.product_name,
	s.customer_id,
	s.order_date,
	mem.join_date,
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as r
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id
WHERE
	order_date >= join_date	
) as t


/* 7) Which item was purchased just before the customer became a member? */

	SELECT
	s.product_id,
	m.product_name,
	s.customer_id,
	s.order_date,
	mem.join_date,
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as r
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id
WHERE
	order_date < join_date	

/* 8) What is the total items and amount spent for each member before they became a member? */

WITH bfr_member_details AS 
(
	SELECT
	s.product_id,
	m.product_name,
	s.customer_id,
	s.order_date,
	mem.join_date,
	ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) as r
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
JOIN members mem
ON mem.customer_id = s.customer_id
WHERE
	order_date < join_date	
),
count_of_products AS
(
	SELECT COUNT(product_id) as total_items, customer_id
	FROM bfr_member_details	
	GROUP BY customer_id
),
total_purchase_amount AS
(
	SELECT SUM(m.price) as amount, bfr.customer_id
	FROM menu m
	JOIN bfr_member_details bfr
	ON bfr.product_id = m.product_id
	GROUP BY bfr.customer_id
)
SELECT total_items, amount, total_purchase_amount.customer_id
FROM count_of_products
JOIN total_purchase_amount
ON count_of_products.customer_id = total_purchase_amount.customer_id



/* 9) If each $1 spent equates to 10 points and sushi has a 2x points multiplier 
- how many points would each customer have? */


-- not considering the membership condition

WITH points AS 
(
	SELECT
	product_id,
	product_name,
	CASE
		WHEN product_id = '1' THEN price * 10 * 2
		WHEN product_id = '2' THEN price * 10
		WHEN product_id = '3' THEN price * 10
	END AS total_point
	FROM menu
)
SELECT 
	s.customer_id,
	s.product_id,
	sum(p.total_point) 
FROM sales s
FULL JOIN points p
ON s.product_id = p.product_id
GROUP BY s.customer_id, s.product_id
ORDER BY s.product_id


/* 10) In the first week after a customer joins the program (including their join date) 
they earn 2x points on all items, not just sushi - 
how many points do customer A and B have at the end of January? */
