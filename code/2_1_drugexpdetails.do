/*
2025-01-02
1. compress all data before saving 
2. small fix for drug status with >3 skipped visits 
bug fix for previously coded continuous but skipped visits and with raw drug status as start at the beginning of at least 3 skipped visits,  120010013    orencia affects total of 50 and 10 are b/tsDMARDs

2024-10-30 added more biosimilars to drug key, fixed errors for some drugtxt extractions

2024-10-08 bug fixes 
1. for the 2024-09-17 fix, exclude rituxan. rows #526-527; affecting ROM rituxan re-start counts by adding 50%; after examples showing two infusion days are within 1 year, should be continue instead of restart 
2. for one row at FU 

2024-08-16 bug fixes

Not imputing start dates for drugs stopped prior to enrollment date, as it will cause start/stop dates being the same, per GR's email on 2024-07-16; 
Not imputing start dates for csDMARDs with another csDMARDs stopped prior to the current csDMARDs at enrollment visit; 

2024-07-10 
v20240701z build 

2024-06-18 
notes from UCB counts for cimzia initiators, found start_dates for 3 subjects are not correct 
064010150 086030474 636397067 
2024-06-03 
waiting for the 20240601 build. cleaning code by deleting unwanted lines and try to run all together


2024-05-21 
try to use disc due to ae variable from TAE forms to define a stop 

2024-05-08
fix bugs, found from Rhiannon and Ying's monthly reason disc report 

reason of disc is only available for MD forms. for TM data, when there is a MD form with disc date in month and then a TAE form is available with exact dates, the TAE row will be marked as stop, because the MD drug date will be YYYY-MM-01. we need to carry the reason of disc from the MD visit to the TAE row so it is easier to find the reason of disc 

2024-05-07
fix bugs 
1. wherever using dw_event_type to identify enrollment or FU, use visit_indexn instead; preTM has EN happening after FU; 
2. imputing start_date at enrollment where there are other drug episodes happening prior to the drug start 
3. xeljanz changed to xeljanz xr without any other drugs in between within the same visit, code all stop->start as continue for generic tofa.
4. If at enrollment the drug status is continue, do not count as init.

2024-04-05 
update using the v20240401 build 

2024-04-03 
1. Bob found missing start_date for 667839441 infliximab, not started at enrollment and should use the prev_visit and the drug date. check how to fix it; 
2. Discussed with Ying regarding the new definition of pres and the count of pres for QRR

2024-04-02
not creating pres_X for b/tsDMARDs, create wide format for QRR only, check remicade counts. v20240305 counted 9,055 for remicade, lower than Q4 2023 report of 9,242, check why.

2024-03-28 
during feasibility counts for UCB, found cimzia initiator with a init date in 2019 but reported in 2023 and prev visit is also in 2023. 
try to find the error of coding for start date 

2024-03-20
also modify drug/generic status that as long as drug plan is 3-6, status is 2-continue

2024-03-19 
update requested by PV to separate drug start-stop pairs at enrollment. 
Use the drug_status raw data for stop, do not combine 001080016 enbrel as one episode
 
2024-03-08
add variable labels
eliminate temp vars 

2024-03-07
use v20240305 build 
try to make drug_status consistent with generic_status if a drug like orencia does not have biosimilars 

2024-02-29 
need to modify coding for hx_X. Some drugs only have one start row and hx=0, but hx_X should be 1 after the row. 

2024-02-27 refine pres to pres_drug and pres_generic and refine pres_X at visit level 

2024-02-22 
change wide drug history from hxX to hx_X 

2024-02-21 
in respond to Bernice's query about one or two drug episodes prior to enrollment 

2024-02-20 
1. increase the range of baseline visit from 155 days (4 months from the 1st to the 31st) to 183 days (straight 6 months)

2024-02-16 
adjust imputation for stop date. If from continue to start, use the midpoint between the current and the next drug date. Example, 4th exposure for 003001448 orencia 

2024-02-15 
1. compare start and stop pairs 
2. drop if generic_key is missing drug_key="other_ra"

2024-02-13
1. use v20240202 data 
2. for different dosages on the same drug date: 
	keep the most frequently reported one
	keep the earliest one
	keep the one with values 
	
3. make adjustments for drug/generic starts

2024-01-26
adjust order, link visitdate first then identify start and stop 

2024-01-25
1. add start_X for other b/tsDMARDs needed for initiators file 
2. add labels to unlabeled variables, change not used text variables to raw, coded *_code to *, such as renaming drug_category to drug_category_raw; drug_category_code to drug_category,
2024-01-22
1. the 6 and 12 months FU in the data did not include the visits that had no drug records. Need to add them so there are more 6/12 months of FU dates 
2. pres_cDMARDs needs to be created 

2024-01-17 start of 2_2 DrugExp data 
1. create wide format of thx and current_cDMARDs

2024-01-16

1. create drug_status, start/stop dates using drugkey for b/tsDMARDs only 
2. put 2_1_drug_exp_details new vars into data dictionary 

2024-01-12
create start_date/stop dates, base_visit/fu_grp for cDMARDs  
2024-01-11 
1. refine missing start dates or stop dates 
2. create init_date, base_visit, fu_days for b/tsDMARDs initiations

2024-01-10
1. find baseline visit for init b/tsDMARDs
2. code start and stop dates for cDMARDs 

2024-01-09 
after counts of initiation, create generic drug start date and drug stop date
2024-01-08 
update drug_status definition, if raw data is continue and drug date is the same as visitdate, it means drug was reported in dose and frequency only. 
2024-01-04
update data dictionary for 1_6_RADrugRecord data 
2023-12-29
list more unmatched init examples to see anything needs to be adjusted.

2023-12-28
after testing and comparing with dwsub1 
1. check drug dates, FU on day 01 and EN has a date in the same month 
2. Adjust for hx: for pt reported drug use, separate curr_dmards_X from prev_*_md/prev_drugs_*. At enrollment, hx=1 if curr_dmards_X==1 and drug date is missing or prior to the enrollment month 
3. adjust for init: init=1 event if drug_plan_code=3. 

2023-12-11
use v20231201 build 
added one more clean step for 1_6_RADrugRecord data by dropping duplicated visits that reported same drug information
2023-11-27 
compare init in exp data but not in dwsub1, check reasons other than pt reported curr_dmards_X 

2023-11-17 update
using v20231115 build 

2023-11-16 moved generic key and clean drug date into clean doi code 

2023-11-15 use v20231110 build 
2023-11-14 update after discussion with Ying
1. use 1.2_allvisits data for visit_indexN, last visit and next visit dates 
2. for rituxan stop/continue at the last visit date, use >12 month for stop 
3. for started and stopped (one row of drug record), use the drug date as start date and the next visitdate as the stop date 
4. use cordisone as generic key for pred related drugkeys 
v20231103 build 

v20231027 build 

v20231020 build 

v20231013 build 

2023-09-21 
build RAdrug exposure details 

*global bdmards "actemra amjevita avsola cimzia enbrel enbrel_bs erelzi humira humira_bs inflectra kevzara kineret orencia remicade remicade_bs renflexis rituxan rituxan_bs simponi simponi_aria sirukumab truxima ruxience"

*global tsdmards "xeljanz xeljanz_xr rinvoq olumiant"
*/


*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\temp\LGtest_2024-08-12"

*cap log close


*log using 2_1_drugexpdetails_2024-08-01.log,append // replace 

/*2024-04-03 check missing start date 
use "..\2_1_drugexpdetails", clear 
for any 667839441: br generic_key visitdate visit_indexn generic_start generic_start_date generic_stop generic_stop_date if subject_number=="X" & inlist(drug_category, 250,390)*/ 
// create patient reported prev_x from preTM_RA
// create patient reported curr_dmards_X data from preTM for coding of hx 
// 2023-12-26 separate curr_dmards_X from prev_*_md or prev_drugs, only when curr_dmards=1 at en and stdt is different from enrollment month, code as hxX=1, if curr_dmards=1 at enrollment and drug_date is in the same month as the enrollment visit, hxX=0.

/////////////////////	Do not need to repeat this part 
/*
use "~\Corrona LLC\Biostat Data Files - RA\monthly\CSG & Access\PreTM_RA", clear
ds *infusion*, v(32)
ds prev_drugs_*, v(32)
ds prev_*_md, v(32)
ds curr_dmards_*, v(32)
ds *_dt_st, v(32)
codebook form_master_id 

keep if form_master_id==1 
keep optional_id visitdate prev_drugs_* prev_*_md curr_dmards_* infusion_date *_dt_st
drop prev_*_dt_st
drop actonel_dt_st aredia_dt_st boniva_dt_st ert_hrt_dt_st evista_dt_st forteo_dt_st fosamax_dt_st invest_agent_dt_st miacalcin_dt_st oth_bio_dt_st oth_dmard_dt_st oth_op_dt_st reclast_dt_st curr_dmards_uncertain curr_dmards_no_dmards curr_dmards_other_dmard prev_drugs_actonel prev_drugs_boniva prev_drugs_cuprimine prev_drugs_didronel  prev_drugs_estrogen prev_drugs_evista  prev_drugs_forteo prev_drugs_fosamax prev_drugs_miacalcin prev_drugs_reclast prev_drugs_ridaura prev_drugs_solganal prev_drugs_none_antirheu_c1 

replace rituxan_dt_st=infusion_date if rituxan_dt_st=="" & curr_dmards_rituxan==1 // 318

drop infusion_date

save preTM_pt_drugs_en_wide, replace 

// 2024-01-16, also use drug_key from pt_reported_en
// reshape to long format and generate generic code 
// 2024-02-29, keeping drug_key for patient reported hx, so generic hx and drug hx can match 

use  preTM_pt_drugs_en_wide, clear 

rename *_dt_st start_date*
rename curr_dmards_* curr_dmards*
rename prev_drugs_* prev_drugs*
rename prev_*_md prev_md*

reshape long curr_dmards start_date prev_drugs prev_md, i(optional_id visitdate) j(drugkey) string
// change start_date to numeric 
gen startdate = daily(start_date, "YMD")
format startdate visitdate %tdCCYY-NN-DD

count if curr_dmards==1 & month(visitdate)==month(startdate) & year(visitdate)==year(startdate) // 392 
*br if curr_dmards==1 & month(visitdate)==month(startdate) & year(visitdate)==year(startdate)
// do not count as hx if curr_dmards is yes but the start_date is the same as visit month
drop if curr_dmards==1 & month(visitdate)==month(startdate) & year(visitdate)==year(startdate)

tab drugkey,m 
tab prev_drugs,m
tab prev_md,m 
tab curr_dmards,m 

keep if curr_dmards==1|prev_drugs==1|prev_md==1
// 2024-01-16 separate drug_key and generic_key 
clonevar drug_key=drugkey 
replace drug_key="mtx" if strpos(drugkey, "mtx")
replace drug_key="cyclosporine" if drugkey=="neoral"
replace drug_key="minocin" if strpos(drugkey, "minocin")
groups drug_key drugkey, sepby(drug_key) missing ab(16)
gen generic_key=""
replace generic_key="adalimumab" if drugkey=="humira"|drugkey=="humira_bs"|drugkey=="amjevita"
replace generic_key="etanercept" if drugkey=="enbrel"|drugkey=="enbrel_bs"|drugkey=="erelzi"
replace generic_key="certolizumab pegol" if drugkey=="cimzia"
replace generic_key="infliximab" if drugkey=="remicade"|drugkey=="remicade_bs"|drugkey=="inflectra"|drugkey=="renflexis"|drugkey=="avsola"
replace generic_key="golimumab" if drugkey=="simponi"|drugkey=="simponi_aria"
replace generic_key="abatacept" if drugkey=="orencia"
replace generic_key="tocilizumab" if drugkey=="actemra"
replace generic_key="rituximab" if drugkey=="rituxan"|drugkey=="rituxan_bs"|drugkey=="ruxience"|drugkey=="truxima"
replace generic_key="sarilumab" if drugkey=="kevzara"
replace generic_key="tofacitinib" if drugkey=="xeljanz"|drugkey=="xeljanz_xr"
replace generic_key="baricitinib" if drugkey=="olumiant"
replace generic_key="upadacitinib" if drugkey=="rinvoq"
replace generic_key="anakinra" if drugkey=="kineret"
replace generic_key="sirukumab" if drugkey=="sirukumab"
// csDMARDs
replace generic_key="mtx" if strpos(drugkey, "mtx")
replace generic_key="cyclosporine" if drugkey=="neoral"
replace generic_key=drugkey if strpos(drugkey,"minocin")|drugkey=="imuran"|drugkey=="plaquenil"|drugkey=="arava"|drugkey=="azulfidine"
replace generic_key="minocin" if strpos(drugkey, "minocin")
groups generic_key drugkey , missing ab(16) sepby(generic_key)

drop drugkey 

unique optional_id visitdate generic_key drug_key
unique optional_id visitdate drug_key
duplicates drop optional_id visitdate generic_key, force 

rename optional_id subject_number

save preTM_pt_drugs_en_long, replace
*/

