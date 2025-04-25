

/*
2025-02-06 
LG put 2023 as a whole year instead of month-by-month.

2024-05-01
YS refined prevalent initiators definition
LG added FDA_approval_date to 2.1 data 

2024-04-18 

after expanding rows for drugexpdetails data for visitdate with startdate reported prior to visitdate and with current dose and frequency, re-run the report to see how the re-start numbers look like 

Date: 2024-4-1 
Program: Ying Shan 
Aim: ROM-RA enrollment monthly report 

Definitions:
Index Date is the date of the specified drug approval of drug, registry start date or contract defined start date depending on subscriber defined start
Initiation is patient first time in life start to use the drug
Prevalent initiation is initiated in 12 months prior enrollment and continue use at enrollment
Baseline visit defined as a registry visit within 4 months prior to drug start date if known start date (or  6 months prior to report drug start  unknow start date for older versions or missing report start date)
Non-initiation start is prior used the drug, restart in RA registry enrollment/follow up visit
Note: 
Avsola is one of infliximab biosimilar, which index date is 12/6/2019, but we don't have any patient used  it in RA registry. We don't include it in current report, will check it after 6 months

drug includes:

xeljanz olumiant rinvoq humira amjevita_bs cimzia enbrel erelzi_bs simponi remicade inflectra_bs renflexis_bs rituxan orencia actemra kevzara 

 # of patients with at least one initiation from biologic cohort in last colunm of Abbvie sheet 

*/ 

cap log close 
global datacut "2025-04-01"
global data "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\2025-04-01"

cd "~\Corrona LLC\Biostat Data Files - Queries and Projects\RA\ROM-RA" 

log using "RA Enrollment Monthly Report 2025-04-10.log",append // replace 
 

use "$data\2_1_drugexpdetails_$datacut", clear 

// update each month 
*drop if visitdate>=d(01dec2024)  // 0 

preserve 
keep if strpos(generic_key, "tofa") | strpos(generic_key, "golim") 
keep subject_number *visit* *generic* drug_date drug_category cumpt_reported_en drug_status_raw

drop drug_start* drug_stop* drug_base_visit
for any key indexn indexN status start stop start_date stop_date start_visit stop_visit start_order stop_order init_date base_visit: rename generic_X drug_X     
for any hx_  nhx_b_ts_  init_   pres_ : rename Xgeneric Xdrug 

replace drug_key="xeljanz" if drug_key=="tofacitinib" 
replace drug_key="simponi" if drug_key=="golimumab" 

sort subject_number drug_key drug_date 
save tofa,  replace 

restore 


keep if drug_category==250 | drug_category==390 
drop if strpos(drug_key, "xeljanz") | strpos(drug_key, "simponi") | drug_key=="kineret" | drug_key=="sirukumab" | strpos(drug_key, "_bs") 

tab drug_key 
drop *generic* *steroid* discontinued*

drop if drug_key=="" 

append using tofa 

drop if strpos(drug_key, "_bs") 
cap erase tofa.dta  

replace drug_start=. if drug_start==1 & drug_start_date==.  // clean carry forward drug_start prior to enrollment 


* limit drugs since indexn date 
// 2024-05-01 data included fda_approval_date for every drug except for _bs, invest 
for any drug_start init_drug: replace X=. if drug_start_date<fda_approval_date & fda_approval_date<. & X==1

tab drug_key if init_drug==1 & visit_indexn==1 & drug_base_visit==. 

*prevalent init: initiation prior enrollment in 12 months with continue use at the enrollment -no stop at enrollment 

// no baseline, initiation prior enrollment 
replace init_drug=0 if init_drug==1 & visit_indexn==1 & ( drug_base_visit==. | drug_start_date==.) 

sort subject_number drug_key visitdate drug_start drug_date 
by subject_number drug_key: gen cumstart=sum(drug_start) if visitdate==enroll_visit 
by subject_number drug_key: gen cumstop=sum(drug_stop) if visitdate==enroll_visit 

clonevar stopdt=drug_stop_date 
by subject_number drug_key: replace stopdt=stopdt[_n-1] if visit_indexn==1 & stopdt==. & stopdt[_n-1]<. 

by subject_number drug_key visitdate drug_start: gen vtn=_n  if visit_indexn==1 & drug_start==1 
by subject_number drug_key visitdate drug_start: gen vtN=_N  if  visit_indexn==1 & drug_start==1 

egen prinit=sum(init_drug) if visit_indexn==1, by(subject_number drug_key visitdate) 

sort subject_number drug_key visitdate drug_date 
by subject_number drug_key visitdate: gen prev_init=1 if visit_indexn==1 & vtN==1 & prinit!=1 & enroll_visit-drug_start_date<366  & (cumstop==0 | cumstop==1 & stopdt>enroll_visit & stopdt[_N] > enroll_visit & stopdt[_N]<. | drug_status[_N]<3) 

replace prev_init=0 if prev_init==1 & drug_start_date==visitdate & cumpt_reported_en==1 // 623 cases -->602
replace prev_init=0 if drug_indexn>1  & prev_init==1  

gen drug_yr=year(drug_start_date) if drug_start==1 | prev_init==1 | init_drug==1 
gen drug_mo=month(drug_start_date) if drug_start==1  | prev_init==1 | init_drug==1 
 
replace drug_yr=2019 if drug_yr<2019 



/*
// prevalent initiations  
foreach x in xeljanz olumiant rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara { 

replace `x'yr=year(dofm(`x'_stdt)) if indexn==1 & add`x'==0 // prevalent initiation start year 
replace `x'yr = 2020 if `x'yr<2020 

replace `x'mo=month(dofm(`x'_stdt)) if indexn==1 & add`x'==0  // prevalent initiation start month 

gen `x'base=0 if init`x'==1 & vindadd`x'==2 
replace `x'base=1 if init`x'==1 & (vindadd`x'==1 | vindadd`x'==2 & (`x'_adddt-prvisitym<=4 & `x'_stdt<. | `x'_adddt-prvisitym<=6 & `x'_stdt==.))  
} 

********************************************************/ 

*use temp1, clear 
save temp1_$datacut, replace

sort drug_key subject_number visitdate drug_start drug_date 
by drug_key subject_number visitdate drug_start: gen st1=1 if drug_start==1 & _n==1 
/*
gen fu=visit_indexn>1 
tab drug_key fu if drug_start==1 & init_drug !=1 & prev_init!=1  
tab drug_key fu if st1==1 & init_drug !=1 & prev_init!=1  
*/
replace drug_start=0 if drug_start==1 & st1!=1 
// 2024-04-18 LG test, use 366 days, suggested by Ying  
replace drug_start=0 if drug_start==1 & visit_indexn==1 & visitdate-drug_start_date>=366 

*2024-05-16 check first start not true start 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & prev_init==1 , m 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & drug_start==1 , m 

replace prev_init=0 if visit_indexn==1 & drug_indexn==1 & prev_init==1 & drug_status_raw!="start"
replace drug_start=0 if  visit_indexn==1 & drug_indexn==1 & drug_start==1 & drug_status_raw!="start"


*********************************************************

clear matrix 

* for counts from index yearly 

	 
foreach y in 2019 2020 2021 2022 2023 { 	
	matrix t`y'=J(8, 21, .) 	
	local c=0 
foreach x in xeljanz olumiant rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara { 
	local ++c
qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`y'  // prevalent initiations 
	matrix t`y'[1, `c']=(r(N))
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y'  // total initiations at en/fu 
	matrix t`y'[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y' & drug_base_visit<.  // initiations with baseline 
	matrix t`y'[3, `c']=(r(N))
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y' & drug_base_visit==.    // initiations without baseline 
	matrix t`y'[4, `c']=(r(N))
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)  & drug_yr==`y'    // total prevalent initiations / initiations at en/fu 
	matrix t`y'[5, `c']=(r(N))
qui count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1  & drug_yr ==`y'    // no-initiation starts at/after enrollment 
	matrix t`y'[6, `c']=(r(N)) 
	} 
} 


foreach z in 2024 { 
forvalue i= 1/12 { 
	
	matrix t`i'=J(8, 21, .)  
	local c=0 
foreach x in xeljanz olumiant rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara { 
	local ++c	
	
qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`z'  & drug_mo==`i' // prevalent initiations 
	matrix t`i'[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'   // total initiations at en/fu
	matrix t`i'[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visit<.  & drug_yr==`z' &  drug_mo==`i'   // initiations with baseline 
	matrix t`i'[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visit==.  & drug_yr==`z' & drug_mo==`i'     // initiations without baseline 
	matrix t`i'[4, `c']=(r(N)) 
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)  & drug_yr==`z' & drug_mo==`i'      // total prevalent initiations / initiations at en/fu 
	matrix t`i'[5, `c']=(r(N)) 
