--Covid 19 Data Exploration 

--Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

Select *
From PortfolioProject..CovidDeaths
ORDER BY 3,4


Select *
From PortfolioProject..CovidVaccinations
ORDER BY 3,4


--Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2

--Shows Likelihood of Dying if you contract covid in your Country(US)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2


--Looking at Total Cases vs Population(US)
-Shows what percentage of population got covid
Select Location, date,population, total_cases,  (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
ORDER BY 1,2


--Shows Likelihood of Dying if you contract covid in your Country(Turkey)
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%turkey%'
ORDER BY 1,2


--Looking at Total Cases vs Population(Turkey)
Select Location, date, population,total_cases,  (total_cases/population)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%turkey%'
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population,MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
SELECT Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC


--Break things down by continent
SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Showing Continents with the Highest Death Count per Population
SELECT continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) as TotalCase, SUM(cast(new_deaths as int)) as TotalDeath, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Joing CovidDeaths and  CovidVaccinations
SELECT *
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date


--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by  dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated )
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by  dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by  dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT (int,vac.new_vaccinations)) OVER (Partition by  dea.location Order By dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select *
From PercentPopulationVaccinated