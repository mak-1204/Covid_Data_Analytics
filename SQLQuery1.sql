
SELECT * FROM CovidDataAnalytics..CovidDeaths WHERE continent IS NOT NULL

--SELECT * FROM CovidDataAnalytics..CovidVaccinations
--ORDER BY 3,4



-- Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidDataAnalytics..CovidDeaths WHERE continent IS NOT NULL ORDER BY 1,2



-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in India
SELECT Location, date, total_cases,total_deaths, ROUND(total_deaths/total_cases*100,5) DeathPercentage FROM CovidDataAnalytics..CovidDeaths 
WHERE LOCATION LIKE '%India%' 
ORDER BY 1,2
 


 -- Loking at Total cases vs Population
 -- What percentage of Population got covid
 SELECT Location, date, total_cases,total_deaths,population, ROUND(total_cases/population*100,10) PercentagePopulationInfected FROM CovidDataAnalytics..CovidDeaths 
WHERE LOCATION LIKE '%India%'
ORDER BY 1,2
 


 -- Countries with highest Infection rate
 SELECT Location,MAX(population) HighestPopulation,MAX(total_cases) HighestInfectionCount,MAX(ROUND(total_cases/population*100,10)) AS PercentagePopulationInfected FROM CovidDataAnalytics..CovidDeaths 
 WHERE continent IS NOT NULL GROUP BY Location 
 ORDER BY 4 DESC



 -- Showing the countries with fighest death count per population
  SELECT Location,MAX(CAST(total_deaths AS INT)) TotalDeathCount FROM CovidDataAnalytics..CovidDeaths 
 WHERE continent IS NOT NULL GROUP BY Location
 ORDER BY 2 DESC



 -- LET'S BREAK THINGS DOWN BY CONTINENT

 -- This query is wrong coz it gives us the max death of country in that continent
 --  SELECT continent,SUM(CAST(total_deaths AS INT)) TotalDeathCount FROM CovidDataAnalytics..CovidDeaths 
 --WHERE continent IS NOT NULL GROUP BY continent
 --ORDER BY 2 DESC



  -- Showing continent with highest dath count
 SELECT location,SUM(CAST(total_deaths AS INT)) TotalDeathCount FROM CovidDataAnalytics..CovidDeaths 
 WHERE continent IS NULL GROUP BY location
 ORDER BY 2 DESC





 -- GLOBAL NUMBER


-- Death percentage by date
 SELECT date, SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage--,total_deaths, ROUND(total_deaths/total_cases*100,5) DeathPercentage 
 FROM CovidDataAnalytics..CovidDeaths 
WHERE continent IS NOT NULL
group by date
ORDER BY 1,2



-- Death percentage 
 SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage--,total_deaths, ROUND(total_deaths/total_cases*100,5) DeathPercentage 
 FROM CovidDataAnalytics..CovidDeaths 
WHERE continent IS NOT NULL AND location!='world'
ORDER BY 1,2
                              -- OR
 SELECT SUM(new_cases) TotalNewCases, SUM(CAST(new_deaths AS INT)) TotalNewDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 DeathPercentage--,total_deaths, ROUND(total_deaths/total_cases*100,5) DeathPercentage 
 FROM CovidDataAnalytics..CovidDeaths 
WHERE continent IS NULL 
ORDER BY 1,2

---- 
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
--TotalVaccinatedByLocationTillDate, ()
--FROM CovidDataAnalytics..CovidDeaths dea 
--JOIN CovidDataAnalytics..CovidVaccinations vac ON  dea.location=vac.location AND dea.date=vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3



-- use cte
WITH PopvsVac AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
TotalVaccinatedByLocationTillDate
FROM CovidDataAnalytics..CovidDeaths dea 
JOIN CovidDataAnalytics..CovidVaccinations vac ON  dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL)

SELECT *,(TotalVaccinatedByLocationTillDate/population)*100 VaccinatedPercentageByPopulation FROM PopvsVac 



-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated ( Continent nvarchar(255),location nvarchar(255), date datetime, population numeric, New_vaccinations numeric, TotalVaccinatedByLocationTillDate numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
TotalVaccinatedByLocationTillDate
FROM CovidDataAnalytics..CovidDeaths dea 
JOIN CovidDataAnalytics..CovidVaccinations vac ON  dea.location=vac.location AND dea.date=vac.date

SELECT *,(TotalVaccinatedByLocationTillDate/population)*100 VaccinatedPercentageByPopulation FROM #PercentPopulationVaccinated 

-- CREATE VIEW

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) 
TotalVaccinatedByLocationTillDate
FROM CovidDataAnalytics..CovidDeaths dea 
JOIN CovidDataAnalytics..CovidVaccinations vac ON  dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated