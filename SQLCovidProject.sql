Select *
From PortfolioProjectBeta..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From PortfolioProjectBeta..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProjectBeta..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjectBeta..CovidDeaths$
Where location like '%states%'
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentofPopulationInfected
From PortfolioProjectBeta..CovidDeaths$
--Where location like '%states%'
order by 1,2



--Looking at Countries with Highest Infection Rate compare to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
From PortfolioProjectBeta..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentofPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectBeta..CovidDeaths$
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc

--Breakdown by Continent

--Show continents with the highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjectBeta..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers


Select date, SUM(new_cases) as total_caes, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjectBeta..CovidDeaths$
--Where location like '%states%'
where continent is not null
Group By date
order by 1,2

--Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date)
 as RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/population)*100
From PortfolioProjectBeta..CovidDeaths$ dea
Join PortfolioProjectBeta..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, 
    dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
    From PortfolioProjectBeta..CovidDeaths$ dea
    Join PortfolioProjectBeta..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
    --order by 2,3
	)
	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

	--Temp Table

	DROP Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated numeric
	)



	Insert into #PercentPopulationVaccinated 
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, 
    dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
    From PortfolioProjectBeta..CovidDeaths$ dea
    Join PortfolioProjectBeta..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
    --order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated 

	--Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,   SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location, 
    dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
    From PortfolioProjectBeta..CovidDeaths$ dea
    Join PortfolioProjectBeta..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
	--where dea.continent is not null
    --order by 2,3

	Select *
	From PercentPopulationVaccinated
