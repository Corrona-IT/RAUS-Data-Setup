/*

date: 2023-11-10
programmer: Ying Shan
data use: 1.1 subjects.dta, 1.2 allvisits.dta
data out: keyvisitvar.dta 


common variable name:
bmi_cat3
bmi_cat4
virtual_md
virtual_subj


global bv "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\ODBC\dwh_db\2024-02-02" 
global site "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\2023\2023-12-31"  
global dataout "~\Corrona LLC\Biostat Data Files - Registry Data\RA\Data Warehouse Project 2020 - 2021\Analytic File\data\custom_table\"
global cleantable "~\Corrona LLC\Biostat Data Files - Registry Data\RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table"

cd "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\Transition\analysis\allvisits" 

2025-01-25 LG update 
1. fixed typo from lab var to lab val for the lab values of subnodever 

2025-02-28 Ying updated
use imp_onset_date from allinf and allcomor since already updated in each setup 
*/ 

**************************************************************************

* created current using (nsaid, analgesics, opioid) 

use clean_table\1_3_conmeds_$datacut, clear 

drop if conmed_status=="past" | conmed_status=="unknown" | conmed_status=="stop" 
destring full_version site_number, replace 

// 2025-04-04 changed from 998 to 997
drop if site_number>=997 

keep  if strpos(conmed_section, "NSAID") | strpos(conmed_section, "analgesics") 

gen drugcat="nsaiduse" if strpos(conmed_section, "NSAID") 
replace drugcat="analgesics" if conmed_section=="SU analgesics" 
replace drugcat="opioid" if (drugkey=="narcotic" | drugkey=="tyleno_cod")   

sort subject_number visitdate drugcat drugkey 
by subject_number visitdate drugcat: drop if _n>1  

sort subject_number visitdate drugcat 
keep subject_number visitdate drugcat 

encode drugcat, gen(grp) 
reshape wide grp , i(subject_number visitdate) j(drugcat) string 

lab define ny 0 no 1 yes, modify 
foreach x in nsaiduse opioid analgesics {
gen `x'= grp`x' >=1 & grp`x' <.
drop grp`x'  
lab val `x' ny 
}
replace analgesics=1 if opioid==1  

sort subject_number visitdate 

lab var nsaiduse "NSAIDs use"
lab var opioid "Opioid use"
lab var analgesics "Analgesics use" 

unique subject_number visitdate 
save temp\temp_nsaids, replace 

***************************************************
* history of comorbidities, reshape to wide 

use clean_table\1_7_allcomor_$datacut, clear 
 
unique subject_number visitdate comor_type imp_onset_date comor_type_txt if comorkey!="fracture" & strpos(comorkey, "oth")==0 

sort subject_number visitdate comorkey imp_onset_date comor_type comor_type_txt location 
by subject_number visitdate comorkey imp_onset_date: gen vn=_n if comorkey!="fracture" & strpos(comorkey, "oth")==0 
by subject_number visitdate comorkey imp_onset_date: gen vN=_N if comorkey!="fracture" & strpos(comorkey, "oth")==0  
tab vN if vn==1 

tab comor_type vn if vN==2 & comorkey=="ulcer" 

* duplicate bleeding ulcer and peptic ulcer on same onset date 
drop if comor_type=="bleeding ulcer" & vN==2 & comorkey=="ulcer" 
drop vn vN

* duplicate comors not fracture or other 
sort subject_number visitdate comorkey imp_onset_date comor_type comor_type_txt location 
by subject_number visitdate comorkey imp_onset_date: gen vn=_n if comorkey!="fracture" & strpos(comorkey, "oth")==0 
by subject_number visitdate comorkey imp_onset_date: gen vN=_N if comorkey!="fracture" & strpos(comorkey, "oth")==0  
tab vN if vn==1 
*br subject_number visitdate comorkey comor_type imp_onset_date  vn if vN==2 
drop if vn==2  

drop vn vN 

gen comortxt=lower(comor_type_txt) 
tab comortxt if comorkey=="oth_cond" & strpos(comortxt, "cancer") , sort 

replace comorkey="skin_cancer_squa" if comortxt=="basal cell cancer" | comortxt=="squamos cell cancer" 
replace comorkey="skin_cancer_unk" if comorkey=="oth_cond" & strpos(comortxt,"skin cancer") 

foreach x in bladder pancreatic thyroid ovarian pancreatic renal brain kidney rectal liver testicular tongue esophageal gastric "small cell"  {
    replace comorkey="oth_cancer" if comorkey=="oth_cond" & strpos(comortxt, "cancer") & strpos(comortxt, "`x'")
}

replace comorkey="oth_cancer" if comorkey=="oth_cond" & comortxt=="cancer" 
drop comortxt 

unique subject_number visitdate comorkey imp_onset_date comor_type comor_type_txt location 

sort subject_number comorkey imp_onset_date 
by subject_number comorkey: gen fstdt=imp_onset_date[1] 
format fstdt %tdCCYY-NN-DD 

sort subject_number visitdate comorkey imp_onset_date 

save temp\temp_allcomor, replace  

************************************** 
use temp\temp_allcomor, clear 

*link to allvisit
// 2025-02-06 changed var name dw_event_instance_uid
keep subject_number visitdate dw_event_type_acronym c_dw_event_instance_key
bysort subject_number visitdate: drop if _n>1 
save temp\temp_comorvisit, replace 

use subject_number visitdate using "clean_table\1_2_allvisits_$datacut", clear 

sort subject_number visitdate 
by subject_number: gen lastvisit=visitdate[_N] 
format lastvisit %tdCCYY-NN-DD 

merge 1:1 subject_number visitdate using temp\temp_comorvisit 

clonevar link_visit=visitdate if _m==1| _m==3 

gsort subject_number -visitdate - _m 
by subject_number: replace link_visit=link_visit[_n-1] if _m==2 & link_visit==. & link_visit[_n-1]<. 
 
sort subject_number visitdate _m 
by subject_number: replace lastvisit=lastvisit[_n-1] if lastvisit==. 

count if link_visit==. & visitdate>lastvisit // TAEs after last subject visits 
* link to last visit if comor reported after last visit 

by subject_number: replace link_visit=link_visit[_n-1] if link_visit==. & link_visit[_n-1]<. & visitdate>lastvisit 

tab dw_event_type_acronym  if link_visit==.  // subject only have TAEs, no subject visit, can't link. 

tab _m 

drop if _m==1 

keep subject_number visitdate link_visit 

merge 1:m subject_number visitdate using temp\temp_allcomor 
drop _m 

count if link_visit==. // 20 only have TAEs 

lab var link_visit "linked office visit" 
 
unique subject_number visitdate comorkey comor_type comor_type_txt location 

sort subject_number visitdate comorkey  
save temp\1_7_allcomor_linked, replace // LG changed from clean_table folder to temp folder for codebook automation

erase temp\temp_comorvisit.dta 
erase temp\temp_allcomor.dta 


*keep subject_number visitdate comorkey comor_type location imp_onset_date full_version site_number dw_event_type_acronym serious targeted 

use temp\1_7_allcomor_linked, clear 

* reshape to wide format for history of comorbidities 

sort subject_number visitdate comorkey imp_onset_date 
by subject_number visitdate comorkey: drop if _n>1  // only keep first comor onset at same visit date 
by subject_number visitdate comorkey: drop if _n==_N & imp_onset_date>visitdate // drop if TAEs reported after last subject visit 

sort subject_number comorkey imp_onset_date visitdate 
by subject_number comorkey: gen fstdt_= imp_onset_date[1] if comorkey==comorkey[1] 

keep subject_number visitdate comorkey fstdt_ 
encode comor, gen(comor_)  

reshape wide comor_  fstdt_, i(subject_number visitdate) j(comorkey) string 

sort subject_number visitdate 

lab define ny 0 no 1 yes, modify 

ds comor_*, v(32)  

local list acs alopecia anemia anxiety arthritis_ost asthma attempt_sui bc bio_reaction boop bowel_perf cancer_cer cancer_colon cancer_pro cancer_ute card_arrest carotid chf chf_nohosp copd cor_art_dis dementia demyelin depression diabetes diag_cath diarrhea drug_ind_sle dyspepsia edema elev_creat emphysema fib fm fracture gerd hematolog_dis hemiplegia_paraplegia hemorg_hosp hemorg_nohosp hepatic_nobiop hepatic_oth_noseri hepatic_wbiop hld htn htn_hosp kidney_acu kidney_chr lc leukemia liver_dis lung_oth lymphoma malignancy_pre medical_surg metabolic_oth mi myeloma_mul nausea new_gout_wors osteopenia osteoporosis oth_cancer oth_clot oth_cond oth_gi oth_neuro other_cv pat_event pef_art_dis pi pml psoriasis psychiatric pulm_emb rash revasc rheum_nodules rheum_pleurisy sjogrens_sec skin_cancer_mel skin_cancer_squa skin_cancer_unk stroke sub_nodules thoughts_suic tia ulcer unstab_ang urg_par vascular_oth ven_arrhythm wbc_low

 foreach x of local list { 
    replace comor_`x'=1 if comor_`x'<. & comor_`x'>0 
	lab val comor_`x' ny 
}

drop if visitdate==. 

sort subject_number visitdate 
save temp\temp_comor, replace 


********************************************************************

* created history of serious infection (hosp/iv) since version 7 
// 2025-03-05 LG uncommented #218 and commented #221 for 2025-02-28 code 
use "clean_table\1_8_allinf_$datacut", clear 
*Ying 2025-02-21 revise 

*use temp\allinf_clean, clear 

destring full_version site_number, replace 

gen inf_serious=1 if (serious=="yes" | iv_antiinfectives=="yes" )  // hosp/iv infection started since version 7 

keep if inf_serious==1 

* keep first onset date for serious infection  
sort subject_number inf_serious imp_onset_date visitdate
by subject_number inf_serious: gen fstdt_inf_serious=imp_onset_date[1] 
assert fstdt_inf_serious<. 
 
* keep first event row for each visitdate 
sort subject_number visitdate imp_onset_date dw_event_type_acronym  
by subject_number visitdate: keep if _n==1 

drop if site_number>=998 

keep subject_number visitdate full_version dw_event_type_acronym study_acronym source_acronym site_number inf_serious imp_onset_date fstdt_inf_serious   
rename imp_onset_date inf_serious_dt 
save temp\temp_inf2, replace 

/****************************************************
* history of drug 
use subject_number visitdate dw_event_type_acronym study_acronym source_acronym site_number c_provider_id full_version hx_* drug_key generic_key using "2_1_DrugExpDetails", clear  
destring site_number full_version , replace 
bysort subject_number visitdate: drop if _n<_N  
ds hx_*, v(32) 

tab dw_event_type_acronym 
save temp\temp_hxdrug, replace 

*****************************************************************************************************************************/

* merge all baseviwe data of lab, imaging, comor, inf, radrug, othmed, subjects) with longitudinal data 

use "clean_table\1_2_allvisits_$datacut", clear 

unique subject_number visitdate 

sort subject_number visitdate 
merge m:1 subject_number using "clean_table\1_1_subjects_$datacut", keepus(height_in_tot symptom_year race_* c_education famhx_* hispanic birthyear female_male diagnosis_year exit_* death_dt marital_status) 
drop if site_number>=998 
drop if _m<3 
drop _m 

sort site_number 
merge m:1 site_number using temp\temp_sites 

drop if _m==2 
drop _m 


foreach x in radrug conmed lab imaging comor infection { 
	replace `x'_yn=0 if `x'_yn==. 
	lab val `x'_yn ny 
	lab var `x'_yn "with data `x'" 
} 

*list site_number subject_number visitdate event_instance dw_event_type_acronym study_source_acronym if labonly==1 & site_number<998, noobs ab(30) sep(0) 
// one subject in TM removed from EDC 

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_comor 
rename _m taecomor 

ds x_surgeries_*, v(32) 

*tab dw_event_type_acronym if _m==2 

sort subject_number visitdate  

* hx_comor_X=1 if visitdate later than first onset date 
//pml no data yet 
local list acs alopecia anemia anxiety arthritis_ost asthma attempt_sui bc bio_reaction boop bowel_perf cancer_cer cancer_colon cancer_pro cancer_ute card_arrest carotid chf chf_nohosp copd cor_art_dis dementia demyelin depression diabetes diag_cath diarrhea drug_ind_sle dyspepsia edema elev_creat emphysema fib fm fracture gerd hematolog_dis hemiplegia_paraplegia hemorg_hosp hemorg_nohosp hepatic_nobiop hepatic_oth_noseri hepatic_wbiop hld htn htn_hosp kidney_acu kidney_chr lc leukemia liver_dis lung_oth lymphoma malignancy_pre medical_surg metabolic_oth mi myeloma_mul nausea new_gout_wors osteopenia osteoporosis oth_cancer oth_clot oth_cond oth_gi oth_neuro other_cv pat_event pef_art_dis pi pml psoriasis psychiatric pulm_emb rash revasc rheum_nodules rheum_pleurisy sjogrens_sec skin_cancer_mel skin_cancer_squa skin_cancer_unk stroke sub_nodules thoughts_suic tia ulcer unstab_ang urg_par vascular_oth ven_arrhythm wbc_low 
foreach x of local list {  
cap drop hx_comor_`x'
sort subject_number fstdt_`x'  
by subject_number: replace fstdt_`x'=fstdt_`x'[1] if fstdt_`x'==. 
gen hx_comor_`x'=visitdate>fstdt_`x'  
lab var hx_comor_`x' "History of `x'"  
lab val hx_comor_`x' ny 
drop fstdt_`x' 
}  

*list subject_number visitdate dw_event_type_acronym comor_chf hx_comor_chf comor_chf_dt fstdt_chf _m  if subject_number=="671153607",noobs ab(30) sep(0) 
drop  if taecomor==2 
drop taecomor 

*list subject_number visitdate dw_event_type_acronym comor_chf hx_comor_chf comor_chf_dt fstdt_chf  if subject_number=="671153607" & inftae!=2, noobs ab(30) sep(0) 


// version clean comorbidities 

foreach x in  unstab_ang lc bc fib asthma copd anemia depression {
replace hx_comor_`x' =. if full_version<7
replace comor_`x' =. if full_version<7
}

foreach x in hld acs tia skin_cancer_mel skin_cancer_squa bowel_perf fm {
replace hx_comor_`x'=. if full_version<8
replace comor_`x'=. if full_version<8
}

foreach x in revasc ven_arrhythm card_arrest other_cv hemorg_hosp hemorg_nohosp oth_neuro {   // no pml 
replace hx_comor_`x'=. if full_version<9
replace comor_`x'=. if full_version<9
} 
 
// maybe pml is only for v10?  // no more hxchf_nohosp 
// 2022-04-01 lung dis is for v4-6 general lung dis , v10-11 combined with fib lung_dis 
qui foreach x in cor_art_dis carotid pi pat_event urg_par pulm_emb {
replace hx_comor_`x'=. if full_version<10
replace comor_`x'=. if full_version<10 
}

foreach x in osteoporosis bio_reaction{ 
replace hx_comor_`x'=. if full_version<12
replace comor_`x'=. if full_version<12
}