use  clean_table\1_6_drugrecord_$datacut, clear

//////////////////////////////////////////////////////////////////////////////////
//	A. updated 2024-02-14 further de-duplicate dosage to make drug date unique 
//////////////////////////////////////////////////////////////////////////////////
// use the mode to fill in the missing rows for drug_plan, dose/freq and reason, then deduplicate
 
duplicates tag subject_number drug_key drug_date, gen(dup10)
tab dup10,m 

/*
testing 1.6 data after fixing drug date imputation

      dup10 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  1,061,425       90.92       90.92
*/

////////////////////////////////////////////////////////////////////////////////////////////////////
// get the non-missing, max mode for each item 
egen drug_plan_mode=mode(drug_plan) if dup10>0, by(subject_number drug_key drug_date) 
lab val drug_plan_mode drug_plan 

foreach x in  dose_unit freq_unit {
	cap drop `x'_mode
	egen `x'_mode=mode(`x') if dup10>0,maxmode by(subject_number drug_key drug_date)
	lab val `x'_mode `x'_code
}

foreach x in dose_value freq_value reason_1 reason_1_code reason_2 reason_2_code reason_3 reason_3_code reason_1_category reason_2_category reason_3_category reason_1_category_code reason_2_category_code reason_3_category_code {
	cap drop `x'_mode
	egen `x'_mode=mode(`x') if dup10>0,maxmode by(subject_number drug_key drug_date)
}

// example: 149010336 remicade 2013-03-08
/////////////////////////	A. Execution 
foreach x in drug_plan  dose_unit freq_unit dose_value freq_value reason_1 reason_1_code reason_2 reason_2_code reason_3 reason_3_code reason_1_category reason_2_category reason_3_category reason_1_category_code reason_2_category_code reason_3_category_code {
replace `x'=`x'_mode if dup10>0
}
 
cap drop dup11 difdrug dup10 *_mode

// updated 2024-05-02 use generic key for drug key so the generic dup won't need to be fixed 

duplicates drop subject_number generic_key drug_date, force 
// v20240701z: n=51,994;  v20240331: n=49,144; v20240305 48,855; (45,453 observations deleted)


compress 
save temp\2_1_drugexpdetails_unique_date, replace 

*corcf * using temp\2_1_drugexpdetails_unique_date_old, id(subject_number generic_key drug_date)


use bv_raw\bv_drugs_of_interest, clear
forvalues i=1/3{ 
drop if reason_`i'==""	
preserve 
keep reason_`i'*
duplicates drop *, force 
save temp\reason_`i'_codes, replace 
restore 
}
// 2024-08-12 checking result after changing imputation of drug_date 
* for any 101010781: list subject_number drug_key linked_visit visit_indexn drug_date drug_date_raw drug_status if subject_number=="X" & inlist(drug_key,"humira","xeljanz"), sepby(linked_visit) noobs ab(16)
* for any 101010781: list subject_number generic_key linked_visit visit_indexn drug_date drug_date_raw drug_status if subject_number=="X" & inlist(generic_key,"adalimumab","tofacitinib"), sepby(linked_visit) noobs ab(16)
* for any 100236829:list source dw_event_type subject_number drug_key report_date linked_visit visit_indexn drug_date drug_date_raw drug_plan drug_status if subject_number=="X" & drug_key=="simponi_aria", sepby(linked_visit) noobs ab(16)



// 2024-03-19 update for drug/generic status 
// 2024-05-22 bug fix and testing starts here 
// 2024-09-18 testing if each time a string variable will be sorted the same
/*
use 2_1_drugexpdetails_unique_date,clear
preserve 
keep generic_key drug_key
duplicates drop *, force 
save string_keys, replace 
restore
*/
// 2024-10-03 testing bug fix 
*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-10-01\temp\LG_test_2024-10-03"

use temp\2_1_drugexpdetails_unique_date, clear 
drop reason_1_*
merge m:1 reason_1 using temp\reason_1_codes
drop if _m==2
drop _m
drop reason_2_*
merge m:1 reason_2 using temp\reason_2_codes
drop if _m==2
drop _m
drop reason_3_*
merge m:1 reason_3 using temp\reason_3_codes
drop if _m==2
drop _m

forvalues i=1/3{
groups reason_`i' reason_`i'_code reason_`i'_category reason_`i'_category_code if reason_`i'_category_code==1, missing ab(24) sepby(reason_`i'_category)
groups reason_`i' reason_`i'_code reason_`i'_category reason_`i'_category_code if reason_`i'_category_code==2, missing ab(24) sepby(reason_`i'_category)
groups reason_`i' reason_`i'_code reason_`i'_category reason_`i'_category_code if reason_`i'_category_code==9, missing ab(24) sepby(reason_`i'_category) 
}

///////////////////////////////////////////////////////////////////////////////////////////
//////		A1. create indicator for both generic key and drugkey  (added 2024-01-16)
///////////////////////////////////////////////////////////////////////////////////////////

//2024-09-18 simplified and tested 
cap drop generic_indexn generic_indexN drug_indexn drug_indexN 
foreach x in generic drug{
sort subject_number `x'_key drug_date report_date
by subject_number `x'_key: gen `x'_indexn=_n 
by subject_number `x'_key: gen `x'_indexN=_N 

	lab var `x'_key "`x' key"
	lab var `x'_indexn "`x' indexn"
	lab var `x'_indexN "`x' indexN"
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// start generic, use generic_status; use drug_status for drug_key  
// 2023-12-22 modified by adding drug_plan_code==. for generic_indexn==1, e.g. humira for 002020417   2005-07-27 has drug_plan of continue, should use the midpoint of prev_event and the current drug_date as the start date.

// 2024-02-05 change all drug_plan_code to drug_plan; all event index to visit index  

clonevar generic_status=drug_status 

foreach x in generic drug {

// first drug use without MD reported plan, or MD reported start
// 2024-08-12 except for there is only one row of data and indicating the drug is stopping 
replace `x'_status=1 if `x'_indexn==1 & drug_plan==.|drug_plan==1

// 2024-03-20 continue as long as drug_plan is 3  modify dose or frequency;  5  continue drug plan / no changes; 6  current use
replace `x'_status=2 if `x'_status!=2 & inlist(drug_plan, 3,5,6)

// at enrollment, if drug_plan is continue or drug started > 1 month prior to visitdate then code as continue 
// example 4 have 2 drug use started and stopped way before enrollment. if within 1 mon to a year of enrollment, then code as continue; if more than a year prior to enrollment, keep as start 
// 2024-05-01 do not limit this row anymore. will have fewer prevalant initiators. example: 001010127 humira should have status of start on 2010-01-01.
*replace `x'_status=2 if `x'_status==1 & visit_indexn==1 & inlist(drug_plan,1,2,9)==0 & (linked_visit-drug_date)>30 & (linked_visit-drug_date)<365

// 2024-01-08 if no drug date and only dose and freq is provided, drug_status_raw is continue and is correct. drug date is mapped the same as visitdate. example 001010043 27sep2013 etanercept; 001020004 prednisone
replace `x'_status=2 if `x'_status==1 & drug_status_raw=="continue" & drug_date==linked_visit & drug_date_raw!=""


// stop for 000000000 enbrel, only create stop at the end if drug_plan is missing
replace `x'_status=3 if (`x'_indexn==`x'_indexN & `x'_indexN>1 & drug_plan==.)|inlist(drug_plan,2,8,9) 

// exception for stop, last visit or last visit is within 6 month for rituxan 
replace `x'_status=2 if `x'_status==3 & visit_indexn==visit_indexN & inlist(drug_plan,2,8,9) ==0 
replace `x'_status=2 if `x'_status==3 & inlist(`x'_key,"rituximab","rituxan") & (last_visit-drug_date<=365) 

// continue at FU and not at the end of visits, if drug plan did not indicate start or stop 
// 2024-09-18 testing by adding limitation of not skipped visits: `x'_indexn[_n-1]==`x'_indexn-1; found "unknown" for `x'_status, try not limiting 
replace `x'_status=2 if `x'_indexn>1 & `x'_indexn!=`x'_indexN & `x'_indexN>=3 & inlist(drug_plan, 1,2,8,9)==0 //& `x'_indexn[_n-1]==`x'_indexn-1


// re-start: if there is no visit in between and drug date is more than 3 months apart 
// 2023-11-09 drug stopped and restarted add drug date difference >90 days? at least 4 drug dates available for a pair of stopped and restart 
// 2023-11-09 also make sure drug_plan did not indicate continue, eg. for 1020004 mtx use.
// 2024-09-18 change from visit_indexn to drug_date or `x'_indexn visit_indexn 
// 2024-10-30 adding more rituxan biosimilars into the list where rituxan is related 

sort subject_number `x'_key drug_date 

by subject_number `x'_key: replace `x'_status=1 if inlist(drug_plan, 3,5,6,2,8,9)==0 & visit_indexn-1>visit_indexn[_n-1] & `x'_status==2 & `x'_indexn>1 & `x'_indexn!=`x'_indexN & `x'_indexN>=4 & drug_date-drug_date[_n-1]>90 & inlist(`x'_key,"rituximab","rituxan","riabni","ruxience","truxima","rituxan_bs")==0

// adjusted for 1020004 mtx, stopped 19jun2017 prior to start identification on 28nov2018
// or maybe after code re-start, just code the previous one as stop.
by subject_number `x'_key: replace `x'_status=3 if inlist(drug_plan, 3,5,6)==0 & visit_indexn+1<=visit_indexn[_n+1] & `x'_status==2 & `x'_indexn>1 & `x'_indexn!=`x'_indexN & `x'_indexN>=4 & drug_date[_n+1]-drug_date>90 & inlist(`x'_key,"rituximab","rituxan","riabni","ruxience","truxima","rituxan_bs")==0 & `x'_status[_n+1]==1


// 2023-11-09, example actemra for 036010196: if stopped and restart dates are the same dates as previous drug dates, then recode as continue
// 2024-05-07 after de-duplicate by drug date, there won't be any same drug dates. change to the same month between the two episodes
// 2024-07-02 cannot replace to continue if drug_plan indicates stop==>fixing inconsistency between humira and ada 101011364 on 2021-10-28
// 2024-09-18 unique by drug date, no need to add `x'_indexn, also already sorted in row #462
*sort subject_number `x'_key drug_date 
by subject_number `x'_key: replace `x'_status=2 if `x'_status==3 & inlist(drug_plan,2,8,9) ==0 & year(drug_date)==year(drug_date[_n-1]) & month(drug_date)==month(drug_date[_n-1]) & `x'_indexn>1 & `x'_indexn!=`x'_indexN & `x'_indexN>=4 
by subject_number `x'_key: replace `x'_status=2 if `x'_status==1 & drug_plan!=1 & year(drug_date)==year(drug_date[_n-1]) & month(drug_date)==month(drug_date[_n-1]) & `x'_indexn>1 & `x'_indexn!=`x'_indexN & `x'_indexN>=4 

// 2023-11-09 if start is identified in between and no stop prior to the start, then still code as continue 
*by subject_number drugkey: replace drug_status=2 if drug_status==1 & drug_status[_n-1]==2 
by subject_number `x'_key: replace `x'_status=2 if `x'_status==3  & `x'_status[_n-1]==2 & (`x'_status[_n+1]==2|`x'_status[_n+1]==3) & inlist(drug_plan,2,8,9)==0

// added 2023-11-09: if there are two starts before and after, then code as stop; if continue before and start after then code as stop (eg 1020004 mtx 24jun2019). 
// modified 2023-12-13: added drug_plan_code==. for pt 000000000 enbrel reported at enrollment  
by subject_number `x'_key: replace `x'_status=3 if `x'_status==2  & `x'_status[_n+1]==1 & (`x'_status[_n-1]==1|`x'_status[_n-1]==2) & drug_plan==.

// 3 starts in a row, change the middle one to stop for plaquenil 001020004   24jun2019
// 2024-08-12 only change if drug_plan==. example  100236829 simponi_aria 2022-01-13, but should be fixed by the change for 1.6
by subject_number `x'_key: replace `x'_status=3 if `x'_status==1  & `x'_status[_n+1]==1 & `x'_status[_n-1]==1 & drug_plan==.

// 2023-11-13 for 1020004 pred use, one start and one stop and skipped visits, code both as start.
by subject_number `x'_key: replace `x'_status=1 if `x'_status==3 & `x'_indexN==2 & visit_indexn-visit_indexn[_n-1]>1 & inlist(drug_plan,2,8,9)==0

// 2024-02-09 continuation between two stops, example 001020071 xeljanz_xr, code the middle continue as start 
by subject_number `x'_key: replace `x'_status=1 if `x'_status==2 & `x'_status[_n-1]==3 & inlist(drug_plan,2,8,9)==0

// 2024-03-20 added for PV pre-enrollment separate two drug episodes, eg. 001080016 enbrel and 006030099 orencia 
replace `x'_status=1 if drug_status_raw=="start" & drug_plan==. & visit_indexn==1 //dw_event_type=="EN"
replace `x'_status=3 if drug_status_raw=="stop" & drug_plan==. & visit_indexn==1 //dw_event_type=="EN"

// 2024-05-02 added, if start-stop-stop and 2 stops are within the same month, 205020177 example humira at EN
// 2024-06-05 added withint 30 days in addition to within the same calendar month, to accomodate 2 stops for example 4 205020177 cimzia 
by subject_number `x'_key: replace `x'_status=2 if `x'_status==3 & `x'_status[_n+1]==3 & (year(drug_date)==year(drug_date[_n+1]) & month(drug_date)==month(drug_date[_n+1])|drug_date[_n+1]-drug_date<30)

// 2024-05-22 update, code as stop if discontinued_due_to_ae. If two stop due to ae and the difference is less than 60 days, use the later one 
// 900+ generic / drug 
replace `x'_status=3 if `x'_status!=3 & discontinued_due_to_ae=="yes"
// if both TAE reported disc, use the later one if the two reported dates are within 30 days.
by subject_number `x'_key: replace `x'_status=2 if `x'_status==3 & discontinued_due_to_ae=="yes" & discontinued_due_to_ae[_n+1]=="yes" & drug_date[_n+1]-drug_date<30
// if the next visit also reported stop within 30 days, code as continue 
by subject_number `x'_key: replace `x'_status=2 if `x'_status==3 & discontinued_due_to_ae=="yes" & `x'_status[_n+1]==3 & drug_date[_n+1]-drug_date<30

// 2024-06-05 update, if two starts are within the same calendar month and linked to the same visit, then code the 2nd start as continue. Examples 4 actemra and example 10 for humira.  
// 2024-07-02 update, remove the restriction of within the same calendar month. As long as there are 2 starts linked to the same visit, code the 2nd start as continue. Also trying to fix inconsistency between humira and ada for 101011364 linked to visit #4, drug dates 2022-11-01 and 2023-01-05: removed & year(drug_date)==year(drug_date[_n-1]) & month(drug_date)==month(drug_date[_n-1]) , added 120 days limit and drug_plan did not indicate start or stop.
by subject_number `x'_key: replace `x'_status=2 if  `x'_status==1  & `x'_status[_n-1]==1 & visit_indexn==visit_indexn[_n-1] & (drug_date-drug_date[_n-1]<121) & inlist(drug_plan,1,2,8,9)==0

// 2024-07-03 update: if there is a single drug row with drug status raw as stop, should code as stop intead of start. eg  101010781 humira/adalimumab==> causing pres numbers drop.
// 2024-08-12 changed from linked_visit-1 to linked_visit
replace `x'_status=3 if `x'_indexn==1 & `x'_indexN==1 & `x'_status==1 & drug_plan!=1 & drug_status_raw=="stop" & drug_date==linked_visit & reason_1!="" & visit_indexn>1
// 2024-09-18 bug fix for drug status being continue but should be stop, with skipped visits and drug_status_raw is stop 
// 2024-10-08 exclude rituxan. stop for rituxan means last infusion date. change for ROM code. 
by subject_number `x'_key: replace `x'_status=3 if  drug_plan==. & drug_status_raw=="stop" & `x'_status==2 & `x'_status[_n+1]==2 & visit_indexn[_n+1]>visit_indexn+1 & visit_indexn[_n+1]!=. & inlist(`x'_key,"rituximab","rituxan","riabni","ruxience","truxima","rituxan_bs")==0

// 2024-12-31 bug fix for previously coded continuous but skipped visits and with raw drug status as start at the beginning of at least 3 skipped visits,  120010013    orencia affects total of 50 and 10 are b/tsDMARDs
by subject_number `x'_key: replace `x'_status=1 if  drug_plan==. & drug_status_raw=="start" & `x'_status==2 & `x'_status[_n+1]==2 & visit_indexn-visit_indexn[_n-1]>3 & visit_indexn[_n-1]!=. & inlist(`x'_key,"rituximab","rituxan","riabni","ruxience","truxima","rituxan_bs")==0

// 2024-10-03 bug fix for drug status: only one row of stop, drug status should be stop instead of start, so the exposure of the drug will not likely be overlapped with other drugs. it is similar to dwsub1 btwadd, and should be counted as drug use for quarterly reports. updated quarterly report code too to address this situation. it is not a pres in 2.1 data, but will be counted for table 5 for QRR. Also exclude rituxan  
replace `x'_status=3 if `x'_indexN==1 & drug_status_raw=="stop" & drug_plan==. & `x'_status==1 & visit_indexn>1 & inlist(`x'_key,"rituximab","rituxan","riabni","ruxience","truxima","rituxan_bs")==0
	
lab var `x'_status "`x' status" 
}

// 2024-07-03 check inconsistency between humira and ada & inlist(generic_key,"adalimumab")==>fixed for 101011364 but not drug/generic status for 101010781 
*for any 101010781 101011364: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if subject_number=="X" , noobs ab(12) sepby(generic_key)


// 2024-05-07 update, for generic with biosimilars only, if within the same visit, drug_key is different but generic_key is the same, code from stop to continue 
sort subject_number generic_key generic_indexn 
foreach x in generic {
	// within the same visit, drug changed within the same generic, example 006040073  
	by subject_number generic_key: replace `x'_status=2 if `x'_status==3 & drug_status==3 & visit_indexn==visit_indexn[_n-1] & visit_indexn==visit_indexn[_n+1] & generic_key==generic_key[_n-1] & generic_key==generic_key[_n+1] & drug_key!=drug_key[_n+1] & inlist(generic_key, "adalimumab","corticosteroids","etanercept", "golimumab", "infliximab", "rituximab", "tofacitinib")

	// MD reported drug stop but changed to the same generic for the next visit, example 001060048 xeljanz 
	by subject_number generic_key: replace `x'_status=2 if `x'_status==3 & drug_status==3 & drug_key!=drug_key[_n+1] & drug_plan==2 & generic_key==generic_key[_n-1] & generic_key==generic_key[_n+1] & visit_indexn==visit_indexn[_n+1]-1 & inlist(generic_key, "adalimumab","corticosteroids","etanercept", "golimumab", "infliximab", "rituximab", "tofacitinib")
	by subject_number generic_key: replace `x'_status=2 if `x'_status==1 & drug_status==1 & drug_key!=drug_key[_n-1] & drug_plan[_n-1]==2 & generic_key==generic_key[_n-1] & generic_key==generic_key[_n+1] & visit_indexn==visit_indexn[_n-1]+1 & inlist(generic_key, "adalimumab","corticosteroids","etanercept", "golimumab", "infliximab", "rituximab", "tofacitinib")
}


// use generic status for drugs without any biosimilars. generic status were more accurate
// 2024-08-12 add cdmards to the list!! 
foreach x in orencia cimzia kevzara actemra olumiant rinvoq arava azulfidine cyclosporine imuran minocin mtx plaquenil cuprimine ridaura{
	display "`x'"
* groups drug_status generic_status if drug_key=="`x'", sepby(drug_status) missing ab(20)
replace drug_status=generic_status if drug_status!=generic_status & drug_key=="`x'"
}


groups drug_status generic_status,missing ab(20)  
/*
v20250113
  +-------------------------------------------------+
  | drug_status   generic_status    Freq.   Percent |
  |-------------------------------------------------|
  |       start            start   194984     17.29 |
  |       start         continue     1386      0.12 |
  |       start             stop       73      0.01 |
  |    continue            start      100      0.01 |
  |    continue         continue   801881     71.10 |
  |-------------------------------------------------|
  |    continue             stop      123      0.01 |
  |        stop            start       61      0.01 |
  |        stop         continue     1985      0.18 |
  |        stop             stop   127244     11.28 |
  +-------------------------------------------------+

  +-------------------------------------------------+
  | drug_status   generic_status    Freq.   Percent |
  |-------------------------------------------------|
  |       start            start   215737     19.20 |
  |       start         continue     1389      0.12 |
  |       start             stop      112      0.01 | tested 001020016 002031812 tofa , ok 
  |    continue            start      151      0.01 | no need to modify based on 001020113 tofa 
  |    continue         continue   750995     66.83 |
  |-------------------------------------------------|
  |    continue             stop      226      0.02 |no need to change based on 001010019 tofa  
  |        stop            start      112      0.01 |no need to change based on 001040002 tofa 
  |        stop         continue     1891      0.17 |
  |        stop             stop   153168     13.63 |
  +-------------------------------------------------+
*/
*save temp\2_1_drugexpdetails_status_test_2024_10-30, replace
*br subject_number report_date drug_date linked_visit visit_indexn drug_key generic_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if drug_status==3 & generic_status==1

//for any : list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if subject_number=="X" & strpos(generic_key,"tofa"), noobs ab(12) sepby(generic_key)

*count if drug_status==2 & drug_status_raw=="continue" & generic_status==1 // 139, change for consistency

//2024-12-31 testing results for added row # 529
for any  120010013 015010763 030120163 100273676 101010216 101011398 145010013 147010095 359476932 611891639: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn if subject_number=="X"  & inlist(drug_category, 250,390), noobs ab(12) sepby(generic_key) 

compress
save temp\2_1_drugexpdetails_status, replace
// 2025-01-14 note from discussion with Page and Skyler. Found humira does not have a stop flag on visit 9. There should be a stop and a stop date should be imputed, because cimzia started on visit #10. 
for any 001010063: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn if subject_number=="X"  & inlist(drug_category, 250,390), noobs ab(12) sepby(generic_key)

count if drug_indexn==2 & drug_indexN==2 & drug_status==2 & inlist(drug_plan,3, 5,6) & inlist(drug_category, 250,390) // 7,144 and 2,468 b/tsDMARDs
 
// examples as of 2024-10-08 fix 
// examples for prednisone  
*for any 001020065 001020233: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if subject_number=="X" & strpos(generic_key,"corti"), noobs ab(12) sepby(generic_key)

// examples for rituximab
*for any 000000056 000123476 000591001: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if subject_number=="X" & generic_key=="rituximab", noobs ab(12) sepby(generic_key)

// example for enbrel provided by Bob.
*for any 001040002: list dw_event_type subject_number report_date drug_date linked_visit visit_indexn drug_key drug_plan drug_status drug_status_raw drug_indexn generic_status generic_indexn if subject_number=="X" & inlist(drug_key,"actemra", "enbrel", "orencia"), noobs ab(12) sepby(generic_key)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////	A2. create drug/treatment history 
////////////////////////////////	Add all visits data to DOI data 
 

rename linked_visit visitdate 
*merge m:1 subject_number visitdate generic_key drug_key using "~\Corrona LLC\Biostat Data Files - RA\monthly\for_update\preTM_pt_drugs_en_long"

// 2024-02-29 adding drug_key to match hx status for both generic and drug 
merge m:1 subject_number visitdate generic_key drug_key using ..\..\for_update\preTM_pt_drugs_en_long
/*
v20241203---->fixed 
    Result                           # of obs.
    -----------------------------------------
    not matched                     1,073,411
        from master                 1,053,943  (_merge==1)
        from using                     19,468  (_merge==2)

    matched                            69,776  (_merge==3)
    -----------------------------------------
*/

///////////	to carry enrollment reported pt use to DOI event data
tab generic_key if _m==2 
cap drop pt_reported_en
gen pt_reported_en=1 if _m>=2


sort subject_number generic_key drug_key visitdate
*br subject_number generic_key visitdate curr_dmards

cap drop cumpt_reported_en
clonevar cumpt_reported_en=pt_reported_en
by subject_number generic_key drug_key: replace cumpt_reported_en=cumpt_reported_en[_n-1] if cumpt_reported_en==.
lab var cumpt_reported_en "patient reported drug/generic history prior to enrollment visit from preTM data"
// 2023-12-29 maybe keep pt reported drug use for under counted inits.
drop if _m ==2
// 2023-12-29 maybe keep curr_dmards in case drug date reported in later TM visits
drop _m start_date startdate prev_md curr_dmards prev_drugs


//////////////////////////////////////////////////////////////////////////////
////	A2. hxX 
//////////////////////////////////////////////////////////////////////////////
// 2024-02-29 updated row#572, previously drug_status, now fixed to `x'_status; added var labels 

lab define ny 1 yes 0 no, modify
// 2024-01-16 generate hx for both drug_key and generic_key 
/// for long data 
foreach x in generic drug{
cap drop hx_`x' 
gen hx_`x'=0
// after the first use 
replace hx_`x'=1 if `x'_indexn>1|cumpt_reported_en==1 //& dw_event_type=="EN" 
*replace hx=1 if drug_status!=1 & generic_indexN>1 // for single stop row, still code as hx==0
// from addX coding row #624 in cr_dmard at enrollment visit, addX=1 only if started within 4 months of enrollment.
// limit enroll_visit and drug date for generic_indexn==1
// 2023-12-22 try to change from 125 to 30
// 2023-12-28 try to change from 30 to 45.

// 2024-01-05 try to add hx at enrollment to reduce over-counted// hx=1 if MD reported 2=stop or 3=modify 5=continue 6=current
// 2024-05-07 substitute from  dw_event_type=="EN" to visit_indexn==1
replace hx_`x'=1 if `x'_indexn==1 & drug_plan>=2 & drug_plan<. & visit_indexn==1 & drug_date==visitdate 

// 2024-01-08 tried to define 001010043   2013-09-27 hx=1 to reduce over-counted 2024-05-03 the updated code already include the one below.
*replace hx_`x'=1 if `x'_indexn==1 & drug_plan==. & drug_date==visitdate & drug_date_raw!="" & `x'_status==2 & visit_indexn==1
// 2024-04-24  without MD reported drug plan at enrollment, the first drug status is not a start 
replace hx_`x'=1 if `x'_indexn==1 & drug_plan==.  & `x'_status!=1 & visit_indexn==1
lab var hx_`x' "History of `x'"
///////////////////////////////////////////////////////
// create initiation here.
///////////////////////////////////////////////////////
cap drop init_`x' 

gen init_`x'=1 if  hx_`x'==0  //& drug_status!=3 //including start and continue & example: subject_number 000000003 enbrel prev_enbrel_dt_st and prev_enbrel_dt_stp years before enrollment 
*replace init=1 if drug_status==3 & hx==0 & generic_indexN==1 // does not apply for  002020047   25jan2005, generic_indexN==3, init in dwsub1
replace init_`x'=0 if init_`x'!=1 
// 2024-04-03, at enrollment visit, if only one stop row is reported, do not count as init. (247 rows affected)
// 2024-05-06 also adding continuation at enrollment 
replace init_`x'=0 if drug_status!=1 & visit_indexn==1
// 2024-01-05 try to change from 30 to 60 to accommodate eg. 01nov to 31dec.
// 2024-05-03 instead of controlling hx, control init to be within a month of enrollment visit.
replace init_`x'=0 if `x'_indexn==1 & (enroll_visit-drug_date>60) 

lab var init_`x' "Initiation of `x'"
lab val hx_`x' init_`x' ny 

// 2024-05-22 replace hx to 0 where status is start at the very beginning of drug, with drug date prior to enrollment, does not affect coding for init. PV requested change.

replace hx_`x'=0 if `x'_status==1 & drug_status_raw=="start" & `x'_indexn==1 & visit_indexn==1 & drug_date<visitdate & cumpt_reported_en==1
}

// version 12+ examples 
*for any 000000025 000000035 000000040: list study source dw_event_type full_version subject_number drug_key visitdate visit_indexn report_date drug_indexn drug_status drug_date cumpt_reported_en hx_drug init_drug if subject_number=="X" & visit_indexn==1, noobs ab(18) sepby(drug_key)

// version 9 examples ==> report date was in version 7
*for any 000000012 000000013 000000014 000000015: list study source dw_event_type full_version subject_number drug_key visitdate visit_indexn report_date drug_indexn drug_status drug_date cumpt_reported_en hx_drug init_drug if subject_number=="X" & visit_indexn==1, noobs ab(18) sepby(drug_key)

// version 7 examples 
*for any 000000003: list full_version subject_number drug_key visitdate visit_indexn drug_indexn drug_status drug_date cumpt_reported_en hx_drug init_drug if subject_number=="X" & visit_indexn==1, noobs ab(18) sepby(drug_key)


groups hx_generic hx_drug if inlist(drug_category,250,390), missing ab(16)
groups init_generic init_drug if inlist(drug_category,250,390), missing ab(16) //sepby(generic_key)

tab init_drug if drug_key=="enbrel" // v20240901:n=5,325; v20240701z: n=5,281; v20240601: n=5,275; 2024-05-22 updated, 5,261; v20240501: 5,284; 20240418, 5,258; v20240401: 5,257; v20240331 5,266; v20240305:5,247 5,229

sort subject_number generic_key generic_indexn 
*for any 001060048 001060566  001220494 002021365 002022344: list subject_number generic_key drug_key generic_indexn drug_indexn drug_date visitdate generic_status hx_generic init_generic hx_drug init_drug if generic_key=="rituximab" & subject_number=="X", noobs ab(15) sepby(generic_key)


save temp\2_1_expdetails_init, replace

*save temp\2_1_expdetails_init_test_2024-10-30, replace

//////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2024-01-09 create generic drug start date and drug stop date ==>>> b/tsDMARDs only !!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////
// separately create for b/tsDMARDs 
/////////////////////////////////////////////////////////

// 2024 06-18 notes, if two dmards had a large gap, the start_date for the later one will be impacted largely up to 10 years. examples are the 3 UCB cimzia initiators. 064010150 086030474 636397067. TO implement it, if drug status is continue and prev_visit is available, then use the midpoint between current drug date and the prev visit; if prev_visit is not available (at enrollment) and the prev drug date is available, then use the prev drug date. 

// 2024-05-06 use visit_indexn instead of dw_event_type_acronym to identify EN and FU 

// 2024-01-16 separately create start and stop dates for generic vs. drug 
*use temp\2_1_expdetails_init_test_2024-10-03, clear 



// 2024-02-08: also need to create generic/drug_start/stop 
// 2024-05-03 for the imputation of start date=(drug_date+prev_visit)/2 when prev_visit is not missing; if prev_visit is missing, use 
use temp\2_1_expdetails_init, clear 

*use 2_1_expdetails_init_2024-05-07, clear 
*use 2_1_expdetails_init_2024-05-22, clear
*preserve 
keep if drug_category==250|drug_category==390

/* 2025-01-14 test count for change from < to <=
foreach x in generic drug{
sort subject_number drug_date
by subject_number : gen next_`x'=`x'_key[_n+1]  if `x'_indexn==`x'_indexN
by subject_number : gen prev_`x'=`x'_key[_n-1]  if `x'_indexn==1
// ying suggested using the next drug start date directly instead of using the midpoint & `x'_indexn==`x'_indexN& `x'_indexn==`x'_indexN& `x'_indexn==`x'_indexN 
// updated by adding not the same day as the next drug; 
//2024-02-15 added next drug date not missing and `x'_status<3 instead of ==2 
// 2025-01-14 changed from drug_date<drug_date[_n+1] to drug_date<=drug_date[_n+1] because after 001010063 humira, simponi started the same date on visit 9

*by subject_number: replace `x'_stop=1  if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<=drug_date[_n+1] & drug_date[_n+1]!=.
count if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<drug_date[_n+1] & drug_date[_n+1]!=. // 4,045 generic, 4,813 drug
count if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date==drug_date[_n+1] & drug_date[_n+1]!=. // 597/643
count if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<=drug_date[_n+1] & drug_date[_n+1]!=.
}
foreach x in generic drug{
	cap drop next_`x'
	cap drop prev_`x'
}
*/

// overall 
foreach x in generic drug{

// 2024-02-15 added indexn==1 to start=1 
gen `x'_start=1 if `x'_status==1|`x'_indexn==1
gen `x'_stop=1 if `x'_status==3 	

gen `x'_start_date=drug_date if `x'_status==1
gen `x'_stop_date=drug_date if `x'_status==3

gen `x'_start_visit=visitdate if `x'_status==1
gen `x'_stop_visit=visitdate if `x'_status==3

lab var `x'_start "`x' started"
lab var `x'_stop "`x' stopped"

lab var `x'_start_date "`x' started date"
lab var `x'_stop_date "`x' stopped date"

lab var `x'_start_visit "the visit date linked to `x' started date"
lab var `x'_stop_visit "the visit date linked to `x' stopped date"

format `x'_start_date `x'_stop_date `x'_start_visit `x'_stop_visit  %tdCCYY-NN-DD

lab var `x'_start "`x' started"
lab var `x'_stop "`x' stopped"
lab var `x'_start_date "`x' start date"
lab var `x'_stop_date "`x' stop date"
lab var `x'_start_visit "`x' start visit date"
lab var `x'_stop_visit "`x' stop visit date"

// did not report stop, but changed to another drug later, use the midpoint between current drug date and the next_event
// 2024-02-09 remove next drug name limit of `x'_indexn==`x'_indexN, added next_`x'!=`x'_key
// 2024-02-15 add back `x'_key? `x'_indexn==`x'_indexN
sort subject_number drug_date
by subject_number : gen next_`x'=`x'_key[_n+1]  if `x'_indexn==`x'_indexN
by subject_number : gen prev_`x'=`x'_key[_n-1]  if `x'_indexn==1
// ying suggested using the next drug start date directly instead of using the midpoint & `x'_indexn==`x'_indexN& `x'_indexn==`x'_indexN& `x'_indexn==`x'_indexN 
// updated by adding not the same day as the next drug; 
//2024-02-15 added next drug date not missing and `x'_status<3 instead of ==2 
// 2025-01-14 changed from drug_date<drug_date[_n+1] to drug_date<=drug_date[_n+1] because after 001010063 humira, simponi started the same date on visit 9

by subject_number: replace `x'_stop=1  if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<=drug_date[_n+1] & drug_date[_n+1]!=.

by subject_number: replace `x'_stop_date=next_visit if `x'_status<3  & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<=drug_date[_n+1] & drug_date[_n+1]!=.
by subject_number: replace `x'_stop_visit=next_visit if `x'_status<3 & next_visit!=. & next_`x'!="" & next_`x'!=`x'_key & drug_date<=drug_date[_n+1] & drug_date[_n+1]!=.

// 2024-02-09 did not report start but had a stop after a stop from another drug  001020071      xeljanz   2022-01-28
// 2024-02-15 also changed from stop to not start  and current date is later than previous one  eliminated & `x'_status[_n-1]==3 
// 2024-05-09 changed from prev_visit date to last drug date for drug change 
// 2024-05-09 if at a follow-up visit, drug status is continue, drug start date is prior to the last drug_start date due to imputation between the prior and current visit date, use the midpoint between the last drug date and the current drug date instead of the midpoint between the prior visit and the current visit. example 001010200 start xeljanz_xr first then continue xeljanz 

by subject_number: replace `x'_start=1  if `x'_status>1  & prev_visit!=.& prev_`x'!="" & prev_`x'!=`x'_key & drug_date>drug_date[_n-1]
// 2024-06-18 use the midpoint of drug date and prev visit if prev_visit is available, use prev drug date if visit_indexn==1
by subject_number: replace `x'_start_date=(drug_date+prev_visit)/2 if `x'_status>1  & prev_visit!=. & prev_`x'!="" & prev_`x'!=`x'_key & drug_date>drug_date[_n-1]
by subject_number: replace `x'_start_date=(drug_date+drug_date[_n-1])/2 if `x'_status>1 & visit_indexn==1 & prev_`x'!="" & prev_`x'!=`x'_key & drug_date>drug_date[_n-1]
by subject_number: replace `x'_start_visit=visitdate if `x'_status>1  & prev_visit!=. & prev_`x'!="" & prev_`x'!=`x'_key & drug_date>drug_date[_n-1]


/// two stops within the same drug, or 2024-03-21 from stop to continue  
sort subject_number  `x'_key `x'_indexn
by subject_number `x'_key :replace `x'_start=1 if `x'_status!=1 & `x'_status[_n-1]==3 
// if two stops, use the mid point between the drug date and the prev_visit 
// 2024-05-03 use the mid point between two drug dates instead of using prev_visit; prev_visit maybe missing at enrollment.example  001010108 enbrel 
// 2024-06-18 use the midpoint of drug date and prev visit if prev_visit is available, use prev drug date if visit_indexn==1
by subject_number `x'_key :replace `x'_start_date=(drug_date+prev_visit)/2 if visit_indexn>1 & `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_date==.
by subject_number `x'_key :replace `x'_start_date=(drug_date+drug_date[_n-1])/2 if visit_indexn==1 & `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_date==.

// if continue after stop, use the mid point between two drug dates as the start date ==> there will be sorting error, use the same rule
*by subject_number  `x'_key:replace `x'_start_date=(drug_date+drug_date[_n-1])/2 if `x'_status==2 & `x'_status[_n-1]==3 & `x'_start_date==.

by subject_number `x'_key :replace `x'_start_visit=visitdate if `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_visit==.


// did not report stop and have another start, eg. 143011134 enbrel 003001448 orencia 4th exposure; use the midpoint between the current and the next drug date.
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key:replace `x'_stop=1 if `x'_status!=3 & `x'_status[_n+1]==1
by subject_number `x'_key:replace `x'_stop_date=(drug_date+next_visit)/2 if `x'_status!=3 & `x'_status[_n+1]==1
by subject_number `x'_key:replace `x'_stop_visit=next_visit if `x'_status!=3 & `x'_status[_n+1]==1

// drug from continue to start, stop is created but start is not, example  001020004 pred   2015-12-30
by subject_number `x'_key:replace `x'_start=1 if `x'_status>1 & `x'_indexn==1  & `x'_start==. & `x'_status[_n+1]==1

// 2024-04-03 example 667839441 infliximab, fix start date and start visit since X_start is already 1, also fill in start_date by not limiting the next drug status 
by subject_number `x'_key:replace `x'_start_date=(drug_date+prev_visit)/2 if `x'_status>1 & `x'_indexn==1  & `x'_start==1 & prev_visit!=. & `x'_start_date==. // & `x'_status[_n+1]==1 // no start date if prev_visit is not available 
by subject_number `x'_key:replace `x'_start_visit=visitdate if `x'_status>1 & `x'_indexn==1  & `x'_start==1 & `x'_start_visit==. //& `x'_status[_n+1]==1

// only one continue row at the last visit, use the midpoint between prev event and the current drug date as the start date 
*replace start_date=(drug_date+prev_event)/2 if drug_status==2 & generic_indexN==1
// MD reported continue at FU visit 
// 2024-01-11 for only one stop/continue row reported, use the midpoint of prev_event and the stop date as the start date 
// 2024-02-15 corrected from indexn to indexN  
// 2024-05-07 substitute from dw_event_type=="FU" to visit_indexn>1
replace `x'_start=1 if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_date==.
replace `x'_start_date=(drug_date+prev_visit)/2 if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_date==.
replace `x'_start_visit=visitdate if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_visit==.


// for example 4, drug date is reported but coded as continue at EN, use drug date as start_date
// 2024-02-08 code as start if within 1 month of enrollment visit (visitdate-drug_date<31)
// 2024-02-15 rule #5, if drug date < visitdate, use drug date; if drug_date==visitdate, code drug_start_date as missing but drug_start==1 
// 2024-05-07 substitute from dw_event_type=="EN" to visit_indexn==1
replace `x'_start=1 if `x'_status>=2 & drug_date<=visitdate & visit_indexn==1 & `x'_indexn==1
// 2024-08-12 Do not impute a start date.
*replace `x'_start_date=drug_date if `x'_status>=2 & drug_date<visitdate & visit_indexn==1 & `x'_indexn==1

// 2024-05-07 if there is another b/tsDMARDs drug used prior to the current drug, we can still impute start date as the last drug date of the prior drug.
sort subject_number visitdate drug_date 
by subject_number: replace `x'_start_date=drug_date[_n-1] if `x'_status>=2 & drug_date==visitdate & visit_indexn==1 & `x'_indexn==1 
replace `x'_start_visit=visitdate if `x'_status>=2 & drug_date<=visitdate & visit_indexn==1 & `x'_indexn==1


// carry all start dates up to the stop date 
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key: replace `x'_start_date=`x'_start_date[_n-1] if `x'_start_date==.
by subject_number `x'_key: replace `x'_start_visit=`x'_start_visit[_n-1] if `x'_start_visit==.

drop prev_`x' next_`x'
}

// 2025-01-14 note from discussion with Page and Skyler counts for JAKi used together with bDMARDs. Found humira does not have a stop flag on visit 9. There should be a stop and a stop date should be imputed. Found simponi started on the same drug date as humira, changed from < next drug date to <= for the fix. 
for any 001010063: list subject_number visitdate visit_indexn drug_date drug_key drug_plan drug_status drug_status_raw drug_indexn drug_start drug_start_date drug_stop drug_stop_date if subject_number=="X"  & inlist(drug_category, 250,390), noobs ab(12) sepby(generic_key)

compress
save temp\2_1_btsDMARDs_starts, replace

*save temp\2_1_btsDMARDs_starts_2024-10-30, replace


/* 2024-08-13 check bug fix 
sort subject_number generic_key drug_date
for any 101010781 100236829: list drug_key drug_indexn visitdate visit_indexn prev_visit drug_date drug_status generic_status drug_start_date generic_start_date drug_stop_date generic_stop_date if subject_number=="X", sepby(generic_key) noobs ab(18)

// 2024-05-09 check wrong imputation for start date tofa 001010200 
for any 001010200: list drug_key drug_indexn visitdate visit_indexn prev_visit drug_date drug_status drug_start drug_start_date drug_start_visit drug_stop drug_stop_date drug_stop_visit if subject_number=="X", sepby(drug_key) noobs ab(18)

// 2024-04-03 check missing start date for example Bob M had provided 
for any 667839441: list drug_key drug_indexn visitdate visit_indexn prev_visit drug_date drug_status drug_start drug_start_date drug_start_visit drug_stop drug_stop_date drug_stop_visit if subject_number=="X", sepby(drug_key) noobs ab(18)
*/

mdesc *_start_* *_stop_* ,ab(32) 
tab drug_start if drug_start_visit!=. & drug_start_date==.,m

// at EN, some drug start dates are missing but drug start visits are the enrollment visit, and drug start visits are carried to the end  
*br subject_number visitdate drug_key drug_status drug_start drug_start_date drug_start_visit if drug_start_visit!=. & drug_start_date==.

*for any 000000010: br subject_number visitdate drug_key drug_status drug_start drug_start_date drug_start_visit if subject_number=="X"

count if drug_start_date>drug_start_visit & drug_start_date<. // 170 ==>184 v20240601: 189==>174

count if drug_stop_date>drug_stop_visit & drug_stop_date<. // 24==>166 v20240601: 173==>180


/* 2024-03-27 correction for drug start and start visit 
*for any : br subject_number drug_key drug_date drug_status drug_indexn drug_indexN drug_start drug_start_date drug_start_visit drug_stop  visitdate prev_visit visit_indexn visit_indexN  if subject_number=="X"
for any 245020005:list dw_event_type subject_number  drug_plan generic_key generic_status generic_indexn  drug_date visitdate visit_indexn generic_start generic_start_date generic_start_visit generic_stop generic_stop_date generic_stop_visit if subject_number=="X" & inlist(drug_category,250,390), noobs ab(12) sepby(generic_key)
//// 2024-02-15 spot QC for start/stop pairs 
*use 2_1_btsDMARDs_starts_2024-03-27, clear
for any 064010517:list dw_event_type subject_number  drug_plan generic_key generic_status generic_indexn  drug_date visitdate visit_indexn generic_start generic_start_date generic_start_visit generic_stop generic_stop_date generic_stop_visit if subject_number=="X" & inlist(drug_category,250,390), noobs ab(10) sepby(generic_key)
*/
//////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2024-01-12 create generic drug start date and drug stop date ==>>> cDMARDs only !!!!
//////////////////////////////////////////////////////////////////////////////////////////////////////////

*use  ".\temp_data\build_doi_exp_details_v20231215_2024-01-10", clear
*codebook drug_category

//////////////////////////////////////////////////////////////////////////////////////////////
// separately create for cDMARDs or other (690:cDMARDs, 710: pred; 900 includes invest_agent)
//////////////////////////////////////////////////////////////////////////////////////////////
use temp\2_1_expdetails_init, clear 


*use temp\2_1_expdetails_init_test_2024-10-30, clear 


drop if drug_category==250|drug_category==390 

// 2024-01-16 separately create for generic vs. drug 

// overall 
foreach x in generic drug{
	
// 2024-02-15 added indexn==1 to start=1 
gen `x'_start=1 if `x'_status==1|`x'_indexn==1
gen `x'_stop=1 if `x'_status==3 	
gen `x'_start_date=drug_date if `x'_status==1
gen `x'_stop_date=drug_date if `x'_status==3

gen `x'_start_visit=visitdate if `x'_status==1
gen `x'_stop_visit=visitdate if `x'_status==3

lab var `x'_start "`x' started"
lab var `x'_stop "`x' stopped"

lab var `x'_start_date "`x' started date"
lab var `x'_stop_date "`x' stopped date"

lab var `x'_start_visit "the visit date linked to `x' started date"
lab var `x'_stop_visit "the visit date linked to `x' stopped date"

format `x'_start_date `x'_stop_date `x'_start_visit `x'_stop_visit  %tdCCYY-NN-DD

/* b/tsDMARDs only: did not report stop, but changed to another drug later, use the midpoint between current drug date and the next_event
sort subject_number drug_date
by subject_number: gen next_generic=generic_key[_n+1]  if generic_indexn==generic_indexN 
replace stop_date=(drug_date+next_event)/2 if drug_status==2 & generic_indexn==generic_indexN & next_event!=.& next_generic!=""
*/
// 2024-02-14 update: 001020004 pred 2020-08-18 started and not reported in later visits, generic_indexn=indexN and visit_indexn<visit_indexN, should create stop date and stop visit as the next visitdate 
replace `x'_stop=1 if `x'_indexn==`x'_indexN & visit_indexn<visit_indexN & `x'_status!=3
replace `x'_stop_date=next_visit if `x'_indexn==`x'_indexN & visit_indexn<visit_indexN & `x'_status!=3
replace `x'_stop_visit=next_visit if `x'_indexn==`x'_indexN & visit_indexn<visit_indexN & `x'_status!=3

/// two stops within the same drug, or 2024-03-21 from stop to continue  
sort subject_number  `x'_key `x'_indexn
by subject_number `x'_key :replace `x'_start=1 if `x'_status!=1 & `x'_status[_n-1]==3 
// 2024-05-03 use the mid point between two drug dates instead of using prev_visit; prev_visit maybe missing at enrollment. example  001010108 enbrel 
// 2024-06-18 use the midpoint between drug date and prev_visit if not at enrollment. two b/tsDMARDs maybe 10 years apart. 
by subject_number `x'_key :replace `x'_start_date=(drug_date+prev_visit)/2 if visit_indexn>1 & `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_date==.
by subject_number `x'_key :replace `x'_start_date=(drug_date+drug_date[_n-1])/2 if visit_indexn==1 & `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_date==.
// if continue after stop, use the mid point between two drug dates as the start date ==> there will be sorting error, use the same rule
*by subject_number  `x'_key:replace `x'_start_date=(drug_date+drug_date[_n-1])/2 if `x'_status==2 & `x'_status[_n-1]==3  & `x'_start_date==.

by subject_number `x'_key :replace `x'_start_visit=visitdate if `x'_status!=1 & `x'_status[_n-1]==3 & `x'_start_visit==.

// did not report stop and have another start, eg. 143011134 enbrel 
// 2024-02-09 change from ==1 to !=3, example 001020004 mtx
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key:replace `x'_stop=1 if `x'_status!=3 & `x'_status[_n+1]==1
by subject_number `x'_key:replace `x'_stop_date=(drug_date+next_visit)/2 if `x'_status!=3 & `x'_status[_n+1]==1
by subject_number `x'_key:replace `x'_stop_visit=next_visit if `x'_status!=3 & `x'_status[_n+1]==1

// drug from continue to start, stop is created but start is not, example  001020004 pred   2015-12-30
by subject_number `x'_key:replace `x'_start=1 if `x'_status>1 & `x'_indexn==1  & `x'_start==. & `x'_status[_n+1]==1
// 2024-04-03 example 667839441 infliximab, fix start date and start visit since X_start is already 1, also fill in start_date by not limiting the next drug status 
by subject_number `x'_key:replace `x'_start_date=(drug_date+prev_visit)/2 if `x'_status>1 & `x'_indexn==1  & `x'_start==1 & prev_visit!=. & `x'_start_date==. // & `x'_status[_n+1]==1 // no start date if prev_visit is not available 
by subject_number `x'_key:replace `x'_start_visit=visitdate if `x'_status>1 & `x'_indexn==1  & `x'_start==1 & `x'_start_visit==. //& `x'_status[_n+1]==1

// only one continue row at the last visit, use the midpoint between prev event and the current drug date as the start date 
*replace start_date=(drug_date+prev_event)/2 if drug_status==2 & generic_indexN==1

// MD reported continue at FU visit 
// 2024-01-11 for only one stop row reported, use the midpoint of prev_event and the stop date as the start date 
// 2024-05-07 substitute dw_event_type=="FU" with visit_indexn>1
replace `x'_start=1 if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_date==.
replace `x'_start_date=(drug_date+prev_visit)/2 if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_date==.
replace `x'_start_visit=visitdate if `x'_status>1 & `x'_indexN==1 & visit_indexn>1 & `x'_start_visit==.

// for example 4, drug date is reported as prior to EN and coded as continue at EN, use drug date as start_date(visitdate-drug_date<31)
// rule #5, if continue at EN, drug date same as visitdate, code start_date as missing but start as 1.
// 2024-02-15 update, reported stop at enrollment visit, create a start and leave start date as unknown 
// 2024-05-07 substitute dw_event_type=="EN" with visit_indexn==1
replace `x'_start=1 if `x'_status>=2 & drug_date<=visitdate & visit_indexn==1 & `x'_indexn==1
// 2024-08-12 Do not impute a start date 
*replace `x'_start_date=drug_date if `x'_status>=2 & drug_date<visitdate & visit_indexn==1 & `x'_indexn==1
// 2024-05-07 if there is another drug date available prior to the current drug, we can still impute start date as the last drug date of the prior drug.
// 2024-08-19 this imputation of start date does not have to be applied to csDMARDs. Example 002020970 pred start date will be the same as stop date due to imputed start date based on the stop date of mtx. 
*sort subject_number visitdate drug_date 
*by subject_number: replace `x'_start_date=drug_date[_n-1] if `x'_status>=2 & drug_date==visitdate & visit_indexn==1 & `x'_indexn==1 
*replace `x'_start_date=. if `x'_status>=2 & drug_date==visitdate & dw_event_type=="EN" & `x'_indexn==1
replace `x'_start_visit=visitdate if `x'_status>=2 & drug_date<=visitdate & visit_indexn==1 & `x'_indexn==1

// carry all start dates up to the stop date 
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key: replace `x'_start_date=`x'_start_date[_n-1] if `x'_start_date==.
by subject_number `x'_key: replace `x'_start_visit=`x'_start_visit[_n-1] if `x'_start_visit==.
}


append using temp\2_1_btsDMARDs_starts


*append using temp\2_1_btsDMARDs_starts_2024-10-30 


sort subject_number generic_key generic_indexn

// 2024-05-07 moving the start stop order up before saving the data 
foreach x in generic drug{
	sort subject_number `x'_key `x'_indexn 
	by subject_number `x'_key: gen `x'_start_order=sum(`x'_start) //if inlist(drug_category,250,390)
	by subject_number `x'_key: gen `x'_stop_order=sum(`x'_stop)	if `x'_stop==1 //
	lab var `x'_start_order "the order of `x' start"
	lab var `x'_stop_order "the order of `x' stop"
}

