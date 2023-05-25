SELECT *
FROM PORTFOLIO..CovidDeaths$
ORDER BY 3,4


--SELECT *
--FROM PORTFOLIO..CovidVaccinations$
--ORDER BY 3,4


--- SELECT DATA I WILL BE USING

SELECT Location, Date, total_cases, New_cases, total_deaths, Population
FROM PORTFOLIO..CovidDeaths$
ORDER BY 1,2

--- LOOKING AT TOTAL_CASES VS TOTAL_DEATH (DEATH_PERCENTAGE)
--- SHOWS DEATH RATE
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PORTFOLIO..CovidDeaths$
where location = 'NIGERIA'
ORDER BY 1,2


--- LOOKING AT TOTAL CASES VS POPULATION (INFECTED_PERCENTAGE)
--- SHOWS INFECTION RATE OF COVID
SELECT Location, Date, population,total_cases, (total_cases/population)*100 as infected_percentage
FROM PORTFOLIO..CovidDeaths$
where location = 'NIGERIA'
ORDER BY 1,2


--- LOOKING AT COUNTRIES WITH THE HIGHEST INFECTION RATE
SELECT Location, population,MAX(total_cases) as highestinfection_count, MAX((total_cases/population))*100 as infected_percentage
FROM PORTFOLIO..CovidDeaths$
where continent is not null
GROUP BY Location,population
ORDER BY highestinfection_count DESC

--- LOOKING AT COUNTRIES WITH THE HIGHEST DEATH RATE
SELECT Location, population, MAX(CAST(total_deaths as int)) as highestdeath_count, MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 as death_percentage
FROM PORTFOLIO..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY highestdeath_count DESC

---- global total deaths

SELECT sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as totaldeath_count, sum(CAST(new_deaths AS INT))/sum(new_cases)*100 as death_percentage
FROM PORTFOLIO..CovidDeaths$
WHERE continent IS not NULL 
---GROUP BY location
ORDER BY 1,2


SELECT *
FROM PORTFOLIO..CovidDeaths$ dea
JOIN PORTFOLIO..CovidVaccinations$ vacc
  ON dea.location = vacc.location
     AND dea.date = vacc.date

----  LOOKING AT TOTAL POPULATION VS VACCINATION


SELECT dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(convert(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as total_vaccination 
FROM PORTFOLIO..CovidDeaths$ dea
JOIN PORTFOLIO..CovidVaccinations$ vacc
  ON dea.location = vacc.location
     AND dea.date = vacc.date
where dea.continent is not null
order by 1,2


---using CTE

WITH populationvsvaccinations (continent, location, date, population, new_vaccination, total_vaccination)
as 
(SELECT dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(convert(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as total_vaccination 
FROM PORTFOLIO..CovidDeaths$ dea
JOIN PORTFOLIO..CovidVaccinations$ vacc
  ON dea.location = vacc.location
     AND dea.date = vacc.date
where dea.continent is not null
---order by 1,2
)

select *, (total_vaccination/population)*100
from populationvsvaccinations

--- create view for visualization

CREATE VIEW populationvsvaccinations AS
SELECT dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(convert(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as total_vaccination 
FROM PORTFOLIO..CovidDeaths$ dea
JOIN PORTFOLIO..CovidVaccinations$ vacc
  ON dea.location = vacc.location
     AND dea.date = vacc.date
where dea.continent is not nulL

CREATE VIEW deathrate AS
SELECT Location, population, MAX(CAST(total_deaths as int)) as highestdeath_count, MAX(CAST(total_deaths AS INT))/MAX(total_cases)*100 as death_percentage
FROM PORTFOLIO..CovidDeaths$
WHERE continent IS NOT NULL 
GROUP BY location, population
---ORDER BY highestdeath_count DESC


---- creating a Temp Table
DROP TABLE IF EXISTS #percentpopulationvaccinated 
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
total_vaccination numeric
)

INSERT INTO  #percentpopulationvaccinated
SELECT dea.continent,dea.location, dea.date, dea.population, vacc.new_vaccinations,
Sum(convert(int,vacc.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as total_vaccination 
FROM PORTFOLIO..CovidDeaths$ dea
JOIN PORTFOLIO..CovidVaccinations$ vacc
  ON dea.location = vacc.location
     AND dea.date = vacc.date
---where dea.continent is not null
---order by 1,2

select *, (total_vaccination/population)*100
from #percentpopulationvaccinated
