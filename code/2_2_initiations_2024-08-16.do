/*
2024-08-16 
using v20240801 2.1 data to test bug fixes 

2024-07-10
using v20240701z build 

2024-05-09
continue checking questions from GR 
1. 20240301 word document question: the max FU for subject 001020113    infliximab
2024-05-03
review GR's request 
1. add md_cod 
2. add reasons of disc for initiators first stop 

2024-04-18 
updated 2.1drugexpdetails data, need to re-run to correct some of the stop dates 

2024-04-05
use v20240401 build, check inconsistencies between generic start and drug start 

2024-04-04 check George's questions for allinits data 

2024-04-03
fix the switching bug, switching from infliximab to inflectra should be avoided 
2024-03-28
found errors in drug/generic start date imputation coding. updated 2.1 and also need to update 2.2

2024-03-07
using v20240305 build 

2024-03-04
make fu days as int, without any decimal places (gen int fu_days=)

2024-03-01 
work on the data dictionary
add variable/value labels to all variables 

2024-02-29
1. add mono_combo variable to be consistent with prev data;
2. simplify example coding by using loops 
3. check Amgen063 mono therapy counts 

2024-02-27
The Query Team also needs 18 and 24 months FU 

2024-02-23
1. modify drug/generic_init_date to init_date for convenience 

2024-02-21 
1. simplify loop, run amjevita and erelzi separately 
2. modify loop for generics 
3. add grpindexn to filter baseline visits 
4. code for Amgen 063 and compare numbers 


2024-02-20
1. for v20240202 build of 2.1 DrugExpDetails data, adjusted baseline up to 183 days prior to initiation;
2. try to make a loop for all drugs 

2024-02-16 
using v20240202 build of 2.1 drug exp details data

strategy:
1. create init drug data, with init date, base_visit and baseline pres_cdmards_name, link to allvisits data using base visit 

2. create first stop data for the drug 

3. create all drug start data, if another drug started right after a init, then identify as a first switch 

4. keep all visits after the init and find 6/12 months FU 
 
2024-02-09
use v20240130 build drugexpdetails data to build initiators data; change the order from 2.4 to 2.2

2024-01-23
try to build 2_4 initiations data 


2024-01-25
Stopped prior to a follow-up window — use the visit that is closer to the stopped date
Stopped within a follow-up window — use the stop visit as the follow-up visit
Stopped after a follow-up windows — select the visit that is closer to 183 (6 months FU) or 365 days (12 months FU); if both visits have the same distance to 183 or 365 days, use the later one to keep more drug exposure.  
*/

cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\temp\LGtest_2024-08-12"

*global testdata "~\Corrona LLC\Biostat Data Files - RA\monthly\ODBC\dwh_db\2024-03-31"

cap log close

log using 2_2_initiators_2024-08-19.log, replace // append 

*use 2_1_drugexpdetails_2024-08-19, clear 

use "..\2_1_drugexpdetails", clear
// 2024-05-03 check stop dates for tofa sent by GR ==> addressed from bug fix in April by appending another row. Tofa continuously using throughtout all visits for the subject below. Emailed GR. 
for any 176010020: list dw_event_type subject_number visitdate visit_indexn generic_key drug_key drug_status generic_status drug_date drug_start drug_stop drug_start_date drug_stop_date generic_start generic_start_date generic_stop generic_stop_date if subject_number=="X" & generic_key=="tofacitinib", noobs ab(6) sepby(visitdate)
// GR 2024-04-02 email In the init file if I use the generic tofacitinib is looks like the only way to know which tofa was initiated is to match init_date with start_date_xeljanz or start_date_xeljanz_xr  (which sit in record 1 or 2)
// 001010125 001017042 001020063 
for any 001010200 : list dw_event_type subject_number visitdate visit_indexn prev_visit generic_key init_generic drug_key init_drug drug_status generic_status drug_date drug_start drug_stop drug_start_date generic_start generic_start_date generic_init_date drug_init_date if subject_number=="X" & generic_key=="tofacitinib", noobs ab(6) sepby(visitdate)

// GR email about stop date not unique, imputation needs to be refined  
for any 002023045 : list dw_event_type subject_number visitdate visit_indexn next_visit  drug_key drug_status init_drug drug_date drug_date_raw drug_start drug_stop drug_start_date drug_stop_date if subject_number=="X" & generic_key=="tofacitinib", noobs ab(16) sepby(visitdate)

// GR request, reasons of disc for initiators 

