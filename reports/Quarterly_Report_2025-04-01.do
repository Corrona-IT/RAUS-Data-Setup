/*********************************************************************************************************
Date: 1-7-15
Name: Ying Shan
Aim: Quarterly Registry Update Report
data use: corrona quarterly download-DWsub1
data out: none

do file: revised from rpt_10-15-15.do

1-5-16: 	George suggest restricted 6 month if vindaddX=2 & 
			interval >6 month for baseline table of initiator/switchers

			
1-15-18: 	{Wendi Malley} Modified to update PUTDOCX capabilities.			
			Make sure to install 
				ssc install catplot
			Added titles through out the code so it's easier to know where
			you are in the code. 
			
			You must also have the following in your directory: 
			raqtrly_coverpage.docx   (this is the cover page for the RA Qtrly report) 

2-20-18: 	{Wendi Malley} Added Log File tracking.			
			Added dynamic date setting at the beginning of the file 

1-15-19:	Lin added Olumiant			
4-22-19:	Ying separated the last 2 graphs into 2 horizontal pages
6-25-19:	Lin added higher resolution (1100*800 pixels)for the figures
7-22-19:	Lin changed table 1 row#5 from "Number of MDs" to "Number of Providers" 
10-25-19:	Lin modified based on Heather's comments using temp/rptdt__2_Oct_2019 data
12-11-19:	Add Rinvoq to bio list, maybe revise small molecule to JAKi?
8-13-2020:	Revise template based on comments: table2, remove exited; table 6-7, footnote "mean unless otherwise indicated"; figure 1, show 2015+
10-3-2020: adding inflectra_bs and renflexis_bs
10-12-2020: adding margins and footer options using STATA16
1-25-2021: Revise template by extending scales for all figures and modify footer by including Q# year# 
1-26-2021: Change order of xeljanz and kevzara so JAKs are together
4-2-2021: Changed coverpage and templates for re-branding and new requests.
4-5-2021: sites 118 & 142 were confirmed as active sites, re-run quarterly report to update Tables 1-3 and double check report automation 

==>updated on 7-2-21
4-30-21 DP comments: we do not need a 2nd decimal places for all tables. 

==>updated on 7-28-21
figure 5b : is % within each biologic looks like. can we indicate that in a footnot4e?-- rephrased in title

figure 5a : the same. can we indicate that in a footnote-- rephrased in title

tables 4 and 5 and throughout  : i would list first all TNFs then orencia rtx actemra kevzara then jaks then biosimilars 

table 6 and 7 : re-arranged footnotes, added "baseline is at the time of initiation or switch"

==> updated on 12-6-21~12-8-21 

revised footnotes and names of tables. 
trying automation for total number of tables 3-4, and QX YYYY through QX YYYY in parenthesis

run from line # 206 temp data 

==> 1-26-2022 comments for Q4 2021 report 
Figure 1a: 3 colors: TNF, non-TNF, JAKi 
Figure 1b: olumiant and rinvoq colors are very similar, try to make adjacent colors more different 

==> 6-22-2022 comments from Q1 2022 report 
1. add table 8a to include active patients only 
2. some other edits for footnotes. a. Table 6 *Baseline is at the time of initiation b.Table7 *Baseline is at the time of switch

==> 8-8-2022 comments from Q2 2022 report 
1. change all table footnotes to letters, a b c, etc...
2. delete "in the CorEvitas RA Registry" from table titles 
********************************************************************************************************/
/*
Notes after the RA data migration 
2024-04-25 
update all patient to subject in all RA reports 

2024-04-24
bug fixes for 2.1 and 2.3 data for hx_X 

2024-04-19
v20240401 datacut was updated by appending rows for start date reported prior to visitdate with current dose/freq 

2024-04-05
using the v20240401 datacut (to fix the missingness for bmi)

2024-04-04 
using the v20240331 datacut 
1. fitting initX and presX to wide format 
2. presX was generated using new rules==> 
	a. start/continue at FU visit 
	b. not stopped at the EN visitdate 

2024-08-19 LG working on the revision comments for Q3 2024 report 

DP: 1. re-order drug name by TNF, non-TNF, and JAKs ==> already did? does he mean moving biosimilars of remicade to TNF?
2. Figure 2 compare prior 4 quarters vs. last 4 quarters 
3. remove other disease activities tjc, sjc, pt global, md global in table 6,7 8, only keep pt pain and mHAQ
Rich: 
1. add race/ethnicity to tables 6-8a;

2024-08-21 LG try to run the whole code again after restart computer. color change for figures did not work previously.
*/

*****************************************************************
*					SETUP MONTHLY DATA 
*			data staging - MODIFY EACH MONTH
*	following program section NEEDs to be modify at each update			        
*****************************************************************
**** Set Source Files:  DWSUB1 & SITE STATUS
clear * 
*macro drop _all
*set more off 
cap log close

**** Set Directory
// Update each quarter 
cd "~\Corrona LLC\Biostat Data Files - RA\Quarterly Report\codes\2025-04-01"
// 2024-03-28 create wide format of init_X using 2.1 drugexpdetails data, add all wide init_X to 2.3_keyvisitvars data 

// 2024-08-19 using Aug 2024 data for testing 
global data "~\Corrona LLC\Biostat Data Files - RA\monthly\2025\2025-04-01"

global text "Q1 2025"
global fig2lbl "Change from the period Q4 2022 to Q3 2023 compared to the period Q4 2023 to Q3 2024" // need to update for Q3 2024. currently Q3 data is not complete, the Quarter will just count up to Q2 2024. Wording maybe change from 2022Q2-2023Q1 to 2023Q2-2024Q1? discuss.
global fig3lbl "Q4 2023 through Q3 2024"

log using ra_qr_2025-04-10.log,replace  //append

*********************************************************************************/
*		NO MODIFICATIONS NEEDED STARTING HERE TO THE END.... 
*				preparing data
*********************************************************************************/

use "$data\\2_1_drugexpdetails_$datacut.dta", clear 

// using temp test data after bug fixes 
*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\temp\LGtest_2024-08-12\2_1_drugexpdetails", clear 

// exlude the drug names that are not in the quarterly report 
# delimit;
global drug_init
"enbrel
humira
remicade
inflectra 
renflexis   
cimzia
orencia
rituxan
actemra 
kevzara 
olumiant 
rinvoq
"
;
# delimit cr;

# delimit;
global generic_init
"golimumab
tofacitinib
"
;
#delimit cr;


// prepare pres X and initX at visit level 
count if drug_key=="enbrel" & init_drug==1 // 5,257
count if drug_key=="enbrel" & init_drug==1 & drug_base_visit<. // 4,665 base_visit should be within 183 days of drug_init_date
tab visit_indexn if drug_key=="enbrel" & init_drug==1 & drug_base_visit==.,m 
// create wide initX, baseline visit for each drug name and init naive/switch



//enbrel 

foreach x in $drug_init{
    gen pres_`x'=0
    gen init`x'=0
	gen base_visit`x'=.
	replace base_visit`x'=drug_base_visit if drug_key=="`x'" & init_drug==1
	gen initnai`x'=1 if drug_key=="`x'" & init_drug==1 & nhx_b_ts_generic==0
	gen initswt`x'=1 if drug_key=="`x'" & init_drug==1 & nhx_b_ts_generic>0
replace pres_`x'=1 if drug_key=="`x'" & pres_drug==1
// 2024-10-08 adding btw add fixes 
replace pres_`x'=1 if drug_key=="`x'" & pres_drug==. & drug_indexN==1 & drug_status==3 & drug_plan==. & drug_status_raw=="stop" & visit_indexn>1

replace init`x'=1 if drug_key=="`x'" & init_drug==1
 
// make initX consistent for the same visitdate, same as pres_X 
foreach y in init pres_ base_visit initnai initswt{
egen max`y'`x'=max(`y'`x'), by(subject_number visitdate)
replace `y'`x'=max`y'`x' 
drop max`y'`x'
}
lab var init`x' "`x' initiated"
lab var pres_`x' "`x' prevalent use"
lab var base_visit`x' "baseline visit for `x' initiator"
format base_visit`x' %tdCCYY-NN-DD
lab var initnai`x' "`x' initiated naive"
lab var initswt`x' "`x' initiated switcher"
lab val init`x' ny
}

unique subject_number if initenbrel==1 
unique subject_number if initenbrel==1 & base_visitenbrel<.

foreach x in $generic_init {
    gen pres_`x'=0
    gen init`x'=0
	gen base_visit`x'=.
	replace base_visit`x'=generic_base_visit if generic_key=="`x'" & init_generic==1
	gen initnai`x'=1 if generic_key=="`x'" & init_generic==1 & nhx_b_ts_generic==0
	gen initswt`x'=1 if generic_key=="`x'" & init_generic==1 & nhx_b_ts_generic>0
replace pres_`x'=1 if generic_key=="`x'" & pres_generic==1	
// 2024-10-08 adding btw add fixes 
replace pres_`x'=1 if generic_key=="`x'" & pres_generic!=1 & generic_indexN==1 & generic_status==3 & drug_plan==. & drug_status_raw=="stop" & visit_indexn>1

replace init`x'=1 if generic_key=="`x'" & init_generic==1
// make initX consistent for the same visitdate, same as pres_X 
foreach y in init pres_ base_visit initnai initswt{
egen max`y'`x'=max(`y'`x'), by(subject_number visitdate)
replace `y'`x'=max`y'`x' 
drop max`y'`x'
} 
lab var init`x' "`x' initiated"
lab var pres_`x' "`x' prevalent use"
lab var base_visit`x' "baseline visit for `x' initiator"
format base_visit`x' %tdCCYY-NN-DD
lab var initnai`x' "`x' initiated naive"
lab var initswt`x' "`x' initiated switcher"
lab val init`x' ny
}

// keep pres and init related vars in wide format and deduplicate for visit level
keep subject_number visitdate prev_visit init* base_visit* pres_* 

drop init_drug init_generic pres_drug pres_generic 

unique subject_number visitdate 
unique *

duplicates drop 
unique subject_number visitdate 

unique subject_number if pres_enbrel==1 

count if initenbrel==1 
count if initenbrel==1 & base_visitenbrel<.
count if initnaienbrel==1
count if initswtenbrel==1

// rename to be consistent with Q4 2023 names 
cap drop *simponi* *xeljanz*
rename *golimumab* *simponi*
rename *tofacitinib* *xeljanz*
unique subject_number if pres_simponi==1
unique subject_number if pres_xeljanz==1
save drug_temp, replace

use "$data\\2_1_drugexpdetails_$datacut", clear 
 
*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\temp\LGtest_2024-08-12\2_1_drugexpdetails", clear 

// create cost-insurance category from "other"
groups reason_1 reason_1_category, missing ab(16) sepby(reason_1_category)
groups reason_2 reason_2_category, missing ab(16) sepby(reason_2_category)

foreach x in drug generic{
// cost
gen `x'_disc_rsn_cost=1 if `x'_stop==1 & reason_1_category=="other" & (strpos(reason_1,"cost")|strpos(reason_1, "insurance"))
replace `x'_disc_rsn_cost=1 if `x'_stop==1 & reason_2_category=="other" & (strpos(reason_2,"cost")|strpos(reason_2, "insurance"))
replace `x'_disc_rsn_cost=1 if `x'_stop==1 & reason_3_category=="other" & (strpos(reason_3,"cost")|strpos(reason_3, "insurance"))
// other
gen `x'_disc_rsn_oth=1 if `x'_stop==1 & reason_1_category=="other" & (strpos(reason_1,"cost")==0 & strpos(reason_1, "insurance")==0)
replace `x'_disc_rsn_oth=1 if `x'_stop==1 & reason_2_category=="other" & (strpos(reason_2,"cost")==0 & strpos(reason_2, "insurance")==0)
replace `x'_disc_rsn_oth=1 if `x'_stop==1 & reason_3_category=="other" & (strpos(reason_3,"cost")==0 & strpos(reason_3, "insurance")==0)
// efficacy
gen `x'_disc_rsn_eff=1 if `x'_stop==1 & (reason_1_category=="effectiveness"|reason_2_category=="effectiveness"|reason_2_category=="effectiveness")
// safety 
gen `x'_disc_rsn_safe=1 if `x'_stop==1 & (reason_1_category=="safety"|reason_2_category=="safety"|reason_2_category=="safety")
}
// check results and make individual vars by drug, then consistent within visit date 
groups drug_disc_rsn_cost drug_stop reason_1 reason_2 reason_3, missing ab(16)

keep if drug_stop==1|generic_stop==1

unique subject_number visitdate  // not unique 

foreach x in $drug_init{
foreach y in eff safe cost oth{
gen `x'_disc_`y'=1 if drug_key=="`x'" & drug_disc_rsn_`y'==1 
// make consistent for the same visitdate, same as pres_X 
egen max`x'_disc_`y'=max(`x'_disc_`y'), by(subject_number visitdate)
replace `x'_disc_`y'=max`x'_disc_`y' 
drop max`x'_disc_`y'
}
}

foreach x in $generic_init{
foreach y in eff safe cost oth{
gen `x'_disc_`y'=1 if generic_key=="`x'" & generic_disc_rsn_`y'==1 
// make consistent for the same visitdate, same as pres_X 
egen max`x'_disc_`y'=max(`x'_disc_`y'), by(subject_number visitdate)
replace `x'_disc_`y'=max`x'_disc_`y' 
drop max`x'_disc_`y'
}
}

keep subject_number visitdate *_disc_*

drop drug_* generic_*

duplicates drop 

unique subject_number visitdate 

rename *golimumab* *simponi*
rename *tofacitinib* *xeljanz*

save rsn_disc_temp, replace 


//
/* 
br subject_number visitdate visit_indexn drug_key drug_base_visit init_drug drug_indexn if drug_key=="enbrel" & init_drug==1 & drug_base_visit==. & visit_indexn>1

for any 000000048: br subject_number visitdate visit_indexn prev_visit drug_key drug_base_visit init_drug drug_indexn if drug_key=="enbrel" & subject_number=="X"
*/
// use the value at the (linked) visitdate for  age gender bmi insurance_private insurance_medicare insurance_medicaid insurance_none duration_ra numbio nbdmards rfposever ccpposever erosdisever; 
// use the value at the baseline visit for cdai tender_jts_28 swollen_jts_28 md_global_assess pt_global_assess pt_pain di cdaigrp cdaisub1 cdaisub2 cdaisub3 cdaisub4

// use the value at the base_visit for 
// 2024-04-01 Ying updated keyvisitvars by dropping the 2 extra subjects and changed insurance_none to 0/1. 
// 2024-04-04 all bmi were missing in the keyvisitvars data. emailed Ying for update 

use "$data\\2_3_keyvisitvars_$datacut", clear

*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\2_3_keyvisitvars.dta", clear 

mdesc site_number state 

/*tab subject_number if site_number==.

  Subject ID |      Freq.     Percent        Cum.
-------------+-----------------------------------
   101011542 |          1       50.00       50.00
   174220034 |          1       50.00      100.00
-------------+-----------------------------------
       Total |          2      100.00
. use "~\Corrona LLC\Biostat Data Files - RA\monthly\2023\2023-12-31\dwsub1", clear

. list optional_id visitdate indexn indexN site_id if inlist(subject_number, "101011542", "174220034"), noobs ab(16)

  +-----------------------------------------------------+
  | optional_id   visitdate   indexn   indexN   site_id |
  |-----------------------------------------------------|
  |   101011542   27nov2023        1        1       101 |
  |   174220034   10apr2013        1        1       174 |
  +-----------------------------------------------------+


replace state="TN" if subject_number=="101011542"
replace state="SC" if subject_number=="174220034"
*/

local date: display %td_DD_NN_CCYY date(c(current_date), "DMY")
display "`date'"
local date_string = subinstr(trim("`date'"), " " , "", .)
display  "`date_string'"
local date_c = date("`date_string'","DMY")
display %td "`date_c'"

