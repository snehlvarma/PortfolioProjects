SELECT*
  FROM [Portfolio project].[dbo].[CovidDeaths]
  where continent is not null
  order by 3,4

  --SELECT*
  --FROM [Portfolio project].[dbo].[CovidVaccination]
  --order by 3,4

  -- Select data that we are going to be using 

  Select location, date , total_cases,new_cases, total_deaths, population
  from [Portfolio project].dbo.CovidDeaths
  order by 1,2

  -- Looking at total cases vs total deaths 
  Select location, date , total_cases,total_deaths, (total_deaths/total_cases)*100 as PercentPopulationInfected
  from [Portfolio project].dbo.CovidDeaths
  Where location like '%states%'
  and continent is not null
  order by 1,2

  -- Looking at total cases vs population
  -- Shows what percentage of population got covid 

  Select location, date, total_cases, population, (total_deaths/population)*100 as PercentPopulationInfected
  from [Portfolio project].dbo.CovidDeaths
  --Where location like '%states%'
  where continent is not null
  order by 1,2
  
  --Looking at countries with highest infection rate compared to population

  Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
  from [Portfolio project].dbo.CovidDeaths
  --Where location like '%states%'
  where continent is not null
  group by location, population
  order by PercentPopulationInfected desc

  --Showing the countries with highest death count per population 
    Select location, Max(cast(total_deaths as int)) as TotalDeathCount
  from [Portfolio project].dbo.CovidDeaths
  --Where location like '%states%'
  where continent is not null
  group by location
  order by TotalDeathCount desc
  
  --Breaking down by continent 
  Select location, Max(cast(total_deaths as int)) as TotalDeathCount
  from [Portfolio project].dbo.CovidDeaths
  --Where location like '%states%'
  where continent is null
  group by location
  order by TotalDeathCount desc

  -- Showing continents with highest death count per population
 
  Select location, Max(cast(total_deaths as int)) as TotalDeathCount
  from [Portfolio project].dbo.CovidDeaths
  --Where location like '%states%'
  where continent is not null
  group by location
  order by TotalDeathCount desc 


  --Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from [Portfolio project].dbo.CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from [Portfolio project].dbo.CovidDeaths dea
Join [Portfolio project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3
      





-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project].dbo.CovidDeaths dea
Join [Portfolio project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as percpeoplevaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project].dbo.CovidDeaths dea
Join [Portfolio project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3



Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio project].dbo.CovidDeaths dea
Join [Portfolio project].dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated
