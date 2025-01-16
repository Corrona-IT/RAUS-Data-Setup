/*

Date: 2023-11-15 
Programmer: Ying Shan 
Aim: setup master 

do file: master setup do  
data use baseview monthly download bv_*, fv_* data and site info from saleforce 

2024-09-03 LG setup v20240901 datacut

2024-11-01 LG adding _YYYY-MM-DD to analytic data names

2025-01-01 LG changes

1. For DQ initiative purpose, also add datacut for clean_table\
2. To reduce the size of all data, run compress before saving 
3. updated infection, alllabs, allvisits code 
4. per EDW, -	Column name change to bv_subject_demographic_data: “birth_year” will now be “birthyear” per Biostats request. 
*/ 

*odbc query dwh, schema verbose 

global prog "~/Corrona LLC/Biostat Data Files - RA\Setup\setup_code\ODBC" 

global datacut "2025-01-01"
global pdatacut "2024-12-01"
// 2025-01-09 v20250108 data also include data later than 31dec2024 
global cutdate 31dec2024

global pdata "~/Corrona LLC/Biostat Data Files - RA\monthly\2024\\$pdatacut" // for run test.do

cd "~/Corrona LLC/Biostat Data Files - RA/monthly\2025\\$datacut\"  

mkdir bv_raw\ 
mkdir temp\
mkdir clean_table\ 
mkdir temp\data\ 
mkdir temp\rawdata\

cap log close
do "$prog/0_0_siteinfo_2024-12-01.do" 
// 2024-12-02: saving site data to clean_table for easier transforming analytic data to R. site 176 pending close out.
// 2025-01-01 site 240 pending close out

// 2025-01-09 still having issue downloading bv_labs view 
do "bv_raw/export_odbc_2025-01-13.do"

cap log close
log using temp\test_data_2025-01-13.log, append //replace 
do "$prog/test_data_2025-01-09.do" 
log close 
// 2024-12-02 reported missing bv_subjects and bv_event_instances data and missing reason_code_1 for DW and PP in bv_conmed view 

cap log close
log using temp\1_7_allcomor_2025-01-13.log, replace 
do "$prog/1_7_allcomor_2025-01-09.do" 
// 2025-01-09: removed 12 rows with data entered later than 31dec2024, compress before saving, save data set name with datacut  
// 2024-12-04: check the update regarding comor_code 17090
// 2024-10-30: LG added anaphylaxis for ana data; 2024-12-03 missing bv_event_instances view, cannot run 
for any 000000000: list subject_number visitdate if subject_number=="X", noobs ab(16)
/*
  +-----------------------------+
  | subject_number    visitdate |
  |-----------------------------|
  |      000000000   2009-12-07 |
  |      000000000   2009-12-07 |
  |      000000000   2009-12-07 |
  +-----------------------------+
*/
/* not having the same schema will give a wrong visitdate to some preTM patients
use "C:\Users\lguo\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-12-01\clean_table\archived\1_7_allcomor", clear 
for any 000000000: list subject_number visitdate if subject_number=="X", noobs ab(16)
  +-----------------------------+
  | subject_number    visitdate |
  |-----------------------------|
  |      000000000   2015-12-30 |
  |      000000000   2015-12-30 |
  |      000000000   2015-12-30 |
  +-----------------------------+
*/
log close 
// 2024-12-04 event_instances data is available 

log using temp\1_8_allinf.log, replace 
do "$prog/1_8_allinf_2025-01-09.do"  
// 2025-01-02: Ying made minor adjustments to adapt the difference between inf_type and inf_type_txt with Covid-19 etc. Name is not changed. Lin needs to add datacut to the name and remove visit dates beyond datacut 
// 2024-09-03: LG changed from fv_ to bv_; 2024-12-03 missing bv_event_instances view, cannot run
log close 
// 2024-12-04 event_instances data is available 

// 2024-12-02 event_instances and subject views are not required.

// 2025-01-09 problem with 1.7million rows added compared to the prev datacut hold to the data cleaning 

log using temp\1_3_othmed.log, replace  
do "$prog/1_3_othmed_2025-01-14.do"  
// clean bv_conmed- all non RA drug (NSAIDs, OP, pain, CVD, GI, antidepress, and other medication) from SU & MD form
log close 

// 2025-01-14 place holder for further clean 1.4 alllabs data, after R code 
cap log close 
log using temp\1_4_alllabs.log, replace 
do "$prog/1_4_alllabs_clean_2025-01-13.do"
// 2025-01-14 place holder for further clean 1.5 exit data, after R code 
cap log close 
log using temp\1_5_exits.log, replace 
do "$prog/1_5_exit_clean_2025-01-14.do"

// 2024-12-03 cannot run without bv_subjects data 
// 2024-12-04 subject view available, making site_type as a numeric var. 
cap log close 
log using temp\1_1_subjects.log, replace 
do "$prog/1_1_subjects_2025-01-09.do"  
// 2025-01-09 LG subject_demographic data has changed from birth_year to birthyear. Using subject data to update and replaced birthyear and site_number on row # 664
// clean and combine bv_subjects_demographic_data, fv_subjects, bv_exit(exit reason), and site info 
// 2024-10-02 LG updated state for site 262, no missing for region; noticed var name race_other_specify to race_other_txt
log close 

// 2025-01-09 still waiting for the download of bv_labs 
// 2024-12-04 re-run allvisits data to see why 2015-12-30 was added for 000000000 
log using temp\1_2_allvisits.log, append //replace
 
do "$prog/1_2_allvisits_2025-01-14.do" 
// clean bv_longitudinal and combine with some variables from bv_lab, fv_event_instance, calcv_haqs 
// 2024-10-02 LG: bp cleaning steps are not decided yet
log close 
// 2024-12-04 check if visitdates are out of range  
use clean_table\1_2_allvisits_$datacut, clear 
unique subject_number visitdate 
corcf * using "$pdata\\clean_table\1_2_allvisits_$pdatacut", id(subject_number visitdate)
/*
lab_yn: 828 mismatches
deformity: 12223 mismatches
erosions: 25472 mismatches
jt_sp_narrow: 32657 mismatches
imaging_yn: 5 mismatches
radrug_yn: 44 mismatches
comor_yn: 503 mismatches
infection_yn: 1903 mismatches
conmed_yn: 6 mismatches
*/

rename lab_yn jan25_lab_yn
rename infection_yn jan_infection_yn
rename comor_yn jan25_comor_yn 

rename deformity jan25_deformity
rename erosions jan25_erosions
rename jt_sp_narrow jan25_jt_sp_narrow

merge 1:1 subject_number visitdate using "$pdata\\clean_table\1_2_allvisits_$pdatacut", keepus(lab_yn comor_yn infection_yn deformity erosions jt_sp_narrow)
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                         2,253
        from master                     2,242  (_merge==1)
        from using                         11  (_merge==2)

    matched                           505,518  (_merge==3)
    -----------------------------------------
*/
codebook visitdate if _m==1 
// 2025-01-14 Ying changed the label for deformity, erosions and jt_sp_narrow

* br subject_number visitdate *comor_yn if _m==3 & comor_yn!=dec24_comor_yn
br subject_number visitdate *deformity if _m==3 & jan25_deformity!=deformity

br subject_number visitdate *lab_yn if _m==3 & jan25_lab_yn!=lab_yn

br subject_number visitdate *infection_yn if _m==3 & jan_infection_yn!=infection_yn

groups jan25_deformity deformity if _m==3 & jan25_deformity!=deformity, noobs ab(16) missing

// 2025-01-14 document for label change in README:

foreach x in deformity erosions jt_sp_narrow{
	rename `x' dec24_`x'
	groups jan25_`x' dec24_`x' if _m==3, ab(16)
}

groups jan25_deformity deformity if _m==3, noobs ab(16)  //missing& jan25_deformity!=deformity

