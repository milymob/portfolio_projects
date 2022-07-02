/*
CYCLISTIC DATA PROJECT 
this is a self-driven data project to showcase my data analytics skills to potential employers.

SKILLS USED: aggregate functions, creating views, optimized SQL queries, cleaning data 


SCENARIO: Cyclistic is a bike-share company based in Chicago. The director of Marketing
believes the company's future success depends on maximizing the number of annual memberships.

GOAL: Figure out a way to get casual members to convert to annual members.

QUESTIONS: 
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic's annual membership? 
3. How can Cyclistic use digital media to influence casual riders to become members? 

DATASET: made available by Motivate International Inc under the license: https://www.divvybikes.com/data-license-agreement (Lyft Bikes and Scooters, LLC (“Bikeshare”) operates the City of Chicago’s (“City”) Divvy bicycle sharing service)
*/

-- create table and columns. import CSV file. view data.
SELECT * 
FROM cyclistic

-- begin editing, manipulating, and cleaning data 
SELECT DISTINCT(member_casual) --checking that we only have 'member' and 'casual' values in this column
FROM cyclistic

SELECT COUNT(DISTINCT ride_id) --seeing how many rides were logged (634,851)
FROM cyclistic

SELECT DISTINCT(rideable_type) --checking that we only have the 3 offered values of rideable_types 
FROM cyclistic

-- create a view that includes the calculated ride_length for each trip for further analysis
CREATE VIEW cyclistic_ride_length AS
SELECT (ended_at - started_at) AS ride_length, *
FROM cyclistic
WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL
ORDER BY ride_length DESC

SELECT *
FROM cyclistic_ride_length

SELECT MAX(ride_length)
FROM cyclistic_ride_length --maximum ride logged was 7 days 10 hours 42 minutes 

SELECT MIN(ride_length)
FROM cyclistic_ride_length --minimum ride logged was 0

--here we are calculating the average ride length when the start and end stations are the same 
CREATE VIEW start_end_equal AS 
SELECT start_station_name, end_station_name, AVG(ride_length) AS avg_start_end_equal 
FROM cyclistic_ride_length
WHERE start_station_name = end_station_name
GROUP BY 1, 2 
ORDER BY avg_start_end_equal DESC
--we can see that the 'Vernon Ave & 79th St' station holds the record for highest ride_length on average at 7hr 15min

--here we can get an idea of the average ride length when the start and end stations are not the same 
CREATE VIEW start_end_diff AS 
SELECT start_station_name, end_station_name, AVG(ride_length) AS avg_start_end_notequal 
FROM cyclistic_ride_length
WHERE start_station_name <> end_station_name
GROUP BY 1, 2 
ORDER BY avg_start_end_notequal DESC
--we can see that the longest ride where the start and end stations are not equivalent was 7days, 10hr, 42min

--calculating the average ride length total when start and end stations are the same (32min)
SELECT AVG(ride_length) 
FROM cyclistic_ride_length
WHERE start_station_name = end_station_name

--calculating the average ride length total when start and end stations are not the same (18min)
SELECT AVG(ride_length) 
FROM cyclistic_ride_length
WHERE start_station_name <> end_station_name

-- calculating average ride_length for casual users and members and saving the values in a view
CREATE VIEW avg_ride_member AS 
SELECT AVG(cyclistic_ride_length.ride_length) AS average_ride_member
FROM cyclistic_ride_length
WHERE member_casual = 'member' --the average ride_length for members is 13min

CREATE VIEW avg_ride_casual AS 
SELECT AVG(cyclistic_ride_length.ride_length) AS average_ride_casual
FROM cyclistic_ride_length
WHERE member_casual = 'casual' --the average ride_length for casual users is 27min

-- creating an easy-to-read weekday view for later data visualizations
CREATE VIEW cyclistic_weekday AS
SELECT ride_id, rideable_type, start_station_name, start_station_id, end_station_name, end_station_id, member_casual, ride_length
    , CAST(TO_CHAR(started_at, 'DAY')as text) as "start_weekday"
    , CAST(TO_CHAR(ended_at, 'DAY')as text) as "end_weekday"
FROM cyclistic_ride_length
WHERE start_station_name IS NOT NULL
    AND end_station_name IS NOT NULL

-- calculating mean ride_length for all users and mode of the weekday. creating a view for later visualizations
CREATE VIEW avg_ride_by_week AS 
SELECT AVG(ride_length) AS average_ride_wk, start_weekday
FROM cyclistic_weekday
GROUP BY start_weekday
ORDER BY average_ride_wk DESC

SELECT *
FROM avg_ride_by_week


-- calculating mean ride_length and mode of the weekday for casual users and creating a view
CREATE VIEW avg_ride_wk_casual AS 
SELECT AVG(ride_length) AS average_ride_casual, start_weekday
FROM cyclistic_weekday
WHERE member_casual = 'casual'
GROUP BY start_weekday
ORDER BY average_ride_casual DESC

SELECT *
FROM avg_ride_wk_casual

--calculating mean ride_length and mode of the weekday for members and creating a view 
CREATE VIEW avg_ride_wk_member AS 
SELECT AVG(ride_length) AS average_ride_member, start_weekday
FROM cyclistic_weekday
WHERE member_casual = 'member'
GROUP BY start_weekday
ORDER BY average_ride_member DESC

SELECT *
FROM avg_ride_wk_member

-- calculating the number of rides by user type 
--first, we will calculate the total count of rides logged (634,851)
SELECT COUNT(DISTINCT (ride_id)) 
FROM cyclistic

CREATE VIEW casual_ride_count AS
SELECT COUNT(ride_id), member_casual 
FROM cyclistic
WHERE member_casual = 'casual' 
GROUP BY 2 --number of rides logged by casual users is 280,415

CREATE VIEW member_ride_count AS
SELECT COUNT(ride_id), member_casual
FROM cyclistic
WHERE member_casual = 'member' 
GROUP BY 2 --number of rides logged by members is 354,443

-- we have gained a lot of good insights through the queries and views we have created from the original dataset
-- let's load the views into Tableau so we can get good visuals for our stakeholders