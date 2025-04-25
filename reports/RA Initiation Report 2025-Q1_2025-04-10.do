
/*

Date: 2024-4-24 
Program: Ying Shan 
Aim: RA New Initiation quarterly report by yearly 
Time period covered: This should start with 01/01/2020 and end with the date of the end of the previous quarter. 

Table 1. Number of initiations by Drug and Year 
Description:
Drug initiations categorized by the year the drug was started. Initiations are only counted if they have a valid baseline visit and any subsequent follow-up is then categorized within the year the drug was started.

Definitions:
1. Initiation is defined as the first use of the drug and occurs at or after the Registry Enrollment.
2. Baseline visit is defined as the visit occurring within the 6-weeks prior to the drug start
3. Follow-up is defined as any visit occurring after the drug start and DOES NOT have to fall within any specified, time-window
4. 6-month visit is defined as a visit occurring within 5-9 months of a drug start
5. 12-month visit is defined as a visit occurring within 10-15 months of a drug start


Table 2a. Number of initiations by Disease Severity and Drug and Year
Description: 
Drug initiations categorized by the year the drug was started. Initiations are only counted if they have a valid baseline visit and disease severity is according to what was reported at their baseline visit.

Clarifying Points:

1. Table 2a is a subset of Table 1
2. The sum of yearly columns in Table 2a should be less than or equal to the yearly enrollment in Table 1

a. The sum of columns “Initiation and No Follow-up” and ‘Initiation and Any Follow-up” regardless of time

b. Any differences noted would likely be due to missing disease severity measures and should be noted as such

3. Each registry lead should choose the disease activity measure that is most appropriate for their indication. If unsure, please consult with ClinEpi.

4. If this table is not available/applicable for your registry, simply include “N/A” instead of an empty table.


Table 2b. Number of initiations by Disease Sub-Type and Drug and Year 
Description:

Drug initiations categorized by the year the drug was started. Initiations are only counted if they have a valid baseline visit and disease subtype is according to what was reported at their baseline visit.

Note: RA registry don't have sub-type, so this talbe is N/A 

Table 3. Drug Starts by Drug and Year

Description:
Drug starts categorized by their timing (pre- or at/after enrollment) and by enrollment year (for pre-enrollment starts) or the year the drug was started (for at/after enrollment starts). not baseline visit required

Clarifying Points:
1. There are no timing restrictions when defining a baseline visit
2. Only count drug initiations in the “at/after enrollment” category

*2024-5-22 Wendi update FU time period on Registry lead meeting 
6 months fu (5-9 monthes):  >=5*365.25/12 & <=9*365.25/12 
12 months fu (10-15 months): > 9*365.25/12 & <=15*365.25/12 


************************************************************************************
Guidance on Timing, Access, and Folder Structure

Timing:

This report should align with the schedule of existing quarterly reports, i.e., should be created/run/releases on the same day as the Registry’s Quarterly Report. For example, the 2024 Q2 version of this report would be expected when the 2024 Q2 quarterly reports come out.

The first version of this report, 2024 Q1, should be available by the first week of June 2024.
Access to Reports:

Biostatistics Department (read/write access)

ClinEpi Department (read access)

Leslie Harrold (read access)

Folder Structure: Location: SharePoint site -> Biostat and Epi Team -> Biostat Initiations Report -> 2024 -> Quarter#

All registries can put their reports in the same quarterly folder

File Structure:

Please include registry name and quarter: “Initiations_Report_RegistryAbbreviation_Quarter#”


********************************************************************************************************/ 

cap log close 

cd "~\Corrona LLC\Biostat Data Files - RA\registry_counts\RA Initiation Report\2025"

global data "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\2025-04-01" 

local q "2025Q1"

log using "RA_initiation_report_`q'_2025-04-10.log", replace 

use   "$data\2_2_allinits_$datacut", clear 

// drop if visitdate>=d(1Oct2024) for 2024Q3 report data cut 2024-09-30 

gen fu_yes=visit_indexn<visit_indexN if grpindexn==1 

gen f6=1 if fu_days>=(5*365.25/12) & fu_days <=9*365.25/12 // 5-9 months of drug start
gen f12=1 if fu_days> 9*365.25/12  & fu_days<=15*365.25/12   // 10-15 months 

