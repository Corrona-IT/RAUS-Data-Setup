/*
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
cd "C:\Users\lguo\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\temp"

global testdata "~\Corrona LLC\Biostat Data Files - RA\monthly\ODBC\dwh_db\2024-02-02"

cap log close

log using ".\temp_data\build_drug_exp_details_2024-02-23.log", append //replace

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_1_DrugExpDetails_v20240202", clear

/*groups  generic_start drug_start, missing ab(16)

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
*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_1_DrugExpDetails_v20240202", clear 


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

preserve 
keep subject_number drug_date visitdate nhx_b_ts_generic pres_cdmards_name hx_*
drop hx_drug hx_generic
sort subject_number visitdate drug_date 
by subject_number visitdate: gen drug_indexn=_n 
by subject_number visitdate: gen drug_indexN=_N 
tab drug_indexN 
// keep the last row as the most recent hx at the visit level
keep if drug_indexN==drug_indexn 

unique subject_number visitdate 
drop *index*
drop drug_date 

save cdmard_hx, replace 

restore 

use start_btdmards_1st_per_visit_drug, clear 
merge 1:1 subject_number visitdate using start_btdmards_1st_per_visit_generic
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        18,701
        from master                    18,336  (_merge==1)
        from using                        365  (_merge==2)

    matched                            54,089  (_merge==3)
    -----------------------------------------
*/
// keep all 
/*br if _m==2 
groups subject_number if _m==2, missing ab(16)

  +-------------------------------------------+
  | subject_number   Freq.   Percent      %<= |
  |-------------------------------------------|
  |      064010517      21     46.67    46.67 |
  |      081178947      11     24.44    71.11 |
  |      112020023       2      4.44    75.56 |
  |      149010858      11     24.44   100.00 |
  +-------------------------------------------+
*/
drop _m 
save start_btdmards_1st_per_visit, replace 

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\clean_table\1_2_allvisits.dta", clear
mdesc visitdate // 148 missing 

mdesc study_source dw_event_type, ab(24)
groups study_source dw_event_type, missing ab(16) // no TAE 
*format visitdate %tdCCYY-NN-DD  
*drop if visitdate==. // 2024-02-12 let Ying know 

keep subject_number visitdate study_source dw_event_type
unique subject_number visitdate 
sort subject_number visitdate 

by subject_number: gen visit_indexn=_n 
by subject_number: gen visit_indexN=_N 

by subject_number: gen enroll_visit=visitdate[1]
by subject_number: gen last_visit=visitdate[_N]
by subject_number: gen prev_visit=visitdate[_n-1] // not using prev_visit yet, just in case will use it later. 
by subject_number: gen next_visit=visitdate[_n+1]

clonevar linked_visit=visitdate 

format linked_visit enroll_visit last_visit prev_visit next_visit %tdCCYY-NN-DD  

keep subject_number linked_visit visitdate visit_index* enroll_visit last_visit prev_visit next_visit
mdesc *

sort subject_number visitdate 
save allvisits_link_visit, replace 


/////////////////////////////////////////////////////////////////////
// STEP A. use simplified visitdate data to add cdmard use 
use allvisits_link_visit, clear 
merge 1:1 subject_number visitdate using cdmard_hx

drop if _m==2
// carry all hx to the last visit 
sort subject_number visitdate 
ds hx*, v(32)
local hxlist " `r(varlist)' " 
foreach x of local hxlist { 
by subject_number: replace `x'=`x'[_n-1] if `x'==.
}
by subject_number: replace nhx_b_ts_generic=nhx_b_ts_generic[_n-1] if nhx_b_ts_generic==.
rename _m drug_details
lab var drug_details "visit with drug details data, 1=visit data only;3=with drug details"

save allvisits_cdmard_hx,replace 


/////////////////////////////////////////////////////////////////////
// STEP B, add drug start wide data
use  allvisits_cdmard_hx, clear
merge 1:1 subject_number visitdate using start_btdmards_1st_per_visit

rename _m start_details
lab var start_details "visit with drug start data, 1=no starts;3=with drug starts"

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

save allvisits_cdmard_hx_starts, replace 

/////////////////////////////////////////////////////////////////////////////////
///////////////////// Next, Step C for each drug/generic 

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_1_DrugExpDetails_v20240202", clear

sort subject_number drug_date
// generate last drug/generic used and reason for disc for initiators
foreach x in drug generic{
    keep if inlist(drug_category, 250,390)
    cap drop prev_`x' prev_reason1 prev_reason2 prev_reason3 
by subject_number : gen prev_`x'=`x'_key[_n-1]  if init_`x'==1
by subject_number : gen prev_`x'_reason1=reason_1_category[_n-1]  if init_`x'==1
by subject_number : gen prev_`x'_reason2=reason_2_category[_n-1]  if init_`x'==1
by subject_number : gen prev_`x'_reason3=reason_3_category[_n-1]  if init_`x'==1
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
foreach y in $btsdmards_drug_list amjevita erelzi{
// merge using base_visit from drugexpdetails at init 
preserve 
keep if drug_key=="`y'" & init_drug==1
keep drug_key subject_number drug_base_visit drug_init_date  prev_drug prev_generic prev_drug_reason1-prev_drug_reason3 prev_generic_reason1-prev_generic_reason3
rename drug_key druggrp
rename drug_init_date init_date
rename drug_base_visit base_visit 
save `y'_init_date, replace 
restore 
 
// create drug data with everinit and with the first stopped date 
// 2024-02-16 create the first stop date for initiators  
preserve 
keep if drug_key=="`y'" & everinit_drug==1 & drug_stop==1 & drug_stop_order==1 & drug_base_visit<.
keep drug_key subject_number drug_stop drug_stop_date drug_stop_visit
rename drug_key druggrp 
rename drug_stop stop 
rename drug_stop_date stop_date
rename drug_stop_visit visitdate
*rename visitdate first_stop_visit
save `y'_stop_date, replace 
restore 
}

foreach y in adalimumab etanercept golimumab infliximab rituximab tofacitinib{
// merge using base_visit from drugexpdetails at init 
preserve 
keep if generic_key=="`y'" & init_generic==1
keep generic_key subject_number generic_base_visit generic_init_date  prev_drug prev_generic prev_drug_reason1-prev_drug_reason3 prev_generic_reason1-prev_generic_reason3
rename generic_key druggrp 
rename generic_base_visit base_visit 
rename generic_init_date init_date 
save `y'_init_date, replace 
restore 
 
// create drug data with everinit and with the first stopped date 
// 2024-02-16 create the first stop date for initiators  
preserve 
keep if generic_key=="`y'" & everinit_generic==1 & generic_stop==1 & generic_stop_order==1 & generic_base_visit<.
keep generic_key subject_number generic_stop generic_stop_date generic_stop_visit
rename generic_key druggrp 
rename generic_stop stop 
rename generic_stop_date stop_date
rename generic_stop_visit visitdate
*rename visitdate first_stop_visit
save `y'_stop_date, replace 
restore 
}

use drug_temp, clear
foreach y in $btsdmards_drug_list adalimumab etanercept golimumab infliximab rituximab tofacitinib{
    display "`y'"
// Add C to data B 
use allvisits_cdmard_hx_starts, clear 
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
*gen druggrp="orencia" 
gen fu_days=visitdate-init_date 
*sum fu_days, d // min: -183

// find 6 month (91-274 days) and 12 month (275-458 days)

// 1. if stopped during the FU window, use the stopped visit 
gen fu_6m=1 if fu_days>90 & fu_days<274 & stop==1

egen everfu_6m=sum(fu_6m), by(subject_number druggrp)

replace fu_6m=1 if everfu_6m==0 & fu_days>90 & fu_days<274

gen fu_12m=1 if fu_days>=274 & fu_days<458 & stop==1

egen everfu_12m=sum(fu_12m), by(subject_number druggrp)

replace fu_12m=1 if everfu_12m==0 &  fu_days>=274 & fu_days<458

// 2. if stopped prior to the FU window, use the earlier one if more than one visit within the FU window 
// generate a duplicate indicator for fu_grp 
cap drop dup_fu6 dup_fu12
cap duplicates tag subject_number druggrp fu_6m if fu_6m==1 & everfu_6m==0, gen(dup_fu6)
cap duplicates tag subject_number druggrp fu_12m if fu_12m==1 & everfu_12m==0, gen(dup_fu12)

cap egen min_fu6=min(fu_days) if dup_fu6>=1 & dup_fu6<., by(subject_number druggrp)
cap egen min_fu12=min(fu_days) if dup_fu12>=1 & dup_fu12<., by(subject_number druggrp)

clonevar fu_6m_raw=fu_6m
clonevar fu_12m_raw=fu_12m

sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumstop=sum(stop)
*tab cumstop,m 
cap replace fu_6m=. if fu_days>min_fu6 & dup_fu6>=1 & dup_fu6<. & cumstop==1 & stop==.
cap replace fu_12m=. if fu_days>min_fu12 & dup_fu12>=1 & dup_fu12<.  & cumstop==1 & stop==.


// 3.1 if stopped later than the FU window and more than 1 visits available in the FU window, choose the one that is closer to 183 or 365

gen dif_temp=abs(fu_days-183) if fu_6m==1
replace dif_temp=abs(fu_days-365) if fu_12m==1

cap egen dif_temp_6=min(dif_temp) if fu_6m==1 & dup_fu6>=1 & dup_fu6<., by(subject_number druggrp)
cap egen dif_temp_12=min(dif_temp) if fu_12m==1 & dup_fu12>=1 & dup_fu12<., by(subject_number druggrp)

cap replace fu_6m=. if dif_temp>dif_temp_6 & fu_6m_raw==1 & dup_fu6>=1 & dup_fu6<. & cumstop==0 
cap replace fu_12m=. if dif_temp>dif_temp_12 & fu_12m_raw==1 & dup_fu12>=1 & dup_fu12<.& cumstop==0 


// 3.2 if stopped later than the FU window and more than 1 visits available and there are two visits to the same distance of 183 or 365, choose the later one to have more exposure time 

*duplicates list subject_number fu_6m if fu_6m==1
cap duplicates tag subject_number fu_6m if fu_6m==1, gen(dup2_fu6)
*tab dup2_fu6 

*duplicates list subject_number fu_12m if fu_12m==1
cap duplicates tag subject_number fu_12m if fu_12m==1, gen(dup2_fu12)
*tab dup2_fu12 

// use the later visit to have more exposure time 
cap egen max_fu6=max(fu_days) if dup2_fu6>=1 & dup2_fu6<., by(subject_number druggrp)
cap egen max_fu12=max(fu_days) if dup2_fu12>=1 & dup2_fu12<., by(subject_number druggrp)
cap replace fu_6m=. if fu_days<max_fu6 & dup2_fu6>=1 & dup2_fu6<.
cap replace fu_12m=. if fu_days<max_fu12 & dup2_fu12>=1 & dup2_fu12<.

// simplify variable
gen fu_grp=6 if fu_6m==1
replace fu_grp=12 if fu_12m==1 

drop fu_6m everfu_6m fu_12m everfu_12m dup_fu6 dup_fu12 min_fu6 min_fu12 fu_6m_raw fu_12m_raw dif_temp dif_temp_6 dif_temp_12 dup2_fu6 dup2_fu6 dup2_fu12 max_fu6 max_fu12


gen switch=1 if cumstop==1 & numstart>=1 & strpos(namestart,"`y'")==0
*tab switch,m 
sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumswitch=sum(switch)

*tab cumswitch,m  
gen firstswitch=1 if cumswitch==1 & switch==1 
*groups namestart if firstswitch==1
*unique subject_number if drug_stop==1
*unique subject_number if firstswitch==1
*groups cumstop firstswitch, missing ab(16)

gen switchname=namestart if firstswitch==1

// create 4 visitdates and carry to the end, then drop the visitdates that are larger than the latest visit 
gen fu6_visit=visitdate if fu_grp==6 
gen fu12_visit=visitdate if fu_grp==12
gen stop_visit=visitdate if stop==1
gen switch_visit=visitdate if firstswitch==1 
format fu6_visit fu12_visit stop_visit switch_visit %tdCCYY-NN-DD
sort druggrp subject_number visitdate 
foreach x in fu6 fu12 stop switch {
by druggrp subject_number: replace `x'_visit=`x'_visit[_n-1] if `x'_visit==.
} 

cap drop maxdate 
egen maxdate=rowmax(fu6_visit fu12_visit stop_visit switch_visit) if cumswitch==1 & fu_days>458
format maxdate %tdCCYY-NN-DD
sort druggrp subject_number visitdate
by druggrp subject_number: replace maxdate=maxdate[_n-1] if maxdate==.

drop if visitdate>maxdate 

drop maxdate 

sort subject_number visitdate 
by subject_number: gen grpindexn=_n 

save init_`y', replace // size: 24.79M
}

///////////////////////	Run separately for amjevita and erelzi 

use drug_temp, clear

foreach y in amjevita erelzi{
    display "`y'"
// Add C to data B 
use allvisits_cdmard_hx_starts, clear 
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
*gen druggrp="orencia" 
gen fu_days=visitdate-init_date 
*sum fu_days, d // min: -183

// find 6 month (91-274 days) and 12 month (275-458 days)

// 1. if stopped during the FU window, use the stopped visit 
gen fu_6m=1 if fu_days>90 & fu_days<274 & stop==1

egen everfu_6m=sum(fu_6m), by(subject_number druggrp)

replace fu_6m=1 if everfu_6m==0 & fu_days>90 & fu_days<274

gen fu_12m=1 if fu_days>=274 & fu_days<458 & stop==1

egen everfu_12m=sum(fu_12m), by(subject_number druggrp)

replace fu_12m=1 if everfu_12m==0 &  fu_days>=274 & fu_days<458

// 2. if stopped prior to the FU window, use the earlier one if more than one visit within the FU window 
/* generate a duplicate indicator for fu_grp 
cap drop dup_fu6 dup_fu12
duplicates tag subject_number druggrp fu_6m if fu_6m==1 & everfu_6m==0, gen(dup_fu6)
duplicates tag subject_number druggrp fu_12m if fu_12m==1 & everfu_12m==0, gen(dup_fu12)
tab dup_fu6 
tab dup_fu12

cap egen min_fu6=min(fu_days) if dup_fu6>=1 & dup_fu6<., by(subject_number druggrp)
cap egen min_fu12=min(fu_days) if dup_fu12>=1 & dup_fu12<., by(subject_number druggrp)

clonevar fu_6m_raw=fu_6m
clonevar fu_12m_raw=fu_12m
*/
sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumstop=sum(stop)
/*
*tab cumstop,m 
cap replace fu_6m=. if fu_days>min_fu6 & dup_fu6>=1 & dup_fu6<. & cumstop==1 & drug_stop==.
cap replace fu_12m=. if fu_days>min_fu12 & dup_fu12>=1 & dup_fu12<.  & cumstop==1 & drug_stop==.


// 3.1 if stopped later than the FU window and more than 1 visits available in the FU window, choose the one that is closer to 183 or 365

gen dif_temp=abs(fu_days-183) if fu_6m==1
replace dif_temp=abs(fu_days-365) if fu_12m==1

cap egen dif_temp_6=min(dif_temp) if fu_6m==1 & dup_fu6>=1 & dup_fu6<., by(subject_number druggrp)
cap egen dif_temp_12=min(dif_temp) if fu_12m==1 & dup_fu12>=1 & dup_fu12<., by(subject_number druggrp)

cap replace fu_6m=. if dif_temp>dif_temp_6 & fu_6m_raw==1 & dup_fu6>=1 & dup_fu6<. & cumstop==0 
cap replace fu_12m=. if dif_temp>dif_temp_12 & fu_12m_raw==1 & dup_fu12>=1 & dup_fu12<.& cumstop==0 


// 3.2 if stopped later than the FU window and more than 1 visits available and there are two visits to the same distance of 183 or 365, choose the later one to have more exposure time 

*duplicates list subject_number fu_6m if fu_6m==1
cap duplicates tag subject_number fu_6m if fu_6m==1, gen(dup2_fu6)
*tab dup2_fu6 

*duplicates list subject_number fu_12m if fu_12m==1
cap duplicates tag subject_number fu_12m if fu_12m==1, gen(dup2_fu12)
*tab dup2_fu12 

// use the later visit to have more exposure time 
cap egen max_fu6=max(fu_days) if dup2_fu6>=1 & dup2_fu6<., by(subject_number druggrp)
cap egen max_fu12=max(fu_days) if dup2_fu12>=1 & dup2_fu12<., by(subject_number druggrp)
cap replace fu_6m=. if fu_days<max_fu6 & dup2_fu6>=1 & dup2_fu6<.
cap replace fu_12m=. if fu_days<max_fu12 & dup2_fu12>=1 & dup2_fu12<.
*/
// simplify variable
gen fu_grp=6 if fu_6m==1
replace fu_grp=12 if fu_12m==1 

cap drop fu_6m everfu_6m fu_12m everfu_12m dup_fu6 dup_fu12 min_fu6 min_fu12 fu_6m_raw fu_12m_raw dif_temp dif_temp_6 dif_temp_12 dup2_fu6 dup2_fu6 dup2_fu12 max_fu6 max_fu12


gen switch=1 if cumstop==1 & numstart>=1 & strpos(namestart,"`y'")==0
*tab switch,m 
sort subject_number druggrp visitdate 
by subject_number druggrp: gen cumswitch=sum(switch)

*tab cumswitch,m  
gen firstswitch=1 if cumswitch==1 & switch==1 
*groups namestart if firstswitch==1
*unique subject_number if drug_stop==1
*unique subject_number if firstswitch==1
*groups cumstop firstswitch, missing ab(16)

gen switchname=namestart if firstswitch==1

// create 4 visitdates and carry to the end, then drop the visitdates that are larger than the latest visit 
gen fu6_visit=visitdate if fu_grp==6 
gen fu12_visit=visitdate if fu_grp==12
gen stop_visit=visitdate if stop==1
gen switch_visit=visitdate if firstswitch==1 
format fu6_visit fu12_visit stop_visit switch_visit %tdCCYY-NN-DD
sort druggrp subject_number visitdate 
foreach x in fu6 fu12 stop switch {
by druggrp subject_number: replace `x'_visit=`x'_visit[_n-1] if `x'_visit==.
} 
/* keep all for amjevita and erelzi
cap drop maxdate 
egen maxdate=rowmax(fu6_visit fu12_visit stop_visit switch_visit) if cumswitch==1 & fu_days>458
format maxdate %tdCCYY-NN-DD
sort druggrp subject_number visitdate
by druggrp subject_number: replace maxdate=maxdate[_n-1] if maxdate==.

drop if visitdate>maxdate 
drop maxdate*/

sort subject_number visitdate 
by subject_number: gen grpindexn=_n 

save init_`y', replace // size: 24.79M
}


foreach y in adalimumab etanercept golimumab infliximab rituximab tofacitinib amjevita erelzi  $btsdmards_drug_list {
cap erase `y'_init_date.dta 
cap erase `y'_stop_date.dta
}

// try to append 
// 11-7-2022 added avsola 
use init_adalimumab, clear 
foreach y in etanercept golimumab infliximab rituximab tofacitinib orencia humira  amjevita kineret cimzia enbrel erelzi simponi simponi_aria avsola inflectra remicade remicade_bs renflexis rituxan rituxan_bs ruxience truxima kevzara actemra olumiant xeljanz xeljanz_xr rinvoq {
    append using "init_`y'.dta"
}
drop linked_visit
save "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", replace

use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
groups druggrp if grpindexn==1
for any 002020417: list subject_number druggrp visitdate init_date base_visit fu_days fu_grp stop switch visit_indexn grpindexn if subject_number=="X" , noobs ab(16) sepby(druggrp)

/*
use init_orencia, clear
// provide some PPT examples for drug switches 
for any 001010019 001010052 001010063  001010082 001010095: list subject_number druggrp grpindexn visitdate visit_indexn visit_indexN drug_init_date drug_base_visit fu_days fu_grp drug_stop  firstswitch fu6_visit fu12_visit stop_visit switch_visit if subject_number=="X", noobs ab(16) sepby(druggrp) 
// example for never stopped drug 
preserve 
keep if cumstop==0 & grpindexn>10
list subject_number druggrp grpindexn visitdate drug_init_date drug_base_visit fu_days fu_grp drug_stop  firstswitch fu6_visit fu12_visit stop_visit switch_visit prev_drug switchname in 1/5, noobs ab(16)
restore 

for any 000123496 001010010: list subject_number druggrp grpindexn visitdate drug_init_date drug_base_visit fu_days fu_grp drug_stop  firstswitch fu6_visit fu12_visit stop_visit switch_visit prev_drug switchname if subject_number=="X", noobs ab(16) sepby(druggrp) 
*/
/////////////////////////////////	Training Session #4 

//////////////////	Feasibility for Janssen 101 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\allinits", clear 
/// 3 categories of CCP 
clonevar base_CCPcat3=base_ccpposever
replace base_CCPcat3=2 if  base_ccphighposever==1 
lab define base_CCPcat3 0 "CCP low (CCP < 20)" 1 "20<=CCP<250 (low positive)" 2 "CCP>=250 (high positive)", modify 
lab val base_CCPcat3 base_CCPcat3
lab var base_CCPcat3 "baseline CCP 3 categories"
// overall initiators 
count if druggrp=="orencia" & grpindexn==1 & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
count if druggrp=="rituxan" & grpindexn==1 & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
// initiators with 6-months FU 
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
// initiators with 6-months FU and with CDAI at both baseline and FU
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1
// initiators with 6-months FU and with CDAI at both baseline and FU & with CCP
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3<.
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3<.
// initiators with 6-months FU and with CDAI at both baseline and FU & with CCP<20
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==0
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==0
// initiators with 6-months FU and with CDAI at both baseline and FU & with CCP low positive
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==1
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==1
// initiators with 6-months FU and with CDAI at both baseline and FU & with CCP high positive
count if druggrp=="orencia" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==2
count if druggrp=="rituxan" & fu_grp==6 & selectmon==1 & cdai<. & base_cdai<. & base_cdai>10 & dofm(initmon)>=d(01dec2012) & base_numpriorbio>=1 & base_CCPcat3==2

/////////////////////	Feasibility for Janssen 101 using the new data 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
sort druggrp subject_number visitdate 
by druggrp subject_number : gen base_nhx_b_ts_generic=nhx_b_ts_generic[1]
// select study population
keep if inlist(druggrp, "orencia", "rituxan", "rituximab") & base_nhx_b_ts_generic>0 & init_date>=d(01dec2012)
// getting variables needed from keyvisitvars data
merge m:1 subject_number visitdate using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_3_keyvisitvars", keepus(cdai ccpposever ccphighposever) 
drop if _m==2
// create baseline value
sort druggrp subject_number visitdate 
foreach x in cdai ccpposever ccphighposever{
by druggrp subject_number : gen base_`x'=`x'[1]
}
keep if base_cdai<. & base_cdai>10
// overall initiators with a baseline visit
count if druggrp=="orencia" & grpindexn==1
count if druggrp=="rituxan" & grpindexn==1 
count if druggrp=="rituximab" & grpindexn==1 
// with baseline visit and a 6 month FU 
count if druggrp=="orencia" & fu_grp==6
count if druggrp=="rituxan" & fu_grp==6
count if druggrp=="rituximab" & fu_grp==6
// with baseline visit, a 6 month FU and cdai
count if druggrp=="orencia" & fu_grp==6 & cdai<.
count if druggrp=="rituxan" & fu_grp==6 & cdai<.
count if druggrp=="rituximab" & fu_grp==6 & cdai<.
// create CCP 3 levels 
clonevar base_CCPcat3=base_ccpposever
replace base_CCPcat3=2 if  base_ccphighposever==1 
lab define base_CCPcat3 0 "CCP low (CCP < 20)" 1 "20<=CCP<250 (low positive)" 2 "CCP>=250 (high positive)", modify 
lab val base_CCPcat3 base_CCPcat3
lab var base_CCPcat3 "baseline CCP 3 categories"
// count # with 6 month FU and cdai and with CCP 
count if druggrp=="orencia" & fu_grp==6 & cdai<. & base_CCPcat3<.
count if druggrp=="rituxan" & fu_grp==6 & cdai<. & base_CCPcat3<.
count if druggrp=="rituximab" & fu_grp==6 & cdai<. & base_CCPcat3<.
// count # with 6 month FU and cdai and with CCP<20 
count if druggrp=="orencia" & fu_grp==6 & cdai<. & base_CCPcat3==0
count if druggrp=="rituxan" & fu_grp==6 & cdai<. & base_CCPcat3==0
count if druggrp=="rituximab" & fu_grp==6 & cdai<. & base_CCPcat3==0
// count # with 6 month FU and cdai and with CCP low positive  
count if druggrp=="orencia" & fu_grp==6 & cdai<. & base_CCPcat3==1
count if druggrp=="rituxan" & fu_grp==6 & cdai<. & base_CCPcat3==1
count if druggrp=="rituximab" & fu_grp==6 & cdai<. & base_CCPcat3==1
// count # with 6 month FU and cdai and with CCP high positive  
count if druggrp=="orencia" & fu_grp==6 & cdai<. & base_CCPcat3==2
count if druggrp=="rituxan" & fu_grp==6 & cdai<. & base_CCPcat3==2
count if druggrp=="rituximab" & fu_grp==6 & cdai<. & base_CCPcat3==2


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////	Feasibility counts for Amgen 063
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\allinits", clear 
// overall count of initiators
count if grpindexn==1 & druggrp=="enbrel" & dofm(initmon)>=d(1nov2012)
count if grpindexn==1 & druggrp=="humira" & base_cdai<. //& dofm(initmon)>=d(1nov2012)
// # firstline initiators 
count if grpindexn==1 & druggrp=="enbrel" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0
count if grpindexn==1 & druggrp=="humira" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0
// # with 6 month FU 
count if druggrp=="enbrel" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0 & fu_grp==6 & selectmon==1
count if druggrp=="humira" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0 & fu_grp==6 & selectmon==1
// # with 12 month FU 
count if druggrp=="enbrel" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0 & fu_grp==12 & selectmon==1
count if druggrp=="humira" & dofm(initmon)>=d(1nov2012) & base_numpriorbio==0 & fu_grp==12 & selectmon==1

////////////////////// Feasibility using new data 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_1_DrugExpDetails_v20240202", clear
count if drug_key=="enbrel" & init_drug==1 & drug_date>=d(1nov2012)
count if drug_key=="humira" & init_drug==1 & drug_date>=d(1nov2012)
// # firstline initiators 
count if drug_key=="enbrel" & init_drug==1 & drug_date>=d(1nov2012) & nhx_b_ts_generic==0
count if drug_key=="humira" & init_drug==1 & drug_date>=d(1nov2012) & nhx_b_ts_generic==0
// # with 6 month FU and a baseline visit 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
sort druggrp subject_number visitdate 
by druggrp subject_number : gen base_nhx_b_ts_generic=nhx_b_ts_generic[1]
count if druggrp=="enbrel" & fu_grp==6 & init_date>=d(1nov2012) & base_nhx_b_ts_generic==0
count if druggrp=="humira" & fu_grp==6 & init_date>=d(1nov2012) & base_nhx_b_ts_generic==0
// with 12 month FU and a baseline visit 
count if druggrp=="enbrel" & fu_grp==12 & init_date>=d(1nov2012) & base_nhx_b_ts_generic==0
count if druggrp=="humira" & fu_grp==12 & init_date>=d(1nov2012) & base_nhx_b_ts_generic==0

//////////////////		generate KM curve 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\allinits", clear 
keep if (druggrp=="enbrel"|druggrp=="humira") & base_numpriorbio==0 & dofm(initmon)>=d(1nov2012)
stset fu_mon, id(id) fail(firstdisc==1)
sts graph, by(druggrp) xtitle("Follow-up time in months") legend(pos(6) rows(1) order (1 "enbrel" 2 "humira")) saving(KM_cohort1.png, replace)
graph export KM_cohort1.png,  width(1100) height(800)  replace
sts test druggrp , logrank
sts test druggrp, cox 

// output list table of survivor function
sts list, by(druggrp) at (6 12 18 24) compare //saving(stslist1,replace)
sts list, by(druggrp) at (6 12 18 24) risktable

//////////////////		generate KM curve using new data 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
sort druggrp subject_number visitdate 
by druggrp subject_number : gen base_nhx_b_ts_generic=nhx_b_ts_generic[1]
keep if (druggrp=="enbrel"|druggrp=="humira") & base_nhx_b_ts_generic==0 & init_date>=d(1nov2012) & fu_days>=0
stset fu_days, id(subject_number) fail(stop==1)
sts graph, by(druggrp) xtitle("Follow-up time in days") legend(pos(6) rows(1) order (1 "enbrel" 2 "humira")) saving(KM_newdata.png, replace)
graph export KM_newdata.png,  width(1100) height(800)  replace
sts test druggrp, logrank
sts test druggrp, cox 
// output list table of survivor function
sts list, by(druggrp) at (183 365 548 730) compare //saving(stslist1,replace)
sts list, by(druggrp) at (183 365 548 730) risktable

////////////////////	Selected Table 1 variables that were changed ////////////////
//////	OLD Way 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\allinits", clear 
keep if (druggrp=="enbrel"|druggrp=="humira") & base_numpriorbio==0 & fu_grp==6 & selectmon==1 & dofm(initmon)>=d(1nov2012) 
gen base_hxsrs_inf=base_hxhosp_infect|base_hxiv_infect
lab val base_hxsrs_inf ny
lab var base_hxsrs_inf "Serious infections"

foreach v in base_gender base_duration_ra base_rfposever base_ccpposever base_college base_newsmoker base_bmi base_hxsrs_inf base_hxcvd base_hxcancer {
foreach x in enbrel humira {    
		display "`x'"
sum `v' if druggrp=="`x'"
}
}

///////	NEW Way 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
sort druggrp subject_number visitdate 
by druggrp subject_number : gen base_nhx_b_ts_generic=nhx_b_ts_generic[1]
keep if (druggrp=="enbrel"|druggrp=="humira") & base_nhx_b_ts_generic==0 & init_date>=d(1nov2012) 
// get baseline variables from allvisits data 
merge m:1 subject_number visitdate using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_3_keyvisitvars", keepus(female_male duration_ra rfposever ccpposever c_education smoker3 bmi hx_inf_serious hx_comor_cvd hx_comor_cancer)
drop if _m==2 
//// create college completed variable 
gen college=c_education==5
replace college=. if c_education==.

sort druggrp subject_number visitdate 
foreach v in female_male duration_ra rfposever ccpposever college smoker3 bmi hx_inf_serious hx_comor_cvd hx_comor_cancer{
by druggrp subject_number: gen base_`v'=`v'[1]
}

foreach v in base_female_male base_duration_ra base_rfposever base_ccpposever base_college base_smoker3 base_bmi base_hx_inf_serious base_hx_comor_cvd base_hx_comor_cancer{
foreach x in enbrel humira {    
		display "`x'"
sum `v' if druggrp=="`x'" & fu_grp==6
}
}

////////////////////	Calculate CDAI change at 6 month FU 
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\allinits", clear 
keep if (druggrp=="enbrel"|druggrp=="humira") & base_numpriorbio==0 & fu_grp==6 & selectmon==1 & dofm(initmon)>=d(1nov2012) 
gen dif_cdai=base_cdai-cdai
ttest dif_cdai, by(druggrp)

////////////////////	Calculate CDAI change at 6 month FU using the new data
use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_2_allinits", clear
sort druggrp subject_number visitdate 
by druggrp subject_number : gen base_nhx_b_ts_generic=nhx_b_ts_generic[1]
keep if (druggrp=="enbrel"|druggrp=="humira") & base_nhx_b_ts_generic==0 & init_date>=d(1nov2012) 
// get baseline cdai and cdai at follow-up from allvisits data 
merge m:1 subject_number visitdate using "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-01-31\2_3_keyvisitvars", keepus(cdai)
drop if _m==2 
sort druggrp subject_number visitdate 
by druggrp subject_number: gen base_cdai=cdai[1]
gen dif_cdai=base_cdai-cdai if fu_grp==6
ttest dif_cdai, by(druggrp)

cap log close 
