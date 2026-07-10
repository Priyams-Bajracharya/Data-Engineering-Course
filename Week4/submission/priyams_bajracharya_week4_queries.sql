--task 3
-- ## 3. Revenue by city / month

-- Write a warehouse query that returns total revenue grouped by pickup city
-- and month.

-- Then write the equivalent query against the OLTP schema (`trips`,
-- `locations`, etc.) directly.

-- **Answer:** how many table joins does each version need? Which one needed
-- fewer, and why?

SELECT dl.city_name , dd.month_name , sum(f.fare_amount) AS total_revenue FROM 
fact_trips f
JOIN dim_location dl ON f.pickup_location_key  = dl.location_key 
JOIN dim_date dd ON f.date_key = dd.date_key 
GROUP BY dl.city_name , dd.month_name ;


SELECT pck.city_name, EXTRACT (MONTH FROM t.requested_at) AS month , sum(t.fare_amount) AS total_revenue 
FROM trips t 
JOIN locations pck ON t.pickup_location_id = pck.location_id
GROUP BY pck.city_name , month;


SELECT pck.city_name, EXTRACT (MONTH FROM t.requested_at) AS month , sum(round(COALESCE(t.base_fare,0) * COALESCE(t.surge_multiplier,0) + COALESCE(t.tip_amount,0) - COALESCE(t.discount_amount,0), 2)) AS total_revenue 
FROM trips t 
JOIN locations pck ON t.pickup_location_id = pck.location_id
GROUP BY pck.city_name , month;

--2 joins for datawarehouse tables , while 1 join for oltp database, 
-- because oltp is optimised for less redundancy while in datawarehouse we separate
-- the date into a new dim table for easier analysis and to reduce computational complexity of extracting month 
-- from requested at 


-- ## 4. Payment method revenue

-- - Write a warehouse query for total revenue per payment method.
---  Extend it (or write a second query) for **average fare per trip, per
--  payment method, per month**.


SELECT p.name ,sum(t.fare_amount) AS total_revenue 
FROM fact_trips t JOIN dim_payment_method p 
ON t.payment_method_key = p.payment_method_key 
GROUP BY p.name ;

SELECT
	p.name ,
	d.month_name ,
	sum(t.fare_amount) AS total_revenue ,
	round(avg(t.fare_amount), 2) AS avg_fare
FROM
	fact_trips t
LEFT JOIN dim_payment_method p 
ON
	t.payment_method_key = p.payment_method_key
JOIN dim_date d ON
	t.date_key = d.date_key
GROUP BY
	p.name ,
	d.month_name ;

--in this query should we use join or left join as the payment method could have been null?



-- ## 5. Busiest hour of day

-- Write a warehouse query that returns trip count per hour of day (0–23),
-- along with each hour's percentage of all trips — computed with a **window
-- function** (not a second query for the grand total).


SELECT dt.HOUR , count(*) AS trip_count 
FROM fact_trips f
JOIN dim_time dt ON f.time_key  = dt.time_key 
GROUP BY dt."hour" 
ORDER BY dt.HOUR;


SELECT HOUR , trip_count ,
trip_count::NUMERIC/sum(trip_count) OVER () * 100 AS hourly_percentage
FROM (
	SELECT dt.HOUR, count(*) AS trip_count 
	FROM fact_trips ft 
	JOIN dim_time dt  ON ft.time_key = dt.time_key 
	GROUP BY dt."hour" 
) AS hourly_counts 
ORDER BY HOUR ;