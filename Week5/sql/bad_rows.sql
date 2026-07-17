-- 1) completed_have_duration
ALTER TABLE trips DROP CONSTRAINT chk_completed_at;
-- insert: status='completed', completed_at=NULL
-- (run after: ALTER TABLE trips DROP CONSTRAINT chk_completed_at;)

INSERT INTO trips (
    trip_id, driver_id, passenger_id, pickup_location_id, dropoff_location_id,
    payment_method_id, promo_code_id, vehicle_id, base_fare, tip_amount, discount_amount,
    surge_multiplier, distance_km, status, requested_at, completed_at,
    driver_rating, passenger_rating
) VALUES (
    999001, 1, 1, 1, 2,
    1, NULL, 1, 10, 0, 0,
    1.0, 5.2, 'completed', NOW(), NULL,
    5, 5
);
-- run 	python pipeline.py >> logs/run3_bad_data.log 2>&1

DELETE FROM trips WHERE trip_id = 999001;

ALTER TABLE trips ADD CONSTRAINT chk_completed_at
  CHECK ((((status)::text = 'completed'::text) AND (completed_at IS NOT NULL)) OR ((status)::text <> 'completed'::text));

-- 2) valid_status
ALTER TABLE trips DROP CONSTRAINT trips_status_check;
-- insert: status='in_progress'

INSERT INTO trips (
    trip_id, driver_id, passenger_id, pickup_location_id, dropoff_location_id,
    payment_method_id, promo_code_id, vehicle_id, base_fare, tip_amount, discount_amount,
    surge_multiplier, distance_km, status, requested_at, completed_at,
    driver_rating, passenger_rating
) VALUES (
    999002, 1, 1, 1, 2,
    1, NULL, 1, 10, 0, 0,
    1.0, 5.2, 'in_progress', NOW(), NULL,
    NULL, NULL
);
-- run 	python pipeline.py >> logs/run3_bad_data.log 2>&1


DELETE FROM trips WHERE trip_id = 999002;






ALTER TABLE trips ADD CONSTRAINT trips_status_check
  CHECK (status::text = ANY (ARRAY['completed','cancelled','no_show']::text[]));

-- 3) no_negative_fares
ALTER TABLE trips DROP CONSTRAINT trips_base_fare_check;

ALTER TABLE trips DROP CONSTRAINT chk_discount_not_exceed_base;

-- insert: base_fare=10, surge_multiplier=1, tip_amount=0, discount_amount=50, status='completed', completed_at=NOW()


INSERT INTO trips (
    trip_id, driver_id, passenger_id, pickup_location_id, dropoff_location_id,
    payment_method_id, promo_code_id, vehicle_id, base_fare, tip_amount, discount_amount,
    surge_multiplier, distance_km, status, requested_at, completed_at,
    driver_rating, passenger_rating
) VALUES (
    999003, 1, 1, 1, 2,
    1, NULL, 1, -999, 0, 0,
    1.0, 5.2, 'completed', NOW(), NOW() + INTERVAL '15 minutes',
    5, 5
);

-- run 	python pipeline.py >> logs/run3_bad_data.log 2>&1

DELETE FROM trips WHERE trip_id = 999003;

ALTER TABLE trips ADD CONSTRAINT chk_discount_not_exceed_base
  CHECK (discount_amount <= base_fare);
ALTER TABLE trips ADD CONSTRAINT trips_base_fare_check
  CHECK (base_fare >= (0)::numeric);


-- NOTE: 1) check_row_count
-- Not tested here — this check can never fail as currently wired.
-- pipeline.py only calls run_quality_checks() when fact_rows is
-- non-empty (see the `if not fact_rows:` guard), so len(rows) >= 1
-- is already guaranteed before this check ever runs.


-- 2) check_no_null_driver_keys
-- Not tested here — transform.py already skips (and never appends
-- to fact_rows) any row whose driver_id doesn't resolve to a
-- driver_key, so this check never receives a row that could fail it.
-- Would require directly constructing a fact_rows list in a unit
-- test to actually exercise, rather than an end-to-end DB insert.