/*ds hx_*, v(32)
br visitdate hx_enbrel hx_eta hx_erelzi if subject_number=="001010233" 

// 2024-02-28 revisit the example in spreadsheet, then answer Ning's questions
for any 002020417: list subject_number generic_key drug_key generic_status drug_status generic_start drug_start generic_stop drug_stop if subject_number=="X" & generic_key=="infliximab", noobs ab(16) sepby(generic_key)

preserve 
keep if drug_status==1 & generic_status==3
list subject_number generic_key drug_key generic_status drug_status generic_start drug_start generic_stop drug_stop in 1/5,  noobs ab(16) 
restore 

for any 001010124 001010217 001017042: list subject_number visitdate visit_indexn generic_key drug_key generic_status drug_status generic_start generic_stop drug_start drug_stop if subject_number=="X" & generic_key=="tofacitinib", noobs ab(16) sepby(generic_key)

for any 001010124: list subject_number visitdate visit_indexn drug_date generic_key drug_key generic_status drug_status generic_start generic_stop drug_start drug_stop if subject_number=="X" & inlist(drug_category, 250,390) , noobs ab(16) sepby(generic_key)
// check old orencia slide 
for any 001010133 001010055 002010013: list subject_number visitdate visit_indexn drug_date generic_key drug_key generic_status drug_status generic_start generic_stop drug_start drug_stop if subject_number=="X" & drug_key=="orencia" , noobs ab(16) sepby(generic_key)

groups  generic_start drug_start, missing ab(16)

  +-----------------------------------------------+
  | generic_start   drug_start    Freq.   Percent |
  |-----------------------------------------------|
  |             1            1   252068     27.05 |
  |             1            .     1038      0.11 |
  |             .            1     3452      0.37 |==>xeljanz xr started and xeljanz is continue 
  |             .            .   675289     72.47 |
  +-----------------------------------------------+
*/

preserve 
// 2024-02-12 created drug/generic_start in 2.1 drugexpdetails data, use drug_start 
keep if drug_start==1 & inlist(drug_category,250,390) //& visit_indexn>1
keep subject_number visitdate drug_key drug_start drug_start_date drug_start_visit //drug_start_order
unique subject_number visitdate drug_key //drug_start_order // unique 
unique subject_number visitdate drug_key drug_start_visit // NOT unique 
unique subject_number visitdate drug_key

// create drug start data in wide format, one visit per subject with drug name and start date. the visitdate is the visit that drug start linked to.
compare visitdate drug_start_visit // some drugs are started from the prev visit. keep drug start visit
rename drug_start_date start_date_ 
rename drug_start start_
drop visitdate 
rename drug_start_visit visitdate 
// if multiple starts of the same drug is linked to the same visit, then keep the first one 
bysort subject_number visitdate drug_key: gen drug_start_indexn=_n 
bysort subject_number visitdate drug_key: gen drug_start_indexN=_N 
tab drug_start_indexn 
*list subject_number visitdate drug_key start_date_ if drug_start_indexN==3, noobs ab(16) //multiple start dates linked to the same visit, keep the first one is enough to identify a first switch  
keep if drug_start_indexn==1
mdesc start_date_ // missing start date for drug continue at enrollment or first available visit date 
drop *_index*
reshape wide start_ start_date_, i(subject_number visitdate) j(drug_key) string
egen nmiss=rowmiss(start_*)
tab nmiss 
* br if nmiss==49
mdesc *
drop if visitdate==. //3,477
drop nmiss
save start_btdmards_1st_per_visit_drug, replace 
restore 

// also create for a few generic names with multiple drug keys 

preserve 
keep if generic_start==1 & inlist(drug_category,250,390) & inlist(generic_key, "adalimumab", "etanercept", "golimumab", "infliximab", "rituximab", "tofacitinib") 
keep subject_number visitdate generic_key generic_start generic_start_date generic_start_visit //drug_start_order

rename generic_start_date start_date_ 
rename generic_start start_
drop visitdate 
rename generic_start_visit visitdate
// if multiple starts of the same drug is linked to the same visit, then keep the first one 
bysort subject_number visitdate generic_key: gen generic_start_indexn=_n 
bysort subject_number visitdate generic_key: gen generic_start_indexN=_N 
tab generic_start_indexn // also up to 3 
 
*for any 001017021: list subject_number visitdate generic_start_date generic_start_indexn if subject_number=="X" & generic_key=="etanercept", noobs ab(12) sepby(generic_key)

keep if generic_start_indexn==1
drop *index*

reshape wide start_ start_date_, i(subject_number visitdate) j(generic_key) string
mdesc *
drop if visitdate==.

save start_btdmards_1st_per_visit_generic, replace
restore 



use start_btdmards_1st_per_visit_drug, clear 
merge 1:1 subject_number visitdate using start_btdmards_1st_per_visit_generic
/*
v20240801 
    Result                           # of obs.
    -----------------------------------------
    not matched                        19,119
        from master                    19,015  (_merge==1)
        from using                        104  (_merge==2)

    matched                            56,149  (_merge==3)
    -----------------------------------------

v20240701z 
    Result                           # of obs.
    -----------------------------------------
    not matched                        19,012
        from master                    18,912  (_merge==1)
        from using                        100  (_merge==2)

    matched                            56,170  (_merge==3)
    -----------------------------------------
*/


drop _m 
save start_btdmards_1st_per_visit, replace 

*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\2_3_keyvisitvars.dta", clear
// 2024-05-03 use keyvisitvars instead of allvisits to include md_id 
use "..\2_3_keyvisitvars.dta", clear
*use "..\clean_table\1_2_allvisits.dta", clear
mdesc visitdate // 148 missing 