qui count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1  & drug_yr ==`z' &  drug_mo==`i'   // no-initiation starts at/after enrollment 
	matrix t`i'[6, `c']=(r(N)) 
	} 
}
} 

* total cumulated counts from index date to data cut 

matrix t=J(6, 21, .) 

local c=0 
foreach x in xeljanz olumiant rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara { 
local ++c 

qui count if drug_key=="`x'" & prev_init==1  // prevalent initiations 
	matrix t[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1    // total initiations at en/fu
	matrix t[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visit<.    // initiations with baseline 
	matrix t[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_base_visi==.    // initiations without baseline 
	matrix t[4, `c']=(r(N)) 
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)   // total prevalent initiations / initiations at en/fu 
	matrix t[5, `c']=(r(N)) 
qui count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1   // no-initiation starts at/after enrollment 
	matrix t[6,`c']=(r(N)) 
	} 

	
	* count monthly for 2025 
// update monthly for value i=1/?
foreach z in 2025 { 
forvalue i=1/3 { 
    
	matrix a`i'=J(8, 21, .)  
	local c=0 
foreach x in xeljanz olumiant rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara { 
	local ++c	

qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`z'  & drug_mo==`i' // prevalent initiations 
	matrix a`i'[1, `c']=(r(N))  
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'   // total initiations at en/fu
	matrix a`i'[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visit<.  & drug_yr==`z' &  drug_mo==`i'   // initiations with baseline 
	matrix a`i'[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_base_visi==.  & drug_yr==`z' & drug_mo==`i'     // initiations without baseline 
	matrix a`i'[4, `c']=(r(N)) 
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)  & drug_yr==`z' & drug_mo==`i'      // total prevalent initiations / initiations at en/fu 
	matrix a`i'[5, `c']=(r(N)) 
qui count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1  & drug_yr ==`z' &  drug_mo==`i'   // no-initiation starts at/after enrollment 
	matrix a`i'[6, `c']=(r(N)) 
	}  	
} 
} 


*output matrix 
// add \a? each month 
matrix yr19 = t2019\t2020\t2021\t2022\t2023\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t11\t12
matrix yr25 = a1\a2\a3

matrix yr=yr19\yr25\t 
 
putexcel set "RA Enrollment Monthly Report $datacut.xlsx", sheet(Drugs) modify 
putexcel B8=matrix(yr) 	


**********************************************************************************

use temp1_$datacut, clear 

* biologic index date use Rinvoq index date 

qui foreach x in  humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara {		
	replace init_drug=0 if drug_key=="`x'" & init_drug==1 & (hx_rinvoq==1 | drug_start_date < d(15Aug2019) ) 
	// LG, this was not in the Jan code, we did not limit for prior reports  
	replace prev_init=0 if drug_key=="`x'" & prev_init==1 & (hx_rinvoq==1 | drug_start_date < d(15Aug2019) ) 
	// LG, adding for non-initiation starts.
	replace drug_start=0 if drug_key=="`x'" & drug_start==1 & (hx_rinvoq==1 | drug_start_date < d(15Aug2019) )
} 

/* 2024-05-08 need to repeat instead of saving temp 1, or else the number will drop  
2024-04-18 do the same for re-start*/
sort drug_key subject_number visitdate drug_start drug_date 
by drug_key subject_number visitdate drug_start: gen st1=1 if drug_start==1 & _n==1 

replace drug_start=0 if drug_start==1 & st1!=1 
// 2024-04-18 LG test, use 366 days, suggested by Ying  
replace drug_start=0 if drug_start==1 & visit_indexn==1 & visitdate-drug_start_date>=366


clear matrix 

	
foreach y in 2019 2020 2021 2022 2023 { 
	
	matrix t`y' =J(8, 20, .)  
	
	local c=0 
qui foreach x in rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara {	
	local ++c 
	
* for counts from index yearly 
	
qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`y'  // prevalent initiations 
	matrix t`y'[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y'  // total initiations at en/fu
	matrix t`y'[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y' & drug_base_visit<.  // initiations with baseline 
	matrix t`y'[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1  & drug_yr==`y'  & drug_base_visi==.    // initiations without baseline 
	matrix t`y'[4, `c']=(r(N)) 
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)  & drug_yr==`y'    // total prevalent initiations / initiations at en/fu 
	matrix t`y'[5, `c']=(r(N)) 
qui count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1  & drug_yr ==`y'    // no-initiation starts at/after enrollment 
	matrix t`y'[6,`c']=(r(N)) 
}  

