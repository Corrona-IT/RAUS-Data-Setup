
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

use "bv_raw\bv_subjects", clear 
// 2025-04-03 use march exit_form_date to update and replace the April data. 
/*merge 1:1 subject_number using "$pdata\bv_raw\bv_subjects", keepus(exit_form_date) update replace 

    Result                           # of obs.
    -----------------------------------------
    not matched                           203
        from master                       120  (_merge==1)
        from using                         83  (_merge==2)

    matched                            62,316
        not updated                    59,877  (_merge==3)
        missing updated                 2,376  (_merge==4)
        nonmissing conflict                63  (_merge==5)
    -----------------------------------------


drop if _m==2
drop _m  
*/

#delimit;
for any 000000005
000103133
000123473
000591000
001010010
001010055
001010182
001017045
001020009
001020022
002020166: list subject_number exit_form_date if subject_number=="X", noobs ab(16)
;
#delimit cr;

// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"

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
// 2025-03-05 change from birth_year to birthyear 
replace birthyear="1935" if subject_number=="003001455" 
replace birthyear="1996" if subject_number=="100415414"

replace diagnosis_year="2014" if subject_number=="100285369"
replace birthyear="1945" if subject_number=="100285369" 

replace birthyear="1923" if subject_number=="036010633" 
replace diagnosis_year="2005" if subject_number=="036010633" 



// earliest_visit_date & most_recent_visit_date missing are subject no true visits in EDC, may only exit or other forms PMO/Rich agree remove subjects if missing most_recent_visit & earliest_visit_date 
drop if most_recent_visit_date=="" & earliest_visit_date=="" & exit_form_date=="" 

unique subject_number 
*drop if earliest_site_number=="1440" | earliest_site_number=="999" 
// 2025-03-05 change from birth_year to birthyear 
destring birthyear diagnosis_year, replace 
 
lab var birthyear "Year of birth" 
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
// 2025-03-05 check date values 
codebook enrollment_date earliest_visit_date most_recent_visit_date exit_form_date
count if enrollment_date>d($cutdate) & enrollment_date<. // 0
count if earliest_visit_date>d($cutdate) & earliest_visit_date<. // 0
count if most_recent_visit_date>d($cutdate) & most_recent_visit_date<. // 4

list subject_number enrollment_date if  enrollment_date>d($cutdate) & enrollment_date<., noobs ab(16)
list subject_number earliest_visit_date if  earliest_visit_date>d($cutdate) & earliest_visit_date<., noobs ab(16)
list subject_number most_recent_visit_date if most_recent_visit_date>d($cutdate) & most_recent_visit_date<., noobs ab(16)
/*
  +-----------------------------------+
  | subject_number   most_recent_vi~e |
  |-----------------------------------|
  |      001020165         2025-12-17 | check longitudinal view: d(01jan2025)
  |      001020235         2025-12-31 | check d(13jan2025)
  |      001040564         2025-12-03 | had
  |      001100690         2025-12-11 | had
  |      011595202         2025-10-14 | check d(10jan2025)
  |-----------------------------------|
  |      205090631         2025-11-26 | had
  +-----------------------------------+
*/
// 2025-03-05 LG only find a few in 1.4 alllabs data; all others will be dropped from subjects data  
// 2025-04-02 LG updated additional 3 subjects from bv_longitudinal data 
replace most_recent_visit_date=d(01jan2025) if subject_number=="001020165" & most_recent_visit_date==d(17dec2025)
replace most_recent_visit_date=d(13jan2025) if subject_number=="001020235" & most_recent_visit_date==d(31dec2025)
replace most_recent_visit_date=d(10jan2025) if subject_number=="011595202" & most_recent_visit_date==d(14oct2025)
 
replace most_recent_visit_date=d(07jan2025) if subject_number=="001100690" & most_recent_visit_date==d(11dec2025)
replace most_recent_visit_date=d(07jan2025) if subject_number=="001040564" & most_recent_visit_date==d(03dec2025)
replace most_recent_visit_date=d(17jan2025) if subject_number=="205090631" & most_recent_visit_date==d(26nov2025)

drop if x_is_test=="1"  // ENG created variable for test subject 
drop x_is_test 
// 2025-03-05 change from birth_year to birthyear
* clean and check birth year 
gen en_age=year(enrollment_date)-birthyear   
list subject_number en_age birthyear diagnosis_year enrollment_date earliest_site_number most_recent_site_number if en_age>94 & en_age<., noobs ab(25) sep(0) 

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
// 2025-03-05 change from birth_year to birthyear
replace birthyear= 1993 if subject_number== "003001455" & birthyear==1193
replace birthyear= 1940 if subject_number== "022050028" & birthyear==1640
replace birthyear= 1961 if subject_number== "104010061" & birthyear==1061
replace birthyear= 1953 if subject_number== "061010735" & birthyear==1853
replace birthyear= 1953 if subject_number== "061010733" & birthyear==1853
replace birthyear= 1954 if subject_number== "167010038" & birthyear==1054  
replace birthyear= 1933 if subject_number== "167010010" & birthyear==33   


*rename birth_year birthyear 

replace birthyear=. if year(enrollment_date)-birthyear>130 & enrollment_date<. 


drop en_age 

lab var exit_form_date "Exit form date"
lab var enrollment_date "Enrollment date" 
lab var earliest_visit_date "First visit date"
lab var most_recent_visit_date "Most recent visit date"  

destring most_recent_site_number, gen(site_number)  

*keep subject_number birthyear female_male diagnosis_year exit_form_date 
sort subject_number 
// 2025-02-05 changed var names related to previous *_uid
drop is_in_substudy_1 subject_provided_* parent_study_acronym c_subject_key earliest_site_key most_recent_site_key // *_uid 

save temp\bv_subjects_clean, replace 


// 2025-02-05 Talked with Ying, confirmed there were missingness in the visitdates in subject data, but we only need the subjects with demographic data. 

mdesc exit_form_date enrollment_date earliest_visit_date most_recent_visit_date, ab(32)
/*
    Variable                     |     Missing          Total     Percent Missing
---------------------------------+--------------------------------------------------------------
                  exit_form_date |      23,427         61,819          37.90
                 enrollment_date |       1,079         61,819           1.75
             earliest_visit_date |         311         61,819           0.50
          most_recent_visit_date |         774         61,819           1.25
---------------------------------+--------------------------------------------------------------

*/

codebook exit_form_date enrollment_date earliest_visit_date most_recent_visit_date

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

// 2024-12-04 moved site status from analytic folder to clean table folder
use "clean_table\RAsitestatus_$datacut.dta", clear 
rename site_id site_number 
drop if site_number>=997 
unique site_number 

replace state="FL" if state=="Fl" 
*replace state="" if state=="AN" 
replace state="FL" if site_number==262 & state=="NA" // 2024-10-02 edited by LG
count if state!=shipping_state // 1
list site_number account_name state shipping_state if state!=shipping_state, noobs ab(16)
/*
  +---------------------------------------------------------------------+
  | site_number                 account_name   state   shipping_state~e |
  |---------------------------------------------------------------------|
  |         269   Texoma Arthritis Clinic PA      IL                 TX |
  +---------------------------------------------------------------------+

*/
count if state=="NA" // 1 
list site_number account_name state shipping_state  if state=="NA", noobs ab(16)

replace state="IL" if site_number==266 & state=="NA" // 2025-04-03 LG googled by name of the clinic 

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
// 2024-12-04 create numeric format of site_type 

encode site_type, gen(site_type_num)
rename site_type site_type_str 
rename site_type_num site_type 
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

codebook death_dt
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
// 2025-03-05 LG: no created/modified date to clean visitdates 

unique subject_number 

*famhx_mi_or_stroke_code  famhx_mother_code  famhx_father_code famhx_alt not in specs_view_definition
// 2025-02-05 changed var names related to *_uid
*drop dw_subject_uid  dw_site_uid 

