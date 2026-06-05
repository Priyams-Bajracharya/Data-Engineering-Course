# Data Engineering Course

A hands-on data engineering course covering the core tools and concepts used in modern data pipelines — from ingestion and storage to transformation and orchestration. Course material is added weekly.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- Python 3.10+
- Basic SQL knowledge

## Course Structure

| Week | Topic | Status |
|------|-------|--------|
| [Week 1](#week-1--postgresql--docker) | Data engineering and Basic SQL | In progress |

---

## Week 1 — Data engineering and Basic SQL


### Files

| File | Description |
|------|-------------|
| `docker-compose.yml` | Launches a PostgreSQL 16 container with a persistent volume |
| `rides.csv` | Sample ride-sharing dataset (ride fares, distances, statuses across Nepali cities) |

### Dataset Schema

`rides.csv` — ride-level records from a fictional ride-sharing service.

| Column | Type | Description |
|--------|------|-------------|
| `ride_id` | int | Unique ride identifier |
| `driver_name` | string | Driver full name |
| `rider_name` | string | Rider full name |
| `pickup_city` | string | City where the ride started |
| `dropoff_city` | string | City where the ride ended |
| `fare_amount` | float | Fare in NPR |
| `ride_distance_km` | float | Trip distance in kilometers |
| `ride_status` | string | `completed`, `cancelled`, or `no_show` |
| `requested_at` | timestamp | When the ride was requested |
| `completed_at` | timestamp | When the ride was completed (null if not completed) |
| `rating` | float | Rider rating out of 5 (null if not completed) |
| `payment_method` | string | `cash` or `card` |

### Getting Started

```bash
cd Week1

# Start the PostgreSQL container
docker compose up -d

# Connect to the database
docker exec -it course_postgres psql -U postgres -d ridedb


# Stop the container when done
docker compose down
```

---

## License

This repository is for educational purposes.