mdesc study_acronym source dw_event_type, ab(24)
groups study_acronym source dw_event_type, missing ab(16) // no TAE 
*format visitdate %tdCCYY-NN-DD  
*drop if visitdate==. // 2024-02-12 let Ying know 

keep subject_number visitdate site_number full_version c_provider_id md_id study_acronym source dw_event_type_acronym 
unique subject_number visitdate 
sort subject_number visitdate 

by subject_number: gen visit_indexn=_n 
by subject_number: gen visit_indexN=_N 

by subject_number: gen enroll_visit=visitdate[1]
by subject_number: gen last_visit=visitdate[_N]
by subject_number: gen prev_visit=visitdate[_n-1] // not using prev_visit yet, just in case will use it later. 
by subject_number: gen next_visit=visitdate[_n+1]

*clonevar linked_visit=visitdate 
//linked_visit 
format enroll_visit last_visit prev_visit next_visit %tdCCYY-NN-DD  
lab var visit_indexn "the order of visit dates"
lab var visit_indexN "the total number of visit dates"
lab var enroll_visit "enrollment visit date"
lab var last_visit "last visit date"
lab var prev_visit "previous visit date, if available"
lab var next_visit "next visit date, if available"
*keep subject_number visitdate visit_index* enroll_visit last_visit prev_visit next_visit
mdesc *

*sort subject_number visitdate 
// 2024-05-03 changed name to keyvisits_simple
save keyvisits_simple, replace 


/////////////////////////////////////////////////////////////////////
// STEP A. use simplified visitdate data to add cdmard use 
use keyvisits_simple, clear 

merge 1:1 subject_number visitdate using start_btdmards_1st_per_visit

rename _m start_details
lab var start_details "visits with drug start data, 1=no starts;3=with drug starts"

gen numstart=0
gen namestart=""
# delimit;
global btsdrug_list
"orencia
amjevita 
humira 
kineret
cimzia
enbrel
erelzi 
avsola 
inflectra 
remicade 
remicade_bs 
renflexis 
rituxan 
rituxan_bs
ruxience 
truxima 
kevzara 
actemra
olumiant 
rinvoq
adalimumab
etanercept
golimumab
infliximab
rituximab
tofacitinib
"
;
# delimit cr;
foreach x in $btsdrug_list {
replace numstart=numstart+1 if start_`x'==1
replace namestart=namestart + " " + "`x'" if start_`x'==1
}

lab var numstart "number of drugs started at the visit"
lab var namestart "the name(s) of drug started at the visit"
// 2024-05-03 changed name to keyvisits_starts 
save keyvisits_starts, replace 

/////////////////////////////////////////////////////////////////////////////////
///////////////////// Next, Step C for each drug/generic 
use 2_1_drugexpdetails_2024-08-19, clear

use "..\2_1_drugexpdetails", clear

sort subject_number drug_date

forvalues i=1/3{
    gen prev_reason_`i'="" 
	lab var prev_reason_`i' "previous reason `i'"
	gen prev_reason_`i'_category=""
	lab var prev_reason_`i'_category "previous reason `i' category"
	*gen prev_reason_`i'_category_code=.
	*lab var prev_reason_`i'_category_code "previous reason `i' category code"
}	
// generate last drug/generic used and reason for disc for initiators
// 2024-03-01 note: need to fix the reason categories for the 1.6 Drugrecords data during deduplication. 
// 2024-03-21 fix prev drug/generic to missing if nhx_b_ts_generic=0
foreach x in drug generic{
    keep if inlist(drug_category, 250,390)
    cap drop prev_`x' 
by subject_number : gen prev_`x'=`x'_key[_n-1]  if init_`x'==1 & nhx_b_ts_generic>0

lab var prev_`x' "previous `x' name"
forvalues i=1/3{
by subject_number : replace prev_reason_`i'=reason_`i'[_n-1]  if init_`x'==1 & nhx_b_ts_generic>0
by subject_number : replace prev_reason_`i'_category=reason_1_category[_n-1]  if init_`x'==1 & nhx_b_ts_generic>0
*by subject_number : replace prev_reason_`i'_category_code=reason_1_category_code[_n-1]  if init_`x'==1
}
} 

// create everinit for b/tsDMARDs initiators 
egen everinit_generic=sum(init_generic), by(subject_number generic_key)
egen everinit_drug=sum(init_drug), by(subject_number drug_key)


save drug_temp, replace 

tab drug_key 
tab generic_key 



//amjevita erelzi do not have enough FU visits yet, the deduplicate steps won't run for both. 
use drug_temp, clear

# delimit;
global btsdmards_drug_list
"orencia
humira 
kineret
cimzia
enbrel
simponi 
simponi_aria
avsola 
inflectra 
remicade 
remicade_bs 
renflexis 
rituxan 
rituxan_bs
ruxience 
truxima 
kevzara 
actemra
olumiant 
xeljanz
xeljanz_xr
rinvoq
"
;
# delimit cr;
///////////////////////////////////////////////////////////////
// 2024-02-20 try looping for drugs start here 
// orencia
foreach y in $btsdmards_drug_list amjevita erelzi{
// merge using base_visit from drugexpdetails at init 
preserve 
keep if drug_key=="`y'" & init_drug==1
keep drug_key subject_number drug_base_visit drug_init_date nhx_b_ts_generic prev_drug prev_generic prev_reason_1-prev_reason_3_category nhx_b_ts_generic pres_cdmards_name pres_cuprimine pres_ridaura hx_*
drop hx_drug hx_generic
rename * base_*
rename base_subject_number subject_number
rename base_drug_key druggrp
rename base_drug_init_date init_date
rename base_drug_base_visit base_visit 
lab var druggrp "drug group"
lab var init_date "date of initiation"
lab var subject_number "subject number"
replace base_nhx_b_ts_generic=0 if base_prev_drug=="" & base_prev_generic==""
save `y'_init_date, replace 
restore 
 
// create drug data with everinit and with the first stopped date 
// 2024-02-16 create the first stop date for initiators  
// 2024-05-03 add reason_1_3 at drug stop 
preserve 
keep if drug_key=="`y'" & everinit_drug==1 & drug_stop==1 & drug_stop_order==1 & drug_base_visit<.
keep drug_key subject_number drug_stop drug_stop_date drug_stop_visit reason_1 reason_2 reason_3 reason_1_category reason_2_category reason_3_category
rename drug_key druggrp 
rename drug_stop stop 
rename drug_stop_date stop_date
rename drug_stop_visit visitdate
rename reason_1 stop_reason_1
rename reason_2 stop_reason_2
rename reason_3 stop_reason_3
rename reason_1_category stop_reason_1_category
rename reason_2_category stop_reason_2_category
rename reason_3_category stop_reason_3_category
lab var stop "the first stop of initiator"
lab var stop_date "the first stop date of initiator"
lab var stop_reason_1 "reason 1 for the first stop of initiator"
lab var stop_reason_2 "reason 2 for the first stop of initiator"
lab var stop_reason_3 "reason 3 for the first stop of initiator"
lab var stop_reason_1_category "reason 1 category for the first stop of initiator"
lab var stop_reason_2_category "reason 2 category for the first stop of initiator"
lab var stop_reason_3_category "reason 3 category for the first stop of initiator"
*rename visitdate first_stop_visit
save `y'_stop_date, replace 
restore 
}

/* check baseline mono_combo
use orencia_init_date, clear 
br base_pres_cdmards_name if subject_number=="001010052" // missing name, mono therapy 
*/

use drug_temp, clear
foreach y in adalimumab etanercept golimumab infliximab rituximab tofacitinib{
// merge using base_visit from drugexpdetails at init 
preserve 
keep if generic_key=="`y'" & init_generic==1
keep generic_key subject_number generic_base_visit generic_init_date nhx_b_ts_generic prev_drug prev_generic prev_reason_1-prev_reason_3_category nhx_b_ts_generic pres_cdmards_name pres_cuprimine pres_ridaura  hx_*
drop hx_drug hx_generic
rename * base_*
rename base_subject_number subject_number
rename base_generic_key druggrp 
rename base_generic_base_visit base_visit 
rename base_generic_init_date init_date 
lab var druggrp "drug group"
lab var init_date "date of initiation"
lab var subject_number "subject number"
replace base_nhx_b_ts_generic=0 if base_prev_drug=="" & base_prev_generic==""
save `y'_init_date, replace 
restore 
 
// create drug data with everinit and with the first stopped date 
// 2024-02-16 create the first stop date for initiators  
// 2024-05-03 add reason_1_3 at drug stop 
preserve 
keep if generic_key=="`y'" & everinit_generic==1 & generic_stop==1 & generic_stop_order==1 & generic_base_visit<.
keep generic_key subject_number generic_stop generic_stop_date generic_stop_visit reason_1 reason_2 reason_3 reason_1_category reason_2_category reason_3_category
rename generic_key druggrp 
rename generic_stop stop 
rename generic_stop_date stop_date
rename generic_stop_visit visitdate
rename reason_1 stop_reason_1
rename reason_2 stop_reason_2
rename reason_3 stop_reason_3
rename reason_1_category stop_reason_1_category
rename reason_2_category stop_reason_2_category
rename reason_3_category stop_reason_3_category
lab var stop "the first stop of initiator"
lab var stop_date "the first stop date of initiator"
lab var stop_reason_1 "reason 1 for the first stop of initiator"
lab var stop_reason_2 "reason 2 for the first stop of initiator"
lab var stop_reason_3 "reason 3 for the first stop of initiator"
lab var stop_reason_1_category "reason 1 category for the first stop of initiator"
lab var stop_reason_2_category "reason 2 category for the first stop of initiator"
lab var stop_reason_3_category "reason 3 category for the first stop of initiator"

save `y'_stop_date, replace 
restore 
}

// test start data 
use enbrel_init_date, clear
groups base_prev_drug base_prev_generic base_nhx_b_ts_generic, missing ab(16)

///////////////////////////////////////////////////	
// finding follow-up, switch
///////////////////////////////////////////////////

// orencia infliximab

foreach y in $btsdmards_drug_list adalimumab etanercept golimumab infliximab rituximab tofacitinib{
    display "`y'"
// Add C to data B 
use keyvisits_starts, clear 
merge m:1 subject_number using `y'_init_date
drop _m 

drop if visitdate<base_visit // including _m==1

unique subject_number
// Add D to B & C 
merge 1:1 subject_number visitdate using `y'_stop_date
drop if _m==2
drop _m 

unique subject_number //humira: 5,307  5,189 with increased baseline definition; 5,022 Orencia initiators with a baseline visit 

////////////////////////////////////////////////////////////
/////////////// Part E. find 6/12 months FU 
// days of follow-up since initiation 
 
gen int fu_days=visitdate-init_date 

lab var fu_days "days of follow-up (visitdate-init_date)"

// find 6 month (91-274 days) and 12 month (275-458 days)
// 2024-02-28 adding 18 (458-639 days) and 24 months FU (639-820 days) 
// 1. if stopped during the FU window, use the stopped visit 
gen fu_6m=1 if fu_days>90 & fu_days<274 & stop==1

egen everfu_6m=sum(fu_6m), by(subject_number druggrp)

replace fu_6m=1 if everfu_6m==0 & fu_days>90 & fu_days<274

gen fu_12m=1 if fu_days>=274 & fu_days<458 & stop==1

egen everfu_12m=sum(fu_12m), by(subject_number druggrp)

replace fu_12m=1 if everfu_12m==0 &  fu_days>=274 & fu_days<458

// 18 months FU 
gen fu_18m=1 if fu_days>=458 & fu_days<639 & stop==1

egen everfu_18m=sum(fu_18m), by(subject_number druggrp)

replace fu_18m=1 if everfu_18m==0 & fu_days>=458 & fu_days<639
// 24 months FU 
gen fu_24m=1 if fu_days>=639 & fu_days<820 & stop==1

egen everfu_24m=sum(fu_24m), by(subject_number druggrp)

replace fu_24m=1 if everfu_24m==0 & fu_days>=639 & fu_days<820

// 2. if stopped prior to the FU window, use the earlier one if more than one visit within the FU window 

sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumstop=sum(stop)
lab var cumstop "cumulative stop status"
lab val cumstop ny
// generate a duplicate indicator for fu_grp 
forvalues i=6(6)24{
    
cap drop dup_fu`i' 

cap duplicates tag subject_number druggrp fu_`i'm if fu_`i'm==1 & everfu_`i'm==0, gen(dup_fu`i')

cap egen min_fu`i'=min(fu_days) if dup_fu`i'>=1 & dup_fu`i'<., by(subject_number druggrp)

clonevar fu_`i'm_raw=fu_`i'm
 
cap replace fu_`i'm=. if fu_days>min_fu`i' & dup_fu`i'>=1 & dup_fu`i'<. & cumstop==1 & stop==.
}

// 3.1 if stopped later than the FU window and more than 1 visits available in the FU window, choose the one that is closer to 183 or 365

gen dif_temp=abs(fu_days-183) if fu_6m==1
replace dif_temp=abs(fu_days-365) if fu_12m==1
replace dif_temp=abs(fu_days-548) if fu_18m==1
replace dif_temp=abs(fu_days-730) if fu_24m==1

// simplify variable
gen fu_grp=.
lab var fu_grp "follow-up group"

forvalues i=6(6)24{
  
cap egen dif_temp_`i'=min(dif_temp) if fu_`i'm==1 & dup_fu`i'>=1 & dup_fu`i'<., by(subject_number druggrp)

cap replace fu_`i'm=. if dif_temp>dif_temp_`i' & fu_`i'm_raw==1 & dup_fu`i'>=1 & dup_fu`i'<. & cumstop==0 

// 3.2 if stopped later than the FU window and more than 1 visits available and there are two visits to the same distance of 183 or 365

cap duplicates tag subject_number fu_`i'm if fu_`i'm==1, gen(dup2_fu`i')

// use the later visit to have more exposure time 
cap egen max_fu`i'=max(fu_days) if dup2_fu`i'>=1 & dup2_fu`i'<., by(subject_number druggrp)

cap replace fu_`i'm=. if fu_days<max_fu`i' & dup2_fu`i'>=1 & dup2_fu`i'<.

replace fu_grp=`i' if fu_`i'm==1
}

forvalues i=6(6)24{
drop fu_`i'm everfu_`i'm dup_fu`i' min_fu`i' fu_`i'm_raw dif_temp_`i' dup2_fu`i' max_fu`i'
}

drop dif_temp

/////////////	Finding the first switch 

gen switch=1 if cumstop==1 & numstart>=1 & strpos(namestart,"`y'")==0

// 2024-04-03 generic cannot be coded as switch if the switched drug name is within the generic group 
replace switch=. if "`y'"=="adalimumab" & switch==1  & numstart==1 & (strpos(namestart,"amjevita")|strpos(namestart,"humira"))
replace switch=. if "`y'"=="etanercept" & switch==1  & numstart==1 & (strpos(namestart,"erelzi")|strpos(namestart,"enbrel"))
replace switch=. if "`y'"=="golimumab" & switch==1  & numstart==1 & (strpos(namestart,"simponi")|strpos(namestart,"simponi_aria"))
replace switch=. if "`y'"=="infliximab" & switch==1  & numstart==1 & (strpos(namestart,"avsola")|strpos(namestart,"inflectra")|strpos(namestart, "remicade")|strpos(namestart,"remicade_bs")|strpos(namestart, "renflexis"))
replace switch=. if "`y'"=="rituximab" & switch==1  & numstart==1 & (strpos(namestart,"rituxan")|strpos(namestart,"rituxan_bs")|strpos(namestart, "ruxience")|strpos(namestart,"truxima"))
replace switch=. if "`y'"=="tofacitinib" & switch==1  & numstart==1 & (strpos(namestart,"xeljanz")|strpos(namestart,"xeljanz_xr"))
    
