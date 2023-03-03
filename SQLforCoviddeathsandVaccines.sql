SELECT *
FROM [dbo].[CovidDeaths]
order by 3,4

SELECT *
FROM [dbo].[CovidVaccines]
order by 3,4

-- SELECT DATA THAT WE ARE GOING TO BE USING 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 
SELECT location, date, total_cases,  total_deaths, (total_deaths / total_cases) *100 as Death_pct
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at the Total Cases vs the Population 
SELECT location, date, total_cases,  total_deaths, (total_cases / population ) *100 as Death_pct
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

-- Looking at countries with highest infection rate compared to population 
SELECT location, population, MAX (total_cases ) as HighestInfectionCount, Max(total_cases/ population) *100  as PercentPopulationInfected
FROM CovidDeaths  
--WHERE location like '%states%'
GROUP BY location, population
order by PercentPopulationInfected desc


-- Looking at countries with highest death count  compared to population 
SELECT location, MAX( cast(total_deaths as int )) as TotalDeathCount
FROM CovidDeaths  
--WHERE location like '%states%'
WHERE continent is not NULL 
GROUP BY location
order by TotalDeathCount desc

-- Lets break things down by continent 
SELECT continent, MAX( cast(total_deaths as int )) as TotalDeathCount
FROM CovidDeaths  
--WHERE location like '%states%'
WHERE continent is not NULL 
GROUP BY continent
order by TotalDeathCount desc

--- Global Numbers 
SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases) *100 as Deathpct
FROM CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date 
order by 1,2



---Looking at Total Population vs vaccinations 
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
		SUM(Convert(int, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.location , a.date ) 
FROM CovidDeaths as a
JOIN CovidVaccines as b
ON a.location = b.location
AND a.date= b.date
WHERE a.continent is not null 
order by 2,3

With PopvsVac (continent, location, Date , population, new_vaccinations, RollingPeopleVaccinated)

as
 (
	SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
		SUM(Convert(int, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.location , a.date ) as RollingPeopleVaccinated
	FROM CovidDeaths as a
	JOIN CovidVaccines as b
	ON a.location = b.location AND a.date= b.date
	WHERE a.continent is not null
	)

SELECT *
FROM PopvsVac

--Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as 
SELECT a.continent, a.location, a.date, a.population, b.new_vaccinations,
		SUM(Convert(int, b.new_vaccinations)) OVER (PARTITION BY a.location ORDER BY a.location , a.date ) as RollingPeopleVaccinated
	FROM CovidDeaths as a
	JOIN CovidVaccines as b
	ON a.location = b.location AND a.date= b.date
	WHERE a.continent is not null

	SELECT * 
	FROM PercentPopulationVaccinated