local ++c 

qui unique subject_number if prev_init==1 & drug_yr==`y' & drug_category==250 
matrix t`y'[1, `c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_yr==`y' & drug_category==250 
matrix t`y'[2,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_base_visit<. & drug_yr==`y' & drug_category==250 
matrix t`y'[3,`c']=(r(unique))
qui unique subject_number if init_drug==1  & drug_base_visi==. & drug_yr==`y' & drug_category==250 
matrix t`y'[4,`c']=(r(unique))
unique subject_number if (prev_init==1 | init_drug==1) & drug_yr==`y' & drug_category==250 
matrix t`y'[5,`c']=(r(unique)) 

} 
	
* count monthly for 2024 

foreach z in 2024 { 
    
forvalue i=1/12 { 
	
	matrix t`i' =J(8, 20, .)  
	
	local c=0 
qui foreach x in rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara {	
	local ++c 

qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`z' & drug_mo==`i'   
	matrix t`i'[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'    
	matrix t`i'[2, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_base_visit<. 
	matrix t`i'[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_base_visi==.   
	matrix t`i'[4, `c']=(r(N)) 
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1) & drug_yr ==`z' & drug_mo==`i'    
	matrix t`i'[5, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug!=1  & drug_start==1  & prev_init!=1 & drug_yr ==`z' & drug_mo==`i'      
	matrix t`i'[6, `c']=(r(N)) 
}  

local ++c 

qui unique subject_number if prev_init==1 & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix t`i'[1,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix t`i'[2,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_base_visit<. & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix t`i'[3,`c']=(r(unique))
qui unique subject_number if init_drug==1  & drug_base_visi==. & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix t`i'[4,`c']=(r(unique))
unique subject_number if (prev_init==1 | init_drug==1) & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix t`i'[5,`c']=(r(unique)) 
	}  
}

	
* total cumulated counts from index date to data cut 
	matrix t =J(6, 20, .) 
	/* 
	2024-05-06 change from 158 to 166 to accomodate adding Apr 2024
	// update monthly adding 8
	*local row =166
	local row=174
	*/
	local c=0 
