
/* 
Code Name: clean_subjects.do 
Purpose: clean subjects demographic, exit, site info variables
Programmer: Ying Shan
Input datasets: fv_subjects, sites, bv_subject_demographic_data, bv_exits 
Final Dataset: 1_1_subjects.dta  
Version1 	Date: 2023-10-17
Description 

variables: 
fv_subjects: sex, birth_year, diagnosis_year, exit_form_date, eenrollment_date, earliest_visit_date, most_recent_visit_date  
sites/fv_sites: status site_type state academic_affiliation 
fv_exits: reason_discontinuation reason_discontinuation_oth_spec death_dt 
bv_subject_demographic_data: 
dw_event_instance_uid    major_version            dw_subject_uid           marital_status_alt       race_other_specify       famhx_mi_or_stroke_code
dw_event_type_acronym    minor_version            c_height_inches          race_native_am           hispanic                 famhx_mother
parent_study_acronym     c_effective_event_date   c_height_inches_alt      race_asian               race_alt                 famhx_mother_code
parent_study_uid         c_provider_id            symptom_year             race_black               c_education              famhx_father
study_source_acronym     site_number              symptom_year_alt         race_pacific             c_education_code         famhx_father_code
study_source_uid         dw_site_uid              marital_status           race_white               c_education_alt          famhx_alt
full_version             subject_number           marital_status_code      race_other               famhx_mi_or_stroke

************************************************************************************************************************************/


************************************

/* this section only run once save the data in for_update folder 

use  subject_number id gender birthdate ara_func_class visitdate indexn yr_onset_ra no_chest_xray no_bone_density_results no_mri no_ultrasound no_rad_results  using "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\dwsub1.dta", clear 

preserve 
keep subject_number visitdate ara_func_class no_chest_xray no_bone_density_results no_mri no_ultrasound no_rad_results 
foreach x in no_chest_xray no_bone_density_results no_mri no_ultrasound no_rad_results {
    replace `x'=0 if `x' ==1 
} 
rename no_chest_xray chest_xray_yn 
rename no_bone_density_results dxa_yn 
rename no_mri joint_mri_yn 
rename no_ultrasound joint_ultrasound_yn 
rename no_rad_results joint_xray_yn 
sort subject_number visitdate 
save ..\..\for_update\ara, replace 
restore 

merge 1:1 id visitdate using "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\dwsub3.dta", keepus(race_*) 
drop if indexn>1 
keep subject_number gender birthdate race_* yr_onset_ra 
rename gender female_male 
rename birthdate birthyear 
rename yr_onset_ra diagnosis_year 
rename race_other_spec race_other_specify 

sort subject_number  
save ..\..\for_update\gender, replace  

*******************************************************/

use "bv_raw\fv_subjects", clear 


* Rich email on 2024-04-01 updates from sites

replace diagnosis_year="2013" if subject_number=="135010063" 
replace diagnosis_year="1994" if subject_number=="149010425" 
replace diagnosis_year="2002" if subject_number=="002020043"
replace diagnosis_year="2006" if subject_number=="002020795"
replace diagnosis_year="2006" if subject_number=="002020852"
replace diagnosis_year="2007" if subject_number=="002021077"
replace diagnosis_year="2002" if subject_number=="002022061"
replace diagnosis_year="2002" if subject_number=="002022293"
replace diagnosis_year="2016" if subject_number=="002022703"
replace diagnosis_year="2016" if subject_number=="002051218"
replace diagnosis_year="2002" if subject_number=="074490770" 
replace diagnosis_year="2003" if subject_number=="723791057" 
replace diagnosis_year="2003" if subject_number=="824793341" 
replace diagnosis_year="2008" if subject_number=="036010382" 
replace diagnosis_year="2003" if subject_number=="624645881" 
replace diagnosis_year="1997" if subject_number=="100292904"
replace diagnosis_year="2014" if subject_number=="100555516"
replace diagnosis_year="1977" if subject_number=="100616100"
replace birth_year="1935" if subject_number=="003001455" 
replace birth_year="1996" if subject_number=="100415414"

replace diagnosis_year="2014" if subject_number=="100285369"
replace birth_year="1945" if subject_number=="100285369" 

replace birth_year="1923" if subject_number=="036010633" 
replace diagnosis_year="2005" if subject_number=="036010633" 



// earliest_visit_date & most_recent_visit_date missing are subject no true visits in EDC, may only exit or other forms PMO/Rich agree remove subjects if missing most_recent_visit & earliest_visit_date 
drop if most_recent_visit_date=="" & earliest_visit_date=="" & exit_form_date=="" 

unique subject_number 
*drop if earliest_site_number=="1440" | earliest_site_number=="999" 

destring birth_year diagnosis_year, replace 
 
lab var birth_year "Year of birth" 
lab var diagnosis_year "Year of RA diagnosis"

