-- 1. DROP tables (so it can be re-run cleanly)
DROP TABLE IF EXISTS trips;

DROP TABLE IF EXISTS drivers;

DROP TABLE IF EXISTS passengers;

DROP TABLE IF EXISTS locations;

DROP TABLE IF EXISTS payment_methods;

------------------------------------------------------------------------------------------------------	
-- 2. CREATE all 5 tables
CREATE TABLE locations(
	location_id SERIAL PRIMARY KEY,
	city_name varchar(100) NOT NULL UNIQUE 
);

CREATE TABLE drivers(
	driver_id serial PRIMARY KEY,
	name varchar(100) NOT NULL 
);

CREATE TABLE passengers (
passenger_id serial PRIMARY KEY ,
name varchar(100) NOT NULL 
);

CREATE TABLE payment_methods (
payment_method_id serial PRIMARY KEY ,
name varchar(30) NOT NULL 
);

CREATE TABLE trips(
	trip_id serial PRIMARY KEY,
	driver_id integer NOT NULL REFERENCES drivers(driver_id),
	passenger_id integer NOT NULL REFERENCES passengers(passenger_id),
	pickup_location_id integer NOT NULL REFERENCES locations(location_id),
	dropoff_location_id integer NOT NULL REFERENCES locations(location_id),
	fare_amount NUMERIC(10, 2) NOT NULL CHECK (fare_amount > 0),
	distance_km NUMERIC(6, 2) NOT NULL ,
	status varchar(50) NOT NULL CHECK(status IN('completed', 'cancelled', 'no_show')),
	requested_at timestamp NOT NULL ,
	completed_at timestamp,
	rating NUMERIC(2, 1) CHECK(rating BETWEEN 1.0 AND 5.0),
	payment_method_id integer REFERENCES payment_methods(payment_method_id)
);
-------------------------------------------------------------------------------------------------

-- 3. INSERT into drivers (with cleaning)
INSERT
	INTO
	drivers(name)
SELECT
	DISTINCT initcap(trim(regexp_replace(r.driver_name , '\s+', ' ', 'g')))
FROM
	rides r;

SELECT
	*
FROM
	drivers;
--------------------------------------------------------------------------------------------
-- 4. INSERT into passengers (with cleaning)

INSERT
	INTO
	passengers(name)
SELECT
	DISTINCT (initcap(trim(regexp_replace(r.rider_name, '\s+', ' ', 'g'))))
	FROM rides r;

SELECT
	*
FROM
	passengers;
----------------------------------------------------------------------------------------------
-- 5. INSERT into locations (UNION of pickup + dropoff)


INSERT
	INTO
	locations (city_name)
SELECT
	DISTINCT (pickup_city)
FROM
	rides r
UNION
SELECT
	DISTINCT (dropoff_city)
FROM
	rides r;

SELECT
	*
FROM
	locations;
-- 6. INSERT into payment_methods
INSERT
	INTO
	payment_methods (name)
SELECT
	DISTINCT (payment_method)
FROM
	rides
WHERE
	payment_method IS NOT NULL;

INSERT
	INTO
	payment_methods (name)
VALUES('IME pay5');

SELECT
	*
FROM
	payment_methods pm ;
-- 7. INSERT into trips (the big one with all the subqueries)
INSERT
	INTO
	trips(
	driver_id,
	passenger_id,
	pickup_location_id,
	dropoff_location_id ,
	fare_amount,
	distance_km,
	status,
	requested_at,
	completed_at,
	rating,
	payment_method_id
)
SELECT
	(
	SELECT
		driver_id
	FROM
		drivers
	WHERE
		name = initcap(trim(regexp_replace(r.driver_name, '\s+', ' ', 'g')))) driver_id,
	(
	SELECT
		passenger_id
	FROM
		passengers p
	WHERE
		p.name = initcap(trim(regexp_replace(r.rider_name, '\s+', ' ', 'g')))) passenger_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.pickup_city ) pickup_location_id,
	(
	SELECT
		location_id
	FROM
		locations p
	WHERE
		p.city_name = r.dropoff_city ) dropoff_location_id,
	fare_amount,
	ride_distance_km,
	ride_status,
	requested_at,
	completed_at,
	rating,
	(
	SELECT
		payment_method_id
	FROM
		payment_methods pm
	WHERE
		pm.name = r.payment_method ) payment_method_id
FROM
	rides r;
	
-----------------------------------------------------------------------------------------------------------------

-- 8. Verify with SELECTs
SELECT
	count(*)
FROM
	trips;

SELECT
	count(*)
FROM
	rides;
