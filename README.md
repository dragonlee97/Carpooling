# Documentation
A real business context of carpooling: A driver can publish carpooling trips that riders can book according to their needs (departure & destination)
# OLTP
Normalized OLTP tables which store event data from software.
![OLTP MODEL](https://github.com/dragonlee97/blablacar_exercise/blob/main/images/OLTP.png?raw=true)
# OLAP
Here below are 3 data marts created using One Big Table(OBT) methodology.
![OLAP MODEL](https://github.com/dragonlee97/blablacar_exercise/blob/main/images/OLAP.png?raw=true)
## Trip Offer Datamart
- **Description**: This datamart is used to analyse the trip offers supply on capacity, route planning, pricing etc.
- **Freshness**: Daily (Updated at HH:mm every day to have D-1 data)
- **Granularity**: Trip (trip_id)
- **Partition & Expiration**: Partitioned by published and expires in xx days
- **Clustering Columns**: departure_time, trip_status, country
### Schema
| Column                             | Type      | Description                                                                           |
|------------------------------------|-----------|---------------------------------------------------------------------------------------|
| **Dimensions**                     |           |                                                                                       |
| PARTITIONING FIELD: published_date | date      | Date when the trip offer is published                                                 |                                                              |
| trip_id                            | string    | Id of the trip                                                                        |
| depature_time*                     | timestamp | Depature time of the trip                                                             |
| trip_status*                       | string    | Status of the trip (ongoing, cancelled, closed, etc.)                                 |
| country*                           | string    | Country of this trip                                                                  |
| origin_city                        | string    | Departure city name of the trip                                                       |
| destination_city                   | string    | Destination city name of the trip                                                     |
| route                              | string    | Name of the route chosen by the driver                                                |
| car_model                          | string    | Car model of this trip                                                                |
| **Metrics**                        |           |                                                                                       |
| nb_seats                           | int       | Number of seats for carpooling set by the driver                                      |
| trip_distance_km                   | float     | Total distance of this trip in kilometers                                             |
| proposed_stops                     | array<string> | A list of possible intermediate stops chosen by the driver                            |
| recommend_price_per_seat           | float     | Recommended price of the carpooling fees of the whole trip for one rider              |
| customized_price_per_seat          | float     | Price of the carpooling fees of the whole trip for one rider customized by the driver |
| driver_rating                      | float     | The rating of the driver of this trip                                                 |


## Trip Ride Datamart
- **Description**: This datamart is used to analyse finished trips on environmental impact, riding demands and revenue
- **Freshness**: Daily (Updated at HH:mm every day to have D-1 data)
- **Granularity**: Trip (trip_id)
- **Partition & Expiration**: Partitioned by and expires in xx days
- **Clustering Columns**: country, origin_city, destination_city, route
### Schema
| Column                            | Type      | Description                                                                              |
|-----------------------------------|-----------|------------------------------------------------------------------------------------------|
| **Dimensions**                    |           |                                                                                          |
| PARTITIONING FIELD: depature_date | date      | Departure date of the trip                                                               |
| trip_id                           | string    | Id of the trip                                                                           |
| country*                          | string    | Country of this trip                                                                     |
| origin_city*                      | string    | Departure city name the of trip                                                          |
| destination_city*                 | string    | Destination city name of the trip                                                        |
| route*                            | string    | Name of the route chosen by the driver                                                   |
| **Metrics**                       |           |                                                                                          |
| nb_requests                       | int       | Number of requests this trip have received                                               |
| nb_riders                         | int       | Number of riders(passengers) actually took this carpooling trip                          |
| occupancy_rate                    | float     | nb_riders/nb_seats; Can be also defined as total_ride_distance/(nb_seats\*trip_distance) |
| ride                              | record<array> | Nested field for rides of the trip                                                       |
| - ride_origin_city                | string    | Departure city of a ride                                                                 |
| - ride_destination_city           | string    | Destination city of a ride                                                               |
| - ride_distance_km                | float     | Distance of the ride                                                                     |
| - ride_status                     | string    | Status of the ride (ongoing, declined, finished, etc.)                                   |
| trip_distance_km                  | float     | Total distance of this trip in kilometers                                                |
| total_co2_saved                   | float     | Total CO2 saved of this trip (Calculated with some metrics on ride_distance_km)          |
| total_trip_revenue                | float     | The gross revenue of this trip (sum of all ride_price)                                   |
| average_trip_ratings              | float     | Average of all the ratings that riders gave to this trip                                 |


## CRM Datamart
- **Description**: This datamart enrich the OLTP user table. It is used to analyse blablacar users, their activities, earnings within a certain period of time
- **Freshness**: Daily (Updated at HH:mm every day)
- **Granularity**: User (user_id)
- **Partition & Expiration**: Not partitioned, each dag run overwrites the table
- **Clustering Columns**: country, origin_city, destination_city, route
- Getting the metrics of all the user is computationally expensive and probably not scalable, we can filter on chose users that interest us
### Schema
| Column                    | Type   | Description                                                    |
|---------------------------|--------|----------------------------------------------------------------|
| **Dimensions**            |        |                                                                |
| user_id                   | int    | The date when the trip offer is published                      |                                                              |
| user_name                 | string | Name of the user                                               |
| country*                  | string | Country of the user                                            |
| telephone                 | string | Telephone number of the user                                   |
| email                     | string | Email address of the user                                      |
| **Metrics**               |        |                                                                |
| last_trip_date            | date   | Last date when the user offered a trip                         |
| last_ride_date            | date   | Last date when the user took a ride                            |
| nb_trips                  | int    | Number of trips the user offered in the given time period      |
| nb_rides                  | int    | Number of rides the user took in the given time period         |
| total_trip_km             | int    | Number of trips the user offered in the given time period      |
| total_ride_km             | int    | Number of rides the user took in the given time period         |
| earnings                  | float  | Earnings the user made through offering trips                  |
| expenses                  | float  | Expenses the user spent on taking rides                        |
| nb_ratings_received       | int    | Number of ratings the driver received from others              |
| nb_ratings_given          | int    | Number of ratings the driver gave for others                   |
| avg_ratings               | float  | Average rating of this user                                    |
| avg_customized_price_diff | float  | Average customized price difference the user set for its trips |
*\* are clustering fields*

# Modelling process
![Modelling lineage](https://github.com/dragonlee97/blablacar_exercise/blob/main/images/modelling.png?raw=true)