tab sex sex_code, m 

lab define sexf 0 male 1 female, modify  
lab val sex_code sexf 
lab var sex_code "Sex at birth" 
drop sex 
rename sex_code female_male 

foreach x in enrollment_date earliest_visit_date most_recent_visit_date exit_form_date { 
	gen dt=date(`x', "YMD")
	drop `x' 
	rename dt `x' 
	format `x' %tdCCYY-NN-DD 
} 

drop if x_is_test=="1"  // ENG created variable for test subject 
drop x_is_test 

* clean and check birth year 
gen en_age=year(enrollment_date)-birth_year   
list subject_number en_age birth_year diagnosis_year enrollment_date earliest_site_number most_recent_site_number if en_age>94 & en_age<., noobs ab(25) sep(0) 

/*
  +--------------------------------------------------------------------------------------------------------------------------+
  | subject_number   en_age   birth_year   diagnosis_year   enrollment_date   earliest_site_number   most_recent_site_number |Rich confirm on 20240729
  |--------------------------------------------------------------------------------------------------------------------------|
  |      036010633     2011            1             2012        2012-12-18                     36                        36 |site still checking
  |      121767220       95         1909             2002        2004-02-05                     38                        38 |accurate
  |      178130292       95         1920             2006        2015-08-31                    178                       178 |accurate
  |      002022589       95         1919             2014        2014-10-29                      2                         2 |accurate
  |      003001455      820         1193             2012        2013-01-07                      3                         3 |site still checking
  |      019101146      101         1917             2014        2018-12-07                     19                        19 |site still checking
  |      022050028      373         1640             2006        2013-01-31                     22                        22 |site closed
  |      104010061      951         1061             2012        2012-08-31                    104                       104 |site closed
  |      061010735      160         1853             2012        2013-01-08                     61                        61 |site closed 
  |      061010733      160         1853             2005        2013-01-07                     61                        61 |site closed 
  |      167010038      958         1054             2011        2012-12-19                    167                       167 |site still checking
  |      205070463       95         1926             2020        2021-08-23                    205                       205 |accurate
  |      236010009      100         1920             2020        2020-08-11                    236                       236 |site closed
  |      167010010     1979           33             1978        2012-10-05                    167                       167 |site still checking
  |      118022226      111         1906             2000        2017-04-06                    118                       118 |site closed
  +--------------------------------------------------------------------------------------------------------------------------+
*/ 
* before ROM decided how to fix such birth year, we correct as below 

replace birth_year= 1993 if subject_number== "003001455" & birth_year==1193
replace birth_year= 1940 if subject_number== "022050028" & birth_year==1640
replace birth_year= 1961 if subject_number== "104010061" & birth_year==1061
replace birth_year= 1953 if subject_number== "061010735" & birth_year==1853
replace birth_year= 1953 if subject_number== "061010733" & birth_year==1853
replace birth_year= 1954 if subject_number== "167010038" & birth_year==1054  
replace birth_year= 1933 if subject_number== "167010010" & birth_year==33   


rename birth_year birthyear 

replace birthyear=. if year(enrollment_date)-birthyear>130 & enrollment_date<. 


drop en_age 

lab var exit_form_date "Exit form date"
lab var enrollment_date "Enrollment date" 
lab var earliest_visit_date "First visit date"
lab var most_recent_visit_date "Most recent visit date"  

destring most_recent_site_number, gen(site_number)  

*keep subject_number birthyear female_male diagnosis_year exit_form_date 
sort subject_number 

drop is_in_substudy_1 subject_provided_* parent_study_acronym *_uid 

save temp\fv_subjects_clean, replace 

*****************************
/* check age onset

gen age_onset_ra=diagnosis_year-birthyear 
gen duration_ra=year(earliest_visit_date)-diagnosis_year

sum age_onset_ra duration_ra 

destring earliest_site_number, gen(site_id) force 

count if age_onset_ra<10 & site_id<990   
count if age_onset_ra>90 & age_onset_ra<. & site_id<990 

br subject_number birth_year diagnosis_year age_onset_ra earliest_site_number most_recent_site_number exit_form_date if age_onset_ra <10 | age_onset_ra>90 & age_onset_ra<. & site_id <990

export excel subject_number birth_year diagnosis_year age_onset_ra duration_ra earliest_site_number most_recent_site_number exit_form_date if age_onset_ra<10 & site_id<997 using "age_onset_ra.xlsx", sheet(less_than_10, replace) firstrow(var) 
export excel subject_number birth_year diagnosis_year age_onset_ra duration_ra earliest_site_number most_recent_site_number exit_form_date if age_onset_ra>90 & age_onset_ra<. & site_id<997  using "age_onset_ra.xlsx", sheet(large_than_90, replace) firstrow(var) 

*/


use "RAsitestatus.dta", clear 
rename site_id site_number 
drop if site_number>=997 
unique site_number 

replace state="FL" if state=="Fl" 
replace state="" if state=="AN" 


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

keep site_number status state site_type region 

sort site_number 
save temp\temp_sites, replace 

**************************************************************

use subject_number c_effective_event_date reason_death_dt reason_discontinuation* reason_discontinuation_oth_spec using "bv_raw\bv_exits", clear 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD 

gen death_dt=date(reason_death_dt, "YMD") 
format death_dt %tdCCYY-NN-DD 

tab reason_discontinuation reason_discontinuation_code, m  

groups reason_discontinuation reason_discontinuation_code, sep(0) 
groups reason_discontinuation_code, sep(0) 

rename reason_discontinuation_code exit_reason 
rename reason_discontinuation_oth_spec exit_other 

/*
1	patient withdrew consent
2	patient lost to follow-up (unknown vital status)
3	patient died
5	patient moved
6	administrative reasons
7	patient enrolled into a double-blind, randomized drug trial for an RA medication
8	change in insurance (loss of coverage or plan no longer accepted by registry provider)
9	patient was misdiagnosed (does not have rheumatoid arthritis)
10	patient switched to another provider
88	site withdrew from registry and none of the other exit reasons apply
99	other reason for exit (specify) 
*/ 


lab define exitf 1 "pt withdrew consent" 2 "lost to fu" 3 death  5 "Patient moved" 6 "administration reason"  7 "enrolled clinical trail" 8 "change insurance"   9 "not RA" 10 "switched to another provider" 88 "site withdrew"  99 other, modify 
lab val exit_reason exitf  
lab var exit_reason "Exit reason" 


* missing code in current download 
replace exit_reason=2 if reason_discontinuation== "lost to fu"
replace exit_reason=1 if reason_discontinuation=="pt withdrew concent"

sort subject_number visitdate 
foreach x in exit_reason exit_other death_dt { 
by subject_number visitdate: replace `x'=`x'[1] if missing(`x') 
}
by subject_number visitdate: drop if _n<_N 

