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

Ying 2024-07-25: 
Monthly updated site data & path: Biostat Data Files > Site and Provider Data > data > site_data_clean.csv

***********************************************/
/*
2024-03-06 Ying 
Could you also run your code to updated site status data using salesforce data for future each download as you did for “RAsitestatus_2024-01-01” and put in monthly folder? We need to use updated site status for setup. Fv_sites have issue never updated.
*/

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

tab registry // 244 RA ==>247 RA 

keep if registry=="RA"
destring site_id, force replace 
unique site_id // 247

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
br city
keep site_id account_name status practice_type state city shipping_state_province academic_affiliation academic site_type
duplicates report *

*duplicates drop *, force 
unique shipping_state_province // 43 states 

save RAsitestatus, replace 

export excel  * using "temp\RAsitestatus.xlsx" , firstrow(var) replace 

count if site_id==95 // added

corcf * using "$pdata\RAsitestatus", id(site_id) verbose noobs v(50)

cap log close 

/*
tab status,m
use "$output\\$sitedata", clear 
duplicates list site_id status shipping_state_province site_type
duplicates drop site_id status shipping_state_province site_type, force

tab site_type, m 


rename academic_affiliation academic_affiliation_geo
gen academic_affiliation=.
replace academic_affiliation=1 if site_type=="Academic Site"
replace academic_affiliation=0 if site_type=="Private Site"

lab define ny 0 No 1 Yes, modify
lab val academic_affiliation ny
tab academic_affiliation,m

des, f 
codebook site_id
unique site_id

//destring site_id, force replace  7-1-21 site_id was string 

drop if site_id==.
count

* rename site_number_numeric site_id
sort site_id
by site_id: gen vN=_N
tab vN

*list site_name site_id if vN==2, noobs ab(20) 
*browse if vN==2 | site_id==083 
rename state state_ori
rename shipping_state_province state 
tab state,m
*br if state=="-" // 10 as of 11-1-21
*br if state=="" // 15 as of 4-1-2022
*br if state=="NA" // 3-2-2022 the missing state shows "NA"
/*
 6-1-21 updated site_id	account_name	status
239	Roger Kornu, MD, PC	Approved / Active
240	C.V. Mehta, MD Medical Corp, Inc.	Approved / Active
*/
replace state="" if state=="-"|state=="NA"
//replace state="OK" if state=="Oklahoma" 
//replace state="MI" if state=="Michigan" 
//replace state="FL" if state=="Florida"/* updated 9-1-19	*/
tab state,m
unique state if state!="" // 43 states with OR added from state variable
*list site_id account_name practice_type state if site_id==255, noobs 
* Regional divisions used by the  United State Census Bureau 
cap drop region
gen region=. 

* Northeast 9
foreach x in MA RI NH CT VT ME NY NJ PA {
replace region=1 if strpos(state, "`x'") 
}

* Midwest 12
foreach x in IN IL OH MI WI MN IA MO ND SD NE KS {
replace region=2 if strpos(state, "`x'") 
}
* South  17
foreach x in MD DE DC VA WV NC SC GA FL LA AR OK TX MS AL TN KY {
replace region=3 if strpos(state, "`x'")  
}
* West 13
foreach x in AZ CO ID NM MT UT NV WY AK CA HI OR WA{
replace region=4 if strpos(state, "`x'") 
}

lab define regionf 1 Northeast 2 Midwest 3 South 4 West, modify
lab val region regionf

tab region, m 

gen sitestatus="Not Active"
replace sitestatus="Active" if strpos(lower(status), "active")>0 // 5-4-2021 change to lower status containing "active" so onhold/active will be active 

tab status sitestatus, m
list site_id if status=="On hold (active)", noobs // 118 226
sort site_id
by site_id: assert _n==1
by site_id: gen vn=_N

tab vn

tab status, m

keep site_id state region sitestatus academic_affiliation
sort site_id

save siteinfo, replace 
*/