qui foreach x in rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara {	
	local ++c 
	qui count if drug_key=="`x'" & prev_init==1  
	matrix t[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1   
	matrix t[2, `c']=(r(N))  
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visit<. 
	matrix t[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_base_visi==.   
	matrix t[4, `c']=(r(N))	
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1)      
	matrix t[5, `c']=(r(N))		
qui count if drug_key=="`x'" & init_drug!=1 & drug_start==1 & prev_init!=1 
	matrix t[6, `c']=(r(N)) 	
} 

local ++c 
qui unique subject_number if prev_init==1  & drug_category==250 
matrix t[1,`c']=(r(unique)) 
qui unique subject_number if init_drug==1  & drug_category==250 
matrix t[2,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_base_visit<. &  drug_category==250 
matrix t[3,`c']=(r(unique))
qui unique subject_number if init_drug==1  & drug_base_visi==. & drug_category==250 
matrix t[4,`c']=(r(unique))
unique subject_number if (prev_init==1 | init_drug==1) &  drug_category==250 
matrix t[5,`c']=(r(unique)) 

*******************************************************************
* count monthly for 2024 - updating monthly by adding new month in 2024 
// update monthly for i=1/?	

foreach z in 2025 { 
forvalue i=1/3 { 
	
	matrix a`i' =J(8, 20, .)  
	
	local c=0 
qui foreach x in rinvoq humira amjevita abrilada cyltezo cimzia enbrel erelzi simponi remicade inflectra renflexis avsola  rituxan ruxience truxima orencia actemra kevzara {	
	local ++c 
	
qui count if drug_key=="`x'" & prev_init==1 & drug_yr==`z' & drug_mo==`i'   
	matrix a`i'[1, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'    
	matrix a`i'[2, `c']=(r(N))  
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_base_visit<. 
	matrix a`i'[3, `c']=(r(N)) 
qui count if drug_key=="`x'" & init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_base_visi==.   
	matrix a`i'[4, `c']=(r(N)) 	
qui count if drug_key=="`x'" & (init_drug==1 | prev_init==1) & drug_yr ==`z' & drug_mo==`i'    
	matrix a`i'[5, `c']=(r(N)) 	
qui count if drug_key=="`x'" & init_drug!=1  & drug_start==1  & prev_init!=1 & drug_yr ==`z' & drug_mo==`i'      
	matrix a`i'[6, `c']=(r(N)) 
} 

local ++c 
qui unique subject_number if prev_init==1 & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix a`i'[1,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix a`i'[2,`c']=(r(unique)) 
qui unique subject_number if init_drug==1 & drug_base_visit<. & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix a`i'[3,`c']=(r(unique))
qui unique subject_number if init_drug==1  & drug_base_visi==. & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix a`i'[4,`c']=(r(unique))
unique subject_number if (prev_init==1 | init_drug==1) & drug_yr==`z' & drug_mo==`i'  & drug_category==250 
matrix a`i'[5,`c']=(r(unique)) 
} 
} 

*output matrix 

matrix yr19 = t2019\t2020\t2021\t2022\t2023\t1\t2\t3\t4\t5\t6\t7\t8\t9\t10\t11\t12
matrix yr25 = a1\a2\a3 
matrix yr=yr19\yr25\t 
 

putexcel set "RA Enrollment Monthly Report $datacut.xlsx", sheet(Abbvie) modify 
putexcel B6=matrix(yr) 	

// update 11(8)xxx each month by adding 8
forvalue i=11(8)171 { 
   putexcel U`i'=("n/a") 
}

log close 



///////////////////// 2024-10-03 QC for the increased numbers of restart for Rituxan from 576 to 906
/* 
for any 000123476 000591001 001010055: list study source subject_number visitdate visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status_raw drug_status drug_start drug_stop if subject_number=="X" & drug_key=="rituxan", noobs ab(16) sepby(drug_key)
use temp1_2024-10-01, clear
 sort drug_key subject_number visitdate drug_start drug_date 
by drug_key subject_number visitdate drug_start: gen st1=1 if drug_start==1 & _n==1 

replace drug_start=0 if drug_start==1 & st1!=1 
// 2024-04-18 LG test, use 366 days, suggested by Ying  
replace drug_start=0 if drug_start==1 & visit_indexn==1 & visitdate-drug_start_date>=366 

*2024-05-16 check first start not true start 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & prev_init==1 , m 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & drug_start==1 , m 

replace prev_init=0 if visit_indexn==1 & drug_indexn==1 & prev_init==1 & drug_status_raw!="start"
replace drug_start=0 if  visit_indexn==1 & drug_indexn==1 & drug_start==1 & drug_status_raw!="start"



count if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1

local x rituxan

preserve 
keep if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1
keep subject_number visitdate visit_indexn drug_key drug_plan drug_status hx_drug init_drug 
save `x'_restarts_2024-10-01, replace 
restore 

use temp1_2024-09-01, clear
 sort drug_key subject_number visitdate drug_start drug_date 
by drug_key subject_number visitdate drug_start: gen st1=1 if drug_start==1 & _n==1 

replace drug_start=0 if drug_start==1 & st1!=1 
// 2024-04-18 LG test, use 366 days, suggested by Ying  
replace drug_start=0 if drug_start==1 & visit_indexn==1 & visitdate-drug_start_date>=366 

*2024-05-16 check first start not true start 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & prev_init==1 , m 
tab drug_status_raw if visit_indexn==1 & drug_indexn==1 & drug_start==1 , m 

replace prev_init=0 if visit_indexn==1 & drug_indexn==1 & prev_init==1 & drug_status_raw!="start"
replace drug_start=0 if  visit_indexn==1 & drug_indexn==1 & drug_start==1 & drug_status_raw!="start"

*local x xeljanz
preserve 
keep if drug_key=="`x'" & drug_start==1 & init_drug !=1 & prev_init!=1
keep subject_number visitdate visit_indexn drug_key drug_plan drug_status hx_drug init_drug 
save `x'_restarts_2024-09-01, replace 
restore 

use rituxan_restarts_2024-10-01, clear 
unique subject_number visitdate 
merge 1:1 subject_number visitdate using rituxan_restarts_2024-09-01, keepus(subject_number visitdate)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           330
        from master                       330  (_merge==1)
        from using                          0  (_merge==2)

    matched                               576  (_merge==3)
    -----------------------------------------
  +-----------------------------+
  | subject_number    visitdate |
  |-----------------------------|
  |      000000056   2013-03-13 |
  |      000123476   2012-05-15 |
  |      000591001   2012-01-18 |
  |      001010055   2010-04-13 |
  |      001010055   2013-02-19 |
  +-----------------------------+
preserve 
keep if _m==1
list subject_number visitdate in 1/5, noobs ab(16)
restore 
*/