groups comor_yn jan25_comor_yn if _m==3 & comor_yn!=jan25_comor_yn, noobs ab(16)

groups infection_yn jan_infection_yn if _m==3 & infection_yn!=jan_infection_yn, noobs ab(16)


cap log close
log using temp\1_6_drugrecord.log, replace

do "$prog/1_6_drugrecord_2025-01-14.do" 
// 2024-12-05:dropped 3 rows of visitdate 12/30/2024 and 11 rows after 11/30/2024
// 2024-12-04 checking visitdate and drug_date data entry issue, one subject had 30dec2024
// LG 2024-11-04: making reason_i/_category/_code consistent

////////////////	2024-10-01 started to add YYYY-MM-DD to the analytic data names 

// 2024-11-04 found inconsistencies between reason_category vs. reason_category_code after unique date cleaning step 
cap log close 
log using temp\2_1_drugexpdetails.log, replace //append  

do "$prog/2_1_drugexpdetails_2025-01-14.do"

cap log close

log using temp\2_3_keyvisitvars.log, replace // append  

do "$prog/2_3_keyvisitvars_2025-01-15.do"  // nsaid data had visitdate out of range 

use 2_3_keyvisitvars_$datacut, clear

corcf * using "$pdata\\2_3_keyvisitvars_$pdatacut", id(subject_number visitdate) //verbose noobs 

*corcf birthyear using "$pdata\\2_3_keyvisitvars_$pdatacut", id(subject_number visitdate) verbose noobs sepby(subject_number) // missing data filled in 
rename infection_yn jan25_infection_yn
merge 1:1 subject_number visitdate using "$pdata\\2_3_keyvisitvars_$pdatacut", keepus(visitdate infection_yn)
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         2,251
        from master                     2,240  (_merge==1)
        from using                         11  (_merge==2)

    matched                           505,516  (_merge==3)
    -----------------------------------------
*/

codebook visitdate if _m==1 
gen year=year(visitdate)
tab year if _m==1
list subject_number site_number full_version visitdate indexn indexN if _m==1 & year==2003, noobs ab(16)
/*
  +----------------------------------------------------------------------------+
  | subject_number   site_number   full_version    visitdate   indexn   indexN |
  |----------------------------------------------------------------------------|
  |      183786423             8              4   2003-11-15        2        2 |
  |      318505342             8              4   2003-11-19        2        2 |
  |      389149020             2              5   2003-12-01        1       21 |
  |      442172803             5              5   2003-10-01        2        3 |
  |      450939242            53              4   2003-10-06        2        2 |
  |----------------------------------------------------------------------------|
  |      639539897            44              4   2003-12-11        2        6 |
  +----------------------------------------------------------------------------+
*/

log close 

log using temp\1_11_sumedprob.log, replace 
do "$prog/1_11_sumedprob_2025-01-15.do"
log close 

log using temp\2_2_initiations.log, replace  
do "$prog/2_2_initiations_2025-01-15.do" 

cap log close 

log using temp\2_4_drugexposures.log, replace
do "$prog/2_4_drugexposure_2024-10-31.do" 

cap log close
 


/* 2024-12-05: use R code to save alllabs_temp into temp folder, then run Ying's lab cleaning code to save alllabs data into clean_table folder 
cap log close 
log using 1_4_alllabs_clean.log, replace 
do  "$prog/1_4_alllabs_dose_clean_2024-11-26_LG20241205.do"
*/
// also run R code to clean 1_5 exits data 

// after all analytic data is ready, use R to create R data into DQ checks folder and create data dictionary.

// monthly executive slides 
cd "~\Corrona LLC\Biostat Data Files - RA\registry_counts\Monthly_Registry_slides"
global data "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\\$datacut"

log using monthly_executive_$datacut.log, replace

use "$data\\2_3_keyvisitvars_$datacut", clear

global rptdt 2025-01
do "~\Corrona LLC\Biostat Data Files - RA\registry_counts\Monthly_Registry_slides\Monthly_executive_slides_2024-11-04.do"


