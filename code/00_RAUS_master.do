/*
Date: 2023-11-15 
Programmer: Ying Shan 
Aim: setup master for RA-US

do file: master setup do  
data use baseview monthly download bv_*, fv_* data and site info from saleforce 
*/ 


****************************************************************************************************************************
*! version 1.0  01dec2023
*! Control program for RAUS

capture log close 
clear

// version notes

// Part 0: Set macro values
    // 0a: Values from user
global  currdt=d(31oct2023) 

global bv "~/Corrona LLC/Biostat Data Files - Registry Data/RA/monthly/ODBC/dwh_db/2023-11-10" 
global site "~/Corrona LLC/Biostat Data Files - Registry Data/RA/monthly/2023/2023-10-31"  
global data "~/Corrona LLC/Biostat Data Files - Registry Data/RA/Data Warehouse Project 2020 - 2021/Analytic File/data/clean_table"
global prog "~/Corrona LLC/Biostat Data Files - Registry Data/RA/Setup/setup_code/ODBC"

cd "~/Corrona LLC/Biostat Data Files - Registry Data/RA/monthly/Transition/analysis/allvisits" 

        // CDB connection
if "`cdbinfo'"=="" | "`cdbinfo'"=="default" {
	* v2.6.4: changed default to new reporting connection
    local cdbinfo connect_report.dof
}

// Part 1: Error checking
run checks.do "`pso'" "`cdbinfo'" `dates'

// Part 2: Run site creation file if needed

// Part 3: Clean main data
log using setup.log, replace 
	// subject
do "$prog/clean_subjects_2023-11-07.do"  // clean and combine bv_subjects_demographic_data, fv_subjects, bv_exit(exit reason), and site info 
	// allvisits
do "$prog/clean_allvisits_2023-11-07.do" // clean bv_longitudinal and combine with some variables from bv_lab, fv_event_instance, calcv_haqs 







*<end>
