-- Q1
SELECT COUNT(DISTINCT trip_id)
FROM trip_offer_datamart
WHERE
    published_date BETWEEN CURRENT_DATE()
    AND DATETIME_SUB(CURRENT_DATE(), INTERVAL 30 DAY)

--Q2
SELECT
    country,
    COUNT(DISTINCT trip_id) AS nb_publications
FROM trip_offer_datamart
WHERE
    published_date BETWEEN CURRENT_DATE()
    AND DATETIME_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
GROUP BY country
ORDER BY 2 DESC
LIMIT 10

--Other use cases
-- How many riders took carpooling from Lyon to Marseille for the last month?
SELECT count(*)
FROM trip_ride_datamart, unnest(ride) AS ride
WHERE
    departure_date <= current_date()
    AND departure_date >= datetime_sub(current_date(), INTERVAL 30 DAY)
    AND country = "France"
    AND ride.ride_origin_city = "Lyon"
    AND ride.ride_destination_city = "Marseille"
    AND ride.ride_status = "Finished"


-- Which origin and destination city pairs (trip route) in France have the highest occupancy rates for the last month?
SELECT
    origin_city,
    destination_city,
    AVG(occupancy_rate)
FROM trip_ride_datamart
WHERE
    departure_date <= CURRENT_DATE()
    AND departure_date >= DATETIME_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
    AND country = "France"
GROUP BY origin_city, destination_city
ORDER BY occupancy_rate DESC
LIMIT 100