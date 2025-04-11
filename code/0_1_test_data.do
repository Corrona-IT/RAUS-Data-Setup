
*global pdata "~/Corrona LLC/Biostat Data Files - RA\monthly\2024\2024-07-01\" 
*cd "~/Corrona LLC/Biostat Data Files - RA/monthly\2024\2024-08-01\"  

use bv_raw\bv_subjects, clear 
* drop *_uid // 2025-02-04 uid data is not included 
corcf *  using "$pdata\bv_raw\bv_subjects", id(subject_number) //verbose noobs 

/*
note: master has 62436 observations; using has 62399 observations
diagnosis_date: does not exist in using
Comparison of common IDs follows
birthyear: 3 mismatches
sex: 1 mismatches
sex_code: 1 mismatches
diagnosis_year: 26 mismatches
enrollment_date: 5 mismatches
earliest_visit_date: 5 mismatches
most_recent_visit_date: 1168 mismatches
exit_form_date: 2888 mismatches
enrollment_provider_id: 5 mismatches
earliest_site_key: 1 mismatches
earliest_site_number: 1 mismatches
most_recent_site_key: 1 mismatches
most_recent_site_number: 1 mismatches
subject_provided_dob: 2858 mismatches
subject_provided_email: 2858 mismatches
subject_provided_name: 2858 mismatches
subject_provided_phone: 2858 mismatches
subject_provided_sex: 2858 mismatches
subject_provided_zipcode: 2859 mismatches

2025-04-09 v2025-04-08 from fido2 server  
note: master has 62460 observations; using has 62399 observations
diagnosis_date: does not exist in using
Comparison of common IDs follows
birthyear: 4 mismatches
sex: 2 mismatches
sex_code: 2 mismatches
diagnosis_year: 30 mismatches
enrollment_date: 7 mismatches
earliest_visit_date: 7 mismatches
most_recent_visit_date: 1850 mismatches
exit_form_date: 1669 mismatches
enrollment_provider_id: 7 mismatches
earliest_site_key: 1 mismatches
earliest_site_number: 1 mismatches
most_recent_site_key: 3 mismatches
most_recent_site_number: 3 mismatches
subject_provided_dob: 2872 mismatches
subject_provided_email: 2872 mismatches
subject_provided_name: 2872 mismatches
subject_provided_phone: 2871 mismatches
subject_provided_sex: 2872 mismatches
subject_provided_zipcode: 2873 mismatches

*/
rename subject_provided_* apr_08_subject_provided_*
rename *_date apr_08_*_date

merge 1:1 subject_number using "$pdata\bv_raw\bv_subjects", keepus(subject_provided_* *_date) 

rename subject_provided_* mar2025_subject_provided_*
rename most_recent_visit_date mar2025_most_recent_visit_date
rename exit_form_date mar2025_exit_form_date

// list some examples for the difference between MAR vs. Apr data. 
foreach x in dob email name phone sex zipcode{
preserve 
keep if _m==3 & apr_08_subject_provided_`x'!=mar2025_subject_provided_`x'
list subject_number mar2025_subject_provided_`x' apr_08_subject_provided_`x' in 1/10, noobs ab(28)
restore 
}

foreach x in dob email name phone sex zipcode{

groups apr_08_subject_provided_`x' mar2025_subject_provided_`x' if _m==3, missing ab(16) sepby(apr_08_subject_provided_`x') 

}

foreach x in most_recent_visit_date exit_form_date{
preserve 
keep if _m==3 & apr_08_`x'!=mar2025_`x'
list subject_number mar2025_`x' apr_08_`x' in 1/10, noobs ab(28)
restore 
}

mdesc mar2025_exit_form_date apr_08_exit_form_date  if _m==3 

count if mar2025_exit_form_date==apr_08_exit_form_date & _m==3 & mar2025_exit_form_date!=""

// 2025-04-01 sent to EDW support to verify 
export excel subject_number mar2025_exit_form_date apr_08_exit_form_date  if _m==3 & mar2025_exit_form_date!=apr_08_exit_form_date using "bv_raw\bv_subjects_exit_form_date_2025-04-09.xlsx" , firstrow(var) replace 

br subject_number mar25_exit_form_date apr25_exit_form_date mar25_most_recent_visit_date apr25_most_recent_visit_date if _m==3 & mar25_exit_form_date!=apr25_exit_form_date

*count if _m==3 & mar25_exit_form_date!=apr_08_exit_form_date & mar25_most_recent_visit_date!=apr_08_most_recent_visit_date

*count if _m==3 & mar25_exit_form_date!="" & apr25_exit_form_date=="" & mar25_most_recent_visit_date==apr25_most_recent_visit_date

mdesc mar2025_exit_form_date apr_08_exit_form_date  if _m==3 & mar2025_exit_form_date!=apr_08_exit_form_date, ab(28)
/*
    Variable                 |     Missing          Total     Percent Missing
-----------------------------+----------------------------------------------------------
      mar2025_exit_form_date |         490          1,669          29.36
       apr_08_exit_form_date |          15          1,669           0.90
-----------------------------+----------------------------------------------------------


drop most_recent_visit_date 
corcf *  using "$pdata\bv_raw\bv_subjects", id(subject_number) verbose noobs 

*/
/*keep subject_number exit_form_date 


*br subject_number exit_form_date* if exit_form_date!=exit_form_date_current & _m==3 & exit_form_date!="" 
use bv_raw\bv_subjects, clear
gen year=substr(exit_form_date_current, 1, 4)

destring year, replace 

list subject_number exit_form_date* if _m==3 & exit_form_date != exit_form_date_current & year<2024, noobs ab(16)
// none for v20241203

  +----------------------------------------------------+
  | subject_number   exit_form_date~t   exit_form_date |
  |----------------------------------------------------|
  |      245060036         2023-04-04                  |
  |      253010103         2023-08-02                  |
  +----------------------------------------------------+
*/

* br subject_number exit_form_date* if _m==3 & exit_form_date_current != exit_form_date & year==2024
*br subject_number enrollment_date* if _m==3 & enrollment_date_current != enrollment_date // all RCC visits 
*br subject_number earl*_date* enroll* if _m==3 & earliest_visit_date_current != earliest_visit_date // all RCC visits 

**************************
use bv_raw\bv_subject_demographic_data, clear  
*drop *_uid // 2025-02-04 no more *_uid vars
corcf *  using "$pdata\bv_raw\bv_subject_demographic_data", id(subject_number) 

/*
note: master has 61887 observations; using has 61774 observations
Comparison of common IDs follows
birthyear: 2 mismatches
curated_diagnosis_year: 22 mismatches
c_height_inches: 21 mismatches
c_height_inches_alt: 21 mismatches
curated_symptom_year: 18 mismatches
symptom_year_alt: 18 mismatches
marital_status: 18 mismatches
marital_status_code: 18 mismatches
marital_status_alt: 18 mismatches
race_white: 17 mismatches
race_other: 1 mismatches
hispanic: 18 mismatches
c_education: 18 mismatches
c_education_code: 18 mismatches
c_education_alt: 18 mismatches
famhx_mi_or_stroke: 18 mismatches
famhx_mi_or_stroke_code: 18 mismatches
famhx_mother: 2 mismatches
famhx_mother_code: 2 mismatches
famhx_father: 4 mismatches
famhx_father_code: 4 mismatches
famhx_alt: 18 mismatches
c_dw_event_instance_key: 61721 mismatches
*/

drop c_dw_event_instance_key
corcf *  using "$pdata\bv_raw\bv_subject_demographic_data", id(subject_number) verbose noobs // all mismatch because prior data missing value 

