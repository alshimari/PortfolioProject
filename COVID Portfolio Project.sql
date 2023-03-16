SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

--select data we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases*100) as Deathpercentage
FROM PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%canada%'
order by 1,2

-- Looking at total cases vs population
--shows what percentage of population got covid
SELECT Location, date,  population, total_cases, (total_deaths/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%canada%'
order by 1,2

-- looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%canada%'
group by Location, population
order by PercentagePopulationInfected DESC

-- showing countries with highest death count per population

SELECT Location, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%canada%'
group by Location
order by Totaldeathcount DESC

-- breakdown by continent 


--showing continents with highest death count

SELECT continent, MAX(cast(total_deaths as int)) as Totaldeathcount
FROM PortfolioProject..CovidDeaths$
where continent is not null
--where location like '%canada%'
group by continent
order by Totaldeathcount DESC


-- global numbers 

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM
	(new_cases)*100 as Deathpercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- looking at total population vs vaccinations

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
 as rollingpeoplevaccinated
-- , (rollingpeoplevaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3 


-- USING CTE 

With PopvsVac (Continent, Location, Date, Population,New_Vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
 as rollingpeoplevaccinated
-- , (rollingpeoplevaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)

SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
 as rollingpeoplevaccinated
-- , (rollingpeoplevaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *, (rollingpeoplevaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
 as rollingpeoplevaccinated
-- , (rollingpeoplevaccinated/population)*100
 From PortfolioProject..CovidDeaths$ dea
 JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated
