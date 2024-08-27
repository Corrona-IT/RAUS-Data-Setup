/*

Date: 2023-11-15 
Programmer: Ying Shan 
Aim: setup master 

do file: master setup do  
data use baseview monthly download bv_*, fv_* data and site info from saleforce 

*/ 

*odbc query dwh, schema verbose 

global prog "~/Corrona LLC/Biostat Data Files - RA\Setup\setup_code\ODBC" 

global pdata "~/Corrona LLC/Biostat Data Files - RA\monthly\2024\2024-07-01" // for run test.do

cd "~/Corrona LLC/Biostat Data Files - RA/monthly\2024\2024-08-01\"  

mkdir bv_raw\ 
mkdir temp\
mkdir clean_table\ 
mkdir temp\data\ 
mkdir temp\rawdata\


do "bv_raw/export_odbc_2024-08-01.do"

do "$prog/1_2_siteinfo_2024-08-01.do" 


log using temp\1_7_allcomor.log, replace 
do "$prog/1_7_allcomor_20240503.do"
log close 

log using temp\1_8_allinf.log, replace 
do "$prog/1_8_allinf_20240523.do"
log close 

log using temp\1_3_othmed.log, replace  
do "$prog/1_3_othmed_2024-01-03.do"  // clean bv_conmed- all non RA drug (NSAIDs, OP, pain, CVD, GI, antidepress, and other medication) from SU & MD form
log close 

cap log close 
log using temp\1_1_subjects.log, replace 
do "$prog/1_1_subjects_2023-11-07.do"  // crean and combine bv_subjects_demographic_data, fv_subjects, bv_exit(exit reason), and site info 
log close 


log using temp\1_2_allvisits.log, replace 
do "$prog/1_2_allvisits_2024-03-12.do" // clean bv_longitudinal and combine with some variables from bv_lab, fv_event_instance, calcv_haqs 
log close 

* Lin's code use cd to temp folder
do "$prog/1_6_drugrecord_2024-07-10.do"
do "$prog/2_1_drugexpdetails_2024-07-10.do"

cd "~/Corrona LLC/Biostat Data Files - RA/monthly\2024\2024-08-01\" 
log using temp\2_3_keyvisitvars.log, replace 
do "$prog/2_3_keyvisitvars_2024-06-14.do" 
log close 


do "$prog/2_2_initiations_2024-07-10.do" 
do "$prog/2_4_drugexposure_2024-07-10.do" 

cd "~/Corrona LLC/Biostat Data Files - RA/monthly\2024\2024-08-01\" 
log using temp\1_11_sumedprob_20240624.log, replace 
do "$prog/1_11_sumedprob_20240624.do"
log close 
********************************************************
local pdata "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-05-30" 
do "$prog/test_data.do" 
log close 

/***********Lin's codes 
log using 1_6_drugrecord.log, replace 
do "$prog/1_6_DrugRecord_2024-01-08.do" // clean bv_drug_of_interest- all of RAdrug (biologic, biosimilar, csDMARD, prednisone) from MD and TAEs form 
log close 







