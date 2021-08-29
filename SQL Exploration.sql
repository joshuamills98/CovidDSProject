Select *
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 3,4

-- Looking at total cases vs. total deaths (how many deaths do they have per x number of cases?) for Australia


Select Location, date, total_cases, total_deaths, population, 100*total_deaths/total_cases as death_percentage
From PortfolioProject..CovidDeaths$
Where Location = 'Australia'
AND continent is not null
order by 1,2

-- Looking at Total Cases vs. Population for Australia

Select Location, date, total_cases, total_deaths, population, (100*total_cases/population) as case_percentage 
From PortfolioProject..CovidDeaths$
Where Location = 'Australia'
AND continent is not null
order by 1,2

-- almost 0.2% of Australians have had COVID as of the end of August 2021, not very high natural immunity


-- Countries with the highest infection rates compared to population?

Select Location, Population, MAX(total_cases) as highest_infection_count, MAX(100*total_cases/population) as percent_population_infected 
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location, Population
order by percent_population_infected DESC


-- Showing countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_death_count, MAX(100*cast(total_deaths as int)/population) as percentage_total_death_count
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by Location
order by percentage_total_death_count DESC

-- Continental breakdown

Select Location, MAX(cast(total_deaths as int)) as total_death_count, MAX(100*cast(total_deaths as int)/population) as percentage_total_death_count
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
order by percentage_total_death_count DESC

-- Global numbers - total rate

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 100*SUM(cast(new_deaths as int))/SUM(new_cases) as case_death_percentage--(total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
order by 1,2

-- global numbers - trajectory

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 100*SUM(cast(new_deaths as int))/SUM(new_cases) as case_death_percentage--(total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths$
Where continent is not null
Group By date
order by 1,2

-- case death percentage a little over 2%

-- Joining death and vaccination lables primary key is composed of multible keys: date and location (both should be sufficient to uniquely identify each row)
-- Look at vaccine doses administered per 100 people (this can not be used to give an inidication of total % vaccination rates)
With PopvsVac (Continent, location, date, population, new_vaccinations, rolling_vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int),
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations --first you partition by segmented group, then you order it so it becomes a rolling sum
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null
)
Select *, (rolling_vaccinations/population)*100 as vax_per_100_people
From PopvsVac
Where location = 'Australia'

-- Create a new view of vaccination rate per 100 people (use a temp table method)

Create View VaccinationRate as 
With PopvsVac (Continent, location, date, population, new_vaccinations, rolling_vaccinations)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, cast(vac.new_vaccinations as int),
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations --first you partition by segmented group, then you order it so it becomes a rolling sum
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.date = vac.date
and dea.location = vac.location
Where dea.continent is not null
)
Select *, (rolling_vaccinations/population)*100 as vax_per_100_people
From PopvsVac


-- This can now be used for visualization later

Select *
From VaccinationRate