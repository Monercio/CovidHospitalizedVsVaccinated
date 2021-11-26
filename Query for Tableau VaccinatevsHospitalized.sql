-- QUERY FOR CTE PREPARATION
select dea.date, dea.location, population,hosp_patients, 
hosp_patients/population*10000 as HospitalizePer10Kpeople,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as TotalVaccinations
from CovidDeaths Dea
join CovidVaccinations Vac
on	Dea.date=Vac.date and dea.location=vac.location
where dea.continent is not null
--and dea.location = 'portugal'
order by location, date desc

--CTE FOR FULLY VACCINATED PERECENTAGE (DOUBLE DOSE)

With VaccinationPercentage as
(select dea.date, dea.location, population,hosp_patients, 
hosp_patients/population*10000 as HospitalizePer10Kpeople,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as TotalVaccinations
from CovidDeaths Dea
join CovidVaccinations Vac
on	Dea.date=Vac.date and dea.location=vac.location
where dea.continent is not null)
--and dea.location = 'portugal'
--order by location, date desc)
select *, TotalVaccinations/population/2*100   as FullyVaccinatedPerecentage
from VaccinationPercentage
--where location = 'portugal'
order by FullyVaccinatedPerecentage desc

-- CREATE TEMP TABLE FROM DOUBLE CTE TO CORRECT FullyVaccinatedPerCentage ABOVE 100 (THIRD DOSE)

---DROP Table if exists #VACCINATIONPERCENT

Drop table #VACCINATIONPERCENT

Create table #VACCINATIONPERCENT
(Date datetime, Location nvarchar (255), population int, hosp_patients int, Hosp_per10k float, TotalVaccinations bigint,
FullVaxPerCent float)


With VaccinationPercentage as
(select dea.date, dea.location, population,hosp_patients, 
hosp_patients/population*10000 as HospitalizePer10Kpeople,
SUM(cast (new_vaccinations as bigint)) over (partition by dea.location order by dea.date) as TotalVaccinations
from CovidDeaths Dea
join CovidVaccinations Vac
on	Dea.date=Vac.date and dea.location=vac.location
where dea.continent is not null),
VaccinationPercentage2 as
(select *, TotalVaccinations/population/2*100   as FullyVaccinatedPerecentage
from VaccinationPercentage)


Insert into #VACCINATIONPERCENT
Select * from VaccinationPercentage2

Select *,
Case when FullVaxPercent>100 Then 100 ELSE FullVaxPercent END AS FullVaxPercenCorrect
from #VACCINATIONPERCENT
where location = 'portugal'

