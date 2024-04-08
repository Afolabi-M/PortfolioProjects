SELECT *
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4;

SELECT	location,
		date,
		total_cases,
		new_cases,
		total_deaths,
		population
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 ;



--Looking at Total cases Vs Total Deaths
--Shows likelihood of dying if you contract COVID in your country

SELECT	location,
		date,
		total_cases,
		total_deaths,
		(total_deaths/total_cases) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%states%'
and continent IS NOT NULL
ORDER BY 1,2 ;

  

--Looking at the Total cases Vs Population
--Shows what percentage of population got COVID

SELECT	location,
		date,
		population,
		total_cases,
		(total_cases/population) * 100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2 ;

 

 --Looking at country with Highest Infection Rate compared to Population

SELECT	location,
		population,
		MAX(total_cases) AS HighestInfectionCount,
		MAX((total_cases/population)) * 100 AS PercentPopulationInfected
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;



--Showing the country with Highest Death Count per Population

SELECT	location,
		MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT	location,
		MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;


--Showing Continent with the Highest Death Count per Population

SELECT	continent,
		MAX(CAST (total_deaths AS INT)) AS TotalDeathCount
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- GLOBAL NUMBERS

SELECT	SUM(new_cases) AS Total_Cases,
		SUM(CAST(new_deaths AS INT)) AS Total_Deaths,
		SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS DeathPercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 ;


--Looking at Total Population Vs Vaccination

SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population) * 100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

SELECT *
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--USE CTE

With PopVsVac (continent, location, Date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population) * 100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population) * 100
FROM PopVsVac



--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR(225),
	Location NVARCHAR(225),
	Date DATETIME,
	Popluation NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population) * 100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Popluation) * 100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT	dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--, (RollingPeopleVaccinated/population) * 100
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated