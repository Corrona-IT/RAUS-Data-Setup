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

global datacut "2025-04-01"
global pdatacut "2025-03-01"
// 2025-01-09 v20250108 data also include data later than 31dec2024 
global cutdate 31mar2025

global pdata "~/Corrona LLC/Biostat Data Files - RA\monthly\2025\\$pdatacut" // for run test.do

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
do "bv_raw/export_odbc_2025-04-09.do"

cap log close
log using temp\test_data.log, append //replace 
do "$prog/0_1_test_data_2025-04-10.do" 
log close 

/////////////////////////////////////////////////////////
// 2025-02-06 drop 4 jr RA subjects from all data 
// 001010120 019100453 100140636 452722687
/////////////////////////////////////////////////////////

// 2024-12-02 reported missing bv_subjects and bv_event_instances data and missing reason_code_1 for DW and PP in bv_conmed view 
// 2025-04-10 v20250408 build of base views. found missing c_event_created_dates for all, downloaded again and it appeared. also moved the corcf step to the 1.7 code. 
cap log close
log using temp\1_7_allcomor.log, replace 
do "$prog/1_7_allcomor_2025-04-10.do" 

// 2024-12-04 event_instances data is available 
// 2025-04-10: LG added corcf to the code 
// 2025-04-02: LG dropped testing site 997 from data. 
// 2025-01-02: Ying made minor adjustments to adapt the difference between inf_type and inf_type_txt with Covid-19 etc. Name is not changed. Lin needs to add datacut to the name and remove visit dates beyond datacut 
cap log close 
log using temp\1_8_allinf.log, replace 
do "$prog/1_8_allinf_2025-04-10.do"

// 2024-09-03: LG changed from fv_ to bv_; 2024-12-03 missing bv_event_instances view, cannot run

// 2024-12-04 event_instances data is available 

// 2024-12-02 event_instances and subject views are not required.

// 2025-01-09 problem with 1.7million rows added compared to the prev datacut hold to the data cleaning 
log close 
log using temp\1_3_othmed.log, replace  
do "$prog/1_3_othmed_2025-04-10.do" 
// 2025-04-02 LG added site number 997 to drop  
// clean bv_conmed- all non RA drug (NSAIDs, OP, pain, CVD, GI, antidepress, and other medication) from SU & MD form

//2025-04-10 LG moved 1.9 after 1.3. and added corcf 
//2025-02-07 change the number from 11 to 9 to be consistent with the codebook
cap log close 
log using temp\1_9_sumedprob.log, replace 
do "$prog/1_9_sumedprob_2025-04-10.do"


// 2025-01-14 place holder for further clean 1.4 alllabs data, after R code 
cap log close 
log using temp\1_4_alllabs_clean.log, replace 
do "$prog/1_4_alllabs_clean_2025-04-10.do"

// 2025-01-14 place holder for further clean 1.5 exit data, after R code 
cap log close 
log using temp\1_5_exits.log, replace 
do "$prog/1_5_2_exit_clean_2025-04-02.do"


// 2025-04-03 LG use March subject data for exit_form_date values for the 2,888 inconsistencies between March and April download. EDW is still investigating. Decision made from spot checking.
// 2024-12-03 cannot run without bv_subjects data 
// 2024-12-04 subject view available, making site_type as a numeric var. 
// 2025-01-09 LG subject_demographic data has changed from birth_year to birthyear. Using subject data to update and replaced birthyear and site_number on row # 664
// clean and combine bv_subjects_demographic_data, fv_subjects, bv_exit(exit reason), and site info 
// 2024-10-02 LG updated state for site 262, no missing for region; noticed var name race_other_specify to race_other_txt
cap log close 
log using temp\1_1_subjects.log, replace 
do "$prog/1_1_subjects_2025-04-10.do"  
log close 

// 2025-01-09 still waiting for the download of bv_labs 
// 2024-12-04 re-run allvisits data to see why 2015-12-30 was added for 000000000 
log using temp\1_2_allvisits.log, append //replace
 
do "$prog/1_2_allvisits_2025-04-10.do" 
// clean bv_longitudinal and combine with some variables from bv_lab, fv_event_instance, calcv_haqs 
// 2024-10-02 LG: bp cleaning steps are not decided yet
/* 
// 2024-12-04 check if visitdates are out of range  
use clean_table\1_2_allvisits_$datacut, clear 
unique subject_number visitdate 
corcf * using "$pdata\\clean_table\1_2_allvisits_$pdatacut", id(subject_number visitdate)

merge 1:1 subject_number visitdate using "$pdata\\clean_table\1_2_allvisits_$pdatacut", keepus(subject_number visitdate)

    Result                           # of obs.
    -----------------------------------------
    not matched                         1,359
        from master                     1,327  (_merge==1)
        from using                         32  (_merge==2)

    matched                           509,946  (_merge==3)
    -----------------------------------------

codebook visitdate if _m==1 // all after 2024
codebook visitdate if _m==2 
tab subject_number if _m==2 // including Jr RA
log close
*/

cap log close
log using temp\1_6_drugrecord.log, append
do "$prog/1_6_drugrecord_2025-04-10.do" 
// 2024-12-05:dropped 3 rows of visitdate 12/30/2024 and 11 rows after 11/30/2024
// 2024-12-04 checking visitdate and drug_date data entry issue, one subject had 30dec2024
// LG 2024-11-04: making reason_i/_category/_code consistent

////////////////	2024-10-01 started to add YYYY-MM-DD to the analytic data names 

// 2025-04-04 LG fixed imputation of start/stop dates by using midpoint between two visitdates, not using midpoint between visitdates and drug dates to avoid overlapped drug episodes; further limited rituxan re-starts without switching. Affecting ROM monthly counts, rituxan restart dropped from 500+ to 389.

// 2024-11-04 found inconsistencies between reason_category vs. reason_category_code after unique date cleaning step 
cap log close 
log using temp\2_1_drugexpdetails.log,append //  replace 

do "$prog/2_1_drugexpdetails_2025-04-10.do"

cap log close

log using temp\2_3_keyvisitvars.log, replace // append  

do "$prog/2_3_keyvisitvars_2025-04-10.do"  // nsaid data had visitdate out of range 

use 2_3_keyvisitvars_$datacut, clear

rename exit_form_date Apr2025_exit_form_date
rename active_pt Apr2025_active_pt

merge 1:1 subject_number visitdate using "$pdata\\2_3_keyvisitvars_$pdatacut", keepus(visitdate exit_form_date active_pt)
/*
v2025-04-08 
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,518
        from master                     1,481  (_merge==1)
        from using                         37  (_merge==2)

    matched                           509,937  (_merge==3)
    -----------------------------------------

    Result                           # of obs.
    -----------------------------------------
    not matched                         1,359
        from master                     1,327  (_merge==1)
        from using                         32  (_merge==2)

    matched                           509,942  (_merge==3)
    -----------------------------------------
*/

rename exit_form_date Mar2025_exit_form_date 
rename active_pt Mar2025_active_pt 

unique subject_number if _m==3 & Apr2025_active_pt!=Mar2025_active_pt // 193 ==>207
tab site_number if _m==3 & Apr2025_active_pt!=Mar2025_active_pt

unique subject_number if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date // 431 subjects have different exit form date ==>1,641

unique subject_number if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date & Apr2025_active_pt!=Mar2025_active_pt
// 27 subjects have different exit form date and changed active pt from active to not active ==>39

