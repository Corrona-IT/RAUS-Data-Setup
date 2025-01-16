/***************************************************************************************************************************

code Name: clean_allvisits.do 
Purpose: clean variables on all visits from data source 
Programmer: Ying Shan
Input datasets: fv_subjects, sites, bv_subject_demographic_data, bv_exits 
Final Dataset: 1_1_subjects.dta  
Version1 	Date: 2023-10-17
Description: 
Main variables from each imput data: 
bv_longitudinal_visit_data: disease activity, PROs, smoking, drinking, vaccine, work status... 
bv_labtest: lab_name=rf, ccp, crp, esr with value and unit, upper_limit_value 
bv_imigings: imiging_name= erosions, deformity, joint space narrowing 
fv_event_instance: for all office visits from all events 

Ying: revised 2024-12-09 
use clean_table 1_4_alllabs instead bv_labs to consistent with final clean lab data and 
excluded vectra_da which created for UnlearnAI, now it is in 1_4_alllabs 

******************************************************************************************************************************/
/* this section will remove after finalized and run from master.do file 

global bv "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\ODBC\dwh_db\2024-01-31" 
global site "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\2023\2023-12-31"  
global data "~\Corrona LLC\Biostat Data Files - Registry Data\RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table"
global prog "~\Corrona LLC\Biostat Data Files - Registry Data\RA\Setup\setup_code\ODBC" 

global tt "C:\Users\yshan\Corrona LLC\Biostat Data Files - Registry Data\RA\Data Warehouse Project 2020 - 2021\EDW M2 July 2021 - Dec. 2021\Testing\Testing 2023\"  

cd "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\Transition\analysis\allvisits" 

*******************************************************************************************************************************/

// this data includes all office visits and any event forms 
use bv_raw\bv_event_instances, clear  

tab dw_event_type_acronym if visit_date!="" 
tab dw_event_type_acronym if visit_date=="" 

gen visitdate=date(visit_date, "YMD") // visit_date is true subject en/fu visit date 
format visitdate %tdCCYY-NN-DD  
drop if visitdate==.
destring site_number full_version, replace 
*drop if site_number>=997 

drop  if strpos(dw_event_type_acronym, "TAE") | dw_event_type_acronym=="PREG" | dw_event_type_acronym=="EXIT" | visitdate==. 

keep site_number subject_number study_acronym source_acronym c_provider_id c_effective_event_date full_version dw_event_instance_uid dw_event_type_acronym visitdate visit_date 

unique dw_event_instance_uid 

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 

*list subject_number study_source_acronym c_effective_event_date dw_event_type_acronym if  subject_number=="093010805" | subject_number=="147010028", noobs ab(30) 

*drop if subject_number=="093010805" | subject_number=="147010028" // ticket 502 these two subjects only have exit form in EDC, no visits 

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 
save temp\temp_event_instance, replace 

****************

*br subject_number c_effective_event_date dw_event_type_acronym full_version visitdate if subject_number=="093010015" | subject_number=="093010016" | subject_number=="205030900"

* RA drug visits


use  subject_number c_effective_event_date c_event_created_date c_event_last_modified_date c_provider_id dw_event_type_acronym study_acronym source_acronym site_number full_version dw_event_instance_uid drug_name* using "bv_raw\bv_drugs_of_interest", clear  

keep if dw_event_type_acronym=="EN" | dw_event_type_acronym=="FU" | dw_event_type_acronym=="RFU" 

drop if drug_name=="" & drug_name_txt=="" 
drop drug_name* 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD  
replace visitdate=dofc(c_event_created_date) if visitdate==. 

destring site_number full_version, replace 
drop if site_number>=997 

sort subject_number visitdate dw_event_type_acronym 
bysort subject_number visitdate: drop if _n>1 
save temp\temp_radrug, replace 

*list  dw_event_instance_uid subject_number c_effective_event_date dw_event_type_acronym study_acronym source_acronym  full_version if full_version=="", noobs ab(20)  

********************************
// 2025-01-14 add $datacut for all data in clean_table folder 
use subject_number visitdate dw_event_type_acronym study_acronym source_acronym site_number c_provider_id full_version dw_event_instance_uid  using "clean_table\1_3_conmeds_$datacut", clear  

drop if site_number>=997 
sort subject_number visitdate dw_event_type_acronym 
bysort subject_number visitdate: drop if _n>1 
save temp\temp_conmedvt, replace 

*list  dw_event_instance_uid subject_number c_effective_event_date dw_event_type_acronym study_acronym source_acronym  full_version if full_version=="", noobs ab(20) 

*********************************

use subject_number visitdate c_effective_event_date c_event_created_date dw_event_type_acronym study_acronym source_acronym site_number c_provider_id full_version dw_event_instance_uid using "clean_table\1_7_allcomor_$datacut", clear  

keep if dw_event_type_acronym=="EN" | dw_event_type_acronym=="FU" | dw_event_type_acronym=="RFU" 
bysort dw_event_instance_uid: drop if _n>1 

destring site_number full_version, replace 
drop if site_number>=997 

bysort subject_number visitdate: drop if _n>1 
sort subject_number visitdate  
save temp\temp_comorvt, replace 


********************************
use subject_number visitdate  dw_event_type_acronym study_acronym source_acronym site_number c_provider_id full_version infkey dw_event_instance_uid using "clean_table\1_8_allinf_$datacut", clear  

keep if dw_event_type_acronym=="EN" | dw_event_type_acronym=="FU" | dw_event_type_acronym=="RFU"   

drop if infkey=="" 
drop infkey  
bysort dw_event_instance_uid: drop if _n>1 

destring site_number full_version, replace 
drop if site_number>=997 

bysort subject_number visitdate: drop if _n>1 
sort subject_number visitdate  

save temp\temp_infvt, replace 

*destring site_number, replace 

*list dw_event_instance_uid subject_number site_number visitdate full_version study_source dw_event_type_acronym if full_version=="" & site_number<997, noobs ab(20) 

**************************************

*2024-12-09 revise to use clean_table 1_4_alllabs 

// for RF, CCP, CRP, ESR used for calculated variables in analysis data on viist level 
*20240601 add Vectra VA score 
use "clean_table\1_4_alllabs_$datacut", clear 

assert visitdate<.
assert full_version<.  

keep if lab_img_type==1 

preserve 
keep subject_number visitdate dw_event_type_acronym site_number c_provider_id full_version lab_img_dt 
sort subject_number visitdate lab_img_dt 
bysort subject_number visitdate: drop if _n<_N 
save temp_labvisit, replace 
restore 

gen lab_name=""
foreach x in rf ccp crp esr  {
    replace lab_name="`x'" if lab_img_name=="`x'"  
}  

keep if lab_name!="" 

tab lab_name if result_value==. & lab_img_result_intpn==9771  

drop if result_value==. & lab_img_result_intpn==9771  // 860 dropped no lab value 

gen pos= result_value>=20  if result_value<. 
replace pos=1 if lab_img_result_intpn==1000 
replace pos=0 if lab_img_result_intpn==2000 & pos==. 
replace pos=. if lab_name=="crp" | lab_name=="esr" 

/* run this part in 1_4_alllabs.do 
tab lab_name if lab_uln_value<. 
tab lab_name if lab_uln_value==. & lab_uln_value_raw!=""
tab lab_uln_value_raw if lab_uln_value==., sort

* update ulper limited value: lab_uln_value, current as missing if raw data has any charactors 
cap drop lab_uln 
clonevar lab_uln=lab_uln_value_raw if lab_uln_value==. 
replace lab_uln=subinstr(lab_uln, "<=", "", .) 
replace lab_uln=subinstr(lab_uln, "1-0.5", "1", .) if lab_result_unit_code==150 // mg/dL 
replace lab_uln=subinstr(lab_uln, "0.1.0", "1", .) if lab_result_unit_code==150 // mg/dL  

replace lab_uln=subinstr(lab_uln, "-0.", ".", .) 
replace lab_uln=subinstr(lab_uln, "0.0-", "", .) 
replace lab_uln=subinstr(lab_uln, "00-", "", .)  
replace lab_uln=subinstr(lab_uln, "0-", "", .)  
replace lab_uln=subinstr(lab_uln, ">", "", .) 
replace lab_uln=subinstr(lab_uln, "<", "", .) 
replace lab_uln=subinstr(lab_uln, "=", "", .) 
replace lab_uln=subinstr(lab_uln, "..", ".", .) 
replace lab_uln=subinstr(lab_uln, "*", "", .) 
replace lab_uln=subinstr(lab_uln, "`", "", .) 
replace lab_uln=subinstr(lab_uln, "mg/L", "", .) 
replace lab_uln=subinstr(lab_uln, "mg/l", "", .) 
replace lab_uln=subinstr(lab_uln, "mg/dL", "", .) 
replace lab_uln=subinstr(lab_uln, "o", "0", .) 
replace lab_uln=subinstr(lab_uln, ",", ".", .) 
replace lab_uln=subinstr(lab_uln, ".0.", ".", .) 
replace lab_uln=subinstr(lab_uln, "/", ".", .) 

replace lab_uln=subinstr(lab_uln, "-", "", .) 
replace lab_uln="0.8" if lab_uln=="0.80." 

destring lab_uln, gen(uln) force 

export excel subject_number visitdate lab_name lab_uln_value_raw uln lab_uln_value if uln<. using "temp\alllabs_update_uln", sheet(updated, modify) firstrow(var) 
export excel subject_number visitdate lab_name lab_uln_value_raw uln lab_uln_value if uln==. & lab_uln="" using "temp\alllabs_update_uln", sheet(unupdated, modify) firstrow(var) 

replace lab_uln_value=uln if lab_uln_value==. 
*/

keep subject_number visitdate lab_name result_value lab_img_dt lab_result_unit_code lab_uln_value pos 
duplicates drop 


sort subject_number visitdate lab_name lab_img_dt result_value 
by subject_number visitdate lab_name: drop if _n<_N & lab_img_dt<=lab_img_dt[_N]  & result_value[_N] <. // keep later lab value if duplicates : 12 dropped
drop lab_img_dt 

unique subject_number visitdate lab_name 

reshape wide result_value lab_result_unit_code lab_uln_value pos, i(subject_number visitdate) j(lab_name) string 

drop posesr poscrp lab_result_unit_codeccp lab_uln_valueccp lab_result_unit_codeesr lab_uln_valueesr lab_result_unit_coderf lab_uln_valuerf

for any rf ccp:    rename posX Xpos  
for any rf ccp crp esr: rename result_valueX X 
rename lab_result_unit_codecrp crp_unit  
rename lab_uln_valuecrp ul_crp 
 
gen crptype=1 if crp_unit==160 | crp_unit==130	 // mg/L, mcg/L
replace crptype=2 if crp_unit==150  			 // "mg/dL" 

replace crptype=1 if ul_crp>=4 & ul_crp<=10 & crptype==. & crp<. 
replace crptype=2 if ul_crp>=.4 & ul_crp<=1 & crptype==. & crp<. 

sort subject_number visitdate 
by subject_number: replace crptype=crptype[_n-1] if crp<. & crptype==. 

gen double crp_mgl=crp if crptype==1 
replace crp_mgl=crp*10 if crptype==2 
replace crp_mgl=. if crp_mgl<0|crp_mgl>1000 

lab define pos 0 negative 1 positive, modify 
for any rf ccp: lab val Xpos pos 

lab var crp_mgl "CRP(mg/L)" 
lab var rf "RF value" 
lab var ccp "CCP value" 
lab var crp "CRP value" 
lab var rfpos "RF positive" 
lab var ccppos "CCP positive" 

unique subject_number visitdate 

keep subject_number visitdate ccp crp esr rf rfpos ccppos crp_mgl 
sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp_labvisit 
drop _m 

sort subject_number visitdate 

save temp\temp_rfccp, replace 
erase temp_labvisit.dta 

 
********************************************************
// for erosion, deformity, joint space narrowing in analysis data on visit level  
use "clean_table\1_4_alllabs_$datacut", clear  

keep if lab_img_type==2 

/*
tab img_finding if lab_img_result_raw!="" & lab_img_result_intpn==. & lab_img_result==., m  
tab img_finding lab_img_result_intpn if lab_img_result_raw!="" , m 
tab img_finding lab_img_result_intpn, m  
tab lab_img_name if img_finding==., m 
*/

preserve 
keep subject_number visitdate dw_event_type_acronym site_number c_provider_id full_version 
bysort subject_number visitdate: drop if _n>1
save temp_imagingvisit2, replace 
restore 

keep if img_finding==2 | img_finding==4| img_finding== 5 

drop if lab_img_result_intpn==.  //46 dropped 
keep subject_number visitdate img_finding lab_img_result_intpn lab_img_dt 

*keep if imaging_finding=="deformity" | imaging_finding=="erosions" | imaging_finding=="joint space narrowing" 
*replace imaging_finding="jt_sp_narrow" if imaging_finding=="joint space narrowing" 

keep subject_number visitdate img_finding lab_img_result_intpn lab_img_dt 
duplicates drop 

gen result=0     if lab_img_result_intpn==4  
replace result=1 if lab_img_result_intpn==7  
replace result=2 if lab_img_result_intpn==5 
replace result=3 if lab_img_result_intpn==2 
replace result=4 if lab_img_result_intpn==6 

lab define result 0 none 1 present  2 old 3 new 4 "old and new", modify 
lab val result result 

tab result lab_img_result_intpn, m 

decode img_finding, gen(image) 
replace image="jt_sp_narrow" if image=="joint space narrowing" 

unique subject_number visitdate image lab_img_dt

sort subject_number visitdate image lab_img_dt result
by subject_number visitdate image lab_img_dt: gen drp=1 if _n<_N 
by subject_number visitdate image: replace drp=1 if _n<_N 

tab drp 
drop if drp==1
drop drp lab_img_dt lab_img_result_intpn img_finding 

reshape wide result, i(subject_number visitdate) j(image) string 

foreach x in deformity erosions jt_sp_narrow {
	rename result`x' `x' 
}

lab var deformity "Joint deformity"
lab var erosions "Erosions"
lab var jt_sp_narrow "Joint space narrowing" 

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp_imagingvisit2 
drop _m 
sort subject_number visitdate
// Ying to compare the difference for revision from Oct 24 to Dec 24
*corcf deformity erosions jt_sp_narrow using temp\temp_image, id(subject_number visitdate) 

save temp\temp_image2, replace 

erase temp_imagingvisit2.dta  
*********************************************************
/*
use temp\temp_image2, clear 

foreach x in deformity erosions jt_sp_narrow{
    clonevar `x'2=`x' 
	replace `x'=1 if `x'2==2 
	replace `x'=2 if `x'2==2 
}

for any deformity erosions jt_sp_narrow: rename X X2 
merge 1:1 subject_number visitdate using temp\temp_image 

for any deformity erosions jt_sp_narrow: tab X X2, nolabe 
*/


***************


*****************************************************************************
*****************************************************************************

use "bv_raw\bv_longitudinal_visit_data", clear 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD 

replace visitdate=dofc(c_event_created_date) if visitdate==. 

list subject_number site_number visitdate dw_event_type_acronym study_acronym source_acronym full_version c_event_* if c_effective_event_date=="" , noobs 

destring full_version site_number, replace 

drop if visitdate==. 
ds *_code, has(type string) v(32) 

// 2025-01-14 LG: variable changed to x_outpt_visit_rheum_code
*destring outpt_visit_rheum_calc_code, replace 
*destring x_outpt_visit_rheum_code, replace // already numeric, no replace 

* data issue clean 
replace infections_since_yes_no=lower(infections_since_yes_no)
replace infections_since_yes_no_code=1 if infections_since_yes_no=="yes" 
replace infections_since_yes_no_code=0 if infections_since_yes_no=="no" 
replace labs_imaging_coll_code=1 if labs_imaging_coll=="checked" 

*replace mri_ultra_erosion_notseen_code=1 if mri_ultra_erosion_notseen=="checked" 


*** variables with  
lab define ny 0 no 1 yes, modify 

// 2025-01-14 taking out outpt_visit_rheum_calc from list. Not in data 
#delimit; 
local list 
pregnant_since
pregnant_now
pregnant_ever
breastfeed_now
menopause_post 

insurance_yes_no
insurance_medicare  
insurance_medicaid  
insurance_va_military 
insurance_private 
smoke_oth
smoke_oth_cigars
smoke_oth_pipes
smoke_oth_chewing
smoke_oth_e_cigar 
smoke_oth_tobacco 

disabled_ra 
am_stiffness 
hosp
hospitalizations_ra
hosp_inf
hosp_cve
hosp_oth_cond
hosp_arthro
wpai_employed
ae_comor_tox_fract
ae_comor_tox_fract_since
hx_bio_en
no_bio_sm
no_bio_sm_since 
fractures_yes_no
fractures_since_yes_no
infections_yes_no
infections_since_yes_no
med_condition_since_yes_no
med_condition_since2_yes_no
med_condition_ever_yes_no
med_condition_ever2_yes_no
su_meds_yes_no
md_meds_yes_no
osteo_meds_yes_no
osteo_meds_since_yes_no
surgeries_yes_no
surgeries_since_yes_no

doi_since_yes_no 
tb_ever
tb_since 
tb_skin_performed 
tb_blood_performed 
tb_test_performed_6mo 
tb_blood_positive
tb_latent_treatment
tb_skin_positive_treatment
tb_blood_skin_positive_tx
x_surgeries_atlantoaxial
x_surgeries_carpal
x_surgeries_cspine
x_surgeries_elbow
x_surgeries_foot_ankle
x_surgeries_hand_wrist
x_surgeries_hip
x_surgeries_knee
x_surgeries_mcp
x_surgeries_mtp
x_surgeries_oth
x_surgeries_shoulder
x_outpatient_visits_since
x_outpt_visit_rheum

outpt_visit_pcp
outpt_visit_er 
outpt_visit_oth 


drink_none drinks_status
smoke_ever_100 smoke_current smoke_regular smoke_start smoke_quit 
emergency newbio_today infections_for_yes_no 
labs_imaging_coll lab_rad_dxa_submit 
chest_xray_yn joint_xray_yn study_other_enrolled 
curr_no_dmards 
cbc_yn
dxa_yn
hep_b_panel_yn
hep_c_panel_yn 
inflammatory_yn
joint_mri_yn
joint_ultrasound_yn
kidney_function_yn
lipid_panel_yn
liver_function_yn
ra_diag_results_yn 
vitamin_d_yn 

conmed_yes_no 
 ; 
#delimit cr 

foreach x of local list { 
tab `x' `x'_code, m 
drop `x' 
rename `x'_code `x' 
lab val `x' ny 
}  


/*
foreach x in doi_not_started_1 doi_not_started_2  doi_reason_1 doi_reason_2 {
	tab `x' `x'_code 
}

* ticket 545 missing value for _code
foreach x in hep_b_panel_yn hep_c_panel_yn joint_ultrasound_yn ra_diag_results_yn kidney_function_yn vitamin_d_yn cbc_yn inflammatory_yn lipid_panel_yn dxa_yn joint_mri_yn liver_function_yn {
replace `x'_code=0 if `x'!="" 
drop `x' 
rename `x'_code `x' 
lab val `x' ny   
}
*/

lab define route 1 "Oral(PO)"  2 "subcutaneous(SC)"  3 "intravenous(IV)" 4 "intramuscular(IM)" , modify 
foreach x in doi_route_1 doi_route_2 { 
    replace `x'_code=1 if `x'_code==100 
	replace `x'_code=2 if `x'_code==201 
	replace `x'_code=3 if `x'_code==211 | `x'_code==212 
	replace `x'_code=4 if `x'_code==220
   drop `x' 
   rename `x'_code `x'
   lab val `x' route 
} 


* category variables 
lab define ny20 0 no 1 yes  2 new, modify 

foreach x in joint_deformity subcutan_nods sec_sjog{
   tab `x' `x'_code, m  
   drop `x'
   rename `x'_code `x'
   replace `x'=2 if `x'==20 
   lab val `x' ny20 
}

* yes/no/unknown 

lab define ny970 0 no 1 yes 2 unknown, modify  

foreach x in rf_pos_ever ccp_pos_ever {
	 tab `x' `x'_code, m 
    drop `x' 
	rename `x'_code `x' 
	replace `x'=2 if `x'==970 
	lab val `x' ny970 
}

lab define ny971 0 no 1 yes 2 "I am not sure", modify  

foreach x in vaccine_flu vaccine_flu_since vaccine_zoster vaccine_zoster_since vaccine_pneumo vaccine_pneumo_since vaccine_pna_zos_ever vaccine_pna_zos_flu_since vaccine_covid_ever vaccine_covid_since menopause_now  { 
    tab `x' `x'_code, m 
    drop `x' 
	rename `x'_code `x' 
	replace `x'=2 if `x'==971 
	lab val `x' ny971 
} 

lab define ny972 0 no 1 yes 2 "reason not specified", modify 

foreach x in tb_skin_no_test tb_blood_skin_no_test	{
    tab `x' `x'_code, m 
	replace `x'_code=2 if `x'_code==972 
    drop `x'
	rename `x'_code `x'
	lab val `x' ny972 
} 

lab define ny400 0 no 1 yes 2 "I prefer not to answer", modify 
foreach x in marijuana_recent marijuana_pres {
    tab `x' `x'_code, m 
	replace `x'_code=2 if `x'_code==400 
    drop `x'
	rename `x'_code `x' 
	lab val `x' ny400 
} 	

lab define work 1 "full time"  2 "part time"  3 "not working outside home with pay"   4 "student"  5 "disabled" 6 "retired" 7 "stay-at-home parent/spouse"  8 "unemployed", modify 
lab val work_status_code work 
drop work_status 
rename work_status_code work_status

lab define eqm 1 "no problems" 2 "some problems" 3 "unable to do", modify 

for any walking selfcare activities: lab val health_status_X_code eqm  

lab define eqp 	1 "none" 2 "Moderate" 3 "extreme" , modify 
for any pain anx_dep: lab val health_status_X_code eqp 	

foreach x in walking selfcare activities pain anx_dep { 
    drop health_status_`x' 
	rename health_status_`x'_code  health_status_`x' 
} 

lab define instype 1 "fee for service" 2 "HMO/medicare advantage", modify 
replace insurance_medicare_type_code=1 if insurance_medicare_type_code==1120 
replace insurance_medicare_type_code=2 if strpos(insurance_medicare_type, "HMO") 
drop insurance_medicare_type 
rename insurance_medicare_type_code  insurance_medicare_type  
lab val insurance_medicare_type instype 


lab define tbpos 0 negative 1 positive 2 indeterminate, modify 
foreach x in tb_blood_result tb_skin_result {
	tab `x' `x'_code, m 
	encode `x', gen(`x'_1) label(tbpos)
	drop `x' `x'_code 
	rename `x'_1 `x' 
} 


lab define tbtype 1 blood 2 skin, modify 
encode tb_test_type, gen(tb_type) label(tbtype) 
drop tb_test_type tb_test_type_code 
rename tb_type tb_test_type   


*tab marijuana_recent_freq marijuana_recent_freq_code, m 

lab define marijuanaf 1 daily 2 "2-3 times per week" 3 "once per week" 4 "2-3 times per month" 5 "once per month" 6 "I prefer not to answer", modify 
encode marijuana_recent_freq, gen(marijuanaf) label(marijuanaf) 
*tab marijuana_recent_freq marijuanaf , m 
drop marijuana_recent_freq*
rename marijuanaf marijuana_recent_freq 
lab val marijuana_recent_freq marijuanaf 


lab define virtual 1 "in-person clinical assessments" 2 "virtual clinical assessments", modify
encode  assessment_obtained_how, gen(visittype) label(virtual) 
drop assessment_obtained_how_code assessment_obtained_how 
rename visittype assessment_obtained_how 
lab val assessment_obtained_how virtual 


lab define drinkf 0 none 1 "every day" 2 "5-6 times a week" 3 "4 times a week" 4 "3 times a week" 5 "twice a week" 6 "once a week" 7 "2-3 times a month" 8 "once a month"  9 "less than once a month" 10 "1-3 per week" 11 "1-2 per day" 12 "3 or more daily"  13 "occasionally" , modify 

cap drop drink_freq 
gen drink_freq=0 if drinking_etoh=="none"  
local n=0
foreach x in "daily" "5-6 times per week"  "4 times per week"  "3 times a week"  "twice per week"  "once per week"  "2-3 times per month" "once per month" "less than once per month" "1-3 per week"  "1-2 per day" "3 or more daily" "occasionally" {
	local ++n 
	replace drink_freq= `n' if drinking_etoh== "`x'"  
} 

lab val drink_freq drinkf 
drop drinking_etoh drinking_etoh_code 
rename drink_freq drinking_etoh 

lab define drinkdwm 1 day 2 week 3 month, modify 
lab val drink_times_dwm_code drinkdwm 
drop drink_times_dwm  
rename drink_times_dwm_code drink_times_dwm 

lab define drinkwmy 1 week 2 month 3 year, modify 
encode drink_days_3_wmy, gen(drinkwmy) label(drinkwmy) 
drop drink_days_3_wmy*
rename drinkwmy drink_days_3_wmy 

lab define smoke 0 "never smoked" 1 "current smoker" 2 "previous smoker"  3 "yes, only socially"
lab val smoking_cigs_code smoke 
replace smoking_cigs_code=3 if smoking_cigs=="yes, only socially" 
drop smoking_cigs 
rename smoking_cigs_code smoking_cigs 


foreach x in tb_blood_skin_dt  tb_blood_dt  tb_skin_dt  x_surgeries_most_recent_dt smoke_start_dt smoke_quit_dt { 
	gen dt=date(`x', "YMD") 
	drop `x' 
	rename dt `x' 
	format `x' %tdCCYY-NN-DD 
} 

destring bp_diastolic bp_systolic pt_pain pt_fatigues am_stiff_severity tender_jts_28 swollen_jts_28 pt_global_assess md_global_assess am_stiff_hrs am_stiff_mins health_status_assess, replace 
destring curated_weight curated_bmi wpai_absent wpai_present wpai_wrkimp wpai_actimp di_calc haq_di_calc ,  replace  // computed 
destring wpai_* drink_days_3 drink_perday drink_times, replace 

*haq values 

lab define haq 0 "without any difficulty" 1 "with some difficulty" 2 "much difficulty" 3 "unable to do" , modify 

foreach x in dress_yourself get_in_out_bed lift_cup_glass walk_outdoors wash_dry_body bend_down_pick_up turn_faucets get_in_out_car climb_5_steps chores {
drop haq_`x' 
rename haq_`x'_code haq_`x'
lab val haq_`x' haq 
}

compress 

ds *_code, v(32) 

/*
doi_not_started_1_code  doi_not_started_2_code  doi_reason_1_code doi_reason_2_code  doi_route_1_code   doi_route_2_code       
*/

lab var subject_number  "Subject ID"
lab var site_number  "Site ID"
lab var visitdate  "Date of office visit"
lab var c_effective_event_date "date of office visit
lab var study_acronym "Study type"
lab var source_acronym  "EDC data source"
lab var dw_event_type_acronym  "Form: enrollment/follow up"
lab var full_version  "Form version" 

* su form 
lab var work_status  "Work status"	
lab var disabled_ra  "Disabled due to RA"	

lab var smoke_ever_100  "Ever smoked 100 cigs"	
lab var smoke_regular  "Smoke regularly"	
lab var smoke_current  "Currently smoke"	
lab var smoke_start_age  "Age started smoking"	
lab var smoke_perday  "# of cigs. per day"	
lab var smoke_n_perday  "# of cigs. per day"	
lab var smoke_last_age  "Age last smoked "	
lab var smoke_lifetime_year  "Years of smoked in the life"	
lab var smoke_lifetime_month  "Months of smoked in the life"	
lab var smoke_start  "Start smoking since last visit"	
lab var smoke_start_dt  "Date of start smoke since last visit"	
lab var smoke_quit  "Quit smoking since last visit"	
lab var smoke_quit_dt  "Date of quit smoke"	
lab var smoke_oth  "Smoke other tobacco/nicotine products"	
lab var smoke_oth_cigars  "Cigars  "	
lab var smoke_oth_pipes  " Pipes"	
lab var smoke_oth_chewing  "Chewing tobacco"	
lab var smoke_oth_e_cigar  "E-cigarettes or other vaping device"	
lab var smoke_oth_tobacco  "Other tobacco or nicotine product"	
lab var smoke_oth_tobacco_spec  "Other tobacco or nicotine product specify"	
lab var smoking_cigs  "Smoke cigarettes"

lab var marijuana_recent  "Used marijuana in the past 30 days"	
lab var marijuana_recent_freq  "How often did you take marijuana?"	
lab var marijuana_pres  "Prescription for marijuana from physician"	
lab var drinks_status  "Have drink in the past 3 months?"	
lab var drinking_etoh  "drink frequency"	
lab var drink_perday  "# average drinks on drinking days"	
lab var drink_times  "How often drinking in last year"	
lab var drink_times_dwm  "day/week/month(drink time)"	
lab var drink_none  "Not drinking"	
lab var drink_days_3  "days had >=3 drinks"	
lab var drink_days_3_wmy  "days had >=3 drinks per w/m/y"	
lab var pregnant_ever  "Have you ever been pregnant?"	
lab var pregnant_since  "Pregnant since the last visit"	
lab var pregnant_now  "Are you currently pregnant?"	
lab var menopause_now  "current menopause symptoms"	
lab var menopause_post   "past-menopausal"	
lab var emergency  "Emergent visit since last visit"	
lab var breastfeed_now  "currently breastfeeding"	
lab var pt_pain  "Patient pain assessment"	
lab var pt_global_assess  "patient global assessment "	
lab var pt_fatigues  "patient fatigues assessment"	
lab var am_stiffness  "Stiffness in the morning"	
lab var am_stiff_hrs  "Stiffness hours"	
lab var am_stiff_mins  "Stiffness minutes"	
lab var am_stiff_severity  "Severity of stiffness"	
lab var health_status_walking  "Mobility"	
lab var health_status_selfcare  "Self care"	
lab var health_status_activities  "Usual activities"	
lab var health_status_pain  "Pain/discomfort"	
lab var health_status_anx_dep  "Anxious/depressed"	
lab var health_status_assess  "Your own helath state today"	
lab var wpai_employed  "Are you currently employed?"	
lab var wpai_past_7_missed  "In past 7 days,  hours missed work by RA"	
lab var wpai_past_7_missed_other  "In past 7 days,  hours missed work by other"	
lab var wpai_hours_actual_work  "In past 7 days,  hours actually worked"	
lab var wpai_work_affected  "RA affected productivity while you were working."	
lab var wpai_ability_affected  "RA affected your ability to do your regular daily activities"	
lab var su_meds_yes_no  "You are not taking any of these medications"	
*lab var med_probs_none  "You have not had any of these medical conditions"	
*lab var outpt_visit  "Had outpatient doctor visit since last form"	
lab var x_outpt_visit_rheum  "Rheumatologist visit"	
lab var outpt_visit_pcp  "premary care"	
lab var outpt_visit_er  "emergency room"	
lab var outpt_visit_oth  "other doctor visit"	
lab var outpt_visit_oth_spec  "Other doctor visit specify"	
*lab var outpt_visits_total  "How many outpatient doctors visits"	
lab var hosp  "Admitted to the hospital since last form"	
lab var hospitalization_calc  "Admitted to the hospital" 

* md form 
lab var curated_weight  "weight (pounds)"
lab var bp_systolic  "Seated BP(systolic)"
lab var bp_diastolic  "Seated BP(diastolic)" 
lab var study_other_enrolled  "Currently enrolled in another registry  study?"

lab var tender_jts_28  "28 joints: tender "
lab var swollen_jts_28  "28 joint: swollen "
lab var md_global_assess  "Physician global assessment scale"
lab var assessment_obtained_how  "How were the provider assessments obtained for this visit?"

lab var surgeries_yes_no  "Had any spinal surgeries, arthroplasities, or joint fusions related to RA?"
lab var surgeries_since_yes_no   "Had any spinal surgeries, arthroplasities, or joint fusions related to RA?"

lab var insurance_yes_no  "Health insurance "
lab var insurance_medicare  "Insurance: Medicare"
lab var insurance_medicare_type  "If medicare, plan type"
lab var insurance_medicaid  "Insurance: Medicaid"
lab var insurance_private  "Insurance: Private"
lab var insurance_private_com  "Name of insurance compary" 
lab var insurance_va_military  "Insurance: VA/Military" 

lab var vaccine_pna_zos_ever  "EVER received pneumonia or shingles vaccine?"
lab var vaccine_pna_zos_flu_since  "Received pneumonia, zoster, or flu vaccine since last visit?"
lab var vaccine_flu  "Ever received influenza vaccine ?"
lab var vaccine_flu_since  "Received influenza vaccine in the last 12 months?"
lab var vaccine_pneumo  "Has patient received pneumonia vaccine in the last 12 months?"
lab var vaccine_pneumo_since  "Has patient received pneumonia vaccine in the last 12 months?"
lab var vaccine_zoster  "Has patient ever received zoster vaccine?"
lab var vaccine_zoster_since  "Has patient received zoster vaccine in the last 12 months?"
lab var vaccine_covid_ever  "EVER received a COVID-19 vaccine?"
lab var vaccine_covid_since  "Received a COVID-19 vaccine since last visit?"

lab var tb_ever  "Has the patient EVER been tested for TB?"
lab var tb_since  "Has the pateint been test for TB SINCE last visit"
lab var tb_blood_performed  "Blood based TB screening"
lab var tb_skin_performed  "PPD performed" 
lab var tb_test_performed_6mo  "if yes, TB testing  performed in 6month"
lab var tb_blood_result  "Blood based TB test"
lab var tb_blood_positive  "Blood based TB positive?"
lab var tb_skin_result  "PPD >= 5mm"
lab var tb_skin_result  "PPD >=5mm or QFT positive"
lab var tb_blood_dt  "Date of blood based TB test"
lab var tb_skin_dt  "Date of Skin Test"
lab var tb_blood_skin_dt  "PPD/QFT test date"
lab var tb_test_type  "most recent test type"
lab var tb_latent_treatment  "Was treatment prescribed for latern TB?"
lab var tb_blood_skin_positive_tx  "If positive, was treatment prescribed?"
lab var tb_skin_positive_treatment  "If PPD positive, was prescribed?"
lab var tb_skin_no_test  "PPD test was not performed or interpreted medical reason?"
lab var tb_blood_skin_no_test  "Blood/skin test was not performed or interpreted medical reason?"

lab var labs_imaging_coll  "Laboratory/radiology/DXA submitted today"
lab var lab_rad_dxa_submit  "Laboratory/radiology/DXA submitted later"
lab var infections_for_yes_no  "EVER had active TB, HIV, Herpes zoster, hepatitis B or C, or PML regardless of seriousness?"
lab var infections_yes_no  "EVER have any infections?"
lab var infections_since_yes_no  "Any infections since the last visit?"

lab var ae_comor_tox_fract  " EVER had any comorbidities or adverse events?"
lab var ae_comor_tox_fract_since  "Any comorbidities or adverse events since last visit?"

lab var med_condition_ever_yes_no  "EVER had any comorbidities or adverse events (part 1)?"
lab var med_condition_ever2_yes_no  "EVER had any comorbidities or adverse events part 2)?"
lab var med_condition_since_yes_no  "Had any comorbidities or adverse events since last visit (part 1)?"
lab var med_condition_since2_yes_no  "Had any comorbidities or adverse events since last visit (part 2)?"

lab var fractures_yes_no  "Never had Fractures" 
lab var fractures_since_yes_no  "Fractures since last visit"
lab var joint_deformity  "Clinical joint deformity"
lab var md_meds_yes_no  "TM: not taking any these meds; V11/RCC: not taken any NSAIDs"
lab var conmed_yes_no "Conmed drug use"

lab var osteo_meds_yes_no  "ever received an osteoporosis drug"
lab var osteo_meds_since_yes_no  "received an osteoporosis drug since last visit"


lab var subcutan_nods  "Subcutaneous nodules"
lab var sec_sjog  "Secondary Sjogren's"

lab var doi_since_yes_no  "Since the last registry visit: Were any drugs used for the treatment of RA newly prescribed but never started?"
lab var doi_not_started_1  "Not started drug name 1"
lab var doi_not_started_2   "Not started drug name 2" 
lab var doi_reason_1  "Primary reason drug not started 1"
lab var doi_reason_2  "Primary reason drug not started 2" 
lab var doi_not_started_oth_1  "Other reason drug was not started 1"
lab var doi_not_started_oth_2  "Other reason drug was not started 2"
lab var doi_reason_oth_spec_1  "Specify other reason if drug not started 1"
lab var doi_reason_oth_spec_2  "Specify other reason if drug not started 2"

lab var no_bio_sm  "Did patient EVER use or start DOI?"
lab var no_bio_sm_since  "Did patient use or start DOI since last visit?"
lab var hosp  "D. Hospitalization "
lab var hospitalizations_ra  "Hospitalization for RA "
lab var hosp_arthro  "Hospitalization for joint arthroplasty"
lab var hosp_inf  "Hospitalization for Infection"
lab var hosp_cve  "Hospitalization for CVE"
lab var hosp_oth_cond  "Hospitalization for other medical conditions" 

lab var cbc_yn "CBC results available"
lab var chest_xray_yn "Chest x-ray results available"
lab var dxa_yn "DXA results available"
lab var hep_b_panel_yn "Hepatitis B panel results available"
lab var hep_c_panel_yn "Hepatitis C panel results available"
lab var inflammatory_yn "Inflammatory marker results available"
lab var joint_mri_yn "Joint MRI results available"
lab var joint_ultrasound_yn "Joint US results available"
lab var joint_xray_yn "Joint xray results available"
lab var kidney_function_yn "Kidney function results available"
lab var lipid_panel_yn "Lipid panel results available"
lab var liver_function_yn "Liver function results available"
lab var ra_diag_results_yn "RA diagnostic results available"
lab var vitamin_d_yn "Vitamin D results available"

// 2025-01-14 several _calc vars are not available 
*lab var outpt_visit_rheum_calc "outpt_visit_rheum calc RCC and v9-11"
*lab var outpt_dr_visits_count_calc "How many outpatient doctors visits did you have?"
*lab var outpt_any_calc "Calculation to determine if the patient had any outpatient visits standardized across edc sources"
*lab var surgeries_any_ra_calc "Calculation to determine if the patient had any ra surgeries standardized across edc sources"
*lab var surgeries_any_ra_count_calc "Calculation to determine total surgeries standardized across edc sources"
lab var labs_imaging_coll "Blood or imaging tests Parent Y/N - blood or imaging tests listed in the registry Lab-Imaging Form available for reporting"
lab var hospitalization_calc "Calculation to determine if the patient had any hospitalizations standardized across edc sources"
lab var di_calc "mHAQ"
lab var haq_di_calc "HAQ-DI"
// 2025-01-14 changed from cdai to cdai_calc
lab var cdai_calc "CDAI" 
*
lab var hosp_count "How many times were you Admitted to the hospital"
destring hosp_count, replace 

replace md_meds_yes_no=0 if md_meds_yes_no==1 & strpos(source_acronym, "PRETM") >0 // preTM reported in subject form and is a checked box if not using any nsaids

* clean duplicate visits 

sort subject_number visitdate full_version 
by subject_number visitdate: gen vn=_n 
by subject_number visitdate: gen vN=_N 
tab vN if vn==1 

*br subject_number visitdate study_source major_version dw_event_type  if vN==3  // RCC test data 

preserve 
    keep if vn==2  
	sort subject_number visitdate 
	save vn2, replace 
restore 

keep if vn==1 

clonevar version = full_version   

sort subject_number visitdate 
merge 1:1 subject_number visitdate using vn2, update replace  // using later version as priority 
rename vN dupvisits 

replace full_version=version if _m>=3 & full_version>=12 & year(visitdate)<2012  // some sites reenter CSG visits, use earliest version for visit if dupliates 
drop _m vn version
erase vn2.dta  


* clean weight 

clonevar weight_lb=curated_weight 
replace weight_lb=. if weight_lb<=0
replace weight_lb=. if weight_lb>800 

sort subject_number visitdate 
by subject_number: gen ck=1 if abs(weight_lb-weight_lb[_n-1])>80 & abs(weight_lb - weight_lb[_n+1])>80 & weight_lb<. & weight_lb[_n-1]<. & weight_lb[_n+1]<.
by subject_number: replace ck=0 if ck[_n+1]==1 | ck[_n-1]==1 

tab ck 
by subject_number: replace weight_lb=weight_lb[_n-1] if ck==1 

list subject_number visitdate curated_weight weight_lb ck if ck<. in 1/3000, noobs ab(30) sepby(subject_number) 

/*
  +---------------------------------------------------------------+
  | subject_number    visitdate   curated_weight   weight_lb   ck |
  |---------------------------------------------------------------|
  |      000000063   2013-10-02              146         146    0 |
  |      000000063   2014-03-11               46         146    1 |
  |      000000063   2014-12-08              148         148    0 |
  |---------------------------------------------------------------|
  |      000123497   2014-05-27              112         112    0 |
  |      000123497   2015-05-21              205         112    1 |
  |      000123497   2015-12-09              104         104    0 |
  |---------------------------------------------------------------|
  |      001010083   2007-11-20              205         205    0 |
  |      001010083   2008-03-04               12         205    1 |
  |      001010083   2008-06-16              202         202    0 |
  |---------------------------------------------------------------|
  |      001010088   2011-12-13              228         228    0 |
  |      001010088   2012-04-05               80         228    1 |
  |      001010088   2012-08-21              229         229    0 |
  |---------------------------------------------------------------|
  |      001010124   2010-11-18              116         116    0 |
  |      001010124   2011-01-25              256         116    1 |
  |      001010124   2011-03-28              162         162    0 |
  |---------------------------------------------------------------|
  |      001010183   2015-09-15              137         137    0 |
  |      001010183   2016-03-15              247         137    1 |
  |      001010183   2016-10-25              130         130    0 |
  |      001010183   2018-09-11              123         123    0 |
  |      001010183   2018-10-01              285         123    1 |
  |      001010183   2018-10-30              130         130    0 |
  +---------------------------------------------------------------+
  */
 
 drop ck 

 gen ck=1 if weight_lb<70 
 egen everck=sum(ck), by(subject_number) 
*br subject_number visitdate *weight* ck if everck>0 
list subject_number visitdate *weight* ck if everck>0 in 1/30000, noobs ab(30) sepby(subject_number) 

/* 155 cases 
  +---------------------------------------------------------------+
  | subject_number    visitdate   curated_weight   weight_lb   ck |
  |---------------------------------------------------------------|
  |      001019016   2018-09-11              183         183    . |
  |      001019016   2019-05-01              180         180    . |
  |      001019016   2021-10-27              169         169    . |
  |      001019016   2022-08-03              170         170    . |
  |      001019016   2023-05-08              123         123    . |
  |      001019016   2023-11-08               60         123    1 |
  |---------------------------------------------------------------|
  |      002020150   2020-01-02              173         173    . |
  |      002020150   2020-06-04              173         173    . |
  |      002020150   2021-01-07              166         166    . |
  |      002020150   2021-09-23              171         171    . |
  |      002020150   2022-11-28              164         164    . |
  |      002020150   2023-08-29               66         164    1 |
  |---------------------------------------------------------------|
  |      002020779   2006-01-09               30          30    1 |
  |---------------------------------------------------------------|
  |      002021119   2014-08-20              144         144    . |
  |      002021119   2015-05-14              142         142    . |
  |      002021119   2015-11-12               63         142    1 |
  |      002021119   2017-01-05              170         170    . |
  |      002021119   2018-06-26              171         171    . |
  |      002021119   2022-03-16              175         175    . |
  |---------------------------------------------------------------|

  |      002021688   2014-12-23              115         115    . |
  |      002021688   2015-03-25              114         114    . |
  |      002021688   2015-09-22              117         117    . |
  |      002021688   2016-03-23               51         117    1 |
  |---------------------------------------------------------------|
  |      002022573   2014-07-29               22         221    1 |
  |      002022573   2014-12-11              221         221    . |
  |      002022573   2016-03-16              226         226    . |
  +---------------------------------------------------------------+
  */ 

by subject_number: replace weight_lb=weight_lb[_n-1] if weight_lb<70 & weight_lb[_n-1]>=70 & weight_lb[_n-1]<. 
by subject_number: replace weight_lb=weight_lb[_n+1] if weight_lb<70 & weight_lb[_n+1]>=70 & weight_lb[_n+1]<. 
drop ck everck 

unique subject_number visitdate 
sort subject_number visitdate 
save temp\bv_longitudinal_clean, replace 


****************************************************************************************************************
****************************************************************************************************************

use temp\bv_longitudinal_clean , clear 

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_event_instance 

assert study_acronym!="" & source_acronym!="" 


tab dw_event_type_acronym if _m==2 
gen event_instance=_m==2 

drop _m 

drop if visitdate==. 


/*
v20250113
    Result                           # of obs.
    -----------------------------------------
    not matched                           899
        from master                       326  (_merge==1)
        from using                        573  (_merge==2)

    matched                           508,025  (_merge==3)
    -----------------------------------------

    Result                           # of obs.
    -----------------------------------------
    not matched                           640
        from master                       360  (_merge==1)
        from using                        280  (_merge==2)

    matched                           491,610  (_merge==3)
    -----------------------------------------
br subject_number c_effective_event_date dw_event_type_acronym full_version if subject_number=="093010015" | subject_number=="093010016" | subject_number=="205030900"
*/ 

sort subject_number visitdate  
merge 1:1 subject_number visitdate using temp\temp_rfccp 
replace event_instance=0 if _m==3
gen lab_yn=_m>=2 
drop _m 

assert study_acronym!="" & source_acronym!="" 

// 2025-01-14 changed to temp_image2
sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_image2
replace event_instance=0 if _m==3  
gen imaging_yn=_m>=2
drop _m 

assert study_acronym!="" & source_acronym!="" 

replace tb_blood_skin_no_test=tb_skin_no_test if full_version>9 & tb_blood_skin_no_test==. 
replace tb_skin_no_test=. if full_version>9 

lab var c_provider_id "Provider ID" 
lab var curated_bmi "BMI"
lab var ccp_pos_ever "Ever had CCP positive"
lab var rf_pos_ever "Ever had RF positive" 
lab var hx_bio_en "Ever used/started DOI" 
*lab var conmeds_yes_no "current use conmon medications" 
lab var rheum_visits "RA visits"

// 2025-01-14 surgeries_any_ra_calc not found 
*lab var surgeries_any_ra_calc "surgeries caused by RA"
lab var hospitalization_calc "hospitalization" 
// surgeries_any_ra_calc 
foreach x in hospitalization_calc {
	gen `x'2=`x'=="yes" if `x'!=""
	drop `x' 
	rename `x'2 `x' 
} 

drop parent_study_acronym dw_site_uid dw_subject_uid 
drop doi_*_code 

*destring outpt_dr_visits_count_calc, replace 
drop if site_number>=997 // test site

rename bp_systolic seatedbp1
rename bp_diastolic seatedbp2 

gen insurance_none=1 if insurance_yes_no==0 
lab var insurance_none "no insurance" 
lab val insurance_none ny 

* ENG created calculated variables 
rename di_calc di 
rename haq_di_calc haq_di 


sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_radrug, update 
replace event_instance=0 if _m==3 
gen radrug_yn=_m>=2 
drop _m 

assert study_acronym!="" & source_acronym!="" 


drop if visitdate==. 

rename seatedbp1 bp_systolic  
rename seatedbp bp_diatolic 

*************************

merge 1:1 subject_number visitdate using temp\temp_comorvt  
replace event_instance=0 if _m==3 
gen comor_yn=_m>=2 
drop _m 
assert study_acronym!="" & source_acronym!=""  

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_infvt  
replace event_instance=0 if _m==3 
gen infection_yn=_m>=2 
drop _m 

assert study_acronym!="" & source_acronym!=""  

*use "clean_table\1_2_allvisits.dta", clear 

assert study_acronym!="" & source_acronym!="" 

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_conmedvt  
replace event_instance=0 if _m==3 
gen conmed_yn=_m>=2 
drop _m 
assert study_acronym!="" & source_acronym!=""  

foreach x in lab imaging radrug comor infection conmed {
    lab val `x'_yn yn  
	lab var `x'_yn "with `x' data"
	replace `x'_yn=0 if `x'_yn==. 
} 

tab dw_event_type_acronym if event_instance==1 

drop if event_instance==1 
drop event_instance 

drop c_is_* x_*

sort subject_number visitdate 
merge 1:1 subject_number visitdate using ..\..\for_update\ara, update 
drop if _m==2 
drop _m 
assert study_acronym!="" & source_acronym!="" 

list site_number subject_number visitdate study_acronym source_acronym dw_event_type_acronym if full_version==., noobs

replace full_version=15 if full_version==. & source_acronym=="RCC" 
replace full_version=11 if full_version==. & source_acronym=="TM" & study_acronym=="CERTAIN" 

lab var c_event_created_date "Created date"
lab var c_event_last_modified_date "Last modified date"   

* ENG calculated -no tested value drop for now 
*drop wpai_absent wpai_present wpai_wrkimp wpai_actimp conmed_yes_no* outpt_visit_rheum_calc outpt_dr_visits_count_calc outpt_any_calc surgeries_any_ra_count_calc  surgeries_any_ra_calc  hospitalization_calc
*rename cdai cdai_calc
cap drop cdai_calc 
drop c_dw_event_instance_key  dupvisits visit_date dupvisits visit_date curr_no_dmards curated_weight 
cap drop c_edc_event_instance_key
drop wpai_absent wpai_present wpai_wrkimp wpai_actimp hospitalization_calc 
cap drop surgeries_any_ra_calc surgeries_any_ra_count_calc  // ENG created, need to test future 
drop c_effective_event_date

* drop cpai_absent w

assert study_acronym!="" & source_acronym!=""  

rename drink_perday drink_n_perday // drink_n_perday is standardized name 

replace drink_n_perday=50 if  drink_n_perday>50 & drink_n_perday<. 

// LG 2024-10-02 talked with Ying, this part was not decided yet
*replace bp_systolic=220 if bp_systolic>300 & bp_systolic<. 
*replace bp_diatolic=150 if bp_diatolic>130 & bp_diatolic<. 

*replace bp_systolic=. if bp_diatolic<60 
*replace bp_diatolic=. if bp_
 


sort subject_number visitdate 

codebook visitdate // [01oct2001,07jan2025] ==> [01jan1900,31dec2024]
*count if visitdate>d(31dec2024) //144

count if visitdate>d($cutdate)
drop if visitdate>d($cutdate)

compress
save clean_table\1_2_allvisits_$datacut, replace 

* Rich 2024-05-14 email site confirm subject 015001015 two visit after death date (2014-10-01) are date enter issue, need to remove 

count if visitdate>d(1Oct2014) & subject_number=="01001015" 


for any event_instance radrug conmedvt comorvt infvt exit image2 rfccp: cap erase "temp\temp_X.dta" 