sort subject_number visitdate 
by subject_number: gen lastexit=1 if _n==_N 
by subject_number: gen vN=_N 

tab exit_reason if vN>1, m 

order subject_number visitdate exit_reason exit_other death_dt 

foreach x in exit_reason exit_other death_dt { 
	by subject_number: replace `x'=`x'[_n-1] if missing(`x')
} 

by subject_number: drop if _n<_N  // keep last exit_form 

keep subject_number death_dt exit_reason exit_other
sort subject_number  
save temp\temp_exit, replace 

/*
*education edit using college_completed in version 4-14, baseview data not mapped -may no need to run since ENG will map college_completed 

use optional_id visitdate final_education college_completed form_master_id version using "$tm\dwsub1", clear 
tab final_education college_completed, m 

cap drop education 
gen education=final_education 
replace education=0 if final_education==4 
replace education=4 if college_completed==1 & final_education==3 
replace education=3 if college_completed==0 & final_education!=3

gen edu=1 if education<. 
gen edu1=education if form_master_id==1 
sort optional_id edu visitdate 
by optional_id edu: replace edu1=education[1] if edu1==. 

gen en=1 if form_master_id==1 
egen everen=sum(en), by(optional_id) 


sort optional_id visitdate 
by optional_id: gen indexn=_n 
tab everen if indexn==1 
br if everen==2 
keep if indexn==1 & everen==0 | en==1 

unique optional_id 
keep optional_id edu 

rename optional_id subject_number 
sort subject_number 
save temp\temp_edu, replace 
 
*************************************************************************************************************************************/ 
*************************************************************************************************************************************

use "bv_raw\bv_subject_demographic_data", clear 

unique subject_number 

*famhx_mi_or_stroke_code  famhx_mother_code  famhx_father_code famhx_alt not in specs_view_definition

drop dw_subject_uid  dw_site_uid 

lab define ny 0 No 1 Yes, modify  

*RA symptoms begin year 
destring curated_symptom_year, replace 
lab var symptom_year "RA symptom begin (year)" 
rename curated_symptom_year symptom_year 

rename hispanic race_hispanic 

gen anyrace=0 
foreach x in race_native_am race_asian race_black race_pacific race_white race_other race_hispanic{
	replace anyrace=1 if `x'=="yes" 
}

*RACE/Histpanic 
foreach x in white black asian other native_am pacific hispanic  {  
	rename race_`x' `x'
	gen race_`x'= `x'=="yes" if anyrace==1  
	lab val race_`x' ny 	
	drop `x' 
}  

drop anyrace  