sort subject_number druggrp visitdate 
by subject_number druggrp: gen switch_order=sum(switch)

gen firstswitch=1 if switch_order==1 & switch==1 

gen switchname=namestart if firstswitch==1

lab var switch "drug switched"
lab var switch_order "number of switches"
lab var firstswitch "the first switch"
lab val stop switch  firstswitch ny //cumswitch
lab var switchname "name of the firstswitch"

// create 4 visitdates and carry to the end, then drop the visitdates that are larger than the latest visit 
forvalues i=6(6)24{
gen fu`i'_visit=visitdate if fu_grp==`i' 
format fu`i'_visit %tdCCYY-NN-DD
}

gen stop_visit=visitdate if stop==1
gen switch_visit=visitdate if firstswitch==1
 
format stop_visit switch_visit %tdCCYY-NN-DD

sort druggrp subject_number visitdate 
foreach x in fu6 fu12 fu18 fu24 stop switch {
by druggrp subject_number: replace `x'_visit=`x'_visit[_n-1] if `x'_visit==.
} 

cap drop maxdate 
egen maxdate=rowmax(fu6_visit fu12_visit fu18_visit fu24_visit stop_visit switch_visit) if switch_order>=1 & fu_days>820
format maxdate %tdCCYY-NN-DD
sort druggrp subject_number visitdate
by druggrp subject_number: replace maxdate=maxdate[_n-1] if maxdate==.

drop if visitdate>maxdate 

drop maxdate fu6_visit fu12_visit fu18_visit fu24_visit stop_visit switch_visit

sort subject_number visitdate 
by subject_number: gen grpindexn=_n 
lab var grpindexn "initiator group index n; 1=baseline visit"

// 2024-02-29 carry all base_* to the end of data, and use the init row for the baseline row if baseline is prior to init 
// numeric variables
foreach z in nhx_b_ts_generic pres_cuprimine pres_ridaura hx_cyclosporine hx_mtx hx_amjevita hx_simponi_aria hx_rituxan_bs       hx_xeljanz_xr hx_etanercept hx_plaquenil hx_humira hx_avsola hx_ruxience hx_rinvoq hx_adalimumab hx_golimumab hx_ridaura hx_kineret hx_inflectra        hx_truxima hx_kenalog hx_arava hx_imuran hx_rituximab hx_cimzia hx_remicade hx_kevzara hx_meth_pred hx_azulfidine hx_infliximab hx_sirukumab        hx_enbrel hx_remicade_bs hx_actemra hx_pred hx_corticosteroids  hx_invest hx_tofacitinib hx_erelzi hx_renflexis hx_olumiant hx_cuprimine hx_minocin hx_orencia hx_simponi hx_rituxan hx_xeljanz{
    by subject_number: replace base_`z'=base_`z'[_n-1] if base_`z'==.
	by subject_number: replace base_`z'=base_`z'[_n+1] if base_`z'==. & grpindexn==1 & fu_days<0
}
// string variables
foreach z in pres_cdmards_name prev_drug prev_generic prev_reason_1 prev_reason_2 prev_reason_3 prev_reason_1_category prev_reason_2_category prev_reason_3_category{
	by subject_number: replace base_`z'=base_`z'[_n-1] if base_`z'==""
	by subject_number: replace base_`z'=base_`z'[_n+1] if base_`z'=="" & grpindexn==1 & fu_days<0
}

# delimit;
order subject_number
site_number
visitdate
visit_indexn
visit_indexN 
enroll_visit
last_visit
prev_visit
next_visit
full_version
c_provider_id
dw_event_type_acronym
study_acronym 
source_acronym
druggrp
init_date
base_visit
fu_days
fu_grp
stop
stop_date
cumstop
switch
switch_order
firstswitch
switchname
grpindexn
base_*
start_*
numstart
namestart
;
# delimit cr;

save init_`y', replace 
}

use init_infliximab, clear 
tab switchname 

/* check data 
use init_orencia, clear 
br base_pres_cdmards_name if subject_number=="001010052" // fixed 
*/
///////////////////////	Run separately for amjevita and erelzi 

