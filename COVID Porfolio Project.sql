use citrinne

SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL;

-- Select data to use
SELECT d.location, d.date, d.total_cases, d.new_cases, d.total_deaths, d.population
FROM CovidDeaths$ d
ORDER BY d.location, d.date;

-- Looking at Total Cases vs Total Deaths
-- Shows likelhood of dying if you attract covid in your country.
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
--WHERE location like'%states%'
WHERE continent IS NOT NULL
ORDER BY location, date;

CREATE VIEW total_death_v_total_cases AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidDeaths$
--WHERE location like'%states%'
WHERE continent IS NOT NULL
--ORDER BY location, date;

-- Looking at Total Cases  vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidDeaths$
WHERE location like'%states%'
ORDER BY location, date;

CREATE VIEW deaths_v_population AS
SELECT location, date, total_cases, population, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidDeaths$
--WHERE location like'%states%'


-- Looking at countries with highest infection rate compared to population.
SELECT location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 AS Infection_Rate
FROM CovidDeaths$
GROUP BY location, population
ORDER BY Infection_Rate DESC

CREATE VIEW infection_rate AS 
SELECT location, MAX(total_cases) AS Highest_Infection_Count, population, MAX((total_cases/population))*100 AS Infection_Rate
FROM CovidDeaths$
GROUP BY location, population


-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS Total_Death
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death DESC

--Breaking things down by contient
SELECT continent, MAX(total_deaths) AS Total_Death
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death DESC;

SELECT location, MAX(total_deaths) AS Total_Death
FROM CovidDeaths$
WHERE continent IS NULL
GROUP BY location
ORDER BY Total_Death DESC;

-- Showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS Total_Death
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death DESC;

-- Global Numbers (originally had date at the start of the select statement and ordered by date and total cases calculated)
SELECT SUM(new_deaths) AS total_deaths_calculated, SUM(new_cases) AS total_cases_calculated, SUM(new_deaths)/SUM(new_cases)*100 AS death_percentage
FROM CovidDeaths$
--WHERE location like'%states%'
WHERE continent IS NOT NULL 
AND new_cases > 0
--GROUP BY date
ORDER BY total_cases_calculated;


SELECT *
FROM CovidVacinations2

-- Looking at total population vs vaccinations

SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_people_vaccinated
FROM CovidDeaths$ death,
(rolling_total_people_vaccinated/death.population)*100
JOIN CovidVacinations2 vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
ORDER BY  death.location, death.date;

-- USE CTE
WITH popvsvax (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_People_Vaccinated)
AS
(
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_people_vaccinated
--,(rolling_total_people_vaccinated/death.population)*100
FROM CovidDeaths$ death
JOIN CovidVacinations2 vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
--ORDER BY  death.location, death.date
)
SELECT *, (Rolling_Total_People_Vaccinated/Population)*100
FROM popvsvax

--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_Total_People_Vaccinated numeric)


INSERT INTO #percent_population_vaccinated
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_people_vaccinated
FROM CovidDeaths$ death
JOIN CovidVacinations2 vax
	ON death.location = vax.location
	AND death.date = vax.date
--WHERE death.continent IS NOT NULL

SELECT *, (Rolling_Total_People_Vaccinated/Population)*100 AS percentage_of_people_vaccinated
FROM  #percent_population_vaccinated


-- Creating view to store data for visualizations
CREATE VIEW percent_population_vaccinated AS
SELECT death.continent, death.location, death.date, death.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS rolling_total_people_vaccinated
--,(rolling_total_people_vaccinated/death.population)*100
FROM CovidDeaths$ death
JOIN CovidVacinations2 vax
	ON death.location = vax.location
	AND death.date = vax.date
WHERE death.continent IS NOT NULL
--ORDER BY  death.location, death.date

SELECT *
FROM percent_population_vaccinated;