drop c_subject_key c_site_key

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
lab var race_pacific "Native Hawaiian or other pacific islander"
lab var race_white  "White"
lab var race_other  "Other"
lab var race_other_txt  "Other race specify" // 2024-10-02 LG changed to race_other_txt; found variable called "race_alt", no value
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

lab var famhx_mi_or_stroke "Family history of MI/Stroke" 
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
lab var site_number  "site id" 
lab var c_height_inches  "height (inches)" // "computed height in inches captured at earliest visit"

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %dCY-N-D
lab var visitdate "visit date" 

rename c_height_inches height_in_tot 

// 2025-02-26 round and clean height values
// if more than 135, treat as cm?
replace height_in_tot=height_in_tot/2.54 if height_in_tot>135 & height_in_tot<. 
gen double height_round=round(height_in_tot)
compare height_in_tot height_round 
groups height_in_tot height_round if height_in_tot!=height_round, missing ab(16) 
drop height_in_tot
rename height_round height_in_tot
replace height_in_tot=. if height_in_tot<45
replace height_in_tot=. if height_in_tot>90 & height_in_tot<.
sum height_in_tot,d

drop x_is_test c_height_inches_alt symptom_year_alt  marital_status_alt race_alt c_education_alt  famhx_alt parent_study_acronym c_is_suppressed_not_seen

unique subject_number 
sort subject_number 

save temp\bv_subject_demo_clean, replace 

// 2025-02-05 check missingness of visitdate for subject_demographic data
mdesc visitdate 
codebook visitdate // no created/modified date to clean visitdate 
********************************************
********************************************

use temp\bv_subject_demo_clean, clear 
destring site_number, replace 
// 2025-01-09 subject_demographic view changed from birth_year to birthyear 

destring birthyear, replace 

corcf * using temp\bv_subjects_clean, id(subject_number) verbose noobs 