foreach y in amjevita erelzi{
    display "`y'"
// Add C to data B 
use keyvisits_starts, clear 
merge m:1 subject_number using `y'_init_date

*br subject_number visitdate drug_base_visit drug_key drug_init_date prev_drug prev_generic prev_drug_reason1-prev_drug_reason3 prev_generic_reason1-prev_generic_reason3 if _m==3 

drop if visitdate<base_visit // including _m==1
drop _m 
unique subject_number
// Add D to B & C 
merge 1:1 subject_number visitdate using `y'_stop_date
drop if _m==2
drop _m 

unique subject_number //humira: 5,307  5,189 with increased baseline definition; 5,022 Orencia initiators with a baseline visit 

////////////////////////////////////////////////////////////
/////////////// Part E. find 6/12 months FU 
// days of follow-up since initiation 
cap drop fu_days
gen int fu_days=visitdate-init_date 
lab var fu_days "days of follow-up (visitdate-init_date)"


// find 6 month (91-274 days) and 12 month (275-458 days)

// 1. if stopped during the FU window, use the stopped visit 
gen fu_6m=1 if fu_days>90 & fu_days<274 & stop==1

egen everfu_6m=sum(fu_6m), by(subject_number druggrp)

replace fu_6m=1 if everfu_6m==0 & fu_days>90 & fu_days<274

gen fu_12m=1 if fu_days>=274 & fu_days<458 & stop==1

egen everfu_12m=sum(fu_12m), by(subject_number druggrp)

replace fu_12m=1 if everfu_12m==0 &  fu_days>=274 & fu_days<458
// 18 months FU 
gen fu_18m=1 if fu_days>=458 & fu_days<639 & stop==1

egen everfu_18m=sum(fu_18m), by(subject_number druggrp)

replace fu_18m=1 if everfu_18m==0 & fu_days>=458 & fu_days<639
// 24 months FU 
gen fu_24m=1 if fu_days>=639 & fu_days<820 & stop==1

egen everfu_24m=sum(fu_24m), by(subject_number druggrp)

replace fu_24m=1 if everfu_24m==0 & fu_days>=639 & fu_days<820

sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumstop=sum(stop)

// simplify variable
gen fu_grp=.
lab var fu_grp "follow-up group"

forvalues i=6(6)24{
replace fu_grp=`i' if fu_`i'm==1 
}

cap drop fu_6m everfu_6m fu_12m everfu_12m fu_18m everfu_18m fu_24m everfu_24m

gen switch=1 if cumstop==1 & numstart>=1 & strpos(namestart,"`y'")==0

sort subject_number druggrp visitdate 
by subject_number druggrp: gen switch_order=sum(switch)

gen firstswitch=1 if switch_order==1 & switch==1 

gen switchname=namestart if firstswitch==1

lab var switch "drug switched"
lab var switch_order "number of switches"
lab var firstswitch "the first switch"
lab val stop switch firstswitch ny // cumswitch 
lab var switchname "name of the firstswitch"

/* keep all for amjevita and erelzi

// create 4 visitdates and carry to the end, then drop the visitdates that are larger than the latest visit 
forvalues i=6(6)24{
gen fu`i'_visit=visitdate if fu_grp==`i' 
format fu`i'_visit %tdCCYY-NN-DD
}
gen stop_visit=visitdate if stop==1
gen switch_visit=visitdate if firstswitch==1 
format stop_visit switch_visit %tdCCYY-NN-DD

sort druggrp subject_number visitdate 
foreach x in fu6 fu12 fu18 fu24 stop switch {
by druggrp subject_number: replace `x'_visit=`x'_visit[_n-1] if `x'_visit==.
} 

cap drop maxdate 
egen maxdate=rowmax(fu6_visit fu12_visit stop_visit switch_visit) if cumswitch==1 & fu_days>458
format maxdate %tdCCYY-NN-DD
sort druggrp subject_number visitdate
by druggrp subject_number: replace maxdate=maxdate[_n-1] if maxdate==.

drop if visitdate>maxdate 
drop maxdate*/

sort subject_number visitdate 
by subject_number: gen grpindexn=_n 
lab var grpindexn "initiator group index n; 1=baseline visit"

// 2024-02-29 carry all base_* to the end of data, and use the init row for the baseline row if baseline is prior to init 
foreach z in nhx_b_ts_generic pres_cuprimine pres_ridaura hx_cyclosporine hx_mtx hx_amjevita hx_simponi_aria hx_rituxan_bs       hx_xeljanz_xr hx_etanercept hx_plaquenil hx_humira hx_avsola hx_ruxience hx_rinvoq hx_adalimumab hx_golimumab hx_ridaura hx_kineret hx_inflectra        hx_truxima hx_kenalog hx_arava hx_imuran hx_rituximab hx_cimzia hx_remicade hx_kevzara hx_meth_pred hx_azulfidine hx_infliximab hx_sirukumab        hx_enbrel hx_remicade_bs hx_actemra hx_pred hx_corticosteroids  hx_invest hx_tofacitinib hx_erelzi hx_renflexis hx_olumiant hx_cuprimine hx_minocin hx_orencia hx_simponi hx_rituxan hx_xeljanz{
    by subject_number: replace base_`z'=base_`z'[_n-1] if base_`z'==.
	by subject_number: replace base_`z'=base_`z'[_n+1] if base_`z'==. & grpindexn==1 & fu_days<0
}

// string variables
foreach z in pres_cdmards_name prev_drug prev_generic prev_reason_1 prev_reason_2 prev_reason_3 prev_reason_1_category prev_reason_2_category prev_reason_3_category{
	by subject_number: replace base_`z'=base_`z'[_n-1] if base_`z'==""
	by subject_number: replace base_`z'=base_`z'[_n+1] if base_`z'=="" & grpindexn==1 & fu_days<0
}


# delimit;
order subject_number
site_number
visitdate
visit_indexn
visit_indexN 
enroll_visit
last_visit
prev_visit
next_visit
full_version
c_provider_id
dw_event_type_acronym
study_acronym
source_acronym
druggrp
init_date
base_visit
fu_days
fu_grp
stop
stop_date
cumstop
switch
switch_order
firstswitch
switchname
grpindexn
base_*
start_*
numstart
namestart
;
# delimit cr;

save init_`y', replace 
}

// testing data 
*use init_amjevita, clear

// try to append 
// 11-7-2022 added avsola 
use init_adalimumab, clear 
foreach y in etanercept golimumab infliximab rituximab tofacitinib orencia humira  amjevita kineret cimzia enbrel erelzi simponi simponi_aria avsola inflectra remicade remicade_bs renflexis rituxan rituxan_bs ruxience truxima kevzara actemra olumiant xeljanz xeljanz_xr rinvoq {
    append using "init_`y'.dta"
}

