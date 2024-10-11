--Explore data
select *
from PortfolioProject..CovidDeaths
order by 1,2
-----------------------------------------------------------------------

--select data we will use
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2
-----------------------------------------------------------------------

--Total cases vs Total Deaths
select location, date, total_cases, total_deaths, 
case 
when total_cases=0 then 0
else (total_deaths/total_cases)*100
end as DeathPercentage
--(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where total_cases != 0
order by 1,2
-----------------------------------------------------------------------

--Total cases vs Population
--Percentage of population infected
select location, date, population, total_cases, (total_cases/population)*100
from PortfolioProject..CovidDeaths
order by 1,2
-----------------------------------------------------------------------

--Countries with highst infection rate compared to population
select location, population, max(total_cases) as highestInfectionCount, max((total_cases/population)*100) as populationInfectedPercentage
from PortfolioProject..CovidDeaths
group by location, population
order by populationInfectedPercentage desc
-----------------------------------------------------------------------

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc
-----------------------------------------------------------------------

--Showing continent with the highest death count per population
select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc
-----------------------------------------------------------------------

--Statisticals per each date: total cases, total deaths, percentage of deaths comparing to total cases
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths 
, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
from PortfolioProject..CovidDeaths
where new_cases != 0
and continent is not null
group by date
order by 1,2
-----------------------------------------------------------------------

--Total population vs vaccinations
--RollingPeopleVaccinated is the cumulative count of vaccinated individuals.
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.date not like '%2024%' 
and dea.date not like '%2023%' 
and dea.date not like '%2022%'
and dea.date not like '%2020%'
and dea.continent is not null
order by 2,3
-----------------------------------------------------------------------

--Calculate the percentage of vaccinated individuals compared to the total population using the cumulative count, this can be achieved by any of the below
--#option1 Using CTE
with popvsVaccRolling
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.date not like '%2024%' 
and dea.date not like '%2023%' 
and dea.date not like '%2022%'
and dea.date not like '%2020%'
and dea.continent is not null
--order by 2,3
)
select *, (rollingPeopleVaccinated/population)*100 as percentgeVaccinated
from popvsVaccRolling
-----------------------------------------------------------------------

--#option2 Using Temp table
DROP Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.date not like '%2024%' 
and dea.date not like '%2023%' 
and dea.date not like '%2022%'
and dea.date not like '%2020%'
and dea.continent is not null
--order by 2,3


select *, (rollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
-----------------------------------------------------------------------

--Create view for later visualization
create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations --per day
,sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as rollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.date not like '%2024%' 
and dea.date not like '%2023%' 
and dea.date not like '%2022%'
and dea.date not like '%2020%'
--and vac.new_vaccinations is not NULL
and dea.continent is not null
--order by 2,3