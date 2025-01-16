/*
2024-07-10
using updated v20240701z base views 

2024-04-29 
Criteria:	
1	start and stop pairs
2	only starts with continue/last visit
3	only stops no start information
4	history for prevalent initiators at the drug record and history is calculated at start of drug
5	We need all the initiations occurring in the prior 12 months before enrollment (prevalent initiation) and include prev_init variable
6	stacking drug/generic keys into druggrp

2024-04-22
create 2.4_drugexp data for pv use
1. only include start and stop pairs
2. only include pv requested columns 
study_source_acronym	site_number	site_id	subject_number	dw_event_type_acronym	c_effective_event_date	c_provider_id	full_version	at_visit	drug_category	drug_name	drug_name_code	drug_key	generic_key	enroll_visit	last_visit	hx_generic	init_generic	hx_drug	init_drug	generic_start	generic_stop	generic_start_date	generic_stop_date	generic_start_visit	generic_stop_visit	drug_start	drug_stop	drug_start_date	drug_stop_date	drug_start_visit	drug_stop_visit	generic_init_date	generic_base_visit	drug_init_date	drug_base_visit	hx_adalimumab	hx_arava	hx_azulfidine	hx_corticosteroids	hx_cuprimine	hx_cyclosporine	hx_etanercept	hx_golimumab	hx_imuran	hx_infliximab	hx_invest	hx_minocin	hx_mtx	hx_plaquenil	hx_ridaura	hx_rituximab	hx_sirukumab	hx_tofacitinib	hx_orencia	hx_amjevita	hx_humira	hx_kineret	hx_cimzia	hx_enbrel	hx_erelzi	hx_simponi	hx_simponi_aria	hx_avsola	hx_inflectra	hx_remicade	hx_remicade_bs	hx_renflexis	hx_rituxan	hx_rituxan_bs	hx_ruxience	hx_truxima	hx_kevzara	hx_actemra	hx_olumiant	hx_xeljanz	hx_xeljanz_xr	hx_rinvoq	hx_kenalog	hx_meth_pred	hx_pred	nhx_b_ts_generic
*/

*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\temp"


use 2_1_drugexpdetails_$datacut, clear


/* 2024-10-21 Bob requested "error source" variables for start/stop dates 
PsO example 
    Error code for start date |      Freq.     Percent        Cum.
------------------------------+-----------------------------------
                     No error |     50,601       83.17       83.17 ==>needed, same as drug date 
      Day missing in original |      2,241        3.68       86.86 ==>needed
Month+day missing in original |      2,905        4.77       91.63 ==>needed
                   Post-dated |          3        0.00       91.64
                 Missing date |      5,057        8.31       99.95 ==>needed
   Sourced from change record |         26        0.04       99.99
              Out of sequence |          3        0.00      100.00
        Illogical date edited |          2        0.00      100.00 ==>wrong date value
------------------------------+-----------------------------------
                        Total |     60,838      100.00

*/

gen drug_date_raw_year=substr(drug_date_raw, 1,4)
destring drug_date_raw_year, replace 
tab drug_date_raw_year 

gen drug_date_raw_mon=substr(drug_date_raw, 6,2)
destring drug_date_raw_mon, force replace 
replace drug_date_raw_mon=. if drug_date_raw_mon==0
tab drug_date_raw_mon

gen drug_date_raw_day=substr(drug_date_raw, 9,2)
destring drug_date_raw_day, force replace 
replace drug_date_raw_day=. if drug_date_raw_day==0
tab drug_date_raw_day 

lab define date_impute 1 "No imputation" 2 "Day missing in original" 3 "Month+day missing in original" 4 "Drug year out of range" 5 "Imputed differently from original"  9 "No original data", modify 

