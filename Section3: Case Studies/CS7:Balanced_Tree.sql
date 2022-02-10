
									/* A. High Level Analysis */
									
/* 1. What was the total quantity sold for all products? */

SELECT
	pd.product_name,
	pd.product_id,
	SUM(s.qty) AS total_quantity
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s
ON pd.product_id = s.prod_id
GROUP BY pd.product_name, pd.product_id
ORDER BY total_quantity DESC


/* 2. What is the total generated revenue for all products before discounts? */

SELECT
	pd.product_name,
	pd.product_id,
	SUM(s.qty * s.price) AS total_revenue_generated
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s
ON pd.product_id = s.prod_id
GROUP BY pd.product_name, pd.product_id
ORDER BY total_revenue_generated DESC

/* 3) What was the total discount amount for all products? */

SELECT
	pd.product_name,
	pd.product_id,
	SUM(s.discount) AS total_discount_amount
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s
ON pd.product_id = s.prod_id
GROUP BY pd.product_name, pd.product_id
ORDER BY total_discount_amount DESC


								/* B. Transaction Analysis */
							
/* 1) How many unique transactions were there? */

SELECT
	COUNT(DISTINCT txn_id) AS total_unique_transactions
FROM balanced_tree.sales

/* 2) What is the average unique products purchased in each transaction? */

WITH unq_prod_cte AS
(
	SELECT
		txn_id,
		COUNT(DISTINCT prod_id) AS unique_products_purchased
	FROM balanced_tree.sales
	GROUP BY txn_id	
)
SELECT
	txn_id,
	AVG(unique_products_purchased) :: int AS avg_unique_products_purchased
FROM unq_prod_cte
GROUP BY txn_id
	

/* 3) What are the 25th, 50th and 75th percentile values for the revenue per transaction? */

WITH revenue_cte AS
(
	SELECT
		txn_id,
		SUM((qty * price) - discount) AS total_revenue
	FROM balanced_tree.sales
	GROUP BY txn_id
	ORDER BY total_revenue DESC	
)
SELECT
	PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY total_revenue) AS percentile_25,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_revenue) AS percentile_50,
	PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY total_revenue) AS percentile_75,
	PERCENTILE_CONT(1.0) WITHIN GROUP(ORDER BY total_revenue) AS percentile_100
FROM revenue_cte


/* 4) What is the average discount value per transaction? */

SELECT
	txn_id,
	AVG(discount) :: int AS avg_discount_value
FROM balanced_tree.sales
GROUP BY txn_id
ORDER BY avg_discount_value DESC

/* 5) What is the percentage split of all transactions for members vs non-members? */

WITH members_cte AS
(
	SELECT
		COUNT(member) AS members
	FROM balanced_tree.sales
	WHERE member = true
),
non_members_cte AS
(
	SELECT
		COUNT(member) AS non_members
	FROM balanced_tree.sales
	WHERE member = false
),
total_cte AS
(
	SELECT 
		COUNT(member) AS total
	FROM balanced_tree.sales
)
SELECT
	(members / total) :: FLOAT * 100 AS perc_mem,
	(non_members / total) :: FLOAT * 100 AS perc_non_mem
FROM members_cte, non_members_cte, total_cte
	

/* 6) What is the average revenue for member transactions and non-member transactions? */

WITH cte_member_revenue AS 
(
  SELECT
    	member,
    	txn_id,
    	SUM(price * qty) AS revenue
  FROM balanced_tree.sales
  GROUP BY member, txn_id
)
SELECT
 	 member,
  	ROUND(AVG(revenue), 2) AS avg_revenue
FROM cte_member_revenue
GROUP BY member


								/* C. Product Analysis */
								

/* 1) What are the top 3 products by total revenue before discount? */

SELECT
	pd.product_name,
	pd.product_id,
	SUM(s.qty * s.price) AS total_revenue
FROM balanced_tree.product_details pd
JOIN balanced_tree.sales s
ON pd.product_id = s.prod_id
GROUP BY pd.product_name, pd.product_id
ORDER BY total_revenue DESC
LIMIT 3

/* 2) What is the total quantity, revenue and discount for each segment? */

SELECT
	pd.segment_name,
	SUM(s.qty) AS total_quantity,
	SUM((s.qty * s.price) - s.discount) AS total_revenue,
	SUM(s.discount) AS total_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON pd.product_id = s.prod_id
