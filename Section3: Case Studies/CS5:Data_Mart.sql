                 				/* A. Data Cleaning Steps */

/*
Convert the week_date to a DATE format

Add a week_number as the second column for each week_date value, 
for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc

Add a month_number with the calendar month for each week_date value as the 3rd column

Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values

Add a new column called age_band after the original segment 
column using the following mapping on the number inside the segment value

Add a new demographic column using the following mapping for the first letter in the segment values

Ensure all null string values with an "unknown" 
string value in the original segment column as well as the new age_band and demographic columns

Generate a new avg_transaction column as the sales value divided by transactions rounded 
to 2 decimal places for each record
*/



SELECT * FROM data_mart

ALTER TABLE data_mart
ADD COLUMN id SERIAL

CREATE TABLE clean_weekly_sales AS
(
	WITH week_num_cte AS
	(
		SELECT
			id,
			EXTRACT(WEEK FROM week_date) AS week_number
		FROM data_mart
	),
	month_num_cte AS
	(
		SELECT
			id,
			EXTRACT(MONTH FROM week_date) AS month_number
		FROM data_mart
	),
	year_num_cte AS
	(
		SELECT
			id,
			EXTRACT(YEAR FROM week_date) AS year_number
		FROM data_mart
	),
	age_band_cte AS
	(
		SELECT
			id,
			segment,
			CASE
				WHEN RIGHT(segment, 1) :: int = 1 THEN 'Young Adults'
				WHEN RIGHT(segment, 1) :: int = 2 THEN 'Middle Aged'
				WHEN RIGHT(segment, 1) :: int = 3 OR RIGHT(segment, 1) :: int = 4 THEN 'Retirees'
				ELSE NULL
			END AS age_band
		FROM data_mart
	),
	demographics_cte AS
	(
		SELECT
			id,
			segment,
			CASE
				WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
				WHEN LEFT(segment, 1) = 'F' THEN 'Families'
				ELSE NULL
			END AS demographics
		FROM data_mart
	),
	avg_transaction_cte AS
	(
		SELECT
			id,
			ROUND((sales :: numeric /transactions :: numeric) :: numeric, 2) AS avg_transactions
		FROM data_mart
	)
	SELECT
		dm.id,
		dm.week_date,
		wk.week_number,
		mk.month_number,
		yk.year_number,
		agb.age_band,
		demo.demographics,
		atr.avg_transactions
	FROM
	data_mart dm
	JOIN week_num_cte wk
	ON dm.id = wk.id
	JOIN month_num_cte mk
	ON wk.id = mk.id
	JOIN year_num_cte yk
	ON mk.id = yk.id
	JOIN age_band_cte agb 
	ON yk.id = agb.id
	JOIN demographics_cte demo
	ON agb.id = demo.id
	JOIN avg_transaction_cte atr
	ON demo.id = atr.id
)

SELECT * FROM clean_weekly_sales



							/* B. Data Exploration */
							
/* 1) What day of the week is used for each week_date value? */

SELECT
	week_date,
	TO_CHAR(week_date, 'Day')
FROM clean_weekly_sales

/* 2) What range of week numbers are missing from the dataset? */


SELECT 
	CASE
		WHEN (SELECT * FROM GENERATE_SERIES(1, 52)) IN week_number THEN 'MISSING'
		ELSE 'NOT MISSING'
	END AS week_range
FROM clean_weekly_sales

/* 3)How many total transactions were there for each year in the dataset? */

SELECT
	EXTRACT(YEAR FROM week_date),
	COUNT(transactions)
FROM data_mart
GROUP BY EXTRACT(YEAR FROM week_date)

/* 4)What is the total sales for each region for each month? */

SELECT 
	region,
	TO_CHAR(week_date, 'Month') AS month_name,
	EXTRACT(MONTH from week_date) AS month_number,
	SUM(sales) AS total_sales
FROM data_mart
GROUP BY region, TO_CHAR(week_date, 'Month'),EXTRACT(MONTH from week_date)
ORDER BY region, EXTRACT(MONTH from week_date)

/* 5) What is the total count of transactions for each platform */

SELECT
	platform,
	COUNT(transactions)
FROM data_mart
GROUP BY platform

/* 6) What is the percentage of sales for Retail vs Shopify for each month? */

SELECT
	platform,
	EXTRACT(MONTH from week_date) AS month_number,
	ROUND((COUNT(sales) / (SELECT COUNT(sales) FROM data_mart) :: numeric) * 100,2) AS percentage_of_sales
FROM data_mart
GROUP BY 
	ROLLUP (platform, EXTRACT(MONTH from week_date))
ORDER BY platform, EXTRACT(MONTH from week_date)

/* 7) What is the percentage of sales by demographic for each year in the dataset? */

WITH sales_cte AS
(
	SELECT COUNT(sales) AS total_sales FROM data_mart
),
demo_cte AS
(
	SELECT
		cl.demographics,
		cl.year_number,
		COUNT(dm.sales) AS demo_sales
FROM clean_weekly_sales cl
JOIN data_mart dm
ON dm.id = cl.id
GROUP BY cl.demographics, cl.year_number
ORDER BY cl.demographics, cl.year_number	
)
SELECT
	demographics,
	year_number,
	ROUND(demo_sales / total_sales :: numeric * 100, 2)
