/*
date: 2024-11-25 
Programmer: Ying Shan
Aim: 
1. clean lab result value from raw data 
2. out of range(min/max) value for lab test result in 1_4_alllabs discussed with Rich as std lab test range 

*/ 
*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-11-01\" 

use "temp\1_4_alllabs_temp", clear 

destring site_number full_version, replace 
drop if site_number>=997 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD 

assert c_effective_event_date!="" 

gen labkey=lab_img_name if lab_img_type==1 
assert labkey!="" if lab_img_type==1 

clonevar result_value_raw=lab_img_result_raw if lab_img_type==1 
clonevar result_value=result_value_raw 
destring result_value, force replace 

format lab_img_dt %tdCCYY-NN-DD  

*br subject_number labkey labdate full_version result_value_raw if result_value==. & result_value_raw!="" 

******************************************************************
* clean result_value 

* with > or < 
gen less_great="<" if substr(result_value_raw, 1, 1)=="<" & result_value==. 
replace less_great=">" if substr(result_value_raw, 1, 1)==">" & result_value==. 

tab less_great 

*br subject_number labkey labdate full_version result_value* if less_great!="" & result_value==. 

gen value2=substr(result_value_raw, 2, .) if less_great!="" 
replace value2=substr(result_value_raw, 3,.) if substr(result_value_raw, 1,2)=="<=" 
replace value2=substr(result_value_raw, 3,.) if substr(result_value_raw, 1,2)=="<." 

replace less_great=">" if strpos(result_value_raw, "greater than") 
replace less_great="<" if strpos(result_value_raw, "less than")  

replace value2= subinstr(result_value_raw, "greater than ", "", .) if less_great==">" & strpos(result_value_raw, "greater than") 
replace value2= subinstr(result_value_raw, "less than ", "", .) if  less_great=="<" & strpos(result_value_raw, "less than") 

destring value2, gen(value) force 

 
*tab result_value_raw if result_value==. & less_great!="" // one onely with <, no value 
*replace less_or_greater_than=less_great if less_or_greater_than=="" & less_great!="" 
tab less_great 
/*
 less_great |      Freq.     Percent        Cum.
------------+-----------------------------------
          < |      6,258       99.43       99.43
          > |         36        0.57      100.00
------------+-----------------------------------
      Total |      6,294      100.00

	  */ 
	  
tab lab_result_lt_or_gt less_great, m 
replace lab_result_lt_or_gt=1 if less_great=="<" & lab_result_lt_or_gt==. 
replace lab_result_lt_or_gt=2 if less_great==">" & lab_result_lt_or_gt==.  

drop value2  less_great 

replace result_value=value if result_value==. & value<. 

*save clean_table\test\labonly_temp, replace 


*********************************************

*use clean_table\test\labonly_temp, clear 

/*
"[1] abnormal; 
[2] new; 
[3] normal;
[4] not present;
[5] old; 
[6] old and new; 
[7] present; 
[1000] positive;
[1100] reactive; 
[1399] detected (specify); 
[2000] negative; 
[2100] non-reactive; 
[2300] not detected; 
[2500] high non-response; 
[2600] very high non-response; 
[9771] result unknown

*/  

gen result_interpretation="negative" if strpos(result_value_raw, "neg") 
for any NORMAL norm NR: replace result_interpretation="normal" if result_value_raw=="X" 
replace result_interpretation="not detected" if result_value_raw=="nd" | strpos(result_value_raw, "no results") 
replace result_interpretation="positive" if result_value_raw=="+" | strpos(result_value_raw, "POS") & result_value==.  
replace result_interpretation="high non-response" if result_value_raw=="HIGH"  
for any n/a na: replace result_interpretation="result unknown" if result_value_raw=="X" 

replace lab_img_result_intpn=2000 if result_interpretation=="negative" 
replace lab_img_result_intpn=1000 if result_interpretation=="positive" 
replace lab_img_result_intpn=9771 if result_interpretation=="result unknown" 
replace lab_img_result_intpn=2500 if result_interpretation=="high non-response"
replace lab_img_result_intpn=2300 if result_interpretation=="not detected"  
replace lab_img_result_intpn=3 if result_interpretation=="normal"

drop result_interpretation 


*with double point ".." or ",.", or "," ...  clean to "." 

gen value2=result_value_raw  if result_value==. & lab_img_result_intpn==. 
replace value2=subinstr(value2, "..", ".", .) 
replace value2=subinstr(value2, ",.", ".", .) 

replace value2=subinstr(value2, ".;", ".", .)
replace value2=subinstr(value2, "*.", ".", .)
replace value2=subinstr(value2, ".i", ".", .)
replace value2=subinstr(value2, ".l", ".", .)
replace value2=subinstr(value2, "+.", ".", .)
replace value2=subinstr(value2, ";.", ".", .)
replace value2=subinstr(value2, "-.", ".", .) 
replace value2=subinstr(value2, "./", ".", .) 
replace value2=subinstr(value2, ".,", ".", .) 
replace value2=subinstr(value2, "o.", ".", .) 
replace value2=subinstr(value2, "O.", ".", .) 
replace value2=subinstr(value2, ":", ".", .) 
replace value2=subinstr(value2, "/", ".", .) 
replace value2=subinstr(value2, "P.", ".", .) 
replace value2=subinstr(value2, ". ", ".", .) 
replace value2=subinstr(value2, ".o", ".", .) 

