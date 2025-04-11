/*****************************************
Date: 1-21-2015
Name: Ying
Aim: create geographic & site active indicator 

data use: excelsheet from Corrona Alfresco: Site Contact Info - Master List 

data out: siteinfo_01-21-15 

Note: from 6-1-18, we recieve site status by email and site number included in site name, so revise program.
9-1-19 site_id was from raw data, do not need to rename from site_number_numeric
4-1-2020 changed site data path. both monthly folder and site-info folder keep site data for convenience
5-1-2020 add academic affiliation to siteinfo data for merging with dwsub1
/*
2024-03-06 Ying 
Could you also run your code to updated site status data using salesforce data for future each download as you did for “RAsitestatus_2024-01-01” and put in monthly folder? We need to use updated site status for setup. Fv_sites have issue never updated.
*/

Ying 2024-07-25: 
Monthly updated site data & path: Biostat Data Files > Site and Provider Data > data > site_data_clean.csv

LG 2024-10-01: 
1. updated shipping_state_province to "FL" for site 262 from googled address 
2. site 261 is added compared to the previous month.
***********************************************/

/*
clear 
cap log close 
local year = "2024"							/*	update each year */
local dt = "2024-07-01"						/*	update each month */ 

cd "~\Corrona LLC\Biostat Data Files - RA\monthly/`year'/`dt'"	 


import delimited using "site_data_clean",bindquote(strict) asdouble 
*/


log using temp\site_data.log,  replace    
import delimited using "~\Corrona LLC\Biostat Data Files - Site and Provider Data\data\site_data_clean", bindquote(strict) asdouble clear 

tab registry // 244 RA ==>247 RA ==>248==>249==>250==>251==>254

keep if registry=="RA"
destring site_id, force replace 
unique site_id // 250

groups academic academic_affiliation site_type, missing ab(30) 
 
mdesc shipping_state_province state
groups shipping_state_province state, missing ab(16)
list site_id account_name shipping_state_province state if shipping_state_province=="NA", noobs ab(32) // make Fl and FL consistent 
// 2023-07-05 only replace Fl to FL 
replace shipping_state_province=state if shipping_state_province=="NA"
replace shipping_state_province="FL" if site_id==253 & shipping_state_province=="Fl"
// googled the location for site 243, should be in TN instead of MI 
replace shipping_state_province="TN" if site_id==243 & shipping_state_province=="MI"
// 2024-04-01 adding city to site data, requested for RF500+counts 
mdesc city
*br city
keep site_id account_name status practice_type state city shipping_state_province academic_affiliation academic site_type
duplicates report *

*duplicates drop *, force 

// 2024-10-01: site 262 is FL 
list if state=="NA", noobs ab(16)
replace shipping_state_province="FL" if site_id==262 & shipping_state_province=="NA"
unique shipping_state_province // 43 states

save clean_table\RAsitestatus_$datacut, replace 

export excel  * using "clean_table\RAsitestatus.xlsx" , firstrow(var) replace 

count if site_id==95 // added

corcf * using "$pdata\\clean_table\RAsitestatus_$pdatacut", id(site_id) verbose noobs v(50)
/*
account_name: 1 mismatches

  +-------------------------------------------------------------------------------+
  | site_id   master_data                        using_data                       |
  |-------------------------------------------------------------------------------|
  |     227   Eastside Rheumatology & Intern..   Eastside Rheumatology & Intern.. |
  +-------------------------------------------------------------------------------+



status: 1 mismatches

  +-------------------------------------------------+
  | site_id          master_data         using_data |
  |-------------------------------------------------|
  |     253   Closed / Completed   Pending closeout |
  +-------------------------------------------------+

*/

merge 1:1 site_id using "$pdata\\clean_table\RAsitestatus_$pdatacut"
list site_id account_name status city if _m==1, noobs ab(12) 

/*
  +-------------------------------------------------------------------------------------------+
  | site_id                                       account_name              status       city |
  |-------------------------------------------------------------------------------------------|
  |     266                Arnold Arthritis & Rheumatology, SC   Approved / Active         NA |==> in Skokie, IL according to google. check later data and add if needed.
  |     268   Overlake Arthritis and Osteoporosis Center, PLLC   Approved / Active   Bellevue |
  |     269                         Texoma Arthritis Clinic PA   Approved / Active   McKinney |
  +-------------------------------------------------------------------------------------------+
*/

cap log close 