compare generic_start_order generic_stop_order if generic_stop==1

compare drug_start_order drug_stop_order if drug_stop==1

compress 
save temp\2_1_allDMARDs_starts, replace 

*save 2_1_allDMARDs_starts, replace


/* 2024-08-13 check bug fix results for not imputing start date at enrollment when drug date is prior to enrollment and status is stop 
for any 001120653 001230701 001240745:list dw_event_type subject_number  drug_plan  drug_key drug_date visitdate visit_indexn generic_start generic_start_date drug_start_date generic_stop generic_stop_date drug_stop_date if subject_number=="X" & inlist(drug_key,"pred"), noobs ab(16) sepby(generic_key) 
// 2024-05-07 checking the updated imputed drug date at enrollment where another drug date is available for xeljanz and xeljanz xr ==>fixed for continuous using for tofa and separated drug_key  
for any 006040073:list dw_event_type subject_number  drug_plan generic_key generic_status generic_indexn drug_key drug_date visitdate visit_indexn generic_start generic_start_date drug_start_date generic_stop generic_stop_date drug_stop_date if subject_number=="X" & inlist(drug_category,250,390), noobs ab(8) sepby(generic_key)

//// 2024-02-15 spot QC for start/stop pairs 

for any 064010517:list dw_event_type subject_number  drug_plan generic_key generic_status generic_indexn  drug_date visitdate visit_indexn generic_start generic_start_date generic_start_visit generic_stop generic_stop_date generic_stop_visit if subject_number=="X" & inlist(drug_category,250,390), noobs ab(10) sepby(generic_key)

// Re-visit examples 1-2 drug_start_datedrug_stop_datedrugtxt

for any 001020004 036010196 :list subject_number drug_key report_date visitdate visit_indexn drug_date drug_date_raw drug_plan generic_status generic_start generic_start_date generic_start_visit generic_stop generic_stop_date generic_stop_visit if subject_number=="X" & inlist(drug_category,250,390)==0 , noobs ab(6) sepby(generic_key)

// Re-visit example 9 drug_status drug_key generic_indexn drug_indexn
// need to add start for indexn==1 
for any 002020417 :list subject_number generic_key  report_date visitdate prev_visit drug_date drug_plan generic_status generic_start generic_start_date generic_start_visit generic_stop generic_stop_date generic_stop_visit if subject_number=="X" & inlist(drug_category,250,390), noobs ab(8) sepby(generic_key)

sort subject_number generic_key generic_indexn  
// found from initiators do file 
for any 001020071:list subject_number drug_key visitdate drug_plan generic_status drug_status  drug_date generic_start generic_start_date generic_stop generic_stop_date drug_start drug_start_date drug_stop drug_stop_date if subject_number=="X" & generic_key=="tofacitinib", noobs ab(8) sepby(generic_key)
*/

// 2024-03-28 check if all start dates <=visits stop dates <=visits 
count if drug_start_date>drug_start_visit & drug_start_date<. // 220==>234==>226==>232
count if drug_stop_date>drug_stop_visit & drug_stop_date<. // 39==>209==>230==>235

mdesc drug_start_date drug_start_visit drug_stop_date drug_stop_visit, ab(32) 


/* 2024-03-21 new list 
// if continue after stop at EN, change drug_status to start if continue and drug_status_raw is start and drug_plan is missing; 
// 2024-05-03 fixed for stop to continue: use the mid point between the last drug date and the current drug date
for any 001010108:list dw_event_type subject_number visitdate visit_indexn drug_date drug_plan generic_key drug_key generic_status drug_status generic_start generic_start_date drug_start_date generic_stop_date if subject_number=="X" & generic_key=="etanercept", noobs ab(10) sepby(generic_key)

// if continue after stop generate start=1 and impute start date  
for any 001010158:list dw_event_type subject_number drug_plan generic_key drug_key generic_status drug_status generic_indexn  drug_date visitdate visit_indexn generic_start generic_start_date generic_stop generic_stop_date generic_start_order generic_stop_order if subject_number=="X" & generic_key=="rituximab", noobs ab(10) sepby(generic_key)

for any 027010076  090010025:list dw_event_type subject_number drug_plan generic_key generic_status generic_indexn  drug_date visitdate visit_indexn generic_start generic_start_date generic_stop generic_stop_date generic_start_order generic_stop_order if subject_number=="X" , noobs ab(10) sepby(generic_key)
// Bernice's example, overlapped exposure ==>fixed 
for any 003001448: list subject_number drug_key drug_indexn drug_plan drug_date visitdate visit_indexn drug_status drug_start_date drug_stop_date drug_start drug_stop drug_start_order drug_stop_order if  subject_number=="X" & drug_key=="orencia", noobs ab(10) sepby(generic_key)

// updated 2024-07-02 UCB examples  ==>fixed 
for any  064010150 086030474 636397067 : list drug_key subject_number visitdate visit_indexn prev_visit drug_date drug_start_date init_drug drug_status drug_status_raw  if subject_number=="X" & drug_key=="cimzia", noobs ab(16) sepby(drug_key)

// updated 2024-07-03 GR's examples ==>fixed 
for any  101010781 : list drug_key subject_number visitdate visit_indexn prev_visit drug_date drug_start_date drug_stop_date init_drug drug_status drug_status_raw  if subject_number=="X" , noobs ab(16) sepby(drug_key)

use 2_1_allDMARDs_starts, clear*/