local lastqtr=qofd(`date_c')-1
display "`lastqtr'"
local lastrptday=dofq(qofd(`date_c'))-1
display "`lastrptday'"
local rptdate: display %tdMonth_dd,_CCYY dofq(qofd(`date_c'))-1
display "`rptdate'"
// LG add rptdate2 
local rptdate2: display %tdMonth_dd,_CCYY dofq(qofd(`date_c')-2)-1
display "`rptdate2'"

**For setting dates through out the report
**Last 6months
di %td (dofq(qofd(`date_c')-2))
global yr6mth (dofq(qofd(`date_c')-2))
**Last Year 	
di %td (dofq(qofd(`date_c')-6)) 
global yrlast (dofq(qofd(`date_c')-6)) 

// 2024-08-20 add last 2 years 
global yrlast2 (dofq(qofd(`date_c')-10)) 
*quarter indicator, first year of the quarter
// 8-13-2020 changed to minus 6 to exclude 2014 and avoid crowding
di %ty (year(`lastrptday')-6)
global qtryr (year(`lastrptday')-6)
display $qtryr
**Last 12months
di %td (dofq(qofd(`date_c')-4))
global yrind12m (dofq(qofd(`date_c')-4))

// 2024-08-20 last 30 month for figure 2 modification: data using current date minus 6 month, comparing last 7-18 month withlast 19 month-last 30 month  
global yrind30m (dofq(qofd(`date_c')-10)) // current date minus 10 quarters (30 months)

**Title of the report
	di "`rptdate'"
	scalar datepost = "`rptdate'" 
	di "`rptdate2'"
	scalar datepost2 = strltrim("`rptdate2'") 

gen last6m=1 if visitdate>=$yr6mth 

codebook visitdate if last6m==1 // [02jan2024,31jul2024]

* indicators of last year, quarter, half year, last 2 quarters 
gen lastyr=1 if visitdate>=$yrlast & last6m!=1 

codebook visitdate if lastyr==1 // [01jan2023,29dec2023]
// last 2 years 
gen lastyr2=1 if visitdate>=$yrlast2 & last6m!=1 

codebook visitdate if lastyr2==1 // [03jan2022,29dec2023] 

*quarter indicator 
gen timeqrt=qofd(visitdate) if year(visitdate)>$qtryr & last6m!=1 
format timeqrt %tq  

tab timeqrt 
codebook visitdate if timeqrt==.

* semi year indicator without last half year because data enter delay 
gen timehy=hofd(visitdate)  if year(visitdate)>$qtryr & last6m!=1   
format timehy %th 

tab timehy

codebook visitdate if timehy==.

gen timeyr=yofd(visitdate)  if year(visitdate)>$qtryr & last6m!=1   
format timeyr %ty 

tab timeyr 

codebook visitdate if timeyr==.

****************************
**text versions!!
****************************
*quarter indicator 

gen timeqrtQ=quarter(visitdate) if year(visitdate)>$qtryr & last6m!=1 

*** Create String Variables for time/date stamps for charts
gen str2 timeqrt_c= "q" + string(timeqrtQ)
replace timeqrt_c="" if missing(timeqrtQ)
* semi year indicator without last half year because data enter delay 
gen timehy_c=string(timeqrt, "%th") // 2024-08-20 not used and ranged from 2078h1 to 2087h2
gen timeyr_c=string(timeyr, "%ty")
gen timeqrt_c2 = (timeyr_c + timeqrt_c)

* last 2 quarter indicator without last 6 month
/*	
4-13-18 Lin: add Kevzara to report 
12-11-19 added Rinvoq to report, change hxanybio_sm to hxanybio_JAK, added ccpposever
10-3-20 added inflectra and renflexis to report	
*/
gen last2qrt=1 if visitdate>=$yrind12m & last6m!=1

codebook visitdate if last2qrt==1 // [01jul2023,29dec2023]

// 2024-08-20 generate indicator of last 2 years for figure 2 comparing current-6 of 4 quarters comparing with the 4 quarters before.
gen last2yr=1 if visitdate>=$yrind30m & last6m!=1

// testing result 
codebook visitdate if last2yr==1 // [03jan2022,29dec2023]

//md_cod  hxoth_dmard hxtnf hxanybio hxanybio_JAK
// LG from 06_temp code 
sort subject_number visitdate
by subject_number: gen intervalyr=(visitdate-visitdate[_n-1])/365.25 if _n>1 
lab var intervalyr "Interval between visits(yr)" 
sum intervalyr
gen lastencounter=1 if indexn==indexN 
lab var lastencounter "Last visit" 

// 2024-08-21 LG adding race and ethnicity to QRR 

gen ethnicity=race_hisp_cat5==5
replace ethnicity=. if race_hisp_cat5==.

gen race=race_hisp_cat5
replace race=. if race_hisp_cat5==.|race_hisp_cat5==5

groups race ethnicity race_hisp_cat5, missing ab(16)

keep source site_number state subject_number visitdate full_version indexn site_number md_id intervalyr last2qrt lastencounter last6m last2qrt active_pt female_male age bmi insurance_* cdai erosdisever duration_ra rfposever ccpposever tender_jts_28 swollen_jts_28 *_global_assess pt_pain di hx_arava hx_azulfidine hx_imuran hx_mtx hx_plaquenil hx_cyclosporine hx_minocin  hx_invest lastyr lastyr2 timehy timeqrt timeyr timeqrt_c timeqrt_c2 timehy_c timeyr_c  *remicade* *enbrel* *golimumab* *orencia* *rituxan* *humira* *tofacitinib*  *kevzara* *olumiant* *rinvoq* *inflectra* *renflexis* *kineret* *actemra* *cimzia* race ethnicity

rename *golimumab* *simponi*
rename *tofacitinib* *xeljanz*

save visit_temp, replace


*****************************************************************
*					Generate tables 1-3 
*****************************************************************

use visit_temp, clear 
// 2024-04-01 changed all id to subject_number
sort subject_number visitdate
by subject_number: gen last=1 if _n==_N 

gen follow=indexn>1 if last==1 

by site_number, sort: gen site=1 if _n==1 & site_number<. 
by md_id, sort: gen md=1 if _n==1 & md_id!=""  
by state, sort: gen staten=1 if _n==1 & state!=""

* table 1. overview of Registry 
matrix t1=J(5, 1, 0)
matrix colnames t1=Frequency 
matrix rownames t1="Number of Registry Study Visits" "Number of Subjects" "Number of Sites" "Number of Providers" "Number of States" 

count 
matrix t1[1, 1]=r(N) 
gen visits=1

count if indexn==1 
matrix t1[2, 1]=r(N) 
gen subjects=1 if indexn==1 

count if site==1 
matrix t1[3, 1]=r(N) 
gen sites=1 if site==1 

count if md==1 
matrix t1[4, 1]=r(N) 
gen docs=1 if md==1 

count if staten==1 
matrix t1[5, 1]=r(N)
gen states=1 if staten==1 

matrix list t1, title(table 1. Overview of Registry) format(%5.0fc)


* table 2. RA Patients by Active Status
// change var name from activept to active_pt
matrix t2=J(2,3,0) 
matrix colnames t2="Total" "Active Subjects" "%" 
matrix rownames t2=Subjects Visits 

local row 1
count if indexn==1 
matrix t2[`row',1]=r(N) 
qui sum active_pt if last==1 
matrix t2[`row',2]=r(sum)
matrix t2[`row',3]=r(mean)*100 
/*
matrix t2[`row',3]=r(N)-r(sum)
matrix t2[`row',4]=100-r(mean)*100 
*/
local ++row
count 
matrix t2[`row',1]=r(N) 
qui sum active_pt 
matrix t2[`row',2]=r(sum)
matrix t2[`row',3]=r(mean)*100 
/*
matrix t2[`row',3]=r(N)-r(sum)
matrix t2[`row',4]=100-r(mean)*100 
*/
matrix list t2 , title(Table 2. Subjects by Active Status) f(%6.1fc) 

*table 3. patient year of fu in total/active patients 
// change from id to subject_number, activept to active_pt
// 2024-08-27, add number of subjects with at least one FU to Table 3 
sort subject_number visitdate 
by subject_number: gen fuyr=sum(intervalyr) 
by subject_number: replace fuyr=. if follow!=1 
gen fuyr_act=fuyr if active_pt==1 

// 2023-01-18 did not update the calculation of intervalyr for the patient below. Need to modify starting from dw data in next setup.
// 2023-04-03 data already fixed in EDC ,no need to add if optional_id!=2051367 
tabstat fuyr fuyr_act , s(n sum mean sd med min max) c(s) save  
matrix t3=r(StatTotal)'
matrix colnames t3= "Number of Subjects" "Total Years" "Mean" "SD" "Median" "Min" "Max"
matrix rownames t3= "Total" "Active subjects"
matrix list t3, title(Table 3. Length of Follow-up (years) in RA Subjects) f(%10.2fc)


*****************************************************************
*					Generate table 4-5 
*						   Data
*****************************************************************
// 7-8-21 changed order to TNF, non-TNF and JAK 
********************************************
*tab 4-5. initiator/prevalent users in corrona
// 10-3-2020 adding inflectra_bs renflexis_bs
// 2024-04-01 add drug_temp data for initiators and pres_X at the visit level 

merge 1:1 subject_number visitdate using drug_temp 

/*
v2024-08-21

    Result                           # of obs.
    -----------------------------------------
    not matched                        21,991
        from master                    21,991  (_merge==1)
        from using                          0  (_merge==2)

    matched                           478,383  (_merge==3)
    -----------------------------------------

    Result                           # of obs.
    -----------------------------------------
    not matched                        55,301
        from master                    55,301  (_merge==1)
        from using                          0  (_merge==2)

    matched                           439,762  (_merge==3)
    -----------------------------------------
*/

sort subject_number visitdate
cap drop numbio
gen numbio=0 
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
qui replace numbio=numbio+1 if hx_`x'==1
} 
lab var numbio "# prior b/tsDMARDs"
drop _m 

// 10-3-2020 adding inflectra_bs renflexis_bs
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
    /*
cap drop init`x'nai init`x'swt
* biologic naive/switch 
gen init`x'nai=1 if init`x'==1 & numbio==0 
gen init`x'swt=1 if init`x'==1 & init`x'nai!=1 
*/
by subject_number: gen nst`x'=sum(init`x') 
replace nst`x'=1 if nst`x'>1 & nst`x'<. 
replace nst`x'=.  if last!=1 


*prevalent use 
*gen pres`x'=1 if (pres_`x'==1 | disc`x'==-1 & indexn>1 | add`x'==1 )
by subject_number: gen puse`x'=sum(pres_`x')
replace puse`x'=1 if puse`x'>1 & puse`x'<. 
replace puse`x'=. if last!=1
} 

* mrtab nst*
* mrtab puse*
* browse id visitdate indexn numbio initenbrel initenbrelnai initenbrelswt nstenbrel pres_enbrel discenbrel addenbrel presenbrel puseenbrel
* baseline characteristics 

// 2024-03-28 oth_dmard is not available anymore 

local dmard "arava azulfidine imuran mtx plaquenil cyclosporine minocin"
gen nbdmards=0 
foreach x of local dmard{ 
replace nbdmards=nbdmards+1 if hx_`x'==1 
	} 

// 2024-03-28 cdai_cat4 can be used directly 

egen cdaigrp=cut(cdai), at(0, 2.8001, 10.001, 22.001, 100) icode 
tab cdaigrp, gen(cdaisub) 

// 2024-08-21 generate race group 
tab race, gen(race_sub)
groups race race_sub1 race_sub2 race_sub3 race_sub4, missing ab(16)

****************************************************************
sort subject_number visitdate 

* 1-5-17 revised baseline disease activity and PROs as missing if vindaddX=2 & interval from start >6m 
* total biologic initiation in naive/switch 
gen visitym=mofd(visitdate)
by subject_number: gen prvisitym=visitym[_n-1] 

qui foreach x in nai swt{ 
cap drop init`x'bio
egen init`x'bio=rsum(init`x'*)
replace init`x'bio=. if init`x'bio==0
} 
* cap drop initbio
gen initbio=1 if initnaibio==1|initswtbio==1 
// 2024-04-01 also create row max for base_visitbio for the baseline 
egen base_visitbio=rmax(base_visit*)
format base_visitbio %tdCCYY-NN-DD
 
/*
cap drop vindaddbio 
gen vindaddbio=. 
// 10-3-2020 adding inflectra_bs renflexis_bs
qui foreach x in enbrel humira remicade cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq inflectra_bs renflexis_bs{
replace vindaddbio=1 if init`x'==1 & vindadd`x'==1 & vindaddbio==. 
by id: replace vindaddbio=2 if init`x'==1 & vindadd`x'==2 
} 
clonevar bio_adddt=enbrel_adddt 
replace bio_adddt=. if initenbrel!=1 | initbio==. 
// 10-3-2020 adding inflectra_bs renflexis_bs
qui foreach x in enbrel humira remicade cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq inflectra_bs renflexis_bs{
replace bio_adddt=`x'_adddt if initbio==1 & init`x'==1 & `x'_adddt<bio_adddt 
} 
*/
// 10-3-2020 adding inflectra_bs renflexis_bs
// 2024-03-28 use base_visit to link with keyvisitvars data for baseline values
// add ccpposever

// 2024-08-21 adding race ethnicity and remove tjc, sjc, pt global, md global in table 6,7 8, only keep pt pain and mHAQ
// tender_jts_28 swollen_jts_28 md_global_assess pt_global_assess cdaigrp 

local list "age female_male race_sub1 race_sub2 race_sub3 race_sub4 ethnicity bmi insurance_private insurance_medicare insurance_medicaid insurance_none duration_ra numbio nbdmards rfposever ccpposever erosdisever cdai pt_pain di cdaisub1 cdaisub2 cdaisub3 cdaisub4" 

foreach y in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq  bio{
   
foreach x of local list{ 
cap drop `y'b`x' 
gen `y'b`x'=`x' if init`y'==1 & base_visit`y'==visitdate
by subject_number: replace `y'b`x'=`x'[_n-1] if init`y'==1 & base_visit`y'<. & base_visit`y'==prev_visit
} 


foreach x in age female_male race_sub1 race_sub2 race_sub3 race_sub4 ethnicity bmi insurance_private insurance_medicare insurance_medicaid insurance_none duration_ra numbio nbdmards rfposever ccpposever erosdisever{
replace `y'b`x'=`x' if init`y'==1 & `y'b`x'==. & base_visit`y'!=visitdate
} 
} 

merge 1:1 subject_number visitdate using rsn_disc_temp
drop _m 
save qrr_temp, replace

*****************************************************************
*					Insert Summary & Table: 
*		Overall Summary & Tables 1, 2, & 3 into Word Report
*				PUTDOCX COMMANDS
*****************************************************************
use qrr_temp, clear 

putdocx clear
putdocx begin ,  footer(npage)
putdocx paragraph, tofooter(npage) halign(center) font(calibri) spacing(before,0) spacing(after,0) 		
// 4-2-2021 changed to calibri 
putdocx text ("$text CorEvitas")
*putdocx text ("SM") , script(super)
putdocx text (" RA Registry Quarterly Report"),linebreak 							// 4-2-2021 update every quarter  
putdocx text ("Copyright © 2025 CorEvitas, LLC. All Rights Reserved."),linebreak	// changed text for re-branding
putdocx text ("For use consistent with the CorEvitas RA Registry Publication Policies."), linebreak		// changed text for re-branding
putdocx paragraph, tofooter(npage) halign(right) font(calibri) spacing(before, 0) spacing(after,0) // putdocx paragraph will leave one empty line before the last putdocx paragraph, so there is one line between the footer and the page numbers 
putdocx pagenumber																	// 4-2-2021 changed to below the footer text 

putdocx paragraph, style(Heading2)  halign(center)					// need to check how to automatically change the headings to orange(heading2) and gold (heading3)
putdocx text ("Overview of the CorEvitas RA Registry"), bold font("Calibri Light", "13", darkorange) 
// 2024-08-22 specified the font for Heading2, because word is not using Calibri Light anymore.
// 1-25-2021 added RA
local sum : display %16s datepost
local sum2 :display %16s datepost2
putdocx paragraph, halign(center)
putdocx text ("Tables 1-8: Data through "+ strltrim("`sum'")), font("Calibri", "11") // 1-27-2020 trying to avoid extra spaces 
putdocx paragraph, halign(center)
putdocx text ("All figures: Data through "+ strltrim("`sum2'")), font("Calibri", "11") 
putdocx paragraph, halign(center)
putdocx text ("This report is based on the CorEvitas RA Registry"), font("Calibri", "11")  // 4-2-21 changed 
putdocx paragraph
putdocx text (" ")
putdocx paragraph, style(Heading2)  halign(center)
putdocx text ("Table 1. Overview of the CorEvitas RA Registry"), bold font("Calibri Light", "13", darkorange)
**insert table 1
putdocx table table1 = matrix(t1), width(4in) nformat(%15.0fc) rownames colnames halign(center) layout(autofitcontents)
putdocx table table1(.,2), halign(right)
putdocx table table1(1,2), bold
putdocx table table1(.,.), font("Calibri", "11")

putdocx paragraph
putdocx text (" ")
putdocx paragraph, style(Heading2)  halign(center)
putdocx text ("Table 2. Subjects by Active Status"), bold font("Calibri Light", "13", darkorange) // 2022-08-08 deleted "in the CorEvitas RA Registry"
**insert table 2
putdocx table table2 = matrix(t2), width(4in) rownames colnames halign(center) layout(autofitcontents) 
putdocx table table2(1/3,.), halign(center) 
putdocx table table2(1,2/4), bold 
putdocx table table2(2/3,2), nformat(%15.0fc) 
putdocx table table2(2/3,3), nformat(%15.0fc) 
putdocx table table2(2/3,4), nformat(%15.1fc) // 7-2-21 keep 1 decimal throughout
putdocx table table2(1,3) = (" a, b") , script(super) append
putdocx table table2(.,.), font("Calibri", "11")

putdocx paragraph, font(Calibri,9)
putdocx text ("a"), script(super) // 2022-08-08 change all table footnotes to letters 
putdocx text (" Active subjects: subjects followed in the registry who have not exited, are participating at an active site, and whose most recent visit was ≤ 18 months ago.")
putdocx paragraph, font(Calibri,9)
putdocx text ("b"), script(super) // 2022-08-08 change all table footnotes to letters 
putdocx text (" Inactive / Exited subjects: subjects followed in the registry who have exited, are participating at an inactive site, or whose most recent visit was > 18 months ago.")
putdocx paragraph
putdocx text (" ")
putdocx paragraph, style(Heading2)  halign(center)
putdocx text ("Table 3. Length of Subject Follow-Up (years) Among Subjects"), bold font("Calibri Light", "13", darkorange) linebreak
putdocx text ("with at Least One Follow-Up Registry Visit"), bold font("Calibri Light", "13", darkorange) // in the CorEvitas RA Registry
**insert table 3
// 2024-08-27 adding 1 more column
putdocx table table3 = matrix(t3), width(5.5in) rownames colnames halign(center) layout(autofitcontents) 	// 7-2-21 changed to 1 decimal place 
putdocx table table3(1/3,2/8), halign(center) 
putdocx table table3(1,2/8), bold 
putdocx table table3(.,.), font("Calibri", "11") 
putdocx table table3(2/3,3/8), nformat(%15.1fc)
putdocx table table3(2/3,2), nformat(%15.0fc)
*putdocx paragraph
*putdocx text (" ")

// to check results: 
*putdocx save Tables1-3_2024-08-27.docx, replace 

*****************************************************************
*					Insert Summary & Table: 
*				Tables 4 & 5 into Word Report
*					PUTDOCX COMMANDS
*****************************************************************
*putdocx begin, margin(top,0.4) margin(bottom,0.4)
putdocx sectionbreak, margin(top,0.4) margin(bottom,0.4)

**insert table 4

* table 4  biologic initiator 
mrtab nst* 
matrix t4=r(responses) \ r(N)
mat list t4
matrix t4t = t4'
preserve
clear
/* put the matrix into the dataset */
svmat t4t, names(col) 
/* swap frequency back into column */
xpose, varname clear

rename _varname Drug
replace Drug = proper(subinstr(Drug,"nst","",.))
tab Drug
**replace Drug = subinstr(Drug,"_"," ",.)			// only if you have underscores
replace Drug = "Total # of Subjects" if Drug=="R15" 	//change to R16, to add inflectra_bs and renflexis_bs		changed to 15 by excluding kineret

*** you only need this step if you want the total first
/* 4-13-18 Lin --Trying to re-order the rows for tables 4-5	
7-28-21 updated the order of drug list 
enbrel humira remicade cimzia simponi orencia rituxan actemra kevzara kineret xeljanz olumiant rinvoq inflectra_bs renflexis_bs
*/ 
// 1-26-21 switch xeljanz and kevzara 	
// 2024-08-21 move inflectra and renflexis after remicade 
label def drugE 0 "Total # of Subjects" 1 "Enbrel" 2 "Humira" 3 "Remicade" 4 "Inflectra" 5 "Renflexis" 6 "Cimzia" 7 "Simponi" 8 "Orencia" 9 "Rituxan" 10 "Actemra" 11 "Kevzara" 12 "Xeljanz" 13 "Olumiant" 14 "Rinvoq" , modify
* encode Drug, gen(DrugE)	
generate byte drugE= 0 if Drug == "Total # of Subjects"
replace drugE=1 if Drug=="Enbrel"
replace drugE=2 if Drug=="Humira" 
replace drugE=3 if Drug=="Remicade" 
replace drugE=4 if Drug=="Inflectra"
replace drugE=5 if Drug=="Renflexis"
replace drugE=6 if Drug=="Cimzia" 
replace drugE=7 if Drug=="Simponi" 
replace drugE=8 if Drug=="Orencia" 
replace drugE=9 if Drug=="Rituxan" 
replace drugE=10 if Drug=="Actemra" 
replace drugE=11 if Drug=="Kevzara" 
replace drugE=12 if Drug=="Xeljanz"
replace drugE=13 if Drug=="Olumiant"
replace drugE=14 if Drug=="Rinvoq"


label values drugE drugE
sort drugE


putdocx paragraph, style(Heading2) halign(center)
putdocx text ("Table 4. b/tsDMARD Initiations at or after Enrollment "), bold font("Calibri Light", "13", darkorange) // in the CorEvitas RA Registry
putdocx text ("a"), linebreak bold font("Calibri Light", "13", darkorange) script(super) // 2022-08-08 changed to superscript a
putdocx text ("(initiations prior to enrollment are not counted)"), bold font("Calibri Light", "13", darkorange)
putdocx table t4 = data(drugE v1), width(4in) border(all,single) halign(center) 
	local rows = rowsof(t4)
putdocx table t4(2/`rows',.), nformat(%15.0fc) 
putdocx table t4(1,.), addrows(1, before)
putdocx table t4(1,2) = ("Initiators") 
putdocx table t4(.,2), halign(right)
putdocx table t4(2,2), nformat(%15.0fc) 
putdocx table t4(1/2,.), bold
putdocx table t4(.,.), font(Calibri,10.5) valign(center)

putdocx paragraph, font(Calibri,8.5) // 12-6-21 changed to be consistent throughout the report 
putdocx text ("a"),	script(super)
putdocx text (" This table reflects the number of subjects with drug initiation while observed in the CorEvitas RA registry, counting the number of subjects who initiated the drug at or at any point after enrollment. An initiation is counted only the first time the medication is started – restarts are not counted. Both active and inactive subjects are included. Subjects may be counted more than once if they initiated multiple b/tsDMARDs.")	

restore


* table 5  biologic user

mrtab puse*
matrix t5=r(responses) \ r(N)
mat list t5
matrix t5t = t5'
preserve
clear
/* put the matrix into the dataset */
svmat t5t, names(col) 
/* swap frequency back into column */
xpose, varname clear

rename _varname Drug
replace Drug = proper(subinstr(Drug,"puse","",.))

**replace Drug = subinstr(Drug,"_"," ",.)			// only if you have underscores
replace Drug = "Total # of Subjects" if Drug=="R15" 	// add 2 for inflectra and renflexis	


*** you only need this step if you want the total first
label def drugE 0 "Total # of Subjects" 1 "Enbrel" 2 "Humira" 3 "Remicade" 4 "Inflectra" 5 "Renflexis" 6 "Cimzia" 7 "Simponi" 8 "Orencia" 9 "Rituxan" 10 "Actemra" 11 "Kevzara" 12 "Xeljanz" 13 "Olumiant" 14 "Rinvoq", modify

generate byte drugE= 0 if Drug == "Total # of Subjects"
replace drugE=1 if Drug=="Enbrel"
replace drugE=2 if Drug=="Humira" 
replace drugE=3 if Drug=="Remicade" 
replace drugE=4 if Drug=="Inflectra"
replace drugE=5 if Drug=="Renflexis"
replace drugE=6 if Drug=="Cimzia" 
replace drugE=7 if Drug=="Simponi" 
replace drugE=8 if Drug=="Orencia" 
replace drugE=9 if Drug=="Rituxan" 
replace drugE=10 if Drug=="Actemra" 
replace drugE=11 if Drug=="Kevzara" 
replace drugE=12 if Drug=="Xeljanz"
replace drugE=13 if Drug=="Olumiant"
replace drugE=14 if Drug=="Rinvoq"

label values drugE drugE
sort drugE

**insert table 5
putdocx paragraph, style(Heading2) halign(center)
putdocx text ("Table 5. b/tsDMARD Prevalent use (initiation prior, at or after Enrollment) "), bold font("Calibri Light", "13", darkorange) //in the CorEvitas RA Registry
putdocx text ("a"), bold font("Calibri Light", "13", darkorange) script(super)
putdocx table t5 = data(drugE v1), width(4in) border(all,single) halign(center)  
	local rows = rowsof(t5)
putdocx table t5(2/`rows',.), nformat(%15.0fc) 
putdocx table t5(1,.), addrows(1, before)
putdocx table t5(1,2) = ("Prevalent Users") 
putdocx table t5(.,2), halign(right)
putdocx table t5(2,2), nformat(%15.0fc) 
putdocx table t5(1/2,.), bold
putdocx table t5(.,.), font(Calibri,10.5) valign(center)

putdocx paragraph, font(Calibri,8.5) // 12-6-21 changed to be consistent throughout the report; how to avoid a line after the table?
putdocx text ("a"), script(super)	
putdocx text (" This table reflects total drug use in the CorEvitas RA Registry, counting both the number of subjects who initiated or restarted a therapy at or after enrollment, as well as the subjects who had started therapy prior to enrollment and continued using the therapy at enrollment. Both active and inactive subjects are included. Subjects may be counted more than once if they used multiple b/tsDMARDs.")	

restore

*putdocx save Tables4-5_2024-08-22.docx, replace

*****************************************************************
*					Generate table 6-7 
*						   Data
*					        
*****************************************************************
// 12-7-21 data were not saved. re-run from line # 635 to re-create matrix for testing 

* tab6-7 baseline characteristics in RA pts 
// 10-3-2020 add 2 more col for inflectra_bs and renflexis_bs
// 7-28-21 adjusted order of drugs according to DP's comments

// 2024-08-21 moved inflectra and renflexis after remicade, added race/ethnicity, removed 4 disease activities, added 5 rows for race/ethnicity, adding 1 row to matrix 

foreach y in nai swt{ 
matrix t`y'=J(26, 15, .) 
matrix colnames t`y'=Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq Totalbio 
matrix rownames t`y'=N Age Female White Black Asian Other Hispanic BMI Private Medicare Medicaid None Duration nbio nbDMARDs RF CCP Erosions CDAI Remission Low Moderate High Ptpain mHAQ  

local col 0 
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq bio {
local col=`col'+1 
local row 1 
qui sum init`y'`x'   
matrix t`y'[`row', `col']=r(N) 
#delimit; 
local list" age female_male race_sub1 race_sub2 race_sub3 race_sub4 ethnicity bmi insurance_private insurance_medicare insurance_medicaid 
 insurance_none duration_ra numbio nbdmards rfposever ccpposever erosdisever cdai 
 cdaisub1 cdaisub2  cdaisub3 cdaisub4 pt_pain di ";
 #delimit cr 
foreach z of local list{ 
qui sum `x'b`z' if init`y'`x'==1, meanonly 
local ++row 
matrix t`y'[`row', `col']=r(mean) 
} 
}
}

********************************************************************
* Ying added on 3-9-18 for total number of initiator/switchers for table 6 & 7
foreach y in nai swt{ 
cap drop tot`y'num 
gen tot`y'num=0 
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
qui replace tot`y'num=tot`y'num +1 if init`y'`x'==1
} 
}

qui sum totnainum if totnainum>0 
matrix tnai[1, 15]=r(sum)	/*	10-3-20 Lin: change # of columns to 16 to add inflectra and renflexis 2023-01-02 eliminate kineret */

qui sum totswtnum if totswtnum>0
matrix tswt[1, 15]=r(sum) 

matrix list tnai   
matrix list tswt 
****************************************************************************

matrix t6=tnai
matrix tbl6=tnai
mat list t6


matrix tbl6AB = J(26,15,.)

// 2024-08-21 adding 5 rows of 1 and remove 4 100
#delimit; 
matrix X = [
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1\
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
100,100,100,100,100,100,100,100,100,100,100,100,100,100,100 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 \
1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ];
#delimit cr


mat li X
mat list tbl6


// 10-3-20 changed j=1/14 to 16 then to 15 2023-01-02
// 2024-08-21 changed to i=1/26 
forvalues i =1/26 {
	forvalues j = 1/15 {
		** normal values
		 matrix tbl6AB[`i',`j'] = tbl6[`i',`j']*X[`i',`j']
	}
}
       
matrix colnames tbl6AB=Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq Totalbio 
mat li tbl6AB

**https://www.stata.com/support/faqs/data-management/element-by-element-operations-on-matrices/

*****************************************************************
*					Insert Summary & Table: 
*				Tables 6 & 7 into Word Report
*					PUTDOCX COMMANDS
*****************************************************************
*putdocx clear
*putdocx begin ,landscape margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5)

putdocx sectionbreak, landscape margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5)

putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Table 6. Baseline"), bold font("Calibri Light", "13", darkorange)
putdocx text ("a"), bold font("","", darkorange) script(super)
putdocx text (" Characteristics of b/tsDMARD Initiations in b/tsDMARD naïve subjects"), bold font("Calibri Light", "13", darkorange) // in the CorEvitas RA Registry
putdocx text ("b, c"), bold font("Calibri Light", "13", darkorange) script(super)

putdocx table t6 = matrix(tbl6AB), rownames colnames width(8in) border(all,single) halign(center) layout(autofitc) 

** decimal formating (N)
putdocx table t6(2,.), nformat(%15.0fc) halign(right) font(Calibri,9)
// 7-2-21 changed to 1 decimal place 
putdocx table t6(3/27,.), nformat(%4.1fc) halign(right) font(Calibri,9) 
*putdocx table t6(27,.), halign(left) font(Calibri,9)
putdocx table t6(1,16)=("Total"), halign(right) font(Calibri,9) // change to 17 add 2 bs
putdocx table t6(2,1)=("Total (N)"), halign(left) font(Calibri,9)
putdocx table t6(3,1)=("Age"), halign(left) font(Calibri,9)
putdocx table t6(4,1)=("Female (%)"), halign(left) font(Calibri,9)
putdocx table t6(5,1)=("`=uchar(8195)'White"), halign(left) font(Calibri,9)
putdocx table t6(6,1)=("`=uchar(8195)'Black"), halign(left) font(Calibri,9)
putdocx table t6(7,1)=("`=uchar(8195)'Asian"), halign(left) font(Calibri,9)
putdocx table t6(8,1)=("`=uchar(8195)'Other"), halign(left) font(Calibri,9)
putdocx table t6(9,1)=("`=uchar(8195)'Hispanic or Latino"), halign(left) font(Calibri,9) 
putdocx table t6(10,1)=("BMI"), halign(left) font(Calibri,9) 
putdocx table t6(11,1)=("`=uchar(8195)'Private"), halign(left) font(Calibri,9) 
putdocx table t6(12,1)=("`=uchar(8195)'Medicare"), halign(left) font(Calibri,9) 
putdocx table t6(13,1)=("`=uchar(8195)'Medicaid"), halign(left) font(Calibri,9) 
putdocx table t6(14,1)=("`=uchar(8195)'None"), halign(left) font(Calibri,9) 
putdocx table t6(15,1)=("Disease Duration"), halign(left)  font(Calibri,9)
putdocx table t6(16,1)=("Prior # of Biologics"), halign(left)  font(Calibri,9)
putdocx table t6(17,1)=("Prior # of nbDMARDs"), halign(left)  font(Calibri,9)
putdocx table t6(18,1)=("RF positive (%)"), halign(left)  font(Calibri,9)
putdocx table t6(19,1)=("CCP positive (%)"), halign(left)  font(Calibri,9)
putdocx table t6(20,1)=("Xray erosions (%)"), halign(left)  font(Calibri,9)
putdocx table t6(21,1)=("CDAI"), halign(left)  font(Calibri,9)
putdocx table t6(22,1)=("`=uchar(8195)'Remission"), halign(left)  font(Calibri,9)
putdocx table t6(23,1)=("`=uchar(8195)'Low"), halign(left) font(Calibri,9)
putdocx table t6(24,1)=("`=uchar(8195)'Moderate"), halign(left) font(Calibri,9)
putdocx table t6(25,1)=("`=uchar(8195)'High"), halign(left)  font(Calibri,9)
putdocx table t6(26,1)=("Pt pain"), halign(left) font(Calibri,9)
putdocx table t6(27,1)=("mHAQ"), halign(left) font(Calibri,9)

	local cols = colsof(tnai)+1
putdocx table t6(1,.), bold shading("","","pct25") font(Calibri,9)
putdocx table t6(3,.), addrows(1, before) shading("","","pct25") font(Calibri,9)
putdocx table t6(3,1) = ("Demographics"), span(1,`cols') font(Calibri,9) bold

putdocx table t6(6,.), addrows(1, before) font(Calibri,9) //shading("","","pct25")
putdocx table t6(6,1) = ("Race (%)"), span(1,`cols') font(Calibri,9) bold

putdocx table t6(11,.), addrows(1, before) font(Calibri,9) //shading("","","pct25") 
putdocx table t6(11,1) = ("Ethnicity (%)"), span(1,`cols') font(Calibri,9) bold

// 2024-08-21 changing position for insurance type
putdocx table t6(14,.), addrows(1, before) shading("", "", "pct25")  
putdocx table t6(14,1) = ("Insurance Type (%) ") , span(1,`cols')  font(Calibri,9) bold
putdocx table t6(14,1) = ("d") ,   font(Calibri,9) bold append script(super) // 2022-08-01 added superscript
putdocx table t6(14,1) = (":") ,   font(Calibri,9) bold append

putdocx table t6(19,.), addrows(1, before) shading("", "", "pct25") 
putdocx table t6(19,1) = ("Disease Characteristics") , span(1,`cols') font(Calibri,9) bold

putdocx table t6(27,.), addrows(1, before) shading("", "", "pct10") 
putdocx table t6(27,1) = ("Disease Activity by CDAI (%):") , span(1,`cols') font(Calibri,9) bold

putdocx table t6(32,.), addrows(1, before) shading("", "", "pct10") 
putdocx table t6(32,1) = ("Other Disease Activity Measures") , span(1,`cols') font(Calibri,9) bold

putdocx table t6(21,.), drop // prior # of biologic not needed

putdocx paragraph, font(Calibri,8.5) // changed from table notes to footnotes 

putdocx text ("a"), script(super)
putdocx text (" Baseline is at the time of initiation"), linebreak
putdocx text ("b"), script(super)
putdocx text (" Mean, except where indicated; all estimates are among those with valid data") , linebreak
putdocx text ("c"), script(super)
putdocx text (" Table includes all subjects, i.e. active and subjects no longer active. It counts initiations at or after enrollment to registry") , linebreak
putdocx text ("d"), script(super)
putdocx text (" Subjects may indicate more than one type of insurance or coverage, so total may be larger than 100%") 

*putdocx save table6_test.docx, replace 

////////////////////////////// 2024-08-21 Testing Table 7
*putdocx clear
*putdocx begin ,landscape margin(left,0.5) margin(right,0.5)

putdocx sectionbreak, landscape  margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5)


matrix list tswt
matrix t7=tswt

matrix tbl7AB= J(26,15,.)

forvalues i =1/26 {
	forvalues j = 1/15 {
		** normal values
		 matrix tbl7AB[`i',`j'] = t7[`i',`j']*X[`i',`j']
	}
}
matrix colnames tbl7AB=Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq Totalbio        
mat li tbl7AB


*layout(autofitcontents)
**insert table 7
putdocx paragraph, style(Heading2) halign(center) 

putdocx text ("Table 7. Baseline"), bold font("Calibri Light", "13", darkorange)
putdocx text ("a "), bold font("","", darkorange) script(super)
putdocx text (" Characteristics of b/tsDMARD initiations in b/tsDMARDs experienced subjects"), bold font("Calibri Light", "13", darkorange)
putdocx text ("b, c"), bold font("Calibri Light", "13", darkorange) script(super)

putdocx table t7 = matrix(tbl7AB), rownames colnames width(8in) border(all,single) halign(center) layout(autofitc) 

putdocx table t7(2,.), nformat(%15.0fc) halign(right) font(Calibri,9)
// 7-2-21 changed to 1 decimal place 
putdocx table t7(3/27,.), nformat(%4.1fc) halign(right) font(Calibri,9)
*putdocx table t7(27,.), halign(left) font(Calibri,9)
putdocx table t7(1,16)=("Total"), halign(right) font(Calibri,9) /* 10-3-20 changed # of cols by adding 2 bs	*/
putdocx table t7(2,1)=("Total (N)"), halign(left) font(Calibri,9)
putdocx table t7(3,1)=("Age"), halign(left) font(Calibri,9)
putdocx table t7(4,1)=("Female (%)"), halign(left) font(Calibri,9)
putdocx table t7(5,1)=("`=uchar(8195)'White"), halign(left) font(Calibri,9)
putdocx table t7(6,1)=("`=uchar(8195)'Black"), halign(left) font(Calibri,9)
putdocx table t7(7,1)=("`=uchar(8195)'Asian"), halign(left) font(Calibri,9)
putdocx table t7(8,1)=("`=uchar(8195)'Other"), halign(left) font(Calibri,9)
putdocx table t7(9,1)=("`=uchar(8195)'Hispanic or Latino"), halign(left) font(Calibri,9) 
putdocx table t7(10,1)=("BMI"), halign(left) font(Calibri,9) 
putdocx table t7(11,1)=("`=uchar(8195)'Private"), halign(left) font(Calibri,9) 
putdocx table t7(12,1)=("`=uchar(8195)'Medicare"), halign(left) font(Calibri,9) 
putdocx table t7(13,1)=("`=uchar(8195)'Medicaid"), halign(left) font(Calibri,9) 
putdocx table t7(14,1)=("`=uchar(8195)'None"), halign(left) font(Calibri,9) 
putdocx table t7(15,1)=("Disease Duration"), halign(left)  font(Calibri,9)
putdocx table t7(16,1)=("Prior # of Biologics"), halign(left)  font(Calibri,9)
putdocx table t7(17,1)=("Prior # of nbDMARDs"), halign(left)  font(Calibri,9)
putdocx table t7(18,1)=("RF positive (%)"), halign(left)  font(Calibri,9)
putdocx table t7(19,1)=("CCP positive (%)"), halign(left)  font(Calibri,9)
putdocx table t7(20,1)=("Xray erosions (%)"), halign(left)  font(Calibri,9)
putdocx table t7(21,1)=("CDAI"), halign(left)  font(Calibri,9)
putdocx table t7(22,1)=("`=uchar(8195)'Remission"), halign(left)  font(Calibri,9)
putdocx table t7(23,1)=("`=uchar(8195)'Low"), halign(left) font(Calibri,9)
putdocx table t7(24,1)=("`=uchar(8195)'Moderate"), halign(left) font(Calibri,9)
putdocx table t7(25,1)=("`=uchar(8195)'High"), halign(left)  font(Calibri,9)
putdocx table t7(26,1)=("Pt pain"), halign(left) font(Calibri,9)
putdocx table t7(27,1)=("mHAQ"), halign(left) font(Calibri,9)

putdocx table t7(1,.), bold shading("","","pct25") font(Calibri,9)
putdocx table t7(3,.), addrows(1, before) shading("","","pct25") font(Calibri,9)

	local cols = colsof(tswt)+1
putdocx table t7(3,1) = ("Demographics"), span(1,`cols') font(Calibri,9) bold

putdocx table t7(6,.), addrows(1, before) font(Calibri,9) //shading("","","pct25")
putdocx table t7(6,1) = ("Race (%)"), span(1,`cols') font(Calibri,9) bold

putdocx table t7(11,.), addrows(1, before) font(Calibri,9) //shading("","","pct25") 
putdocx table t7(11,1) = ("Ethnicity (%)"), span(1,`cols') font(Calibri,9) bold

// 2024-08-21 changing position for insurance type
putdocx table t7(14,.), addrows(1, before) shading("", "", "pct25")  
putdocx table t7(14,1) = ("Insurance Type (%) ") , span(1,`cols')  font(Calibri,9) bold
putdocx table t7(14,1) = ("d") ,   font(Calibri,9) bold append script(super) // 2022-08-01 added superscript
putdocx table t7(14,1) = (":") ,   font(Calibri,9) bold append

putdocx table t7(19,.), addrows(1, before) shading("", "", "pct25") 
putdocx table t7(19,1) = ("Disease Characteristics") , span(1,`cols') font(Calibri,9) bold

putdocx table t7(27,.), addrows(1, before) shading("", "", "pct10") 
putdocx table t7(27,1) = ("Disease Activity by CDAI (%):") , span(1,`cols') font(Calibri,9) bold

putdocx table t7(32,.), addrows(1, before) shading("", "", "pct10") 
putdocx table t7(32,1) = ("Other Disease Activity Measures") , span(1,`cols') font(Calibri,9) bold

putdocx paragraph, font(Calibri,8.5) // changed from table notes to footnotes 

putdocx text ("a"), script(super)
putdocx text (" Baseline is at the time of switch"), linebreak
putdocx text ("b"), script(super)
putdocx text (" Mean, except where indicated; all estimates are among those with valid data") , linebreak
putdocx text ("c"), script(super)
putdocx text (" Table includes all subjects, i.e. active and subjects no longer active. It counts initiations at or after enrollment to registry") , linebreak
putdocx text ("d"), script(super)
putdocx text (" Subjects may indicate more than one type of insurance or coverage, so total may be larger than 100%") 

// test results: 
*putdocx save tables6-7_2024-08-22.docx, replace

*****************************************************************
*					Generate table 8 
*						   Data
*****************************************************************
/*	9-24-19	LG	Add N for % and SD for mean		*/
*****************************************************************
*					Insert Summary & Table: 
*				   Tables 8 into Word Report
*					PUTDOCX COMMANDS
*****************************************************************

//use qrr_temp, clear

*putdocx clear
*putdocx begin

putdocx sectionbreak 

preserve
keep if lastencounter==1
lab var age "Age (years)"
lab var female_male "Female (%)"
lab var race_sub1 "`=uchar(8195)'White"
lab var race_sub2 "`=uchar(8195)'Black"
lab var race_sub3 "`=uchar(8195)'Asian"
lab var race_sub4 "`=uchar(8195)'Other"
lab var ethnicity "`=uchar(8195)'Hispanic or Latino"
lab var bmi "BMI"
lab var insurance_private "`=uchar(8195)'Private"
lab var insurance_medicare "`=uchar(8195)'Medicare"
lab var insurance_medicaid "`=uchar(8195)'Medicaid"
lab var insurance_none "`=uchar(8195)'None"
lab var duration_ra "Disease Duration (years)"
lab var numbio "Prior # of Biologics"
lab var nbdmards "Prior # of nbDMARDs"
lab var rfposever "RF positive (%)"
lab var ccpposever "CCP positive (%)"
lab var erosdisever "Xray erosions (%)"
lab var cdai "CDAI"
lab var cdaisub1 "`=uchar(8195)'Remission"
lab var cdaisub2 "`=uchar(8195)'Low"
lab var cdaisub3 "`=uchar(8195)'Moderate"
lab var cdaisub4 "`=uchar(8195)'High"
lab var pt_pain "Pt pain evaluation (VAS 0-100)"
lab var di "mHAQ"


*list variables in local macros by variable type; then attach prefix to varname
// tender_jts_28 swollen_jts_28 md_global_assess pt_global_assess
local cont age bmi duration_ra numbio nbdmards cdai  pt_pain di
rename (`cont') con=

local bin female_male race_sub1 race_sub2 race_sub3 race_sub4 ethnicity rfposever ccpposever erosdisever cdaisub1 cdaisub2  cdaisub3 cdaisub4
rename (`bin') bin=

local all  insurance_private insurance_medicare insurance_medicaid insurance_none  
rename (`all') all=

putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Table 8. Characteristics of All Subjects (active and non-active) at Last Visit "),  bold font("Calibri Light", "13", darkorange)	 
putdocx text ("a"), linebreak script(super) bold font("Calibri Light", "13", darkorange)	 

putdocx text ("(cross-sectional)"),bold font("Calibri Light", "13", darkorange)
putdocx table a=(2,2) , halign(center) layout(autofitc) //note(a Mean ± SD, except where indicated) //width(4in) 2022-08-08 reformated table 

putdocx table a(1,1)=("RA Subject"), bold linebreak
count 
local temp1: display %10.0fc (r(N))
putdocx table a(1,1)=("N="), bold append
putdocx table a(1,1)=(strltrim("`temp1'")), bold append
putdocx table a(1,2) = ("Mean ± SD or n (%)"), bold


local vars " conage binfemale_male binrace_sub1 binrace_sub2 binrace_sub3 binrace_sub4 binethnicity conbmi allinsurance_private allinsurance_medicare allinsurance_medicaid allinsurance_none conduration_ra connumbio connbdmards binrfposever binccpposever binerosdisever concdai bincdaisub1 bincdaisub2  bincdaisub3 bincdaisub4 conpt_pain condi"


local row=2
foreach v of local vars {

	* binary variables
	if substr("`v'",1,3)=="bin" {
			if "`v'"=="binrace_sub1"  {
		putdocx table a(`row',.), addrows(1, before)	//shading("","","pct10")
		putdocx table a(`row',1) = ("Race (%):"),colspan(2) bold		
        local ++row
			}
			if "`v'"=="binethnicity"  {
		putdocx table a(`row',.), addrows(1, before)	//shading("","","pct10")
		putdocx table a(`row',1) = ("Ethnicity (%):"),colspan(2) bold		
        local ++row
			}
			if "`v'"=="bincdaisub1"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct10")
		putdocx table a(`row',1) = ("Disease Activity by CDAI (%):"),colspan(2) bold		
        local ++row
			}
			
		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = (`"`lbl'"')
		tab `v' 
		local countN = r(N)
		count if `v' == 1 
				local temp1: display %10.0fc (r(N))
				local tmp: display %5.1f (r(N) / `countN')*100	// 7-2-21 change to 1 decimal 			
				putdocx table a(`row',2) = (strltrim("`temp1'")), halign(right) append  
				putdocx table a(`row',2) = (" (" + strltrim("`tmp'") + ")"), append 
		local ++row
		}
	
	* continuous variables
	if substr("`v'",1,3)=="con" {
	 		if "`v'"=="conage"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct25")
		putdocx table a(`row',1) = ("Demographics"),colspan(2) bold	
			local ++row
			}
		if "`v'"=="conduration_ra"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct25")
		putdocx table a(`row',1) = ("Disease Characteristics"),colspan(2) bold		
			local ++row
			}
		if "`v'"=="conpt_pain"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct10")
		putdocx table a(`row',1) = ("Other Disease Activity Measures"),colspan(2) bold	
			local ++row
			}	
		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = (`"`lbl'"')
					summarize `v' , d
			local temp2: display %5.1f (r(mean)) // 7-2-21 change to 1 decimal 
			local temp3: display %5.1f (r(sd)) // 7-2-21 change to 1 decimal 
		putdocx table a(`row',2) = (strltrim("`temp2'") + "±" + strltrim("`temp3'")),  halign(right)	
		local ++row
		}
		
	* "check all that apply"
	if substr("`v'",1,3)=="all" {
	
		* add header row for "Insurance Type" 
 		if "`v'"=="allinsurance_private"  {
		putdocx table a(`row',.), addrows(1, before) shading("","","pct25")
		putdocx table a(`row',1) = ("Insurance Type (%)"),colspan(2) bold
		putdocx table a(`row',1) = ("b"), script(super) append
		putdocx table a(`row',1) = (":"), append
			local ++row
			}

		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = ("`lbl'")
						tab `v' 
				local countN = r(N)
						count if `v' == 1 
				local temp1: display %10.0fc (r(N))
				local tmp: display %5.1f (r(N) / `countN')*100 // 7-2-21 change to 1 decimal 
							
				putdocx table a(`row',2) = (strltrim("`temp1'")), halign(right) append  
				putdocx table a(`row',2) = (" (" + strltrim("`tmp'") + ")"), append 
		local ++row
		}
	
	}
restore
/*	9-24-19 LG: there'll be an extra line at the bottom, delete it	*/
putdocx table a(`row',.), drop
putdocx table a(.,.), font(Calibri,11) valign(center)

putdocx table a(.,1), halign(left)

putdocx table a(.,2), halign(right)

putdocx table a(1/2,.), nformat(%15.0fc) shading("","","pct25")

putdocx paragraph, font(Calibri,8.5) // changed from table notes to footnotes 

putdocx text  ("a") , script(super)
putdocx text  (" Mean ± SD, except where indicated") , linebreak
putdocx text  ("b") , script(super)
putdocx text  (" Subjects may indicate more than one type of insurance or coverage, so total may be larger than 100%")

*putdocx save table8_test_2024-08-22.docx, replace 

//////////////////////////////////
// 6-23-2022 add table 8a  for active patients only 
//////////////////////////////////
*putdocx clear
*putdocx begin
putdocx sectionbreak 

preserve
keep if lastencounter==1 & active_pt==1

lab var age "Age (years)"
lab var female_male "Female (%)"
lab var race_sub1 "`=uchar(8195)'White"
lab var race_sub2 "`=uchar(8195)'Black"
lab var race_sub3 "`=uchar(8195)'Asian"
lab var race_sub4 "`=uchar(8195)'Other"
lab var ethnicity "`=uchar(8195)'Hispanic or Latino"
lab var bmi "BMI"
lab var insurance_private "`=uchar(8195)'Private"
lab var insurance_medicare "`=uchar(8195)'Medicare"
lab var insurance_medicaid "`=uchar(8195)'Medicaid"
lab var insurance_none "`=uchar(8195)'None"
lab var duration_ra "Disease Duration (years)"
lab var numbio "Prior # of Biologics"
lab var nbdmards "Prior # of nbDMARDs"
lab var rfposever "RF positive (%)"
lab var ccpposever "CCP positive (%)"
lab var erosdisever "Xray erosions (%)"
lab var cdai "CDAI"
lab var cdaisub1 "`=uchar(8195)'Remission"
lab var cdaisub2 "`=uchar(8195)'Low"
lab var cdaisub3 "`=uchar(8195)'Moderate"
lab var cdaisub4 "`=uchar(8195)'High"
lab var pt_pain "Pt pain evaluation (VAS 0-100)"
lab var di "mHAQ"


*list variables in local macros by variable type; then attach prefix to varname
//tender_jts_28 swollen_jts_28 md_global_assess pt_global_assess
local cont age bmi duration_ra numbio nbdmards cdai pt_pain di
rename (`cont') con=

local bin female_male race_sub1 race_sub2 race_sub3 race_sub4 ethnicity rfposever ccpposever erosdisever cdaisub1 cdaisub2  cdaisub3 cdaisub4
rename (`bin') bin=

local all insurance_private insurance_medicare insurance_medicaid insurance_none  
rename (`all') all=

putdocx paragraph, style(Heading2) halign(center) 

putdocx text ("Table 8a. Characteristics of Active Subjects at Last Visit "), bold font("Calibri Light", "13", darkorange) 
putdocx text ("a"), linebreak bold font("Calibri Light", "13", darkorange)	script(super) 


putdocx text ("(cross-sectional)"),bold font("Calibri Light", "13", darkorange)
putdocx table a=(2,2) , layout(autofitc) halign(center) ///width(4in)

putdocx table a(1,1)=("RA Active Subject"), bold linebreak
count 
local temp1: display %10.0fc (r(N))
putdocx table a(1,1)=("N="), bold append
putdocx table a(1,1)=(strltrim("`temp1'")), bold append
putdocx table a(1,2) = ("Mean ± SD or n (%)"), bold

local vars " conage binfemale_male binrace_sub1 binrace_sub2 binrace_sub3 binrace_sub4 binethnicity conbmi allinsurance_private allinsurance_medicare allinsurance_medicaid allinsurance_none conduration_ra connumbio connbdmards binrfposever binccpposever binerosdisever concdai bincdaisub1 bincdaisub2  bincdaisub3 bincdaisub4 conpt_pain condi"


local row=2
foreach v of local vars {

	* binary variables
	if substr("`v'",1,3)=="bin" {
			if "`v'"=="binrace_sub1"  {
		putdocx table a(`row',.), addrows(1, before)	//shading("","","pct10")
		putdocx table a(`row',1) = ("Race (%):"),colspan(2) bold		
        local ++row
			}
			if "`v'"=="binethnicity"  {
		putdocx table a(`row',.), addrows(1, before)	//shading("","","pct10")
		putdocx table a(`row',1) = ("Ethnicity (%):"),colspan(2) bold		
        local ++row
			}
			if "`v'"=="bincdaisub1"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct10")
		putdocx table a(`row',1) = ("Disease Activity by CDAI (%):"),colspan(2) bold		
        local ++row
			}
		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = (`"`lbl'"')
		tab `v' 
		local countN = r(N)
		count if `v' == 1 
				local temp1: display %10.0fc (r(N))
				local tmp: display %5.1f (r(N) / `countN')*100	// 7-2-21 change to 1 decimal 			
				putdocx table a(`row',2) = (strltrim("`temp1'")), halign(right) append  
				putdocx table a(`row',2) = (" (" + strltrim("`tmp'") + ")"), append 
		local ++row
		}
	
	* continuous variables
	if substr("`v'",1,3)=="con" {
	 		if "`v'"=="conage"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct25")
		putdocx table a(`row',1) = ("Demographics"),colspan(2) bold	
			local ++row
			}
		if "`v'"=="conduration_ra"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct25")
		putdocx table a(`row',1) = ("Disease Characteristics"),colspan(2) bold		
			local ++row
			}
		if "`v'"=="conpt_pain"  {
		putdocx table a(`row',.), addrows(1, before)	shading("","","pct10")
		putdocx table a(`row',1) = ("Other Disease Activity Measures"),colspan(2) bold	
			local ++row
			}	
		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = (`"`lbl'"')
					summarize `v' , d
			local temp2: display %5.1f (r(mean)) // 7-2-21 change to 1 decimal 
			local temp3: display %5.1f (r(sd)) // 7-2-21 change to 1 decimal 
		putdocx table a(`row',2) = (strltrim("`temp2'") + "±" + strltrim("`temp3'")),  halign(right)	
		local ++row
		}
		
	* "check all that apply"
	if substr("`v'",1,3)=="all" {
	
		* add header row for "Insurance Type" 
 		if "`v'"=="allinsurance_private"  {
		putdocx table a(`row',.), addrows(1, before) shading("","","pct25")
		putdocx table a(`row',1) = ("Insurance Type (%)"),colspan(2) bold
		putdocx table a(`row',1) = ("b"), script(super) append
		putdocx table a(`row',1) = (":"), append
			local ++row
			}

		putdocx table a(`row',.), addrows(1, before)
		local lbl: variable label `v'
		putdocx table a(`row',1) = ("`lbl'")
						tab `v' 
				local countN = r(N)
						count if `v' == 1 
				local temp1: display %10.0fc (r(N))
				local tmp: display %5.1f (r(N) / `countN')*100 // 7-2-21 change to 1 decimal 
							
				putdocx table a(`row',2) = (strltrim("`temp1'")), halign(right) append  
				putdocx table a(`row',2) = (" (" + strltrim("`tmp'") + ")"), append 
		local ++row
		}
	
	}
restore
/*	9-24-19 LG: there'll be an extra line at the bottom, delete it	*/
putdocx table a(`row',.), drop
putdocx table a(.,.), font(Calibri,11) valign(center)

putdocx table a(.,1), halign(left)

putdocx table a(.,2), halign(right)

putdocx table a(1/2,.), nformat(%15.0fc) shading("","","pct25")

putdocx paragraph, font(Calibri,8.5) // changed from table notes to footnotes 

putdocx text  ("a") , script(super)
putdocx text  (" Mean ± SD, except where indicated") , linebreak
putdocx text  ("b") , script(super)
putdocx text  (" Subjects may indicate more than one type of insurance or coverage, so total may be larger than 100%")

*putdocx save tables8_8a_2024-08-22.docx, replace

*****************************************************************
*					Generate Figure 1a. 
*						   Data				        
*****************************************************************
// 2023-01-02 eliminated kineret
// 10-3-2020 added inflectra and renflexis
* for figure 1. initiators (
// 2024-04-01 delete all _bs, change id to subject_number
*use qrr_temp, clear 

cap drop bioinit 
local count 0
gen bioinit=.
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
local count=`count'+1
qui replace bioinit=`count' if init`x'==1 
lab define bio `count' `x', modify
lab val bioinit bio
} 

* fig 1- initiators by semi year	
tab timehy bioinit, matcell(f1)

// add inflectra and renflexis as TNF?
* figure 2a & 2b
sort subject_number timeqrt visitdate 
cap drop tnfuse
gen tnfuse=.
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi {
qui by subject_number timeqrt: gen cpres`x'=sum(pres_`x')
qui by subject_number timeqrt: replace cpres`x'=. if _n!=_N 
qui replace tnfuse=1 if cpres`x'>=1 & cpres`x'<. 
} 

foreach x in orencia rituxan actemra kevzara {
qui by subject_number timeqrt: gen cpres`x'=sum(pres_`x')
qui by subject_number timeqrt: replace cpres`x'=. if _n!=_N 
qui replace tnfuse=2 if cpres`x'>=1 & cpres`x'<. 
} 

// 1-26-2022 moved JAKi to a 3rd category 
foreach x in xeljanz olumiant rinvoq {
qui by subject_number timeqrt: gen cpres`x'=sum(pres_`x')
qui by subject_number timeqrt: replace cpres`x'=. if _n!=_N 
qui replace tnfuse=3 if cpres`x'>=1 & cpres`x'<. 
} 

lab define tnf 1 TNF 2 "non-TNF" 3 "tsDMARDs", modify 
lab val tnfuse tnf 

lab define bioinit 1 "Enbrel" 2 "Humira" 3 "Remicade" 4 "Inflectra" 5 "Renflexis" 6 "Cimzia" 7 "Simponi" 8 "Orencia" 9 "Rituxan" 10 "Actemra" 11 "Kevzara" 12 "Xeljanz" 13 "Olumiant" 14 "Rinvoq" , modify 
lab val bioinit bioinit 

local count 0
cap drop biouse
gen biouse=.
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
local count=`count'+1 
qui replace biouse=`count' if cpres`x'>=1 & cpres`x'<. 
drop cpres`x'
} 

lab val biouse bioinit
* Lin modified for Figure 1b

/* 1-26-2022 This part is not necessary for putdocx
cap drop biouser
gen biouser = 1 if bioinit!=.
cap drop tnfy
gen tnfy = tnfuse if tnfuse==1
cap drop tnfn 
gen tnfn = tnfuse if tnfuse==2
lab val tnfy tnf 
lab val tnfn tnf 

* fig 1a- initiators by semi year	
tab timeqrt tnfuse, matcell(f1a)

* fig 1b- initiators by semi year	
tab timeqrt bioinit, matcell(f1b)

* fig 2a&b-tnfi user by qrt  
tab timeqrt tnfuse, matcell(f2a) 
*/
*****************************************************************
*					Create Chart: 
*			   		Figure 1a. 
*				Bar Chart by TNF vs Non-TNF
*****************************************************************
**   browse timeqrt tnfuse timehy  bioinit biouser
**bar(1, bcolor(blue)) bar(2, bcolor(red))
** Figure 1a Chart
// 11-1-2021 change the label of non-TNF to non-TNF/JAKi
	catplot tnfuse timeqrt_c, percent(timeqrt_c timeyr) over(timeyr) asyvars stack /// 
	ytitle("b/tsDMARD Users (% Total)") ylabel(, angle(h)) recast(bar) ///
	var2opts(label(labsize(*.75))) var1opts(label(labsize(*.75))) ///
    legend(label(1 "TNF") label(2 "non-TNF") label(3 "tsDMARDs") rows(1) region(lcolor(white))) /// 
	name(fig1a, replace)  

	graph export fig1a.png,  width(1100) height(800)  replace

*****************************************************************
*					Create Chart: 
*			   		Figure 1b. 
*				 Bar Chart by Biologic
*****************************************************************
// 10-3-20 added 15 & 14 to order
** Figure 1b Chart
	catplot biouse timeqrt_c, percent(timeqrt_c timeyr) over(timeyr) asyvars stack ///
    ytitle("b/tsDMARD Users (% Total)") ylabel(, angle(h)) recast(bar) ///
    var2opts(label(labsize(*.5))) var1opts(label(labsize(*.75))) legend(order(14 13 12 11 10 9 8 7 6 5 4 3 2 1) ///
    symys(*.5) symxs(*.5) pos(3) col(1) subtitle("",size(small)) size(small)) ///
	name(fig1b_test, replace)  

	graph export fig1b.png,  width(1100) height(800)  replace
*****************************************************************
*					Insert FIGURES: 
*			   Figure 1a. into Word Report
*					PUTDOCX COMMANDS
*****************************************************************
*putdocx begin, margin(top,0.5) margin(bottom,0.5)

putdocx sectionbreak, margin(top,0.5) margin(bottom,0.5) 

putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 1a. Quarterly Report of Product Share of TNF vs. non-TNF vs. tsDMARDs Use"), bold font("Calibri Light","13", darkorange)	 // in CorEvitas RA Registry Patients
putdocx paragraph
putdocx image fig1a.png, width(6.5in) height(3.5in) linebreak

*****************************************************************
*					Insert FIGURES: 
*			   Figure 1b. into Word Report (same page)
*					PUTDOCX COMMANDS
*****************************************************************
	
**insert title for Figure 1b.
putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 1b. Quarterly Report of Product Share of b/tsDMARDs Use"), bold font("Calibri Light","13", darkorange) 
putdocx paragraph, halign(center)
putdocx image fig1b.png, width(6.5in) height(3.5in) linebreak

//putdocx save Figure1s_test.docx, replace  
//save temp, replace 1-25-2021 temporarily saved docx and data
*****************************************************************
*					    Create Chart: 
*			Figure 2. Change in Quarterly Product Share  
*				Bar Chart by Biologic/Small Molecule Use in RA 
*****************************************************************
//use temp, clear  1-25-2021 for repeating purpose 
*use qrr_temp, clear
// 2024-08-20 changed to comparing 4 quarters with 4 quarters before 
// 2024-08-21 timeyr is not an appropriate variable for Q3 2024
cap drop timeyr2
gen timeyr2=1 if lastyr2==1
replace timeyr2=2 if lastyr2==1 & lastyr==1
tab timeyr2 timeyr, missing
tab timeyr2 biouse if lastyr2==1, row nofreq matcell(freq)
// previously comparing the last 2 quarters prior to 6 months of current date 
*tab timeqrt biouse if  last2qrt==1, row nofreq matcell(freq) 
mata: st_matrix("freq", (st_matrix("freq")  :/ rowsum(st_matrix("freq"))*100))
mat li freq , format("%3.2f")
matrix colnames freq= "Enbrel" "Humira" "Remicade"  "Inflectra" "Renflexis" "Cimzia" "Simponi" "Orencia" "Rituxan" "Actemra" "Kevzara" "Xeljanz" "Olumiant" "Rinvoq"

mat tbl2a = freq[1,1...]
mat tbl2b = freq[2,1...]

mat tbl2diff = tbl2b-tbl2a
mat list tbl2a
mat list tbl2b
mat list tbl2diff

matrix rowtest = tbl2diff[1, 1...]

 /* rowtest is the row I want to graph     */
 capture drop var_colnames
 capture drop trans_rowtest
 capture drop var_colorder
 gen var_colnames = ""
 gen var_colorder = .
 gen trans_rowtest = .
 tokenize "`: colnames rowtest'"
 qui forval i = 1/`= colsof(rowtest)' {
  replace trans_rowtest = rowtest[1, `i'] in `i'
  replace var_colnames = "``i''" in `i'
  replace var_colorder = _n
 }
 
// 2023-04-26 bar1-bar14 are sorted alphabetically, bar1 stands for actemra and bar14 stands for xeljanz...etc.

 *** Need to figure out how to insert axis labels with asyvars
 // 2024-08-22 the bar colors are based on alphabetic order. For example, bar 1 stands for Actemra, and bar 14 for Xeljanz. bar 1 is not the first bar in the graph. Current order: 1 Actemra 2 cimzia 3 enbrel 4 humira 5 inflectra 6 kevzara 7 olumiant 8 orencia 9 renflexis 10 remicade 11 rinvoq 12 rituxan 13 simponi 14 xeljanz. After figure 1, check the assigned colors for each drug and make sure the colors of figures 2-4 for each drug is the same as figure 1  
 graph bar (asis) trans_rowtest, over(var_colnames, sort(var_colorder) label(labsize(small) angle(45))) ascategory  asyvars bar(1, color(emidblue)) bar(2, color(cranberry)) bar(3, color(navy)) bar(4, color(maroon)) bar(5, color(dkorange)) bar(6, color(emerald)) bar(7, color(erose)) bar(8, color(khaki)) bar(9, color(teal)) bar(10, color(forest_green))  bar(11, color(gold)) bar(12, color(sienna)) bar(13, color(lavender)) bar(14, color(brown)) ytitle("Change since Last Year (%)") ylabel(-2(1)3, angle(h)) legend(off) blabel(bar, position(outside) format(%9.2f)) showyvars name(fig2_test3, replace)  
	// 1-25-2021 added ylabel option, adjust as future needed 
	
	graph export fig2.png,   width(1100) height(800)  replace

*****************************************************************
*					Insert FIGURES: 
*			   Figure 2. into Word Report (same page)
*					PUTDOCX COMMANDS
*****************************************************************

/*	10-25-2019 Heather: 
Write this out in words: Change from quarter 4 of 2018 to quarter 1 of 2019 
Also recommend having the scale be a percentage (0-X%) rather than a proportion--already in percentage
*/
*putdocx clear
*putdocx begin 
putdocx sectionbreak 


/* use rptdt__2_Oct_2019, clear
re-label timeqrt_c2 to quarter x of xxxx	*/
/* cap drop timeqrt_c2m
gen str20 timeqrt_c2m="Quarter "+substr(timeqrt_c2,6,1)+" of "+substr(timeqrt_c2,1,4)
tab timeqrt_c2m if last2qrt==1
10-3-2020 check order, it depends on the quarter instead of year, e.g. if q4 to q1, the order needs to be changed manually
levelsof timeqrt_c2m if last2qrt==1, local(labs)
forval i=1/2 {
              local lab`i' : word `i' of `labs'
}
*/

*local label2 "`mylbl'"
*di "`mylbl'"

**insert title for Figure 2.
putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 2. Change in Yearly Product Share of b/tsDMARD Use"), bold font("Calibri Light","13", darkorange)
putdocx paragraph, halign(center) 
*putdocx text ("[")
putdocx text ("[$fig2lbl]")
*putdocx text ("]")
putdocx paragraph, halign(center)
putdocx image fig2.png, width(6.5in) height(4.5in) linebreak
** Lin changed the ratio to 4.5in high, previously 3.25in
*putdocx save Figure2_test, replace  
//save temp, replace 

*****************************************************************
*					    Create Chart: 
*	Figure 3. Breakdown by Product of Biologic/Small Molecule Use in RA  
*		Patients in last 12 Months for Biologic Naïve Patients
*	Figure 4. Breakdown by Product of Biologic/Small Molecule   
*		Prescribing in RA Patients in last 12 Months for Biologic Switchers 
*         (Patients with a History of Prior Biologic Use)
*****************************************************************

/* 
fig3. # of pts using their 1st biologic in last yr (even if they initiated it 2 yrs ago)
fig4. use of biologic as above but now it is their 2nd or later biologic used.
*/ 
// 10-3-2020 added inflectra and renflexis here
// 2024-04-01 eliminate all _bs, change from id to subject_number, change from pres to pres_, hx to hx_

foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
cap drop `x'nai
qui gen `x'nai=1 if pres_`x'==1 & (numbio-hx_`x'==0) & lastyr==1
cap drop `x'swt
qui gen `x'swt=1 if pres_`x'==1 & (numbio-hx_`x'>=1) & lastyr==1
} 

sort subject_number lastyr visitdate 
local count 0 
foreach y in nai swt{ 
	cap drop bio`y'lyr
qui gen bio`y'lyr=. 
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
local count=`count' +1
qui by subject_number lastyr: gen cum`x'`y'=sum(`x'`y') if lastyr==1
qui replace cum`x'`y'=1 if cum`x'`y'>1 
qui by subject_number lastyr: replace cum`x'`y'=0 if _n!=_N & lastyr==1
qui replace bio`y'lyr=`count' if cum`x'`y'==1 & lastyr==1 
lab define bio `count' `x', modify 
lab val bio`y'lyr bio 
drop cum`x'`y' `x'`y'  
} 
} 

* fig 3-use in RA patients in last 12 months for biologic naive patients  /*	Lin: install fre to get the Kevzara (obs==0) displayed	*/
/*tab bionailyr if lastyr==1, missing matcell(freq) 
mata: st_matrix("freq", st_matrix("freq"))*/
fre bionailyr if lastyr==1, include(1/14) // from 13 to 15 by including inflectra and renflexis  scalar r(N_valid) =  4027
*local tottab3=r(N_valid)
*display "`tottab3'"
global tottab3: display %5.0fc (r(N_valid))
mat freq=r(valid)

mat li freq

mat freqt = freq'
mat li freqt
matrix colnames freqt= "Enbrel" "Humira" "Remicade" "Inflectra" "Renflexis" "Cimzia" "Simponi" "Orencia" "Rituxan" "Actemra" "Kevzara" "Xeljanz" "Olumiant" "Rinvoq"
mat li freqt

 matrix rowtest = freqt[1, 1...]
 
 /* rowtest is the row I want to graph     */
 capture drop var_colnames
 capture drop trans_rowtest
 capture drop var_colorder
 gen var_colnames = ""
 gen var_colorder = .
 gen trans_rowtest = .
 tokenize "`: colnames rowtest'"
 qui forval i = 1/`= colsof(rowtest)' {
  replace trans_rowtest = rowtest[1, `i'] in `i'
  replace var_colnames = "``i''" in `i'
  replace var_colorder = _n
 }


// 1-25-2021 added scales 0(200)1200 to ylabel 
 *** Need to figure out how to insert axis labels with asyvars
 graph bar (asis) trans_rowtest, over(var_colnames, sort(var_colorder) gap(10) label(labsize(small) angle(45))) asyvars bar(1, color(emidblue)) bar(2, color(cranberry)) bar(3, color(navy)) bar(4, color(maroon)) bar(5, color(dkorange)) bar(6, color(emerald)) bar(7, color(erose)) bar(8, color(khaki)) bar(9, color(teal)) bar(10, color(forest_green))  bar(11, color(gold)) bar(12, color(sienna)) bar(13, color(lavender)) bar(14, color(brown)) ytitle("Number of b/tsDMARDs Users") ylabel(0(200)1200, angle(h)) legend(off)  showyvars name(fig3, replace)  
 

	**blabel(bar, position(outside) format(%9.0f))
	
	graph export fig3.png,  width(1100) height(800) replace

* fig 4 use in RA patients in last 12 months for switcher patients	
// 10-3-2020 changed to include 16-30 by adding 2 biosimilars
// 2023-01-02 changed to 15/28 by not including kineret
	
fre bioswtlyr if lastyr==1, include(15/28)
global tottab4: display %5.0fc (r(N_valid))
mat freq=r(valid) 

mat li freq


mat freqt = freq'
matrix colnames freqt= "Enbrel" "Humira" "Remicade" "Inflectra" "Renflexis" "Cimzia" "Simponi" "Orencia" "Rituxan""Actemra" "Kevzara" "Xeljanz" "Olumiant" "Rinvoq"
mat li freqt

 matrix rowtest = freqt[1, 1...]
 
 /* rowtest is the row I want to graph     */
 capture drop var_colnames
 capture drop trans_rowtest
 capture drop var_colorder
 gen var_colnames = ""
 gen var_colorder = .
 gen trans_rowtest = .
 tokenize "`: colnames rowtest'"
 qui forval i = 1/`= colsof(rowtest)' {
  replace trans_rowtest = rowtest[1, `i'] in `i'
  replace var_colnames = "``i''" in `i'
  replace var_colorder = _n
 }


 *** Need to figure out how to insert axis labels with asyvars
 graph bar (asis) trans_rowtest, over(var_colnames, sort(var_colorder) gap(10) label(labsize(small) angle(45))) asyvars bar(1, color(emidblue)) bar(2, color(cranberry)) bar(3, color(navy)) bar(4, color(maroon)) bar(5, color(dkorange)) bar(6, color(emerald)) bar(7, color(erose)) bar(8, color(khaki)) bar(9, color(teal)) bar(10, color(forest_green))  bar(11, color(gold)) bar(12, color(sienna)) bar(13, color(lavender)) bar(14, color(brown)) ytitle("Number of b/tsDMARDs Users") ylabel(0(200)1200, angle(h)) legend(off) showyvars name(fig4, replace)  

	**blabel(bar, position(outside) format(%9.0f))
	
	graph export fig4.png,  width(1100) height(800) replace



*****************************************************************
*					Insert FIGURES: 
*			   Figure 3 & 4. into Word Report (same page)
*					PUTDOCX COMMANDS
*****************************************************************
*putdocx begin, margin(top,0.4) margin(bottom,0.4) 

putdocx sectionbreak, margin(top,0.4) margin(bottom,0.4)


**insert title for Figure 3.
putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 3. Breakdown by Product of b/tsDMARD Use"), linebreak bold font("Calibri Light","13", darkorange) // in RA Patients
// 7-2-21 change every quarter for title 
putdocx text ("in last 12 Months ($fig3lbl) for b/tsDMARD Naïve Subjects"), linebreak bold font("Calibri Light","13", darkorange) 

putdocx text ("(First-Ever b/tsDMARD, Total=$tottab3)"), bold font("Calibri Light","13", darkorange) // 4,027 12-6-21 needs automation here

putdocx paragraph, halign(center)
putdocx image fig3.png, width(5.5in) height(3.3in) linebreak


**insert title for Figure 4.
putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 4. Breakdown by Product of b/tsDMARD Use"), linebreak bold font("Calibri Light","13", darkorange)
putdocx text ("in last 12 Months ($fig3lbl) for b/tsDMARD Experienced Subjects"), linebreak bold font("Calibri Light","13", darkorange) // 4-2-21 updated

putdocx text ("(Subjects with a History of Prior b/tsDMARD Use, Total=$tottab4)"), bold font("Calibri Light","13", darkorange) // 12-6-21 try automation 5,673

putdocx paragraph, halign(center)
putdocx image fig4.png, width(5.5in) height(3.3in) linebreak

*putdocx save figures3_4_test.docx, replace 

// 2024-04-01 add & lastyr==1 for count 
matrix t6=J(4, 14, .) 
matrix colnames t6=Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq
matrix rownames t6="Side Effect" Efficacy Cost Other 
	
local row 0
foreach x in enbrel humira remicade inflectra renflexis cimzia simponi orencia rituxan actemra kevzara xeljanz olumiant rinvoq {
local row=`row'+1 
local col 0 
// E R N P
foreach y in safe eff cost oth {
local col=`col'+1
qui count if `x'_disc_`y'==1 & lastyr==1 
matrix t6[`col', `row']=r(N) 
} 
} 

cap drop SideEffect	
gen SideEffect = t6[1,_n] in 1/14	/*	10-3-20 Lin: change from 13 to 15 to add 2 bs; 2023-01-02 change from 15 to 14 by eliminating kineret*/
cap drop Efficacy
gen Efficacy = t6[2,_n] in 1/14	
cap drop Cost
gen Cost = t6[3,_n] in 1/14	
cap drop Other
gen Other = t6[4,_n] in 1/14
lab var SideEffect "Side Effect"	
lab var Efficacy "Loss of Efficacy"	
lab var Cost "Cost/Insurance"

 capture drop var_colorder
 capture drop BioUse
 gen BioUse = ""
 gen var_colorder = .
 tokenize "`: colnames t6'"
 qui forval i = 1/`= colsof(t6)' {
  replace BioUse = "``i''" in `i'
    replace var_colorder = _n
 }

  ** browse var_colorder BioUse SideEffect Efficacy Cost Other

* fig 5a		
matrix list t6, title(Fig 6. # of reason of discontinue in last year) 

// 1-25-2021 add 0(50)200 to ylabel 
**removed asyvars
graph bar (asis) SideEffect Efficacy Cost Other, over(BioUse, sort(var_colorder) gap(50) label(labsize(small) angle(45))) ytitle("Number of Events") ylabel(0(50)200, angle(h)) legend(pos(6) rows(1) ) scale(*.75) name(fig5a, replace) 

**Lin, previously gap(50); try gap(60) to solve figure 5 legends too close to each other

	**blabel(bar, position(outside) format(%9.0f))

	graph export fig5a.png,  width(1100) height(800) replace

	
 
**drop Enbrel Humira Remicade Orencia Rituxan Kineret Cimzia Simponi Actemra Xeljanz
	
** create a matrix with percentages 	
matrix t7=t6 
mata: st_matrix("t7", (st_matrix("t7")  :/ colsum(st_matrix("t7"))*100))
mat li t7 , format("%3.2f")
matrix colnames t7= "Enbrel" "Humira" "Remicade" "Inflectra" "Renflexis" "Cimzia" "Simponi" "Orencia" "Rituxan" "Actemra" "Kevzara" "Xeljanz" "Olumiant" "Rinvoq"
mat li t7

** saves columns into variable
svmat t7, names(col)	

matrix t8=t6
matrix rownames t8=SideEffect Efficacy Cost Other  
matrix list t8 
 capture drop var_colorder
 capture drop DropReason

 gen DropReason = ""
 gen var_colorder = .
 tokenize "`: rownames t8'"
 qui forval i = 1/`= rowsof(t8)' {
  replace DropReason = "``i''" in `i'
    replace var_colorder = _n
 }

 
 replace DropReason = "Side Effect" if DropReason=="SideEffect"
 replace DropReason = "Loss of Efficacy" if DropReason=="Efficacy"
 replace DropReason = "Cost/Insurance" if DropReason=="Cost"

 ** drop Enbrel Humira Remicade Orencia Rituxan Kineret Cimzia Simponi Actemra Xeljanz
 
 
**browse var_colorder DropReason Enbrel Humira Remicade Orencia Rituxan Kineret Cimzia Simponi Actemra Xeljanz
	
graph bar (asis) Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq, over(DropReason, label(labsize(medium)) sort(var_colorder)) ytitle("Percent of Events (%)") ylabel(, angle(h)) legend(pos(3) cols(1)) scale(*.75) name(fig5b, replace)
		 
graph export fig5b.png,  width(1100) height(800) replace
		 

		 
drop SideEffect Efficacy Cost Other BioUse var_colorder
drop DropReason Enbrel Humira Remicade Inflectra Renflexis Cimzia Simponi Orencia Rituxan Actemra Kevzara Xeljanz Olumiant Rinvoq
		 
*****************************************************************
*					Insert FIGURES: 
*			   Figure 5 & 6. into Word Report (5-2-19 updated, separate into 2 pages)
*					PUTDOCX COMMANDS
*****************************************************************

*putdocx begin , land margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5)
putdocx sectionbreak, land margin(left,0.5) margin(right,0.5) margin(top,0.5) margin(bottom,0.5)

**insert title for Figure 5.
putdocx paragraph, style(Heading2) halign(center) 
putdocx text ("Figure 5a. Distribution of Reasons for Discontinuation"), linebreak bold font("Calibri Light","13", darkorange)
putdocx text ("by Product in last 12 Months ($fig3lbl)") , bold font("Calibri Light","13", darkorange)

putdocx paragraph, font(Calibri,9) halign(center)
putdocx image fig5a.png, width(8.5 in) height(4.3in) 

**insert table after Fig5. 
putdocx table tbl6 = matrix(t6), rownames colnames width(8.5in) halign(center)  border(all,single) layout(autofitc)
putdocx table tbl6(1/5,1/15), font(Calibri,10)	/* changed to 16 for 2 more bs*/
putdocx table tbl6(2/5,2/15), halign(center)  valign(center) 

putdocx pagebreak

putdocx paragraph, style(Heading2) halign(center) 
/*	10-25-19 changed from Proportion to Percentage	*/
putdocx text ("Figure 5b. Percentage of Reasons for Discontinuation"), linebreak bold font("Calibri Light","13", darkorange)
putdocx text ("by Product in last 12 Months ($fig3lbl)") , bold font("Calibri Light","13", darkorange)
putdocx paragraph, font(Calibri,9) halign(center)
* putdocx paragraph, font(Calibri,9) halign(center)
putdocx image fig5b.png, width(8.5in) height(3.8in) 
putdocx paragraph, font(Calibri,10) halign(left)
putdocx text ("Note: "), bold
// 2025-02-05 change to versions 6-15
putdocx text ("Data shown on reasons for discontinuation were collected under versions 6-15 of the data collection forms. In addition, we collapsed the reasons for discontinuation into 4 categories in the following manner:"), linebreak
// 4-30-2021 changed text according to DP's suggestions
putdocx text ("Safety reasons include (but are not limited to): "), underline
putdocx text ("major side effect, minor side effect, fear of future side effect;"), linebreak
putdocx text ("Efficacy reasons include (but are not limited to): "), underline
putdocx text ("inadequate initial response, failure to maintain initial response;"), linebreak
putdocx text ("Cost/Insurance: "), underline
putdocx text ("includes lack of insurance;"), linebreak
putdocx text ("Other reasons include (but are not limited to): "), underline
putdocx text ("frequency/route of administration, subject preference.")

*putdocx save report_graphs.docx, replace 
******************************************
*			Saving Final Output
******************************************
  local D = c(current_date)
  local D = subinstr("`D'"," ","_",.)
 
*putdocx save figure5_test.docx, replace 

putdocx save RA_QR_body_`D'.docx, replace // version B for double checking after eliminate State=="NA"

// 2022-08-09 putdocx append will change the format of the report body. Use word From the Insert tab, Text group, click on the down arrow next to Object and choose Text from file.

*putdocx append coverpage_2021-12-28 RA_QR__8_Dec_2021_no_cover, pagebreak headsrc(own) saving(RA_QR_2021Q3_test, replace)

// the orange line on cover page disappears, error message in word, need to fix the disappeared borders of tables 



*putdocx append coverpage_2022-05-09_logo_updated RA_QR_`D', pagebreak headsrc(last) saving(RA_QR_`D'_draft, replace) //

// the orange line on cover page remains, error message in word, need to fix the disappeared borders of tables and copy paste footer for the cover page 

//new header rule. 
*putdocx append coverpage_2021-12-30 RA_QR__8_Dec_2021_no_cover, pagebreak saving(RA_QR_2021Q3_test3, replace)
  *local T = c(current_time)
  *local T = subinstr("`T'",":","_",.)
// 10-13-20 prepared coverpage with footers, try to append with report body
// need to add date manually  
// putdocx append ra_qr_coverpage myreport, saving(RA_QR_try2, replace)
// re-created page without title and subtitle format==>looks good but does not work within the code. Run separately
// putdocx append coverpage_re-edit myreport, pagebreak saving(RA_QR, replace)

*erase state.dta
*erase temp.dta 
*matrix drop _all
*program drop _all
*macro drop _all


cap log close


