/*
2023-11-28 
freq_value become str2. check and destring 
Updated by LG 2023-09-12 as step 3A to clean drugs of interest

Program: Ying Shan
Date 2023-02-23
data use: preTM_TAEdrugs 

Aim: to clean preTM TAEdrugs 
 
1. append to two rows if report two drugs at one row  
2. clean free drug and oth_drug_spec text fields to match MDbiologic and MDdmards 
3. create route variable if report route in drug text field 

*/

mdesc dose_txt if dose_patient!="" // there are overlapps, do not use dose_patient

*groups hdr_study_source hdr_dw_event_type if dose_patient!="" // all preTM EN/FU 

// 2023-09-12 keep original values ==>dose/freq_unit is for value label purpose, we update dose/freq_code as the numeric variable with labels

foreach x in dose_value dose_unit_code freq_value freq_unit_code{
	clonevar `x'_raw=`x'
}

// generate lower case of dose and freq txt 
foreach x in dose_txt freq_txt{
	gen l`x'=lower(`x')
}

// ticket #300 inconsistencies for freq_unit, does not affect freq_unit_code 
// 2024-04-29 updated freq_unit 100=once (single-dose)
lab define freq_unit_code 100 "once (single-dose)" 960 cycles 920 "every __ days" 910 "every __ hours" 940 "every __ months" 930 "every __ weeks" 999 "other frequency (specify)" 950 "steroid taper total days" 911 "times per day" 921 "times per week" 990 "as needed", modify
// 2024-04-29 updated dose_unit # 17 to "g"
lab define dose_unit_code 12 "mg" 15 "mg/kg" 17 "g" 22 "vials" 999 "other dose (specify)", modify 

foreach x in freq dose{
	destring `x'_unit_code , replace 
	lab val `x'_unit_code `x'_unit_code 
	codebook `x'_unit_code
	groups `x'_unit `x'_unit_code, missing ab(16)
}



// add to route_code variable 
/*
            tabulation:  Freq.   Numeric  Label
                       139,362       100  oral (PO)
                        38,596       200  subcutaneous (SC)
                           196       201  subcutaneous (SC) injection
                        35,686       210  intravenous (IV)
                           130       211  intravenous (IV) infusion
                             6       212  intravenous (IV) injection
                            25       220  intramuscular (IM) injection
*/
// add more route values from dose/freq_txt 
replace route_code=200 if route_code==. & (strpos(ldose_txt, "sq") | strpos(ldose_txt, "sc")|strpos(lfreq_txt, "sq") | strpos(lfreq_txt, "sc"))

replace route_code=210 if route_code==. & (strpos(ldose_txt, "iv") |strpos(lfreq_txt, "iv"))

replace route_code=100 if route_code==. & (strpos(ldose_txt, "po") & strpos(ldose_txt, "pow")==0  | strpos(ldose_txt, "oral")|strpos(lfreq_txt, "po") & strpos(lfreq_txt, "pow")==0 | strpos(lfreq_txt, "oral") )

replace route_code=220 if route_code==. & (strpos(ldose_txt, "inj")| strpos(lfreq_txt, "inj") )

/////////////////////////////////////////////////////////////
//	dose 
/////////////////////////////////////////////////////////////

/*
groups dose_unit dose_unit_code, missing ab(16)
  +-----------------------------------------------+
  | dose_unit   dose_unit_code    Freq.   Percent |
  |-----------------------------------------------|
  |                              480471     46.58 |
  |        mg               12   478167     46.36 |
  |     mg/kg               15    39371      3.82 |
  |     vials               22    33497      3.25 |
  +-----------------------------------------------+
*/

// start cleaning numeric value 
// check if there are overlapps ==> preTM only, most is remicade 
mdesc dose_value dose_unit if dose_txt!=""
//dose_value dose_unit dose_txt
*groups hdr_study_source hdr_dw_event_type drugkey  if (dose_value!=.|dose_unit!="") & dose_txt!=""

// check preTM data for why there are both dose_value and dose_txt==>from oth_bio_dose 
*list hdr_crf_version hdr_study_source hdr_dw_event_type hdr_subject_id hdr_effective_event_date drugkey dose_value dose_unit dose_txt if (dose_value!=.|dose_unit!="") & dose_txt!="" & drugkey!="remicade", noobs ab(16)

// for string values such as unk and all the listed values, just do not extract the values from ldose_txt
*replace dose_unit_code=. if  strpos(dose_txt, "unk") 

*for any tnfgidose "weight based" uk test ukn x "wt based" "?" "clinical trial"  ct "information not in current records" "n/a":  replace dose="" if  dose=="X" 

*cap drop dose_unit 
* create dose unit variable 
*gen str4 dose_unit= "__mg" if strpos(dose, "mg")  & strpos(dose, "kg")==0 & strpos(dose, "ml")==0 

/////// 12==>mg 

replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "mg")  & strpos(ldose_txt, "kg")==0 & strpos(ldose_txt, "ml")==0

for any 1000m "1000 m" 125m "750 m (iv)" "750m" "750 ng" "msg" : replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "X")    

replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "g") & strpos(ldose_txt, "k")==0 & strpos(ldose_txt, "ng")==0 & drugkey=="orencia" & strpos(ldose_txt, "ml")==0 

replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "g") & strpos(ldose_txt, "kg")==0 & strpos(ldose_txt, "ml")==0 

for any gram mg: replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "X") 

replace dose_unit_code=12 if dose_unit_code==. & strpos(ldose_txt, "m") & strpos(ldose_txt, "ml")==0 

for any "125 ml" 250ml "12.5 ml" "11m\g" : replace dose_unit_code=12 if dose_unit_code==. & ldose_txt=="X" 


////////15==>mg/kg
 
replace dose_unit_code=15 if dose_unit_code==. & strpos(ldose_txt, "mg") & strpos(ldose_txt, "kg") & strpos(ldose_txt, "/") 

for any "mgk/g" "mg/lg" mgkg "mg?kg" "mk/kg" "mg kg" "mg 1kg" "m/kg" "mb/kg" "mg/ky" "mg/kq" "mg/km" "mg/g" "mg/k" "g/kg" "mg/ml": replace dose_unit_code=15 if dose_unit_code==. & strpos(ldose_txt, "X")  

/////////////////////////////////////////////////////////////
* create dose value txt variable- extract numbers from dose 
gen dose_value_txt=ustrregexs(0) if dose_value==. & ustrregexm(ldose_txt,"[0-9,]+")  & strpos(ldose_txt, ".")==0 & strpos(ldose_txt, "-")==0 

*destring dose_va, ignore(",") replace 

gen d1=1 if strpos(ldose_txt, ".") 
gen d2=1 if strpos(ldose_txt, "-") 

// ssc install moss 
moss ldose_txt, match("([0-9]+)") regex 

replace dose_value_txt= _match1 + "." + _match2 if  d1==1 & d2==. 

replace dose_value_txt = _match1 if dose_unit_code==15 & dose_value_txt=="" & strpos(ldose_txt, "vial") 

replace dose_value_txt = _match1 if dose_value_txt=="" & (strpos(ldose_txt,"mg/kg -") |  strpos(ldose_txt,"mg/kg-")) & d1==. 

gen dunk=1 if strpos(ldose_txt, "unk") 
for any uk test ct triall note records: replace dunk=1 if strpos(ldose_txt, "X") 

gen dose2=_match1 + "-" + _match2 if d2==1 & d1==. & dunk==. 
replace dose2 = _match1 + "." + _match2 + "-" + _match3 + "." if d1==1 & d2==1 & dose2=="" 

* clean dosage typo 
replace dose_value_txt="4" if dose2=="3.4-4." 
replace dose_value_txt="40" if dose2=="4-"
replace dose_value_txt="1000" if dose2=="1000-2" | strpos(ldose_txt, "1,000") & dose_unit_code==12
 
* correct rituxan/truxiam dose value from g to mg
gen g=1 if dose_unit_code==. & strpos(ldose_txt, "g") & strpos(ldose_txt, "kg")==0 & strpos(ldose_txt, "ml")==0 |  strpos(ldose_txt, "gram") 
 
replace dose_value_txt="1000" if dose_value_txt=="1" & g==1 & (drugkey=="rituxan" | drugkey=="truxima") & dose_unit_code==12
replace dose_value_txt="1000" if dose_value_txt=="1" & g==1 & dose_unit_code==12 
replace dose_value_txt="1000" if dose_value_txt=="1" & strpos(ldose_txt, "gram") 

replace dose_value_txt=dose2 if dose_value_txt=="" & dose2!="" 
replace dose_value_txt="" if dose_value_txt== "0"

drop d1 d2 _* g dunk dose2

//////////////////////////////////////////////
* clean dose_value
////////////////////////////////////////////// 

gen ck=substr(dose_value_txt, -1, 1)
gen ck2=subinstr(dose_value_txt, ".", "", 1) 
replace dose_value_txt=ck2 if ck=="." 
drop ck ck2 

replace dose_value_txt="" if ldose_txt=="06/02/2016" 
replace dose_value_txt="40" if dose_value_txt=="40.0" 


for any q4wk q4w 6wks q8w q8wk "q2wks x 2 doses" "x 2 doses" : replace dose_value_txt="" if ldose_txt=="X"


replace dose_value_txt="258" if ldose_txt=="258 mg"
replace dose_value_txt="10" if ldose_txt=="110mg" & drugkey=="mtx"
replace dose_value_txt="12.5" if ldose_txt=="125mg" & drugkey=="mtx" 
replace dose_value_txt="750" if ldose_txt=="0750mg"
replace dose_unit_code=15 if ldose_txt=="8.3 mg" & dose_unit_code==12
replace dose_unit_code=12 if ldose_txt=="1000 mg/kg" 

forvalues i= 2(1)20{
	replace dose_value_txt="`i'" if strpos(dose_value_txt, "-`i'")
}

forvalues i= 100(100)2000{
	replace dose_value_txt="`i'" if strpos(dose_value_txt, "-`i'")
}

groups dose_value_txt if strpos(dose_value_txt, "-")

replace dose_value_txt="" if strpos(dose_value_txt, "-")

destring dose_value_txt, force replace 
  
replace dose_value=dose_value_txt if dose_value==.


// example 1
*list hdr_study_source hdr_dw_event_type hdr_subject_id hdr_effective_event_date drugkey drug_date drug_status dose_value dose_txt if hdr_subject_id=="003001193" & hdr_effective_event_date=="2012-11-21" & drugkey=="mtx", noobs ab(20)

*save ".\temp_data\clean_bv_drugs_of_interest_dosetemp1", replace 
////////////////////////////////////////////////////////////////////////////////////////////////////
///////////	use MS-Word to replace f1 to lfreq_txt; fv to freq_value_txt; f2 to freq_tempvar

*use ".\temp_data\clean_bv_drugs_of_interest_dosetemp1", clear

mdesc dose_txt freq_txt // use dose info for frequency too.

////////////////////////////////////////////////////////////////////////////////
//	Frequencies from both freq_txt and if missing, try to find from dose_txt
////////////////////////////////////////////////////////////////////////////////
// 2023-09-12 added by LG 

replace lfreq_txt=ldose_txt if lfreq_txt=="" & ldose_txt!=""

gen freq_temp=""  
// use freq_txt for freq_value_txt
gen freq_value_txt= ustrregexs(0) if ustrregexm(freq_txt,"[0-9,]+")  & strpos(freq_txt, ",")==0  & strpos(freq_txt, "-")==0
 
tab freq_value_txt

tab lfreq_txt if freq_value_txt=="00"

tab lfreq_txt if freq_value_txt=="98"
replace freq_value_txt="" if freq_value_txt=="00"
********************************
* 1. twice per day 

for any "bid" "bd" "2 times a day" "2 x daily" "2x daily" 2xday "twice a day" "twice daily" bid q12hours 2dq  "1 tab bid" "twice qd" "2 daily" "2 times day" "2 times daily": replace freq_temp="twice per day" if strpos(lfreq_txt, "X") 

replace freq_value_txt="2" if freq_temp=="twice per day" 
groups freq_value_txt lfreq_txt if freq_temp=="twice per day", missing ab(16)

********************************
*2. once daily  

for any "2bedtime" "once daily" " daily" " po q day" "dai;ly" dailu daily dailyy daiy daly day "po q day" "q day" qday "po qd" qd "1 qd" "qd " "q d" qd  "qd " dialy  "q d " qid qd "qd " qday "sc q day" "6 tabs daily" "q.d." "1qd": replace freq_temp="once daily" if  lfreq_txt=="X" & freq_temp==""  

replace freq_temp="once daily" if (strpos(lfreq_txt, "qd") |strpos(lfreq_txt, "dq"))  & freq_value_txt=="" 

replace freq_value_txt="1" if freq_temp=="once daily" 
groups freq_value_txt lfreq_txt if freq_temp=="once daily", missing ab(16)

*********************************
*3. every _ days (specify)
// LG added freq_value_txt 
replace freq_temp="every _ days (specify)" if freq_temp=="" & (strpos(lfreq_txt, "ev") | strpos(lfreq_txt, "q")) & strpos(lfreq_txt, "da") & strpos(lfreq_txt, "mo")==0 & strpos(lfreq_txt, "w")==0 

for any "q 21 d" "q 4 d" q10d "q21 d" "q7-10d" qod  "q2 days" "q21 d" "q21days" "q28 days" "q28days" "q2days" "x14 days" "x14 days" "q 14 d" "14 days" "28 days" 28day 28days "35 days" "5 days": replace freq_temp="every _ days (specify)" if freq_temp=="" & strpos(lfreq_txt,"X") 

replace freq_temp="every _ days (specify)" if strpos(lfreq_txt, "q") & strpos(lfreq_txt, "d") & freq_value_txt!="" & freq_temp=="" & strpos(lfreq_txt, "m")==0 & strpos(lfreq_txt, "w")==0  & freq_value_txt!=""

// extract freq_value_txt from X days 
forvalues i=2/21{
	for any "`i' day" "`i'days" "`i'd": replace freq_value_txt="`i'" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" & freq_value_txt==""
}
// 7 vs. 17
for any "17 day" "17day" "17d": replace freq_value_txt="17" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" & freq_value_txt=="7"
// 4 vs. 14
for any "14 day" "14day" "14d": replace freq_value_txt="14" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" & freq_value_txt=="4"
// 3 vs.13
for any "13 day" "13day" "13d": replace freq_value_txt="13" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" & freq_value_txt=="3"
// every other day
for any "other day" "oth.day": replace freq_value_txt="2" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" //& freq_value_txt==""
// every third day
for any "third day": replace freq_value_txt="3" if  strpos(lfreq_txt,"X") & freq_temp=="every _ days (specify)" //& freq_value_txt==""

groups freq_value_txt lfreq_txt if freq_temp=="every _ days (specify)", missing ab(16)

********************************
* 4. times per day (specify) 
for any "q 4"  "q 8" q6 "tid" "three times a day" "4 x daily" "4 times daily" "6 tabls daily":  replace freq_temp="times per day (specify)" if lfreq_txt=="X" & freq_temp=="" 

for any "three" "tid": replace freq_value_txt="3" if freq_temp=="times per day (specify)" & strpos(lfreq_txt,"X") & freq_value_txt==""
groups freq_value_txt lfreq_txt if freq_temp=="times per day (specify)", missing ab(16)

*****************************
* 5. twice per week

for any "b-weekly" "be weekly" "bi weekly" "bi-weekly" biwekly biwkly biweekly biw "bi-wkly" "b/w" "b i w"  "be-weekly" "biweekl" 2qw 2qweek 2qwk 2xw 2xwk 2xqwk "x2 per week" "x2/week" "2 x per week" "2 x per wk" "2 x qwk" "2 x week" "2x wk" 2xweek "2x/ wk" "2 x weekly" "2 x wk" "x2/week" "x2 wk" "x2 per week" "2/wk" "2/w" "2 wkly" "2 x / wk" "2 x 1 week" "2 x 1 wk" "2 x/ wk" "2 x/wk" "2 x/wk." "2 y/wk" "2 qwk" "2 per wk" "1 2xw" "ii qw" "2 times a w" "2 times per w" "2 times w" "2x / week" "2x per week" "2x qwk" "2x week" "2x wk" "2x/week" "2x/wk" "twice a w" "twice per w" "twice weekly" "twice wkly" "q other w" "2xwkly": replace freq_temp="twice per week" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "1")==0 & freq_temp=="" 

replace freq_value_txt="2" if freq_temp=="twice per week" & freq_value_txt==""
groups freq_value_txt lfreq_txt if freq_temp=="twice per week", missing ab(16)

*********************************"
* 6. once per week 
for any "1 inj. sq weekly" "1/w" "1x week" "q 1 w" "q 1w" q1w "once per week" "q w" "q.week" "q0q" "once a w" "weekly" "every week" "every wekk" "one a week" "x 1 weekly" "1 inj q/wk"   "q/wk" "1 a week" "q 1 week": replace freq_temp="once per week" if strpos(lfreq_txt, "X") & freq_temp==""

