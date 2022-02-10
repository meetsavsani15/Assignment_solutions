SELECT * FROM fresh_segments.interest_map

SELECT * FROM fresh_segments.interest_metrics

							/* A. Data Exploration and Cleansing */
							
/* 1) Update the fresh_segments.interest_metrics table 
by modifying the month_year column to be a date data type with the start of the month */

ALTER TABLE fresh_segments.interest_metrics
ALTER month_year TYPE DATE USING month_year :: DATE

/* 2) What is count of records in the fresh_segments.interest_metrics 
for each month_year value sorted in chronological order (earliest to latest) 
with the null values appearing first? */

SELECT
	month_year,
	COUNT(*) AS total_records
FROM fresh_segments.interest_metrics
GROUP BY month_year
ORDER BY month_year

/* 3) What do you think we should do with these null values in the fresh_segments.interest_metrics */

DELETE FROM fresh_segments.interest_metrics
WHERE interest_id IS NULL

/* 4) How many interest_id values exist in the fresh_segments.interest_metrics 
table but not in the fresh_segments.interest_map table? What about the other way around? */

SELECT
	COUNT(DISTINCT mapp.id) AS total_map_id,
	COUNT(DISTINCT met.interest_id) AS total_metrics_id,
	SUM(CASE WHEN mapp.id IS NULL THEN 1 ELSE 0 END) AS not_in_metric,
	SUM(CASE WHEN met.interest_id IS NULL THEN 1 ELSE 0 END) AS not_in_map
FROM fresh_segments.interest_metrics met
FULL OUTER JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int

/* 5) Summarise the id values in the fresh_segments.interest_map by its total record count in this table */

SELECT
	COUNT(id) AS total_ids
FROM fresh_segments.interest_map

/* 6) What sort of table join should we perform for our analysis and why? 
Check your logic by checking the rows where interest_id = 21246 in your joined output 
and include all columns from fresh_segments.interest_metrics 
and all columns from fresh_segments.interest_map except from the id column. */

SELECT *
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON met.interest_id :: int = mapp.id
WHERE met.interest_id :: int = 21246



							/* B. Interest Analysis */

/* 1) Which interests have been present in all month_year dates in our dataset? */

SELECT 
  	COUNT(DISTINCT month_year) AS unique_month_year_count, 
  	COUNT(DISTINCT interest_id) AS unique_interest_id_count
FROM fresh_segments.interest_metrics;
	
/* 2) Using this same total_months measure - 
calculate the cumulative percentage of all records starting at 14 months - 
which total_months value passes the 90% cumulative percentage value? */

WITH cte_interest_months AS 
(
	SELECT
	  interest_id,
	  MAX(DISTINCT month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE interest_id IS NOT NULL
	GROUP BY interest_id
),
cte_interest_counts AS 
(
	  SELECT
		total_months,
		COUNT(DISTINCT interest_id) AS interest_count
	  FROM cte_interest_months
	  GROUP BY total_months
)
SELECT
  total_months,
  interest_count,
  ROUND(100 * SUM(interest_count) OVER (ORDER BY total_months DESC) / 
  (SUM(INTEREST_COUNT) OVER ()),2) AS cumulative_percentage
FROM cte_interest_counts;


/* 3) If we were to remove all interest_id values which are lower than the total_months 
value we found in the previous question - how many total data points would we be removing? */

WITH cte_interest_months AS 
(
	SELECT
	  interest_id,
	  MAX(DISTINCT month_year) AS total_months
	FROM fresh_segments.interest_metrics
	WHERE interest_id IS NOT NULL
	GROUP BY interest_id
),
cte_interest_counts AS 
(
	SELECT
		total_months,
		COUNT(DISTINCT interest_id) AS interest_count
	FROM cte_interest_months
	GROUP BY total_months
)
SELECT
	SUM(interest_count) AS total_values_to_be_removed
FROM cte_interest_counts

/* 4) Does this decision make sense to remove these data points from a business perspective?
Use an example where there are all 14 months present to a removed interest example 
for your arguments - 
think about what it means to have less months present from a segment perspective. */

-- No, it does not make sense to remove the data from the business perspective


									/* C. Segment Analysis */
									
/* 1) Which 5 interests had the lowest average ranking value? */

SELECT * FROM fresh_segments.interest_metrics
SELECT * FROM fresh_segments.interest_map

SELECT
	mapp.interest_name,
	ROUND(AVG(met.ranking), 2) AS avg_ranking
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int
GROUP BY mapp.interest_name
ORDER BY avg_ranking 

/* 2) Which 5 interests had the largest standard deviation in their percentile_ranking value? */

SELECT
	mapp.interest_name,
	STDDEV(percentile_ranking) AS standard_deviation
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int
GROUP BY mapp.interest_name
ORDER BY standard_deviation DESC 

/* 3) For the 5 interests found in the previous question - 
what was minimum and maximum percentile_ranking values for each interest 
and its corresponding year_month value? 
Can you describe what is happening for these 5 interests? */

SELECT
	mapp.interest_name,
	STDDEV(percentile_ranking) AS standard_deviation,
	MAX(percentile_ranking) AS maximum_percentile,
	MIN(percentile_ranking) AS minimum_percentile
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int
GROUP BY mapp.interest_name
ORDER BY standard_deviation DESC 


								/* D. Index Analysis */
								
							
/* 1) What is the top 10 interests by the average composition for each month? */

SELECT
	mapp.interest_name,
	met._month,
	AVG(met.composition / met.index_value) AS avg_compostion
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int
GROUP BY mapp.interest_name, met._month

/* 2) For all of these top 10 interests - which interest appears the most often? */

WITH interest_cte AS
(
	SELECT
		mapp.interest_name,
		met._month,
		AVG(met.composition / met.index_value) AS avg_compostion
	FROM fresh_segments.interest_metrics met
	JOIN fresh_segments.interest_map mapp
	ON mapp.id = met.interest_id :: int
	GROUP BY mapp.interest_name, met._month
)
SELECT
	interest_name,
	COUNT(interest_name) AS total_appearences
FROM interest_cte
GROUP BY interest_name
ORDER BY total_appearences DESC

/* 3) What is the average of the average composition for the top 10 interests for each month? */

SELECT
	mapp.interest_name,
	met._month,
	AVG(met.composition / met.index_value) AS avg_composition
FROM fresh_segments.interest_metrics met
JOIN fresh_segments.interest_map mapp
ON mapp.id = met.interest_id :: int
GROUP BY mapp.interest_name, met._month
ORDER BY avg_composition
limit 10



