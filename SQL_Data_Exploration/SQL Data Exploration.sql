select *
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 3,4

--Covid 19 Data Exploration
--Skill used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Funtions, Creating Views, Converting Data Types

--Select data that i am going to be starting with:
Select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio Project]..CovidDeaths$
order by 1,2

--1) Total Cases vs Total Deaths
--Show likelihoo dof dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from [Portfolio Project]..CovidDeaths$
where location like '%state%'
and continent is not null
order by 1,2

--2) Total Cases vs Population
--Show what percentage of population infected with Covid

Select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
--where location like '%state%'
order by 1,2

--3) Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,
		max(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..CovidDeaths$
group by population, location
order by PercentPopulationInfected desc

--4) Countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by location
order by totaldeathcount desc


--5) Showing continents with the highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths$
where continent is not null
group by continent
order by totaldeathcount desc

--6)  Global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
	   sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercent
from [Portfolio Project]..CovidDeaths$
where continent is not null
order by 1, 2

--7) Population vs Vaccinations
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	   sum(cast(b.new_vaccinations as int)) over(partition by a. location order by a.location, a.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ a
join [Portfolio Project]..CovidVaccinations$ b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
order by 2,3

--8) Using CTE to perform calculation on Partition by previous query

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as (
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	   sum(cast(b.new_vaccinations as int)) over(partition by a. location order by a.location, a.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ a
join [Portfolio Project]..CovidVaccinations$ b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as Rolling_People_Vaccinated_per
from PopvsVac

--9) Using temp table to performc calculatin on partition in previous query
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated (
continent nvarchar (255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	   sum(cast(b.new_vaccinations as int)) over(partition by a. location order by a.location, a.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ a
join [Portfolio Project]..CovidVaccinations$ b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--10) Creating view to store data for later visualizations
create view PercentPopulationVaccinatedd as
select a.continent, a.location, a.date, a.population, b.new_vaccinations,
	   sum(cast(b.new_vaccinations as int)) over(partition by a. location order by a.location, a.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths$ a
join [Portfolio Project]..CovidVaccinations$ b
	on a.location = b.location
	and a.date = b.date
where a.continent is not null