for any aweek weekly qwk " qwk" qw qweek q1w poqwk q1w q1week q1wk q1wks qwk qwkk qwks scqwk "weekly'" weeks weeklly weekly "weekly " weeky weelkly weely wekly week wkly qweekly qweeks qweenk "qweek " qweej "q weekly"  "every week"  "once weekly"  "once a wk"  "per week" "po weekly" "po qwk" "q 1 wweek" "q 1 week;y" "q 1 weeks"  "1 weekly" "q 1 weeks" "q 1 wk" " q 1wk" "q  wk" "q w" "q w " "q*wk" "q wks" "q weel" "sc q wk" "sc qw" "sc qweek" "sc qwk" "sc wekly" "scqweek"  "sq weekly" "weekly sq" "qwk " qyw "sc weekly" "weekley"  "wk" "weekly (stopped july 09)" "weekly - (stopped 2/09)" "wky"   "once wk" "every wk"  "each wk" "each week"  50mg/wk "once in week"  "once week" "once wK" "once wkly" "once/week" qwkj "sq qwk" woq  "1 qwk" "1 qw" 1qwk 1gwk "1 inj qwk" "1 wkly" "0.6 cc qwk" "0.8ccqwk" ".7ccqwk" ".8cc/wk"   "15 mg/wk"  q1wk q1wkly q1week q1w q1wks "1 wk" "1 week" "1 x wk"  "1 x week"  "17,5 weekly": replace freq_temp= "once per week" if lfreq_txt=="X" & freq_temp==""  

replace freq_temp="once per week" if strpos(lfreq_txt, "/week") &strpos(lfreq_txt, "x")==0 & freq_temp=="" 
 
groups freq_value_txt lfreq_txt if freq_temp=="once per week" , missing ab(16)
/*
implemented for times per week 
  |              3                                3 times weekly       1      0.01 |
  |              3                                    3 x weekly       4      0.03 |
  |--------------------------------------------------------------------------------|
  |              3                                     3x weekly       2      0.02 |
  |              3                                     3x/weekly       2      0.02 |
  |              4                                    4 x weekly       6      0.05 |
  |              7                                      7 q week       2      0.02 |
  |              8                                       8/weeks       2      0.02 |
  +--------------------------------------------------------------------------------+
*/

*************************
* 7. every 2 weeks 
// LG added more for v20231020
replace freq_temp="every 2 weeks" if strpos(lfreq_txt, "qow") | strpos(lfreq_txt, "q o w") | strpos(lfreq_txt, "q2w") & strpos(lfreq_txt, "m")==0 & freq_temp==""|strpos(lfreq_txt, "q 2 wk")|strpos(lfreq_txt, "q/o wk")|strpos(lfreq_txt, "(2) wk")|strpos(lfreq_txt, "every other wk")

for any "every other wk" "bw" "(2) wk" "q/o wk" "q2 w" "q 2 w" "2 wk" "every 2 w" "q 2w" "q.o.w" "qo wk" "every other w" "every two weeks" "every other  w" "every othetr w" "q o w" qok "q ow" : replace freq_temp="every 2 weeks" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "6")==0 & strpos(lfreq_txt, "0")==0 & strpos(lfreq_txt, "1")==0 & freq_temp==""

for any "2 week" "1 qok" 2w 2wk "2 weeks" "2 weeks" "2 weeks " " 2 weeks" "qod week" "qo2 weeks" q2sw "every 2weeks" qow "q0 w" "q o w" "twice monthly" "every 14 days" qow qoweek qowek qowk "evey other week" "evert other week"  "very other week" "qo week" "qo weekly" "qow " qbwk "q 14 days" "q 14 days " "bimonthly"  "q 2k"   qowly "sc qow" "q ow" "q-2 wk" "e o week"  aow eow "e o w" 1qow "1 cc/2 wk" "1 inj qow" "one qowk" "1 qo week" "q.o. week" "q 2 wk x 1" "very 2 weeks" "x 2 week" "x 2 weeks" "q. 2 weeks" "1 inj q ow" :replace freq_temp="every 2 weeks" if strpos(lfreq_txt,"X" ) & freq_temp==""

replace freq_temp="every 2 weeks" if strpos(lfreq_txt, "2 weeks apart") & strpos(lfreq_txt, "m")==0  & freq_temp==""

replace freq_value_txt="2" if freq_temp=="every 2 weeks" & freq_value_txt==""
groups freq_value_txt lfreq_txt if freq_temp=="every 2 weeks" , missing ab(16)
// implement for 12 weeks 

//////////////////////////
* 8. every 4 weeks 

replace freq_temp="every 4 weeks" if (strpos(lfreq_txt, "q") | strpos(lfreq_txt, "ever"))  & strpos(lfreq_txt, "w")  & strpos(lfreq_txt, "4") & strpos(lfreq_txt, "m")==0 & strpos(lfreq_txt, "x")==0 & strpos(lfreq_txt, "-")==0 & freq_temp==""

replace freq_temp="every 4 weeks" if strpos(lfreq_txt, "q")  & strpos(lfreq_txt, "k")  & strpos(lfreq_txt, "4") & strpos(lfreq_txt, "m")==0 &  strpos(lfreq_txt, "-")==0 & freq_value_txt!="" & freq_temp==""

for any "w4 wks" "x 4 wks" "q4wk x 6 cycles"  "q4akks": replace freq_temp="every 4 weeks" if strpos(lfreq_txt, "X")  &  freq_temp==""

for any "4weeks" "4wk" "4wks"  "4 wwks" "4 wks" "4wkeeks" "4 week" "4 wjs" "4 wk" "4 weeks" " 4 weeks" : replace freq_temp="every 4 weeks" if lfreq_txt=="X" & freq_temp==""

replace freq_value_txt="3" if freq_temp=="every 4 weeks" & strpos(lfreq_txt, "3") & freq_value_txt==""
replace freq_value_txt="8" if freq_temp=="every 4 weeks" & strpos(lfreq_txt, "8") & freq_value_txt==""
replace freq_value_txt="4" if freq_temp=="every 4 weeks"  & freq_value_txt==""

groups freq_value_txt lfreq_txt if freq_temp=="every 4 weeks" , missing ab(16)
// LG: 24 and other numbers will fit with new categories, do not have to change freq_temp

///////////////////////////////
* 9. every __ weeks (specify) 
// 2023-09-18 trying to accomodate q/o wk with mg 
replace freq_temp="every _ weeks (specify)" if (strpos(lfreq_txt, "ev") | strpos(lfreq_txt, "q")) & strpos(lfreq_txt, "w") & strpos(lfreq_txt, "mo")==0 & strpos(lfreq_txt, "time")==0  & strpos(lfreq_txt, "qw")==0 & freq_value_txt!="" & freq_temp=="" 

for any  "q3wk for 6 mo" e8w "once every eight weeks"  "q 8 qweeks" "3mg/kg every 8 weeks"  q8k q82k  "q 8 ks"  q5ks "2 times every 6 weeks" "x 8 weeks" "q8k" "x2 doses q4-6wk" "8 weekly" "8weekly" q0w  q0week q0wk : replace freq_temp="every _ weeks (specify)" if lfreq_txt=="X" & freq_temp=="" 

for any wks weks week wk qwk ws: replace freq_temp="every _ weeks (specify)" if  strpos(lfreq_txt, "X") & freq_value_txt!=""  & strpos(lfreq_txt, ",")==0 & strpos(lfreq_txt, "x")==0  & strpos(lfreq_txt, "-")==0 & strpos(lfreq_txt, " 0 ")==0 & strpos(lfreq_txt, "0 $")==0 & freq_value_txt!="" & freq_temp==""

replace freq_temp="every _ weeks (specify)" if freq_temp=="every 2 weeks" & freq_value_txt=="12"

for any "6 weeks" "6wk": replace freq_value_txt="6" if freq_temp=="every _ weeks (specify)" & strpos(lfreq_txt, "X") 
for any "16 weeks" "16wk": replace freq_value_txt="16" if freq_temp=="every _ weeks (specify)" & strpos(lfreq_txt, "X") & freq_value_txt=="6"
for any "96 weeks" "96wk": replace freq_value_txt="96" if freq_temp=="every _ weeks (specify)" & strpos(lfreq_txt, "X") & freq_value_txt=="6"
groups freq_value_txt lfreq_txt if freq_temp=="every _ weeks (specify)" , missing ab(16)

///////////////////////////////////
// 10. times per week 
for any "q wk" "q  wk" "weekly" "a week" qwk "per week" "nine weeks" "seven weeks" "six weeks" "62ks"  : replace freq_temp="times per week (specify)" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "tab") & freq_temp==""
 
for any  "7.5 mg (6 tab wkly)" 5tabswk "weekly6" "wkly x 3" "wkly x 2" "qwk x 4"  "3-6 tabs/week" "4 cc q wk" "4 tabls qwk" "7 q week" "8 pa q wk" "8 tabls q wk" "2 q wks" "9 q wks" "sx/wk" "2 q wk" "3x/wk" "1-2x qwk" "tiw": replace freq_temp="times per week (specify)" if lfreq_txt=="X" & freq_temp=="" 

forvalues i=2/8{
replace freq_temp="times per week (specify)" if freq_value_txt=="`i'" & freq_temp=="once per week"
}

for any "2x": replace freq_value_txt="2" if freq_temp=="times per week (specify)" & strpos(lfreq_txt,"X") & freq_value_txt==""
for any "tiw": replace freq_value_txt="3" if freq_temp=="times per week (specify)" & lfreq_txt=="X" & freq_value_txt==""
groups freq_value_txt lfreq_txt if freq_temp=="times per week (specify)" , missing ab(16)

**************************************************************
* 11. once per month -should combine with every 4 weeks? 

for any "q mo" "once a m" "every m" "once monthly": replace freq_temp="once per month" if strpos(lfreq_txt, "X")  & freq_temp==""

for any "1 x mo." "month" " months" "once monthly" monothly monhly "month;y" monthy montly monyly "q i month" monthly qmo qmonth "qmonth " qmonthly qmos "sq 1x mmonthly" "one monthly" monthlly "monthly "  "every month" "q m" mq qm "sq 1x monthly"  "q/month" "monthly?" "lv monthly?" : replace freq_temp="once per month" if lfreq_txt=="X" & freq_temp==""

replace freq_value_txt="1" if freq_temp=="once per month" &freq_value_txt=="" 
groups freq_value_txt lfreq_txt if freq_temp=="once per month" , missing ab(16)

**************************************************************
* 12. every _ months" 
// re-do 
replace freq_temp="" if freq_temp=="every _ months (specify)"

for any ever q : replace freq_temp="every _ months (specify)" if  strpos(lfreq_txt, "X") & strpos(lfreq_txt, "m") & strpos(lfreq_txt, "w")==0 & strpos(lfreq_txt, "d")==0 & freq_temp==""

for any "4-6 m" 6months yearly q4month "twice year" q4mow "q year" annually  "q6 mo" q6mo "q 4-5 m" "q 4-6 m" "q 6 m" "q6 m" "q 4-6m" q3m q6m q7m q5m q4m "q4-6m" "q4 m" "q 4-6  m" "q5 m" qomo qyear "/year" annual "bi-y" "bi-yearly" "twice year" "x3 month" "x 3month" "twice every 6 month" "twice yrly" :replace freq_temp="every _ months (specify)" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "w")==0  & freq_temp==""

for any "twice every 6 months"  "twice year" "twice yearly" "twice yrly" "q2w x2 q6m" q4mow "q 6 mo x 2 wks" "q 2 weeks then q 6 months" "q 2 weeks every 6 mo" "wk0,2,q4 months" "twice yrly" "wk0, 2, q4months" "2 weeks apart, then 6 mo" anually "2 doeses per six months" "2 x year" 2wksq6mo : replace freq_temp="every _ months (specify)" if lfreq_txt=="X"  & freq_temp==""

for any " 2mo" " 2 mo" " 2 mos" " 2  mo": replace freq_value_txt="2" if  strpos(lfreq_txt,"X") & freq_temp=="every _ months (specify)" & (freq_value_txt=="12")

for any "5mo" "5 mo" "5 mos" "5  mo": replace freq_value_txt="5" if  strpos(lfreq_txt,"X") & freq_temp=="every _ months (specify)" & (freq_value_txt=="")

for any "4mo" "4 mo" "4 mos" "4  mo": replace freq_value_txt="4" if  strpos(lfreq_txt,"X") & freq_temp=="every _ months (specify)" & (freq_value_txt=="")

for any "6mo" "6 mo" "6 mos" "6  mo" "6 mths" "6m": replace freq_value_txt="6" if  strpos(lfreq_txt,"X") & freq_temp=="every _ months (specify)" & (freq_value_txt==""|freq_value_txt=="1000"|freq_value_txt=="2"|freq_value_txt=="12"|freq_value_txt=="1")

for any "9mo" "9 mo" "9 mos" "9  mo": replace freq_value_txt="9" if  strpos(lfreq_txt,"X") & freq_temp=="every _ months (specify)" & (freq_value_txt=="12")

replace freq_value_txt="12" if freq_temp=="every _ months (specify)" & freq_value_txt==""

replace freq_value_txt="1" if freq_temp=="every _ months (specify)" & freq_value_txt=="12" & lfreq_txt=="50mg qm"

for any "twice year" "bi-yearly" "2 x year":replace freq_value_txt="6" if freq_temp=="every _ months (specify)" & freq_value_txt=="12" & lfreq_txt=="X"

groups freq_value_txt lfreq_txt if freq_temp=="every _ months (specify)" , missing ab(16)

/////////////////////////////////
* 13. every _ hours
 
for any  q24hrs q24h : replace freq_temp="once daily" if  lfreq_txt=="X"  & freq_temp==""

replace freq_value_txt="1" if freq_temp=="once daily" & freq_value_txt=="24"
groups freq_value_txt lfreq_txt if freq_temp=="once daily" , missing ab(16)
 

////////////////////////////////////////////////////////////////////////////
* create frequency value variable- extract numbers from frequency  

gen fm="" 
for any yearly annually anually "q year" qyear: replace fm="12" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "-")==0 & strpos(freq_temp, "_") 

for any "twice year" "twice yrly" "bi-yearly" "2 x year" "2 doses /year": replace fm="6" if strpos(lfreq_txt, "X") & strpos(freq_temp, "_")  

for any other qo "q o" "q/o": replace fm="2" if freq_value_txt=="" & strpos(freq_temp, "_") &  strpos(lfreq_txt, "X") & strpos(lfreq_txt, "-")==0 
for any three tid: replace fm="3" if (strpos(freq_temp, "_") | strpos(freq_temp, "times")) & strpos(lfreq_txt, "X") & strpos(lfreq_txt, "-")==0 
for any eight : replace fm="8" if freq_value_txt=="" & strpos(freq_temp, "_") & strpos(lfreq_txt, "X") & strpos(lfreq_txt, "-")==0 

replace freq_value_txt=fm if fm!="" & freq_value_txt==""

drop fm 

gen d1=1 if strpos(lfreq_txt, "-") 

moss lfreq_txt, match("([0-9]+)") regex 

 
gen fv2= _match1 + "-" + _match2 if  d1==1 & _match1!="" & _match2!="" 
replace fv2= _match2 + "-" + _match3 if  d1==1 & _match2!="" & _match3!=""
replace fv2= _match1 + "-" + _match2 if  d1==1 & _match1!="" & _match2!="" & substr(lfreq_txt, -9, .)=="x 2 doses" 


for any "day 1 and 15 q" "d1 & d15 q" "day1&day 15 q" "2 x q 6 m" "q2w x2 q6m" "1000mg q6mo x 2 doses" "7.5 mg (6 tab wkly)" : replace fv2="6" if strpos(lfreq_txt, "X") 

replace fv2="" if lfreq_txt=="last dose 5-9-09" 

replace freq_value_txt=fv2 if fv2!="" & freq_value_txt==""

replace freq_value_txt="3" if lfreq_txt=="tiw" & freq_value_txt==""
replace freq_value_txt="6" if lfreq_txt=="sx/wk" & freq_value_txt==""
replace freq_value_txt="3" if lfreq_txt=="tid" & freq_value_txt==""
replace freq_value_txt="16" if lfreq_txt=="1 6 weeks" & freq_value_txt=="" 
replace freq_value_txt="18" if lfreq_txt=="1 8 wks" & freq_value_txt==""
replace freq_value_txt="6" if lfreq_txt=="62ks" & freq_value_txt==""
replace freq_value_txt="5" if lfreq_txt=="five tabs a week" & freq_value_txt==""
replace freq_value_txt="6" if freq_temp=="every _ weeks (specify)" & lfreq_txt=="six weeks" & freq_value_txt==""
replace freq_value_txt="7" if freq_temp=="every _ weeks (specify)" & lfreq_txt=="seven weeks" & freq_value_txt==""
replace freq_value_txt="9" if freq_temp=="every _ weeks (specify)" & lfreq_txt=="nine weeks" & freq_value_txt==""
replace freq_value_txt="8" if lfreq_txt=="3mg/kg every 8 weeks" & freq_value_txt==""
replace freq_value_txt="10" if strpos(lfreq_txt, "q 10 days") & freq_value_txt=="" & freq_value_txt==""