use temp\2_1_allDMARDs_starts, clear
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// 2024-01-12: try to create baseline_visit (within 6 months prior to the initiation, if initiation is prior to a visit) for b/tsDMARDs and cDMARDs initiators 
foreach x in generic drug{
gen `x'_init_date=`x'_start_date if init_`x'==1 

format `x'_init_date %tdCCYY-NN-DD
lab var `x'_init_date "`x' initiation date"

// carry to each following drug records 
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key: replace `x'_init_date=`x'_init_date[_n-1] if `x'_init_date==.

/* general rule of base_visit: 
if init_date is the same as linked_visit, use linked visit;
if not exactly the same date, the same month also works due to MD reported drug date can only be in months
if not in the same month, check the difference between init date and the prev visit date. use 4 month which is up to (4+1)*31=155 days?
*/ 
cap drop `x'_base_visit 
gen `x'_base_visit=visitdate if `x'_init_date==visitdate & init_`x'==1
replace `x'_base_visit=visitdate if `x'_base_visit==. & year(visitdate)==year(`x'_init_date) & month(visitdate)==month(`x'_init_date) & init_`x'==1
replace `x'_base_visit=prev_visit if `x'_base_visit==. & `x'_init_date-prev_visit<=183 & init_`x'==1
// carry to each following drug records 
sort subject_number `x'_key `x'_indexn
by subject_number `x'_key: replace `x'_base_visit=`x'_base_visit[_n-1] if `x'_base_visit==.

format `x'_base_visit %tdCCYY-NN-DD
lab var `x'_base_visit "Baseline visit for `x' initiators"
}

///////////////////////////////////	2024-01-17 start to create wide format of hx DMARDs and pres cDMARDs for LOT and mono/combo therapy 
*use "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\data\custom_table\2_1_DrugExpDetails", clear 
// 2024-02-29 update, for example hx_adalimumab hx_humira hx_amjevita  if subject_number=="002033107"
//abactacept, sarilumab, certolizumab_pegol, sirukumab, arava, azulfidine, cyclosporine, imuran, minocin, mtx, plaquenil, cuprimine, invest, ridaura generic and drug keys are the same, do not include in drug keys list 
# delimit;
global drug_list
"orencia
humira
amjevita 
cyltezo
hadlima
hulio
hyrimoz
yusimry 
kineret
cimzia
enbrel
erelzi 
simponi 
simponi_aria
remicade 
avsola 
inflectra 
ixifi
renflexis 
remicade_bs 
rituxan 
riabni
ruxience 
truxima 
rituxan_bs
kevzara 
actemra
olumiant 
xeljanz
xeljanz_xr
rinvoq
kenalog
meth_pred
pred 
"
;
# delimit cr;

# delimit;
global generic_list 
"
adalimumab
arava
azulfidine
corticosteroids
cuprimine
cyclosporine

etanercept
golimumab
imuran
infliximab
invest

minocin
mtx
plaquenil
ridaura
rituximab
sirukumab
tofacitinib
"
;
#delimit cr;
// 2024-01-19 modify wide hxX to be more accurate 
// create wide hxX and carry forward to all later visits  
// 2024-02-22 change var names to hx_X
// 2024-04-19 create the date where the hx began, all drug dates later than hx X date will have hxX==1  

sort subject_number visitdate drug_date 
//adalimumab
foreach x in  $generic_list {
    cap drop hx_`x'
    gen hx_`x'=0
replace hx_`x'=1 if generic_key=="`x'" & hx_generic==1

gen hx_`x'_date=drug_date if hx_`x'==1 //& hx_generic==1
//2024-02-29 adding if prev_generic_key appeared, hx_X=1
by subject_number: replace hx_`x'=1 if hx_`x'==0 & generic_key[_n-1]=="`x'" 
by subject_number: replace hx_`x'_date=drug_date[_n-1]+1 if hx_`x'==1 & hx_`x'_date==. & generic_key[_n-1]=="`x'" //& drug_date==drug_date[_n-1]

// carry hx_`x'_date for subject_number
egen hx_`x'_firstdate=min(hx_`x'_date) , by(subject_number)
format hx_`x'_date hx_`x'_firstdate %tdCCYY-NN-DD

replace hx_`x'=1 if drug_date>=hx_`x'_firstdate
replace hx_`x'=0 if hx_`x'==1 & drug_date<hx_`x'_firstdate

drop hx_`x'_firstdate hx_`x'_date 

lab var hx_`x' "History of `x'"
lab val hx_`x' ny
} 

/*
for any  000000040: list subject_number visitdate drug_date drug_key hx_drug generic_key hx_generic hx_adalimumab* if subject_number=="X", noobs ab(16) sepby(visitdate)

for any 001020004: list subject_number visitdate drug_date drug_key hx_drug generic_key hx_generic hx_adalimumab* if subject_number=="X", noobs ab(16) sepby(visitdate)

for any 002021196: list subject_number visitdate drug_date drug_key drug_status init_drug hx_drug generic_key hx_generic hx_adalimumab* if subject_number=="X", noobs ab(16) sepby(visitdate)

// humira amjevita*/

foreach x in  $drug_list {
    cap drop hx_`x'
    gen hx_`x'=0
	
replace hx_`x'=1 if drug_key=="`x'" & hx_drug==1

gen hx_`x'_date=drug_date if hx_`x'==1 //& hx_generic==1
//2024-02-29 adding if prev_generic_key appeared once , hx_X=1
by subject_number: replace hx_`x'=1 if hx_`x'==0 & drug_key[_n-1]=="`x'" 
// 2024-04-23 adding one day if drug row only appeared once with hx_drug/generic==0
by subject_number: replace hx_`x'_date=drug_date[_n-1]+1 if hx_`x'==1 & hx_`x'_date==. & drug_key[_n-1]=="`x'" //& drug_date==drug_date[_n-1]

// carry hx_`x'_date for subject_number
egen hx_`x'_firstdate=min(hx_`x'_date) , by(subject_number)
format hx_`x'_date hx_`x'_firstdate %tdCCYY-NN-DD

replace hx_`x'=1 if drug_date>=hx_`x'_firstdate
replace hx_`x'=0 if hx_`x'==1 & drug_date<hx_`x'_firstdate

drop  hx_`x'_date hx_`x'_firstdate

lab var hx_`x' "History of `x'"
lab val hx_`x' ny
}

/*
for any 001020004: list subject_number visitdate drug_date drug_key hx_drug drug_key hx_drug hx_humira* if subject_number=="X", noobs ab(16) sepby(visitdate)

for any 002021196: list subject_number visitdate drug_date drug_key drug_status init_drug hx_drug drug_key hx_drug hx_humira* if subject_number=="X", noobs ab(16) sepby(visitdate)


// check 002021196
for any 002033107: list subject_number visitdate drug_date drug_key hx_drug hx_adalimumab* hx_humira* hx_amjevita*  if subject_number=="X", noobs ab(16) sepby(visitdate)
//
for any  178130226: list subject_number visitdate drug_date drug_key hx_drug generic_key hx_generic hx_adalimumab* hx_humira*  if subject_number=="X", noobs ab(16) sepby(visitdate)

for any 002033107: list subject_number visitdate drug_date drug_key hx_adalimumab hx_humira hx_amjevita  if subject_number=="X", noobs ab(16) sepby(visitdate)

// test  002033107
for any RA-178-0001 : list subject_number visitdate drug_key drug_date drug_start_date init_drug hx_drug hx_enbrel* if subject_number=="X" , noobs ab(16)

 
for any 100326958: list subject_number visitdate drug_key drug_date drug_start_date init_drug hx_drug hx_actemra if subject_number=="X" , sepby(visitdate) noobs ab(16)
*/

*groups hx_eta hx_enbrel hx_erelzi, missing ab(16)
// 2024-10-30 LG added more biosimilars to humira 
groups hx_adalimumab hx_humira hx_amjevita hx_cyltezo hx_hadlima hx_hulio hx_hyrimoz hx_yusimry, missing ab(16)
// 2024-10-30 LG added ixifi to remicade
groups hx_infliximab hx_remicade hx_renflexis hx_inflectra hx_avsola hx_ixifi hx_remicade_bs, missing ab(16)
// 2024-10-30 LG added riabni to rituxan 
groups hx_rituximab hx_rituxan hx_riabni hx_ruxience hx_truxima hx_rituxan_bs, missing ab(16)

*groups hx_tofa hx_xeljanz hx_xeljanz_xr, missing ab(16) // pt reported did not specify xeljanz or xeljanz_xr, use tofa is more accurate

*groups hx_golimumab hx_simponi hx_simponi_aria, missing ab(16) 

*groups hx_corticosteroids hx_pred hx_kenalog hx_meth_pred, missing ab(16)



////////////	Calculation of general line of therapy 
cap drop nhx_b_ts_generic

egen nhx_b_ts_generic=rowtotal(hx_orencia hx_adalimumab hx_kineret hx_cimzia hx_etanercept hx_golimumab hx_infliximab hx_rituximab hx_kevzara  hx_actemra hx_olumiant hx_tofacitinib hx_rinvoq)

lab var nhx_b_ts_generic "number of prior b/ts generics used"
note nhx_b_ts_generic: rowtotal(hx_orencia hx_adalimumab hx_kineret hx_cimzia hx_etanercept hx_golimumab hx_infliximab hx_rituximab hx_kevzara  hx_actemra hx_olumiant hx_tofacitinib hx_rinvoq)

// check enbrel bionaive 
tab nhx_b_ts_generic if drug_key=="enbrel" & init_drug==1,m // 3,047, 57.66%==>3,021, 57.42% ==>v20240601: 3,024, 57.33%==>v20240701z: 3,015, 57.09 ; v20240801 revised, 3,043       57.29

tab nhx_b_ts_generic if drug_key=="humira" & init_drug==1,m // 3,496, 52.75%==>3,476, 52.62% ==>v20240601:3,478, 52.60% ==>v20240701z:3,467       52.43%; v20240801 revised, 3,489       52.58  

///////////////////////////////	2024-01-23 modification 

foreach x in drug generic{
cap drop pres_`x'
gen pres_`x'=1 if `x'_status!=3 & visit_indexn>1
// 2024-10-03 update, if there is only one row and drug_status is stop and at FU visit==>2024-10-08 do not change for 2.1, only update for QRR
*replace pres_`x'=1 if `x'_status==3 & `x'_indexN==1 & dw_event_type=="FU" & source=="TM"
sort subject_number `x'_key visitdate drug_date
// 2024-04-03 update, at enrollment the drug is not stopped yet  
by subject_number `x'_key visitdate: replace pres_`x'=1 if `x'_status[_N]!=3 & `x'_stop[_N]!=1 & visit_indexn==1 //& visitdate-drug_date<366 
// if stopped at enrollment visit, but stop date might be later than the visitdate. stop date is imputed as between the current and the next visit.
by subject_number `x'_key visitdate: replace pres_`x'=1 if `x'_stop[_N]==1 & `x'_stop_date[_N]>visitdate & visit_indexn==1 & `x'_stop_date[_N]<. // & visitdate-drug_date<366
// 2024-04-03 update, check if there are other rows on the same visitdate, same drug_date and drug_status is stop.
*replace pres_`x'=1 if `x'_status==2 & visit_indexn==1 & visitdate==drug_date

lab var pres_`x' "`x' Prescribed"
lab val pres_`x' ny
}

// 2024-10-08 numbers dropped because of the adjustment of drug status to stop 
unique subject_number if pres_drug==1 & drug_key=="remicade" // v20240401 9,338==>v20240501: 9,361==>9,328==> v20240601: 9,340==>v20240701z: 9,354==>v20240801 revised: 9,347

unique subject_number if pres_drug==1 & drug_key=="humira" // 11,238 v20240701z: 11240==>v20240801 revised:11,232
unique subject_number if pres_drug==1 & drug_key=="enbrel" // 11,314 z:11313==>v20240801 revised:11317
unique subject_number if pres_drug==1 & drug_key=="olumiant" // 459->463->460->464 z:468==>v20240801 revised:473
unique subject_number if pres_drug==1 & drug_key=="renflexis" // 291->287->288==>v20240801 revised:287
unique subject_number if pres_drug==1 & drug_key=="inflectra" // 430->431->433 z:431==>v20240801 revised:432

/*
sort subject_number visitdate drug_key drug_indexn 
for any 000123495 000123507 000952462 001020131: list subject_number drug_key drug_indexn drug_indexN drug_status drug_start drug_stop drug_stop_date drug_date visitdate visit_indexn visit_indexN pres_drug if inlist(drug_category, 250,390) & subject_number=="X", noobs ab(16) sepby(drug_key)


// example ==>fixed drug vs. generic status inconsistency 
// 2024-05-07 actemra use at enrollment should be continuous, but was coded as 3 starts pres_drug pres_generic
for any 205020177: list subject_number dw_event_type report_date visitdate visit_indexn drug_key  drug_date drug_status drug_status_raw generic_status  if subject_number=="X" & visit_indexn==1, sepby(drug_key) noobs ab(12)
*/

// 2024-04-02 not including b/tsDMARDs, re-calculate for Quarterly report to make sure remicade is accurate 
sort subject_number visitdate drug_date 
//$drug_list
foreach x in arava azulfidine cyclosporine imuran minocin mtx plaquenil cuprimine ridaura pred {
    cap drop pres_`x'
    gen pres_`x'=0
replace pres_`x'=1 if drug_key=="`x'" & pres_drug==1 
// make pres csdmard the same for the same visitdate  
egen sumpres_`x'=sum(pres_`x'), by(subject_number visitdate)
tab sumpres_`x'
replace pres_`x'=1 if sumpres_`x'>0
drop sumpres_`x'
lab var pres_`x' "`x' prescribed"
lab val pres_`x' ny
}

// create names of cdmards pres_cdmards 
cap drop pres_cdmards_name
gen pres_cdmards_name=""
foreach x in arava azulfidine cyclosporine imuran minocin mtx plaquenil {
replace pres_cdmards_name="`x'" if pres_`x'==1	
}
foreach x in arava azulfidine cyclosporine imuran minocin mtx plaquenil {
replace pres_cdmards_name=pres_cdmards_name + " " + "`x'" if pres_`x'==1 & pres_cdmards_name!="" & strpos(pres_cdmards_name, "`x'")==0
}

lab var pres_cdmards_name "Name(s) of current cDMARDs"
note pres_cdmards_name: including arava azulfidine cyclosporine imuran minocin mtx plaquenil 
 
/*
groups pres_cdmards_name, missing ab(32) 

for any 000000000 000000001: list subject_number generic_key drug_key visitdate drug_date pres_mtx pres_plaquenil pres_cdmards_name if subject_number=="X", sepby(visitdate) noobs ab(16)

tab init_drug hx_drug, m 
tab init_generic hx_generic,m 


// 2024-01-22 re-visit more possible identifications for 6/12 months FU visit for visits not in DOI view 
// b/tsDMARDs example 9 for ppt study_source  dw_event_type report_visitinfliximab_start_date remicade_start_date inflectra_start_date avsola_start_date renflexis_start_date 
for any 002020417: list subject_number generic_key drug_key generic_indexn drug_date visitdate visit_indexn generic_status hx_generic init_generic generic_start_date generic_stop_date generic_init_date generic_base_visit if generic_key=="infliximab" & subject_number=="X", noobs ab(15) sepby(generic_key)

// 2024-07-02 re-check GR's examples for humira vs. adalimumab==>fixed 
for any 101010781 101011364: list subject_number generic_key drug_key generic_indexn drug_date visitdate visit_indexn generic_status generic_start_date generic_stop_date drug_status drug_start_date drug_stop_date if generic_key=="adalimumab" & subject_number=="X", noobs ab(15) sepby(generic_key)

// generic/drug_indexN=1 so humira was coded as start. if only one start row and is a past use, should code as stop...
sort subject_number drug_date
for any 101010781 : list subject_number generic_key drug_key drug_date visitdate prev_visit visit_indexn drug_status_raw generic_status generic_start_date generic_stop_date drug_status drug_start_date drug_stop_date if subject_number=="X" & inlist(drug_category, 250,390), noobs ab(15) sepby(generic_key)
*/

drop pt_reported_en 

lab var drug_date_raw "Originally reported drug date"


// 2024-05-03 add FDA approval date 
// 2024-10-30 adding more FDA approval date for added biosimilars
gen fda_approval_date=.
format fda_approval_date %tdCCYY-NN-DD
replace fda_approval_date=d(31dec2002) if drug_key=="humira"
replace fda_approval_date=d(23sep2016) if drug_key=="amjevita"
replace fda_approval_date=d(18nov2019) if drug_key=="abrilada"
replace fda_approval_date=d(15oct2021) if drug_key=="cyltezo"
replace fda_approval_date=d(23jul2019) if drug_key=="hadlima"
replace fda_approval_date=d(17dec2021) if drug_key=="idacio"
replace fda_approval_date=d(30oct2018) if drug_key=="hyrimoz"
replace fda_approval_date=d(29jul2022) if drug_key=="yusimry"
replace fda_approval_date=d(03jul2023) if drug_key=="hulio"

replace fda_approval_date=d(02nov1998) if drug_key=="enbrel"
replace fda_approval_date=d(30aug2016) if drug_key=="erelzi"
replace fda_approval_date=d(02apr2008) if drug_key=="cimzia"
replace fda_approval_date=d(24apr2009) if drug_key=="simponi"|drug_key=="simponi_aria"
replace fda_approval_date=d(23dec2005) if drug_key=="orencia"
replace fda_approval_date=d(08jan2010) if drug_key=="actemra"
replace fda_approval_date=d(26nov1997) if drug_key=="rituxan"
replace fda_approval_date=d(23jul2019) if drug_key=="ruxience"
replace fda_approval_date=d(28nov2018) if drug_key=="truxima"
replace fda_approval_date=d(01oct2020) if drug_key=="riabni"

replace fda_approval_date=d(06nov2012) if drug_key=="xeljanz"
replace fda_approval_date=d(23feb2016) if drug_key=="xeljanz_xr"
replace fda_approval_date=d(22may2017) if drug_key=="kevzara"
replace fda_approval_date=d(31may2018) if drug_key=="olumiant"
replace fda_approval_date=d(15aug2019) if drug_key=="rinvoq"
replace fda_approval_date=d(24aug1998) if drug_key=="remicade"
replace fda_approval_date=d(05apr2016) if drug_key=="inflectra"
replace fda_approval_date=d(27apr2017) if drug_key=="renflexis"
replace fda_approval_date=d(06dec2019) if drug_key=="avsola"
replace fda_approval_date=d(13dec2017) if drug_key=="ixifi"

replace fda_approval_date=d(14nov2001) if drug_key=="kineret"

replace fda_approval_date=d(10aug1959) if drug_key=="mtx"
replace fda_approval_date=d(18apr1955) if drug_key=="plaquenil"
replace fda_approval_date=d(10sep1998) if drug_key=="arava"
replace fda_approval_date=d(20jun1950) if drug_key=="azulfidine"
replace fda_approval_date=d(30mar1968) if drug_key=="imuran"
replace fda_approval_date=d(30jun1971) if drug_key=="minocin"
replace fda_approval_date=d(29oct1999) if drug_key=="cyclosporine"
replace fda_approval_date=d(24may1985) if drug_key=="ridaura"
replace fda_approval_date=d(26oct2004) if drug_key=="cuprimine"

replace fda_approval_date=d(28jun1974) if drug_key=="pred"

replace fda_approval_date=d(30jun1964) if drug_key=="kenalog"
replace fda_approval_date=d(24oct1985) if drug_key=="meth_pred"
groups drug_key if fda_approval_date==.
groups generic_key drug_key fda_approval_date, missing ab(25) sepby(generic_key)

lab var fda_approval_date "FDA approval date for drug"

// v20240601 for projects with disc reasons, if disc date was on a TAE form (no disc reason fields), use the prior MD visit form if available
foreach x in generic drug{
	sort subject_number `x'_key `x'_indexn 
by subject_number `x'_key: gen miss_reason_`x'=1 if `x'_stop==1 & `x'_stop[_n-1]!=1 & reason_1=="" & strpos(dw_event_type,"TAE") & strpos(dw_event_type[_n-1], "TAE")==0 & reason_1[_n-1]!="" & `x'_key==`x'_key[_n-1] 
tab miss_reason_`x'
}

foreach x in generic drug{
	sort subject_number `x'_key `x'_indexn 
forvalues i=1/3{
by subject_number `x'_key: replace reason_`i'=reason_`i'[_n-1] if miss_reason_`x'==1 & reason_`i'==""
by subject_number `x'_key: replace reason_`i'_category=reason_`i'_category[_n-1] if miss_reason_`x'==1 & reason_`i'_category==""
by subject_number `x'_key: replace reason_`i'_code=reason_`i'_code[_n-1] if miss_reason_`x'==1 & reason_`i'_code==.
by subject_number `x'_key: replace reason_`i'_category_code=reason_`i'_category_code[_n-1] if miss_reason_`x'==1  & reason_`i'_category_code==.
}
}

drop miss_reason*

/*
// 2024-05-08 Rhiannon's example for missing disc reason at the stop row 
for any 002021371: list subject_number visitdate visit_indexn dw_event_type drug_key drug_date drug_date_raw drug_indexn drug_status drug_stop drug_stop_date reason_1 if subject_number=="X" & drug_key=="rinvoq", noobs ab(16)


*save 2_1_drugexpdetails_2024-05-22, replace 

// 2024-05-10 testing Bob M's case where rinvoq stopped in dwsub1 but not in drugexp data 
*use 2_1_drugexpdetails_2024-05-22, clear 
for any 101010060: list dw_event_type subject_number visitdate visit_indexn report_date drug_plan drug_key drug_status drug_status_raw drug_date init_drug drug_start drug_start_date dose_value discontinued_due_to_ae if subject_number=="X" & drug_key=="rinvoq", noobs ab(12)
*/
// 2024-07-02 two stops in a row, not a problem. the drug date for the FU is more than 1 yr from the 2nd TAE. 

/*tricky case, count how many 
sort subject_number generic_key generic_indexn
*by subject_number generic_key: replace generic_status=3 if visit_indexn==visit_indexN & generic_indexn==generic_indexN & generic_status==2 & (dose_value<. |freq_value<.) & discontinued_due_to_ae[_n-1]==”yes” & drug_date-drug_date[_n-1]<30
gen disc_replace=.
by subject_number generic_key: replace disc_replace=1 if visit_indexn==visit_indexN & generic_indexn==generic_indexN & generic_status==2 & (dose_value<. |freq_value<.) & discontinued_due_to_ae[_n-1]=="yes" & drug_date-drug_date[_n-1]<30
tab disc_replace, m // only 24 
*/ 

*merge m:1 subject_number using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-10-01\clean_table\1_1_subjects", keepus(death_dt)



// 2024-06-03 need to drop visits after death date for several patients, death_dt is from 1.1 subjects data 

merge m:1 subject_number using clean_table\1_1_subjects_$datacut, keepus(death_dt)

drop if _m==2 
drop _m 
foreach x in 154010035 254010086 205060061 015001015 038010143 {
    list subject_number visitdate death_dt  if subject_number=="`x'" & visitdate>death_dt , noobs ab(30) 
                drop if subject_number=="`x'" & visitdate>death_dt 
}

/*
  +------------------------------------------+
  | subject_number    visitdate     death_dt |
  |------------------------------------------|
  |      038010143   2023-06-22   2018-12-08 |
  +------------------------------------------+
(1 observation deleted)
*/

lab var death_dt "death date"
// extra variables to be dropped 
ds x_*, v(32) // x_edc_event_name_raw  x_edc_event_ordinal   x_is_test

drop x_*

drop dup10

ds *_mode, v(32)

drop *_mode

codebook visitdate drug_date

*save temp\2_1_drug_exp_details_2024-10-30, replace 
compress 
save 2_1_drugexpdetails_$datacut, replace

*corcf * using temp\2_1_drugexpdetails_2024-11-01_old, id(subject_number generic_key drug_date)
 
corcf * using "$pdata\\2_1_drugexpdetails_$pdatacut", id(subject_number generic_key drug_date)

use "$pdata\\2_1_drugexpdetails_$pdatacut", clear
// raw count for QRR, all increased from dec2024 
unique subject_number if pres_drug==1 & drug_key=="remicade" //9,314
unique subject_number if pres_drug==1 & drug_key=="humira" // 11,161
unique subject_number if pres_drug==1 & drug_key=="enbrel" // 11,225
unique subject_number if pres_drug==1 & drug_key=="olumiant"  //469
unique subject_number if pres_drug==1 & drug_key=="renflexis" //291
unique subject_number if pres_drug==1 & drug_key=="inflectra" //417

/* 
rename drug_name_raw dec24_drug_name_raw
rename drug_name_code_raw dec24_drug_name_code_raw 
merge 1:1 subject_number generic_key drug_date using "$pdata\\2_1_drugexpdetails_$pdatacut", keepus(drug_name_raw drug_name_code_raw)
br subject_number visitdate generic_key drug_date *drug_name_raw *drug_name_code_raw if _m==3 & (drug_name_raw!=dec24_drug_name_raw|drug_name_code_raw !=dec24_drug_name_code_raw)
// drug_name_raw are all lower case
preserve 
keep if _m==3 & drug_name_raw!=dec24_drug_name_raw
rename drug_name_raw nov24_drug_name_raw
list subject_number visitdate drug_date generic_key drug_key *drug_name_raw in 1/20, noobs ab(16)
restore 

br subject_number visitdate generic_key drug_date *drug_name_raw *drug_name_code_raw if _m==3 & drug_name_code_raw !=dec24_drug_name_code_raw

groups generic_key drug_name_code dec24_drug_name_code drug_name_code_raw if  _m==3 & drug_name_code_raw !=dec24_drug_name_code_raw, noobs ab(16)

2024-12-04 considered as a minor issue, will check with EDW later 
  +----------------------------------------------------------------------------------------------+
  |        generic_key   drug_name_code   dec24_dru~de_raw   drug_name_code~w    Freq.   Percent |
  |----------------------------------------------------------------------------------------------|
  |          abatacept              100                100                920        1      0.00 |
  |              arava              530                530                531        1      0.00 |
  |         azulfidine              551                550                551        1      0.00 |
  | certolizumab_pegol              140                920                140        1      0.00 |
  |    corticosteroids              730                730                920        2      0.00 |
  |----------------------------------------------------------------------------------------------|
  |          golimumab              170                170                171        2      0.00 |
  |          golimumab              170                171                170        1      0.00 |
  |          plaquenil              520                521                520   117431     99.99 |???
  |        tofacitinib              301                301                300        1      0.00 |
  +----------------------------------------------------------------------------------------------+


rename drug_name_code_raw nov24_drug_name_code_raw
groups generic_key drug_name drug_name_code nov24_drug_name_code_raw dec24_drug_name_code if  generic_key=="plaquenil" & _m==3 & nov24_drug_name_code_raw !=dec24_drug_name_code_raw, noobs ab(24)

use 2_1_drugexpdetails_$datacut, clear 
br subject_number visitdate visit_indexn drug_key if subject_number=="000000000"
rename visitdate dec24_visitdate 
rename visit_indexn dec24_visit_indexn
merge 1:1 subject_number generic_key drug_date using "$pdata\\2_1_drugexpdetails_$pdatacut", keepus(visitdate visit_indexn)
br subject_number visitdate generic_key drug_date *visitdate if _m==3 & visitdate!=dec24_visitdate 
*/

// erase extra data 
cap erase temp\2_1_allDMARDs_starts.dta 
cap erase temp\2_1_btsDMARDs_starts.dta 
cap erase temp\2_1_drugexpdetails_status.dta 
cap erase temp\2_1_expdetails_init.dta 

/*
use 2_1_drugexpdetails_2024-11-01, clear
corcf * using 2_1_drugexpdetails_2024-11-01_old, id(subject_number generic_key drug_date)

# delimit;
for any 001100560     
002022127      
002022791 
012131353  
019200534 
035010227
043916970
075001111 
100140374
100143095
106020060 
117010109
152020175
154010057
154010184
154010238
167010294 
205010854
205070226
242010012 
516291075 
835159011  
RA-100-0120
RA-195-0018
035010151
135010068: list subject_number visitdate drug_date drug_key drug_name_txt drug_name_raw drug_start drug_stop reason_1 if subject_number=="X" & generic_key=="rituximab", sepby(visitdate) noobs ab(16) ;
# delimit cr;*/