lab var race_native_am  "American Indian/Alaskan native"
lab var race_asian  "Asian"
lab var race_black  "African american"
lab var race_pacific "race-Native Hawaiian or other pacific islander"
lab var race_white  "race-white"
lab var race_other  "race-other"
lab var race_other_specify  "other race specify"
rename race_hispanic hispanic 
lab var hispanic "Ethnicity-Hispanic/Latina"  


* Highest education- current view data didn't map college_completed for version 4-14

lab define edu 0 "no school completed" 1 "elementary school" 2 "high school" 3 "college/univ (unspecified)" 4 "college/univ (no degree)" 5 "college/univ.(completed)"  6 "graduate school" 7 unknown, modify 
lab val c_education_code edu 
drop c_education 
rename c_education_code c_education 
lab var c_education  "highest education" 


* Marital status

tab marital_status marital_status_code, m 
drop marital_status 

lab define marital 1 single 2 married 3 partnered 4 widowed 5 separated 6 divorced, modify 
lab val marital_status_code marital 
rename marital_status_code marital_status
lab var marital_status "Marital status" 

 
 * family history of MI/stroke 
lab define famhx 0 No 1 Yes 2 "I am not sure", modify 
encode famhx_mi_or_stroke, gen(famhx) label(famhx) 
drop famhx_mi_or_stroke* 
rename famhx famhx_mi_or_stroke 

foreach x in  mother father{
	drop famhx_`x'
	rename famhx_`x'_code famhx_`x' 
	lab val famhx_`x' ny 
} 

lab var famhx_mi_or_stroke "Fimily history of MI/Stroke" 
lab var famhx_mother "Mother has MI/Stroke"
lab var famhx_father "Father has MI/Stroke" 


foreach x in c_height_inches_alt symptom_year_alt  marital_status_alt  c_education_alt  race_alt {
	tab `x', m 
	destring `x', replace 
	lab val `x' ny 
	lab var `x' "not on enrollment visit" 
}

lab var dw_event_type_acronym  "form type" 
lab var parent_study_acronym  "parent study"

lab var subject_number  "subject id" 
lab var site_number  " site id" 
lab var c_height_inches  "height (inches)" // "computed height in inches captured at earliest visit"

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %dCY-N-D
lab var visitdate "visit date" 

rename c_height_inches height_in_tot 

drop x_is_test c_height_inches_alt symptom_year_alt  marital_status_alt race_alt c_education_alt  famhx_alt parent_study_acronym c_is_suppressed_not_seen

unique subject_number 
sort subject_number 

save temp\bv_subject_demo_clean, replace 

********************************************
********************************************

use temp\bv_subject_demo_clean, clear 
destring site_number, replace 

merge 1:1 subject_number using temp\fv_subjects_clean 


rename _m subj_form 
lab define subj 1 "bv_subject_demo. only" 2 "fv_subjects only" 3 both, modify 
lab val subj_form subj 
lab var subj_form "subject data"  

* combine with exit form for exit reason 
sort subject_number 
merge 1:1 subject_number using temp\temp_exit
drop if _m==2
drop _m 

drop if site_number >= 997 // test sites 

destring full_version, replace 

cap drop parent_study_acronym c_height_inches_alt symptom_year_alt marital_status_alt c_education_alt parent_study_uid dw_subject_uid is_in_substudy_1 earliest_site_uid most_recent_site_uid 

* combine with site status and state 
sort site_number
merge m:1 site_number using temp\temp_sites // 25 sites no subjects 
drop if _m==2 
tab site_number if _m==1 // test sites
drop _m  

sort subject_number 
merge 1:1 subject_number using ..\..\for_update\gender, update 
drop if _m==2 
drop _m 

drop c_effective_event_date subj_form 

sort subject_number 
save clean_table\1_1_subjects.dta, replace 

erase temp\temp_exit.dta 


*2024-08-06 update one subject 144010163 missing in this build bv_subject_demographic_data 
use "C:\Users\yshan\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-07-01\clean_table\1_1_subjects.dta", clear 
keep if subject_number=="144010163"
merge 1:1 subject_number using clean_table\1_1_subjects.dta 
drop _m 

sort subject_number 
save clean_table\1_1_subjects.dta, replace 




/*
use clean_table\1_1_subjects.dta, clear 

#delimit;
drop 
subject_number
site_number
visitdate
dw_event_type_acronym
full_version
study_source_acronym
dw_event_instance_uid
c_provider_id


female_male
birthyear
diagnosis_year
enrollment_provider_id
enrollment_date
earliest_visit_date
most_recent_visit_date
earliest_site_number
most_recent_site_number

symptom_year
hispanic
race_white
race_black
race_asian
race_native_am
race_pacific
race_other
race_other_specify
c_education
marital_status
height_in_tot
famhx_mi_or_stroke
famhx_father
famhx_mother
state
status
region
site_type
exit_form_date
exit_reason
exit_other
death_dt

;
#delimit cr 