drop fv2 d1 

for any  "0 & 2 weeks" "0 + 2 wks" : replace freq_temp="" if lfreq_txt=="X" & freq_temp=="every _ weeks (specify)"

replace freq_temp="every _ months (specify)"  if strpos(lfreq_txt, "mo") & freq_temp=="" & strpos(lfreq_txt, "-")==0 & freq_value_txt!=""

for any "6 months - 12 months" "six months" 2wksq6mo "2 x year" "2x yr."  : replace freq_temp="every _ months (specify)" if strpos(lfreq_txt, "X") & freq_temp=="" 
 
for any "0 & 2 weeks at 6 month cycle" "0 & 2 weeks with 6 month repeat": replace freq_temp="every _ months (specify)" if lfreq_txt=="X" 

for any "0 & 2 weeks at 6 month cycle" "0 & 2 weeks with 6 month repeat" "2 x 6" 2wksq6mo "2x 6"  "six months" "2 x year" "2x yr." "60mo." : replace freq_value_txt="6" if strpos(lfreq_txt, "X") & freq_temp=="every _ months (specify)" 

for any "28 day" "28day" "14 day" 14d  "35 day" "5 day": replace freq_temp= "every _ days (specify)" if strpos(lfreq_txt, "X") & freq_temp=="" 

replace freq_temp="every _ weeks (specify)" if freq_temp=="" & (strpos(lfreq_txt, "week") | strpos(lfreq_txt, "wk") & strpos(lfreq_txt, "-") ) & freq_value_txt!="" 

replace freq_temp ="every _ months (specify)" if freq_temp=="" & (strpos(lfreq_txt, "mo") & freq_value_txt!="" | lfreq_txt=="6m" )

replace freq_value_txt="" if lfreq_txt=="dosed 10/28/2008" |  lfreq_txt=="2 doses when needed" 


for any "once" : replace freq_value_txt="1" if strpos(lfreq_txt, "X")& freq_value_txt==""
for any "twice" "every 2 week" : replace freq_value_txt="2" if strpos(lfreq_txt, "X")& freq_value_txt==""
for any "every 4 week": replace freq_value_txt="4" if strpos(lfreq_txt, "X") & freq_value_txt==""

for any  "0 & 2 weeks" "at 0 and 2 weeks as directed" "week 0 and week 2": replace freq_value_txt="" if lfreq_txt=="X" 


for any "2 times every 6 weeks" "x2q6wk" "2 weeks apart, then 6 mo" "day 1 and day 15, the q 6 months" "six months" "0 & 2 weeks with 6 month repeat" "2 doeses per six months" "0 & 2 weeks at 6 month cycle"  "2 infuaions q 6months or longer" 	"2 q 6 months"	"2 times every 6 months":   replace freq_value_txt="6" if lfreq_txt=="X" & freq_value_txt!="6"
				

for any "wekk 0 & 2 then q 4-6 weeks" "day 1&15 q 4-6mos" : replace freq_value_txt="6" if lfreq_txt=="X" & freq_value_txt!="6"
for any "wk0, 2, q4months"  : replace freq_value_txt="4" if lfreq_txt=="X"  & freq_value_txt!="4"

for any "x 2 doses q" "x2 doses q" "x2 dose" "q6x2 dosee" "x2 dosese q 6 m" : replace freq_value_txt="6" if strpos(lfreq_txt, "X") & strpos(lfreq_txt, "6") & strpos(lfreq_txt, "-")==0 

replace freq_value_txt="6" if freq_value_txt!="6" & (strpos(lfreq_txt, "q 6 months") | strpos(lfreq_txt, "q 6 mo") | strpos(lfreq_txt, "q6mo") ) 
replace freq_value_txt="6" if freq_value_txt!="6" & strpos(freq_value_txt, "-")==0 & strpos(lfreq_txt, "6") & strpos(lfreq_txt, "mo") & strpos(freq_temp, "specify") & strpos(lfreq_txt, "q3wk")==0 

replace freq_value_txt="6" if lfreq_txt=="x2doses q 46 mo" & freq_value_txt!="6"

replace freq_value_txt="8" if freq_value_txt=="82"  & freq_value_txt!="8"
replace freq_value_txt="6" if freq_value_txt=="6-2"  & freq_value_txt!="6"
replace freq_value_txt="6" if (lfreq_txt=="2 x year" |lfreq_txt=="2x yr.")  & freq_value_txt!="6"

for any "2 doses q 4 mo" 2xq4m "x2doses q4months" "wk0,2,q4 months" : replace freq_value_txt="4" if lfreq_txt=="X" & freq_value_txt!="4"

replace freq_value_txt="6" if (lfreq_txt=="96 weeks" | lfreq_txt=="wkly - q 6 wks")& freq_value_txt!="6"
replace freq_value_txt="8" if lfreq_txt=="q80wks" & freq_value_txt!="8"

for any "0 & 2 weeks" "at 0 and 2 weeks as directed"  "week 0 and week 2" "/week": replace freq_temp="" if lfreq_txt=="X" 


* Lin & Rich's comments 
for any biweekly "q other week": replace freq_temp="every 2 weeks" if lfreq_txt=="X" & drugkey=="cimzia"
replace freq_temp="once daily" if lfreq_txt=="q morning" 
for any "2 wkly" "2 x week" "2/wk" "be weekly" "bi weekly" "bi-weekly" "bi-wkly" biweekl biweekly "q other week" "q other weeks" "q other wk": replace freq_temp="every 2 weeks" if lfreq_txt=="X" & drugkey=="humira"
for any "q 24 weeks" "q 24 wks": replace freq_temp="every _ months (specify)" if lfreq_txt=="X" 
for any "q 24 weeks" "q 24 wks": replace freq_value_txt="6" if lfreq_txt=="X" & freq_temp=="every _ months (specify)" & freq_value_txt!="6"
for any q24h q24hrs: replace freq_temp="once daily" if lfreq_txt=="X" 
for any q24h q24hrs: replace freq_value_txt="1" if lfreq_txt=="X" & freq_value_txt!="1"


for any "+ w/u weekly" "-: week" "? wkly":  replace freq_temp="once per week" if lfreq_txt=="X" & drugkey=="enbrel" 
for any pow "w weeks": replace freq_temp="every 2 weeks" if lfreq_txt=="X" & drugkey=="humira"  
for any "?d" po "q1" od: replace freq_temp="once daily" if lfreq_txt=="X" &  freq_temp=="" 
replace freq_temp="twice per day" if lfreq_txt=="bod" & drugkey=="xeljanz" 
replace freq_temp="once per week" if lfreq_txt=="/week" & drugkey=="mtx" 

for any "q ? wk" "q  wks" "w weeks": replace freq_temp="every _ weeks (specify)" if lfreq_txt=="X" & freq_temp=="" 

replace freq_temp="twice per daily" if lfreq_txt=="poqod" 

for any "q 8 o" "q6-8 hours" "qhs" "q hs": replace freq_temp="every _ hours" if lfreq_txt=="X" 
for any "q d?" pm "a.m.": replace freq_temp="once daily" if lfreq_txt=="X" 


*********************************

for any "1 daily" "nightly": replace freq_temp="once daily" if lfreq_txt=="X"  
replace freq_temp="twice per day" if lfreq_txt=="1 bid" 
replace freq_temp= "every _ months (specify)" if lfreq_txt=="every year" 
replace freq_value_txt= "12" if lfreq_txt=="every year"  & freq_value_txt!="12"


*tab lfreq_txt if freq_temp==""
tab freq_temp // make it consistent with freq_unit_code
codebook freq_unit_code
/*
               freq_temp |      Freq.     Percent        Cum.
-------------------------+-----------------------------------
           every 2 weeks |      7,931       14.85       14.85==> 930
           every 4 weeks |     11,025       20.64       35.50==> 930
  every _ days (specify) |        346        0.65       36.14==> 920
 every _ month (specify) |      3,755        7.03       43.17==> 940 
every _ months (specify) |          4        0.01       43.18==> 940
  every _ week (specify) |      8,555       16.02       59.20==> 930
              once daily |      5,015        9.39       68.59==> 911
          once per month |      2,217        4.15       72.74==> 940
           once per week |     11,476       21.49       94.23==> 930
 times per day (specify) |         15        0.03       94.26==> 911
times per week (specify) |         29        0.05       94.32==> 921
           twice per day |      2,285        4.28       98.59==> 911
          twice per week |        751        1.41      100.00==> 921
-------------------------+-----------------------------------
                   Total |     53,404      100.00
*/

replace freq_unit_code=930 if freq_unit_code==. & (freq_temp=="every 2 weeks"|freq_temp=="every 4 weeks"|freq_temp=="every _ weeks (specify)"|freq_temp=="once per week")|freq_temp=="every _ week (specify)"
replace freq_value_txt="2" if freq_temp=="every 2 weeks" & freq_value_txt==""
replace freq_value_txt="4" if freq_temp=="every 4 weeks" & freq_value_txt==""
replace freq_value_txt="1" if freq_temp=="once per week" & freq_value_txt==""

replace freq_unit_code=920 if freq_unit_code==. & freq_temp=="every _ days (specify)"

replace freq_unit_code=940 if freq_unit_code==. & (freq_temp=="every _ month (specify)"|freq_temp=="every _ months (specify)"|freq_temp=="once per month")
replace freq_value_txt="1" if freq_temp=="once per month" & freq_value_txt==""

replace freq_unit_code=911 if freq_unit_code==. & (freq_temp=="once daily"|freq_temp=="times per day (specify)"|freq_temp=="twice per day")
replace freq_value_txt="1" if freq_temp=="once daily" & freq_value_txt==""
replace freq_value_txt="2" if freq_temp=="twice per day" & freq_value_txt==""

replace freq_unit_code=921 if freq_unit_code==. & (freq_temp=="times per week (specify)"|freq_temp=="twice per week")
replace freq_value_txt="2" if freq_temp=="twice per week" & freq_value_txt==""

groups freq_value_txt freq_unit_code if freq_temp!="", missing ab(16)


forvalues i= 2(1)16{
	replace freq_value_txt="`i'" if strpos(freq_value_txt, "-`i'")
}

groups freq_value_txt if strpos(freq_value_txt, "-")
/*
  +-------------------------------------+
  | freq_v~t   Freq.   Percent      %<= |
  |-------------------------------------|
  |    02-01       2     15.38    15.38 |
  |    02-08       2     15.38    30.77 |
  |    06-18       2     15.38    46.15 |
  |    07-01       4     30.77    76.92 |
  |    12-01       2     15.38    92.31 |
  |-------------------------------------|
  |    14-06       1      7.69   100.00 |
  +-------------------------------------+
*/

replace freq_value_txt="" if strpos(freq_value_txt, "-")

destring freq_value_txt, replace
destring freq_value, replace  
replace freq_value_txt=. if freq_value_txt==dose_value & dose_txt!="" & freq_txt=="" 


replace freq_value=freq_value_txt if freq_value==.

drop _* ldose_txt lfreq_txt dose_value_txt freq_value_txt

