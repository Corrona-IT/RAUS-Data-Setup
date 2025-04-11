
/**********************************************************************************************

Code Name: 1_7_allcomor
Purpose:  generate an allcomor tall dataset one row per event per subject
Programmer: Nicole Foster/Bernice Gershenson
Modification log:
Input Datasets: bv_comorbidities
Final Datasets: allcomor 

Date: 11/27/2023 
updated 2024-05-03 

***********************************************************************************************/
* ENG miss map skin cancer type which mapped in cancer detail data, we bring it into bv_comorbidities until ENG mapped it 
/*
use bv_raw\bv_tae_can_details, clear 
keep if skin_cancer=="yes" & confirmed_code==1 
keep if skin_cancer_type_code 
unique subject_number c_effective_event_date skin_cancer_type 
keep subject_number dw_event_instance_uid c_effective_event_date skin_cancer_type skin_cancer_type_code 
sort subject_number dw_event_instance_uid 
unique dw_event_instance_uid   
save temp\temp_tae_nmel_type, replace 
*/

*~~~~~~~~~~~ Bring in datasets
* ying added
// 2024-12-04: have to make sure two data are in the same date schema so they have the same dw_event_instance_uid

use "bv_raw\bv_comorbidities", clear 
// 2025-02-04 : It has been replaced with c_dw_event_instance_key which is a persistent unique identifier (will not change value with each build).
*merge m:1 dw_event_instance_uid using "bv_raw\bv_event_instances", keepus(visit_date) 
merge m:1 c_dw_event_instance_key using "bv_raw\bv_event_instances", keepus(visit_date)

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       611,903
        from master                         0  (_merge==1)
        from using                    611,903  (_merge==2)

    matched                           185,229  (_merge==3)
    -----------------------------------------
*/

drop if _m==2 
drop _m 

drop if site_number=="999" | site_number=="998" | site_number=="1440" |site_number=="1019" // test sites 

gen visitdate=date(visit_date, "YMD")
replace visitdate=date(c_effective_event_date, "YMD") if visitdate==. & strpos(c_effective_event_date, "X")==0 
replace visitdate=dofc(c_event_created_date) if visitdate==. 
format visitdate %tdCCYY-NN-DD 
// 2024-12-04 
codebook visitdate // [01jan1900,30jan2025]

assert visitdate<. 
********************************************

** remove test records - 1/11/2024 - Ying requested to keep these test sites in 
drop if site_number=="999" | site_number=="998" | site_number=="1440" |site_number=="1019" | site_number=="997"

** create event_uid to identify specific events later within code 
gen event_uid = _n

// 2025-03-04: LG, using created or modified dates for visitdates that are out of range 
count if visitdate>d($cutdate) // 20 

// 2025-04-02 checking a subject previously had visitdate of 2025-03-28 in base view back in March. last modified date changed from 03-03 to 03-31.
for any RA-252-0006: list subject_number visitdate c_event_created_date c_event_last_modified_date if subject_number=="X", noobs ab(16)
/*
  +-----------------------------------------------------------------------+
  | subject_number    visitdate   c_event_created_~e   c_event_last_mod~e |
  |-----------------------------------------------------------------------|
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   31mar2025 20:50:58 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   31mar2025 20:50:58 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   31mar2025 20:50:58 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   31mar2025 20:50:58 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   31mar2025 20:50:58 |
  +-----------------------------------------------------------------------+
*/
list subject_number visitdate c_event_created_date c_event_last_modified_date if visitdate>d($cutdate), noobs ab(16) 
/*
  +-----------------------------------------------------------------------+
  | subject_number    visitdate   c_event_created_~e   c_event_last_mod~e |
  |-----------------------------------------------------------------------|
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-28   03mar2025 17:34:29   03mar2025 19:50:28 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  +-----------------------------------------------------------------------+
*/
gen created_date=dofc(c_event_created_date)
format created_date %tdCCYY-NN-DD
replace visitdate=created_date if visitdate>15+d($cutdate)
list subject_number visitdate c_effective_event_date c_event_created_date c_event_last_modified_date if visitdate>d($cutdate), noobs ab(16)
/*
  +-----------------------------------------------------------------------+
  | subject_number    visitdate   c_event_created_~e   c_event_last_mod~e |
  |-----------------------------------------------------------------------|
  |    RA-252-0006   2025-03-03   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-03   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-03   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-03   03mar2025 17:34:29   03mar2025 19:50:28 |
  |    RA-252-0006   2025-03-03   03mar2025 17:34:29   03mar2025 19:50:28 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |-----------------------------------------------------------------------|
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-252-0007   2025-03-03   03mar2025 22:46:04   04mar2025 00:19:26 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  |    RA-254-0079   2025-03-03   03mar2025 22:28:54   04mar2025 03:54:29 |
  +-----------------------------------------------------------------------+

*/
*~~~~~~~~~~~ Impute onset date - NEED TO UPDATE BASED ON DISCUSSION

** keep onset_date variable as-is so we retain the original variable - keep raw and separate out month/year/day 
/*
clonevar onset_date_impute = onset_date // may change variable name to awarenessdate 
replace onset_date_impute = c_effective_event_date if missing(onset_date_impute) & !missing(c_effective_event_date)
gen impute_date_flg=1 if missing(onset_date) & !missing(onset_date_impute) // flag records with imputed onset date

gen onset_year_impute = strlower(substr(onset_date_impute,1,4))
assert !missing(onset_year_impute) // should have at least a year 
gen onset_month_impute = strlower(substr(onset_date_impute,6,2))
replace onset_month_impute="" if onset_month_impute=="xx" // change 'xx' missing month to missing 
gen onset_day_impute = strlower(substr(onset_date_impute,9,2))
replace onset_day_impute="" if onset_day_impute=="xx" // change 'xx' missing day to missing 

*/


*~~~~~~~~~~~ Standardize comor_type

** create flag for MD vs TAE record - may update and set flags for these (md 1st, tae 2nd, etc.) - come back to think about this
* later may have value for "both" after de-duplicate 
gen str4 md_tae = "md" if inlist(dw_event_type_acronym, "EN", "FU", "RFU") 
replace md_tae = "tae" if strpos(dw_event_type_acronym, "TAE")>0


**** create new comor_type variable that uses comor_type_txt if missing comor_type and standardizes comor_types where appropriate 

** generate trimmed, lower case outputs (particularly for write-in of comor_type_txt)
* NOTE: TAE inputs are mainly into comor_type_txt and are write-ins - these need to be cleaned and standardized to MD values
* NOTE: MD 'other' values are displayed in comor_type_txt and will also be cleaned to see if values align with another checkbox 
gen comor_type_new = strtrim(strlower(comor_type))
gen comor_type_txt_new = strtrim(strlower(comor_type_txt))
gen location_txt_new = strtrim(strlower(location_txt))
gen comor_type_code_new = comor_type_code 


*** create duplicate rows for comor_type_txt that indicate more than 1 comorbidity
** clean duplicates so 1 record per comorbidity 
* - create flag for each checkbox on Version 15 form using comor_type_txt_new - match to MD where can and create new categories based on V15 if nothing in MD (nothing already in comor_type_new)
* - create separate dataset for each checkbox flag (include dataset for 'other') - separate out dataset that does not have comor_type_txt_new value to keep aside and append to the checkbox datasets 
* - update comor_type_new based on these checkboxes (ensure consistent comor_type_new to MD version 15) 
* - if not in refined category, mark as 'other cardiovascular event'/other malignancy
* - append datasets 

* create dataset that does not have comor_type_txt_new and a dataset that must have comor_type_txt_new - this will be appended later 
preserve
keep if missing(comor_type_txt_new)
save "temp\data\no_txt", replace 
restore 

preserve
keep if !missing(comor_type_txt_new)
save "temp\data\has_txt", replace 
restore 

** metabolic 
* - hyperlipidemia 
preserve 
keep if strpos(comor_type_txt_new, "hyperlipida")>0
replace comor_type_new = "hyperlipidemia"
replace comor_type_code_new = 11120
save "temp\data\hyperlipidemia", replace 
restore 

* - diabetes (not have type I or type II) - just report overall diabetes (can look at comor_type_txt to get more details if needed for a project)
preserve
keep if strpos(comor_type_txt_new, "diabetes")>0 & strpos(comor_type_txt_new, "pre-diabetes")==0 & strpos(comor_type_txt_new, "prediabetes")==0
replace comor_type_new = "diabetes mellitus"
replace comor_type_code_new = 21013
save "temp\data\diabetes.dta", replace 
restore 

* - osteopenia 
preserve 
keep if strpos(comor_type_txt_new, "osteopenia")>0
replace comor_type_new = "osteopenia" 
replace comor_type_code_new = 21030 
save "temp\data\osteopenia", replace 
restore 

* - osteoporosis
preserve 
keep if strpos(comor_type_txt_new, "osteoporosis")>0
replace comor_type_new = "osteoporosis"
replace comor_type_code_new = 21030 // data dictionary has same code as osteopenia 
save "temp\data\osteoporosis", replace 
restore 

* - other metabolic condition  - added 05032024
preserve
keep if strpos(comor_type_txt_new, "metabolic")>0
replace comor_type_new = "metabolic condition other (specify)"
replace comor_type_code_new = 21900
save "temp\data\metaoblic_oth", replace 
restore 



** cvd 
* - hypertension (not splitting by serious/non-serious - can review txt if needed to produce - will need PV input)
preserve 
keep if strpos(comor_type_txt_new, "hypertension")>0 | strpos(comor_type_txt_new, "htn")>0
replace comor_type_new = "hypertension (htn)"
replace comor_type_code_new = 11110
save "temp\data\hypertension", replace 
restore

* - cardiac resvascularization procedure (coronary artery bypass graft (cabg) / stent / angioplasty) - traditionally listed together, so difficult to separate and not included as separate term - can identify through txt field if needed 
preserve 
keep if strpos(comor_type_txt_new, "cabg")>0 | strpos(comor_type_txt_new, "angioplasty")>0 | strpos(comor_type_txt_new, "cardiac revasc")>0 
replace comor_type_new = "cardiac revascularization procedure (cabg, stent, angioplasty)"
replace comor_type_code_new = 12530
save "temp\data\revasc", replace 
restore 

* - ventricular arrhythmia 
preserve 
keep if (strpos(comor_type_txt_new, "vent")>0 & strpos(comor_type_txt_new, "arrhy")>0) | comor_type_txt_new=="vent arrythmia"
replace comor_type_new = "ventricular arrhythmia"
replace comor_type_code_new = 11050
save "temp\data\vent_arrhythmia", replace 
restore 

* - myocardial infarction 
preserve 
keep if strpos(comor_type_txt_new, "myocard")>0 | strpos(comor_type_txt_new, "heart attack")>0 | comor_type_txt_new=="mi" | comor_type_txt_new=="cad and mi"
replace comor_type_new = "myocardial infarction (mi)"
replace comor_type_code_new = 11150
save "temp\data\mi", replace
restore 