* WBC/platlets should be point at ,000 since result_value is 10^3 or type , instead of , 
replace value2=subinstr(value2, ",", ".", .) 

***** remove last character is ".", or "'" or /  \  ... 
replace value2=substr(value2, 1, strlen(value2) - 3) if substr(value2, -3, 3)=="```" 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="+" 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="%" 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="*" 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="o" 
replace value2=substr(value2, 1, strlen(value2) -1) if (substr(value2, -1, 1)=="." | substr(value2, -1, 1)=="\" | substr(value2, -1, 1)=="/") 

replace value2=substr(value2, 1, strlen(value2) -1) if (substr(value2, -1, 1) =="." | substr(value2, -1, 1)=="`")  & result_value==. & value2!="." 

replace value2=substr(value2, 1, strlen(value2) -1)  if substr(value2, -1, 1) == "q" & result_value==. & value==. & value2!=""
replace value2=substr(value2, 1, strlen(value2) -1)  if substr(value2, -1, 1) == "K" & result_value==. & value==. & value2!="" 

replace value2=substr(result_value_raw, 1, 1)  if substr(result_value_raw, -5, 5) == "mm/hr" & result_value==. & value==. 
replace value2=substr(result_value_raw, 2, .)  if substr(result_value_raw, 1, 1) == "*" & result_value==. & value==. 

replace value2=subinstr(value2, ".0.", ".", 1) if result_value==.  & value==. & value2 !=""  
replace value2=subinstr(value2, "`", "", 1)   if result_value==. & value==.  & value2 !=""    

replace value2=subinstr(value2, "k", "", 1) if substr(value2, 1, 1)=="k"  & value==. 
replace value2=substr(value2, 7, 3) if strpos(value2, "Toady")  & value==. 
replace value2=substr(value2, 1, 3) if strpos(result_value_raw, "plan") & value==. 
replace value2=substr(value2, 4, 3) if strpos(value2, "Is ") & value==. 
replace value2=subinstr(value2, "+", ".", 1) if  value==. & result_value==. 
replace value2=subinstr(value2, ";", ".", 1) if  value==. & result_value==. 

replace value2=subinstr(value2, ".-", ".", 1) if  value==. & result_value==. 
replace value2=subinstr(value2, "'", ".", 1) if  value==. & result_value==. 

replace value2=substr(value2, 1, strlen(value2) -1)  if substr(value2, -1, 1) == "n" & result_value==. & value==. & value2!="" 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="m" 

replace lab_result_lt_or_gt=1 if substr(result_value_raw, -1,1)=="<" & result_value==. 
replace value2=substr(value2, 1, strlen(value2) -1) if substr(value2, -1, 1)=="<" & result_value==. 
 

destring value2, force gen(value1) 
*br *value* if value1<. 

replace value=value1 if value==. 
drop value1 


count  if result_value==. & value<. 
count  if result_value==. & value==. & result_value_raw !=""  

replace result_value=value if value<. & result_value==. 

*br subject_number labkey lab_img_dt full_version result_value_raw value2 lab_result_lt_or_gt  if result_value==. &  result_value_raw !=""    
drop value value2


count if result_value==. &  result_value_raw!="" & lab_img_result_intpn==.   // 84 no value need to drop since no lab test value 
*br labkey result_value_raw if result_value==. & value==. & result_value_raw!="" & result_interpretation=="" 

drop if result_value==. & result_value_raw!="" & lab_img_result_intpn==. 
  
 
********************************************************************
 
sort subject_number visitdate labkey lab_img_dt result_value lab_img_result_intpn full_version 
by subject_number visitdate labkey lab_img_dt result_value lab_img_result_intpn: assert _N==1 if result_value<. & labkey!="" 

unique subject_number visitdate labkey lab_img_dt result_value lab_img_result_intpn if labkey!="" 

lab var visitdate  "Date of office visit"
lab var result_value "lab test result value updated" 


unique  subject_number c_effective_event_date labkey lab_img_dt if labkey!=""  
count if result_value_raw=="" & labkey!="" & lab_img_type==1  & lab_img_result_intpn==. 
drop if result_value==. & lab_img_result_intpn==. & labkey!="" & lab_img_type==1  // drop no lab reslut value 

count if lab_img_type==1 & result_value<. & lab_img_result==.  // 6743 updated
replace lab_img_result=result_value if lab_img_result==. & result_value<. 

* out of standerd range discussed with Rich 

gen min=0 if result_value<. 
replace min=1 if labkey== "albumin" & result_value< 3
replace min=1 if labkey== "alp" & result_value< 20
replace min=1 if labkey== "alt" & result_value< 7
replace min=1 if labkey== "anemia_low" & result_value< 1
replace min=1 if labkey== "ast" & result_value< 10
replace min=1 if labkey== "ccp" & result_value< 0
replace min=1 if labkey== "cholesterol" & result_value< 100
replace min=1 if labkey== "cpk" & result_value< 10
replace min=1 if labkey== "creatinine" & result_value< 0.3
replace min=1 if labkey== "crp" & result_value< 0.05
replace min=1 if labkey== "esr" & result_value< 1
replace min=1 if labkey== "hct" & result_value< 15
replace min=1 if labkey== "hcv_rna" & result_value< 6
replace min=1 if labkey== "hdl" & result_value< 15
replace min=1 if labkey== "hgb" & result_value< 5.6
replace min=1 if labkey== "inr" & result_value< 1
replace min=1 if labkey== "ldl" & result_value< 25
replace min=1 if labkey== "neutrophils" & result_value< 10
replace min=1 if labkey== "plat_low" & result_value< 125 
replace min=1 if labkey== "platelets" & result_value< 125 
replace min=1 if labkey== "prism_ra" & result_value< 1 
replace min=1 if labkey== "rf" & result_value< 0
replace min=1 if labkey== "tot_bilirubin" & result_value< 0.1
replace min=1 if labkey== "triglycerides" & result_value< 25
replace min=1 if labkey== "vectra_da" & result_value< 1
replace min=1 if labkey== "vit_d" & result_value< 4
replace min=1 if labkey== "wbc" & result_value< 0.3

gen max=0 if result_value<. 
replace max=1 if labkey== "albumin" & result_value> 6 & result_value<. 
replace max=1 if labkey== "alp" & result_value> 860 & result_value<. 
replace max=1 if labkey== "alt" & result_value> 125 & result_value<. 
replace max=1 if labkey== "anemia_low" & result_value> 100 & result_value<. 
replace max=1 if labkey== "ast" & result_value> 200 & result_value<. 
replace max=1 if labkey== "ccp" & result_value> 1000 & result_value<. 
replace max=1 if labkey== "cholesterol" & result_value> 400 & result_value<. 
replace max=1 if labkey== "cpk" & result_value> 600 & result_value<. 
replace max=1 if labkey== "creatinine" & result_value> 12 & result_value<. 
replace max=1 if labkey== "crp" & result_value> 100 & result_value<. 
replace max=1 if labkey== "esr" & result_value> 150 & result_value<. 
replace max=1 if labkey== "hct" & result_value> 72 & result_value<. 
replace max=1 if labkey== "hcv_rna" & result_value> 10 & result_value<. 
replace max=1 if labkey== "hdl" & result_value> 125 & result_value<. 
replace max=1 if labkey== "hgb" & result_value> 25.3 & result_value<. 
replace max=1 if labkey== "inr" & result_value> 3 & result_value<. 
replace max=1 if labkey== "ldl" & result_value> 210 & result_value<. 
replace max=1 if labkey== "neutrophils" & result_value> 95 & result_value<. 
replace max=1 if labkey== "plat_low" & result_value> 600 & result_value<. 
replace max=1 if labkey== "platelets" & result_value> 600 & result_value<. 
replace max=1 if labkey== "prism_ra" & result_value> 25 & result_value<. 
replace max=1 if labkey== "rf" & result_value> 1000 & result_value<. 
replace max=1 if labkey== "tot_bilirubin" & result_value> 1.9 & result_value<. 
replace max=1 if labkey== "triglycerides" & result_value> 500 & result_value<. 
replace max=1 if labkey== "vectra_da" & result_value> 100 & result_value<. 
replace max=1 if labkey== "vit_d" & result_value> 95 & result_value<. 
replace max=1 if labkey== "wbc" & result_value> 100 & result_value<. 

lab define ny 0 not 1 yes, modify 
lab val min ny 
lab val max ny 
lab var min "less than STD range" 
lab var max "greater than STD range" 
tab1 min max 

drop labkey result_value_raw


* clean ulper limited value: lab_uln_value, current as missing if raw data has any charactors 
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
/*
br  subject_number visitdate lab_img_name lab_uln_value_raw uln lab_uln_value if uln<.
br  subject_number visitdate lab_img_name lab_uln_value_raw uln lab_uln_value if uln==. & lab_uln!=""



export excel subject_number visitdate lab_name lab_uln_value_raw uln lab_uln_value if uln<. using "temp\alllabs_update_uln", sheet(updated, modify) firstrow(var) 
export excel subject_number visitdate lab_name lab_uln_value_raw uln lab_uln_value if uln==. & lab_uln="" using "temp\alllabs_update_uln", sheet(unupdated, modify) firstrow(var) 
*/

replace lab_uln_value=uln if lab_uln_value==.
drop lab_uln uln 
 
sort subject_number visitdate lab_img_name lab_img_dt   

unique  subject_number visitdate lab_img_type lab_img_name lab_img_dt   // not unique 
codebook visitdate // [01jan1900,07jan2025] ==> [01jan1900,31dec2024]
count if visitdate>d(31dec2024)

count if visitdate>d($cutdate)
drop if visitdate>d($cutdate)
compress 
save clean_table\1_4_alllabs_$datacut, replace 





