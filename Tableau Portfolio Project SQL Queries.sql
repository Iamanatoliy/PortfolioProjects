/*

Queries used for Tableau Project

The prepared queries were saved to separate excel documents, then added to tableau and converted.
You can see the finished dashboard at the link below: 

https://public.tableau.com/app/profile/anatoliy.solyar/viz/CovidDashboard_16399338414400/Dashboard1


*/


-- 1. Death Percentage

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
where continent is not null 
--Group By date
order by 1,2


-- 2.  Total Death Count

Select location, SUM(cast(new_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
Where continent is null 
and location not in ('World','European Union','International')
Group by location
order by TotalDeathCount desc


-- 3. Percent Population Infected

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((cast(total_cases as float)/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. Percent Population Infected

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((cast(total_cases as float)/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
Group by Location, Population, date
order by PercentPopulationInfected desc