* - acute coronary syndrome 
preserve 
keep if strpos(comor_type_txt_new, "acute coronary s")>0 | comor_type_txt_new== "acute cor. syndrome" 
replace comor_type_new = "acute coronary syndrome (acs)"
replace comor_type_code_new = 11020
save "temp\data\acs", replace 
restore

* - unstable angina 
preserve
keep if strpos(comor_type_txt_new, "angina")>0 & strpos(comor_type_txt_new, "unstable")>0
replace comor_type_new = "angina unstable"
replace comor_type_code_new = 11033
save "temp\data\unstable_angina", replace
restore  

* - coronary artery disease 
preserve
keep if strpos(comor_type_txt_new, "coronary artery disease")>0 | (strpos(comor_type_txt_new, "cad")>0 & strpos(comor_type_txt_new, "remicade")==0 )
replace comor_type_new = "coronary artery disease (cad)"
replace comor_type_code_new = 11080
save "temp\data\cad", replace 
restore 

* - congestive heart failure
preserve 
keep if strpos(comor_type_txt_new, "chf")>0 | strpos(comor_type_txt_new, "congestive heart failure")>0
replace comor_type_new = "congestive heart failure (chf)"  
replace comor_type_code_new = 11090
save "temp\data\chf", replace 
restore 

* - stroke 
preserve 
keep if strpos(comor_type_txt_new, "stroke")>0 & strpos(comor_type_txt_new, "heat stroke")==0
replace comor_type_new = "stroke"
replace comor_type_code_new = 12050
save "temp\data\stroke", replace 
restore 

* - tia 
preserve 
keep if strpos(comor_type_txt_new, " tia")>0 & strpos(comor_type_txt_new , "dementia")==0 & strpos(comor_type_txt_new , "tial")==0
replace comor_type_new = "transient ischemic attack (tia)" 
replace comor_type_code_new = 12055
save "temp\data\tia", replace 
restore 

* - other cardiovascular condition - 05032024: added 
preserve
keep if strpos(comor_type_txt_new, "cardiovascular")>0 
replace comor_type_new = "cardiovascular condition other (specify)"
replace comor_type_code_new = 11910
save "temp\data\cardio_oth", replace 
restore 

* - dvt 
preserve  
keep if strpos(comor_type_txt_new, "dvt")>0 & strpos(comor_type_txt_new, "negative for dvt")==0 & strpos(comor_type_txt_new, "history of dvt")==0 & strpos(comor_type_txt_new, "no dvt")==0
replace comor_type_new = "deep vein thrombosis (dvt)"
replace comor_type_code_new = 12060
save "temp\data\dvt", replace 
restore 

* - pulmonary embolism 
preserve
keep if (strpos(comor_type_txt_new, "pulm")>0 & strpos(comor_type_txt_new, "emb")>0) | inlist(comor_type_txt_new, "pe", "pe 06")
replace comor_type_new = "pulmonary embolism (pe)"
replace comor_type_code_new = 12061
save "temp\data\pe", replace 
restore 

* - other venous thromboembolism 
preserve 
keep if strpos(comor_type_txt_new, "venous")>0 & strpos(comor_type_txt_new, "thromboe")>0
replace comor_type_new = "venous thromboembolism (vte) other (specify)" // 05032024: updated due to comor_type_new update
replace comor_type_code_new = 12069 // 05032024: added 
save "temp\data\oth_vte", replace 
restore 

* - peripheral arterial disease
preserve 
keep if strpos(comor_type_txt_new, "periph")>0 & strpos(comor_type_txt_new, "arter")>0 & strpos(comor_type_txt_new, "dis")>0
replace comor_type_new = "peripheral arterial disease"
replace comor_type_code_new = 12030
save "temp\data\periph_art_dis", replace 
restore 

* - peripherial arterial thromboembolic event 
preserve 
keep if (strpos(comor_type_txt_new, "periph")>0 & strpos(comor_type_txt_new, "thrombo")>0) | strpos(comor_type_txt_new, "pat ")>0
replace comor_type_new = "peripheral arterial thromboembolic event"
replace comor_type_code_new = 12080
save "temp\data\pat", replace 
restore 

* - urgent peripheral arterial revascularization 
preserve 
keep if strpos(comor_type_txt_new, "urgent")>0 & strpos(comor_type_txt_new, "periph")>0 & strpos(comor_type_txt_new, "revasc")>0
replace comor_type_new = "urgent peripheral arterial revascularization"
replace comor_type_code_new = 12510
save "temp\data\upar", replace 
restore 

* - peripheral ischemia or gangrene 
preserve 
keep if (strpos(comor_type_txt_new, "ischemia")>0 & strpos(comor_type_txt_new, "periph")>0) | strpos(comor_type_txt_new, "gangrene")>0 
replace comor_type_new = "peripheral ischemia or gangrene (necrosis)"
replace comor_type_code_new = 12040
save "temp\data\periph_isch_gang", replace 
restore 

* - other vascular condition (combines serious and non-serious) - 05032024: added
preserve
keep if strpos(comor_type_txt_new, "vascular")>0 & strpos(comor_type_txt_new, "revascular")==0 & strpos(comor_type_txt_new, "cardiovascular")==0
replace comor_type_new = "vascular condition other serious (specify)"
replace comor_type_code_new = 12092
save "temp\data\vascular_oth", replace 
restore 



** respiratory 
* - copd (combined non-serious and exacerbation serious)
preserve 
keep if strpos(comor_type_txt_new, "copd")>0
replace comor_type_new = "chronic obstructive pulmonary disease (copd)"
replace comor_type_code_new = 30080
save "temp\data\copd", replace 
restore 

* - emphysema
preserve 
keep if strpos(comor_type_txt_new, "emphysema")>0
replace comor_type_new = "emphysema" 
replace comor_type_code_new = 30030 // 05032023: added 
save "temp\data\emphysema", replace 
restore 

* - interstitial lung disease/pulmonary fibrosis 
preserve 
keep if strpos(comor_type_txt_new, "interstitial lung")>0 | strpos(comor_type_txt_new, "pulmonary fibrosis")>0
replace comor_type_new = "interstitial lung disease / pulmonary fibrosis"
replace comor_type_code_new = 30090
save "temp\data\int_lung", replace 
restore 

* - asthma 
preserve 
keep if strpos(comor_type_txt_new, "asthma")>0 
replace comor_type_new = "asthma" 
replace comor_type_code_new = 30070
save "temp\data\asthma", replace 
restore 

* - other respiratory - 05032024: added
preserve 
keep if strpos(comor_type_txt_new, "respiratory")>0 & strpos(comor_type_txt_new, "copd")==0 & strpos(comor_type_txt_new, "allergic")==0
replace comor_type_new = "respiratory condition other (specify)"
replace comor_type_code_new = 30900
save "temp\data\respiratory_oth", replace 
restore 


** drug-induced reactions 
* - drug hypersensitivity

/*
// 2024-10-30 adding anaphylaxis? 
1.	Email from Isaias on 10-21-2024:For RA specifically, CERTAIN & PRETM edc values ‘Anaphylaxis’ and ‘Anaphylaxis {TAE}’ will now be coded to 17090 within the ae_comor lookup.
2.  Team chat with Isais 2024-10-31: The Anaphylaxis change will be in 20241201 instead and there are no other changes expected for 20241101
v2024-11-01 . 
groups comor_type_code comor_type_txt comor_type_txt_new if strpos(comor_type_txt_new,"anaphylaxis"), missing ab(20)

  +---------------------------------------------------------------------------------------------------------------------------------+
  | comor_type_code                                 comor_type_txt                             comor_type_txt_new   Freq.   Percent |
  |---------------------------------------------------------------------------------------------------------------------------------|
  |           99920                                    Anaphylaxis                                    anaphylaxis       4     40.00 |
  |           99920   Anaphylaxis (not injection/infusion related)   anaphylaxis (not injection/infusion related)       1     10.00 |
  |           99920                   Anaphylaxis 99 Other Drug 05                   anaphylaxis 99 other drug 05       1     10.00 |
  |           99920                                    anaphylaxis                                    anaphylaxis       3     30.00 |
  |           99923               anaphylaxis to blood transfusion               anaphylaxis to blood transfusion       1     10.00 |
  +---------------------------------------------------------------------------------------------------------------------------------+

. groups comor_type_code comor_type_txt comor_type_txt_new if strpos(comor_type_txt_new,"hypersensitivity reaction"), missing ab(20)

  +-------------------------------------------------------------------------------------------+
  | comor_type_code              comor_type_txt          comor_type_txt_new   Freq.   Percent |
  |-------------------------------------------------------------------------------------------|
  |           99920   hypersensitivity reaction   hypersensitivity reaction       1    100.00 |
  +-------------------------------------------------------------------------------------------+

. groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17041, missing ab(20)

  +----------------------------------------------------------------------------------------------------------------------+
  | comor_type_code                                   comor_type   comor_type_txt   comor_type_txt_new   Freq.   Percent |
  |----------------------------------------------------------------------------------------------------------------------|
  |           17041   drug hypersensitivity reaction anaphylaxis                                            25    100.00 |
  +----------------------------------------------------------------------------------------------------------------------+

. groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17090, missing ab(20)
no observations
. groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17040, missing ab(20)

  +-----------------------------------------------------------------------------------------------------------------------------+
  | comor_type_code                                          comor_type   comor_type_txt   comor_type_txt_new   Freq.   Percent |
  |-----------------------------------------------------------------------------------------------------------------------------|
  |           17040   drug hypersensitivity reaction (specify severity)                                           400    100.00 |
  +-----------------------------------------------------------------------------------------------------------------------------+

groups comor_type_code comor_type_txt comor_type_txt_new if strpos(comor_type_txt_new,"anaphylaxis"), missing ab(20)
groups comor_type_code comor_type_txt comor_type_txt_new if strpos(comor_type_txt_new,"hypersensitivity reaction"), missing ab(20)
groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17041, missing ab(20)
*groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17090, missing ab(20) // no obs 
groups comor_type_code comor_type comor_type_txt comor_type_txt_new if comor_type_code==17040, missing ab(20)
//2024-11-01 LG hold this part
*/
// 2024-12-04 LG added back, but no change is expected 
preserve 
keep if strpos(comor_type_txt_new, "hypersensitivity reaction")>0 |strpos(comor_type_txt_new, "anaphylaxis")>0  
replace comor_type_new = "drug hypersensitivity reaction (specify severity)"
replace comor_type_code_new = 17040
save "temp\data\ana", replace 
restore 

* - drug-induced SLE 
preserve 
keep if (strpos(comor_type_txt_new, "drug")>0 & strpos(comor_type_txt_new, "induce")>0 & strpos(comor_type_txt_new, "sle")>0) | strpos(comor_type_txt_new, "drug induced lupus")>0
replace comor_type_new = "drug-induced sle"
replace comor_type_code_new = 10131
save "temp\data\sle", replace 
restore 


** malignancy 
* - breast cancer 
preserve 
keep if strpos(comor_type_txt_new, "breast")>0 & strpos(comor_type_txt_new, "ca")>0 & strpos(comor_type_txt_new, "construction")==0 & strpos(comor_type_txt_new, "mastectomy")==0
replace comor_type_new = "breast cancer" 
replace comor_type_code_new = 20010
save "temp\data\breast", replace 
restore 

* - lung cancer 
preserve 
keep if (strpos(comor_type_txt_new, "lung")>0 & strpos(comor_type_txt_new, "cancer")>0) | strpos(comor_type_txt_new, "lung ca")>0
replace comor_type_new = "lung cancer"
replace comor_type_code_new = 20080
save "temp\data\lung", replace 
restore 

* - colon cancer 
preserve
keep if strpos(comor_type_txt_new, "colon")>0 & strpos(comor_type_txt_new, "cancer")>0 & strpos(comor_type_txt_new, "pre-cancerious")==0
replace comor_type_new = "colon cancer" 
replace comor_type_code_new = 20040 // 05032024: added 
save "temp\data\colon", replace 
restore 

* - uterine cancer 
preserve 
keep if strpos(comor_type_txt_new, "uter")>0 & strpos(comor_type_txt_new, "cancer")>0
replace comor_type_new = "uterine cancer" // do not have this event yet in MD, so may need to re-assign value if MD value does not match - IMPUTED VALUE 
save "temp\data\uterine", replace 
restore 

* - cervical cancer 
preserve 
keep if strpos(comor_type_txt_new, "cervical")>0 & strpos(comor_type_txt_new, "cancer")>0 & strpos(comor_type_txt_new, "pre-cervical")==0
replace comor_type_new = "cervical cancer" 
replace comor_type_code_new = 20020 // 05032024: added 
save "temp\data\cervical", replace 
restore 

* - prostate cancer 
preserve 
keep if strpos(comor_type_txt_new, "prostate")>0 & strpos(comor_type_txt_new, "cancer")>0 & strpos(comor_type_txt_new, "non cancer")==0 & strpos(comor_type_txt_new, "non-cancerous")==0
replace comor_type_new = "prostate cancer"  
replace comor_type_code_new = 20120 // 05032024: added 
save "temp\data\prostate", replace 
restore 

* - leukemia 
preserve 
keep if strpos(comor_type_txt_new, "leukemia")>0
replace comor_type_new = "leukemia" 
replace comor_type_code_new = 20070 // 05032024: added 
save "temp\data\leukemia", replace 
restore 

* - lymphoma 
preserve 
keep if strpos(comor_type_txt_new, "lymphoma")>0 & strpos(comor_type_txt_new, "not lymphoma")==0
replace comor_type_new = "lymphoma"
replace comor_type_code_new = 20090
save "temp\data\lymphoma", replace 
restore 

* - multiple myeloma 
preserve 
keep if strpos(comor_type_txt_new, "myeloma")>0
replace comor_type_new = "multiple myeloma" 
replace comor_type_code_new = 20100 // 05032024: updated 
save "temp\data\myeloma", replace 
restore 

* - non-melanoma skin cancer basal cell / squamous cell - comor_type does not distinguish, so will create category combining and can use comor_type_txt_new to whittle down if needed 
preserve 
keep if strpos(comor_type_txt_new, "nmsc")>0 | (strpos(comor_type_txt_new, "non")>0 & strpos(comor_type_txt_new, "melanoma")>0 & strpos(comor_type_txt_new, "cancer")>0) | (strpos(comor_type_txt_new, "basal")>0 ///
             & strpos(comor_type_txt_new, "skin")>0) | (strpos(comor_type_txt_new, "squamous")>0 & strpos(comor_type_txt_new, "skin")>0)
replace comor_type_new = "non-melanoma skin cancer (nmsc) squamous cell / basal cell"
replace comor_type_code_new = 20142
save "temp\data\nmsc", replace 
restore 

* - melanoma skin cancer 
preserve 
keep if strpos(comor_type_txt_new, "melanoma")>0 & strpos(comor_type_txt_new, "pre-melanoma")==0 & strpos(comor_type_txt_new, "non")==0 & strpos(comor_type_txt_new, "not melanoma")==0
replace comor_type_new = "melanoma skin cancer"
replace comor_type_code_new = 20145
save "temp\data\melanoma", replace 
restore 

* - other malignancy - classified below for TAE that do not match category 


* - pre-malignancy - 05032024: added 
preserve 
keep if strpos(comor_type_txt_new, "pre-malignancy")>0 | strpos(comor_type_txt_new, "pre malignancy")>0
replace comor_type_new = "pre-malignancy (specify)"
replace comor_type_code_new = 20700 
save "temp\data\malignancy_pre", replace 
restore 


** gi/hepatic 
* - peptic ulcer
preserve 
keep if strpos(comor_type_txt_new, "peptic ulcer")>0
replace comor_type_new = "peptic ulcer"
replace comor_type_code_new = 14040
save "temp\data\peptic", replace 
restore 

* - gi perforation
preserve 
keep if (strpos(comor_type_txt_new, "perforation")>0 & strpos(comor_type_txt_new, "gi")>0) | (strpos(comor_type_txt_new, "perforation")>0 & strpos(comor_type_txt_new, "bowel")>0) | ///
             (strpos(comor_type_txt_new, "perforation")>0 & strpos(comor_type_txt_new, "intestine")>0) 
replace comor_type_new = "gastrointestinal (gi) perforation"
replace comor_type_code_new = 14020
save "temp\data\gi_perf", replace
restore 


* - other GI disorder - added 05032024 
preserve 
keep if strpos(comor_type_txt_new, "gastroin")>0 & strpos(comor_type_txt_new, "perforation")==0 & strpos(comor_type_txt_new, "peptic ulcer")==0 & strpos(comor_type_txt_new, "hemor")==0
replace comor_type_new = "gastrointestinal (gi) disease other (specify)"
replace comor_type_code_new = 14900
save "temp\data\gi_other", replace 
restore


* - hepatic event requiring biopsy / serious
preserve 
keep if (strpos(comor_type_txt_new, "hepatic")>0 & strpos(comor_type_txt_new, "no hosp")==0 & strpos(comor_type_txt_new, "intrahepatic")==0) | strpos(comor_type_txt_new, "liver biopsy")>0 | ///
             (strpos(comor_type_txt_new, "cirrhosis")>0 & strpos(comor_type_txt_new, "liver")>0)
replace comor_type_new = "hepatic event requiring biopsy or serious (specify)" // 05032024: updated 
replace comor_type_code_new = 16114
save "temp\data\hepatic_biop", replace
restore 


* - hepatic event increased LFTs >3x ULN) - code as liver disease for now (to match MD) 
preserve 
keep if strpos(comor_type_txt_new, "liver disease")>0  |  strpos(comor_type_txt_new, "liver funct")>0 | (strpos(comor_type_txt_new, "abnormal results")>0 & strpos(comor_type_txt_new, "liver")>0) | ///
            strpos(comor_type_txt_new, "elevated liver")>0 | strpos(comor_type_txt_new, "hepatitis")>0 | strpos(comor_type_txt_new, "liver enzyme")>0
replace comor_type_new = "liver disease"
replace comor_type_code_new = 16000
save "temp\data\liver_disease", replace 
restore			

* - drug induced liver injury serious - added 05032024 - IMPUTED VALUE (not yet in dataset for comor_type_new value)
preserve 
keep if strpos(comor_type_txt_new, "drug")>0 & (strpos(comor_type_txt_new, "liver")>0 | strpos(comor_type_txt_new, "hepatic")>0) & strpos(comor_type_txt_new, "no drug")==0
replace comor_type_new = "drug-induced liver injury serious (specify)"
replace comor_type_code_new = . // NEED THIS VALUE 
save "temp\data\drug_ind_liver", replace 
restore 


* - hepatic event non-serious 
preserve 
keep if (strpos(comor_type_txt_new, "fatty")>0 & strpos(comor_type_txt_new, "liver")>0) | strpos(comor_type_txt_new, "liver cyst")>0 | strpos(comor_type_txt_new, "liver hemang")>0 | ///
            strpos(comor_type_txt_new, "liver lesion")>0
replace comor_type_new = "hepatic event other non-serious (specify)" // 05032024: updated 
replace comor_type_code_new = 16112
save "temp\data\hepatic_nonser", replace 
restore	


** musculoskeletal 
* - osteoarthritis 
preserve 
keep if strpos(comor_type_txt_new, "osteoarthritis")>0
replace comor_type_new = "osteoarthritis"
replace comor_type_code_new = 22040 // updated 05032024 
save "temp\data\osteoarthritis", replace 
restore 

* - gout  
preserve 
keep if strpos(comor_type_txt_new, "gout")>0
replace comor_type_new = "gout"
replace comor_type_code_new = 10060
save "temp\data\gout", replace 
restore 

* - secondary sjogren's syndrome 
preserve 
keep if strpos(comor_type_txt_new, "sjogren")>0
replace comor_type_new = "secondary sjögren’s syndrome" // 05032024: updated
replace comor_type_code_new = 10120
save "temp\data\sjogren", replace 
restore

* - subcutaneous nodules - 05032024: updated 
preserve
keep if strpos(comor_type_txt_new, "nodules")>0 & strpos(comor_type_txt_new, "subcut")>0
replace comor_type_new = "subcutaneous nodules" 
replace comor_type_code_new = 10080
save "temp\data\sub_nodules", replace 
restore 


* - fracture  - combine serious and non-serious (how reported in comor_type_new)
preserve 
keep if strpos(comor_type_txt_new, "fracture")>0
replace comor_type_new = "fracture (specify location)"
replace comor_type_code_new = 22030
save "temp\data\fracture", replace 
restore 



** other conditions - make sure get all other conditions from comor_type_new not on version 15
* - psoriasis 
preserve 
keep if strpos(comor_type_txt_new, "psoriasis")>0
replace comor_type_new = "psoriasis (not arthritis)"
replace comor_type_code_new = 10141
save "temp\data\pso", replace 
restore 

* - anemia 
preserve 
keep if strpos(comor_type_txt_new, "anemia")>0
replace comor_type_new = "anemia"
replace comor_type_code_new = 15020
save "temp\data\anemia", replace 
restore 

* - anxiety  
preserve 
keep if strpos(comor_type_txt_new, "anxiety")>0
replace comor_type_new = "anxiety"
replace comor_type_code_new = 26010 // 05032024: added 
save "temp\data\anxiety", replace 
restore 


* - depression
preserve 
keep if strpos(comor_type_txt_new, "depression")>0
replace comor_type_new = "depression"
replace comor_type_code_new = 26020
save "temp\data\depression", replace 
restore 

* - suicidal thoughts (ideation)  
preserve 
keep if strpos(comor_type_txt_new, "suicid")>0 & (strpos(comor_type_txt_new, "thought")>0 | strpos(comor_type_txt_new, "ideat")>0)
replace comor_type_new = "suicidal thoughts (ideation)"
replace comor_type_code_new = 26032 // 05032024: added  
save "temp\data\suic_idea", replace 
restore 

* - self-injury -  not in comor_type_new yet, so create new category - no events yet - will need to re-evaluate as more version 15 come in - IMPUTED 
preserve 
keep if strpos(comor_type_txt_new, "self")>0 & (strpos(comor_type_txt_new, "injury")>0 | strpos(comor_type_txt_new, "harm")>0)
replace comor_type_new = "self injury"
replace comor_type_code_new = . // need this value 
save "temp\data\self_injury", replace 
restore 


* - suicide attempt 
preserve 
keep if strpos(comor_type_txt_new, "suicid")>0 & strpos(comor_type_txt_new, "attempt")>0 
replace comor_type_new = "suicide attempt"
replace comor_type_code_new = 26033 // 05032024: added 
save "temp\data\suic_attempt", replace 
restore

* - fibromyalgia 
preserve 
keep if strpos(comor_type_txt_new, "fibromyalgia")>0
replace comor_type_new = "fibromyalgia"
replace comor_type_code_new = 10050
save "temp\data\fibromyalgia", replace 
restore 

* - demyelinating disease  
preserve 
keep if strpos(comor_type_txt_new, "demyel")>0
replace comor_type_new = "demyelinating disease other"
replace comor_type_code_new = 23101 // 05032024: added 
save "temp\data\demyelinating", replace 
restore 


* - dementia 
preserve 
keep if strpos(comor_type_txt_new, "dementia")>0
replace comor_type_new = "dementia"
replace comor_type_code_new = 23080 // 05032024: added 
save "temp\data\dementia", replace 
restore 

* - hemiplegia or paraplegia - not in comor_type_new yet, so create new category - IMPUTED 
preserve 
keep if strpos(comor_type_txt_new, "hemiplegia")>0 | strpos(comor_type_txt_new, "paraplegia")>0
replace comor_type_new = "hemiplegia or paraplegia"
replace comor_type_code_new = . // need this value 
save "temp\data\hemi_para", replace 
restore 

* - other neurological disorder - combine non-serious and serious - may need PV to give us specific terms 
preserve 
keep if strpos(comor_type_txt_new, "neurologic")>0
replace comor_type_new = "neurological disorder other (specify)"
replace comor_type_code_new = 23900
save "temp\data\neuro_other", replace 
restore 

* - chronic kidney disease - combine mild and moderate/severe - may need PV to give us specific terms 
preserve 
keep if (strpos(comor_type_txt_new, "kidney")>0 | strpos(comor_type_txt_new, "renal")>0) & strpos(comor_type_txt_new, "disease")>0
replace comor_type_new = "chronic kidney disease (ckd) - mild renal impairment (gfr 20-50 ml/min)" // 05032024: updated 
replace comor_type_code_new = 27041 // 05032024: added 
save "temp\data\kidney_disease", replace 
restore 


* - acute kidney injury - combine mild and moderate/severe - may need PV to give us specific terms - not in comor_type_new yet, so create new category 
preserve 
keep if (strpos(comor_type_txt_new, "kidney")>0 | strpos(comor_type_txt_new, "renal")>0) & strpos(comor_type_txt_new, "injury")>0
replace comor_type_new = "acute kidney injury (aki) - mild renal impairment (gfr 20-50 ml/min)" // 05032024: updated 
replace comor_type_code_new = 27071 // 05032024: added 
save "temp\data\kidney_injury", replace 
restore 


* - hemorrhage serious (serious spontaneous bleed) 
preserve 
keep if (strpos(comor_type_txt_new, "hemorrhage")>0 | strpos(comor_type_txt_new, "bleed")>0) & (strpos(comor_type_txt_new, "serious")>0)
replace comor_type_new = "hemorrhage (spontaneous bleed) serious (specify)"
replace comor_type_code_new = 31003
save "temp\data\hemorrhage", replace 
restore 


* - surgery/medical procedure  
preserve 
keep if strpos(comor_type_txt_new, "surgery")>0 | strpos(comor_type_txt_new, "medical procedure")>0
replace comor_type_new = "surgery / medical procedure (specify w/ indication)" // 05032024: updated 
replace comor_type_code_new = 91990 // 05032024: added 
save "temp\data\surgery", replace 
restore 


* - other conditions (from comor_type_new): GERD
preserve 
keep if strpos(comor_type_txt_new, "gerd")>0 | (strpos(comor_type_txt_new, "gastro")>0 & strpos(comor_type_txt_new, "reflux")>0)
replace comor_type_new = "gastroesophageal reflux (gerd)"
replace comor_type_code_new = 14030
save "temp\data\gerd", replace 
restore 

* - other conditions (from comor_type_new):  alopecia areata (aa)
preserve 
keep if strpos(comor_type_txt_new, "alopecia areata")>0 
replace comor_type_new = "alopecia areata (aa)"
replace comor_type_code_new = 10150
save "temp\data\aa", replace 
restore 

* - other conditions (from comor_type_new): bronchiolitis obliterans organizing pneumonia (boop)
preserve 
keep if strpos(comor_type_txt_new, "boop")>0 | strpos(comor_type_txt_new, "bronchiolitis obliterans organizing pneumonia")>0
replace comor_type_new = "bronchiolitis obliterans organizing pneumonia (boop)"
replace comor_type_code_new = 30100
save "temp\data\boop", replace 
restore 


* - other conditions (from comor_type_new): cardiac arrest 
preserve 
keep if strpos(comor_type_txt_new, "cardiac arrest")>0 
replace comor_type_new = "cardiac arrest"
replace comor_type_code_new = 11060
save "temp\data\cardiac_arrest", replace 
restore 


* - other conditions (from comor_type_new):  carotid artery disease
preserve 
keep if strpos(comor_type_txt_new, "carotid artery disease")>0 
replace comor_type_new = "carotid artery disease"
replace comor_type_code_new = 11070
save "temp\data\carotid", replace 
restore 


* - other conditions (from comor_type_new):  diagnostic catheterization - do not see any in 'other' yet
preserve 
keep if strpos(comor_type_txt_new, "diagnostic catheterization")>0 
replace comor_type_new = "diagnostic catheterization"
replace comor_type_code_new = 12550 // 05032024: added 
save "temp\data\diagnostic_cath", replace 
restore 



* - other conditions (from comor_type_new):  diarrhea
preserve 
keep if strpos(comor_type_txt_new, "diarrhea")>0 
replace comor_type_new = "diarrhea"
replace comor_type_code_new = 14810
save "temp\data\diarrhea", replace 
restore 

* - other conditions (from comor_type_new):  dyspepsia
preserve 
keep if strpos(comor_type_txt_new, "dyspepsia")>0 
replace comor_type_new = "dyspepsia"
replace comor_type_code_new = 14821
save "temp\data\dyspepsia", replace 
restore 


* - other conditions (from comor_type_new):  elevated creatinine
preserve 
keep if strpos(comor_type_txt_new, "elevated creatinine")>0 
replace comor_type_new = "elevated creatinine"
replace comor_type_code_new = 27810
save "temp\data\elevated_creatinine", replace 
restore 


* - other conditions (from comor_type_new):  hematology disorder
preserve 
keep if strpos(comor_type_txt_new, "hematology disorder")>0 
replace comor_type_new = "hematology disorder"
replace comor_type_code_new = 15000
save "temp\data\hematology_disorder", replace 
restore 


* - other conditions (from comor_type_new):  low wbc (leukopenia)
preserve 
keep if strpos(comor_type_txt_new, "leukopenia")>0 | strpos(comor_type_txt_new, "low wbc")>0
replace comor_type_new = "low wbc (leukopenia)"
replace comor_type_code_new = 18810
save "temp\data\leukopenia", replace 
restore 


* - other conditions (from comor_type_new): lung disease
preserve 
keep if strpos(comor_type_txt_new, "lung disease")>0 & strpos(comor_type_txt_new, "inter")==0
replace comor_type_new = "lung disease"
replace comor_type_code_new = 30110
save "temp\data\lung_disease", replace 
restore 


* - other conditions (from comor_type_new): nausea
preserve 
keep if strpos(comor_type_txt_new, "nausea")>0 
replace comor_type_new = "nausea"
replace comor_type_code_new = 14826
save "temp\data\nausea", replace 
restore 


* - other conditions (from comor_type_new): psychiatric disease
preserve 
keep if strpos(comor_type_txt_new, "psychiatric")>0 
replace comor_type_new = "psychiatric disease"
replace comor_type_code_new = 26000
save "temp\data\psych_disease", replace 
restore 


* - other conditions (from comor_type_new): rheumatoid pleurisy 
preserve 
keep if strpos(comor_type_txt_new, "rheumatoid pleurisy")>0 
replace comor_type_new = "rheumatoid pleurisy"
replace comor_type_code_new = 30063
save "temp\data\rheumatoid_pleurisy", replace 
restore 



* - other conditions (from comor_type_new): rheumatoid pulmonary nodules
preserve 
keep if strpos(comor_type_txt_new, "rheumatoid pulmonary nodules")>0 
replace comor_type_new = "rheumatoid pulmonary nodules"
replace comor_type_code_new = 30064
save "temp\data\rheum_pulm_nodule", replace 
restore 


* - other conditions (from comor_type_new): skin rash
preserve 
keep if strpos(comor_type_txt_new, "skin rash")>0 
replace comor_type_new = "skin rash"
replace comor_type_code_new = 13810
save "temp\data\skin_rash", replace 
restore 

* - other conditions (from comor_type_new): swelling of ankles (edema) 
preserve 
keep if (strpos(comor_type_txt_new, "edema")>0 | (strpos(comor_type_txt_new, "swelling")>0 & strpos(comor_type_txt_new, "ankle")>0)) & strpos(comor_type_txt_new, "angioedema")==0 & ///
             strpos(comor_type_txt_new, "lymphedema")==0
replace comor_type_new = "swelling of ankles (edema)"
replace comor_type_code_new = 90030
save "temp\data\edema", replace 
restore 

* - other conditions (from comor_type_new): bleeding ulcer  
preserve 
keep if strpos(comor_type_txt_new, "bleeding ulcer")>0 
replace comor_type_new = "bleeding ulcer"
replace comor_type_code_new = 14042
save "temp\data\bleed_ulcer", replace 
restore



*** append txt datasets created above 

// 05042024: added metabolic_oth, vascular_oth, cardio_oth, respiratory_oth, malignancy_pre, gi_other, drug_ind_liver, sub_nodules 
use "temp\data\hyperlipidemia", clear  // Ying edit to appending dta from subfolder

for any diabetes osteopenia osteoporosis metaoblic_oth hypertension revasc vent_arrhythmia mi acs unstable_angina cad chf stroke tia dvt pe oth_vte periph_art_dis pat upar periph_isch_gang  copd emphysema int_lung asthma ana sle breast lung colon uterine cervical prostate leukemia lymphoma myeloma nmsc melanoma peptic gi_perf bleed_ulcer hepatic_biop liver_disease hepatic_nonser osteoarthritis gout sjogren fracture pso anemia anxiety depression suic_idea self_injury  suic_attempt fibromyalgia demyelinating dementia hemi_para neuro_other  kidney_disease kidney_injury hemorrhage surgery gerd aa boop cardiac_arrest carotid /*diagnostic_cath*/ diarrhea dyspepsia elevated_creatinine hematology_disorder leukopenia lung_disease nausea psych_disease rheumatoid_pleurisy rheum_pulm_nodule skin_rash edema vascular_oth cardio_oth respiratory_oth malignancy_pre gi_other drug_ind_liver sub_nodules:  append using "temp\data\X.dta"  

/*
local sets diabetes osteopenia osteoporosis metaoblic_oth hypertension revasc vent_arrhythmia mi acs unstable_angina cad chf stroke tia dvt pe oth_vte periph_art_dis pat upar periph_isch_gang  ///
                 copd emphysema int_lung asthma ana sle breast lung colon uterine cervical prostate leukemia lymphoma myeloma nmsc melanoma peptic gi_perf bleed_ulcer hepatic_biop liver_disease ///
				 hepatic_nonser osteoarthritis gout sjogren fracture pso anemia anxiety depression suic_idea self_injury  suic_attempt fibromyalgia demyelinating dementia hemi_para neuro_other ///
				 kidney_disease kidney_injury hemorrhage surgery gerd aa boop cardiac_arrest carotid /*diagnostic_cath*/ diarrhea dyspepsia elevated_creatinine hematology_disorder leukopenia ///
				 lung_disease nausea psych_disease rheumatoid_pleurisy rheum_pulm_nodule skin_rash edema vascular_oth cardio_oth respiratory_oth malignancy_pre gi_other drug_ind_liver ///
				 sub_nodules // 05042024: added metabolic_oth, vascular_oth, cardio_oth, respiratory_oth, malignancy_pre, gi_other, drug_ind_liver, sub_nodules 
foreach s of local sets { 
append using `"temp\data\`s' "' 
} 
*/

save "temp\data\appended_txt", replace 


** merge with full txt dataset (data\has_txt) using event_uid 
*use "temp\data\appended_txt", replace 
merge m:1 event_uid using "temp\data\has_txt"
* records that do not merge (are not in appended dataset) - review to assign either 'medical condition other' or 'malignancy other' or 'cvd other', etc. 
keep if _merge==2 
* keep original comor_type_new if not missing, otherwise put as other medical condition 
replace comor_type_new = "medical condition other (specify)" if missing(comor_type_new) 
replace comor_type_code_new = 99920 if comor_type_new == "medical condition other (specify)" // 05032024: updated 


* append with appended_txt 
append using "temp\data\appended_txt"
save "temp\data\full_appended_txt", replace 

*** append with no_txt dataset to get full dataset
append using "temp\data\no_txt" 

** ensure all events from all_comor are accounted for and have a comor_type_new 
* make sure TAE_ANA all have comor_type_new = "drug hypersensitivity reaction" (events without comor_type_txt_new that have TAE_ANA)
replace comor_type_new = "drug hypersensitivity reaction (specify severity)" if dw_event_type_acronym=="TAE_ANA"
replace comor_type_code_new = 17040 if dw_event_type_acronym=="TAE_ANA"

* make sure all events that are currently labeled as "medical condition other (specify") are changed to malignancy other (specify) if include cancer 
replace comor_type_new = "malignancy other (specify)" if comor_type_new=="medical condition other (specify)" & strpos(comor_type_txt_new, "cancer")>0 & strpos(comor_type_txt_new, "non-canc")==0 ///
              & strpos(comor_type_txt_new, "pre-canc")==0 & strpos(comor_type_txt_new, "not new cancer")==0 & strpos(comor_type_txt_new, "post breast cancer")==0 & strpos(comor_type_txt_new, "noncancer")==0 ///
			  & strpos(comor_type_txt_new, "precancer")==0 & strpos(comor_type_txt_new, "not cancer")==0
replace comor_type_code_new = 20900 if comor_type_new=="malignancy other (specify)"			  

* if missing comor_type_new change to other medical condition 
replace comor_type_new = "medical condition other (specify)" if missing(comor_type_new) 
replace comor_type_code_new = 99920 if comor_type_new == "medical condition other (specify)" // 05032024: updated 



**** continue standardization - shorten name of comor_type_new to use version 14.1 if available; if not on 14.1 but on version 15 create own shortened name
*** using the shortened name will help with de-duplication 
** this will also combine categories of comor_type_new 

* 14.1
gen comorkey = "htn" if inlist(comor_type_new, "hypertension (htn)", "hypertension (htn) non-serious") // assume not require hospitalization unless reports hosp/serious; 05032024: updated 
replace comorkey = "htn_hosp" if inlist(comor_type_new, "hypertension (htn) requiring hospitalization", "hypertension (htn) serious")
replace comorkey = "hld" if inlist(comor_type_new, "hyperlipidemia")
replace comorkey = "revasc" if inlist(comor_type_new, "cardiac revascularization procedure (cabg, stent, angioplasty)", "congestive heart failure (chf) non-serious", "coronary artery bypass graft (cabg)") | ///
                                                    inlist(comor_type_new, "coronary angioplasty w/wo cardiac stent") // 05032024: updated 
replace comorkey = "ven_arrhythm" if inlist(comor_type_new, "ventricular arrhythmia")
replace comorkey = "card_arrest" if inlist(comor_type_new, "cardiac arrest")
replace comorkey = "mi" if inlist(comor_type_new, "myocardial infarction (mi)")
replace comorkey = "acs" if inlist(comor_type_new, "acute coronary syndrome (acs)")
replace comorkey = "unstab_ang" if inlist(comor_type_new, "angina unstable")
replace comorkey = "cor_art_dis" if inlist(comor_type_new, "coronary artery disease (cad)", "coronary artery disease (cad) other", "coronary artery disease (cad) non-serious") // 05032024: updated categories 
replace comorkey = "chf" if inlist(comor_type_new, "congestive heart failure (chf)", "congestive heart failure (chf) requiring hospitalization") | inlist(comor_type_new, "congestive heart failure (chf) serious")
replace comorkey = "chf_nohosp" if inlist(comor_type_new, "congestive heart failure (chf) not requiring hospitalization", "congestive heart failure (chf) non-serious") // assume is serious/hosp unless says non-hosp; 0503024: updated 
replace comorkey = "stroke" if inlist(comor_type_new, "stroke", "stroke / mini-stroke")
replace comorkey = "tia" if inlist(comor_type_new, "transient ischemic attack (tia)")
replace comorkey = "other_cv" if comor_type_new=="cardiac condition other (specify)" | comor_type_new=="cardiac condition other non-serious (specify)" | /// 
                                                       comor_type_new=="cardiac condition other serious (specify)" | comor_type_new=="cardiovascular condition other (specify)" // 05032024: updated 
replace comorkey = "hemorg_hosp" if inlist(comor_type_new, "hemorrhage (spontaneous bleed) requiring hospitalization", "hemorrhage (spontaneous bleed) serious (specify)")
replace comorkey = "hemorg_nohosp" if inlist(comor_type_new, "hemorrhage (spontaneous bleed) not requiring hospitalization")
replace comorkey = "oth_clot" if inlist(comor_type_new, "deep vein thrombosis (dvt)", "venous thromboembolism (vte) other (specify)") | inlist(comor_type_new, "deep vein thrombosis (dvt) w/ pulmonary embolism (pe)") // include vte other 05032024: updated wording for other vte 
replace comorkey = "pef_art_dis" if inlist(comor_type_new, "peripheral arterial disease stable", "peripheral arterial disease", "peripheral arterial disease non-serious") // 05032024: udpated
replace comorkey = "pat_event" if inlist(comor_type_new, "peripheral arterial thromboembolic event")
replace comorkey = "urg_par" if inlist(comor_type_new, "urgent peripheral arterial revascularization")
replace comorkey = "pi" if inlist(comor_type_new, "peripheral ischemia or gangrene (necrosis)")
replace comorkey = "pulm_emb" if inlist(comor_type_new, "pulmonary embolism (pe)")
replace comorkey = "carotid" if inlist(comor_type_new, "carotid artery disease")
replace comorkey = "anemia" if inlist(comor_type_new, "anemia")
replace comorkey = "lymphoma" if inlist(comor_type_new, "lymphoma")
replace comorkey = "lc" if inlist(comor_type_new, "lung cancer")
replace comorkey = "bc" if inlist(comor_type_new, "breast cancer")
replace comorkey = "skin_cancer_mel" if inlist(comor_type_new, "melanoma skin cancer")
replace comorkey = "skin_cancer_squa" if inlist(comor_type_new, "non-melanoma skin cancer (nmsc) squamous cell / basal cell", "non-melanoma skin cancer (nmsc) basal cell") | ///
                                                                     inlist(comor_type_new, "non-melanoma skin cancer (nmsc) squamous cell") // 05032024: updated 
replace comorkey = "oth_cancer" if inlist(comor_type_new, "malignancy other (not lymphoma)", "malignancy other (not skin)", "malignancy other (specify)")
replace comorkey = "ulcer" if inlist(comor_type_new, "peptic ulcer")
replace comorkey = "bowel_perf" if inlist(comor_type_new, "gastrointestinal (gi) perforation", "intestinal / bowel perforation")
replace comorkey = "hepatic_wbiop" if inlist(comor_type_new, "hepatic event requiring biopsy or hospitalization", "hepatic event requiring biopsy or serious (specify)") // 05032024: updated 
replace comorkey = "hepatic_nobiop" if inlist(comor_type_new, "hepatic event not requiring biopsy or hospitalization", "hepatic event (increased lfts >3x uln)", "hepatic event other (specify)") // 05032024: updated 
replace comorkey = "drug_ind_sle" if inlist(comor_type_new, "drug-induced sle")
replace comorkey = "psoriasis" if inlist(comor_type_new, "psoriasis (not arthritis)", "psoriasis") // 05032024: updated 
replace comorkey = "pml" if inlist(comor_type_new, "progressive multifocal leukoencephalopathy (pml)")
replace comorkey = "oth_neuro" if inlist(comor_type_new, "neurological disorder other (specify)", "neurological disorder other requiring hospitalization") | ///
                                                                           inlist(comor_type_new, "neurological disorder other requiring hospitalization or demyelinating disease", "neurological disorder other non-serious (specify)") | ///
																		   inlist(comor_type_new, "neurological disorder other serious (specify)") // may include some demyelinating disease b/c cannot separate; 05032024: updated 
replace comorkey = "fm" if inlist(comor_type_new, "fibromyalgia")		
replace comorkey = "depression" if inlist(comor_type_new, "depression")	
replace comorkey = "fib" if inlist(comor_type_new, "interstitial lung disease", "interstitial lung disease / pulmonary fibrosis", "lung disease", "pulmonary fibrosis") // include lung disease here 		
replace comorkey = "copd" if inlist(comor_type_new, "asthma / chronic obstructive pulmonary disease (copd)", "chronic obstructive pulmonary disease (copd)")	 | ///
                                                  inlist(comor_type_new, "chronic obstructive pulmonary disease (copd) exacerbation serious", "chronic obstructive pulmonary disease (copd) non-serious") // 05032024: updated 
replace comorkey = "asthma" if inlist(comor_type_new, "asthma", "asthma (allergic)") // 05032024: updated 
replace comorkey = "diabetes" if inlist(comor_type_new, "diabetes mellitus", "diabetes mellitus type i", "diabetes mellitus type ii") // 05032024: udpated
replace comorkey = "osteoporosis" if inlist(comor_type_new, "osteoporosis", "osteoporosis new onset", "osteoporosis worsening") // 05032024: updated 
replace comorkey = "bio_reaction" if inlist(comor_type_new, "drug hypersensitivity reaction (specify severity)", "drug hypersensitivity reaction infusion (iv)") | ///
                                                                                   inlist(comor_type_new, "drug hypersensitivity reaction injection (sc or im)", "drug hypersensitivity reaction", "drug hypersensitivity reaction severe") | ///
																				   inlist(comor_type_new, "drug hypersensitivity reaction mild / moderate") // 05032024: updated 
*replace comorkey = "osteoporosis" if inlist(comor_type_new, "osteoporosis")	
replace comorkey = "rheum_nodules" if comor_type_new == "rheumatoid pulmonary nodules"		
replace comorkey = "rheum_pleurisy" if comor_type_new == "rheumatoid pleurisy"	
replace comorkey = "boop" if comor_type_new == "bronchiolitis obliterans organizing pneumonia (boop)"
replace comorkey = "edema" if comor_type_new =="swelling of ankles (edema)"
replace comorkey = "diag_cath" if comor_type_new == "diagnostic catheterization"
replace comorkey = "liver_dis" if comor_type_new == "liver disease"
replace comorkey = "gerd" if comor_type_new == "gastroesophageal reflux (gerd)"
replace comorkey = "dyspepsia" if comor_type_new == "dyspepsia"
replace comorkey = "nausea" if comor_type_new == "nausea"
replace comorkey = "diarrhea" if comor_type_new == "diarrhea"
replace comorkey = "elev_creat" if comor_type_new == "elevated creatinine"
replace comorkey = "psychiatric" if inlist(comor_type_new, "psychiatric disease", "psychiatric disease other")
replace comorkey = "demyelin" if comor_type_new == "demyelinating disease other"
replace comorkey = "hematolog_dis" if comor_type_new == "hematology disorder"
replace comorkey = "ulcer" if comor_type_new == "bleeding ulcer"

																					

* new for 15
replace comorkey = "osteopenia" if inlist(comor_type_new, "osteopenia", "osteopenia new onset")  // 05032024: updated 
replace comorkey = "metabolic_oth" if inlist(comor_type_new, "metabolic condition other (specify)", "metabolic condition other non-serious (specify)") // 05032024: added 
replace comorkey = "emphysema" if inlist(comor_type_new, "emphysema") 
replace comorkey = "cancer_colon" if inlist(comor_type_new, "colon cancer") 
replace comorkey = "cancer_ute" if inlist(comor_type_new, "uterine cancer") 
replace comorkey = "cancer_cer" if inlist(comor_type_new, "cervical cancer") 
replace comorkey = "cancer_pro" if inlist(comor_type_new, "prostate cancer") 
replace comorkey = "leukemia" if inlist(comor_type_new, "leukemia") 
replace comorkey = "myeloma_mul" if inlist(comor_type_new, "multiple myeloma") // 05032024: updated 
replace comorkey = "arthritis_ost" if inlist(comor_type_new, "osteoarthritis") 
replace comorkey = "new_gout_wors" if inlist(comor_type_new, "gout", "gout new or worsening") 
replace comorkey = "sjogrens_sec" if inlist(comor_type_new, "secondary sjögren’s syndrome") // 05032024: updated 
replace comorkey = "fracture" if inlist(comor_type_new, "fracture (specify location)", "fracture non-serious (specify location)", "fracture serious (specify location)") // 05032024: updated  
replace comorkey = "anxiety" if inlist(comor_type_new, "anxiety") 
replace comorkey = "thoughts_suic" if inlist(comor_type_new, "suicidal thoughts (ideation)") 
replace comorkey = "injury_self_noseri" if inlist(comor_type_new, "self injury") 
replace comorkey = "attempt_sui" if inlist(comor_type_new, "suicide attempt") 
replace comorkey = "dementia" if inlist(comor_type_new, "dementia") 
replace comorkey = "hemiplegia_paraplegia" if inlist(comor_type_new, "hemiplegia or paraplegia") 
replace comorkey = "kidney_chr" if comor_type_new=="chronic kidney disease (ckd) - mild renal impairment (gfr 20-50 ml/min)" | ///
                                                          comor_type_new=="chronic kidney disease (ckd) - moderate / severe renal impairment (gfr < 20 ml/min)" 
replace comorkey = "kidney_acu" if comor_type_new=="acute kidney injury (aki) - mild renal impairment (gfr 20-50 ml/min)" | ///
                                                           comor_type_new=="acute kidney injury (aki) - moderate / severe renal impairment (gfr < 20 ml/min)"
replace comorkey = "medical_surg" if inlist(comor_type_new, "surgery / medical procedure (specify w/ indication)") 
replace comorkey = "alopecia" if comor_type_new == "alopecia areata (aa)"
replace comorkey = "rash" if comor_type_new == "skin rash"
replace comorkey = "wbc_low" if comor_type_new == "low wbc (leukopenia)"
replace comorkey = "vascular_oth" if inlist(comor_type_new, "vascular condition other non-serious (specify)", "vascular condition other serious (specify)", "vascular condition other (specify)") // 05032024: added 
replace comorkey = "lung_oth" if comor_type_new=="respiratory condition other (specify)" | comor_type_new=="respiratory condition other non-serious (specify)" // 05032024: added 
replace comorkey = "malignancy_pre" if comor_type_new=="pre-malignancy (specify)" // 05032024: added
replace comorkey = "oth_gi" if inlist(comor_type_new, "gastrointestinal (gi) disease other (specify)", "gastrointestinal (gi) disease other non-serious (specify)") // 05032024: added 
replace comorkey = "liver_inj_seri" if comor_type_new=="drug-induced liver injury serious (specify)" // 05032024: added - IMPUTED VALUE
replace comorkey = "liver_inj_noseri" if comor_type_new =="drug-induced liver injury non-serious (specify)" // 05032024: added - IMPUTED VALUE
replace comorkey = "hepatic_oth_noseri" if inlist(comor_type_new, "hepatic event other non-serious (specify)") // 05032024: added 
replace comorkey = "sub_nodules" if comor_type_new=="subcutaneous nodules" // 05032024: added 


* other condition - use phrase from 14.1 but exclude items from 15 that are coded separately 
replace comorkey = "skin_cancer_unk" if inlist(comor_type_new, "skin cancer") // comor_type_new is just 'skin cancer', so unknown what type 
replace comorkey = "oth_cond" if missing(comorkey)	


save "temp\data\full_clean_before_dedup", replace 

*~~~~~~~~~~~ De-duplication 

*** we will use a leveling approach to flag duplicates based on most detailed to most general overlaps

***** 1. Exact duplicate within visits (EN/FU/RFU) - we will push most recent non-missing information to 1st record in duplicate (EN record if available)
** de-duplicate by id, comor type (detailed version), comor type text, onset year, onset month, location (for fracture)
** sort enrollment visit 1st (will be retained after push missing data to this record)

** remove nmsc from de-duplication with MD and TAE - i.e. allow duplicates for nmsc because can have multiple occurrences on same date 
* 1/12/2024: Do not remove fractures from de-duplication within source (MD/TAE) - de-duplicate by location 

** create separate datasets for visits data (MD) and TAE data - we will de-duplicate within visits this round
use "temp\data\full_clean_before_dedup", clear 

gen onset_date_imp=onset_date 
replace onset_date_imp=c_effective_event_date if onset_date=="" & strpos(c_effective_event_date, "TAE") // Ying 2025-02-26 added if missing onset_date in TAE, use reported_date 

gen onset_year = strlower(substr(onset_date_imp,1,4))
gen onset_month = strlower(substr(onset_date_imp,6,2))
gen onset_day = strlower(substr(onset_date_imp,9,2)) 

for any month day: replace onset_X="01" if (onset_X=="xx" | onset_X=="uk" | onset_X=="") & onset_year!=""  

gen visit=md_tae=="md" 

preserve 
keep if comor_type_new == "non-melanoma skin cancer (nmsc) squamous cell / basal cell" 
save "temp\data\1nmsc", replace 
restore 

preserve 
keep if visit==1 & comor_type_new != "non-melanoma skin cancer (nmsc) squamous cell / basal cell" 
save "temp\data\1visits", replace 
restore 

preserve 
keep if visit==0 & comor_type_new != "non-melanoma skin cancer (nmsc) squamous cell / basal cell" 
save "temp\data\1tae", replace 
restore 

***** Deduplicate within MD
use "temp\data\1visits", clear
bysort subject_number: gen enfirstfusecond=0 if dw_event_type_acronym=="EN" & md_tae=="md" 
bysort subject_number: replace enfirstfusecond=1 if dw_event_type_acronym~="EN" & md_tae=="md"  

sort subject_number comor_type_new comor_type_txt_new onset_year onset_month location enfirstfusecond onset_day 
by subject_number comor_type_new comor_type_txt_new onset_year onset_month location: gen comorevent_dup1 = cond(_N==1,0,_n)
by subject_number: gen conscount=1 if comorevent_dup1==1
** for each episode of duplicate cases with a subject- we get a distinct number
by subject_number: gen Count_conscount=sum(conscount)
replace Count_conscount=. if comorevent_dup1==0 // remove from consideration records that are not part of duplicates

tab comorevent_dup1 visit 


*browse subject_number comor_type_new comor_type_txt_new onset_year onset_month location enfirstfusecond comorevent_dup1 conscount Count_conscount if comorevent_dup1>1

** push most recent non-missing information to enrollment/first record so keeping most up-to-date information for the comorbidity  
* 703092930 - 3 records with different drug_tox_code for each 
* 036010510 - has one ANA listed as mild/moderate and 1 as severe for duplicate event 

local updatevar injection_reaction_code infusion_reaction_code serious_code targeted drug_tox_code drug_tox_fda_rpt_code drug_tox_fda_code ///
         injection_reaction infusion_reaction serious  drug_tox drug_tox_fda_rpt drug_tox_fda
foreach v of local updatevar { 
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number Count_conscount miss_flag -c_effective_event_date 
  by subject_number Count_conscount: replace `v' = `v'[1] if comorevent_dup1>0
  drop miss_flag
}	
	
	
** remove duplicate information 
drop if comorevent_dup1>0 & conscount!=1

drop comorevent_dup1 conscount Count_conscount 


** save dataset - this will be the new 'visits' dataset to be used for further de-duplication 
save "temp\data\2visits", replace 


***** 2. Duplicates within TAE - we will push most recent non-missing information to 1st record in duplicate and keep the 1st record (all duplicate records will have same most-recent information)
** de-duplicate by id, comor type (detailed version), comor type text (keep in - checked removing this and tagged many as duplicates that were not duplicates), onset date (day-level)
use "temp\data\1tae", clear

sort subject_number comor_type_new comor_type_txt_new onset_date_imp location_txt_new
by subject_number comor_type_new comor_type_txt_new onset_date_imp: gen comorevent_dup1 = cond(_N==1,0,_n)
by subject_number: gen conscount=1 if comorevent_dup1==1 
** for each episode of duplicate cases with a subject- we get a distinct number 
by subject_number: gen Count_conscount=sum(conscount)
replace Count_conscount=. if comorevent_dup1==0 // remove from consideration records that are not part of duplicates

*browse subject_number comor_type_new comor_type_txt_new onset_date location_txt_new comorevent_dup1 conscount Count_conscount if comorevent_dup1>0
*036010664

** push most recent non-missing information to enrollment/first record so keeping most up-to-date information for the comorbidity  
/*
sort subject_number Count_conscount comorevent_dup1 
gen miss_flag=0 if !missing(serious_code)
replace miss_flag=1 if missing(serious_code)

gsort subject_number Count_conscount miss_flag -c_effective_event_date 
by subject_number Count_conscount: replace serious_code = serious_code[1] if comorevent_dup1>0
*/
* 003001455 - 2 copd on same date with same c_effective_event_date but 1 non-missing serious 

local updatevar injection_reaction_code infusion_reaction_code serious_code targeted drug_tox_code drug_tox_fda_rpt_code drug_tox_fda_code ///
         injection_reaction infusion_reaction serious  drug_tox drug_tox_fda_rpt drug_tox_fda location_txt_new 
foreach v of local updatevar { 
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number Count_conscount miss_flag -c_effective_event_date 
  by subject_number Count_conscount: replace `v' = `v'[1] if comorevent_dup1>0
  drop miss_flag
}		 

** remove duplicate information 
drop if comorevent_dup1>0 & conscount!=1

drop comorevent_dup1 conscount Count_conscount

** save dataset - this will be the new 'visits' dataset to be used for further de-duplication 
save "temp\data\2tae", replace 

***** 3. Duplicates within MD and TAE  (non-nmsc and non-fracture)

use "temp\data\2visits", clear
append using "temp\data\2tae"
drop enfirstfusecond

bysort subject_number: gen enfirstfusecond=0 if dw_event_type_acronym=="EN"
bysort subject_number: replace enfirstfusecond=1 if dw_event_type_acronym~="EN"


sort subject_number comor_type_new comor_type_txt_new onset_year onset_month visit location_txt_new 

duplicates tag subject_number comor_type_new  onset_year onset_month, gen(_dup1) // exclude comor_type_txt_new as it is too limiting 

browse subject_number comor_type_new comor_type_txt_new  onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond if _dup1>1


gen flag_md=1 if visit==1
gen flag_tae=1 if visit==0

egen total_md = total(flag_md), by(subject_number comor_type_new onset_year onset_month)
egen total_tae = total(flag_tae), by(subject_number comor_type_new onset_year onset_month)

sort subject_number comor_type_new onset_year onset_month visit c_effective_event_date
by subject_number comor_type_new onset_year onset_month: gen sum_md = sum(flag_md)
by subject_number comor_type_new onset_year onset_month: gen sum_tae = sum(flag_tae)
gen sum = sum_md if visit==1
replace sum = sum_tae if visit==0


browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond  total_md total_tae sum_md sum_tae sum if _dup1>1
browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond  total_md total_tae sum_md sum_tae sum if total_md>1 & total_tae>1

gsort subject_number comor_type_new onset_year onset_month sum enfirstfusecond visit  
by subject_number comor_type_new onset_year onset_month sum: gen flag=1 if visit[_n] != visit[_n-1] & _n!=1

browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond total_md total_tae sum_md sum_tae sum flag if _dup1>1
browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond total_md total_tae sum_md sum_tae sum flag if total_md>1 & total_tae>1


local updatevar injection_reaction_code infusion_reaction_code serious_code targeted drug_tox_code drug_tox_fda_rpt_code drug_tox_fda_code ///
         injection_reaction infusion_reaction serious  drug_tox drug_tox_fda_rpt drug_tox_fda location_txt_new 
foreach v of local updatevar {
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number comor_type_new onset_year onset_month sum miss_flag 
  by subject_number comor_type_new onset_year onset_month sum: replace `v' = `v'[1] if _dup1>0
  drop miss_flag
}	

gsort subject_number comor_type_new onset_year onset_month sum visit 
by subject_number comor_type_new onset_year onset_month sum: replace onset_date = onset_date[1] if _dup1>0 	 
by subject_number comor_type_new onset_year onset_month sum: replace onset_date_imp = onset_date_imp[1] if _dup1>0 	 
drop if flag==1

drop flag_md flag_tae total_md total_tae sum sum_md sum_tae flag enfirstfusecond

save "temp\data\md_tae_nonmsc", replace 

*******************************************

***** 4. Duplicates within nmsc between MD and TAE - allow duplicates by date but not by source   
use "temp\data\1nmsc", clear 

* Ying add on 2025-02-27 limited two since only can have two type nmsc: basal or squamous in each source 
duplicates tag visit subject_number comor_type_new onset_date comor_type_txt_new injection_reaction_code infusion_reaction_code serious_code targeted drug_tox_code drug_tox_fda_rpt_code drug_tox_fda_code injection_reaction infusion_reaction serious drug_tox drug_tox_fda_rpt drug_tox_fda location_txt_new, gen(_dup)
drop if _dup>2 
drop _dup 
*****************
sort subject_number comor_type_new onset_year onset_month visit location_txt_new visit 
duplicates tag subject_number comor_type_new onset_year onset_month, gen(_dup1) 

bysort subject_number: gen enfirstfusecond=0 if dw_event_type_acronym=="EN"
bysort subject_number: replace enfirstfusecond=1 if dw_event_type_acronym~="EN"

browse subject_number comor_type_new onset_year onset_month visit location_txt_new  _dup1 dw_event_type_acronym if _dup1>1

browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond if _dup1>1

gen flag_md=1 if visit==1 
gen flag_tae=1 if visit==0 

egen total_md = total(flag_md), by(subject_number comor_type_new onset_year onset_month)
egen total_tae = total(flag_tae), by(subject_number comor_type_new onset_year onset_month)

sort subject_number comor_type_new onset_year onset_month visit c_effective_event_date
by subject_number comor_type_new onset_year onset_month: gen sum_md = sum(flag_md)
by subject_number comor_type_new onset_year onset_month: gen sum_tae = sum(flag_tae) 
gen sum = sum_md if visit==1
replace sum = sum_tae if visit==0 

browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond  total_md total_tae sum_md sum_tae sum if _dup1>1
browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond  total_md total_tae sum_md sum_tae sum if total_md>1 & total_tae>1

gsort subject_number comor_type_new onset_year onset_month sum enfirstfusecond visit  
by subject_number comor_type_new onset_year onset_month sum: gen flag=1 if visit[_n] != visit[_n-1] & _n!=1

browse subject_number onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond total_md total_tae sum flag if _dup1>1
browse subject_number onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond total_md total_tae sum flag if total_md>1 & total_tae>1   

local updatevar injection_reaction_code infusion_reaction_code serious_code targeted drug_tox_code drug_tox_fda_rpt_code drug_tox_fda_code ///
         injection_reaction infusion_reaction serious  drug_tox drug_tox_fda_rpt drug_tox_fda location_txt_new 
foreach v of local updatevar {
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number comor_type_new onset_year onset_month sum miss_flag 
  by subject_number comor_type_new onset_year onset_month sum: replace `v' = `v'[1] if _dup1>0
  drop miss_flag
}	

browse subject_number comor_type_new onset_year onset_month visit _dup1 dw_event_type_acronym enfirstfusecond sum flag onset_date if _dup1>1
gsort subject_number comor_type_new onset_year onset_month sum visit 
by subject_number comor_type_new onset_year onset_month sum: replace onset_date = onset_date[1] if _dup1>0 	
by subject_number comor_type_new onset_year onset_month sum: replace onset_date_imp = onset_date_imp[1] if _dup1>0 	
* drop if duplicated in MD after TAE
drop if flag==1 

drop flag_md flag_tae total_md total_tae sum sum_md sum_tae flag enfirstfusecond

sort subject_number comorkey onset_year onset_month 
save "temp\data\2nmsc", replace

******************************************************************************************************

***** 5. Append de-duplicated non-NMSC/non-fracture with de-duplicated nmsc/fracture   
use "temp\data\md_tae_nonmsc", clear
append using "temp\data\2nmsc"

*~~~~~~~~~~~ Output clean dataset

** use comor_type_new and comor_type_txt_new so formatting is consistent (all lower case) - rename so fit standards (rename to original variable name and keep raw as 'orig')
rename comor_type comor_type_orig 
rename comor_type_new comor_type

rename comor_type_txt comor_type_txt_orig
rename comor_type_txt_new comor_type_txt

rename comor_type_code comor_type_code_orig
rename comor_type_code_new comor_type_code

rename location_txt location_txt_orig
rename location_txt_new  location_txt  


** remove unnecessary variables (keep MD vs TAE flag)
drop event_uid _merge visit _dup1 

** format dates as %tdCCYY-NN-DD  - still deciding on onset_date
gen c_effective_event_date_formatted = date(c_effective_event_date, "YMD")
format c_effective_event_date_formatted %tdCCYY-NN-DD 

gen reported_date_formatted = date(reported_date, "YMD")
format reported_date_formatted %tdCCYY-NN-DD  

gen visit_date_formatted = date(visit_date, "YMD")
format visit_date_formatted %tdCCYY-NN-DD  

/*** impute missing onset dates:
* collect visit_date from fv_event_instances dataset 
* - use visit_date - 1 day for enrollment visit events 
* - use visit_date for FU and TAE records that have visit_date 
* - use c_effective_event_date for independent TAEs without visit_date 
*/ 

destring onset_year, gen(year) 
* clean onset date 

// clean data enter issue onset year > report year 
replace onset_year=substr(c_effective_event_date, 1,4) if year > year(date(c_effective_event_date, "YMD")) & onset_date!=""

egen onsetdt=concat(onset_year onset_month onset_day) if onset_date!="", p("-") 

* EN use visit date -1 day 
gen misdt=date(c_effective_event_date, "YMD")-1 if missing(onset_date) & dw_event_type_acronym=="EN"    
tostring misdt, gen(misdt_str)  format("%tdCCYY-NN-DD")force  

replace onsetdt=misdt_str if onset_date=="" & misdt_str!="" &  dw_event_type_acronym=="EN" 

* FU use visit date 
replace onsetdt=c_effective_event_date if onset_date=="" & dw_event_type_acronym!="EN" 
assert onsetdt !="" 

* format to date 
gen imp_onset_date=date(onsetdt, "YMD") 
format imp_onset_date %tdCCYY-NN-DD 
assert imp_onset_date<. 
lab var imp_onset_date "Imputed onset date" 

** set flag for imputed onset_date 
gen imp_onset_date_flag = 1 if onset_date != onsetdt  
lab var imp_onset_date_flag "Imputed onset date-yes" 
replace onset_date_imp =onsetdt 
lab var onset_date_imp "Imputed onset date (str)" 


drop onset_date_imp visit_date  misdt misdt_str year onsetdt 

** label variables 
label variable c_dw_event_instance_key "unique id of registry event instance"
label variable parent_study_acronym	"parent study: RA"
*label variable parent_study_uid	"parent study unique id (joining key)"
label variable study_acronym "Study"
label variable source_acronym "EDC source" 
*label variable study_uid "unique id (joining key) for study"
label variable site_number	"public site_number of site at visit"
// 2025-02-04 changed names 
label variable c_site_key	"unique id of site at visit"
label variable c_subject_key "subject unique id (joining key)"

label variable subject_number "public facing subject_number (string)"

label variable dw_event_type_acronym "registry event type"
label variable c_effective_event_date "If visit, date of visit or created date when visit date not entered. If TAE, date of event onset, then use date of follow-up visit at which TAE was reported, or created date when neither is entered. If exit, date of exit or created date when exit date not entered."
label variable c_provider_id "provider ID"
label variable full_version "concatenated major_version.minor_version to represent paper form version"
label variable coll_adverse_instance_uid "unique id of comor (or adverse) 'happening' instance"
label variable coll_map_uid	"unique id of 'mapping row'"
// 2025-04-02 name changed 
label variable edc_event_name_raw "event label shown in EDC front-end UI"
label variable edc_event_ordinal "occurrence number of event type in EDC"

label variable coll_crf_name_raw	"CRF or form label shown in EDC front-end UI"
label variable coll_crf_ordinal	"occurrence number of form type in EDC"
label variable coll_group_type_acronym	"EDC back-end group label"
label variable coll_group_ordinal "occurrence number of group type in EDC"
label variable confirm_tae "confirmation status of TAE as reported by site"
label variable confirm_tae_code	"Standardized codification of confirm_tae"
label variable reported_date "Date of Follow-up Visit at which TAE was reported"
label variable comor_type_orig	"Type of comorbidity: raw value"
label variable comor_type_code_orig "Standardized codification of comor_type_orig"
label variable comor_type_txt_orig "Free-text entry of comor_type_orig: raw value"
label variable onset_date "Date of onset"
label variable location "Location of fracture"
label variable location_code "Standardized codification of location"
label variable location_txt_orig	"Free-text entry of location: raw value"
label variable injection_reaction "Severity of injection reaction"
label variable injection_reaction_code "Standardized codification of injection_reaction"
label variable infusion_reaction "Severity of infusion reaction"
label variable infusion_reaction_code "Standardized codification of infusion_reaction"
label variable serious	"Indicates if the infection met seriousness criteria"
label variable serious_code	"Standardized codification of serious"
label variable targeted	"Indicates if the infection was a targeted event"
label variable drug_tox "If a drug toxicity, this is the most responsible drug code."
label variable drug_tox_code "Standardized codification of drug_tox"
label variable drug_tox_fda_rpt "Were any of these toxicities reported to the FDA?"
label variable drug_tox_fda_rpt_code "Standardized codification of drug_tox_fda_rpt"
label variable drug_tox_fda "If toxicity was reported to the FDA, which drug code?"
label variable drug_tox_fda_code "Standardized codification of drug_tox_fda"
label variable onset_year "Date of onset: year"
label variable onset_month "Date of onset: month"
label variable onset_day "Date of onset: day"
label variable md_tae "Indicator for MD/TAE source of comorbidity reporting"
label variable comor_type "Type of comorbidity: formatted"
label variable comor_type_txt "Free-text entry of comor_type: formatted"
label variable location_txt "Free-text entry of location: formatted"
label variable comor_type_code "Standardized codification of comor_type: formatted"
label variable comorkey "Type of comorbidity: shortened"
label variable c_effective_event_date_formatted "Formatted c_effective_event_date"
label variable reported_date_formatted "Formatted reported_date" 
label variable imp_onset_date "Date of onset: imputed from visit_date or c_effective_event_date"
label variable imp_onset_date_flag "Indicates if imp_onset_date is imputed"

save temp\data\omor_after_dedup, replace 

* Ying added to de-duplicate
sort subject_number visitdate comor_type comor_type_txt location location_txt imp_onset_date onset_date md_tae 
by subject_number visitdate comor_type comor_type_txt location location_txt imp_onset_date: gen vN=_N if strpos(comor_type, "non-melanoma")==0 
by subject_number visitdate comor_type comor_type_txt location location_txt imp_onset_date: gen vn=_n if strpos(comor_type, "non-melanoma")==0 
tab vN 

* br subject_number visitdate comor_type onset_date imp_onset_date dw_event_type_acronym vn vN if vN>1 & vN<. 
drop if vN==2 & vn==1 
drop vn vN 

*Ying clean duplicate peptic ulcer and bleeding ulcer which casue data issues: CSG map bleeding ulcer to peptic ulcer in verison<7, keep bleeding ulcer in unmapped. bv map both. 
sort subject_number visitdate comorkey imp_onset_date comor_type 
bysort subject_number visitdate comorkey imp_onset_date: gen ck=1 if _N==2 & comorkey=="ulcer" & comor_type=="bleeding ulcer" & comor_type[_n+1]=="peptic ulcer" 
bysort subject_number visitdate comorkey imp_onset_date: replace ck=2 if _n==2 & ck[_n-1]==1 
tab ck comor_type 
drop if ck==2  
drop ck  

//2025-02-04 updated to reflect changed names 
drop x_is_test c_is_suppressed_not_seen c_subject_key  coll_map_uid  c_site_key coll_adverse_instance_uid // ENG created vars 

* Ying edit on 2024-08-15 
*use clean_table\1_7_allcomor, clear 

lab define ny 0 no  1 yes, modify 
destring targeted, replace 
lab val targeted ny 

foreach x in confirm_tae serious {
	drop `x' 
	rename `x'_code `x' 
	lab val `x' ny 
}

unique subject_number comor_type comor_type_txt imp_onset_date location location_txt_orig // unique key 2025-02-04 9 duplicates. 
*duplicates list subject_number comor_type comor_type_txt onset_date location location_txt_orig

// 2025-02-26 decided to drop the 3 duplicated rows for not
duplicates tag subject_number comor_type comor_type_txt imp_onset_date location location_txt_orig, gen(dup) 

tab dup if strpos(comor_type, "nmsc") ==0  

sort subject_number comorkey comor_type comor_type_txt imp_onset_date  location location_txt_orig dw_event_type_acronym 
by subject_number comorkey comor_type comor_type_txt imp_onset_date  location location_txt_orig: drop if _N==2 & _n==1 & strpos(comor_type, "nmsc")==0 

drop dup 


// 2025-01-09 drop dates beyond datacut 
codebook visitdate // [01jan1900,03mar2025]
*count if visitdate>d(31mar2025)

count if visitdate>d($cutdate)
drop if visitdate>d($cutdate)

// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"
** save dataset 
compress 

*use clean_table\1_7_allcomor_$datacut, clear
drop created_date
save clean_table\1_7_allcomor_$datacut, replace 


foreach x in diabetes osteopenia osteoporosis metaoblic_oth hypertension revasc vent_arrhythmia mi acs unstable_angina cad chf stroke tia dvt pe oth_vte periph_art_dis pat upar periph_isch_gang  copd emphysema int_lung asthma ana sle breast lung colon uterine cervical prostate leukemia lymphoma myeloma nmsc melanoma peptic gi_perf bleed_ulcer hepatic_biop liver_disease hepatic_nonser osteoarthritis gout sjogren fracture pso anemia anxiety depression suic_idea self_injury  suic_attempt fibromyalgia demyelinating dementia hemi_para neuro_other  kidney_disease kidney_injury hemorrhage surgery gerd aa boop cardiac_arrest carotid /*diagnostic_cath*/ diarrhea dyspepsia elevated_creatinine hematology_disorder leukopenia lung_disease nausea psych_disease rheumatoid_pleurisy rheum_pulm_nodule skin_rash edema vascular_oth cardio_oth respiratory_oth malignancy_pre gi_other drug_ind_liver sub_nodules 1nmsc 1tae 1visits 2nmsc 2tae 2visits appended_txt full_appended_txt full_clean_before_dedup has_txt hyperlipidemia md_tae_nonmsc no_txt diagnostic_cath {  
    
cap erase temp/data/`x'.dta 
}

cap log close 
log using temp\test_allcomor.log, replace
use "$pdata\clean_table\1_7_allcomor_$pdatacut" , clear 
unique subject_number visitdate comorkey onset_date
bysort subject_number visitdate comorkey onset_date: drop if _N>1
save temp\1_7_allcomor_test, replace 

use clean_table\1_7_allcomor_$datacut, clear 
unique subject_number visitdate comorkey onset_date
bysort subject_number visitdate comorkey onset_date: drop if _N>1


drop c_effective_event_date_formatted 
corcf * using temp\1_7_allcomor_test, id(subject_number visitdate comorkey onset_date) 

cap log close
exit