foreach x in psoriasis {
replace hx_comor_`x'=. if full_version<6
replace comor_`x'=. if full_version<6
} 
 
gen hx_comor_cvd=0
foreach x in revasc ven_arrhythm card_arrest mi acs unstab_ang chf stroke tia other_cv pef_art_dis oth_clot carotid cor_art_dis pulm_emb {
replace hx_comor_cvd=1 if hx_comor_`x'==1
} 
notes hx_comor_cvd: including hx of revasc ven_arrhyth card_arrest mi acs unstab_ang chf chf_nohosp  stroke tia other_cv pef_art_dis oth_clot carotid cor_art_dis pulm_emb
lab var hx_comor_cvd "History of CVD" 
lab val hx_comor_cvd ny 

gen hx_comor_cancer=0
foreach x in lymphoma lc bc skin_cancer_mel leukemia cancer_cer cancer_colon cancer_pro cancer_ute oth_cancer { 
replace hx_comor_cancer=1 if hx_comor_`x'==1
} 
notes hx_comor_cancer: including hx of lymphoma lc bc skin_cancer_mel leukemia cancer_cer cancer_colon cancer_pro cancer_ute oth_cancer
lab var hx_comor_cancer "History of cancer excluding non-melanoma or unknown skin cancer"
lab val hx_comor_cancer ny 

gen hx_comor_cancer_all=hx_comor_cancer==1 | hx_comor_skin_cancer_squa==1 | hx_comor_skin_cancer_unk==1 
notes hx_comor_cancer: including hx of lymphoma lc bc leukemia cancer_cer cancer_colon cancer_pro cancer_ute oth_cancer skin_cancer_mel skin_cancer_squa skin_cancer_unk 
lab var hx_comor_cancer_all "History of any cancer"
lab val hx_comor_cancer_all ny  


* merge with allinf serious infection (hosp/iv) 
// 2025-03-05 LG changed 371 to temp_inf2
sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_inf2  

* carry forward history of serious infection  

foreach x in inf_serious { 
sort subject_number fstdt_`x' 
by subject_number: replace fstdt_`x' = fstdt_`x'[1] if fstdt_`x'==. 
gen hx_`x'=visitdate > fstdt_`x'  	
} 

replace hx_inf_serious=. if full_version<=6 
lab val hx_inf_serious ny 
lab var hx_inf_serious "History of serious infection" 

drop if _m ==2 
drop _m fstdt_inf_serious inf_serious_dt 

*********************nsaids, opioid and analgesics ******************

sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_nsaids 
assert _m!=2 
 
/*list subject_number visitdate if _m==2, noobs ab(16)
  +-----------------------------+
  | subject_number    visitdate |
  |-----------------------------|
  |      254010199   2024-12-02 |==> 2024-12-05 out of range 
  +-----------------------------+

drop if _m==2*/
drop _m 

for any nsaiduse opioid analgesics: replace X=0 if X==. 
for any nsaiduse opioid analgesics: tab X, m 
lab var nsaiduse "NSAIDs use"
lab var opioid "Opioid use"
lab var analgesics "Analgesics use" 

sort subject_number visitdate 

save temp\temp_allvisits, replace 


use temp\temp_allvisits, clear 


* Rich 2024-04-23 email: site has confirmed subject's visit after death_date are incorrect, will be removed: 154010035 254010086 205060061 015001015
* Rich 2024-05-14 email updated add: 038010143 

foreach x in 154010035 254010086 205060061 015001015 038010143 {
    list subject_number visitdate death_dt exit_reason exit_form_date if subject_number=="`x'" & visitdate>death_dt , noobs ab(30) 
	drop if subject_number=="`x'" & visitdate>death_dt 
} 


* check visit after death_dt, we can't confirm from site because site inactive, drop those visits if FU visit after exit form date and death_dt 
by subject_number: gen ck=1 if visitdate>death_dt & visitdate>exit_form_date 
list site_number status subject_number visitdate exit_form_date exit_reason death_dt if ck==1, noobs ab(20) 
*drop if ck==1 
drop ck 
for any 002021166 002022891 002032350 006040078 015001227 160010207: list subject_number visitdate exit_form_date exit_reason death_dt if subject_number=="X", noobs ab(16) sepby(subject_number)
count if visitdate>death_dt & visitdate>exit_form_date // 6

// 2025-04-10 LG dropping 6 visits from the 6 subjects because their visitdate is later than both exit_form_date and death_dt; checked, the 6 visits are all the last visits for the subjects. 
drop if visitdate>death_dt & visitdate>exit_form_date

/*
2025-04-10 updated exit form date 
  +-----------------------------------------------------------------------------------------------------------+
  | site_number              status   subject_number    visitdate   exit_form_date   exit_reason     death_dt |
  |-----------------------------------------------------------------------------------------------------------|
  |           2   Approved / Active        002021166   2020-04-01       2020-03-26         death   2016-04-20 |
  |           2   Approved / Active        002022891   2020-08-20       2020-04-23         death   2018-11-08 |
  |           2   Approved / Active        002032350   2024-04-09       2024-03-08         death   2024-03-01 |
  |           6   Approved / Active        006040078   2021-12-21       2021-03-02         death   2021-03-02 |
  |          15   Approved / Active        015001227   2022-05-02       2021-03-04         death   2021-02-24 |
  |-----------------------------------------------------------------------------------------------------------|
  |         160   Approved / Active        160010207   2024-10-24       2022-02-10         death   2020-12-30 |
  +-----------------------------------------------------------------------------------------------------------+

 one subject had visits after death but we can't confirm from site because site closed, keep visits for now 
  +------------------------------------------------------------------------------------------------------------+
  | site_number               status   subject_number    visitdate   exit_form_date   exit_reason     death_dt |
  |------------------------------------------------------------------------------------------------------------|
  |          14   Closed / Completed        014010150   2019-03-22       2018-09-20         death   2018-03-23 |
  |          14   Closed / Completed        014010150   2019-10-04       2018-09-20         death   2018-03-23 |
  |          14   Closed / Completed        014010150   2020-05-11       2018-09-20         death   2018-03-23 |
  |          14   Closed / Completed        014010150   2021-02-16       2018-09-20         death   2018-03-23 |
  |          14   Closed / Completed        014010150   2021-12-01       2018-09-20         death   2018-03-23 |
  +------------------------------------------------------------------------------------------------------------+ 
  */ 

* calculate variables  

sort subject_number visitdate 
by subject_number: gen indexn=_n 
by subject_number: gen indexN=_N  

gen death=exit_reason==3

clonevar form= dw_event_type_acronym
replace form="FU" if dw_event_type_acronym=="RFU" 

gen active_site= strpos(status, "Active")>0  if status!=""  

/*Kaliee updated active-inactive_subjects definition for registries_2023_12-07

Active status is defined as meeting all of the following criteria: 
•	Subject has not been exited OR a registry visit occurs within 30-days after the subject’s exit date
•	Subject belongs to an active site
•	Subject has completed a registry visit within the last 18-months
•	[FOR ADOLESCENT REGISTRIES ONLY] Subject is less than 18 years old

*/ 

gen dt = c(current_date) 
replace dt="01" + substr(dt, 3, 11) 
gen curr_dt = date(dt, "DMY")

gen active_pt=active_site==1 & exit_form_date==. 
by subject_number: replace active_pt=1 if exit_form_date-visitdate[_N] <=30 & !missing(exit_form_date) & active_site==1 
by subject_number: replace active_pt=0 if active_pt==1 & (curr_dt-visitdate[_N])> 548  
replace active_pt=0 if death==1 
drop curr_dt dt 


for any active_pt active_site death: lab val X ny 


by subject_number: gen ck=1 if _n==_N & visitdate-exit_form_date<=30 & active_site==1 & active_pt==0 & exit_form_date<. 
tab ck 
tab active_pt if indexn==1

lab var death "Subject died" 
lab var active_site "Active site"
lab var active_pt "Active subject" 
notes: subject's last visit in 18 months 

sort subject_number visitdate 
by subject_number: replace weight_lb=weight_lb[_n-1] if weight_lb==. & weight_lb[_n-1]<. 
gsort subject_number -visitdate
by subject_number: replace weight_lb=weight_lb[_n-1] if weight_lb==. & weight_lb[_n-1]<. 


* Body Mass Index (BMI) – (acceptable range 13-80 based on the WHO BMI categories) * cleaned after bmi file 
gen double bmi=(weight_lb/2.205)/((.3048*height_in_tot/12)^2) 
lab var bmi "BMI" 

replace bmi=. if bmi<13 | bmi>80 

sort subject_number visitdate 
by subject_number: replace bmi=bmi[_n-1] if bmi==. & bmi[_n-1]<.
gsort subject_number -visitdate
by subject_number: replace bmi=bmi[_n-1] if bmi==. & bmi[_n-1]<. 

sort subject_number visitdate 
egen bmi_cat4=cut(bmi) if bmi<., at(0, 18.5, 25, 30, 81) icode 
egen bmi_cat3=cut(bmi) if bmi<., at(0, 25, 30, 80.1) icode 
lab define bmi3 0 "Underweight/Normal" 1 Overweight 2 Obese, modify 
lab define bmi4 0 Underweight 1 Normal 2 Overweight 3 Obese, modify 
for any 3 4: lab val bmi_catX bmiX 
for any 3 4: lab var bmi_catX "BMI(Cat.X)" 


lab define race_cat7 1 "White" 2 "African American" 3  "Asian" 4  "American Indian/Alaska Native" 5  "Native Hawaiian/Pacific Islander" 6  "Multiracial" 7 "Other" , modify

egen multi = rowtotal(race_white race_black race_asian race_native_am race_pacific race_other), missing
generate race_cat7=1 if race_white==1 & multi==1
replace race_cat7=2 if race_black==1 & multi==1
replace race_cat7=3 if race_asian==1 & multi==1
replace race_cat7=4 if race_native_am==1 & multi==1
replace race_cat7=5 if race_pacific==1 & multi==1
replace race_cat7=6 if multi > 1 & !missing(multi)
replace race_cat7=7 if race_other==1 & multi==1
drop multi
lab val race_cat7 race_cat7 
lab var race_cat7 "Race group (7 category)" 

lab define race_cat4 1  "White" 2 "African American" 3 "Asian" 4 "Other", modify
recode race_cat7 (5 6 7=4), gen(race_cat4)
lab val race_cat4 race_cat4 
lab var race_cat4 "Race group (4 category)" 


lab define race_hisp 1  "White, Non-Hispanic" 2 "Black, Non-Hispanic" 3  "Asian, Non-Hispanic" 4 "Other/Multiracial Non-Hispanic" 5 "Hispanic", modify 

gen race_hisp_cat5= race_cat4 
replace race_hisp_cat5=. if missing(hispanic)
replace race_hisp_cat5= 5 if hispanic==1
lab val race_hisp_cat5 race_hisp
lab var race_hisp_cat5 "Combined race/ethnicity (5 category)" 

cap drop edu_cat4 
gen edu_cat4=1 if c_education<=1 
replace edu_cat4= c_education if c_education>=2 & c_education<=4 
replace edu_cat4=4 if c_education==5
lab define edu4 1 "12th grade or less" 2 "High school graduate/GED" 3 "Some college/associate degree" 4 "College graduate or higher", modify 
lab val edu_cat4 edu4
lab var edu_cat4 "Final education" 


for any medicare medicaid private va_military: replace insurance_yes_no=1 if insurance_X==1 

*gen insurance_none=insurance_yes_no==0 if insurance_yes_no<. 
for any medicare medicaid private va_military none: replace insurance_X=0 if insurance_X==. & insurance_yes_no<. 
lab val insurance_none ny 
lab var insurance_none "No insurance" 


 /* 
 
clean age: 
if age at enrollment >130 as missing, consider birthyear incorrect 
if age>90, replace to 90 

clean duration of ra: replace to missing if duration_ra>=age 
*/ 

sort subject_number visitdate 
gen age=year(visitdate)-birthyear if birthyear<. 
by subject_number: replace age=. if age[1] > 130   
replace age=90 if age>90 & age<.  
lab var age "Age" 
 
gen yr_onset_ra=diagnosis_year 
replace yr_onset_ra=symptom_year if (yr_onset_ra-birthyear<10 | yr_onset_ra==.) & symptom_year<. // use subject report start symptom as onset if age_onset_ra<10 
lab var yr_onset_ra "RA onset year" 

gen age_onset_ra=yr_onset_ra-birthyear  // prior algorithm consider as 90 if age onset > 90 
replace age_onset_ra=90 if age_onset_ra>90 & age_onset_ra<.
replace age_onset_ra=. if age_onset_ra<0  // replace to missing if age onset ra <0 
lab var age_onset_ra "Age at onset RA" 

gen duration_ra=year(visitdate)- diagnosis_year if age_onset_ra<. 
replace duration_ra=. if duration_ra<0 | duration_ra>=age & duration_ra<. 

replace duration_ra=year(visitdate)-symptom_year if duration_ra==. & age_onset_ra<. 
replace duration_ra=. if duration_ra<0 | duration_ra>=age 

lab var duration_ra  "Duration of RA" 
lab var yr_onset_ra "Year of onset RA" 


*  smoker indicator 
destring smoke_perday smoke_n_perday , replace 
label define smoker 0 "Never" 1 "Previous" 2 "Current", modify 
 
gen smoker3=0 if smoking_cigs==0 & full_version<=7
replace smoker3=1 if smoking_cigs==2 & full_version<=7 
replace smoker3=2 if (smoking_cigs==1 | smoking_cigs==3) & full_version<=7 

sort subject_number visitdate
by subject_number: replace smoker3=1 if smoking_cigs==0 & smoker3[_n-1]==1 & full_version<=7
by subject_number: replace smoker3=2 if smoking_cigs==0 & smoker3[_n-1]==2 & full_version<=7 

replace smoker3=0 if full_version>=8 & form== "EN" & smoke_ever_100==0 
replace smoker3=1 if full_version>=8 & form=="EN" & smoke_current==0 & smoke_ever_100==1 

replace smoker3=2 if full_version>=8 & smoke_current==1 | smoke_perday>0 & smoke_perday<. & form=="FU" 
replace smoker3=2 if full_version>=8 & form=="FU" & smoke_start==1 

by subject_number: replace smoker3=smoker3[_n-1] if full_version>=8 & form=="FU" & (smoke_start==. | smoke_start==0) & (smoke_quit==. | smoke_quit==0) & smoker==.  
replace smoker3=1 if full_version>=8 & form=="FU" & smoke_quit==1 

by subject_number: replace smoker3=smoker3[_n-1] if smoker3==. & full_version<=7 
by subject_number: replace smoker3=1 if smoking_cigs==. & smoker3[_n-1]==1 & full_version<=7
by subject_number: replace smoker3=2 if smoking_cigs==. & smoker3[_n-1]==2 & full_version<=7
by subject_number: replace smoker3=1 if smoker==0  &  (smoker3[_n-1]==1 | smoker3[_n-1]==2) & full_version<=7 
	
replace smoker3=2 if full_version>=8 & form=="FU" & smoke_perday>0 & smoke_perday<. & smoke_quit!=1  
by subject_number: replace smoker3=smoker3[_n-1] if smoker3==. & full_version>7  
by subject_number: replace smoker3=1 if smoker3[_n-1]==1 & smoker3==0 & full_version>7 
by subject_number: replace smoker3=smoker3[_n-1] if smoker3==. 
by subject_number: replace smoker3=2 if smoker3[_n-1]==2 & smoker3<2 & smoke_quit!=1 & full_version>7 & smoke_perday==. & form=="FU" 
by subject_number: replace smoker3=smoker3[_n+1] if smoker3==. & smoker3[_n+1]==smoker3[_n+2] 

* if prior visit missing smoker, carry smoke status to prior visit 
by subject_number: replace smoker3=smoker3[_n+1] if smoker3==. & smoker3[_n+1]<. 
lab var smoker3 "Smoking status" 
lab val smoker3 smoker 


for any hrs mins: replace am_stiff_X=. if am_stiff_X<0 
gen amstifftime=am_stiff_hrs + am_stiff_mins/60 
replace amstifftime=am_stiff_hrs if am_stiff_mins==. 
replace amstifftime=am_stiff_mins/60 if am_stiff_hrs==. 
replace amstifftime=0 if am_stiffness==0
lab var amstifftime "Morning stiffness time(in hrs)" 
replace amstifftime=. if amstifftime<0|amstifftime>24  


* rapid3 
gen double rapid3=((haq_dress_yourself + haq_get_in_out_bed + haq_lift_cup_glass + haq_walk_outdoors + haq_wash_dry_body + haq_bend_down_pick_up + haq_turn_faucets + haq_get_in_out_car + haq_climb_5_steps + haq_chores)/3+ pt_pain/10 + pt_global_assess/10) 
replace rapid3=((haq_get_in_out_bed + haq_lift_cup_glass + haq_walk_outdoors + haq_wash_dry_body + haq_bend_down_pick_up + haq_turn_faucets + haq_get_in_out_car)/2.4 + pt_pain/10 + pt_global_assess/10) if rapid3==. 

lab var rapid3 "RAPID3 (0-30)" 
note rapid3: based on Lang's algorithm
note rapid3: climb_5_steps and vacuuming are not available for versions 6-7, so the other 8 HAQ items are used and devided by 2.4 when those two items are not applicable.  

destring haq_di, replace 
replace haq_di=. if full_version>4 & full_version<8 

* mHAQ score (di) 

* test di ENG calculated, is OK 
rename di di_calc 
gen haqraw=0
gen dinmiss=0
local list haq_dress_yourself haq_get_in_out_bed haq_lift_cup_glass haq_walk_outdoors haq_wash_dry_body haq_bend_down haq_turn_faucets haq_get_in_out_car 
foreach x of local list{
qui replace haqraw=haqraw+`x' if `x'>0 & `x'<=3 
qui replace dinmiss=dinmiss+1 if `x'>=0 & `x'<=3 
} 

gen double di=haqraw/dinmiss if dinmiss>=6 
lab var di "mHAQ (>=6 domain)"  

assert di_calc==. if dinmiss<6  
drop haqraw dinmiss di_calc 
 
*assert cdai==. if (tender_jts_28 ==. | swollen_jts_28==. | md_global_assess==. | pt_global_assess==.)  
cap drop cdai  // ENG created cdai 

gen double cdai=tender_jts_28+swollen_jts_28 + pt_global_assess/10 + md_global_assess/10 
lab var cdai "CDAI" 

* CDAI categories in 3 or 4 level based on Oksana requests  
egen cdai_cat4=cut(cdai) if cdai<., at(0, 2.8001, 10.001, 22.001, 77) icode 
egen cdai_cat3=cut(cdai) if cdai<., at(0, 10.001, 22.001, 77) icode  
lab define cdai4f 0 "Remission" 1 "low" 2 "Moderate" 3 "High", modify 
lab define cdai3f 0 "Remission/low" 1 "Moderate" 2 "High", modify 
for any 3 4: lab val cdai_catX cdaiXf 
for any 3 4: lab var cdai_catX "CDAI (Cat. X)"  

*SDAI
gen double sdai=tender_jts_28 + swollen_jts_28 + (pt_global_assess/10) + (md_global_assess/10) + crp_mgl/10 
lab var sdai "SDAI" 

* DAS scores and modified DAS 
replace esr=. if esr<0 | esr > 150 
gen dasesr=0.56*sqrt(tender_jts_28) + 0.28*sqrt(swollen_jts_28) + 0.70*log(esr) +0.014*pt_global_assess
lab var dasesr "DAS(ESR)" 
* notes: if esr is between 0 and 1, then log esr will be negative, which might cause negative das values


gen dascrp=.56*sqrt(tender_jts_28) + .28*sqrt(swollen_jts_28) + .36*ln(crp_mgl+1) + 0.014*pt_global_assess + 0.96 
lab var dascrp "DAS(CRP)" 

gen mdas=0.53*sqrt(tender_jts_28) + 0.31*sqrt(swollen_jts_28) + 0.25*di + 0.001*pt_pain + 0.005*md_global_assess + 0.014*pt_global_assess + 1.694 
lab var mdas "Modified DAS28" 

gen ccphighpos=ccp>=250 if ccp<. 
lab var ccphighpos "CCP high positive (>=250)"

gen erosdis=erosions>0 if erosions<.  
lab var erosdis "Erosive disease"  

gen jtspnarrow=jt_sp_narrow>0 if jt_sp_narrow<. 
lab var jtspnarrow "JT space narrowing" 

gen jtdeform=deformity>0 if deformity<. 
lab var jtdeform "Joint deformity"


* ever had rf and ccp positive using new X_pos_ever at version 15 enrollment form 

foreach x in rf ccp {
gen `x'nm=1 if `x'pos<. | `x'_pos_ever<. 
gen `x'p=1 if `x'pos==1 | `x'_pos_ever==1 
by subject_number: gen cum`x'nm=sum(`x'nm) 
by subject_number: gen `x'posever=sum(`x'p) 
replace `x'posever=1 if `x'posever>1 & `x'posever<. 
replace `x'posever=. if `x'posever==0 & cum`x'nm==0   
lab val `x'posever ny 
drop `x'nm cum`x'nm `x'p `x'_pos_ever 
}

* ever indicators as cumulative measures 
foreach x in ccphighpos erosdis jtspnarrow jtdeform  { 
capture drop `x'ever 
gen `x'nm=1 if `x'<.
by subject_number: gen cum`x'nm=sum(`x'nm)
by subject_number: gen `x'ever=sum(`x') 
replace `x'ever=1 if `x'ever>1 & `x'ever<. 
replace `x'ever=. if `x'ever==0 & `x'==. & cum`x'nm==0   
lab val `x' ny 
lab val `x'ever ny 
drop `x'nm cum`x'nm 
} 

lab var rfposever "RF+ ever" 
lab var jtspnarrowever "JT space narrowing ever"
lab var erosdisever "Erosive disease ever"
lab var jtdeformever "Joint deformity ever"
lab var ccpposever "CCP+ (>=20) ever"
lab var ccphighposever "CCP high positive (>=250) ever" 

gen subcnm=1 if subcutan_nods<.
by subject_number: gen cumsubcnm=sum(subcnm)
by subject_number: gen subnodever=sum(subcutan_nods)
replace subnodever=1 if subnodever>1 & subnodever<.
replace subnodever=. if subnodever==0 & subcutan_nods==. & cumsubcnm==0 
lab val subnodever ny
lab var subnodever "Subcutaneous nodules ever" 
drop subcnm cumsubcnm 


