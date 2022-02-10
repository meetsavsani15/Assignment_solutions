SELECT * FROM clique_bait.events
SELECT * FROM clique_bait.event_identifier
SELECT * FROM clique_bait.page_hierarchy

								/* B. Product Funnel Analysis */

/* Using a single SQL query - create a new output table which has the following details:

How many times was each product viewed?
How many times was each product added to cart?
How many times was each product added to a cart but not purchased (abandoned)?
How many times was each product purchased?
*/

CREATE TEMP TABLE product_details AS
(
WITH view_cart_cte AS
(
	SELECT
		e.visit_id,
		ph.page_name AS product_name,
		ph.product_id,
		ph.product_category,
		SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS total_product_views,
		SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS total_cart_add
	FROM clique_bait.events e
	JOIN clique_bait.page_hierarchy ph
	ON e.page_id = ph.page_id
	WHERE ph.product_id IS NOT NULL
	GROUP BY ph.page_name, e.visit_id, ph.product_id, ph.product_category			
),
visit_purchased_cte AS
(
	SELECT
		DISTINCT visit_id
	FROM clique_bait.events
	WHERE event_type = 3
),
purchased_cte AS
(
	SELECT
		vk.visit_id,
		vk.product_name,
		vk.product_category,
		vk.product_id,
		vk.total_product_views,
		vk.total_cart_add,
		CASE WHEN vc.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchased
	FROM view_cart_cte vk
	LEFT JOIN visit_purchased_cte vc
	ON vk.visit_id = vc.visit_id
),
final_cte AS
(
	SELECT
		product_name,
		product_category,
		SUM(total_product_views) AS page_view,
		SUM(total_cart_add) AS cart_add,
		SUM(CASE WHEN total_cart_add = 1 AND purchased = 0 THEN 1 ELSE 0 END) AS abadoned,
		SUM(CASE WHEN total_cart_add = 1 AND purchased = 1 THEN 1 ELSE 0 END) AS purchased
	FROM purchased_cte
	GROUP BY product_name,product_id, product_category
)
SELECT * FROM final_cte 

)

CREATE TEMP TABLE category_details AS
(
	WITH view_cart_cte AS
(
	SELECT
		e.visit_id,
		ph.page_name AS product_name,
		ph.product_id,
		ph.product_category,
		SUM(CASE WHEN event_type = 1 THEN 1 ELSE 0 END) AS total_product_views,
		SUM(CASE WHEN event_type = 2 THEN 1 ELSE 0 END) AS total_cart_add
	FROM clique_bait.events e
	JOIN clique_bait.page_hierarchy ph
	ON e.page_id = ph.page_id
	WHERE ph.product_id IS NOT NULL
	GROUP BY ph.page_name, e.visit_id, ph.product_id, ph.product_category			
),
visit_purchased_cte AS
(
	SELECT
		DISTINCT visit_id
	FROM clique_bait.events
	WHERE event_type = 3
),
purchased_cte AS
(
	SELECT
		vk.visit_id,
		vk.product_name,
		vk.product_category,
		vk.product_id,
		vk.total_product_views,
		vk.total_cart_add,
		CASE WHEN vc.visit_id IS NOT NULL THEN 1 ELSE 0 END AS purchased
	FROM view_cart_cte vk
	LEFT JOIN visit_purchased_cte vc
	ON vk.visit_id = vc.visit_id
),
final_cte_category AS
(
	SELECT
		product_category,
		SUM(total_product_views) AS page_view,
		SUM(total_cart_add) AS cart_add,
		SUM(CASE WHEN total_cart_add = 1 AND purchased = 0 THEN 1 ELSE 0 END) AS abadoned,
		SUM(CASE WHEN total_cart_add = 1 AND purchased = 1 THEN 1 ELSE 0 END) AS purchased
	FROM purchased_cte
	GROUP BY product_name,product_id, product_category
)
SELECT * FROM final_cte_category

)

SELECT * FROM category_details
SELECT * FROM product_details

/* 1) Which product had the most views, cart adds and purchases? */

SELECT
	product_name,
	MAX(page_view) AS max_page_view,
	MAX(cart_add) AS most_cart_add,
	MAX(purchased) AS most_purchased
FROM product_details
GROUP BY product_name
ORDER BY max_page_view, most_cart_add, most_purchased

/* 2) Which product was most likely to be abandoned? */

SELECT
	product_name
FROM product_details 
ORDER BY abadoned DESC
LIMIT 1
	
/* 3) Which product had the highest view to purchase percentage? */

SELECT
	product_name,
	ROUND(100 * purchased/page_view,2) AS purchase_per_view
FROM product_details
ORDER BY purchase_per_view DESC

/* 4) What is the average conversion rate from view to cart add? */

SELECT 
  ROUND(100*AVG(cart_add/page_view),2) AS avg_view_to_cart_add_conversion,
  ROUND(100*AVG(purchased/cart_add),2) AS avg_cart_add_to_purchases_conversion_rate
FROM product_details