groups druggrp if grpindexn==1
drop start_details

save 2_2_allinits, replace 

save "..\2_2_allinits", replace

// eliminate temporary files
foreach y in adalimumab etanercept golimumab infliximab rituximab tofacitinib amjevita erelzi  $btsdmards_drug_list {
cap erase `y'_init_date.dta 
cap erase `y'_stop_date.dta
cap erase init_`y'.dta
}
cap erase allvisits_starts.dta
cap erase drug_temp.dta 

unique subject_number druggrp visitdate 

corcf * using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\2_2_allinits", id(subject_number druggrp visitdate)

merge 1:1 subject_number druggrp visitdate using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\2_2_allinits", keepus(subject_number druggrp visitdate)

preserve 
keep if _m==1 
list subject_number druggrp visitdate in 1/5, noobs ab(16)
restore 

for any 001010063: list _m subject_number druggrp visitdate grpindexn init_date base_visit fu_days fu_grp stop stop_date switch firstswitch switchname if subject_number=="X" & druggrp=="golimumab", noobs ab(16)

corcf * using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-06-01\2_2_allinits", id(subject_number druggrp visitdate)

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-06-01\2_2_allinits",clear 
for any 001010063: list  subject_number druggrp visitdate grpindexn init_date base_visit fu_days fu_grp stop stop_date switch firstswitch switchname if subject_number=="X" & druggrp=="golimumab", noobs ab(16) // switched to cimzia 2009-07-28

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-07-01\archived\2_2_allinits", clear
for any 001010063: list  subject_number druggrp visitdate grpindexn init_date base_visit fu_days fu_grp stop stop_date switch firstswitch switchname if subject_number=="X" & druggrp=="golimumab", noobs ab(16) 

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-07-01\2_1_drugexpdetails", clear
for any 001010063: list  subject_number visitdate visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_start drug_start_date drug_stop drug_stop_date if subject_number=="X" & inlist(drug_key, "simponi", "cimzia"), noobs ab(16) sepby(drug_key)
// LG 2024-07-10 note: the imputed stop date for simponi at visit #9 was the next visitdate, 2009-07-28, and cimzia start date was imputed as earlier than this stop date, on 2009-07-01. drug_date_raw was 2009-07-01. In this case, should have used the start date of the next drug or the mid of current drug date and the next visit, somewhere in May, instead of using the next visitdate. 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-06-01\2_1_drugexpdetails", clear
for any 001010063: list  subject_number visitdate visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_start drug_start_date drug_stop drug_stop_date if subject_number=="X" & inlist(drug_key, "simponi", "cimzia"), noobs ab(16) sepby(drug_key) // drug_stop was not identified.

use  "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-07-01\archived\2_1_drugexpdetails", clear
for any 001010063: list  subject_number visitdate visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_start drug_start_date drug_stop drug_stop_date if subject_number=="X" & inlist(drug_key, "simponi", "cimzia"), noobs ab(16) sepby(drug_key) 

// 2024-08-19 testing GR's bug examples 
// inconsistent in June 2024, fixed
for any 101011364 101010781: list subject_number druggrp visitdate grpindexn init_date base_visit fu_days fu_grp stop stop_date switch firstswitch switchname if subject_number=="X" & inlist(druggrp,"adalimumab", "humira"), noobs ab(16) sepby(druggrp)

cap log close 