foreach x in drug generic{
    foreach y in start stop{
	    cap drop `x'_`y'_date_impute
	    gen `x'_`y'_date_impute=.
		replace `x'_`y'_date_impute=1 if `x'_`y'==1 & `x'_`y'_date<. & year(`x'_`y'_date)==drug_date_raw_year & month(`x'_`y'_date)==drug_date_raw_mon & day(`x'_`y'_date)==drug_date_raw_day // 1=exactly the same date 

		replace `x'_`y'_date_impute=2 if `x'_`y'==1 & `x'_`y'_date<. & year(`x'_`y'_date)==drug_date_raw_year & month(`x'_`y'_date)==drug_date_raw_mon & drug_date_raw_day==. // 2= missing day only, month and year are the same as raw
		
		replace `x'_`y'_date_impute=3 if `x'_`y'==1 & `x'_`y'_date<. & year(`x'_`y'_date)==drug_date_raw_year & drug_date_raw_mon==. & drug_date_raw_day==. // 3= missing month and day, the same year 		
		replace `x'_`y'_date_impute=4 if `x'_`y'==1 & `x'_`y'_date<. & (drug_date_raw_year<1960 | drug_date_raw_year>2024 & drug_date_raw_year<.) // 8= drug year out of range 

		replace `x'_`y'_date_impute=5 if `x'_`y'==1 & `x'_`y'_date<. & `x'_`y'_date_impute==. & (year(`x'_`y'_date)!=drug_date_raw_year | month(`x'_`y'_date)!=drug_date_raw_mon | day(`x'_`y'_date)!=drug_date_raw_day) // 4. all other imputed,  with year or month or day not the same as raw data 
			
		replace `x'_`y'_date_impute=9 if `x'_`y'==1 & `x'_`y'_date<. & drug_date_raw=="" // 9=completely missing
	
		lab var `x'_`y'_date_impute "Type of imputation for `x' `y' date"
		
		lab val `x'_`y'_date_impute date_impute
	}
}

tab drug_start_date_impute if drug_start==1 & drug_start_date<., m 
tab drug_stop_date_impute if drug_stop==1 & drug_stop_date<., m 
tab generic_start_date_impute if generic_start==1 & generic_start_date<., m 
tab generic_stop_date_impute if generic_stop==1 & generic_stop_date<., m 

* br drug_start drug_start_date drug_date_raw  drug_start_date_impute if drug_start==1 & drug_start_date!=. & drug_start_date_impute==5

// examples for imputation: subject did not report any enbrel use on visits #14-15 and reported enbrel start date in 2009 on visit 2017. Coded enbrel as restarted in 2017. 
* for any 000000063: list subject_number visitdate report_date visit_indexn drug_key drug_date drug_date_raw drug_status drug_start_date drug_start_date_impute if subject_number=="X" & drug_key=="enbrel", noobs ab(16)

// 2024-04-29 add prev_initdrug/generic to data created by Ying for ROM monthly enrollment report.
*prevalent init: initiation prior enrollment in 12 months with continue use at the enrollment -no stop at enrollment 
foreach x in drug generic{

// no baseline, initiation prior enrollment 
clonevar init_`x'_copy=init_`x'
replace init_`x'_copy=0 if init_`x'==1 & visit_indexn==1 & ( drug_base_visit==. | drug_start_date==.) 
replace init_`x'_copy=0 if init_`x'==1 & drug_init_date==. & visit_indexn>1  // none

sort subject_number `x'_key visitdate `x'_start drug_date 
by subject_number `x'_key: gen cum`x'start=sum(`x'_start) if visit_indexn==1 
by subject_number `x'_key: gen cum`x'stop=sum(`x'_stop) if visit_indexn==1 

clonevar `x'stopdt=`x'_stop_date 
by subject_number `x'_key: replace `x'stopdt=`x'stopdt[_n-1] if visit_indexn==1 & `x'stopdt==. & `x'stopdt[_n-1]<. 

by subject_number `x'_key visitdate `x'_start: gen `x'vtn=_n  if visit_indexn==1 & `x'_start==1 
by subject_number `x'_key visitdate `x'_start: gen `x'vtN=_N  if visit_indexn==1 & `x'_start==1 

egen prinit`x'=sum(init_`x'_copy) if visit_indexn==1, by(subject_number `x'_key visitdate) 

sort subject_number `x'_key visitdate drug_date 
by subject_number `x'_key visitdate: gen prev_init`x'=1 if visit_indexn==1 & `x'vtN==1 & prinit`x'!=1 & enroll_visit-`x'_start_date<366  & (cum`x'stop==0 | cum`x'stop==1 & `x'stopdt>enroll_visit & `x'stopdt[_N] > enroll_visit & `x'stopdt[_N]<. | `x'_status[_N]<3) 

// added 2024-05-03 by Ying
replace prev_init`x'=. if prev_init`x'==1 & `x'_start_date==visitdate & cumpt_reported_en==1 // 623 cases 
replace prev_init`x'=. if `x'_indexn>1  & prev_init`x'==1 

// added by LG for FDA approval date and Ying's limitation with valid drug/generic_start_date
replace prev_init`x'=. if prev_init`x'==1 & `x'_start_date<fda_approval_date & fda_approval_date<.
replace prev_init`x'=. if prev_init`x'==1 & `x'_start==1 & `x'_start_date==.

lab var prev_init`x' ny
drop cum`x'start cum`x'stop `x'stopdt `x'vtn `x'vtN prinit`x' init_`x'_copy
} 

save temp\2_4_temp, replace 


use temp\2_4_temp, clear

preserve 
keep if drug_start==1
keep study source_acronym	site_number	subject_number	dw_event_type_acronym	c_effective_event_date	c_provider_id	full_version	at_visit	drug_category	drug_name	drug_name_code	drug_key enroll_visit	last_visit	hx_drug	init_drug prev_initdrug drug_start drug_start_order drug_start_date drug_start_date_impute drug_start_visit drug_init_date	drug_base_visit	nhx_b_ts_generic hx_orencia hx_adalimumab hx_humira hx_amjevita  hx_cyltezo hx_hadlima hx_hulio hx_hyrimoz hx_yusimry hx_kineret hx_cimzia hx_etanercept hx_enbrel hx_erelzi hx_golimumab hx_simponi hx_simponi_aria hx_infliximab hx_remicade hx_inflectra hx_avsola hx_ixifi hx_renflexis hx_remicade_bs hx_rituximab hx_rituxan hx_truxima hx_ruxience hx_riabni hx_rituxan_bs hx_kevzara hx_sirukumab hx_actemra hx_olumiant hx_tofacitinib hx_xeljanz hx_xeljanz_xr hx_rinvoq hx_arava hx_azulfidine hx_cuprimine hx_cyclosporine hx_imuran hx_minocin hx_mtx hx_plaquenil hx_ridaura hx_corticosteroids hx_pred hx_kenalog hx_meth_pred hx_invest		
save temp\drug_hx_at_start, replace 
restore 

keep if drug_stop==1|drug_indexn==drug_indexN & drug_stop==. //|generic_stop==1|generic_indexn==generic_indexN & generic_stop==.

keep subject_number	drug_key drug_start_order drug_stop drug_start_date drug_start_visit  enroll_visit drug_stop_date drug_stop_date_impute drug_stop_visit	

unique subject_number drug_key drug_start_order // unique 

merge 1:1 subject_number drug_key drug_start_order using temp\drug_hx_at_start 
drop _m
ds *drug*, v(32)

rename drug_key druggrp 
rename drug_start_date start_date
rename drug_start_date_impute start_date_impute
rename drug_start_visit start_visit
rename drug_start_order start_order
rename hx_drug hx
rename drug_start start 
rename drug_base_visit base_visit 
rename drug_stop stop 
rename drug_stop_date stop_date 
rename drug_stop_date_impute stop_date_impute 
rename drug_stop_visit stop_visit 
rename init_drug init 
rename drug_init_date init_date
rename prev_initdrug prev_init 

save temp\drug_exp, replace 


// for generic exposure 

use temp\2_4_temp, clear

preserve 
keep if generic_start==1
keep study_acronym source_acronym	site_number	subject_number	dw_event_type_acronym	c_effective_event_date	c_provider_id	full_version	at_visit	drug_category	drug_name	drug_name_code	generic_key enroll_visit last_visit	hx_generic	init_generic prev_initgeneric generic_start generic_start_order generic_start_date generic_start_date_impute generic_start_visit generic_init_date	generic_base_visit	nhx_b_ts_generic hx_orencia hx_adalimumab hx_humira hx_amjevita  hx_cyltezo hx_hadlima hx_hulio hx_hyrimoz hx_yusimry hx_kineret hx_cimzia hx_etanercept hx_enbrel hx_erelzi hx_golimumab hx_simponi hx_simponi_aria hx_infliximab hx_remicade hx_inflectra hx_avsola hx_ixifi hx_renflexis hx_remicade_bs hx_rituximab hx_rituxan hx_truxima hx_ruxience hx_riabni hx_rituxan_bs hx_kevzara hx_sirukumab hx_actemra hx_olumiant hx_tofacitinib hx_xeljanz hx_xeljanz_xr hx_rinvoq hx_arava hx_azulfidine hx_cuprimine hx_cyclosporine hx_imuran hx_minocin hx_mtx hx_plaquenil hx_ridaura hx_corticosteroids hx_pred hx_kenalog hx_meth_pred hx_invest	
save temp\generic_hx_at_start, replace 
restore 

keep if generic_stop==1|generic_indexn==generic_indexN & generic_stop==.

keep subject_number	generic_key generic_start_order generic_stop generic_start_date generic_start_visit enroll_visit generic_stop_date generic_stop_date_impute generic_stop_visit	

unique subject_number generic_key generic_start_order // unique 

merge 1:1 subject_number generic_key generic_start_order using temp\generic_hx_at_start 
drop _m

keep if inlist(generic_key, "adalimumab", "etanercept", "golimumab", "infliximab", "rituximab", "tofacitinib", "corticosteroids")

rename generic_key druggrp 
rename generic_start_date start_date
rename generic_start_date_impute start_date_impute
rename generic_start_visit start_visit
*drop drug_start_order  
rename hx_generic hx
rename generic_start start 
rename generic_base_visit base_visit 
rename generic_stop stop 
rename generic_stop_date stop_date 
rename generic_stop_date_impute stop_date_impute
rename generic_stop_visit stop_visit 
rename init_generic init 
rename generic_init_date init_date
rename prev_initgeneric prev_init 
rename generic_start_order start_order
save temp\generic_exp, replace 

use temp\drug_exp, clear
append using temp\generic_exp

lab var prev_init "prevalent initiator"
order study source_acronym	site_number	subject_number	dw_event_type_acronym	c_effective_event_date	c_provider_id	full_version	at_visit	drug_category	drug_name	drug_name_code	druggrp enroll_visit	last_visit hx init init_date base_visit nhx_b_ts_generic prev_init start stop start_date start_date_impute stop_date stop_date_impute start_visit stop_visit 
lab var subject_number "subject ID"
lab var site_number	"site ID"
lab var c_effective_event_date	"date of office visit when drug use was reported by MD"
lab var dw_event_type_acronym	"form type" 
lab var full_version "form version"
lab var study_ "study: RA or CERTAIN"
lab var source_acronym	"data source: preTM, TM or RCC"
lab var c_provider_id "provider ID"
*lab var dw_event_instance_uid		"event instance UID"
*lab var c_event_created_date	"created date"
*lab var c_event_last_modified_date	"last modified date"
lab var druggrp "drug group"
lab var prev_init "prevalent initiators"

// 2024-06-06 update, if start_date is missing, then code start to missing 
replace start=. if start_date==.

save 2_4_drugexposures_$datacut, replace 

// 2024-10-21 testing data, send to PV for testing 
* save temp\2_4_drugexposures_updated_2024-10-21, replace 
* corcf * using 2_4_drugexposures_2024-10-01, id(subject_number druggrp start_order)
tab start_date_impute if start_date!=.,m
tab stop_date_impute if stop_date!=.,m 

unique subject_number druggrp start_order

// eliminate extra data 
cap erase temp\drug_exp.dta
cap erase temp\generic_exp.dta
cap erase temp\generic_hx_at_start.dta
cap erase temp\2_4_temp.dta

corcf * using "$pdata\2_4_drugexposures_$pdatacut", id(subject_number druggrp start_order)
//drug_name: 37 mismatches
*corcf drug_name using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-07-01\2_4_drugexposures", id(subject_number druggrp start_order) noobs verbose


