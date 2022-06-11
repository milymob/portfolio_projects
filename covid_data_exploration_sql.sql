/* 
Covid-19 Data Exploration

Skills Used: joins, CTE's, temp tables, aggregate functions, creating views

*/

SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4

-- select data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- total_cases vs total_deaths
-- shows the likelihood of dying if you contract Covid-19 in your country
-- can add WHERE clause to filter by country; WHERE location = ''

CREATE VIEW mortality_rate_by_country AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- total_cases vs population 
-- shows what percentage of the population contracted Covid-19 in each country
-- can add WHERE clause to filter by country; WHERE location = ''

CREATE VIEW contraction_percentage_date AS 
SELECT location, date, population, total_cases, (total_cases/population)*100 AS contraction_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- countries with highest infection rate compared to population size 
-- can add WHERE clause to filter by country; WHERE location = ''

CREATE VIEW infection_percentage_by_country AS
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS highest_infection_percentage
FROM covid_deaths
WHERE continent IS NOT NULL 
--WHERE location = 'United States'
GROUP BY location, population
ORDER BY highest_infection_percentage DESC

-- countries with the highest death count per population

CREATE VIEW death_count_by_country AS
SELECT location, MAX(total_deaths) AS highest_death_count
FROM covid_deaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY highest_death_count DESC 

-- BREAKING THINGS DOWN BY CONTINENT
-- highest death count by continent

CREATE VIEW death_count_by_continent AS
SELECT location, MAX(total_deaths) AS highest_death_count
FROM covid_deaths
WHERE continent IS  NULL 
GROUP BY location
ORDER BY highest_death_count DESC 

-- GLOBAL NUMBERS 
-- showing global totals of new_cases and new_deaths by each day

CREATE VIEW global_death_percentage AS
SELECT date, SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2
-- to get an overall total as of 04/30/2021, eliminate date in SELECT and GROUP BY clauses
-- we will also create a view for later data vizs 
CREATE VIEW world_totals AS
SELECT SUM(new_cases) AS global_new_cases, SUM(new_deaths) AS global_new_deaths, (SUM(new_deaths)/SUM(new_cases))*100 AS global_death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2


-- MOVING ON TO covid_vaccinations DATASET 

SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date 
    
-- looking at total population vs vaccinations 

-- shows us a rolling number of people vaccinated on each day, but we want vax vs pop, so we need to create a temp table 
-- since we can use a new column we create, sum_vaccinations, to run a query (must create a new table with that column in order to extract that data)
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USE CTE

-- we are creating a CTE to be able to use our new sum_vaccinations column to get a percentage of vaccinated people per population

WITH pop_vs_vax (continent, location, date, population, new_vaccinations, sum_vaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (sum_vaccinations/population)*100 AS vax_percentage
FROM pop_vs_vax

-- another way to achieve the same results is to create table and then a view from that table
-- USING TABLE & VIEWS

CREATE TABLE pop_vs_vax AS
SELECT dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations, 
    SUM(vax.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS sum_vaccinations
FROM covid_deaths dea
JOIN covid_vaccinations vax
    ON dea.location = vax.location
    AND dea.date = vax.date
WHERE dea.continent IS NOT NULL
 -- and now, using this view to complete a query to get the percentage of vaccinated people in a countries population 
CREATE VIEW percent_pop_vax AS
SELECT *, (sum_vaccinations/population)*100 AS vax_percentage
FROM pop_vs_vax