foreach x in 6 12 {
	egen fu`x'=sum(f`x'), by(subject_number druggrp) 
	replace fu`x'=1 if fu`x'>1 & fu`x'<. 
	drop f`x' 
}


keep if grpindexn==1 

gen fu_no=1 if fu_yes==0 
gen drug_yr=year(init_date) 
drop if drug_yr<2020 

// 2025-04-04 adding 2025
for any 20 21 22 23 24 25: gen yrX=drug_yr==20X 
gen tot=1 


drop if init_date-visitdate>42  // no baseline start to base visit>6 weeks 

sort subject_number visitdate druggrp 
merge m:1 subject_number visitdate using "$data\2_3_keyvisitvars_$datacut", keepus(cdai*) 
keep if _m==3
drop _m  

save table1&2_`q', replace 


* for table 3 data 

use  "$data\2_1_drugexpdetails_$datacut", clear 

// drop if visitdate>=d(1Oct2024) for 2024Q3 report data cut  

gen generic=. 

foreach x in adalimumab etanercept infliximab golimumab rituximab tofacitinib { 
replace generic=1 if generic_key=="`x'"
} 

keep if drug_start==1| generic_start==1 
keep if drug_category==250 | drug_category==390 

preserve 
keep if generic==1 & generic_start==1 
keep subject_number *visit* *generic* drug_date drug_category 
drop drug_start* drug_stop* drug_base_visit
for any key indexn indexN status start stop start_date stop_date start_visit stop_visit start_order stop_order init_date base_visit: rename generic_X drug_X     
for any init_  : rename Xgeneric Xdrug 
sort subject_number drug_key drug_date 
save generic.dta,  replace 
restore 

drop *generic* *steroid* discontinued*

append using generic.dta 

drop if drug_start!=1 | drug_start==1 & drug_start_date==. 


* initiation at/after enrollment 
replace init_drug=. if init_drug==1 & drug_init_date==. 
replace init_drug=0 if init_drug==1 & visit_indexn==1 & ( drug_base_visit==. | drug_init_date==.) 

* start pre-enrollment 
gen prestart=1 if drug_start==1 & init_drug!=1 & visit_indexn==1 

keep if prestart==1| init_drug==1 

* start/initiation by year 

gen drug_yr=year(drug_start_date) if drug_start==1 
drop if drug_yr<2020 

// 2025-04-04 adding 2025
for any 20 21 22 23 24 25: gen yrX=drug_yr==20X 

save table3_`q', replace 

*********************************** Report output **********************************************



use table1&2_`q', clear 

// tab 1. initiation at/after enrollment with baseline by fu-no, fu-yes, fu6, fu12

foreach i in yr20 yr21 yr22 yr23 yr24 yr25 tot { 
	
matrix `i'=J(30, 4, .) 	
	
local r=1 
qui foreach x in cimzia	enbrel	erelzi	etanercept	humira	amjevita adalimumab	remicade renflexis inflectra avsola	 remicade_bs infliximab	simponi	simponi_aria golimumab	actemra	orencia	rituxan	truxima	ruxience rituxan_bs	rituximab kevzara	kineret	xeljanz	xeljanz_xr	tofacitinib	rinvoq	olumiant { 
	local c=1 
	foreach y in fu_no fu_yes fu6 fu12 { 	
	count if druggrp=="`x'" & `i'==1 & `y'==1  
	matrix `i'[`r', `c']=(r(N)) 
	local ++c 
	} 
	
	local ++r 
}	
matrix list `i'  
} 

putexcel set "Initiations_Report_RAUS_`q'.xlsx", sheet("Table 1") modify 
putexcel B5=matrix(yr20)  F5=matrix(yr21)  J5=matrix(yr22) N5=matrix(yr23)  R5=matrix(yr24)  V5=matrix(yr25) Z5=matrix(tot)

																	
*********************************************************

* table 2a 

foreach i in yr20 yr21 yr22 yr23 yr24 yr25 { 
	
matrix `i'=J(30, 4, .) 	
	
local r=1 
qui foreach x in cimzia	enbrel	erelzi	etanercept	humira	amjevita adalimumab	remicade renflexis inflectra avsola	 remicade_bs infliximab	simponi	simponi_aria golimumab	actemra	orencia	rituxan	truxima	ruxience rituxan_bs	rituximab kevzara	kineret	xeljanz	xeljanz_xr	tofacitinib	rinvoq	olumiant { 
	local c=1 
	forvalue y = 0/3 { 	
	count if druggrp=="`x'" & `i'==1 & cdai_cat4==`y'  
	matrix `i'[`r', `c']=(r(N)) 
	local ++c 
	} 
	
	local ++r 
}	
matrix list `i'  
} 

putexcel set "Initiations_Report_RAUS_`q'.xlsx", sheet("Table 2a") modify 
putexcel B5=matrix(yr20)  F5=matrix(yr21)  J5=matrix(yr22) N5=matrix(yr23)  R5=matrix(yr24) V5=matrix(yr25)
 

 **************************************
 
 * Table 3: Drug Starts by Drug and Year 
 
use table3_`q', clear 

foreach i in yr20 yr21 yr22 yr23 yr24 yr25 { 
	
matrix `i'=J(30, 2, .) 	
	
local r=1 
qui foreach x in cimzia	enbrel	erelzi	etanercept	humira	amjevita adalimumab	remicade renflexis inflectra avsola	 remicade_bs infliximab	simponi	simponi_aria golimumab	actemra	orencia	rituxan	truxima	ruxience rituxan_bs	rituximab kevzara	kineret	xeljanz	xeljanz_xr	tofacitinib	rinvoq	olumiant { 
	local c=1 
	foreach y in prestart init_drug { 	
	count if drug_key=="`x'" & `i'==1 & `y' ==1  
	matrix `i'[`r', `c']=(r(N)) 
	local ++c 
	} 
	
	local ++r 
}	
matrix list `i'  
} 

putexcel set "Initiations_Report_RAUS_`q'.xlsx", sheet("Table 3") modify 
putexcel B5=matrix(yr20)  D5=matrix(yr21)  F5=matrix(yr22) H5=matrix(yr23)  J5=matrix(yr24) L5=matrix(yr25)

cap erase generic.dta 

cap log close 