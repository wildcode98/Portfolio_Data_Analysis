--Data collected from source https://ourworldindata.org/covid-deaths

select * 
from PortfolioProject..CovidDeaths
order by 3,4;

--select * 
--from PortfolioProject..CovidVaccinations
--order by 3,4;

--Selecting data to be used

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2;

--Total cases vs Total deaths

select location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2;

--Total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
order by 1,2;

--Countries with highest Infection rate wrt population

select location, max(total_cases) as HighestInfectionCount, population, MAX((total_cases/population)*100) as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location, population
order by InfectedPercentage desc;

--Countries with highest death count 

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by location
order by HighestDeathCount desc;

--Continents with highest death count 

select location, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is NULL
group by location
order by HighestDeathCount desc;

--Continents with highest death count in a country

select continent, max(cast(total_deaths as int)) as HighestDeathCount
from PortfolioProject..CovidDeaths
where continent is not NULL
group by continent
order by HighestDeathCount desc;

--Global Numbers

select SUM(new_cases) as New_Cases_Today, SUM(cast(new_deaths as int)) as Total_Deaths_Today, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not NULL
--group by date
order by 1,2;

--Total population vs Vaccination (Using a CTE)

With PopVsVac (continent, location, date, population,new_vaccinations,Total_Vaccines_Given)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_Vaccines_Given
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3;
)
Select *, (Total_Vaccines_Given/population)*100 as Percent_Population_Vaccinated 
from PopVsVac

--Total population vs Vaccination (Using a Temp Table)

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Total_Vaccines_Given numeric
)

Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_Vaccines_Given
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3;

Select *, (Total_Vaccines_Given/population)*100 as Percent_Population_Vaccinated 
from #PercentPopulationVaccinated

--Creating a View for later visualization

Create view PercentPopVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) 
as Total_Vaccines_Given
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
--order by 2,3;

drop view PercentPopVaccinated
