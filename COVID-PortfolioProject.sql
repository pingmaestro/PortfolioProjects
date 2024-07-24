SELECT *
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE continent is not NULL
  ORDER BY 3,4

-- SELECT *
  -- FROM [PortfolioProject].[dbo].[CovidVacci]
  -- ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  ORDER BY 1, 2



-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths,(CONVERT(float, total_deaths)/ NULLIF(CONVERT(float, total_cases),0))*100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE location LIKE 'Canada'
  AND continent is not NULL
  ORDER BY 1, 2

-- About the CONVERT code: I had a lot of troubles importing the .csv file in Azure Data Studio
    -- the Import Wizard kept populating the data types with erronous type due to a considerable numbers of NULL in the first 1000 rows and also working on a Mac >_<

-- Looking at Total Cases vs Population
-- Shows the percentage of population got COVID

SELECT location, date, total_cases, Population,(CONVERT(float, total_cases)/ NULLIF(CONVERT(float, Population),0))*100 AS InfectionRate
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE location LIKE 'Canada'
  ORDER BY 1, 2

-- Looking at Countries with highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (CONVERT (float, MAX(total_cases))/ NULLIF(CONVERT(float, MAX (Population)),0))*100 AS HighestInfectionRate
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  GROUP BY location, Population
  ORDER BY HighestInfectionRate DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(total_deaths) AS TotalDeathCount
    FROM [PortfolioProject].[dbo].[CovidDeaths]
    WHERE continent is not NULL
    GROUP BY location, Population
    ORDER BY TotalDeathCount DESC

-- Now breaking the data by Continents

SELECT continent, MAX(total_deaths) AS TotalDeathCount
    FROM [PortfolioProject].[dbo].[CovidDeaths]
    WHERE continent is not NULL
    GROUP BY continent
    ORDER BY TotalDeathCount DESC

-- Showing continent with the highest Deaths Count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
    FROM [PortfolioProject].[dbo].[CovidDeaths]
    WHERE continent is not NULL
    GROUP BY continent
    ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
-- ******** Ce bout de code ne foncitonne pas correctement, il semble faire un SUM par semaine****
SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_deaths, 
    --SUM(new_deaths) / NULLIF(SUM(new_cases) * 1.0, 0) * 100 AS DeathPercentage
    SUM(new_deaths) / NULLIF(CAST(SUM(new_cases) AS FLOAT), 0) * 100 AS DeathPercentage
  FROM [PortfolioProject].[dbo].[CovidDeaths]
  WHERE continent is not NULL
 -- GROUP BY date
  ORDER BY 1, 2

-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
    dea.date) AS RollingCountPeopleVaccinated
--, (RollingCountPeopleVaccinated/population)*100
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
  WHERE dea.continent is not NULL 
  ORDER BY 2,3

-- USE a CTE

WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingCountPeopleVaccinated)
AS
    (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
    dea.date) AS RollingCountPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not NULL 
    )

SELECT *, (RollingCountPeopleVaccinated/CAST (Population AS FLOAT))*100 AS RollingPeopleVaccinatedPercentage
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingCountPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
    dea.date) AS RollingCountPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not NULL 

SELECT *, (RollingCountPeopleVaccinated/CAST (Population AS FLOAT))*100 AS RollingPeopleVaccinatedPercentage
FROM #PercentPopulationVaccinated

-- CREATE A VIEW TO STORE DATA FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
    , SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
    dea.date) AS RollingCountPeopleVaccinated
    FROM PortfolioProject..CovidDeaths dea
    JOIN PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent is not NULL
