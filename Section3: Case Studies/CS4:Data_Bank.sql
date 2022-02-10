								/* A. Customer Nodes Exploration */

/* 1) How many unique nodes are there on the Data Bank system? */

SELECT COUNT(DISTINCT node_id) FROM customer_nodes

/* 2) What is the number of nodes per region? */

SELECT
	cn.region_id,
	r.region_name,
	COUNT(cn.node_id)
FROM customer_nodes cn
JOIN regions r
ON r.region_id = cn.region_id
GROUP BY cn.region_id, r.region_name

/* 3) How many customers are allocated to each region? */

SELECT
	cn.region_id,
	r.region_name,
	COUNT(DISTINCT cn.customer_id)
FROM customer_nodes cn
JOIN regions r
ON r.region_id = cn.region_id
GROUP BY cn.region_id, r.region_name

/* 4) How many days on average are customers reallocated to a different node? */

SELECT 
	CEIL(AVG(ABS(EXTRACT(DAY FROM start_date) - EXTRACT(DAY FROM end_date)))) AS avg_days_of_reallocation
FROM customer_nodes

/* 5) What is the median, 80th and 95th percentile for this same reallocation days metric for each region? */


WITH days_difference AS
(
	SELECT 
	region_id,
	(ABS(EXTRACT(DAY FROM start_date) - EXTRACT(DAY FROM end_date))) AS days_of_reallocation
	FROM customer_nodes

)
SELECT 	
		region_id,
		PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY days_of_reallocation) AS median,
 		PERCENTILE_CONT(0.8) WITHIN GROUP(ORDER BY days_of_reallocation) AS percentile_80,
 		PERCENTILE_CONT(0.95) WITHIN GROUP(ORDER BY days_of_reallocation) AS percentile_95
FROM days_difference
GROUP BY region_id


								
								/* B. Customer Transactions */
								
/* 1) What is the unique count and total amount for each transaction type? */

SELECT
	txn_type,
	SUM(txn_amount)
FROM customer_transactions
GROUP BY txn_type

/* 2) What is the average total historical deposit counts and amounts for all customers? */

WITH deposit_amount AS
(
	SELECT
		txn_type AS deposit,
		txn_amount AS amount
	FROM customer_transactions
	WHERE txn_type = 'deposit'
)
SELECT
	COUNT(deposit) AS total_deposits,
	CEIL(AVG(amount)) AS avg_amount_of_deposits
FROM deposit_amount
	

/* 3) For each month - how many Data Bank customers
	make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month? */

DROP TABLE deposit_condition
DROP TABLE purchase_condition
DROP TABLE withdrawal_condition

CREATE TEMP TABLE deposit_condition AS
(
	WITH deposit_cust AS
	(
	SELECT
		customer_id,
		txn_type
	FROM customer_transactions
	WHERE txn_type = 'deposit'
	)
	SELECT
		customer_id AS deposit_customers,
		COUNT(customer_id) AS deposit_count
	FROM deposit_cust
	GROUP BY customer_id

);


CREATE TEMP TABLE purchase_condition AS
(
	WITH purchase_cust AS
	(
	SELECT
		customer_id,
		txn_type
	FROM customer_transactions
	WHERE txn_type = 'purchase'
	)
	SELECT
		customer_id AS purchase_customers,
		COUNT(customer_id) AS purchase_count
	FROM purchase_cust
	GROUP BY customer_id
	ORDER BY customer_id

)

DROP TABLE IF EXISTS
CREATE TEMP TABLE withdrawal_condition AS
(
	WITH withdrawal_cust AS
	(
	SELECT
		customer_id,
		txn_type
	FROM customer_transactions
	WHERE txn_type = 'withdrawal'
	)
	SELECT
		customer_id AS withdrawal_customers,
		COUNT(customer_id) AS withdrawal_count
	FROM withdrawal_cust
	GROUP BY customer_id
	
)

CREATE TEMP TABLE months AS
(
	SELECT
		customer_id,
	EXTRACT(MONTH FROM txn_date) as month
	FROM customer_transactions
	GROUP BY customer_id, txn_date
)

SELECT
	COUNT(DISTINCT ct.customer_id),
	mt.month
FROM customer_transactions ct
JOIN months mt
ON ct.customer_id = mt.customer_id
JOIN deposit_condition dt
ON mt.customer_id = dt.deposit_customers
JOIN purchase_condition pt
ON dt.deposit_customers = pt.purchase_customers
JOIN withdrawal_condition wt
ON pt.purchase_customers = wt.withdrawal_customers
WHERE deposit_count > 1 AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY mt.month
ORDER BY mt.month


----------------------- OR ---------------------------------

WITH cust_cte AS
(
	SELECT
		EXTRACT(MONTH from txn_date) AS month_part,
		TO_CHAR(txn_date, 'Month') AS month,
		customer_id,
		SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
		SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
		SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
	FROM customer_transactions
	GROUP BY
		EXTRACT(MONTH from txn_date),
		TO_CHAR(txn_date, 'Month'),
		customer_id
)
SELECT
	month,
	COUNT(customer_id)
FROM cust_cte
WHERE deposit_count > 1 AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY month

	

/* 3.1) For each month - how many Data Bank customers
	make deposit and purchase and withdrawal in a single month? */



