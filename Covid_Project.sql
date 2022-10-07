/*

Dien Vo
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidDeaths
Order by 2;

SELECT *
FROM CovidVaccination
Order by 3,4;

-- Select Data SELECT and view data 

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null 
order by 1,2;

-- Total case vs total death
-- Shows total case and total deaths 

Select total_cases, total_deaths
From CovidDeaths
WHERE total_cases is NOT NULL and total_deaths is Not NULL
order by 1,2;

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage, population
From PorfolioProject
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in my country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%viet%'
and continent is not null 
order by 1,2 

--- Total Cases vs Population
--- Showing what percentage of Vietnamese got Covid
Select total_cases,location, population , (total_cases/population) * 100 AS Percentage_Population
From CovidDeaths
WHERE total_cases is NOT NULL  
AND population IS NOT NULL
AND location like '%viet%'
order by 1;

--- Showing what percentage of Global got Covid

Select total_cases,location, population , (total_cases/population) * 100 AS Percentage_Population
From CovidDeaths
WHERE total_cases is NOT NULL  
AND population IS NOT NULL
order by 1;

Select location, population , MAX(total_cases) as Highest_Infection_rate
From CovidDeaths
WHERE total_cases is NOT NULL  
AND population IS NOT NULL
GROUP BY location, population
order by 3 DESC;

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count 

Select Location, MAX(Total_deaths) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Convert to interger for more accurate data (error with total_death data type)

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Countries with Highest Death Count 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- Total death by continent

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- or

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is null 
AND location NOT LIKE '%income%'
Group by location
order by TotalDeathCount desc


-- Countries with Highest Death Count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Global statistic 

Select date, SUM(new_cases) as Total_case,SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not null 
GROUP BY date 
order by 1,2 

-- Total_case vs total_death

Select  SUM(new_cases) as Total_case,SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as DeathPercentage
From CovidDeaths
Where continent is not null 
order by 1,2 

-- Joining table 
--Looking at total population and Vaccination 

Select dea.continent, dea.date,dea.population, vac.new_vaccinations
FROM CovidDeaths as dea JOIN CovidVaccination as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
Where dea.continent is not null  
ORDER BY 1,2,3


-- Shows total new vaccine and total vacinated by locations 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3;

-- Create temp table/ CTE

With Temp_table(continent, location, date,population,new_vaccinations, Total_vaccinated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS Total_vaccinated
FROM CovidDeaths as dea
JOIN CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
)
SELECT* , (Total_vaccinated/population)*100 as Percentage_vaccinated
FROM Temp_table

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists PercentagePopulationVaccinated
Create Table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccinated numeric
)

Insert into PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_vaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

Select *, (Total_vaccinated/Population)*100 as percentage
From PercentagePopulationVaccinated

-- Create view to store data

DROP Table if exists PercentagePopulationVaccinated

CREATE VIEW PercentagePopulationVaccinated
AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Total_vaccinated
From CovidDeaths as dea
Join CovidVaccination as vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not NULL

SELECT * 
FROM PercentagePopulationVaccinated