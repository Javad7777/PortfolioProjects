--Looking generally data
select * 
from ..CovidDeaths order by 3,4
select * 
from ..CovidVaccinations order by 3,4

--Select data that we are going using
Select 
location,date,total_cases,total_deaths,new_cases,population
from ..CovidDeaths
order by 1,2
--Looking at total cases,total deaths and them percentage
Select 
location,date,total_cases,total_deaths,
concat((total_deaths/total_cases)*100,'%') as Deathpercentage 
from ..CovidDeaths 
where location='Azerbaijan' 
order by 1,2 
--Looking at total cases,population and them Percentpopulationinfect
select 
location,date,total_cases,population, 
(total_cases/population)*100 as Percentpopulationinfect
from ..CovidDeaths order by 1,2
--Looking at countries with Highest infection rate compared to population
select
location, max(population) as HighestCount,
max((total_cases/population))*100 as Percentpopulationinfect 
from ..CovidDeaths group by location,population
order by Percentpopulationinfect desc
--Showing countries with highest deth count per population
select 
location,cast(max(total_deaths) as int) as TotalDethcount
from ..CovidDeaths
where continent is not null
group by location
order by TotalDethcount desc
--Global numbers
Select SUM(new_cases) as total_cases, 
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as Rollinvac from ..CovidDeaths as dea join ..CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null order by 2,3

--CTE
with cte(Continent,Location,Date,Population,New_vaccinations,Rollinvac)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as Rollinvac from ..CovidDeaths as dea join ..CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
) select *, (Rollinvac/Population)*100 as VacPer from cte

-- Using Temp Table to perform Calculation on Partition By in previous query
Drop table if exists #Percentagecal
Create Table #Percentagecal
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollinvac numeric)

insert into #Percentagecal
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) OVER(Partition by dea.location order by dea.location,dea.date) as Rollinvac from ..CovidDeaths as dea join ..CovidVaccinations as vac on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null 
--order by 2,3
select *,(Rollinvac/Population)*100 from #Percentagecal

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 