/* 
Oksana 2023-11-6 eamil: 
Based on how the query team uses alcohol variable in the analysis, can we have the following set of variables in the analytic file?
1.	Original variables drink_freq and drink_n_perday with the skip pattern that is coming from DRINK_RECENT incorporated into the variables
2.	DRINKING_ETOH with 6 categories: 0 = Not at all; 1 = 1-3 drinks per week; 2 = 4-6 drinks per week; 3 = 1-2 drinks per day; 4 = 3 drinks or more daily; 5 = occasion 
3.	Recoded DRINKING_ETOH with 5 categories: 0 = None/<1 drink per week ; 1 = 1-3 drinks per week; 2 =4-6 drinks per week; 3= 1-2 drinks per day; 4 = 3 drinks or more daily
4.	Recoded DRINKING_ETOH with 2 categories: 0 = None/<1 drink per week ; 1 = 1 drink per week or more

* need add category for 3-6 drinks per week 
*/

* drinker yes/no : any variable reported drinking, consider as drinker 

gen drink_yn=(drinking_etoh>0 & drinking_etoh<. | drink_n_perday>0 & drink_n_perday<. | drink_times>0 & drink_times<. | drinks_status==1 ) if drinking_etoh<. | drink_times<. | drink_n_perday<. |  drinks_status<. | drink_none<. 
lab val drink_yn ny 
lab var drink_yn "Drinking status (yes/no)" 

* drinking frequency 
lab define drinkf 0 none 1 "every day" 2 "5-6 times a week" 3 "4 times a week" 4 "3 times a week" 5 "twice a week" 6 "once a week" 7 "2-3 times a month" 8 "once a month"  9 "less than once a month" 10 "1-3 per week" 11 "1-2 per day" 12 "3 or more daily"  13 "occasionally" , modify 

cap drop drink_freq 
clonevar drink_freq=drinking_etoh 

replace drink_freq=1 if (drink_times_dwm==1 & drink_times>=1 & drink_times<. | drink_times>=7 & drink_times<. & drink_times_dwm==2) & drink_freq==. // daily 
replace drink_freq=1 if drink_times>=28 & drink_times<. & drink_times_dwm==3  & drink_freq==. 

replace drink_freq=2 if (drink_times==5 | drink_times==6) & drink_times_dwm==2 & drink_freq==. // 5-6 times per week 
replace drink_freq=2 if drink_times>=20 & drink_times<28 & drink_times_dwm==3 & drink_freq==.	
  
replace drink_freq=3 if drink_times==4 & drink_times_dwm==2 & drink_freq==.  // 4 times per week 
replace drink_freq=3 if drink_times>=16 & drink_times<20 & drink_times_dwm==3  & drink_freq==.  

replace drink_freq=4 if drink_times==3 & drink_times_dwm==2 & drink_freq==.  // 3 times per week 
replace drink_freq=4 if drink_times>=12 & drink_times<16 & drink_times_dwm==3  & drink_freq==. 

replace drink_freq=5 if drink_times==2 & drink_times_dwm==2 & drink_freq==.  // twice a week 
replace drink_freq=6 if drink_times==1 & drink_times_dwm==2 & drink_freq==. // once a week 

replace drink_freq=7 if (drink_times==2 | drink_times==3) & drink_times_dwm==3 & drink_freq==.  // 2-3 times a month 
replace drink_freq=8 if drink_times==1 & drink_times_dwm==3  & drink_freq==. // once a month 
 
replace drink_freq=10 if (drink_times>=4 & drink_times<=12 & drink_times_dwm==3 |drink_times>=1 & drink_times< 4 & drink_times_dwm==2) & drink_freq==. 
replace drink_freq=11 if (drink_times>=7 & drink_times<=14 & drink_times_dwm==2 | drink_times>=30 & drink_times<=60 & drink_times_dwm==3 ) & drink_freq==.
replace drink_freq=12 if (drink_times>60 & drink_times<. & drink_times_dwm==3 |drink_times>14 & drink_times<. & drink_times_dwm==2) & drink_freq==. 

replace drink_freq=0 if drink_yn==0 
lab val drink_freq drinkf 
lab var drink_freq "Recent drinking frequency" 

* standardize number of drinks per week for version 8-14
cap drop drinkpwk 
gen drinkpwk=drink_n_perday*7 if drink_times_dwm==1 
replace drinkpwk=drink_n_perday if drink_times_dwm==2 
replace drinkpwk=drink_n_perday/4 if drink_times_dwm==3 
* version 15 using drink_freq 
replace drinkpwk = drink_n_perday*7 if drink_freq==1 
replace drinkpwk = drink_n_perday*6 if drink_freq==2 
replace drinkpwk = drink_n_perday*4 if drink_freq==3 	
replace drinkpwk = drink_n_perday*3 if drink_freq==4  
replace drinkpwk = drink_n_perday*2 if drink_freq==5  
replace drinkpwk = drink_n_perday   if drink_freq==6  
replace drinkpwk = drink_n_perday*3/4 if drink_freq==7 
replace drinkpwk = drink_n_perday/4 if drink_freq==8 
replace drinkpwk = drink_n_perday/5 if drink_freq==9 
replace drinkpwk=0 if drink_yn==0 

* 6 drink category: 
lab define drink6 0 "Not at all" 1  "1-3 drinks per week" 2 "4-6 drinks per week" 3 "1-2 drinks daily" 4 "3 drinks or more daily" 5 Occasionally, modify 
gen drink_cat6=0 if drink_yn==0 
replace drink_cat6=1 if drinkpwk>=1 & drinkpwk<4
replace drink_cat6=2 if drinkpwk>=4 & drinkpwk<7
replace drink_cat6=3 if drinkpwk>=7 & drinkpwk<=14
replace drink_cat6=4 if drinkpwk>14 & drinkpwk<. 
* if missing standized drink per week, using frequency as number of drinks 
replace drink_cat6=1 if drink_cat6==. & drink_freq>=4 & drink_freq<=6 
replace drink_cat6=2 if drink_cat6==. & drink_freq>=2 & drink_freq<=3
replace drink_cat6=3 if drink_cat6==. & (drink_freq==1 | drink_freq==11)
replace drink_cat6=4 if drink_cat6==. & drink_freq==12 
replace drink_cat6=5 if drink_cat6==. & (drink_freq==13 | drink_freq>=7 & drink_freq<=9)
lab val drink_cat6 drink6 
lab var drink_cat6 "Drinks (cat.6)"

* drinks 5 categories 
lab define drink5  0 "Not/<1 drink per week" 1 "1-3 drinks per week" 2 "4-6 per week" 3 "1-2 drinks daily" 4 "3 or more drinks daily", modify 

gen drink_cat5=drink_cat6 
replace drink_cat5=0 if drink_cat6==5 
lab val drink_cat5 drink5 
lab var drink_cat5 "Drinks (cat.5)"

lab define drink2 0 "Not/<1 drink per week" 1 "1 or more drinks per week" , modify 
gen drink_cat2=drink_cat5>=1 if drink_cat5<. 
lab var drink_cat2 "Drinks (cat.2)" 

drop drinkpwk drink_yn

sort subject_number visitdate 
by subject_number: gen chg=1 if site_number!=site_number[_n-1] & _n>1 
egen site_chg=sum(chg), by(subject_number)
lab var site_chg "Number of Changed sites" 
drop chg 

*******************************************************
*calculation of the comorbidity index CCI

gen myoi = hx_comor_mi == 1 | comor_mi == 1 

gen chf = hx_comor_chf == 1 | comor_chf == 1 
gen pvd = hx_comor_pef_art_dis == 1 | comor_pef_art_dis == 1

gen cvd = hx_comor_tia == 1 | hx_comor_stroke == 1 | comor_tia == 1 | comor_stroke == 1
gen copd = hx_comor_copd == 1 | comor_copd == 1

*Ulcers
*Charlson lists peptic ulcer disease, not just ulcer
*but no history of peptic ulcer, only comorbidity