GROUP BY pd.segment_name

/* 3) What is the top selling product for each segment? */

SELECT
	pd.product_name,
	pd.product_id,
	pd.segment_name,
	COUNT(s.txn_id) AS total_purchases
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON pd.product_id = s.prod_id
GROUP BY pd.product_id, pd.product_name, pd.segment_name
ORDER BY total_purchases DESC
LIMIT 4

/* 4) What is the total quantity, revenue and discount for each category? */

SELECT
	pd.category_name,
	SUM(s.qty) AS total_quantity,
	SUM((s.qty * s.price) - s.discount) AS total_revenue,
	SUM(s.discount) AS total_discount
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON pd.product_id = s.prod_id
GROUP BY pd.category_name


/* 5) What is the top selling product for each category? */

SELECT
	pd.product_name,
	pd.product_id,
	pd.category_name,
	COUNT(s.txn_id) AS total_purchases
FROM balanced_tree.sales s
JOIN balanced_tree.product_details pd
ON pd.product_id = s.prod_id
GROUP BY pd.product_id, pd.product_name, pd.category_name
ORDER BY total_purchases DESC
LIMIT 2

/* 6) What is the percentage split of revenue by product for each segment? */

WITH cte_product_revenue AS 
(
  SELECT
    	product_details.segment_id,
    	product_details.segment_name,
   	 	product_details.product_id,
    	product_details.product_name,
    SUM(sales.qty * sales.price) AS product_revenue
	FROM balanced_tree.sales
	JOIN balanced_tree.product_details
 	ON sales.prod_id = product_details.product_id
 	GROUP BY
    	product_details.segment_id,
    	product_details.segment_name,
    	product_details.product_id,
   	 	product_details.product_name
)
SELECT
	segment_name,
	product_name,
	ROUND( 100 * product_revenue / SUM(product_revenue) OVER (PARTITION BY segment_id),2) AS segment_product_percentage
FROM cte_product_revenue
ORDER BY segment_id, segment_product_percentage DESC


/* 7) What is the percentage split of revenue by segment for each category? */

WITH cte_product_revenue AS 
(
  SELECT
    	product_details.category_id,
    	product_details.category_name,
   	 	product_details.segment_id,
    	product_details.segment_name,
    SUM(sales.qty * sales.price) AS product_revenue
	FROM balanced_tree.sales
	JOIN balanced_tree.product_details
 	ON sales.prod_id = product_details.product_id
 	GROUP BY
    	product_details.category_id,
    	product_details.category_name,
    	product_details.segment_id,
   	 	product_details.segment_name
)
SELECT
	category_name,
	segment_name,
	ROUND(100 * product_revenue / SUM(product_revenue) OVER (PARTITION BY category_id),2) AS category_percentage
FROM cte_product_revenue
ORDER BY category_id, category_percentage DESC

/* 8) What is the percentage split of total revenue by category? */

SELECT 
   ROUND(100 * SUM(CASE WHEN pd.category_id = 1 THEN (s.qty * s.price) END) / SUM(s.qty * s.price),2) AS Women,
   (100 - ROUND(100 * SUM(CASE WHEN pd.category_id = 1 THEN (s.qty * s.price) END) / SUM(s.qty * s.price),2)) AS Men
FROM balanced_tree.sales AS s
JOIN balanced_tree.product_details AS pd
ON s.prod_id = pd.product_id

/* 9) What is the total transaction “penetration” for each product? */

WITH product_transactions_cte AS 
(
  	SELECT 
			DISTINCT prod_id,
    		COUNT(DISTINCT txn_id) AS product_transactions
 	 FROM balanced_tree.sales
  	 GROUP BY prod_id
),
total_transactions_cte AS 
(
  	SELECT
    	COUNT(DISTINCT txn_id) AS total_transaction_count
  	FROM balanced_tree.sales
)
SELECT
  pd.product_id,
  pd.product_name,
  ROUND(100 * pt.product_transactions::NUMERIC / tt.total_transaction_count,2) AS penetration_percentage
FROM product_transactions_cte pt
CROSS JOIN total_transactions_cte tt
INNER JOIN balanced_tree.product_details pd
ON pt.prod_id = pd.product_id
ORDER BY penetration_percentage DESC;