/*
2025-04-03
note: master has 61887 observations; using has 61801 observations
sex: does not exist in using
sex_code: does not exist in using
curated_diagnosis_year: does not exist in using
symptom_year: does not exist in using
marital_status: does not exist in using
race_other_txt: does not exist in using
c_education: does not exist in using
famhx_mother: does not exist in using
famhx_father: does not exist in using
c_dw_event_instance_key: does not exist in using
dw_event_type_acronym: does not exist in using
full_version: does not exist in using
c_effective_event_date: does not exist in using
c_provider_id: does not exist in using
race_white: does not exist in using
race_black: does not exist in using
race_asian: does not exist in using
race_other: does not exist in using
race_native_am: does not exist in using
race_pacific: does not exist in using
hispanic: does not exist in using
famhx_mi_or_stroke: does not exist in using
visitdate: does not exist in using
height_in_tot: does not exist in using
Comparison of common IDs follows

birthyear: 9 mismatches

  +-------------------------------------------+
  | subject_number   master_data   using_data |
  |-------------------------------------------|
  |      003001455          1193         1935 |
  |      022050028          1640         1940 |
  |      036010633             1         1923 |
  |      061010733          1853         1953 |
  |      061010735          1853         1953 |
  |-------------------------------------------|
  |      100285369          1995         1945 |
  |      100415414          1965         1996 |
  |      104010061          1061         1961 |
  |      167010038          1054         1954 |
  +-------------------------------------------+



site_number: 144 mismatches

  +-------------------------------------------+
  | subject_number   master_data   using_data |
  |-------------------------------------------|
  |      001010056             1           83 |
  |      001010128             1           83 |
  |      002021972            76            2 |
  |      009010005             9          146 |
  |      009010026             9          146 |
  |-------------------------------------------|
  |      009010031             9          146 |
  |      009010033             9          146 |
  |      009010047             9          146 |
  |      009010101             9          146 |
  |      009010102             9          146 |
  |-------------------------------------------|
  |      009010104             9          146 |
  |      009010107             9          146 |
  |      009010110             9          146 |
  |      009010111             9          146 |
  |      009010117             9          146 |
  |-------------------------------------------|
  |      009010119             9          146 |
  |      009010122             9          146 |
  |      009010136             9          146 |
  |      009010157             9          146 |
  |      009010158             9          146 |
  |-------------------------------------------|
  |      009010198             9          146 |
  |      009010202             9          146 |
  |      009010214             9          146 |
  |      009010215             9          146 |
  |      009010216             9          146 |
  |-------------------------------------------|
  |      009010223             9          146 |
  |      009010226             9          146 |
  |      009010234             9          146 |
  |      009010235             9          146 |
  |      009010242             9          146 |
  |-------------------------------------------|
  |      009010243             9          146 |
  |      009010249             9          146 |
  |      009010250             9          146 |
  |      009010255             9          146 |
  |      009010287             9          146 |
  |-------------------------------------------|
  |      009010299             9          146 |
  |      009010311             9          146 |
  |      009010315             9          146 |
  |      009010322             9          146 |
  |      009010329             9          146 |
  |-------------------------------------------|
  |      009010333             9          146 |
  |      009010339             9          146 |
  |      009010353             9          146 |
  |      009010367             9          146 |
  |      009010370             9          146 |
  |-------------------------------------------|
  |      009010376             9          146 |
  |      009010382             9          146 |
  |      009010396             9          146 |
  |      009010398             9          146 |
  |      009010405             9          146 |
  |-------------------------------------------|
  |      009010413             9          146 |
  |      009020001             9          146 |
  |      009020002             9          146 |
  |      009020019             9          146 |
  |      009020035             9          146 |
  |-------------------------------------------|
  |      009020037             9          146 |
  |      009020044             9          146 |
  |      009020068             9          146 |
  |      009020079             9          146 |
  |      009020082             9          146 |
  |-------------------------------------------|
  |      009020083             9          146 |
  |      009020085             9          146 |
  |      009020089             9          146 |
  |      009020114             9          146 |
  |      009020116             9          146 |
  |-------------------------------------------|
  |      009020132             9          146 |
  |      009020133             9          146 |
  |      009020135             9          146 |
  |      009020176             9          146 |
  |      009020183             9          146 |
  |-------------------------------------------|
  |      009020184             9          146 |
  |      009020189             9          146 |
  |      009020199             9          146 |
  |      009020208             9          146 |
  |      009020209             9          146 |
  |-------------------------------------------|
  |      009020237             9          146 |
  |      009020245             9          146 |
  |      009020246             9          146 |
  |      009020252             9          146 |
  |      009020253             9          146 |
  |-------------------------------------------|
  |      009020254             9          146 |
  |      009020261             9          146 |
  |      009020265             9          146 |
  |      009020267             9          146 |
  |      009020275             9          146 |
  |-------------------------------------------|
  |      009020278             9          146 |
  |      009020286             9          146 |
  |      009020292             9          146 |
  |      009020295             9          146 |
  |      009020302             9          146 |
  |-------------------------------------------|
  |      009020307             9          146 |
  |      009020325             9          146 |
  |      009020331             9          146 |
  |      009020343             9          146 |
  |      009020344             9          146 |
  |-------------------------------------------|
  |      009020352             9          146 |
  |      009020354             9          146 |
  |      009020360             9          146 |
  |      009020368             9          146 |
  |      009020384             9          146 |
  |-------------------------------------------|
  |      009020387             9          146 |
  |      009020391             9          146 |
  |      009020395             9          146 |
  |      009020397             9          146 |
  |      009020412             9          146 |
  |-------------------------------------------|
  |      009020429             9          146 |
  |      009020430             9          146 |
  |      009020464             9          146 |
  |      009020483             9          146 |
  |      009020491             9          146 |
  |-------------------------------------------|
  |      009030142             9          146 |
  |      009030480             9          146 |
  |      009040048             9          146 |
  |      012060791            12          100 |
  |      042020064            42          151 |
  |-------------------------------------------|
  |      042020124            42          151 |
  |      083010004            83            1 |
  |      083010005            83            1 |
  |      083010026            83            1 |
  |      083010035            83            1 |
  |-------------------------------------------|
  |      083010091            83            1 |
  |      083010143            83            1 |
  |      083010144            83            1 |
  |      086030062            86            1 |
  |      086042302            86          142 |
  |-------------------------------------------|
  |      087100098            87           94 |
  |      107010699           107           35 |
  |      118040520           118          178 |
  |      131010001           131          176 |
  |      131010032           131          176 |
  |-------------------------------------------|
  |      131010047           131          176 |
  |      131010057           131          176 |
  |      131010065           131          176 |
  |      131010097           131          176 |
  |      131010140           131          176 |
  |-------------------------------------------|
  |      131010151           131          176 |
  |      131010161           131          176 |
  |      131010171           131          176 |
  |      140399351            31            1 |
  |      251779508            31            1 |
  |-------------------------------------------|
  |      290699634            31            1 |
  |      740479223            31          108 |
  |      757859374            31            1 |
  |      994239612            31            1 |
  +-------------------------------------------+
*/

