/* Covid 19 Data Exploration // Èññëåäîâàíèå äàííûõ COVID 19

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

/*


select * 
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with // Âûáåðåì äàííûå, ñ êîòîðûìè ìû áóäåì ðàáîòàòü


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths // Îáùåå êîëè÷åñòâî ñëó÷àåâ çàáîëåâàíèÿ ïî ñðàâíåíèþ ñ îáùèì êîëè÷åñòâîì ñìåðòåé
-- Shows the probability of death in case of covid disease infection in Russia (my location) // Ïîêàçûâàåò âåðîÿòíîñòü ñìåðòè â ñëó÷àå çàðàæåíèÿ êîâèäíûìè çàáîëåâàíèÿìè â Ðîññèè (ìîå ìåñòîïîëîæåíèå)


select location, date, total_cases, total_deaths, (CAST((total_deaths) AS Float) / total_cases) * 100 AS DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location like '%russia'
and continent is not null 
order by 1,2

--total cases vs population // Îáùåå êîëè÷åñòâî ñëó÷àåâ ïî ñðàâíåíèþ ñ íàñåëåíèåì
--Shows what percentage of population infected with Covid // Ïîêàçûâàåò, êàêîé ïðîöåíò íàñåëåíèÿ èíôèöèðîâàí Covid

select location, date, population, total_cases, total_deaths, (CAST((total_cases) AS Float) / population) * 100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
WHERE location like '%russia'
order by 1,2

-- Countries with Highest Infection Rate compared to Population // Ñòðàíû ñ ñàìûì âûñîêèì óðîâíåì èíôèöèðîâàíèÿ ïî ñðàâíåíèþ ñ íàñåëåíèåì

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((CAST((total_cases) AS Float)/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--WHERE location like '%russia'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population // Ñòðàíû ñ ñàìûì âûñîêèì ïîêàçàòåëåì ñìåðòíîñòè íà äóøó íàñåëåíèÿ

Select Location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT // ÐÀÇÄÅËÅÍÈÅ ÏÎ ÊÎÍÒÈÍÅÍÒÀÌ 
-- Showing contintents with the highest death count per population // Ïîêàçûâàåì êîíòèíåíòû ñ íàèáîëüøèì êîëè÷åñòâîì ñìåðòåé íà ÷èñëåííîñòü íàñåëåíèÿ

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS // ÃËÎÁÀËÜÍÛÅ ÏÎÊÀÇÀÒÅËÈ

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/SUM(cast(new_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%russia%'
where continent is not null 
--Group By date
order by 1,2


-- Total Population vs Vaccinations // Îáùåå íàñåëåíèå è êîëè÷åñòâî ïðèâèòûõ
-- Shows Percentage of Population that has recieved at least one Covid Vaccine // Ïîêàçûâàåò ïðîöåíò íàñåëåíèÿ, êîòîðîå ïîëó÷èëî õîòÿ áû îäíó âàêöèíó Êîâèä

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query // Èñïîëüçóÿ CTE äëÿ âûïîëíåíèÿ âû÷èñëåíèÿ ïî Partition By â ïðåäûäóùåì çàïðîñå

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query // Èñïîëüçóÿ òàáëèöó Temp Table äëÿ ðàñ÷åòà ïî Partition By â ïðåäûäóùåì çàïðîñå

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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


 --Creating View to store data for later visualizations // Ñîçäàåì ïðåäñòàâëåíèå äëÿ õðàíåíèÿ äàííûõ äëÿ ïîñëåäóþùåé âèçóàëèçàöèè

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

