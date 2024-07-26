/*

Queries used for Tableau Project
Credit to : https://github.com/AlexTheAnalyst/
*/


-- 1. 
--- GL -> Adapted the DeathPercentage calculations since data type was slightly different

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
SUM(new_deaths) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0) * 100 AS DeathPercentage
    From PortfolioProject..CovidDeaths
    where continent is not null 
    order by 1,2


-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
--- GL -> Added the exclusion of '%income%' in the query

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
    From PortfolioProject..CovidDeaths
    Where continent is null 
    and location not in ('World', 'European Union', 'International')
    and location not like ('%income%')
    Group by location
    order by TotalDeathCount desc


-- 3.
--- GL -> Adapted the PercentPopulationInfected calculations since data type was slightly different

Select Location, Population, MAX(total_cases) as HighestInfectionCount,
(CONVERT (float, MAX(total_cases))/ NULLIF(CONVERT(float, MAX (Population)),0))*100 AS PercentPopulationInfected
    From PortfolioProject..CovidDeaths
    Group by Location, Population
    Order by PercentPopulationInfected desc


-- 4.
--- GL -> Adapted the PercentPopulationInfected calculations since data type was slightly different

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,
(CONVERT (float, MAX(total_cases))/ NULLIF(CONVERT(float, MAX (Population)),0))*100 AS PercentPopulationInfected
    From PortfolioProject..CovidDeaths
    Group by Location, Population, date
    Order by PercentPopulationInfected desc

