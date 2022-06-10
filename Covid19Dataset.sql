Select * 
From CovidDeaths
Order by 3,4

--Select * 
--From CovidVaccinations
--Order by 3,4

-- Identifying My Most Relevant Data covering countries' infections --

Select location, date, total_cases, new_cases, total_deaths, population
From PersonalProjects..CovidDeaths
Where continent is not null
Order by 1,2

-- Finding Relation Between Total Cases and Total Deaths
-- Indicates likelihood of dying when infected --
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage  
From PersonalProjects..CovidDeaths
Where location like '%Kenya%'
Order by 1,2

-- Comparing Covid-19 Cases To Kenya's Population --

Select location, date, total_cases, population, (total_cases/population)*100 as infection_percentage  
From PersonalProjects..CovidDeaths
Where location like '%Kenya%'
Order by 1,2

-- Finding Which Country has the highest infected rate in terms of percentage --

Select location, population, Max(total_cases) as highest_infection, Max((total_cases/population))*100 as infection_percentage  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By Location, population
Order by infection_percentage Desc


-- Finding Countries With Highest Death Count --

Select location, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By Location, population
Order by highest_death_count Desc

-- Finding Regions/Continents With Highest Death Count --

Select location, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is null
Group By location
Order by highest_death_count Desc



-- Querying Using Continets Instead of location --

Select continent, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By continent
Order by highest_death_count Desc

-- Global Numbers By Date --
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as deathrate_percentage
from PersonalProjects..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Total Global Numbers --
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as deathrate_percentage
from PersonalProjects..CovidDeaths
where continent is not null

-- Joining The Covid Deaths Table to the Covid Vaccinations Table

Select * 
From PersonalProjects..CovidDeaths dea
Join PersonalProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date

-- Taking a look at global population vs Vaccinations--

Select dea.continent, dea.location, dea.date, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations, (SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100 as rolling_vaccination_percentage
From PersonalProjects..CovidDeaths dea
Join PersonalProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

-- Trying a Temp Table -- 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_total_vaccinations numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations
From PersonalProjects..CovidDeaths dea
Join PersonalProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

 Select * , (rolling_total_vaccinations/population)*100 as rolling_percentage_total
 From #PercentPopulationVaccinated


 -- Creating Views For Visualization In Tableau --
 --1. Cases and Deaths In Kenya --
 Create View CasesAndDeathsKenya as
 Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage  
From PersonalProjects..CovidDeaths
Where location like '%Kenya%'

--2. Covid-19 Cases against Population in Kenya --

Create View InfectionPopulationKenya as
Select location, date, total_cases, population, (total_cases/population)*100 as infection_percentage  
From PersonalProjects..CovidDeaths
Where location like '%Kenya%'

--3. countries with highest infection--

Create View highestIfectedCountries as
Select location, population, Max(total_cases) as highest_infection, Max((total_cases/population))*100 as infection_percentage  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By Location, population

--4. highest death count by country --

create view highestdeathcountbycountry as
Select location, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By Location, population

--5. region/continents with highest death count
create view continentsdeathcount as 
Select location, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is null
Group By location

--6. sames as five but using continet
create view deathcountcontinent as 
Select continent, Max(cast(total_deaths as Int)) as highest_death_count  
From PersonalProjects..CovidDeaths
Where continent is not null
Group By continent

-- 7. Global Numbers --
create view globalnumbers as 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) * 100 as deathrate_percentage
from PersonalProjects..CovidDeaths
where continent is not null

-- 8 global population vs vaccination numbers
create view globalvaccination as
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vaccinations, (SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)/population)*100 as rolling_vaccination_percentage
From PersonalProjects..CovidDeaths dea
Join PersonalProjects..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null