/*
note: master has 61887 observations; using has 61774 observations
Comparison of common IDs follows
birthyear: 2 mismatches

  +-------------------------------------------+
  | subject_number   master_data   using_data |
  |-------------------------------------------|
  |      001250767          1986         1956 |
  |    RA-217-0027          1961      8291961 |
  +-------------------------------------------+
*/

**************************
use "$pdata\bv_raw\bv_longitudinal_visit_data", clear 

drop med_condition_since2_yes_no_code
bysort subject_number c_effective_event_date full_version: gen vN=_N
tab vN 
drop if vN>1 
save temp\bv_longti, replace 

use "bv_raw\bv_longitudinal_visit_data", clear 
/*sort subject_number c_effective_event_date
for any 000000000 000000003 000000005: list subject_number c_effective_event_date study_acronym source_acronym full_version dw_event_type_acronym if subject_number=="X" , noobs ab(16)
*/
*drop *_uid 
bysort subject_number c_effective_event_date full_version: drop if _N>1 

drop *_code 

corcf * using "temp\bv_longti", id(subject_number c_effective_event_date full_version) // all are RCC data, build 20240701z were missing. 
/*
note: master has 511965 observations; using has 510680 observations
c_is_sameday_fu_after_en: does not exist in using
c_is_enrollment_after_fu: does not exist in using
c_is_same_day_visit2: does not exist in using
outpt_visit_rheum_calc: does not exist in using
outpt_dr_visits_count_calc: does not exist in using
outpt_any_calc: does not exist in using
surgeries_any_ra_calc: does not exist in using
surgeries_any_ra_count_calc: does not exist in using
Comparison of common IDs follows
c_provider_id: 3 mismatches
c_event_last_modified_date: 3757 mismatches
bp_diastolic: 36 mismatches
bp_systolic: 36 mismatches
curated_weight: 41 mismatches
curated_bmi: 40 mismatches
pregnant_since: 18 mismatches
pregnant_now: 17 mismatches
breastfeed_now: 16 mismatches
menopause_now: 15 mismatches
menopause_post: 15 mismatches
insurance_yes_no: 38 mismatches
insurance_medicare: 17 mismatches
insurance_medicaid: 3 mismatches
insurance_va_military: 2 mismatches
insurance_private: 21 mismatches
insurance_medicare_type: 18 mismatches
marijuana_recent: 22 mismatches
marijuana_recent_freq: 3 mismatches
marijuana_pres: 2 mismatches
smoke_oth: 21 mismatches
work_status: 22 mismatches
disabled_ra: 2 mismatches
pt_pain: 23 mismatches
pt_global_assess: 23 mismatches
pt_fatigues: 23 mismatches
am_stiffness: 23 mismatches
am_stiff_hrs: 11 mismatches
am_stiff_mins: 13 mismatches
am_stiff_severity: 15 mismatches
ccp_pos_ever: 6 mismatches
rf_pos_ever: 6 mismatches
tender_jts_28: 42 mismatches
swollen_jts_28: 41 mismatches
md_global_assess: 44 mismatches
hosp: 22 mismatches
hosp_count: 3 mismatches
wpai_employed: 22 mismatches
wpai_past_7_missed: 3 mismatches
wpai_past_7_missed_other: 3 mismatches
wpai_hours_actual_work: 3 mismatches
wpai_work_affected: 7 mismatches
wpai_ability_affected: 24 mismatches
wpai_absent: 3 mismatches
wpai_present: 7 mismatches
wpai_wrkimp: 4 mismatches
wpai_actimp: 24 mismatches
di_calc: 22 mismatches
haq_di_calc: 22 mismatches
cdai_calc: 51 mismatches
health_status_walking: 22 mismatches
health_status_selfcare: 22 mismatches
health_status_activities: 22 mismatches
health_status_pain: 21 mismatches
health_status_anx_dep: 22 mismatches
health_status_assess: 22 mismatches
ae_comor_tox_fract: 5 mismatches
ae_comor_tox_fract_since: 37 mismatches
hx_bio_en: 46 mismatches
no_bio_sm: 5 mismatches
infections_yes_no: 5 mismatches
infections_since_yes_no: 35 mismatches
infections_for_yes_no: 5 mismatches
med_condition_since_yes_no: 14 mismatches
med_condition_since2_yes_no: 6 mismatches
md_meds_yes_no: 40 mismatches
osteo_meds_yes_no: 5 mismatches
osteo_meds_since_yes_no: 34 mismatches
surgeries_yes_no: 5 mismatches
surgeries_since_yes_no: 34 mismatches
doi_since_yes_no: 35 mismatches
tb_blood_result: 10 mismatches
tb_blood_skin_dt: 10 mismatches
tb_test_type: 10 mismatches
tb_skin_result: 1 mismatches
tb_ever: 5 mismatches
tb_since: 35 mismatches
vaccine_covid_ever: 6 mismatches
vaccine_covid_since: 33 mismatches
vaccine_flu: 6 mismatches
vaccine_pna_zos_ever: 6 mismatches
vaccine_pna_zos_flu_since: 35 mismatches
hospitalization_calc: 22 mismatches
x_surgeries_count: 1 mismatches
x_outpatient_visits_since: 23 mismatches
x_total_outpatient_visits: 18 mismatches
x_outpt_visit_rheum: 3 mismatches
outpt_visit_pcp: 10 mismatches
outpt_visit_er: 3 mismatches
outpt_visit_oth: 10 mismatches
outpt_visit_oth_spec: 10 mismatches
labs_imaging_coll: 41 mismatches
drinks_status: 22 mismatches
drinking_etoh: 6 mismatches
drink_perday: 6 mismatches
smoke_ever_100: 1 mismatches
smoke_current: 22 mismatches
doi_not_started_1: 2 mismatches
doi_reason_1: 2 mismatches
doi_route_1: 2 mismatches
study_other_enrolled: 38 mismatches
assessment_obtained_how: 39 mismatches
cbc_yn: 2 mismatches
chest_xray_yn: 30 mismatches
dxa_yn: 31 mismatches
hep_b_panel_yn: 23 mismatches
hep_c_panel_yn: 25 mismatches
inflammatory_yn: 3 mismatches
joint_mri_yn: 28 mismatches
joint_ultrasound_yn: 28 mismatches
joint_xray_yn: 25 mismatches
kidney_function_yn: 5 mismatches
lipid_panel_yn: 27 mismatches
liver_function_yn: 2 mismatches
ra_diag_results_yn: 23 mismatches
vitamin_d_yn: 21 mismatches
haq_dress_yourself: 22 mismatches
haq_get_in_out_bed: 21 mismatches
haq_lift_cup_glass: 22 mismatches
haq_walk_outdoors: 22 mismatches
haq_wash_dry_body: 22 mismatches
haq_bend_down_pick_up: 22 mismatches
haq_turn_faucets: 22 mismatches
haq_get_in_out_car: 21 mismatches
haq_climb_5_steps: 22 mismatches
haq_chores: 22 mismatches
insurance_private_com: 21 mismatches

*/

keep if source_acronym=="RCC" 
*log using bv_raw\test_RCCdata.log, replace 
corcf * using "temp\bv_longti", id(subject_number c_effective_event_date full_version) verbose noobs 
*log close 

****
use "$pdata\bv_raw\bv_drugs_of_interest", clear 
bysort subject_number c_effective_event_date dw_event_type_acronym source_acronym full_version drug_name drug_status drug_date dose_value dose_unit dose_txt freq_value freq_unit freq_txt: drop if _N>1 
 
*use temp\test_doi.dta, clear
destring freq_value, replace 
save temp\test_doi.dta, replace

use "bv_raw\bv_drugs_of_interest", clear 
bysort subject_number c_effective_event_date dw_event_type_acronym source_acronym full_version drug_name drug_status drug_date dose_value dose_unit dose_txt freq_value freq_unit freq_txt: drop if _N>1 

drop *_uid 
drop *_code 
drop c_event_created_date c_event_last_modified_date 

corcf * using temp\test_doi, id(subject_number c_effective_event_date dw_event_type_acronym source_acronym full_version drug_name drug_status drug_date dose_value dose_unit dose_txt freq_value freq_unit freq_txt)

/*
note: master has 1127652 observations; using has 1123436 observations
edc_event_name_raw: does not exist in using
edc_event_ordinal: does not exist in using
Comparison of common IDs follows
c_provider_id: 9 mismatches
coll_crf_ordinal: 1 mismatches
dose_status: 3 mismatches
drug_plan: 3 mismatches
route: 19 mismatches
steroid_high_dose_value: 18 mismatches
first_dose_at_visit: 1 mismatches
reason_1_category: 6 mismatches
reason_1: 6 mismatches
discontinued_due_to_ae: 1 mismatches
attributed_to_ae: 2 mismatches
*/
// 2024-12-02 drug_name_txt in december data are all in lower cases.
 
erase temp\test_doi.dta
erase temp\bv_longti.dta 

use "$pdata\bv_raw\bv_conmeds", clear 
unique subject_number c_effective_event_date conmed_section conmed_name conmed_status
bysort subject_number c_effective_event_date conmed_section conmed_name conmed_status: drop if _N>1
 
save temp\test_conmeds, replace 


use "bv_raw\bv_conmeds", clear 
groups reason_1 reason_1_code, missing ab(20)
drop *_uid 
bysort subject_number c_effective_event_date conmed_section conmed_name conmed_status: drop if _N>1 

corcf * using "temp\test_conmeds", id(subject_number c_effective_event_date conmed_section conmed_name_code conmed_status) 
/*
note: master has 1919620 observations; using has 1915024 observations
edc_event_name_raw: does not exist in using
edc_event_ordinal: does not exist in using
Comparison of common IDs follows
c_event_last_modified_date: 14148 mismatches
conmed_date: 7 mismatches
conmed_use: 1 mismatches
conmed_use_code: 1 mismatches
*/

/*
rename reason_1 jan2025_reason_1
rename reason_1_code jan2025_reason_1_code 
merge 1:1 subject_number c_effective_event_date conmed_section conmed_name_code conmed_status using "temp\test_conmeds", keepus(reason_1 reason_1_code)

    Result                           # of obs.
    -----------------------------------------
    not matched                         6,324
        from master                     6,253  (_merge==1)
        from using                         71  (_merge==2)

    matched                         1,901,440  (_merge==3)
    -----------------------------------------


br full_version subject_number c_effective_event_date conmed_section conmed_name_code conmed_status if _m==1 

tab full_version if _m==1, m
tab conmed_name if _m==1,m 
tab conmed_section if _m==1,m 

tab conmed_section if _m==3,m
*br subject_number c_effective_event_date conmed_section conmed_name_code conmed_status reason_1 dec2024_reason_1 reason_1_code dec2024_reason_1_code if reason_1_code !=dec2024_reason_1_code & _m==3 

rename reason_1 dec2024_reason_1
rename reason_1_code dec2024_reason_1_code 

groups jan2025_reason_1 jan2025_reason_1_code dec2024_reason_1 dec2024_reason_1_code, missing ab(16)
*//*
  |                   subject doing well (DW)                260                     patient doing well (DW)                  .       789      0.04 |
  |                   subject preference (PP)                270                     patient preference (PP)                  .      1317      0.07 |

preserve 
keep if nov2024_reason_1_code !=dec2024_reason_1_code & _m==3 
list subject_number c_effective_event_date conmed_section conmed_name_code conmed_status nov2024_reason_1 dec2024_reason_1 nov2024_reason_1_code dec2024_reason_1_code in 1/20, noobs ab(22)
restore 
*/*
erase temp\test_conmeds.dta // 2025-01-09 keep the data for further testing 

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
// 2025-02-04 Victoria: (dw_event_instance_uid)It has been replaced with c_dw_event_instance_key which is a persistent unique identifier (will not change value with each build).
keep site_number subject_number study_acronym source_acronym c_provider_id c_effective_event_date full_version c_dw_event_instance_key dw_event_type_acronym visitdate visit_date 

*unique dw_event_instance_uid 
unique c_dw_event_instance_key

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 

*list subject_number study_source_acronym c_effective_event_date dw_event_type_acronym if  subject_number=="093010805" | subject_number=="147010028", noobs ab(30) 

*drop if subject_number=="093010805" | subject_number=="147010028" // ticket 502 these two subjects only have exit form in EDC, no visits 

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 
save temp\temp_event_instance, replace 

// this data includes all office visits and any event forms 
use "$pdata\\bv_raw\bv_event_instances", clear  

tab dw_event_type_acronym if visit_date!="" 
tab dw_event_type_acronym if visit_date=="" 

gen visitdate=date(visit_date, "YMD") // visit_date is true subject en/fu visit date 
format visitdate %tdCCYY-NN-DD  
drop if visitdate==.
destring site_number full_version, replace 
*drop if site_number>=997 

drop  if strpos(dw_event_type_acronym, "TAE") | dw_event_type_acronym=="PREG" | dw_event_type_acronym=="EXIT" | visitdate==. 
*dw_event_instance_uid
keep site_number subject_number study_acronym source_acronym c_provider_id c_effective_event_date full_version c_dw_event_instance_key  dw_event_type_acronym visitdate visit_date 

unique c_dw_event_instance_key
//dw_event_instance_uid 

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 

*list subject_number study_source_acronym c_effective_event_date dw_event_type_acronym if  subject_number=="093010805" | subject_number=="147010028", noobs ab(30) 

*drop if subject_number=="093010805" | subject_number=="147010028" // ticket 502 these two subjects only have exit form in EDC, no visits 

sort subject_number visitdate dw_event_type_acronym 
by subject_number visitdate: drop if _n>1 

unique subject_number visitdate 

corcf * using temp\temp_event_instance, id(subject_number visitdate)
/*
note: master has 510720 observations; using has 511970 observations
Comparison of common IDs follows
c_dw_event_instance_key: 158 mismatches
study_acronym: 20 mismatches
source_acronym: 126 mismatches
c_provider_id: 12 mismatches
full_version: 139 mismatches
*/

merge 1:1 subject_number visitdate using temp\temp_event_instance, keepus(visitdate)
codebook visitdate if _m==2 //[30jan2024,28mar2025] // will clean using created/modified date if visitdate is out of range

use "$pdata\bv_raw\bv_exits", clear 

unique subject_number c_effective_event_date study_acronym source_acronym 

duplicates drop subject_number c_effective_event_date study_acronym source_acronym, force 
save temp\test_exits.dta, replace 

use bv_raw\bv_exits, clear
 
duplicates drop subject_number c_effective_event_date study_acronym source_acronym, force

corcf * using "temp\test_exits", id(subject_number c_effective_event_date study_acronym source_acronym) 
/*
note: master has 42994 observations; using has 42935 observations
c_is_sameday_fu_after_en: does not exist in using
c_is_enrollment_after_fu: does not exist in using
c_is_same_day_visit2: does not exist in using
Comparison of common IDs follows
c_dw_event_instance_key: 4 mismatches
c_provider_id: 1 mismatches
c_edc_event_instance_key: 4 mismatches
c_is_suppressed_exit: 2862 mismatches
c_event_created_date: 4 mismatches
c_event_last_modified_date: 109 mismatches
additional_comments: 3 mismatches
death_hospital_setting: 1 mismatches
death_hospital_setting_code: 1 mismatches
death_related_ra_tx: 1 mismatches
death_related_ra_tx_code: 1 mismatches
event_bio_exp_since_coll: 2 mismatches
event_bio_exp_since_coll_code: 2 mismatches
reason_death_dt: 3 mismatches
reason_discontinuation: 1 mismatches
reason_discontinuation_code: 1 mismatches
reason_discontinuation_oth_spec: 2 mismatches
reason_fu_last_contact_dt: 1 mismatches
*/

*merge 1:1 subject_number c_effective_event_date c_edc_event_instance_key using "$pdata\bv_raw\bv_exits" 
use "$pdata\bv_raw\bv_comorbidities", clear
mdesc *, ab(32)
unique subject_number comor_type comor_type_txt onset_date location location_txt

use "bv_raw\bv_comorbidities", clear 
mdesc *, ab(32)
unique subject_number comor_type comor_type_txt onset_date location location_txt

use "$pdata\bv_raw\bv_infections", clear
mdesc *, ab(32)

use "bv_raw\bv_infections", clear
mdesc *, ab(32)
/////////// testing for clean tables 




log using temp\1_5_exit_test.log, replace 
use clean_table\1_5_exit_$datacut, clear 
unique subject_number exit_form_dt
corcf * using "$pdata\clean_table\1_5_exit_$pdatacut", id(subject_number exit_form_dt)


cap log close 
log using temp\test_longitudinal_visit_data.log, replace 
use bv_raw\bv_longitudinal_visit_data, clear 
unique subject_number c_effective_event_date 
mdesc subject_number c_effective_event_date
/**************************************************

log using temp\test_longitudinal.log, replace 
use "temp\bv_longitudinal_clean.dta", clear 
corcf * using "$pdata\temp\bv_longitudinal_clean", id(subject_number visitdate) 
log close 

cap log close 
log using temp\test_subjects.log, replace 
use clean_table\1_1_subjects, clear 
drop dw_event_instance_uid most_recent_visit_date
corcf * using "$pdata\clean_table\1_1_subjects", id(subject_number)  
log close 


cap log close 
log using temp\test_allvisits.log, replace 
use clean_table\1_2_allvisits, clear 
drop dw_event_instance_uid 
corcf * using "$pdata\clean_table\1_2_allvisits", id(subject_number visitdate) 

corcf *_jts_28 md_global_assess using "$pdata\clean_table\1_2_allvisits", id(subject_number visitdate) verbose 
log close 






log using test_keyvisit.log, replace 

use 2_3_keyvisitvars, clear 
drop dw_event_instance_uid 
drop c_event_created_date c_event_last_modified_date 
corcf  * using "$pdata\2_3_keyvisitvars", id(subject_number visitdate) 
log close 


use clean_table\1_6_drugrecord, clear 
unique subject_number drug_key drug_status drug_date dose_value freq_value 

sort subject_number drug_key drug_status drug_date dose_value freq_value route_code reason_1_code reason_2_code reason_3_code dw_event_type_acronym 
by subject_number drug_key drug_status drug_date dose_value freq_value: gen vn=_n 
by subject_number drug_key drug_status drug_date dose_value freq_value: gen vN=_N 

tab vN if vn==1

br subject_number drug_key drug_status drug_date dose_value freq_value route reason_1 reason_2 reason_3 dw_event_type_acronym  vn if vN==2 



***********************

* bv_medical_problems_pretm 

odbc query dwh, schema verbose

odbc load, table(ra_20240712.bv_medical_problems_pretm) dsn(dwh) noquote clear 

save "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\2024\2024-07-01\bv_raw\bv_medical_problems_pretm_20240712.dta", replace 



use "C:\Users\yshan\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\ODBC\dwh_db\2024-06-20\bv_medical_problems_pretm", clear 
recast str medprobs_name 
save temp\temp_medprob_pretm, replace 


use "C:\Users\yshan\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\2024\2024-07-01\bv_raw\bv_medical_problems_pretm", clear 

recast str medprobs_name 

merge 1:1 subject_number c_effective_event_date medprobs_name using temp\temp_medprob_pretm 

tab medprobs_name _m if _m<3

groups medprobs_name _m if _m<3