FROM demo_cte, sales_cte
	

/* 8) Which age_band and demographic values contribute the most to Retail sales? */

SELECT
	cl.age_band,
	cl.demographics,
	dm.sales 
FROM clean_weekly_sales cl
JOIN data_mart dm
ON dm.id = cl.id
WHERE cl.age_band IS NOT NULL AND
      cl.demographics IS NOT NULL	
ORDER BY dm.sales DESC
LIMIT 5

/* 9) Can we use the avg_transaction column to 
find the average transaction size for each year for Retail vs Shopify? 
If not - how would you calculate it instead? */

SELECT 
	dm.platform,
	cl.year_number,
	AVG(avg_transactions)
FROM clean_weekly_sales cl
JOIN data_mart dm
ON dm.id = cl.id
GROUP BY ROLLUP(dm.platform, cl.year_number)
ORDER BY dm.platform, cl.year_number


							/* C. Before and After Analysis */
						
/* This technique is usually used when we inspect an important event 
and want to inspect the impact before and after a certain point in time.
Taking the week_date value of 2020-06-15 as the baseline week where 
the Data Mart sustainable packaging changes came into effect.
We would include all week_date values for 2020-06-15 
as the start of the period after the change and the previous week_date values would be before */


/* 1) What is the total sales for the 4 weeks before and after 2020-06-15? 
What is the growth or reduction rate in actual values and percentage of sales? */


WITH week_cte AS
(
	SELECT 
		cl.week_date,
		cl.week_number,
		dm.sales,
		CASE
			WHEN cl.week_number < 25 THEN 'Before'
			WHEN cl.week_number > 25 THEN 'After'
			ELSE 'Present'
		END AS bfr_afr
	FROM clean_weekly_sales cl
	JOIN data_mart dm
	ON cl.id = dm.id
	WHERE cl.week_number BETWEEN 21 AND 29
	ORDER BY cl.week_number		
),
growth_rate_per_sales_cte AS
(
	SELECT
		sales,
		bfr_afr,
		sales - LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date) AS revenue_growth,
		(sales - LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date)) :: numeric/
		(LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date)) :: numeric * 100 AS percentage_growth,
		PERCENT_RANK() OVER(PARTITION BY bfr_afr ORDER BY sales) AS percentage_sales
	FROM week_cte
	GROUP BY bfr_afr, sales, week_date	
)
SELECT
	bfr_afr,
	AVG(revenue_growth) AS avg_sales ,
	AVG(percentage_growth) AS avg_percentage_growth,
	AVG(percentage_sales) AS avg_per_sales
FROM growth_rate_per_sales_cte
GROUP BY bfr_afr
	

/* 2) What about the entire 12 weeks before and after? */

WITH week_cte AS
(
	SELECT 
		cl.week_date,
		cl.week_number,
		dm.sales,
		CASE
			WHEN cl.week_number < 25 THEN 'Before'
			WHEN cl.week_number > 25 THEN 'After'
			ELSE 'Present'
		END AS bfr_afr
	FROM clean_weekly_sales cl
	JOIN data_mart dm
	ON cl.id = dm.id
	ORDER BY cl.week_number		
),
growth_rate_per_sales_cte AS
(
	SELECT
		sales,
		bfr_afr,
		sales - LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date) AS revenue_growth,
		(sales - LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date)) :: numeric/
		(LAG(sales) OVER(PARTITION BY bfr_afr ORDER BY week_date)) :: numeric * 100 AS percentage_growth,
		PERCENT_RANK() OVER(PARTITION BY bfr_afr ORDER BY sales) AS percentage_sales
	FROM week_cte
	GROUP BY bfr_afr, sales, week_date	
)
SELECT
	bfr_afr,
	AVG(revenue_growth) AS avg_sales ,
	AVG(percentage_growth) AS avg_percentage_growth,
	AVG(percentage_sales) AS avg_per_sales
FROM growth_rate_per_sales_cte
GROUP BY bfr_afr

/* 3) How do the sale metrics for 
these 2 periods before and after compare with the previous years in 2018 and 2019? */

WITH sales_for_year AS
(
	SELECT
		cl.week_date,
		EXTRACT(YEAR from cl.week_date),
		PERCENT_RANK() OVER(PARTITION BY EXTRACT(YEAR from cl.week_date) ORDER BY dm.sales DESC) AS per_sales
	FROM clean_weekly_sales cl
	JOIN data_mart dm
	ON cl.id = dm.id
	WHERE EXTRACT(YEAR from cl.week_date) BETWEEN 2018 AND 2019
	GROUP BY ROLLUP (cl.week_date,EXTRACT(YEAR from cl.week_date), dm.sales)	
)
SELECT
	EXTRACT(YEAR FROM week_date),
	AVG(per_sales) AS avg_sales
FROM sales_for_year
GROUP BY EXTRACT(YEAR FROM week_date)






	
	