// 2025-01-09 use update replace for birthyear and site_number from bv_subjects_clean data 

merge 1:1 subject_number using temp\bv_subjects_clean, update replace 

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           706
        from master                       395  (_merge==1)
        from using                        311  (_merge==2)

    matched                            61,508
        not updated                    61,355  (_merge==3)
        missing updated                     0  (_merge==4)
        nonmissing conflict               153  (_merge==5)
    -----------------------------------------

*/

rename _m subj_form 
lab define subj 1 "bv_subject_demo. only" 2 "bv_subjects only" 3 both 5 updated, modify 
lab val subj_form subj 
lab var subj_form "subject data"  

* combine with exit form for exit reason 
sort subject_number 
merge 1:1 subject_number using temp\temp_exit
drop if _m==2
drop _m 

drop if site_number >= 997 // test sites 

destring full_version, replace 

// 2025-02-05 changed the *_uid var names 
*cap drop parent_study_acronym c_height_inches_alt symptom_year_alt marital_status_alt c_education_alt parent_study_uid dw_subject_uid is_in_substudy_1 earliest_site_uid most_recent_site_uid 
cap drop parent_study_acronym c_height_inches_alt symptom_year_alt marital_status_alt c_education_alt  is_in_substudy_1 // parent_study_uid dw_subject_uidearliest_site_uid most_recent_site_uid 
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
codebook visitdate // [01oct2001,07jan2025] ==> [01jan1900,31dec2024]
*count if visitdate>d(28feb2025) // 2025-02-05 those are the missing visitdates
mdesc visitdate // 311 
count if visitdate>d($cutdate)
drop if visitdate>d($cutdate)
// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"

** save dataset 
compress
save clean_table\1_1_subjects_$datacut, replace 

erase temp\temp_exit.dta 

corcf * using "$pdata\clean_table\1_1_subjects_$pdatacut", id(subject_number)

/* 
2025-04-10
note: master has 61492 observations; using has 61374 observations
diagnosis_date: does not exist in using
Comparison of common IDs follows
birthyear: 2 mismatches
curated_diagnosis_year: 24 mismatches
symptom_year: 18 mismatches
marital_status: 18 mismatches
c_education: 18 mismatches
famhx_mother: 2 mismatches
famhx_father: 4 mismatches
c_dw_event_instance_key: 61326 mismatches
race_white: 18 mismatches
race_black: 18 mismatches
race_asian: 18 mismatches
race_other: 18 mismatches
race_native_am: 18 mismatches
race_pacific: 18 mismatches
hispanic: 18 mismatches
famhx_mi_or_stroke: 18 mismatches
height_in_tot: 23 mismatches
diagnosis_year: 24 mismatches
most_recent_visit_date: 1834 mismatches
exit_form_date: 1641 mismatches
exit_reason: 95 mismatches
exit_other: 38 mismatches
death_dt: 16 mismatches
status: 137 mismatches

*/