gen peptic = comor_ulcer == 1
gen pepticwhx = comor_ulcer == 1 | hx_comor_ulcer == 1

*can modify to include hxulcer, comor_ulcer, comor_bleed_ulcer
*check comor_bleed_ulcer_c1, comor_pept_ulcer_c1
*Have an aside regarding ulcers if you want more details
gen dm = hx_comor_diabetes == 1 | comor_diabetes == 1

*aside to find history of leukemia
*can't find any - would be in comor_other_cancer_specify
gen leuk = comor_leukemia==1 | hx_comor_leukemia==1 
gen lymph = hx_comor_lymphoma == 1 | comor_lymphoma == 1 

*add in hxoth_cancer, but have no way of figuring out which are specified

gen solid = hx_comor_oth_cancer==1 | hx_comor_skin_cancer_mel == 1 | hx_comor_lc ==1 | hx_comor_bc==1 | comor_lc == 1 | comor_bc == 1 | comor_oth_cancer == 1 | comor_skin_cancer_mel == 1  //2024-1-22 add hx_comor_lc hx_comor_bc 
for any cer pro colon ute: replace solid=1 if hx_comor_cancer_X==1 | comor_cancer_X==1 

gen liver = hx_comor_liver_dis == 1 | comor_liver_dis == 1 

gen connect = 1  // all RA subject consider as 1 

*don't specifically include connect in the CCI since this would mean everyone has at least a score of 1

*cci with peptic ulcer only
gen cci = connect + myoi + chf + pvd + cvd + copd + peptic + dm + leuk + lymph + solid + liver 

*cci with peptic ulcer and hx of any ulcer
gen cci_2 = connect + myoi + chf + pvd + cvd + copd + pepticwhx + dm + leuk + lymph + solid + liver

/* LG 96-28-2019: drop misc. variables and label cci and cci_2	*/
drop myoi-connect
lab var cci "Charlson Comorbidity Index with peptic ulcer only"
lab var cci_2 "Charlson Comorbidity Index with peptic ulcer and hx of any ulcer" 

// 2024-11-04 LG add eq5d here 
eq5d health_status_walking health_status_selfcare health_status_activities health_status_pain health_status_anx_dep, country(US) saving(eq5d)
lab var eq5d "EQ5D(3L)" 
replace eq5d=. if eq5d<=0  // 265 replaced to 0 

sum eq5d, d // 287k+ out of 481k+

* may drop below variables from keyvisitvars, they are in 1_2_allvisits. 

cap drop  c_effective_event_date c_is_* smoke_oth* ae_comor_tox_fract ae_comor_tox_fract_since hx_bio_en no_bio_sm* fracture_* infections_*  med_condition_* su_meds_* md_meds_* osteo_meds_*  tb_ever tb_since tb_blood_* vaccine_* x_* emergency rheum_visits outpt_* lab_rad_dxa_submit labs_imaging_coll 

cap drop drinks_status drink_n_perday drink_times drink_times_dwm drink_none drink_days_3 drinking_etoh drink_days_3_wmy smoke_ever_100 smoke_start_age smoke_current smoke_perday smoke_n_perday smoke_regular smoke_last_age smoke_lifetime_year smoke_lifetime_month smoke_start smoke_quit smoking_cigs 

cap drop doi_not_started_1 doi_not_started_2 doi_reason_1 doi_reason_2 doi_reason_oth_spec_1 doi_reason_oth_spec_2 doi_route_2 doi_not_started_oth_1 doi_not_started_oth_2 study_other_enrolled cbc_yn cbc_yn_code chest_xray_yn dxa_yn dxa_yn_code hep_b_panel_yn hep_b_panel_yn_code inflammatory_yn inflammatory_yn_code joint_mri_yn joint_mri_yn_code joint_ultrasound_yn_code joint_xray_yn kidney_function_yn kidney_function_yn_code lipid_panel_yn lipid_panel_yn_code liver_function_yn liver_function_yn_code ra_diag_results_yn ra_diag_results_yn_code vitamin_d_yn vitamin_d_yn_code 

// 2025-02-11 Yolanda asks to keep hispanic hispanic 
cap drop race_hispanic race_white race_black race_asian race_native_am race_pacific am_stiff_hrs am_stiff_mins 
cap drop curated_weight curated_bmi race_other 

*cap drop haq_dress_yourself haq_get_in_out_bed haq_lift_cup_glass haq_walk_outdoors haq_wash_dry_body haq_bend_down_pick_up haq_turn_faucets haq_get_in_out_car haq_climb_5_steps haq_chores

cap drop smoke_start_dt smoke_quit_dt dupvisits visit_date form most_recent_site_number earliest_site_number am_stiff_hrs am_stiff_mins curated_weight curated_bmi 
drop hosp hosp_count hospitalizations_ra hosp_inf hosp_cve hosp_oth_cond hosp_arthro 

drop haq_dress_yourself haq_get_in_out_bed haq_lift_cup_glass haq_walk_outdoors haq_wash_dry_body haq_bend_down_pick_up haq_turn_faucets haq_get_in_out_car haq_climb_5_steps haq_chores 

drop tb_latent_treatment  tb_blood_performed  tb_test_performed_6mo  tb_skin_result tb_skin_dt tb_ever  tb_blood_skin_no_test  tb_skin_no_test  tb_test_type tb_since  tb_blood_skin_positive_tx   tb_skin_positive_treatment  tb_blood_skin_dt tb_blood_positive  tb_skin_performed  tb_blood_result tb_blood_dt outpt_* vaccine_* 


for any nsaiduse opioid analgesics: replace X=0 if X==. 
lab var nsaiduse "NSAIDs use" 
lab var opioid "Opioid use"
lab var analgesics "Analgesics use" 

replace haq_di=. if full_version>=5 & full_version<=7 // full HAQ didn't on version 5-7 


/* created unique md_id 
1. if c_provider_id missing, use prior visit or next visit c_provider_id - consider same provider for a subject 
2. if still missing, then use same provider id at same site with same visitdate and only one provider see patient that day
3. created md_id by combined site_number and c_provider_id 
*/ 

destring c_provider_id, gen(md_cod) 

sort subject_number site_number visitdate md_cod 
by subject_number site_number: replace c_provider_id=c_provider_id[_n-1] if c_provider_id=="" 
by subject_number site_number: replace c_provider_id=c_provider_id[_N] if c_provider_id=="" 

cap drop ck 
gen ck=1 if c_provider_id=="" 
egen everck=sum(ck), by(site_number visitdate) 
tab everck 

sort site_number visitdate md_cod  
by site_number visitdate md_cod: gen md=1 if everck>0 & _n==1 & md_cod<. 
by site_number visitdate: egen mdn=sum(md) if everck>0 
tab mdn

sort site_number visitdate md_cod
by site_number visitdate: replace c_provider_id=c_provider_id[1] if c_provider_id=="" & c_provider_id[1]!="" & mdn==1 

count if c_provider_id=="" 
cap drop site_id 
tostring site_number, gen(site_id)

egen md_id=concat(site_id c_provider_id), p(_) 

lab var md_id "MD ID (combined with site number)" 

drop site_id ck everck md mdn md_cod 

lab var c_event_created_date "Created date"
lab var c_event_last_modified_date "Last modified date"
// 2025-02-06 changed var name 
*lab var dw_event_instance_uid "Event instance UID"
lab var exit_other "Other exit reason, specify"
lab var death_dt "Date of death"
lab var status "Site status"
lab var site_type "Site type"
lab var state "Site US state"
lab var region "Site US region" 

lab var indexn "Order of visit"
lab var indexN "Total number of visits"

