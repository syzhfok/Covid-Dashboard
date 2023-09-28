SQL Data Exploration
Dataset: Coronavirus (Covid-19) Deaths dataset from ourworldindata.org
Dataset source: https://ourworldindata.org/covid-deaths

1. Looking at total cases vs total deaths
-- Total Cases vs Total Deaths --
SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
ORDER BY 1,2

2a. Likelihood of dying if you get covid (USA)
-- Likelihood of dying from Covid if contracted --
SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE location = 'United States'
ORDER BY 1,2

2b (Germany)
SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE location = 'Germany'
ORDER BY 1,2

3. Percentage of population got Covid
--Shows what percentage of population got Covid --
SELECT
location,
date,
total_cases,
Population,
(total_cases/population)*100 as DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE location = 'Germany'
ORDER BY 1,2

4. Countries with Highest Infection Rate compared to Population
SELECT
Location,
Population,
MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM `tenacious-text-379818.project02.CovidDeaths`
GROUP by Location, population
order by PercentPopulationInfected desc

5. Countries with Highest Death Count per Population
SELECT
Location,
MAX(total_deaths) as TotalDeathCount
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

5c. more accurate numbers
SELECT
location,
MAX(total_deaths) as TotalDeathCount
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

6. Show continents with the highest death count by continent
SELECT
continent,
MAX(total_deaths) as TotalDeathCount
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

7. Global (40:45 in the video, replace the "location" by "continent" for queries above to have the drill-down effect by having layers)
SELECT
date,
SUM(new_cases) AS total_new_cases,
SUM(new_deaths) AS total_new_deaths,
CASE WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100 ELSE 0 END AS DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

7.b Global, over the entire time period
SELECT
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
CASE WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100 ELSE 0 END AS DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

8. Looking at total population vs vaccinations
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
FROM `tenacious-text-379818.project02.CovidDeaths` AS dea
JOIN `tenacious-text-379818.project02.CovidVaccinations` AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

8b. USE CTE 
WITH PopVSVac AS (
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM `tenacious-text-379818.project02.CovidDeaths` AS dea
JOIN `tenacious-text-379818.project02.CovidVaccinations` AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT
Continent,
location,
date,
population,
new_vaccinations,
RollingPeopleVaccinated,
(RollingPeopleVaccinated / population)*100
FROM PopVSVac;

8c. using TEMP TABLE
-- Create temporary table
CREATE TEMP TABLE TempPercentPopulationVaccinated AS
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER
(PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM `tenacious-text-379818.project02.CovidDeaths` AS dea
JOIN `tenacious-text-379818.project02.CovidVaccinations` AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- Query from temporary table
SELECT *,
(RollingPeopleVaccinated / population) * 100 AS PercentPopulationVaccinated
FROM TempPercentPopulationVaccinated;

9. Creating View
-- Creating View to store data for later visualizations
CREATE VIEW tenacious-text-379818.project02.PercentPopulationVaccinated AS
SELECT
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
SUM(vac.new_vaccinations)
OVER (PARTITION BY dea.location
ORDER BY dea.location,
dea.date
) AS RollingPeopleVaccinated
FROM `tenacious-text-379818.project02.CovidDeaths` AS dea
JOIN `tenacious-text-379818.project02.CovidVaccinations` AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

### Preparing my data containers for Tableau
tableau
1. Global death percentage
SELECT
SUM(new_cases) AS total_cases,
SUM(new_deaths) AS total_deaths,
CASE WHEN SUM(new_cases) > 0 THEN (SUM(new_deaths) / SUM(new_cases)) * 100 ELSE 0 END AS DeathPercentage
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent IS NOT NULL
ORDER BY 1,2;

2. Total Death Count by Continent
SELECT
location,
SUM(new_deaths) AS TotalDeathCount
FROM `tenacious-text-379818.project02.CovidDeaths`
WHERE continent IS null
AND location NOT IN ('World','European Union','International','High income','Upper middle income','Lower middle income','Low income')
GROUP BY location
ORDER BY TotalDeathCount desc

3. Percent of Population Infected
SELECT
location,
population,
MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM `tenacious-text-379818.project02.CovidDeaths`
GROUP BY
location,
population
ORDER BY PercentPopulationInfected desc
