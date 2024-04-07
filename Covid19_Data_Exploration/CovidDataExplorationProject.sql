select * from CovidDataExplorationProject..CovidDeaths
where continent is not null
order by 3,4;


-- select *
--from CovidDataExplorationProject..CovidVaccinations
--order by 3,4 

select location, date, total_cases, new_cases, total_deaths, population
from CovidDataExplorationProject..CovidDeaths
where continent is not null
order by 1,2

--Total Cases vs Total Deaths//United States
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from CovidDataExplorationProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--Total Cases vs Population
select location, date, population, total_cases, (total_cases/population) * 100 AS PercentagePopulationInfected
from CovidDataExplorationProject..CovidDeaths
--where location like '%states%'
--where continent is not null
order by 1,2


--Highest Infection rate and HighestPercentagePopulationInfection
select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population) * 100 AS PercentagePopulationInfected
from CovidDataExplorationProject..CovidDeaths
--where location like '%states%'
group by location, population
order by PercentagePopulationInfected Desc


--Showing countries with highest death count population

select location, Max(cast(total_deaths as INT)) as TotalDeathCount
from CovidDataExplorationProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by location
order by TotalDeathCount Desc


--Let's Break the same thing with respect to continent

--COntinents with highest death count per population
select continent, Max(cast(total_deaths as INT)) as TotalDeathCount
from CovidDataExplorationProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount Desc




---GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDataExplorationProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations // using covid vaccinations table join with covid deaths
-- Shows Percentage of Population that has recieved at least one Covid Vaccine


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100//we cannot run immediately by created column
From CovidDataExplorationProject..CovidDeaths as dea
Join CovidDataExplorationProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query // 
--CTE stands for Common Table Expression. It's a temporary named result set that you can reference within a SELECT, INSERT, UPDATE, or DELETE statement. It's defined within the execution scope of a single SELECT, INSERT, UPDATE, or DELETE statement. In your query, PopvsVac is the name given to the Common Table Expression.

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDataExplorationProject..CovidDeaths dea
Join CovidDataExplorationProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PerPeopleVaccinated
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
From CovidDataExplorationProject..CovidDeaths dea
Join CovidDataExplorationProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
--Select *, (cast(RollingPeopleVaccinated as decimal)/cast(Population as decimal))*100
--From #PercentPopulationVaccinated

SELECT *, (CAST(RollingPeopleVaccinated AS DECIMAL) / NULLIF(CAST(Population AS DECIMAL), 0)) * 100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated



-- Drop the temporary table if it exists
IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

-- Create the temporary table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,  
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Populate the temporary table
INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(DECIMAL(18, 2), vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    CovidDataExplorationProject..CovidDeaths dea
JOIN
    CovidDataExplorationProject..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- Query the temporary table with corrected division
SELECT
    *,
    CASE
        WHEN Population <> 0 THEN (CAST(RollingPeopleVaccinated AS DECIMAL(18, 2)) / Population) * 100
        ELSE NULL
    END AS PercentPopulationVaccinated
FROM
    #PercentPopulationVaccinated;








-- Creating View to store data for later visualizations
DROP VIEW IF EXISTS PercentPopulationVaccinated;

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDataExplorationProject..CovidDeaths dea
Join CovidDataExplorationProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--

SELECT * FROM PercentPopulationVaccinated;

