-- **Abdallah Nasser SQL Project on Covid19 Dataset**

SELECT * FROM PortfolioProject.dbo.CovidDeaths Order By 3,4

--SELECT * FROM PortfolioProject..CovidVaccination Order By 3,4

/*********************************************************************/

--Selecting Data Iam Going To Use 

SELECT location, date,total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

/*********************************************************************/

-- SELECTING  TOTAL_CASES VS TOTAL_DEATHS

SELECT location, date,total_cases, total_deaths , (CAST(total_deaths AS decimal)/total_cases)*100 AS PERCENTFORDEATH
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%u%states'
ORDER BY 1,2

/*********************************************************************/

-- SELECTING  TOTAL_CASES VS POPULATION
-- SHOW THE PERCENTAGE OF PEOPLE GOT COVID

SELECT location, date, population,total_cases , (total_cases/population)*100 AS PERCENTFORDEATH
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%u%states'
ORDER BY 1,2
/*********************************************************************/

-- SHOW THE MOST INFECTION RATE COMPARED TO POPULATION
SELECT LOCATION, POPULATION, 
MAX(CAST(total_cases AS INT)) AS MAX_CASES, 
MAX((CAST(total_cases AS DECIMAL)/CAST(population AS DECIMAL)))*100 AS INFECTION_RATE 
FROM PortfolioProject..CovidDeaths
--WHERE LOCATION  LIKE '%states%'
GROUP BY LOCATION, POPULATION
ORDER BY INFECTION_RATE DESC
/*********************************************************************/

--SHOWING COUNTRIES WITH HIEGHEST DEATH COUNT PER POPULATION

SELECT location , MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
FROM PortfolioProject..CovidDeaths
WHERE continent IS  NOT NULL AND  LOCATION NOT LIKE '%WORLD%'
GROUP BY location
ORDER BY 2 DESC

/*********************************************************************/

--BREAK DOWN BY CONTINENT

-- SHOWING CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location , MAX(CAST(total_deaths AS INT)) AS TOTAL_DEATHS
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL AND  LOCATION NOT LIKE '%INCOME%'
GROUP BY location
ORDER BY 2 DESC

/*********************************************************************/

-- GLOBAL NUMBERS (AROUND THE WORLD)

SELECT
SUM(new_cases) AS TOTAL_CASES,
SUM(CONVERT(DECIMAL, new_deaths)) AS TOTAL_DEATHS,
SUM(CAST(new_deaths AS DECIMAL)) /SUM(new_cases) * 100 AS TOTAL_DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL

/*********************************************************************/
-- SHOWING MAX PERCENTAGE OF DEATHS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
/***************_Cummulative Sum_*********************/
Select LOCATION, DATE , NEW_CASES, SUM(new_cases) OVER (order by date, location) as total_cases
From PortfolioProject..CovidDeaths
--Where location like '%states%'
--where continent is not null 
--Group By date
order by date
/************************************/
-- JOIN

SELECT  D.continent,D.location,D.DATE, D.population,V.new_vaccinations
FROM PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccination V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL-- AND D.LOCATION LIKE '%STATES%'
ORDER BY 3

/***************************************/

/*LOOKING AT TOTAL POPULATION VS VACCINANITONS*/

/* CUMMUALTIVE FOR ALL COLUMNS */
SELECT  D.continent,D.location,D.DATE, D.population,V.new_vaccinations ,
sum(cast(v.new_vaccinations as bigint)) over (order by  d.location,D.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccination V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL-- AND D.LOCATION LIKE '%STATES%'
ORDER BY 2,3



/*STARTING AGAIN WITH EACH COUNTRY USED (CUMMULATIVE FOR EVERY COUNTRY)*/
SELECT  D.continent,D.location,D.DATE, D.population,V.new_vaccinations ,
sum(cast(v.new_vaccinations as bigint)) over (PARTITION BY D.LOCATION order by  d.location,D.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths D
JOIN PortfolioProject..CovidVaccination V
ON D.location = V.location 
AND D.date = V.date
WHERE D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL-- AND D.LOCATION LIKE '%STATES%'
ORDER BY 2,3




-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