drop newbio_today race_white race_black race_asian race_native_am race_pacific hispanic doi_route_* su_meds_yes_no md_meds_yes_no osteo_meds_* med_condition_* infections_* no_bio_* hx_bio_* doi_since_* rheum_visit hep_c_panel_* joint_ultrasound_yn smoke_oth* am_stiff_hrs am_stiff_mins joint_deformity subcutan_nods sec_sjog ae_comor_tox_fract*  menopause_* marijuana_* pregnant_* breastfeed* 
drop symptom_year diagnosis_year form inf_serious  
drop smoke_start_dt smoke_quit_dt lab_rad_dxa_submit labs_imaging_coll 
drop fractures_yes_no fractures_since_yes_no surgeries_yes_no surgeries_since_yes_no emergency famhx_* 
drop conmed_yes_no 

sort subject_number visitdate 
save temp\temp_keyvisitvars, replace 

*************************************************

*this section need to use 2_1_drugexpdetail data for history of drug 
// 2024-11-04 LG added datacut for data name 

use subject_number visitdate hx_* drug_key generic_key init_drug drug_stop drug_stop_date next_visit visit_* dw_event_type_acronym drug_date drug_start_date *generic* drug_status using "2_1_drugexpdetails_$datacut", clear  

drop if visit_indexn==visit_indexN & visitdate<drug_date 

sort subject_number drug_key visitdate drug_date 
by subject_number drug_key visitdate: drop if _n<_N 

sort subject_number visitdate drug_date 

bysort subject_number visitdate: drop if _n<_N  

* initiation is last row in RAdrug and no drug report on next visit, calculated as stop after initiation to next visit, expand next visit for hx_X=1 
sort subject_number visitdate

gen ck=. 
// 2024-11-01 LG added more drug names 
foreach x in arava	azulfidine	cuprimine	cyclosporine	imuran	invest	minocin	mtx	plaquenil	ridaura	sirukumab	orencia	humira amjevita	abrilada cyltezo hadlima idacio hyrimoz yusimry hulio kineret	cimzia	enbrel	erelzi	simponi	simponi_aria	avsola	ixifi inflectra	remicade	remicade_bs	renflexis	rituxan	rituxan_bs	ruxience	truxima riabni	kevzara	actemra	olumiant	xeljanz	xeljanz_xr	rinvoq	kenalog	meth_pred	pred { 
qui by subject_number: replace ck=1 if _n==_N & drug_key=="`x'"  & init_drug==1  & drug_stop==1 & drug_stop_date>visitdate & drug_stop_date<=next_visit 
}	
tab ck 

gen ck2=.
foreach x in adalimumab	etanercept	infliximab	golimumab	tofacitinib	rituximab	corticosteroids	{
qui by subject_number: replace ck2=1 if _n==_N & generic_key=="`x'"  & init_generic==1  & generic_stop==1 & generic_stop_date>visitdate & generic_stop_date<=next_visit 
}	

tab ck ck2, m 

expand 2 if ck==1 | ck2==1, gen(expand) 

replace visitdate=next_visit if ck==1 & expand==1 
replace visitdate=next_visit if ck2==1 & expand==1  

unique subject_number visitdate 
sort subject_number visitdate 

// 2024-11-04 no data yet for abrilada idacio 
foreach x in arava	azulfidine	cuprimine	cyclosporine	imuran	invest	minocin	mtx	plaquenil	ridaura	sirukumab	orencia	amjevita humira cyltezo hadlima hyrimoz yusimry hulio kineret	cimzia	enbrel	erelzi	simponi	simponi_aria	avsola	ixifi inflectra	remicade	remicade_bs	renflexis	rituxan	rituxan_bs	ruxience	truxima	 riabni kevzara	actemra	olumiant	xeljanz	xeljanz_xr	rinvoq	kenalog	meth_pred	pred { 
by subject_number: replace hx_`x'=1 if ck==1 & expand==1 & _n==_N & drug_key=="`x'"  
} 

foreach x in adalimumab	etanercept	infliximab	golimumab	tofacitinib	rituximab	corticosteroids	{
by subject_number: replace hx_`x'=1 if ck2==1 & expand==1 & _n==_N & generic_key=="`x'"  
} 

keep subject_number visitdate hx_* 

drop hx_drug hx_generic 

save temp\temp_hxdrug, replace

use temp\temp_keyvisitvars, clear 
cap drop _m 
sort subject_number visitdate 
merge 1:1 subject_number visitdate using temp\temp_hxdrug

sort subject_number visitdate 

* carry forward history of drug to all visits 
local list hx_adalimumab	hx_arava	hx_azulfidine	hx_corticosteroids	hx_cuprimine	hx_cyclosporine	hx_etanercept	hx_golimumab	hx_imuran	hx_infliximab	hx_invest	hx_minocin	hx_mtx	hx_plaquenil	hx_ridaura	hx_rituximab	hx_sirukumab	hx_tofacitinib	hx_orencia	hx_amjevita	hx_humira hx_cyltezo hx_hadlima hx_hyrimoz hx_yusimry hx_hulio	hx_kineret	hx_cimzia	hx_enbrel	hx_erelzi	hx_simponi	hx_simponi_aria	hx_avsola hx_ixifi	hx_inflectra	hx_remicade	hx_remicade_bs	hx_renflexis	hx_rituxan	hx_rituxan_bs	hx_ruxience	hx_truxima hx_riabni	hx_kevzara	hx_actemra	hx_olumiant	hx_xeljanz	hx_xeljanz_xr	hx_rinvoq	hx_kenalog	hx_meth_pred	hx_pred
foreach x of local list {
by subject_number: replace `x'=`x'[_n-1] if `x'==. & `x'[_n-1]<. 
replace `x'= 0 if `x'==. 	
} 


drop _m 
compress hx_* 

drop inflammatory_yn 
 
order site_number subject_number visitdate md_id full_version dw_event_type_acronym source_acronym study_acronym  
sort subject_number visitdate 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
// 2025-03-07 fix one subject with wrong birthyear
*use 2_3_keyvisitvars_2025-03-01, clear 

list subject_number visitdate age birthyear if age<0, noobs ab(16)
/*
2025-03-01 cut
  +----------------------------------------------------+
  | subject_number    visitdate        age   birthyear |
  |----------------------------------------------------|
  |    RA-217-0027   2025-01-14   -8289936     8291961 |
  +----------------------------------------------------+
replace birthyear=1961 if subject_number=="RA-217-0027"
replace age=2025-1961 if subject_number=="RA-217-0027"
2025-04-01 cut 
  +----------------------------------------------------+
  | subject_number    visitdate        age   birthyear |
  |----------------------------------------------------|
  |    RA-217-0030   2025-02-04   -8219941     8221966 |
  +----------------------------------------------------+
*/
replace birthyear=1966 if subject_number=="RA-217-0030"
replace age=2025-1966 if subject_number=="RA-217-0030"

list subject_number visitdate age birthyear if subject_number=="RA-217-0030", noobs ab(16)

lab var lab_img_dt "Date of lab or imaging test"
lab var height_in_tot "Height in inches"
lab var weight_lb "Weight (pounds)"
ds, not(Varlabel) v(32)

lab var surgeries_any_ra_calc  "any RA surgeries"      
mdesc surgeries_any_ra_count_calc // 2025-04-04 all missing, temporiarily drop it 
drop surgeries_any_ra_count_calc
// 2025-04-10 drop extra vars so DQ won't have problem 
drop edc_event_type_acronym    edc_event_class           edc_event_instance_label  edc_event_ordinal         c_edc_event_ui_label
save 2_3_keyvisitvars_$datacut, replace 

corcf * using "$pdata\\2_3_keyvisitvars_$pdatacut", id(subject_number visitdate) //verbose noobs 

