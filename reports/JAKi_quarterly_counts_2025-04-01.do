/*
2024-07-11 update using v20240701z

2024-04-19 update the report after the 2024-04-01 datacut updated 

JAK quarterly counts by site and by year 

count for Bari and Upa and Tofa 

1. total eligible enrollment: started in past 12 months and continue use at enrollment | initiation at enrollment 
2. total switchers (init at/after enrollment) 
3. by site and by year, then total per year

*/

cap log close 

// update CD quarterly and also on row #217
*cd "~\Corrona LLC\Biostat Data Files - RA\registry_counts\JAKi quarterly counts by site year\2024\Q1"
*cd "~\Corrona LLC\Biostat Data Files - Registry Data\RA\registry_counts\JAKi quarterly counts by site year\2024\Q1" 
cd "~\Corrona LLC\Biostat Data Files - RA\registry_counts\JAKi quarterly counts by site year\2025\Q1" 


log using JAKi_quarterly_2025-04-10.log, append // replace 

*use "~/Corrona LLC/Biostat Data Files - Registry Data/RA/monthly/2024/2024-04-01/2_1_drugexpdetails", clear  

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\2025-04-01/2_1_drugexpdetails_$datacut", clear  
// 2024-07-11 update, found one rinvoq started 2015
for any 310004633: list subject_number dw_event_type visitdate visit_indexn visit_indexN drug_date drug_key drug_status drug_start_date fda_approval_date if subject_number=="X", noobs ab(16) sepby(drug_key)

drop if drug_start_date<fda_approval_date

count if generic_key=="tofacitinib" & init_generic==1 & visit_indexn>1 & generic_start_date>=d(06nov2012) // 3,025==>3,038
count if drug_key=="rinvoq" & init_drug==1 & visit_indexn>1 & drug_start_date>=d(15aug2019) // 1426==> 1,480
count if drug_key=="olumiant" & init_drug==1 & visit_indexn>1 & drug_start_date>=d(31may2018) // 336 ==>349

keep if drug_category==390 
// 2024-07-11, we do not keep site_id in drugexpdetails data anymore, just clone it using site_number
clonevar site_id=site_number
tostring site_number, replace 

drop if site_id>=990 


preserve 
keep if strpos(generic_key, "tofa") 
keep subject_number site_id site_number *visit* *generic* drug_category drug_date

drop drug_start* drug_stop* drug_base_visit
for any key indexn indexN status start stop start_date stop_date start_visit stop_visit start_order stop_order init_date base_visit: rename generic_X drug_X 
    
for any hx  nhx_b_ts  init   pres : rename X_generic X_drug 

replace drug_key="xeljanz" 
sort subject_number drug_key drug_date visitdate 
save temp_tofa,  replace 

restore 

keep if drug_category==390 
drop if strpos(drug_key, "xeljanz") 

tab drug_key 
drop *generic* *steroid* discontinued* 

append using temp_tofa 

* limit drug index date 
for any drug_start init_drug: replace X=. if drug_key=="xeljanz"  & (drug_start_date<d(6Nov2012) | visitdate < d(6Nov2012)  ) 
for any drug_start init_drug: replace X=. if drug_key=="olumiant" & (drug_start_date<d(31may2018) | visitdate < d(31may2018) ) 
for any drug_start init_drug: replace X=. if drug_key=="rinvoq"   & (drug_start_date<d(15aug2019) | visitdate < d(15aug2019) ) 


replace drug_start=. if drug_start==1 & drug_start_date==. 
// 2024-04-15 limit initiation to have both baseline and init date
replace init_drug=0 if init_drug==1 & drug_base_visit==. & visit_indexn==1 & drug_start_date==. 
egen prinit=sum(init_drug) if visit_indexn==1, by(subject_number drug_key visitdate) 

tab prinit 

*prevalent start: start prior to enrollment in 12 months and continue use, use the last start by enrollment date if more than one start 

sort subject_number drug_key visitdate drug_start drug_date drug_status 
by subject_number drug_key visitdate drug_start: gen prev_start=1 if drug_start==1 & _n==_N & visit_indexn==1 & visitdate-drug_start_date<366 & (drug_stop!=1 | drug_stop==1 & drug_stop_date>visitdate)  & prinit!=1

mdesc drug_start_date if prev_start==1

sort subject_number drug_key visitdate drug_date drug_status 
by subject_number drug_key visitdate: replace prev_start=0 if prev_start==1 & drug_stop[_N]==1 & drug_stop_date[_N]<=visitdate 

by subject_number drug_key visitdate: gen cumprst=sum(prev_start) 

* countinue use at enrollment missing drug start and drug date in 12 months to enrollment date 
// 2024-04-15 changed from drug_date to drug_start_date
by subject_number drug_key visitdate: replace prev_start=1 if visit_indexn==1 & _n==_N & cumprst==0 & prinit==0 & pres_drug==1 & visitdate-drug_start_date<366 


gen en=1 if prev_start==1 | init_drug==1  & visit_indexn==1 
gen sw=1 if init_drug==1  & visit_indexn>1   

