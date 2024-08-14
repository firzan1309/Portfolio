Select *
From PortofolioProject..CovidDeaths
Where continent is not null
order by 3,4

-- Select Data that we are going to be starting with
Select location, date, total_cases, new_cases, total_deaths, population
From PortofolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contact covid in Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
Where location like '%indonesia%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortofolioProject..CovidDeaths
Where location like '%indonesia%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
Select location, population, MAX(total_cases) as HIghestInfectionCount, Max((total_cases/population))*100 
as PercentPopulationInfected
From PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
Group by location, population
order by PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population
Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
Where continent is not null
Group by location
order by TotalDeathCount DESC



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From PortofolioProject..CovidDeaths
--Where location like '%indonesia%'
Where continent is not null
Group by continent
order by TotalDeathCount DESC


-- Global Numbers

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortofolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



--Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeepsVac
FROM  PopvsVac


--USE TEMP TABLE

DROP Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageRollingPeepsVac
FROM  #PercentagePopulationVaccinated



--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location
, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated