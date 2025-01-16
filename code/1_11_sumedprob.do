/*******************************************************
date: 2024-06-24
Name: Ying Shan

Aim: create clean table subject reported current medical problems on enrollment and follow up 

data used: monthly updated bv_medical_problems (wide format) and bv_medical_problems_pretm (long format) 
data out: 1_11_sumedprob.dta wide format to match RCC data

do file: 1_11_sumedprob_20240624.do 

*/
******************************************

* this section only need run once for preTM data 

use "bv_raw\bv_medical_problems_pretm", clear 
des, f 
compress 

unique subject_number c_effective_event_date medprobs_name 

recast str medprobs_name 
recast str medprobs_other_spec

gen medprobs_key="" 
replace medprobs_key = "anxiety" if medprobs_name == "anxiety (feeling nervous)"
replace medprobs_key = "backpain" if medprobs_name == "back pain"
replace medprobs_key = "breast_cancer" if medprobs_name == "breast cancer"
replace medprobs_key = "angina" if medprobs_name == "chest pain (angina)"
replace medprobs_key = "chf" if medprobs_name == "congestive heart failure (CHF)"
replace medprobs_key = "constipation" if medprobs_name == "constipation"
replace medprobs_key = "cough" if medprobs_name == "cough"
replace medprobs_key = "blood_stool" if medprobs_name == "dark or bloody stools"
replace medprobs_key = "depression" if medprobs_name == "depression (feeling blue)"
replace medprobs_key = "diarrhea" if medprobs_name == "diarrhea"
replace medprobs_key = "dizziness" if medprobs_name == "dizziness"
replace medprobs_key = "dry_eyes" if medprobs_name == "dry eyes"
replace medprobs_key = "dry_mouth" if medprobs_name == "dry mouth"
replace medprobs_key = "ringing_ears" if medprobs_name == "ear ringing"
replace medprobs_key = "eye_prob_oth" if medprobs_name == "eye problem other"
replace medprobs_key = "fainting" if medprobs_name == "fainting"
replace medprobs_key = "feeling_sick" if medprobs_name == "feeling sick"
replace medprobs_key = "fever" if medprobs_name == "fever"
replace medprobs_key = "gyn_prob" if medprobs_name == "gynecological problem"
replace medprobs_key = "headaches" if medprobs_name == "headaches"
replace medprobs_key = "heart_attach" if medprobs_name == "heart attack"
replace medprobs_key = "heart_disease_oth" if medprobs_name == "heart disease other"
replace medprobs_key = "heart_pounding" if medprobs_name == "heart pounding (palpitations)"
replace medprobs_key = "heartburn_reflux" if medprobs_name == "heartburn or stomach gas"
replace medprobs_key = "infection_hosp" if medprobs_name == "infection for which you were admitted to the hospital"
replace medprobs_key = "joint_pain" if medprobs_name == "joint pain"
replace medprobs_key = "appetite_loss" if medprobs_name == "loss of appetite"
replace medprobs_key = "loss_balance" if medprobs_name == "loss of balance"
replace medprobs_key = "hair_loss" if medprobs_name == "loss of hair"
replace medprobs_key = "lung_cancer" if medprobs_name == "lung cancer"
replace medprobs_key = "lymphoma" if medprobs_name == "lymphoma"
replace medprobs_key = "cancer_other" if medprobs_name == "malignancy other (specify)"
replace medprobs_key = "tia" if medprobs_name == "transient ischemic attack (TIA)"
replace medprobs_key = "muscle_pain" if medprobs_name == "muscle pain, aches, cramps"
replace medprobs_key = "muscle_weakness" if medprobs_name == "muscle weakness"
replace medprobs_key = "nausea" if medprobs_name == "nausea"
replace medprobs_key = "numbness_limbs" if medprobs_name == "numbness or tingling of arms or legs"
replace medprobs_key = "paralysis" if medprobs_name == "paralysis"
replace medprobs_key = "pneumonia" if medprobs_name == "pneumonia requiring hospitalization"
replace medprobs_key = "pregnancy" if medprobs_name == "pregnancy"
replace medprobs_key = "hearing_prob" if medprobs_name == "problems with hearing"
replace medprobs_key = "memory" if medprobs_name == "problems with memory / forgetfulness"
replace medprobs_key = "problem_sleeping" if medprobs_name == "problems with sleeping"
replace medprobs_key = "taste_prob" if medprobs_name == "problems with smell or taste"
replace medprobs_key = "social_prob" if medprobs_name == "problems with social activity"
replace medprobs_key = "thinking" if medprobs_name == "problems with thinking / confusion"
replace medprobs_key = "urination" if medprobs_name == "problems with urination"
replace medprobs_key = "psoriasis" if medprobs_name == "psoriasis"
replace medprobs_key = "sexual_prob" if medprobs_name == "sexual problems"
replace medprobs_key = "short_breath" if medprobs_name == "shortness of breath"
replace medprobs_key = "melanoma" if medprobs_name == "melanoma skin cancer"
replace medprobs_key = "not_melanoma" if medprobs_name == "non-melanoma skin cancer (NMSC)"
replace medprobs_key = "not_mel_basal" if medprobs_name == "non-melanoma skin cancer (NMSC) basal cell"
replace medprobs_key = "not_mel_squa" if medprobs_name == "non-melanoma skin cancer (NMSC) squamous cell"
replace medprobs_key = "skin_prob_oth" if medprobs_name == "skin problems other"
replace medprobs_key = "rash_or_hives" if medprobs_name == "skin rash or hives (urticaria)"
replace medprobs_key = "mouth_sores" if medprobs_name == "sores in the mouth"
replace medprobs_key = "stomach_cramps" if medprobs_name == "stomach pain or cramps"
replace medprobs_key = "stroke" if medprobs_name == "stroke"
replace medprobs_key = "joint_swell" if medprobs_name == "swelling of other joints"
replace medprobs_key = "edema" if medprobs_name == "swelling of ankles (edema)"
replace medprobs_key = "swollen_gland" if medprobs_name == "swollen glands"
replace medprobs_key = "trouble_swallow" if medprobs_name == "trouble swallowing"
replace medprobs_key = "bleeding" if medprobs_name == "unusual bruising or bleeding"
replace medprobs_key = "unsual_fatigue" if medprobs_name == "unusual fatigue"
replace medprobs_key = "vomiting" if medprobs_name == "vomiting"
replace medprobs_key = "wgh_gain" if medprobs_name == "weight gain (>10 lb)"
replace medprobs_key = "wgh_loss" if medprobs_name == "weight loss (>10 lb)"
replace medprobs_key = "wheezing" if medprobs_name == "wheezing"


gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD  
destring site_number full_version, replace 
unique subject_number visitdate medprobs_key 

assert medprobs_key!="" 

tab medprobs_name if medprobs_key=="" 

drop specs_ctag specs_csubtype c_is_suppressed_not_seen dw_crf_instance_uid dw_cordinal 
drop c_effective_event_date dw_subject_uid c_edc_event_instance_key dw_site_uid 

preserve 
keep if medprobs_other_spec!="" & medprobs_name=="malignancy other (specify)"  // preTM only other cancer with text free field 
keep subject_number visitdate medprobs_other_spec 
rename medprobs_other_spec med_prob_cancer_other_spec 
 
save temp\temp_cancer_spec, replace 
restore 

preserve 
bysort subject_number visitdate: drop if _n>1 
drop medprobs_*
merge 1:1 subject_number visitdate using temp\temp_cancer_spec 
drop _m 
sort subject_number visitdate 
save temp\temp_medprob_vts, replace 
restore 

erase temp\temp_cancer_spec.dta 

* shape to wide format for preTM to match TM/RCC data 

keep subject_number visitdate medprobs_key medprobs_name 
reshape wide medprobs_name , i(subject_number visitdate) j(medprobs_key) string 

lab define ny 1 yes, modify 

#delimit;
local list 
angina             diarrhea           hearing_prob       memory             problem_sleeping   thinking
anxiety            dizziness          heart_attach       mouth_sores        psoriasis          tia
appetite_loss      dry_eyes           heart_disease_oth  muscle_pain        rash_or_hives      trouble_swallow
backpain           dry_mouth          heart_pounding     muscle_weakness    ringing_ears       unsual_fatigue
bleeding           edema              heartburn_reflux   nausea             sexual_prob        urination
blood_stool        eye_prob_oth       infection_hosp     not_mel_basal      short_breath       vomiting
breast_cancer      fainting           joint_pain         not_mel_squa       skin_prob_oth      wgh_gain
cancer_other       feeling_sick       joint_swell        not_melanoma       social_prob        wgh_loss
chf                fever              loss_balance       numbness_limbs     stomach_cramps     wheezing
constipation       gyn_prob           lung_cancer        paralysis          stroke
cough              hair_loss          lymphoma           pneumonia          swollen_gland
depression         headaches          melanoma           pregnancy          taste_prob;
#delimit cr 

foreach x of local list{
	cap drop med_prob_`x' 
	gen med_prob_`x'=1 if medprobs_name`x'!="" 
	lab val med_prob_`x' ny 
	drop medprobs_name`x'
}

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_medprob_vts 
drop _m 
save ..\..\for_update\sumedprob_pretm_wide, replace 

*************************************************/

use bv_raw\bv_medical_problems, clear // TM & RCC data 

gen visitdate=date(c_effective_event_date, "YMD")
format visitdate %tdCCYY-NN-DD  
count if visitdate==. 

foreach x in created_date last_modified_date {
	replace c_event_`x'=dofc(c_event_`x') 
	format c_event_`x' %tdCCYY-NN-DD 
}

list subject_number dw_event_type_acronym source full_version site_number c_effective_event_date  c_event_created_date if visitdate==. , noobs ab(30) 

/* EDC need to edit by site 

  +--------------------------------------------------------------------------------------------------------------------------------------+
  | subject_number   dw_event_type_acronym   source_acronym   full_version   site_number   c_effective_event_date   c_event_created_date |
  |--------------------------------------------------------------------------------------------------------------------------------------|
  |      254010260                      FU              RCC           15.0           254              20241-04-01     03apr2024 22:57:13 |
  +--------------------------------------------------------------------------------------------------------------------------------------+
*/


replace visitdate=c_event_created_date if visitdate==. 
 
unique subject_number visitdate 

*deduplicates, keep later version if duplicates 
sort subject_number visitdate full_version 
by subject_number visitdate: gen vN=_N 
by subject_number visitdate: gen vn=_n 

tab vN if vn==1 
tab full_version vn if vN==2 
/*
         vN |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |    180,490       99.99       99.99
          2 |         20        0.01      100.00
------------+-----------------------------------
      Total |    180,510      100.00 
	  
	  full_versi |          vn
        on |         1          2 |     Total
-----------+----------------------+----------
      11.0 |        19          0 |        19 
      12.0 |         0          6 |         6 
      14.0 |         0         13 |        13 
      15.0 |         1          1 |         2 
-----------+----------------------+----------
     Total |        20         20 |        40 
	  */

*list subject_number dw_event_type_acronym source full_version site_number c_effective_event_date  c_event_created_date if vN==2. , noobs ab(30) sepby(subject_number)


preserve 
keep if vn==2 
sort subject_number visitdate 
save temp\dupmed, replace
restore 

drop if vn==2 
merge 1:1 subject_number visitdate using temp\dupmed, update replace 
drop vn vN _m
erase temp\dupmed.dta 

unique subject_number visitdate 

#delimit; 
local list 
alcoholism          cough               headaches           mouth_sores         rash_or_hives
anemia              depression          heart_attack        muscle_pain         stomach_cramps
angina              diabetes_type_1     mi_hosp_tx          muscle_weakness     stroke
anxiety             diabetes_type_2     heart_disease_oth   nausea              stroke_hosp_tx
appetite_loss       diarrhea            heart_pounding      new_cancer          thinking
backpain            dizziness           heart_oth_hosp      not_melanoma        thyroid_problem
blood_other         dry_eyes            heartburn_reflux    numbness_limbs      tia
blood_stool         dry_mouth           htn                 osteoporosis        trouble_swallow
breast_cancer       edema               infection_hosp      peptic_ulcer        unsual_fatigue
broken_bones_50     emphysema           infection_tx_iv     perf_intestine      vomiting
cancer_other        fever               liver_disease       pneumonia           wgh_gain
cataracts           fibromyalgia        lung_cancer         pregnancy           wgh_loss
chf                 gastro_bleed        lymphoma            problem_sleeping    wheezing
chronic_bronchitis  gerd                melanoma            psoriasis
constipation        hair_loss           memory              short_breath			
; 
#delimit cr 
   
foreach x of local list {
  drop med_prob_`x' 
  rename med_prob_`x'_code med_prob_`x' 
}	

* clean text fields 
foreach x in yes "® ^ó" "ü ^ ≥≤^ éμ ≤ ≥" UK UNKNOWN {
	replace med_prob_blood_other_spec="" if med_prob_blood_other_spec=="`x'" 
		replace med_prob_cancer_other_spec="" if med_prob_cancer_other_spec=="`x'" 
} 

sort subject_number visitdate 
destring site_number full_version, replace 

merge 1:1 subject_number visitdate using ..\..\for_update\sumedprob_pretm_wide, update 

drop _m 

ds med_prob_*, not(varl) v(32)

lab var subject_number  "Subject ID"
lab var site_number  "Site ID"
lab var visitdate  "Date of office visit"
lab var c_effective_event_date "date of office visit
lab var study_acronym "Study type"
lab var source_acronym  "EDC data source"
lab var dw_event_type_acronym  "Form: enrollment/follow up"
lab var full_version  "Form version" 
lab var c_provider_id "Provider ID"
lab var c_event_created_date "Form created date" 
lab var c_event_last_modified_date "Form last modified date" 
lab var dw_event_instance_uid "ENG created unique ID" 
lab var med_prob_htn  "High blood pressure"
lab var med_prob_mi  "Heart attack"
lab var med_prob_anemia  "Anemia (low red blood cells)"
lab var med_prob_blood_other  "Other blood problem"
lab var med_prob_chronic_bronchitis  "Chronic bronchitis"
lab var med_prob_emphysema  "Emphysema"
lab var med_prob_peptic_ulcer  "Peptic ulcer"
lab var med_prob_gerd  "GERD"
lab var med_prob_perf_intestine  "Perforation of the intestine/bowel"
lab var med_prob_gastro_bleed  "GI bleed"
lab var med_prob_thyroid_problem  "Thyroid problem"
lab var med_prob_diabetes_type_1  "Diabetes Type I"
lab var med_prob_diabetes_type_2  "Diabetes Type II"
lab var med_prob_osteoporosis  "Osteoporosis"
lab var med_prob_broken_bones_50  "Broken bones after age 50"
lab var med_prob_cataracts  "Cataracts"
lab var med_prob_alcoholism  "Alcoholism"
lab var med_prob_liver_disease  "Liver disease"
lab var med_prob_infection_tx_iv  "Infection for which you had to take antibiotics through a vein (IV) "
lab var med_prob_stroke_hosp_tx  "Stroke that was treated in hospital"
lab var med_prob_mi_hosp_tx  "Heart attack treated in hospital"
lab var med_prob_heart_oth_hosp  "Other heart-related problem requiring hospital admission"
lab var med_prob_new_cancer  "New diagnosis of cancer"
lab var med_prob_fibromyalgia  "Fibromyalgia"

lab var med_prob_anxiety  "anxiety (feeling nervous)"
lab var med_prob_backpain  "back pain"
lab var med_prob_breast_cancer  "breast cancer"
lab var med_prob_angina  "chest pain (angina)"
lab var med_prob_chf  "congestive heart failure (CHF)"
lab var med_prob_constipation  "constipation"
lab var med_prob_cough  "cough"
lab var med_prob_blood_stool  "dark or bloody stools"
lab var med_prob_depression  "depression (feeling blue)"
lab var med_prob_diarrhea  "diarrhea"
lab var med_prob_dizziness  "dizziness"
lab var med_prob_dry_eyes  "dry eyes"
lab var med_prob_dry_mouth  "dry mouth"
lab var med_prob_ringing_ears  "ear ringing"
lab var med_prob_eye_prob_oth  "eye problem other"
lab var med_prob_fainting  "fainting"
lab var med_prob_feeling_sick  "feeling sick"
lab var med_prob_fever  "fever"
lab var med_prob_gyn_prob  "gynecological problem"
lab var med_prob_headaches  "headaches"
lab var med_prob_heart_attach  "heart attack"
lab var med_prob_heart_disease_oth  "heart disease other"
lab var med_prob_heart_pounding  "heart pounding (palpitations)"
lab var med_prob_heartburn_reflux  "heartburn or stomach gas"
lab var med_prob_infection_hosp  "infection for which you were admitted to the hospital"
lab var med_prob_joint_pain  "joint pain"
lab var med_prob_appetite_loss  "loss of appetite"
lab var med_prob_loss_balance  "loss of balance"
lab var med_prob_hair_loss  "loss of hair"
lab var med_prob_lung_cancer  "lung cancer"
lab var med_prob_lymphoma  "lymphoma"
lab var med_prob_cancer_other  "malignancy other"
lab var med_prob_tia  "transient ischemic attack (TIA)"
lab var med_prob_muscle_pain  "muscle pain, aches, cramps"
lab var med_prob_muscle_weakness  "muscle weakness"
lab var med_prob_nausea  "nausea"
lab var med_prob_numbness_limbs  "numbness or tingling of arms or legs"
lab var med_prob_paralysis  "paralysis"
lab var med_prob_pneumonia  "pneumonia requiring hospitalization"
lab var med_prob_pregnancy  "pregnancy"
lab var med_prob_hearing_prob  "problems with hearing"
lab var med_prob_memory  "problems with memory / forgetfulness"
lab var med_prob_problem_sleeping  "problems with sleeping"
lab var med_prob_taste_prob  "problems with smell or taste"
lab var med_prob_social_prob  "problems with social activity"
lab var med_prob_thinking  "problems with thinking / confusion"
lab var med_prob_urination  "problems with urination"
lab var med_prob_psoriasis  "psoriasis"
lab var med_prob_sexual_prob  "sexual problems"
lab var med_prob_short_breath  "shortness of breath"
lab var med_prob_melanoma  "melanoma skin cancer"
lab var med_prob_not_melanoma  "non-melanoma skin cancer (NMSC)"
lab var med_prob_not_mel_basal  "non-melanoma skin cancer (NMSC) basal cell"
lab var med_prob_not_mel_squa  "non-melanoma skin cancer (NMSC) squamous cell"
lab var med_prob_skin_prob_oth   "skin problems other"
lab var med_prob_rash_or_hives  "skin rash or hives (urticaria)"
lab var med_prob_mouth_sores  "sores in the mouth"
lab var med_prob_stomach_cramps  "stomach pain or cramps"
lab var med_prob_stroke  "stroke"
lab var med_prob_joint_swell  "swelling of other joints"
lab var med_prob_edema  "swelling of ankles (edema)"
lab var med_prob_swollen_gland  "swollen glands"
lab var med_prob_trouble_swallow  "trouble swallowing"
lab var med_prob_bleeding  "unusual bruising or bleeding"
lab var med_prob_unsual_fatigue  "unusual fatigue"
lab var med_prob_vomiting  "vomiting"
lab var med_prob_wgh_gain  "weight gain (>10 lb)"
lab var med_prob_wgh_loss  "weight loss (>10 lb)"
lab var med_prob_wheezing  "wheezing"
lab var med_prob_heart_attack  "Heart attack (other)"

lab var med_prob_blood_other_spec "other blood (specify)" 
lab var med_prob_cancer_other_spec "other cancer (specify)" 

drop dw_site_uid dw_subject_uid c_is_*  
drop parent_study_acronym c_edc_event_instance_key c_dw_event_instance_key c_effective_event_date

unique subject_number visitdate 
compress 

codebook visitdate 
count if visitdate>d($cutdate) // 84

drop if visitdate>d($cutdate)

order subject_number visitdate site_number 

save clean_table\1_11_sumedprobs_$datacut, replace 