// 2024-04-15 suggest using year of start date.
// 2024-04-15: one special case, subject number 184010039 TAE reported rinvoq in 2019 but the start can only be linked to enrollment visit in 2016 
// Ying, enrollment use visit
gen year=year(drug_start_date) //if visit_indexn>1 
mdesc year if en==1|sw==1


// still necessary to replace missing, or will showing on report. if drug_start_date is missing, then there is no en or sw.
replace year=year(visitdate) if year==. //if drug_start_date==.|visit_indexn==1
mdesc year
*gen year=year(visitdate) 
keep if year>2011 // changed from 2017 to 2011 by adding xeljanz 

unique subject_number drug_key visitdate if en==1 
unique subject_number drug_key visitdate if sw==1 

tab year drug_key if en==1,m   
tab year drug_key if sw==1,m 
tab year drug_key if en==1|sw==1 ,m

save temp, replace 

********************************
use temp, clear 
codebook visitdate if drug_key=="rinvoq" //[12jan2015,28jun2024]
br if year(visitdate)==2015 & drug_key=="rinvoq" // 310004633

* total each drug counts by site and year for each cell
*keep if en==1|sw==1 

foreach x in en sw { 
egen tot_`x'_site_yr=total(`x'), by(drug_key site_id year)  
egen tot_`x'_site=total(`x'), by(drug_key site_id) 
egen tot_`x'_yr=total(`x'), by(drug_key year) 
egen tot_`x' = total(`x'), by(drug_key) 
} 

keep site_number site_id drug_key year tot_* 
save temp1, replace 

***********************************
use temp1, clear 

*site by year 
preserve 
keep site_number site_id drug_key year tot_en_site_yr tot_sw_site_yr 
bysort drug_key year site_number: drop if _n>1 
reshape wide tot_en_site_yr tot_sw_site_yr, i(site_id year) j(drug_key) string 
rename tot_en_site_yr* *_enrolled
rename tot_sw_site_yr* *_switchers  
save temp_bysiteyear, replace
restore 


* site total 
preserve 
keep site_number site_id drug_key year tot_en_site tot_sw_site 
bysort drug_key site_number: drop if _n>1  
replace year=2025 
reshape wide tot_en_site tot_sw_site, i(site_id) j(drug_key) string 
rename tot_en_site* *_enrolled
rename tot_sw_site* *_switchers  
save temp_bysite, replace
restore 


* by year 
preserve 
keep site_number site_id drug_key year tot_en_yr tot_sw_yr 
bysort drug_key year: drop if _n>1 
replace site_id=1000 
replace site_number="All sites" 
  
reshape wide tot_en_yr tot_sw_yr, i(year) j(drug_key) string 
rename tot_en_yr* *_enrolled
rename tot_sw_yr* *_switchers  
save temp_byyear, replace
restore 


* grand total 
preserve 
keep site_number site_id drug_key tot_en tot_sw year 
bysort drug_key: drop if _n>1 
replace site_number="Grand Total"  
replace site_id=1100
replace year=2025  
reshape wide tot_en tot_sw, i(site_number) j(drug_key) string 
rename tot_en* *_enrolled 
rename tot_sw* *_switchers 
save temp_tot, replace 
restore 

use temp_bysiteyear, clear 
order site_number year xeljanz_* olumiant_* rinvoq_*  
 
append using temp_bysite  
sort site_id year 

append using temp_byyear 
sort site_id year 

append using temp_tot 

tostring year, gen(years) 

replace years="site total" if year==2025 & site_id!=1000
replace years="" if year==2025 & site_number=="Total" 

lab var olumiant_enrolled "Olumiant Enrolled"
lab var olumiant_switchers "Olumiant Switchers"
lab var rinvoq_enrolled "Rinvoq Enrolled"
lab var rinvoq_switchers "Rinvoq Switchers"
lab var xeljanz_enrolled "Xeljanz Enrolled" 
lab var xeljanz_switchers "Xeljanz Switchers" 

tostring *_enrolled *_switchers, replace 

foreach x in xeljanz olumiant rinvoq { 
for any enrolled switchers: replace `x'_X="0" if `x'_X=="." 
}


forvalues i=2012/2017{ 
for any enrolled switchers: replace olumiant_X="N/A" if years=="`i'" & olumiant_X=="0" 
}

forvalues i=2012/2018{ 
for any enrolled switchers: replace rinvoq_X="N/A" if years=="`i'" //& rinvoq_X=="0" 2024-07-11 found a "1"
} 


sort site_id year 
drop site_id year 

order site_number years olumiant_enrolled olumiant_switchers rinvoq_enrolled rinvoq_switchers xeljanz_enrolled xeljanz_switchers 

save JAKi_2025q1, replace 
use JAKi_2025q1, clear
*list site_number years rinvoq_enrolled if rinvoq_enrolled=="1" & years=="2015", noobs ab(16)

export excel site_number years olumiant_* rinvoq_* xeljanz_* using "JAKi_quarterly_bysite_2025-Q1.xlsx", sheet("2025-Q1", modify)  cell(A4) 
 

for any tofa bysite bysiteyear byyear tot: cap erase temp_X.dta 

cap log close

