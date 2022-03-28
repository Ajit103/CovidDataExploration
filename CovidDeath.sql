SELECT * 
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..[Covid Vaccinations]
--ORDER BY 3,4

--Select Data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
ORDER BY 1,2


-- Total cases vs Total deaths
-- Shows the likelihood of dying if you contract covid in Canada

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentByCases
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
AND location like '%canada%' 
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Percentage of population who got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopnInfected
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
--WHERE location like '%canada%' 
ORDER BY 1,2

-- Countries with Highest infection rate compared to Population

SELECT location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopnInfected
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY location, population 
ORDER BY PercentPopnInfected DESC

-- Countries with Highest Death count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Continent with highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, 
	SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..[Covid Deaths]
WHERE continent is not null
--WHERE location like '%canada%'
GROUP BY date
ORDER BY 1,2


--Total popn vs vaccination
SELECT *
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
ON dea.location = vac.location 
AND dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as --Number of columns should be equal
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 from PopvsVac

--TEMP Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
Select *, (RollingPeopleVaccinated/population)*100 
from #PercentPopulationVaccinated


--Create View

Create View PercentPopnVaccn as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..[Covid Deaths] dea
JOIN PortfolioProject..[Covid Vaccinations] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null