WITH deposit_cust AS
(
	SELECT
		customer_id,
		txn_type AS deposit,
		txn_amount AS amount
	FROM customer_transactions
	WHERE txn_type = 'deposit'
),
purchase_cust AS
(
	SELECT
		customer_id,
		txn_type AS deposit,
		txn_amount AS amount
	FROM customer_transactions
	WHERE txn_type = 'purchase'
),
withdrawal_cust AS
(
	SELECT
		customer_id,
		txn_type AS deposit,
		txn_amount AS amount
	FROM customer_transactions
	WHERE txn_type = 'withdrawal'
),
month_cust AS
(
	SELECT
		customer_id,
	EXTRACT(MONTH FROM txn_date) as month
	FROM customer_transactions
	GROUP BY customer_id, txn_date
)
SELECT
	COUNT(DISTINCT ct.customer_id),
	mt.month
FROM customer_transactions ct
JOIN month_cust mt
ON ct.customer_id = mt.customer_id
JOIN deposit_cust dt
ON mt.customer_id = dt.customer_id
JOIN purchase_cust pt
ON dt.customer_id = pt.customer_id
JOIN withdrawal_cust wt
ON pt.customer_id = wt.customer_id
GROUP BY mt.month


/* 4) What is the closing balance for each customer at the end of the month? */

SELECT
	SUM(txn_amount) AS closing_balance,
	customer_id,
	EXTRACT(MONTH FROM txn_date) AS monthh,
	TO_CHAR(txn_date, 'Month')
FROM customer_transactions
GROUP BY customer_id, EXTRACT(MONTH FROM txn_date),TO_CHAR(txn_date, 'Month')
ORDER BY customer_id, EXTRACT(MONTH FROM txn_date)

/* 5) What is the percentage of customers who increase their closing balance by more than 5%? */


WITH closing_balance_cte AS
(
	SELECT
		SUM(txn_amount) AS closing_balance,
		customer_id,
		EXTRACT(MONTH FROM txn_date) AS monthh,
		TO_CHAR(txn_date, 'Month') AS month_name
	FROM customer_transactions
	GROUP BY customer_id, EXTRACT(MONTH FROM txn_date),TO_CHAR(txn_date, 'Month')
	ORDER BY customer_id, EXTRACT(MONTH FROM txn_date)
),
prev_curr_closing_balance_cte AS
(
	SELECT
		customer_id,
		MONTHH,
		closing_balance,
	LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY MONTHH ASC) AS prev_closing_balance,
	closing_balance - LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY MONTHH ASC) AS difference,
	(closing_balance - LAG(closing_balance, 1) OVER(PARTITION BY customer_id ORDER BY MONTHH ASC))/closing_balance :: float * 100 AS percentage_increase
	FROM closing_balance_cte
)
SELECT
	ROUND((COUNT(DISTINCT customer_id) :: numeric / 
	 (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) :: numeric) * 
	 100 , 2) AS percentage_of_customers
FROM prev_curr_closing_balance_cte
WHERE percentage_increase > 5



							/* C. Data Allocation Challenge */
							
/*
To test out a few different hypotheses - the Data Bank team wants to run an experiment 
where different groups of customers would be allocated data using 3 different options:

Option 1: data is allocated based off the amount of money at the end of the previous month

Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

Option 3: data is updated real-time

For this multi-part challenge question - 
you have been requested to generate the following data elements to 
help the Data Bank team estimate how much data will need to be provisioned for each option:

running customer balance column that includes the impact each transaction
customer balance at the end of each month
minimum, average and maximum values of the running balance for each customer

Using all of the data available - 
how much data would have been required for each option on a monthly basis?


*/


-- Option 1 (1720 rows of data)

SELECT * FROM customer_transactions
SELECT * FROM customer_nodes

DROP TABLE total_balance_temp
CREATE TEMPORARY TABLE total_balance_temp AS
(
	SELECT
	customer_id,
	txn_date,
	CASE 
	 	WHEN txn_type = 'credit' THEN '+' || txn_amount
	 	WHEN txn_type = 'debit' THEN '-' || txn_amount
	 	ELSE NULL
	END AS total_balance
	FROM customer_transactions
	ORDER BY customer_id
)

WITH running_balance_cte AS
(
	-- RUNNING BALANCE CTE
	SELECT
	customer_id,
	TO_CHAR(txn_date, 'Month'),
	SUM(total_balance :: int) OVER (PARTITION BY customer_id , EXTRACT(month FROM txn_date) ORDER BY customer_id, EXTRACT(month FROM txn_date)
						  ROWS UNBOUNDED PRECEDING)
						  AS running_balance
	FROM total_balance_temp
)
-- AVG, MAX, MIN RUNNING BALANCE
SELECT 
	customer_id,
	ROUND(AVG(running_balance),2) AS average_value,
	MAX(running_balance) AS maximun_value,
	MIN(running_balance) AS minimum_value
FROM running_balance_cte
GROUP BY ROLLUP (customer_id)
ORDER BY customer_id


-- Option - 3 (Real-Time)

WITH running_balance_cte AS
(
	-- RUNNING BALANCE CTE
	SELECT
	customer_id,
	txn_date,
	SUM(total_balance :: int) OVER (PARTITION BY customer_id , txn_date ORDER BY customer_id, txn_date
						  ROWS UNBOUNDED PRECEDING)
						  AS running_balance
	FROM total_balance_temp
)
-- AVG, MAX, MIN RUNNING BALANCE
SELECT 
	customer_id,
	ROUND(AVG(running_balance),2) AS average_value,
	MAX(running_balance) AS maximun_value,
	MIN(running_balance) AS minimum_value
FROM running_balance_cte
GROUP BY ROLLUP (customer_id)
ORDER BY customer_id


-- Option - 3

-- The output is same as above queries.

SELECT
	customer_id,
	txn_date
FROM customer_transactions
WHERE txn_date > txn_date - interval '30 days'
GROUP BY customer_id, txn_date
ORDER BY customer_id






