groups Mar2025_active_pt Apr2025_active_pt if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date & Apr2025_active_pt!=Mar2025_active_pt
groups site_number subject_number if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date & Apr2025_active_pt!=Mar2025_active_pt, sepby(site_number) ab(16)
/*
2025-04-08 update 
  +---------------------------------------+
  | Mar202~t   Apr202~t   Freq.   Percent |
  |---------------------------------------|
  |       no        yes      25      5.45 |
  |      yes         no     434     94.55 |
  +---------------------------------------+

. groups site_number subject_number if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date & Apr2025_active_pt!=Mar2025_active_pt, sepby(site_number) ab(16)

  +------------------------------------------------+
  | site_number   subject_number   Freq.   Percent |
  |------------------------------------------------|
  |           1        001020022      33      7.19 |
  |------------------------------------------------|
  |           2        002023512       7      1.53 |
  |           2        709073736      29      6.32 |
  |------------------------------------------------|
  |           6        301658165      45      9.80 |
  |------------------------------------------------|
  |          19        019201044      13      2.83 |
  |------------------------------------------------|
  |          38        815486145      19      4.14 |
  |------------------------------------------------|
  |          64        064011248      22      4.79 |
  |------------------------------------------------|
  |          93        093010026      14      3.05 |
  |          93        093010788      12      2.61 |
  |          93        093011609       3      0.65 |
  |------------------------------------------------|
  |         100        100011540      18      3.92 |
  |         100        100011773      19      4.14 |
  |         100        100022222      20      4.36 |
  |         100        100044105      12      2.61 |
  |         100        100083955       8      1.74 |
  |         100        100106017       7      1.53 |
  |         100        100121093      14      3.05 |
  |         100        100145324       4      0.87 |
  |         100        100263564       8      1.74 |
  |         100        100264486       3      0.65 |
  |         100        100555501       4      0.87 |
  |------------------------------------------------|
  |         115        115010592      10      2.18 |
  |         115        115140802       7      1.53 |
  |         115        115180487      12      2.61 |
  |------------------------------------------------|
  |         149        149011078       3      0.65 |
  |------------------------------------------------|
  |         152        152010433      20      4.36 |
  |         152        152020432      19      4.14 |
  |         152        152020863      12      2.61 |
  |         152        152030560      14      3.05 |
  |         152        152030983       9      1.96 |
  |         152        152040876      11      2.40 |
  |------------------------------------------------|
  |         205        205050596       4      0.87 |
  |------------------------------------------------|
  |         220      RA-220-0002       2      0.44 |
  |         220      RA-220-0040       2      0.44 |
  |------------------------------------------------|
  |         227        227010049       2      0.44 |
  |------------------------------------------------|
  |         237        237010026       6      1.31 |
  |         237        237010068       3      0.65 |
  |------------------------------------------------|
  |         256        256010001       6      1.31 |
  |         256        256010002       3      0.65 |
  +------------------------------------------------+

*/
mdesc *_exit_form_date if _m==3 & Apr2025_exit_form_date!=Mar2025_exit_form_date & Apr2025_active_pt!=Mar2025_active_pt 
/*
    Variable    |     Missing          Total     Percent Missing
----------------+-----------------------------------------------
   Apr2025_ex~e |           9            459           1.96
   Mar2025_ex~e |         434            459          94.55
----------------+-----------------------------------------------
*/ 



cap log close 
log using temp\2_2_initiations.log, replace  
do "$prog/2_2_initiations_2025-03-06.do" 

cap log close 

log using temp\2_4_drugexposures.log, replace
do "$prog/2_4_drugexposure_2025-04-04.do" 

cap log close
 


// after all analytic data is ready, use R to create R data into DQ checks folder and create data dictionary.

// monthly executive slides 
global rptdt 2025-04

cd "~\Corrona LLC\Biostat Data Files - RA\registry_counts\Monthly_Registry_slides"
global data "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\\$datacut"

log using monthly_executive_$datacut.log, replace

use "$data\\2_3_keyvisitvars_$datacut", clear

do "~\Corrona LLC\Biostat Data Files - RA\registry_counts\Monthly_Registry_slides\Monthly_executive_slides_2024-11-04.do"


