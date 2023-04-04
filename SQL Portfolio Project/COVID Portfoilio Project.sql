SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4

--- Data we are going to start with 

SELECT location,date,total_cases,new_cases,total_deaths,new_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--- Total Cases vs Total Deaths

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%' AND continent IS NOT NULL
ORDER BY 1,2

--- Total Cases vs Population 

SELECT location,date,population,total_cases ,(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--- WHERE location LIKE '%India%' / --- WHERE location LIKE '%India%' AND IS NOT NULL
WHERE continent IS NOT NULL
ORDER BY 1,2

---- Country with Hihest Infection Rate Compared to Population

SELECT location,population,MAX (total_cases) as HighestInfectionCount ,MAX ((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--- WHERE location LIKE '%India%' AND IS NOT NULL
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY PercentagePopulationInfected DESC


---- Countries with Highest Death Count Compared to Population 

SELECT location,MAX (cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--- WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--- Data by Continent
--- Continent with highest deaths count 

SELECT continent,MAX (cast(total_deaths as int)) as TotalDeathCount 
FROM PortfolioProject..CovidDeaths
--- WHERE location LIKE '%India%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--- Global numbers Overall

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--- Global numbers Overall by Date

SELECT DATE, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths , 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage	
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--- Total Population vs Vaccination

SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--- USE CTE

WITH PopVsVac ( Continent , Location , Date , Poplation , New_vaccinations , RollingPeopleVaccinated )
as
(
SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * ,(RollingPeopleVaccinated/Poplation)*100  
FROM PopVsVac

--- Temp Table

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null

SELECT * ,(RollingPeopleVaccinated/Population)*100  
FROM #PercentPopulationVaccinated


--- Creating View to Store data for later Visualizations

CREATE VIEW PercentagePopulationVacinnated as
SELECT dea.continent, dea.location , dea.date , dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--- ORDER BY 2,3

SELECT * FROM PercentagePopulationVacinnated