
Select * from [dbo].[CovidDeath$]

----TOTAL DEATHS PERCENTAGE PER LOCATION
--Shows Likelihood of Dying if you contract in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from [dbo].[CovidDeath$]
Where location like '%States%'
order by 1,2

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage 
from [dbo].[CovidDeath$]
Where location like '%States%'
and continent is not null 
order by 1,2


----TOTAL CASES VS POPULATION 
--SHOW WHAT % OF POPULATION GOT COVID 

Select Location, date, population, total_cases, (total_cases/population)*100 as Deathpercentage 
from [dbo].[CovidDeath$]
Where location like '%States%'
order by 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

Select Location, population, Max(total_cases) as HighInfectionCount, Max((total_cases/population))*100 as PercentPopulationinfected  
from [dbo].[CovidDeath$]
--Where location like '%States%' (NB:the where clause has been commented out)
Group by Location, population
order by PercentPopulationinfected desc

--SHOW COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION 

Select Location, Max(total_deaths) as Totaldeathcount    as 1
from [dbo].[CovidDeath$]
Group by Location, population
order by Totaldeathcount desc

AS 2 NB:
 the null values changes the results 

Select Location, Max(total_deaths) as Totaldeathcount
from [dbo].[CovidDeath$]
where continent is not null
Group by Location 
order by Totaldeathcount desc


--BREAK IT DOWN BY CONTINENT 1
Select continent, Max(total_deaths) as Totaldeathcount
from [dbo].[CovidDeath$]
where continent is not null
Group by continent 
order by Totaldeathcount desc
2
Select location, Max(total_deaths) as Totaldeathcount
from [dbo].[CovidDeath$]
where continent is null
Group by Location 
order by Totaldeathcount desc

--Showing Continent with Highst Death Count
Select continent, Max(total_deaths) as Totaldeathcount
from [dbo].[CovidDeath$]
where continent is not null
Group by continent 
order by Totaldeathcount desc


--GLOBAL NUMBERS 
Select date, sum(new_cases) as total_cases,  sum(cast(total_deaths as int))as Total_deaths, Sum(Cast(new_deaths as int)) / Sum
  (total_cases)*100 as Deathpercentage 
from [dbo].[CovidDeath$]
Group by date
order by 1,2

Select sum(new_cases) as total_cases,  sum(cast(total_deaths as float))as Total_deaths, Sum(Cast(new_deaths as float)) / Sum
  (total_cases)*100 as Deathpercentage 
from [dbo].[CovidDeath$]
---Group by date 
order by 1,2


--JOINING THE TWO TABLES 
Select * 
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 


--LOOKING AT TOTAL POPULATIONS VS VACCINATIONS 
Select T1.continent, T1.location, T1.date, T1.population, T2.new_vaccinations
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 
where T1.continent is not null 
order by 2,3


 Select T1.continent, T1.location, T1.date, T1.population, T2.new_vaccinations
,  SUM (Cast(T2.new_vaccinations as float)) OVER (Partition by T1.location order by T1.location, T1.date) 
as Rollingpopelevaxx 
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 
where T1.continent is not null 
order by 2,3
 

 --USE CTE
 With PoplevsVaccination (continent, location, Date, population, new_vaccinations, Rollingpopelevaxx)
 as
 (
  Select T1.continent, T1.location, T1.date, T1.population, T2.new_vaccinations
,  SUM (Cast(T2.new_vaccinations as float)) OVER (Partition by T1.location order by T1.location, T1.date) 
as Rollingpopelevaxx 
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 
where T1.continent is not null 
--order by 2,3
)
Select *, (Rollingpopelevaxx/population)*100
from PoplevsVaccination 


--TEMPORARY TABLE 

Create table #PercentPopulationVaccination
(
Continent nvarchar (255),
Location nvarchar (255),
date Datetime,
Population numeric,
new_vaccinations numeric,
Rollingpopelevaxx numeric 
)

insert into #PercentPopulationVaccination
Select T1.continent, T1.location, T1.date, T1.population, T2.new_vaccinations
,  SUM (Cast(T2.new_vaccinations as float)) OVER (Partition by T1.location order by T1.location, T1.date) 
as Rollingpopelevaxx 
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 
where T1.continent is not null 
--order by 2,3

Select *, (Rollingpopelevaxx/Population)*100
from #PercentPopulationVaccination


--CREATING VIEWS TO STORE DATA FOR VISUALIZATION 

Create view PercentagePopulationVaccinated as
Select T1.continent, T1.location, T1.date, T1.population, T2.new_vaccinations
,  SUM (Cast(T2.new_vaccinations as float)) OVER (Partition by T1.location order by T1.location, T1.date) 
as Rollingpopelevaxx 
from [dbo].[CovidDeath$] as T1
join [dbo].[CovidVaxx$] as T2
on T1.location = T2.location
and T1.date = T2.date 
where T1.continent is not null 


select * from [dbo].[PercentagePopulationVaccinated]

