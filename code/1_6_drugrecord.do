/*
2025-02-17 LG found v15 drug_plan of "not applicable / drug not in use" confuses drug setup by adding more re-starts to drugs with complete history reported (1000+) and confuses the drug stop dates. Testing data by eliminating drug_plan of "not applicable / drug not in use" from raw data first and testing the current drug algorithm to see if the listed examples can be fixed. If not, consider modifying the drug algorithm.


2024-10-30 added more biosimilars to drug key, fixed errors for some drugtxt extractions

2024-08-12
use v20240801 data to test code revision 
changed line #927 and revise it in 2.1 data. It will cause some 1-day episodes for some drugs with start reported in drug plan. For example 100236829 simponi_aria started 1-12 and stopped 1-13.
  +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
  | study_ac~m   source_a~m   dw_event~m   subject_~r   report_d~e    visitdate   visit_in~n       drug_key    drug_plan   drug_ind~n   drug_sta~s   drug_sta~w    drug_date   drug_dat~w   drug_sta~e   drug_sto~e |
  |-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
  |         RA           TM           FU    100236829   2023-07-06   2022-01-13            1   simponi_aria            .            1     continue         stop   2022-01-12   2022-01-XX   2022-01-12            . |
  |         RA           TM           EN    100236829   2022-01-13   2022-01-13            1   simponi_aria   start drug            2         stop        start   2022-01-13   2022-01-13   2022-01-12   2022-01-13 |
  |         RA           TM           FU    100236829   2023-07-06   2023-07-06            2   simponi_aria   start drug            3        start        start   2023-07-06   2023-07-06   2023-07-06   2024-01-18 |
  +-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

2024-07-10
base views re-downloaded, v20240701z 
use information from dose_v7 if dose_value and dose_txt are missing 
 
2024-07-08 
base views re-downloaded, v20240701x 

2024-07-03
base views re-downloaded 

2024-07-02
1. drug dates that are too early needs to be cleaned 
2. two consecutive drugs on the same date and on the same month of the visitdate, the one with drug_status=stop needs to be imputed as visitdate-1 instead of visitdate. Example 101010781 reported 2016-12-20 stop date 2016-12-XX for humira and xeljanz started at the visit.

2024-06-03 
waiting for the 20240601 build. cleaning code by deleting unwanted lines and try to run all together
2024-04-17 
Added for cleaning as step B2: 
append rows for start date prior to visitdate, make sure drug status is continue at visit, if started prior to visit 

2024-04-05
ENG created v20240401 base views. update all analytic data 

2024-04-02
1. setup for 2024-03-31 data 
2. if c_effective_event date is missing, per Ying's email on 3/21/2024, use dofc c_event_created_date instead 
gen visitdate=date(visit_date, "YMD") 
replace visitdate=date(c_effective_event_date, "YMD") if visitdate==. & strpos(c_effective_event_date, "X")==0 
replace visitdate=dofc(c_event_created_date) if visitdate==. 
format visitdate %tdCCYY-NN-DD

2024-03-08
check subject on slide #14 for training #4, 001010113 orencia stop date from 2011-06-11 using v20240202 build to 2011-07-11 using v20240305 build 

2024-03-06
1. re-run v202400305 build 
2. during deduplication, whenever reason_1 and reason_2 are included, do the same for reason_1/2_category

2024-02-12 
1. added date cleaning for B3e 
2. using v20240202 build 
3. clean extra rows of coding 

2024-02-05
clean the drug dates, replace drug date to report date if drug date is >183 days from the report_date.
2024-01-31
re-testing ticket #543 
link visitdates for 1.6 data. If no visitdates can be linked,such as drug date starts later than the last visit, use the report date instead. 
2024-01-24
testing tickets 543, 547 and 548
2024-01-19
testing tickets #542 & 543, update 1_6_drugrecord data using v20240117 build 
 
2024-01-18 
fix drug date for C5, drug date reported across b/tsDMARDs and cDMARDs

2024-01-04 
drop freq_temp from 1_6 
2023-12-15 build 
entered ticket #542. for preTM DMARDs, typo for drug name was fixed for main code but not for the freetexts code. both Azufadine and Azufindine exists in drug values. ENG did not map for preTM CERTAIN, which caused preTM CERTAIN missing 391 drug_name values for Azulfidine. Manually fixed in this coding.

2023-12-12 
v20231208 build, testing tickets #517 and #519
2023-12-11 keep one row if multiple visitdates reported the same drug 
2023-12-08
using v20231201 build
2023-11-29
using v20231124 build
2023-11-20
using v20231117 build
2023-11-17
using v20231115 build 
2023-11-15
using v20231110 build
save as 1.6_RADrugRecord in folder \Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table
2023-11-07
use v20231103 build 
2023-11-06
use v20231027 build 

2023-10-24
use v20231020 build 

2023-10-19
use v20231013 build, 
test ticket #446 missing drug names for certain baseline data.==> resolved 

2023-10-18
use v20231006 build 

2023-09-19
use v20230915 build, 
test ticket #116 missing drug_date for preTM data==>previously requested by YS, but is not a ticket 

test tickets 

#225 "anakinra (Kineret)" was categorized as "anakinra (Kineret)" for preTM data and "biologics" for TM data
#226 reason_2 and reason_3 do not have any categorized indicators like reason_1_category

#241 there is no drug_plan_code corresponding to drug_plan value "Yes"
#242 missing visit_date for one TM patient

2023-09-18 
Use v20230908 build

2023-09-13
step A3 cleaned dose and freq freetxts, prepare to drop duplicated rows based on dose/freq value and unit, not including dose/freq txt.
Some dose_txt also have freq information, used dose_txt if freq_txt is missing; after cleaning, if freq_value_txt is the same as dose_value_txt then disgard.

2023-09-11
continue 

1. cleaning extra rows 
2. possibly extract numeric values from dose/freq_txt into dose/freq value field 

2023-09-05
using ODBC download v20230830

to create 1.6 cleaned drug records data and use it for calculated drug variables 
to create 2.1 radrugexpdetail

2023-08-28 continue working on cleaning

2023-08-30 continue cleaning using v20230825 build

*/

*cap log close
*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-10-01"

*log using temp\1_6_drugrecord_2024-10-30.log, append //replace  

use bv_raw\bv_drugs_of_interest, clear

groups full_version drug_plan, missing ab(16) sepby(full_version) // 2025-02-17 4,519 rows "not in use"

groups drug_plan drug_status, missing ab(16) sepby(drug_plan)

// no drug_name or drug_name_txt provided 
tab drug_name if drug_status=="continue" & drug_plan=="not applicable / drug not in use", m 
tab drug_name_txt if drug_status=="continue" & drug_plan=="not applicable / drug not in use", m 

// 2025-02-17 drop all drug plan of "not applicable" from raw data 
drop if drug_plan=="not applicable / drug not in use" 
// (4,159 observations deleted)

mdesc *, ab(32)

// drop data from test sites 
destring site_number, replace 
// 2024-04-04 confirmed that site 997 is also a testing site 
drop if site_number>=997 //v20240401: n=2,584; 2,567 for v20240306; 2,347 for v20240130 2,327 for v20231215; 2,310 for v20231115
sum site_number

// 2024-05-02 check drug date vs. most_recent_dose_date, if drug date is missing and most_recent_dose_date is available, then replace drug date with most_recent_dose_date;
*mdesc drug_date if most_recent_dose_date!=""
*br site_number full_version study source dw_event_type drug_name drug_name_txt drug_date most_recent_dose_date if drug_date=="" & most_recent_dose_date!=""

*list full_version study source dw_event_type site_number subject_number drug_name drug_name_txt drug_status c_effective_event drug_date most_recent_dose_date if drug_date=="" & most_recent_dose_date!="", noobs ab(16)

//2024-07-02  1 available to replace 
// 2024-11-01: n=3

replace drug_date=most_recent_dose_date if drug_date=="" & most_recent_dose_date!=""


// check missing both drug_name and drug_name_txt ==>RCC and PRETM TAE only 
// 2023-12-21 entered ticket #542. forgot to fix azulfidine for do "../clean_MDdmard_LG_2023-04-25.do" for preTM MDdmard 2023-11-22 data. ENG used both for RA but not for preTM CERTAIN.
// v20240117 ticket #542 closed 
*count if  drug_name=="" & drug_name_txt=="" & (dw_event_type=="EN"|dw_event_type=="FU") //v20240501: n=0; v20240401 n=3; v20240122, n=0 391

count if drug_name=="" & drug_name_txt==""  

// v20250113: 1,647; v20241203: 1,430; v20241201: 1,418; v2024-11-01: 1,383; v20240701z: 540 v20240601: n=441; v20240501: n=370; v20240331 n=296; v20240305 n=236 90 at v20240202 70 at v20240130 55 at v20231215 v20231201 3 at v20231110 55 at v20231103; 76 at v20231027 20 at v20231020 6 at v20231013 112==>v20231006 81,678

/*
groups route route_code, missing ab(16)

v20240701 same 
v20240501 
  +--------------------------------------------------------------+
  |                        route   route_code    Freq.   Percent |
  |--------------------------------------------------------------|
  |                                         .   867186     79.27 |
  | intramuscular (IM) injection          220      108      0.01 |
  |             intravenous (IV)          210    32856      3.00 |
  |    intravenous (IV) infusion          211     2315      0.21 |
  |   intravenous (IV) injection          212      330      0.03 |
  |--------------------------------------------------------------|
  |                    oral (PO)          100   149895     13.70 |
  |            subcutaneous (SC)          200    38033      3.48 |
  |  subcutaneous (SC) injection          201     3190      0.29 |
  +--------------------------------------------------------------+

//IV injection==>RCC only 
groups study source_acronym dw_event_type_acronym if route_code==212, sepby(study source)

//SC injection  ==>PRETM or RCC?
// checked preTM MDdmard data. for orencia extracted injection, it should be sc injection instead of IM injection 
groups study source_acronym dw_event_type_acronym if route_code==201 , sepby(study source)

//SC injection  
groups study source_acronym dw_event_type_acronym if route_code==200, sepby(study source)
*/

// No IM injection in preTM data 
tab route if strpos(source_acronym, "PRETM")
tab drug_name if route!=""

// preTM injection was coded as SC injection 
*br if route_code==201 & strpos(hdr_study_source_acronym, "PRETM")

////////////////////////////////////////////////////////////////////
// Step A.1. clean drug keys first before combining visits 
////////////////////////////////////////////////////////////////////

drop if drug_name=="" & drug_name_txt==""  

// v2024-11-01 1,383; v20240701z: 540; v20240331 n=296; 55 for v20231103 76 for v20231027 20 as of v20231020; 6 as of v20231013; ticket #446 resolved 


// 2024-03-06 drop 4 rows with c_effective_event missing, checked drug_date, also missing, ticket #558 
*drop if c_effective_event==""

gen drugkey ="" 

destring route_code, replace 

do "~\Corrona LLC\Biostat Data Files - RA\Setup\setup_code\ODBC\1_6_01_clean_drug_freetext_2024-11-12.do"


//////////////////////////////////////////////////////////////////////////////////////
// 		test route_code results 
//////////////////////////////////////////////////////////////////////////////////////
// go back to clean_drug code if errors are found 
// 1. check consistency of coding 
groups route route_code , missing ab(16)
tab drug_name_txt if route_code==220 & route=="" // GOLD injection is IM 

// 2. check if any txt is missed or wrongly coded
preserve 
keep if  route=="" & route_code!=.& drugkey!="simponi_aria"
list study source dw_event_type subject_number drugtxt drugkey route_code in 1/25, noobs ab(16)
restore 

*groups study source dw_event_type drugtxt drugkey route_code if route=="" & route_code!=., missing ab(16) sepby(drugkey)
*groups dw_event_type drugtxt drugkey route_code if route=="" & route_code!=. & strpos(dw_event_type,"TAE") , missing ab(16) sepby(drugkey)

//////////////////////////////////////////////////////////////////////////////////////
// 		test drugkey results 
//////////////////////////////////////////////////////////////////////////////////////

//	1. see if any drugtxt is left not coded ==> adding truxima 
// 2023-10-18 adding rinnvoq and rinoq 
groups othra nonra drugtxt if drugtxt!="" & drugkey=="", missing ab(16) sepby(othra nonra)

count if othra!="" & nonra!="" // expecting 0


//	2. check if drugkey conflicts with othra or nonra

tab drugkey if othra!="",m // expecting 0

groups drugkey othra drugtxt if othra!="",  ab(16) sepby(drugkey) 
/*
  +-----------------------------------------------+
  | drugkey     othra   drugtxt   Freq.   Percent |
  |-----------------------------------------------|
  |  invest   ocruvas   ocruvas       4    100.00 |
  +-----------------------------------------------+
*/

replace drugkey="" if othra!=""

tab drugkey if nonra!="",m // expecting 0

*groups drugkey drugtxt if drugkey=="other_ra"

//	3. check drugkey vs drugtxt where drugkey have values 

//	4. after checking, it is ok to change drug name based on drugkey, and drug_name already have a raw copy saved.
 
replace drugkey="other_ra" if othra!="" & drugkey=="" // & drug_name==""

replace drugkey="other_non_ra" if nonra!="" & drugkey=="" //& drug_name==""

mdesc drugkey 

// v20250113: 117; 2024-12-04: 103; 2024-11-01: n=101; 2024-10-01: 92; v20240701z: n=351; v20240501 n=235; v20240401 n=195; v20240331 n=200; 307 at v20240202; 303 at v20240130;291 at v20231215 build; 282 at v20231124 build; 276 at v20231110 build; 275 missing at v20231103 build;252 missing, cannot find any clue from txt 

//	5. list where drugkey has value and drug_name shows differently==> TM MD data entry errors; TAE does not have drug_name field  
groups drugkey drugtxt drug_name, missing ab(16) sepby(drugkey)


//////////////////////////////////////////////////////////////////////////////////////
//	STEP A.2. Add drugkey for othra and nonra, create updated drug_name
//////////////////////////////////////////////////////////////////////////////////////

groups drugkey drug_name drugtxt if drugkey=="", missing 

// still can find some drugs to add 2024-05-02 added humira bs: hadlima, will update for the next round.


// do not need this part : 1. TAE does not have drug_name value at all; 2. after testing, some drugs are entered into wrong drug names.
*local if drug_name=="" & drugkey!= "other_ra" 
// already kept original drug_name as drug_name_raw, safe to change/correct drug_name
// 2024-10-29 also replace drug_name_code 
replace drug_name= "abatacept (Orencia)" if drugkey== "orencia"  
replace drug_name= "adalimumab (Humira)" if drugkey== "humira"  
replace drug_name= "adalimumab-aacf (Idacio)" if drugkey== "idacio"  
replace drug_name= "adalimumab-adaz (Hyrimoz)" if drugkey== "hyrimoz"  
replace drug_name= "adalimumab-adbm (Cyltezo)" if drugkey== "cyltezo"  
replace drug_name= "adalimumab-aqvh (Yusimry)" if drugkey== "yusimry"  
replace drug_name= "adalimumab-atto (Amjevita)" if drugkey== "amjevita"  
replace drug_name= "adalimumab-bwwd (Hadlima)" if drugkey== "hadlima"  
replace drug_name= "adalimumab-fkjp (Hulio)" if drugkey== "hulio"  
replace drug_name= "adalimumab other" if drugkey== "humira_bs" 
 
replace drug_name= "anakinra (Kineret)" if drugkey== "kineret" 
replace drug_name= "azathioprine (Imuran)" if drugkey== "imuran" 
replace drug_name= "baricitinib (Olumiant)" if drugkey== "olumiant" 
replace drug_name= "certolizumab pegol (Cimzia)" if drugkey== "cimzia" 
replace drug_name= "cyclosporine (Neoral)" if drugkey== "cyclosporine"  
replace drug_name= "etanercept (Enbrel)" if drugkey== "enbrel" 
replace drug_name= "etanercept-szzs (Erelzi)" if drugkey== "erelzi" 
replace drug_name= "etanercept other" if drugkey== "enbrel_bs"  
replace drug_name= "golimumab (Simponi)" if drugkey== "simponi"  
replace drug_name= "golimumab (Simponi Aria)" if drugkey== "simponi_aria"  
replace drug_name= "hydroxychloroquine (Plaquenil)" if drugkey== "plaquenil" 

replace drug_name= "infliximab (Remicade)" if drugkey== "remicade" 
replace drug_name= "infliximab-abda (Renflexis)" if drugkey== "renflexis"  
replace drug_name= "infliximab-dyyb (Inflectra)" if drugkey== "inflectra" 
replace drug_name= "infliximab (Avsola)" if drugkey=="avsola" 
replace drug_name= "infliximab-qbtx (Ixifi)" if drugkey=="ixifi" 
replace drug_name= "infliximab other" if drugkey== "remicade_bs" 

replace drug_name= "rituximab (Rituxan)" if drugkey== "rituxan" 
replace drug_name= "rituximab (Truxima)" if drugkey== "truxima" 
replace drug_name= "rituximab (Ruxience)" if drugkey=="ruxience"  
replace drug_name= "rituximab (Riabni)" if drugkey=="riabni"  // 2024-10-30 LG added 
replace drug_name= "rituximab other" if drugkey== "rituxan_bs"  

replace drug_name= "sarilumab (Kevzara)" if drugkey== "kevzara" 
replace drug_name= "tocilizumab (Actemra)" if drugkey== "actemra"  
replace drug_name= "tofacitinib extended-release (Xeljanz XR)" if drugkey== "xeljanz_xr" 
replace drug_name= "tofacitinib (Xeljanz)" if drugkey== "xeljanz"  
replace drug_name= "upadacitinib (Rinvoq)" if drugkey== "rinvoq"  
replace drug_name= "leflunomide (Arava)" if drugkey== "arava"  
replace drug_name= "methotrexate (mtx)" if drugkey== "mtx" 
replace drug_name= "minocycline (Minocin)" if drugkey== "minocin"  
replace drug_name= "prednisone" if drugkey== "pred" 
replace drug_name= "methylprednisolone" if drugkey== "meth_pred" 
replace drug_name= "triamcinolone (Kenalog)" if drugkey== "kenalog" 
replace drug_name= "sirukumab" if drugkey== "sirukumab" 
replace drug_name= "auranofin (Ridaura)" if drugkey== "ridaura"  
replace drug_name= "Cuprimine" if drugkey== "cuprimine"  
replace drug_name= "sulfasalazine (Azulfidine)" if drugkey== "azulfidine"  
replace drug_name= "investigational agent" if drugkey== "invest"   
replace drug_name= "RA medication other (specify)" if drugkey=="other_ra" 
replace drug_name= "Non-RA medication other (specify)" if drugkey=="other_non_ra" 

clonevar drug_name_code_raw=drug_name_code
replace drug_name_code= 100 if drugkey== "orencia" 
replace drug_name_code= 110 if drugkey== "humira" 
replace drug_name_code= 122 if drugkey== "idacio" 
replace drug_name_code= 123 if drugkey== "hyrimoz" 
replace drug_name_code= 124 if drugkey== "cyltezo" 
replace drug_name_code= 126 if drugkey== "yusimry" 
replace drug_name_code= 121 if drugkey== "amjevita"
replace drug_name_code= 127 if drugkey== "hadlima" 
replace drug_name_code= 128 if drugkey== "hulio"
  
replace drug_name_code= 118 if drugkey== "humira_bs"  
replace drug_name_code= 130 if drugkey== "kineret" 
replace drug_name_code= 501 if drugkey== "imuran" 
replace drug_name_code= 320 if drugkey== "olumiant" 
replace drug_name_code= 140 if drugkey== "cimzia" 
replace drug_name_code= 511 if drugkey== "cyclosporine" 
replace drug_name_code= 150 if drugkey== "enbrel" 
replace drug_name_code= 161 if drugkey== "erelzi" 
replace drug_name_code= 158 if drugkey== "enbrel_bs"  
replace drug_name_code= 170 if drugkey== "simponi"  
replace drug_name_code= 171 if drugkey== "simponi_aria"  
replace drug_name_code= 520 if drugkey== "plaquenil" 

replace drug_name_code= 180 if drugkey== "remicade" 
replace drug_name_code= 191 if drugkey== "renflexis"  
replace drug_name_code= 193 if drugkey== "inflectra" 
replace drug_name_code= 192 if drugkey== "avsola" 
replace drug_name_code= 194 if drugkey== "ixifi" 
replace drug_name_code= 188 if drugkey== "remicade_bs" 

replace drug_name_code= 200 if drugkey== "rituxan" 
replace drug_name_code= 211 if drugkey== "truxima" 
replace drug_name_code= 212 if drugkey=="ruxience"  // 2024-10-29 LG added manually. No code for ruxience in raw bv_drugs_of_interest data.
replace drug_name_code= 213 if drugkey=="riabni"  	// 2024-10-30 LG added manually. No code for ruxience in raw bv_drugs_of_interest data.
replace drug_name_code= 201 if drugkey== "rituxan_bs"  

replace drug_name_code= 220 if drugkey== "kevzara" 
replace drug_name_code= 240 if drugkey== "actemra"  
replace drug_name_code= 301 if drugkey== "xeljanz_xr" 
replace drug_name_code= 300 if drugkey== "xeljanz"  
replace drug_name_code= 310 if drugkey== "rinvoq"  
replace drug_name_code= 530 if drugkey== "arava"  
replace drug_name_code= 540 if drugkey== "mtx" 
replace drug_name_code= 5111 if drugkey== "minocin"  // LG 2024-10-29 don't know why there are 4 digits 
replace drug_name_code= 730 if drugkey== "pred" 
replace drug_name_code= 731 if drugkey== "meth_pred" // LG added, no code in raw bv_drugs_of_interest data 
replace drug_name_code= 750 if drugkey== "kenalog" 
replace drug_name_code= 230 if drugkey== "sirukumab" 
replace drug_name_code= 580 if drugkey== "ridaura"  
replace drug_name_code= 570 if drugkey== "cuprimine"  
replace drug_name_code= 551 if drugkey== "azulfidine"  
replace drug_name_code= 980 if drugkey== "invest"   
replace drug_name_code= 990 if drugkey=="other_ra" 
replace drug_name_code= 99020 if drugkey=="other_non_ra" 


groups drugkey drug_name drug_name_raw drugtxt if drugkey=="" & drug_name!="", missing ab(16)

replace drug_name="" if drugkey=="" // 53 2024-12-04: 64

// 2023-09-21 also update drug_category
clonevar drug_category_code_raw=drug_category_code

destring drug_category_code, replace 

groups drug_category drug_category_code, missing ab(16)

/*
  +--------------------------------------------------------------------+
  |                drug_category   drug_category_~e    Freq.   Percent |
  |--------------------------------------------------------------------|
  |                                               .    56121      5.14 |
  |               JAK inhibitors                390    19473      1.78 |
  |                    biologics                250   333049     30.53 |
  |          conventional DMARDs                690   524657     48.09 |
  |              corticosteroids                710   133533     12.24 |
  |--------------------------------------------------------------------|
  | other drug class of interest                900    24126      2.21 |
  +--------------------------------------------------------------------+

*/

lab define drug_category_code 390 "JAK inhibitors"  250 "biologics" 690 "conventional DMARDs" 710 "corticosteroids" 900 "other drug class of interest", modify 
lab val drug_category_code drug_category_code

foreach x in xeljanz xeljanz_xr rinvoq olumiant {
    replace drug_category_code=390 if drugkey=="`x'" & drug_category_code!=390
}

foreach x in actemra  cimzia enbrel erelzi enbrel_bs humira idacio hyrimoz cyltezo yusimry amjevita hadlima hulio humira_bs kevzara kineret orencia remicade renflexis avsola inflectra ixifi remicade_bs  rituxan ruxience truxima riabni rituxan_bs simponi simponi_aria sirukumab{
    replace drug_category_code=250 if drugkey=="`x'" & drug_category_code!=250
}

// 2024-10-30 put cuprimine and ridaura as cDMARDs
foreach x in arava azulfidine cyclosporine imuran minocin mtx plaquenil cuprimine ridaura {
    replace drug_category_code=690 if drugkey=="`x'" & drug_category_code!=690
}

foreach x in pred kenalog meth_pred {
    replace drug_category_code=710 if drugkey=="`x'" & drug_category_code!=710
}

foreach x in invest other_ra{
    replace drug_category_code=900 if drugkey=="`x'" & drug_category_code!=900
}



groups drugkey drug_category_code, missing ab(16) sepby(drug_category_code)

replace drug_category_code=. if drugkey==""

////////////////////////////////////////////////////////////////////////////////////////
//	Step A.3. Create generic key 	
/////////////////////////////////////////////////////////////////////////////////////////
cap drop generic_key
gen generic_key=""
// 2024-10-29 added more biosimilars for humira 
replace generic_key="adalimumab" if inlist(drugkey,"humira", "amjevita", "idacio", "hyrimoz", "cyltezo", "yusimry", "hadlima", "hulio", "humira_bs")
replace generic_key="etanercept" if drugkey=="enbrel"|drugkey=="enbrel_bs"|drugkey=="erelzi"
replace generic_key="certolizumab_pegol" if drugkey=="cimzia" // 2023-12-27 use underline for easier creating hxX
replace generic_key="infliximab" if inlist(drugkey, "remicade","remicade_bs","inflectra","renflexis","avsola", "ixifi")
replace generic_key="golimumab" if drugkey=="simponi"|drugkey=="simponi_aria"
replace generic_key="abatacept" if drugkey=="orencia"
replace generic_key="tocilizumab" if drugkey=="actemra"
replace generic_key="rituximab" if inlist(drugkey,"rituxan","ruxience","truxima","riabni","rituxan_bs")
replace generic_key="sarilumab" if drugkey=="kevzara"
replace generic_key="tofacitinib" if drugkey=="xeljanz"|drugkey=="xeljanz_xr"
replace generic_key="baricitinib" if drugkey=="olumiant"
replace generic_key="upadacitinib" if drugkey=="rinvoq"
replace generic_key="anakinra" if drugkey=="kineret"
replace generic_key="sirukumab" if drugkey=="sirukumab"
// 2023-11-15 use cordisone for pred, meth_pred and kenalog 
replace generic_key="corticosteroids" if drug_category_code==710
// 2023-10-25 add csDMARDs and prednisone
replace generic_key=drugkey if drug_category_code==690|drug_category_code==900 & drugkey!="other_ra"


// drop nonRA data 
drop if drugkey=="other_non_ra"|drugkey=="" // v20240401: n=903; 851 at v20240305 build; 977 at v20231115 build; 972 at v20231103 build; 948

// 2024-03-06 
drop if generic_key=="" // drop other non-RA or other_ra // 3,247 rows dropped 

groups drug_category_code generic_key drugkey, missing ab(16) sepby(drug_category_code generic_key)

*save temp\drug_testing_2025-02-17\clean_bv_drugs_of_interest_drugkey, replace

compress 
save temp\clean_bv_drugs_of_interest_drugkey, replace 

////////////////////////////////////////////////////////////////////////////////////////
//	Step A.4. Extract numeric values from dose/freq_txt and fill into dose/freq values 	
/////////////////////////////////////////////////////////////////////////////////////////

// 2023-09-12 clean dose/freq using ying's code for TAE then de-duplicate drug rows.

*use clean_bv_drugs_of_interest_drugkey, clear 

// 2024-07-10 use drug_v7 if both dose_value and dose_txt are missing 
count if dose_value==. & dose_txt=="" & dose_v7!="" // 52,987
clonevar dose_txt_raw=dose_txt 
replace dose_txt=dose_v7 if dose_value==. & dose_txt=="" & dose_v7!=""


do "~\Corrona LLC\Biostat Data Files - RA\Setup\setup_code\ODBC\1_6_02_clean_dose_freq_txt_2024-02-05.do"
// 2024-07-10, if dose_txt is "q 8 wks", dose_value showing 8. Try to fix it next time.
// 2024-12-04 only fixed using hard coding 

for any 000000010: list subject_number c_effective_event_date drugkey drug_date drug_status dose_value dose_unit freq_value freq_unit_code dose_txt dose_txt_raw dose_v7 if subject_number=="X" & drugkey=="remicade" , noobs ab(16)

for any 000000010:  replace freq_value=8 if subject_number=="X" & drugkey=="remicade" & (dose_txt=="q 8 wks"|dose_v7=="q 8 wks")
for any 000000010:  replace freq_unit_code=930 if subject_number=="X" & drugkey=="remicade" & (dose_txt=="q 8 wks"|dose_v7=="q 8 wks")
for any 000000010:  replace dose_value=. if subject_number=="X" & drugkey=="remicade" & dose_value==8

*save temp\drug_testing_2025-02-17\clean_bv_drugs_of_interest_dosefreq, replace 

compress 
save temp\clean_bv_drugs_of_interest_dosefreq, replace 

// 2024-10-30 update: no missing values for drug_name_code after manually assignment; but some new drugs do not have codings in EDC yet.
 
mdesc drug_name drug_name_code

// test added route results 
groups route_code dose_txt freq_txt if dose_txt!=""|freq_txt!=""

// 2024-07-10 list examples sent to Ying 
for any 000000003: list subject_number c_effective_event_date drugkey drug_date drug_status dose_value dose_unit freq_value freq_unit dose_txt dose_txt_raw dose_v7 if subject_number=="X" & drugkey=="arava" & c_effective_event_date=="2009-07-14", noobs ab(16)

for any 000000008: list subject_number c_effective_event_date drugkey drug_date drug_status dose_value dose_unit freq_value freq_unit dose_txt dose_txt_raw dose_v7 if subject_number=="X" & drugkey=="humira" , noobs ab(16)

// 2024-07-10, if dose_txt is "q 8 wks", dose_value showing 8. Try to fix it next time.
for any 000000010: list subject_number c_effective_event_date drugkey drug_date drug_status dose_value dose_unit freq_value freq_unit dose_txt dose_txt_raw dose_v7 if subject_number=="X" & drugkey=="remicade" , noobs ab(16)

// list some examples ==> list after frequency is extracted.
preserve 
keep if dose_txt!="" & dose_value_raw==. & dose_value!=. & dose_unit_code!=.
list study source dw_event_type subject_number c_effective_event_date drugkey dose_value dose_unit_code dose_txt freq_value freq_unit_code freq_txt in 1/20, noobs ab(24)
restore 

// v20231201 build still open v20231124 build (started v20231117 build)ticket #519 missing dose_txt enbrel 50 mg Q 2 wk, extracted as 50.2 mg example: 
// v20231208 build ticket #519 closed 
*list study source dw_event_type subject_number c_effective_event_date drugkey dose_value* dose_unit_code dose_txt freq_value* freq_unit_code freq_txt if subject_number=="107010315" & c_effective_event_date=="2008-08-06", noobs ab(24)


mdesc drugkey drug_name, ab(32) // no missing 

*groups dw_event_type_acronym drugkey drug_name drug_name_raw drugtxt if drugkey!="" & drug_name=="", missing ab(16)
// none

/////////////////////////////////////////////////////////////////////////
//	Clean Drug steps 
//	Step B.1. Making date format consistent. 
////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////
*use clean_bv_drugs_of_interest_dosefreq, clear 

// v20231013 build, a mix of XX or UK  
clonevar drug_date_raw=drug_date

replace drug_date=substr(drug_date, 1,8) + "01" if substr(drug_date, -3, 3) =="-XX" & substr(drug_date, 6,2)!="XX" 
replace drug_date=substr(drug_date, 1,5) + "01-01"  if substr(drug_date, 6,5 )=="XX-XX"
// 2024-04-17 UK for RCC data  
replace drug_date=substr(drug_date, 1,8) + "01" if substr(drug_date, -3, 3) =="-UK" & substr(drug_date, 6,2)!="UK" 
replace drug_date=substr(drug_date, 1,5) + "01-01"  if substr(drug_date, 6,5 )=="UK-UK"
// 2024-04-17 temporarily replace UK to 01 
replace drug_date=substr(drug_date, 1,5) + "01" + substr(drug_date, 8,3) if substr(drug_date, 6,2 )=="UK"

gen date=date(drug_date, "YMD") 
*replace drugdate=date(d, "YMD") if drugdate==. & d!="" 
format date %tdCCYY-NN-DD 
drop drug_date 
rename date drug_date 

// 2024-07-02 check if the year of drug date is out of range 
gen drug_year=year(drug_date)
tab drug_year 

count if drug_year<. & (drug_year <1960|drug_year>2025) // 297
count if drug_year<1960 // 115 
*br subject_number dw_event_type c_effective_event_date c_event_created_date drug_date if drug_year<. & (drug_year <1960|drug_year>2024)
*br c_event_created_date
*br hdr_effective_event_date
// 2024-02-01 change to report_date, use visitdate when a MD/PT visit is linked to drug date  
// 2024-04-02, use created date for missing effective_event_date
gen report_date=date(c_effective_event_date, "YMD")
replace report_date=dofc(c_event_created_date) if report_date==. 
format report_date %tdCCYY-NN-DD  

mdesc report_date drug_date drug_date_raw

list subject_number drugkey report_date drug_date_raw if strpos(drug_date_raw, "-UK-"), noobs ab(16)
/*list examples*/
preserve 
keep if strpos(drug_date_raw, "XX")
list study source_acronym subject_number c_effective_event_date drug_date_raw drug_date in 1/5, noobs ab(16)
restore 

preserve 
keep if strpos(drug_date_raw, "XX-XX")
list study source_acronym subject_number c_effective_event_date drug_date_raw drug_date in 1/5, noobs ab(16)
restore 

groups drug_plan drug_plan_code, missing ab(16)
/*
2025-03-05 without "not applicable"
  +---------------------------------------------------------------------+
  |                       drug_plan   drug_plan_code    Freq.   Percent |
  |---------------------------------------------------------------------|
  |                                                .   736531     65.56 |
  | continue drug plan / no changes                5   290640     25.87 |
  |                     current use                6    14217      1.27 |
  |        modify dose or frequency                3    16937      1.51 |
  |                      start drug                1    34704      3.09 |
  |---------------------------------------------------------------------|
  |                       stop drug                2    29361      2.61 |
  |           stop drug temporarily                9     1096      0.10 |
  +---------------------------------------------------------------------+

  +----------------------------------------------------------------------+
  |                        drug_plan   drug_plan_code    Freq.   Percent |
  |----------------------------------------------------------------------|
  |                                                 .   724123     66.63 |
  |  continue drug plan / no changes                5   271884     25.02 |
  |                      current use                6    11640      1.07 |
  |         modify dose or frequency                3    15939      1.47 |
  | not applicable / drug not in use                8     1264      0.12 |
  |----------------------------------------------------------------------|
  |                       start drug                1    32955      3.03 |
  |                        stop drug                2    28737      2.64 |
  |            stop drug temporarily                9      210      0.02 |
  +----------------------------------------------------------------------+

*/

// updated 2024-02-02 by adding 8 & 9 
destring drug_plan_code, replace 

lab define drug_plan 1 "start drug" 2 "stop drug" 3 "modify dose or frequency"  5 "continue drug plan / no changes" 6 "current use" 8 "not applicable / drug not in use" 9 "stop drug temporarily", modify

lab val drug_plan_code drug_plan 
rename drug_plan drug_plan_raw
rename drug_plan_code drug_plan 
codebook drug_plan 
groups drug_plan drug_plan_raw drug_status, missing ab(16) 

/*
  +----------------------------------------------------------------------------------------------------+
  |                       drug_plan                     drug_plan_raw   drug_status    Freq.   Percent |
  |----------------------------------------------------------------------------------------------------|
  |                      start drug                        start drug         start    34950      3.10 |
  |                       stop drug                         stop drug          stop    29430      2.61 |
  |        modify dose or frequency          modify dose or frequency      continue    17049      1.51 |
  | continue drug plan / no changes   continue drug plan / no changes      continue   292523     25.95 |
  |                     current use                       current use      continue    14324      1.27 |
  |----------------------------------------------------------------------------------------------------|
  |           stop drug temporarily             stop drug temporarily         start      573      0.05 |
  |           stop drug temporarily             stop drug temporarily          stop      573      0.05 |
  |                               .                                        continue   254475     22.57 |
  |                               .                                           start   275460     24.43 |
  |                               .                                            stop   112090      9.94 |
  |----------------------------------------------------------------------------------------------------|
  |                               .                                         unknown    95980      8.51 |
  +----------------------------------------------------------------------------------------------------+
*/

groups study source dw_event_type if drug_plan==9, noobs ab(16) // RCC TAE 

groups study source dw_event_type if drug_plan==9 & drug_status=="start", noobs ab(16) 

*groups site_number study source dw_event_type if drug_plan==8, noobs ab(16)  

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step B.2.	Updated 4/17/2024, expand a continue row for start date prior to visitdate, with drug date same as the visitdate 
count if report_date>drug_date & drug_status=="start" & (dose_value<. | freq_value<.) & drug_plan==. & strpos(source, "RCC")==0 & inlist(dw_event_type_acronym,"EN","FU","RFU")
// 175,460==>v20240601 n=175,462 >> v20240701x: n=175,462;
expand 2 if report_date>drug_date & drug_status=="start" & (dose_value<. | freq_value<.) & drug_plan==. & strpos(source, "RCC")==0 & inlist(dw_event_type_acronym,"EN","FU","RFU"), gen(cont)
tab cont, m  

replace drug_date=report_date if cont==1 
replace drug_status="continue" if cont==1 

/* 2024-04-17 list the example 
sort subject_number report_date drug_date 
list subject_number report_date drug_date drug_date_raw drug_status drug_plan dose_value freq_value reason_1 cont if subject_number=="001010217" & strpos(drug_name, "Xelj"), sepby(report_date) noobs ab(16)
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step B.3.	If drug_date is missing, then use c_effective_event_date to fill in drug_date
// dw_event_type_acronym

groups study source_acronym  drug_plan drug_plan_raw if drug_date==. , missing noobs ab(20) sepby(study source) 
mdesc most_recent_dose_date if drug_date==.

groups study source_acronym  drug_plan drug_plan_raw , missing noobs ab(20) sepby(study source) 

// 2023-10-24 after discussion with Ying 
replace drug_date=report_date if drug_date==. // v20240701x: 10,978; v20240601: n=10,963; v20240401 n=10,888; v20240331 n=10,895; v20240130 (10,940 real changes made)(15,118 real changes made) & drug_plan_code<8  // 8-NA/Drug not in use
mdesc drug_date report_date

// v20231201 closed ticket #520 missing both drug_status and dose_status 
groups drug_status, missing ab(16)
/*
v2025-03-05 no "n/a" for drug status anymore 
  +-----------------------------------------+
  | drug_status    Freq.   Percent      %<= |
  |-----------------------------------------|
  |    continue   751586     57.86    57.86 |
  |       start   309763     23.85    81.71 |
  |        stop   141620     10.90    92.61 |
  |     unknown    95980      7.39   100.00 |
  +-----------------------------------------+

  +-----------------------------------------+
  | drug_status    Freq.   Percent      %<= |
  |-----------------------------------------|
  |    continue   727781     57.66    57.66 |
  |         n/a     1264      0.10    57.76 |
  |       start   300044     23.77    81.53 |
  |        stop   137143     10.87    92.40 |
  |     unknown    95980      7.60   100.00 |
  +-----------------------------------------+
*/

groups dose_status, missing ab(16)

/*
2025-03-05 no "n/a" for dose status either 
  +---------------------------------------------+
  |     dose_status    Freq.   Percent      %<= |
  |---------------------------------------------|
  | 2nd most recent     4842      0.37     0.37 |
  |          change    15541      1.20     1.57 |
  |        continue    24861      1.91     3.48 |
  |         current    82024      6.31     9.80 |
  |     most recent     8985      0.69    10.49 |
  |---------------------------------------------|
  |            past      129      0.01    10.50 |
  |           start   486900     37.48    47.98 |
  |            stop   143294     11.03    59.02 |
  |         unknown   532373     40.98   100.00 |
  +---------------------------------------------+

  +---------------------------------------------+
  |     dose_status    Freq.   Percent      %<= |
  |---------------------------------------------|
  | 2nd most recent     4842      0.38     0.38 |
  |          change    15529      1.23     1.61 |
  |        continue     6105      0.48     2.10 |
  |         current    82024      6.50     8.60 |
  |     most recent     8985      0.71     9.31 |
  |---------------------------------------------|
  |             n/a     1264      0.10     9.41 |
  |            past      129      0.01     9.42 |
  |           start   475950     37.71    47.13 |
  |            stop   137589     10.90    58.03 |
  |         unknown   529795     41.97   100.00 |
  +---------------------------------------------+
*/

// make drug_status and dose_status numerical
// 2024-02-02 updated by adding 8 "n/a"
lab define drug_status 1 start 2 continue 3 stop 8 "n/a" 9 unknown, modify
foreach x in drug_status {
	rename `x' `x'_raw
	encode `x'_raw, gen(`x') lab(`x')
	codebook `x'
	groups `x'_raw 	`x', missing ab(16)
}
// 2023-11-09 re-label dose status
lab define dose_status 1 start 2 "2nd most recent" 3 "most recent" 4 "current/continue" 5 change 6 stop 7 past 9 unknown 10 "n/a", modify
cap drop dose_status_combined
clonevar dose_status_combined=dose_status

replace dose_status_combined="current/continue" if dose_status=="continue"|dose_status=="current"
groups dose_status_combined dose_status, missing ab(16) 

foreach x in dose_status {
    rename `x' `x'_raw
	encode `x'_combined, gen(`x') lab(`x')
	codebook `x'
	groups `x'_raw 	`x', missing ab(16)
}

drop dose_status_combined

mdesc drug_date drug_plan

drop cont drugtxt othra nonra

compress 
save temp\clean_bv_drugs_of_interest_temp, replace 

*save temp\clean_bv_drugs_of_interest_temp_2024-10-30, replace 
*save temp\drug_testing_2025-02-17\clean_bv_drugs_of_interest_temp, replace
*cap erase temp\drug_testing_2025-02-17\clean_bv_drugs_of_interest_drugkey.dta
*use clean_bv_drugs_of_interest_temp, clear 

mdesc study_acronym source dw_event_type, ab(24)

cap erase temp\clean_bv_drugs_of_interest_drugkey.dta
///////////////////////////////////////////////////////////////////////////////////////
// STEP B3. Clean Drug date by adding events from 1.2 allvisits data, then link with MD/PT data  
////////////////////////////////////////////////////////////////////////////////////////


// 2024-02-02 link to MD visits here 
// 2024-02-12 use custom_table/2_3_keyvisitvars.dta instead of 1.2
// 2024-02-16 using updated 2.3 keyvisitvars data
// 2024-03-06 using updated 1_2_allvisits data 
// 2024-03-07 1_2_allvisits data updated 
/*
use clean_table\1_2_allvisits_2024-12-04.dta, clear
for any 000000000: list subject_number visitdate study_acronym source_acronym dw_event_type_acronym full_version if subject_number=="X", noobs ab(16)

mdesc visitdate // 1 missing, fixed  

// 2024-12-04 drop if visitdate is 12/30/2024

count if subject_number=="001020146" & visitdate==d(30dec2024)
list subject_number visitdate c_event_created_date c_event_last_modified_date if visitdate==d(30dec2024), noobs ab(16)

  +-----------------------------------------------------------------------+
  | subject_number    visitdate   c_event_created_~e   c_event_last_mod~e |
  |-----------------------------------------------------------------------|
  |      001020146   2024-12-30   01dec2024 19:34:42   01dec2024 20:08:31 |
  +-----------------------------------------------------------------------+


drop if subject_number=="001020146" & visitdate==d(30dec2024)
*list study_source dw_event_type site_number subject_number visitdate if visitdate==., noobs ab(24)

mdesc study_acronym source dw_event_type, ab(24) // v20240601 missing study_acronym, emailed YS
groups study_acronym source dw_event_type, missing ab(16) sepby(study_acronym) // no TAE 
*/
*format visitdate %tdCCYY-NN-DD  
*drop if visitdate==. // 2024-02-12 let Ying know 

use clean_table\1_2_allvisits_$datacut, clear
mdesc visitdate
keep subject_number visitdate //study_source dw_event_type
unique subject_number visitdate 
sort subject_number visitdate 

by subject_number: gen visit_indexn=_n 
by subject_number: gen visit_indexN=_N 

by subject_number: gen enroll_visit=visitdate[1]
by subject_number: gen last_visit=visitdate[_N]
by subject_number: gen prev_visit=visitdate[_n-1] // not using prev_visit yet, just in case will use it later. 
by subject_number: gen next_visit=visitdate[_n+1]

clonevar linked_visit=visitdate 

format linked_visit enroll_visit last_visit prev_visit next_visit %tdCCYY-NN-DD  
lab var visit_indexn "the order of visit dates"
lab var visit_indexN "the total number of visit dates"
lab var enroll_visit "enrollment visit date"
lab var last_visit "last visit date"
lab var prev_visit "previous visit date, if available"
lab var next_visit "next visit date, if available"
keep subject_number linked_visit visitdate visit_index* enroll_visit last_visit prev_visit next_visit
mdesc *

sort subject_number visitdate
 
save temp\allvisits_link_visit, replace 

*use temp\allvisits_link_visit, clear 
*list subject_number visitdate visit_indexn visit_indexN if subject_number=="000000000", noobs ab(16)


use temp\clean_bv_drugs_of_interest_temp, clear 

// 2025-03-05 clean report_date 
codebook report_date 
count if report_date>d($cutdate) // 199

gen created_date=dofc(c_event_created_date)
format created_date %tdCCYY-NN-DD
replace report_date=created_date if report_date>15+d($cutdate)
list subject_number report_date c_effective_event_date c_event_created_date c_event_last_modified_date if report_date>d($cutdate), noobs ab(16)
count if report_date>d($cutdate)
drop if report_date>d($cutdate)
// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"

*use temp\drug_testing_2025-02-17\clean_bv_drugs_of_interest_temp, clear 
// 2023-11-15, for typo of drug date, eg. 1020004 actemra 01aug2023 vs. visitdate 18aug2020, correct 
gen dif_date=drug_date-report_date 
sum dif_date 
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    dif_date |  1,059,690   -391.4473    5043.846    -693981     365133
*/

// check for all drug dates that reported after the report date 
cap drop drug_year 
gen drug_year=substr(drug_date_raw, 1,4)

tab drug_year 
replace drug_year="" if drug_year=="UNKN"
/*
2025-04-03
       UNKN |         13        0.00      100.00
*/
destring drug_year, replace 

sum drug_year 
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
   drug_year |  1,259,412    2012.846    13.71116        111       3012
*/

gen report_year=year(report_date)
sum report_year 

mdesc dif_date

tab report_year 
sum dif_date if drug_year<=2025, d
count if dif_date>0 

// v20241202: 3,094;v20240801: n=2,767; v20240701z: n=2,720; v20240601: n=2,654; v20240501: n=2,599; v20240331 n=2,563; 2,512 v20240305 1573, count again after all cleaning 

count if dif_date>183 

// v20241203: 553; v20240801: n=534; v20240701z: n=531; v20240601: n=524; v20240501: n=521; v20240331 n=520 518;387 needs to be replaced 

// list some examples for decision making 
/*
count if dif_date>365 & drug_year>2024 & drug_year<. // v20240601:n=182; v20240331 n=182; 188; 175 

tab drug_plan  if dif_date>365 & drug_year>2024,m 


                       drug_plan |      Freq.     Percent        Cum.
---------------------------------+-----------------------------------
                      start drug |          2        1.10        1.10
                       stop drug |          7        3.85        4.95
        modify dose or frequency |          2        1.10        6.04
                               . |        171       93.96      100.00
---------------------------------+-----------------------------------
                           Total |        182      100.00
*/

count if dif_date>183 & drug_year<=2025
 
// v20241202: 371; v20240801: n=352; v20240701z: n=349; v20240601:n=342; 339; 338; 336;199; 203

////////////////////////////////////////////////////////////////////////////////////////
// B3 Execution
////////////////////////////////////////////////////////////////////////////////////////

// B3a
drop if dif_date>0 & strpos(dw_event_type, "TAE") & drug_plan==. // v20240701: n=1,111; v20240601:n=1,104; v20240501: n=1,094; v20240306:1,092 v20240130 185; v20231208: 207; 184

// B3b
replace drug_date=report_date if drug_year>2025 // 182 2025-01-14 change to 2025

// 2024-07-02 
replace drug_date=report_date if drug_year<1960 // 113

// B3c
replace drug_date=report_date if drug_year<=2025 & drug_year<. & dif_date>183 & dif_date<. // 166==>170 2024-01-14 changed to 2025

// re-test distribution after B3a-c
cap drop dif_date
gen dif_date=drug_date-report_date 
sum dif_date 

/*
v20240701:
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
    dif_date |  1,269,281   -400.2391    1127.866     -19221        183
*/

/* list >6 month difference and later than the next visitdate
sort subject_number drug_date
for any 001020004: list study_source dw_event_type subject_number report_date drug_date drug_date_raw dif_date drugkey generic_key drug_plan if subject_number=="X" & drugkey=="actemra", noobs ab(16)
*/
*save clean_bv_drugs_of_interest_cleaned_dates_2024-04-17, replace 

*use ".\temp_data\clean_bv_drugs_of_interest_cleaned_dates_v20240202", clear
// after linked visit step 

clonevar visitdate=drug_date
codebook visitdate 
/*
list subject_number visitdate drug_date if visitdate==d(30dec2024), noobs ab(16)

  +------------------------------------------+
  | subject_number    visitdate    drug_date |
  |------------------------------------------|
  |      001020146   2024-12-30   2024-12-30 |
  |      001020146   2024-12-30   2024-12-30 |
  |      001020146   2024-12-30   2024-12-30 |
  +------------------------------------------+
*/
// 2024-12-04 drop 
*count if visitdate>d(31dec2024) //256
count if visitdate>d($cutdate)

drop if visitdate>d($cutdate)

// 2024-12-05 also check if there's visitdate beyond datacut 
/*list subject_number visitdate drug_date if visitdate>d(30nov2024), noobs ab(16)

  +------------------------------------------+
  | subject_number    visitdate    drug_date |
  |------------------------------------------|
  |      254010199   2024-12-02   2024-12-02 |
  |      254010199   2024-12-02   2024-12-02 |
  |      064011225   2024-12-02   2024-12-02 |
  |      064011225   2024-12-02   2024-12-02 |
  |      015001197   2024-12-02   2024-12-02 |
  |------------------------------------------|
  |      064010774   2024-12-02   2024-12-02 |
  |      064010774   2024-12-02   2024-12-02 |
  |      015010659   2024-12-02   2024-12-02 |
  |      607498423   2024-12-02   2024-12-02 |
  |      183473089   2024-12-02   2024-12-02 |
  |------------------------------------------|
  |      015010712   2024-12-02   2024-12-02 |
  +------------------------------------------+

drop if visitdate>d(30nov2024) // 11*/
// only merge with linked visit then add prev, next, enroll_visit and last_visit after linked_visit is filled in 
sort subject_number visitdate 

merge m:1 subject_number visitdate using temp\allvisits_link_visit, keepus(linked_visit) 

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       459,196
        from master                   426,395  (_merge==1)
        from using                     32,801  (_merge==2)

    matched                           875,715  (_merge==3)
    -----------------------------------------

*/

gsort subject_number -visitdate 
by subject_number: replace linked_visit=linked_visit[_n-1] if linked_visit==.

mdesc linked_visit if drug_date!=. //v20240701: n=1,801; v20240601:n=1,748; 1,681; 1,677; 1,622

unique subject_number if linked_visit==. & drug_date!=. // v20240501: n=1,681; v20240202 1,887; 1,546 1,577 


// replace using the most recent visitdate in allvisits if available 
sort subject_number visitdate
by subject_number: replace linked_visit=linked_visit[_n-1] if linked_visit==.

mdesc linked_visit // v20240801: 18; v20240701: 20 v20240202 18; 16; 


replace linked_visit=report_date if linked_visit==. // & dw_event_type=="EN" 


drop if _m==2
drop _m 
drop visitdate 

codebook drug_date // [01jun1960,31dec2024]
// after all link dates are not missing, merge with prev, next visit, etc.
merge m:1 subject_number linked_visit using temp\allvisits_link_visit, keepus(visit_index* enroll_visit last_visit prev_visit next_visit)

*list study_source dw_event_type subject_number linked_visit drugkey drug_date if _m==1, noobs ab(16) sepby(subject_number)

*for any 064010239 086030047 098319484 118040616 471081438 553086797 716084502 793234251: list study_source dw_event_type subject_number drugkey report_date drug_date linked_visit if subject_number=="X", noobs ab(16)

// if a drug record cannot be linked to any visits, not useful for analytic data 
drop if _m<3 
drop _m 

cap drop dif_date2
gen dif_date2=linked_visit-drug_date 
sum dif_date2, d 
lab var dif_date2 "linked_visit-drug_date"

/*
preserve 
keep if dif_date2>183 & drug_year<=2024  //& drug_date>next_visit& strpos(dw_event_type, "TAE")==0
list study_source dw_event_type subject_number report_date linked_visit drug_date drug_date_raw dif_date2 next_visit drugkey generic_key drug_plan in 1/5, noobs ab(16)
restore 
*/

sum dif_date2 if dif_date2<0, d // those without matching visitdate 

// reported drug prior to EN use, normal 
count if dif_date2<-183 & next_visit!=. // 0 

mdesc next_visit if dif_date2<-183 //100%

*for any 012030801 019200180: list study_source dw_event_type subject_number drugkey report_date drug_date linked_visit next_visit last_visit if subject_number=="X", noobs ab(16)


drop dif_date drug_year report_year

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////	2024-02-12 added B3e: if drug_date_raw has XX, and within the same month as linked_visit (day part is not 01), then use the linked_visit date 
/* example before: 
sort subject_number drug_date
for any 001010085: list study_source dw_event_type subject_number c_effective_event generic_key drugkey drug_plan drug_date drug_date_raw linked_visit dose_value dose_unit freq_value freq_unit if drugkey=="actemra" & subject_number=="X", noobs ab(8) sepby(generic_key)

count if strpos(drug_date_raw,"XX") & day(drug_date)==1 & year(drug_date)==year(linked_visit) & month(drug_date)==month(linked_visit) & day(linked_visit)!=1
// test 
preserve 
keep if strpos(drug_date_raw,"XX") & day(drug_date)==1 & year(drug_date)==year(linked_visit) & month(drug_date)==month(linked_visit) & day(linked_visit)!=1
list study_source dw_event_type subject_number c_effective_event generic_key drugkey drug_plan drug_date drug_date_raw linked_visit dose_value dose_unit freq_value freq_unit in 1/5, noobs ab(8) sepby(generic_key)
restore 
*/

////////////////////////////////
// B3e execution
// updated 2024-07-02: if drug status is "stop", then use linked_visit-1
// updated 2024-08-12: move this step to 2_1 for drug_indexN==1 only? 

*replace drug_date=linked_visit-1 if drug_status==3 & strpos(drug_date_raw,"XX") & day(drug_date)==1 & year(drug_date)==year(linked_visit) & month(drug_date)==month(linked_visit) & day(linked_visit)!=1
//drug_status!=3 & 

replace drug_date=linked_visit if strpos(drug_date_raw,"XX") & day(drug_date)==1 & year(drug_date)==year(linked_visit) & month(drug_date)==month(linked_visit) & day(linked_visit)!=1

// v20240801: n=68,374; v20240601: n=68,374; v20240331, n=68,367 (68,340 real changes made)(68,518 real changes made)

// 2024-07-02 check 101010781 from humira to xeljanz 
// 2024-08-12 re-check--for 101010781, humira stop date will be the same as xeljanz start date, which will cause issue for allinits data; but needs to be fixed later than here; for 100236829, the logic of simponi_aria start and stop within the same month is corrected.
*for any 101010781: list subject_number drugkey linked_visit visit_indexn drug_date drug_date_raw drug_status if subject_number=="X" & inlist(drugkey,"humira","xeljanz"), sepby(linked_visit) noobs ab(16)

*for any 100236829:list source dw_event_type subject_number drugkey report_date linked_visit visit_indexn drug_date drug_date_raw drug_plan drug_status if subject_number=="X" & drugkey=="simponi_aria", sepby(linked_visit) noobs ab(16)

// after 
*for any 001010085: list study_source dw_event_type subject_number c_effective_event generic_key drugkey drug_plan drug_date drug_date_raw linked_visit dose_value dose_unit freq_value if drugkey=="actemra" & subject_number=="X", noobs ab(8) sepby(generic_key)

*save 1_6_drugrecord_linked_visit, replace  

mdesc linked_visit visit_index* enroll_visit last_visit prev_visit next_visit


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Step C.1. combine rows when drug change dose==>drop start row;  

/// C1.1 if report start date with drug_plan=change dose, keep change dose row and use start date for change dose date 

// check drug_plan after any drug_status of 1(start)
// 2023-10-23 edc_group_ordinal changed to coll_group_ordinal

*use 1_6_drugrecord_linked_visit, clear

sort study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status 
by study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date: gen next_plan=drug_plan[2] if _n==1 & drug_status==1 
lab val next_plan drug_plan
tab next_plan

groups study source dw_event_type_acronym next_plan, ab(16) sepby(study source)


// limited by source and event type for step C1
// 2023-11-15 dose status change has changed to 5 from 2 
cap drop ck_extra_start 
sort study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status 
by study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date: gen ck_extra_start=1 if _n==1 & drug_status==1 & dose_status[2]==5 & drug_date_raw!=""
tab ck_extra_start // 21 

*list study source_acronym dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status if ck_extra_start==1, noobs ab(12) // all TM data 
// 20231110 only 1 case 
*list subject_number visitdate drugkey coll_group_ordinal drug_date_raw drug_status dose_status dose_value dose_unit reason_1 if subject_number=="254010086" & drugkey=="rituxan" & drug_date==d(01jun2022), noobs ab(24)

/* examples that can be found in EDC  
list subject_number report_date drugkey coll_group_ordinal drug_date_raw drug_status dose_status dose_value dose_unit reason_1 if subject_number=="001019016" & drugkey=="pred" & drug_date==d(01may2019), noobs ab(24)

list subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status dose_value dose_unit freq_value reason_1 if subject_number=="009010322" & drugkey=="enbrel" & drug_date==d(01mar2016), noobs ab(24)
// 2024-02-12 after cleaning at B3e, more cases appeared for C1
for any 896288782: list subject_number report_date linked_visit drugkey coll_group_ordinal drug_date drug_date_raw drug_status dose_status dose_value dose_unit freq_value reason_1 if subject_number=="X" & drugkey=="actemra" & drug_date==d(16dec2013), noobs ab(24)

groups study source_acronym dw_event_type_acronym if ck_extra_start==1, ab(16) // all TM data 
*/

///////////////////////////////	
// C1.1 Execution
drop if ck_extra_start==1 
drop ck_extra_start next_plan

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// C1.2, change plan is missing on both rows, same start and stop date, with stop dosage only; keep the stop row   

// C1.2 for non rituxan, drug plan is missing on both rows, Drop start row.
// stop dose is reported 
*list major_version study_source dw_event_type_acronym subject_number visitdate drugkey coll_group_ordinal drug_date drug_plan drug_status dose_status dose_value dose_unit_code freq_value freq_unit_code reason_1 if subject_number=="001010204" & visitdate==d(18feb2014), noobs ab(12) sepby(drugkey)

// 202311-15 dose status 6=stop 
cap drop ck_extra_start2 
sort study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status 
by study source dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date: gen ck_extra_start2=1 if _n==1 & drug_status==1 & dose_status[2]==6 & drug_date_raw!="" & study=="RA" & source=="TM" & drugkey!="rituxan" & drug_plan==.& drug_plan[2]==. & dose_value==.& freq_value==. & dose_unit_code==. & freq_unit_code==. & dose_txt=="" & freq_txt=="" & reason_1==reason_1[2]
tab ck_extra_start2 // v20240701: n=1,895; v20240331: n=2,068; v20240305:2,066; v20240202: n=2,081; v20240130: n=2078 v20231201:2,070 2,062

groups study source dw_event_type_acronym if ck_extra_start2==1 // RA TM only 

/*
v20240701: 
  +--------------------------------------------------+
  | study_~m   source~m   dw_eve~m   Freq.   Percent |
  |--------------------------------------------------|
  |       RA         TM         EN    1423     75.09 |
  |       RA         TM         FU     470     24.80 |
  |       RA         TM        RFU       2      0.11 |
  +--------------------------------------------------+
*/

////////////////////////////////////////////////////////
////	C1.2 Execution  
drop if ck_extra_start2==1
drop ck_extra_start2

////////////////////////////////////////////////////////////////////////////////////////////////////////////
* Step C2. PRETM extra data rows 
//////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// C2.1 if start date was reported the same as continue date, keep the start row, drop the continue row
// also limited by source and event 

cap drop ck_extra_cont
sort study source_acronym dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status
 
by study source_acronym dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date: gen ck_extra_cont=1 if _n==2 & drug_status==2 & drug_status[1]==1 &  drug_date_raw!=""

tab ck_extra_cont // v20240701: n=15,333; v20240601: n=15,288; 20240501:15,270; 2027-04-17: 15,257?? v20240331: n=77; v20240306: n=63; v20240130: n=32 v20231201 28 v20231103 29 v20231027: 22 v20231020 20; 8,720==>6 

groups study source_acronym dw_event_type_acronym if ck_extra_cont==1, ab(26) sepby(study source)

// not applicable to TM RA data, mostly preTM certain 
// 2024-04-17 increased to 15,257  
drop if ck_extra_cont==1 
drop ck_extra_cont

/////////////////////////////////////////////////////////////
///  C2.2 if drug_plan is modify dose, then eliminate the row with drug_status as continue and dose_status==unknown  

sort study source_acronym dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date drug_status dose_status
// 2023-11-15 dose status 5= change 9= unknown  
by study source_acronym dw_event_type_acronym subject_number report_date drugkey coll_group_ordinal drug_date: gen ck_extra_cont2=1 if _n==2 & drug_status==2 & drug_status[1]==2 & dose_status[1]==5 & dose_status==9 & drug_date_raw!=""

tab ck_extra_cont2 
// v20241202: 2; 1 as of v20241101  

//////////////////////////////////////////////////////////////
////////////////////////	C2.2	Execution 
drop if ck_extra_cont2==1 
drop ck_extra_cont2


////////////////////////////////////////////////////////////////////////////////////////
//	Step C.3. clean duplicated drug records across data sources 
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////////
//////////// C3.a Execution: drop duplicated drug rows 

// 2024-11-04 adding reason_1/3_code to the list of vars, so reason_i, reason_i_code, reason_i_category/code are consistent
cap drop dup_drug

duplicates drop subject_number report_date drugkey coll_group_ordinal drug_date drug_plan drug_status dose_status dose_value dose_unit dose_txt freq_value freq_unit freq_txt reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code, force 

//v20240113: n=10,756; v20240701z: n=9,634; v20240601: n=9,491; v20240331: n=9,167; v20240305: n=9,022; v20240202: n=5,916; v20231215: n=5,783; v20231201 n=5,821; v20231110 n=5,755; v20231027 n=5,650 v20231020 5,679; v20231013 569 v20230915 8,608


/////////////////////////////////////////////////////////////////////////////////////////
//////////// C3.b  drop similar drug rows

/////////////////////////////////////////////////////////////////////////////////////////
//////////// C3.b Execution: drop duplicated drug rows 
cap drop dup_drug2

duplicates drop subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value dose_unit_code freq_value freq_unit_code reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code, force 

// v20240701z: n=3,342; v20240601: n=3,338; v20240331: n=3,231; v20240305: n=3,227; v20231215: n=2,260; v20231201: n=2,253; v20231110: 2,285; v20231027: 2,172 v20231020:2,225; v20231013==> 460 v20230915: 3,069

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
* Step C3.c. Same drug date, dose, reason and no drug_plan: use later version 
* clean if multiple start rows with current dose on one visitdate -keep the last dose as current dose 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* check duplicates without drug_status and dose_status */

cap drop dup_drug3
duplicates tag subject_number report_date drugkey drug_date drug_plan dose_value dose_unit_code  freq_value freq_unit_code reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code, gen(dup_drug3)

tab dup_drug3 

// v20240701z: n=1,304; v20240601:n=1,292; v20210331: n=1,106; v20240305: n=1,086; v20240202: n=528; v20240130: n=514; v20231208: 538 v20231115: 530; v20231110: 528; v20231103 542; v20231027 526; v20231020: 522; v20231013: 518 up to 1;1,002


groups study source dw_event_type drug_plan if dup_drug3>0, missing ab(16)
// create order for dup_drug3
mdesc drug_plan if dup_drug3==1 // 99.6% missing==>95.11

destring full_version, replace 

cap drop dup_drug3_order
// 20240307: added drug_plan 
sort subject_number report_date drugkey drug_date drug_plan dose_value dose_unit_code freq_value freq_unit_code reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code full_version
by subject_number report_date drugkey drug_date drug_plan dose_value dose_unit_code freq_value freq_unit_code reason_1 reason_2 reason_3: gen dup_drug3_order=_n if dup_drug3==1
tab dup_drug3_order 

////////////////////////////////////
//	C3.c Execution

drop if dup_drug3_order==1
drop dup_drug3_order

drop dup_drug3

//////////////////////////////////////////////////////////////////////////////////////
//// C4.1  Example 1 only start and stop dates are reported and on the same day 
// get some examples then decide if cleaning is needed ==> start-stop pairs with same dosage information
// test without dose_unit_code and freq_unit_code
cap drop dup_drug4
duplicates tag subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code, gen(dup_drug4)

tab dup_drug4 

// v20231013 up to 2, check for next round 
/*
v20250113
  dup_drug4 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  1,261,786       99.93       99.93
          1 |        824        0.07      100.00
          2 |          6        0.00      100.00
------------+-----------------------------------
      Total |  1,262,616      100.00

v20240701:
  dup_drug4 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |  1,237,830       99.96       99.96
          1 |        546        0.04      100.00
          2 |          6        0.00      100.00
------------+-----------------------------------
      Total |  1,238,382      100.00
*/

///////////////////////////////////////////////////////////////////////
// C4.1 Execution part 1: for dup_drug4==2, use the first one 
drop if dup_drug4==2 & dose_unit_code==. // 4 

// use later version information as the main info 
sort subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code

by subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code: gen dup_drug4_order=_n if dup_drug4==1
tab dup_drug4_order // v20241202: 409; 273


save temp\1_6_temp, replace 

*save temp\drug_testing_2025-02-17\1_6_temp, replace 
/////////////////////////////////////////////////////////////////
// C4.1 Execution part 2: for dup_drug4==1, merge and update 
preserve 
keep if dup_drug4_order==1
*recast str60 drug_plan reason_1 reason_2 reason_3, force 
save temp\step4_for_update, replace 
restore 

// update missing field if later version have missing values 
drop if dup_drug4_order==1
unique subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code
duplicates list subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code

duplicates drop subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code, force 

merge 1:1 subject_number report_date drugkey drug_date drug_plan dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code reason_1_category_code reason_1_category reason_2_category reason_2_category_code reason_3_category reason_3_category_code using temp\step4_for_update, update

drop _m 
drop dup_drug4*


//////////////////////////////////////////////////////////////////////////////////////
//// C4.2  Same drug information with different reason codes, check how many 
// drop reason_1 reason_2 reason_3, add drug_status, because some dates are for start and some dates are for start and some are for stop 
cap drop dup_drug5
duplicates tag subject_number report_date drugkey drug_date drug_status drug_plan dose_value freq_value if reason_1!="", gen(dup_drug5)

tab dup_drug5 // 46

/////////////////////////////
//	C4.2 Execution

drop if dup_drug5==1 & subject_number=="152040488" & report_date==d(12may2020) & drugkey=="actemra" & drug_date==d(01dec2019) & drug_status==3 & reason_2==""

drop if reason_1=="temporary interruption (TI)" & subject_number=="152091013" & report_date==d(30may2023) & drugkey=="xeljanz_xr" & drug_date==d(01feb2023) & drug_status==3
replace reason_3="temporary interruption (TI)" if subject_number=="152091013" & report_date==d(30may2023) & drugkey=="xeljanz_xr" & drug_date==d(01feb2023) & drug_status==3 & reason_2!=""
replace reason_3_category="safety" if subject_number=="152091013" & report_date==d(30may2023) & drugkey=="xeljanz_xr" & drug_date==d(01feb2023) & drug_status==3 & reason_2!=""
replace reason_3_category_code=2 if subject_number=="152091013" & report_date==d(30may2023) & drugkey=="xeljanz_xr" & drug_date==d(01feb2023) & drug_status==3 & reason_2!=""

// generate dup_drug5 order, change the 1st one to reason_2, then merge update with most recent version 
cap drop dup_drug5_order 
sort subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value freq_value dup_drug5 
by subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value freq_value dup_drug5: gen dup_drug5_order=_n if dup_drug5==1 & reason_1!="" & reason_2==""
tab dup_drug5_order 

/* 
v20240130 v20231201 
dup_drug5_o |
       rder |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |         17       50.00       50.00
          2 |         17       50.00      100.00
------------+-----------------------------------
      Total |         34      100.00
*/
*list version study_source dw_event_type subject_id visitdate drugkey drug_date drug_plan drug_status dose_status dose_value dose_unit_code dose_txt  freq_value freq_txt reason_1 reason_2 if dup_drug5_order==3, noobs ab(12)

// before 
*list version study_source dw_event_type subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value dose_unit_code dose_txt  freq_value freq_txt reason_1 reason_2 if subject_number=="100555356" & report_date==d(30jul2020) & drugkey=="meth_pred" , noobs ab(12) sepby(drug_date)

unique subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value freq_value dup_drug5 if dup_drug5_order!=2

save temp\1_6_temp2, replace 

*save temp\drug_testing_2025-02-17\1_6_temp2, replace 
*use 1_6_temp2, clear

preserve 
keep if dup_drug5_order==2
drop reason_2 reason_2_code reason_2_category reason_2_category_code reason_3 reason_3_code reason_3_category reason_3_category_code
rename reason_1 reason_2 
rename reason_1_category reason_2_category
rename reason_1_category_code reason_2_category_code
save temp\dup_drug_5_2, replace 
restore 

drop if dup_drug5_order==2
duplicates drop subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value freq_value dup_drug5, force // 1
merge 1:1 subject_number report_date drugkey drug_date drug_plan drug_status dose_status dose_value freq_value dup_drug5 using temp\dup_drug_5_2, update 

drop _m 
drop dup_drug5*


//2024-11-04 manually fix the missing reason_code 
replace reason_2_code=100 if reason_2=="active disease" & reason_2_code==.
replace reason_2_code=170 if reason_2=="failure to maintain initial response (FR)" & reason_2_code==.
replace reason_2_code=180 if reason_2=="inadequate initial response (IR)" & reason_2_code==.
replace reason_2_code=260 if reason_2=="subject doing well (DW)" & reason_2_code==.

/*
  +------------------------------------------------------------------------------------------------------------------------+
  |                                  reason_2   reason_2_code   reason_2_category   reason_2_category_~e   Freq.   Percent |
  |------------------------------------------------------------------------------------------------------------------------|
  |                            active disease             100       effectiveness                      1     495     14.17 |
  |                            active disease               .       effectiveness                      1       1      0.03 |
  |           alternative mechanism of action             110       effectiveness                      1     134      3.84 |
  |                             disease flare             913       effectiveness                      1      41      1.17 |
  | failure to maintain initial response (FR)             170       effectiveness                      1    1061     30.37 |
  | failure to maintain initial response (FR)               .       effectiveness                      1       2      0.06 |
  |          inadequate initial response (IR)             180       effectiveness                      1     751     21.49 |
  |          inadequate initial response (IR)               .       effectiveness                      1       2      0.06 |
  |                          lack of efficacy             900       effectiveness                      1      55      1.57 |
  |                          no longer needed             920       effectiveness                      1      44      1.26 |
  |                   subject doing well (DW)             260       effectiveness                      1     906     25.93 |
  |                   subject doing well (DW)               .       effectiveness                      1       2      0.06 |
  +------------------------------------------------------------------------------------------------------------------------+
*/

replace reason_2_code=240 if reason_2=="minor side effect (ME)" & reason_2_code==.
replace reason_2_code=250 if reason_2=="serious side effect (SE)" & reason_2_code==.

/* 

  +--------------------------------------------------------------------------------------------------------------+
  |                        reason_2   reason_2_code   reason_2_category   reason_2_category_~e   Freq.   Percent |
  |--------------------------------------------------------------------------------------------------------------|
  |                   drug toxicity             910              safety                      2      96      3.55 |
  | fear of future side effect (FE)             230              safety                      2     917     33.89 |
  |                       infection             912              safety                      2       6      0.22 |
  |                      malignancy             911              safety                      2       2      0.07 |
  |          minor side effect (ME)             240              safety                      2    1349     49.85 |
  |          minor side effect (ME)               .              safety                      2       2      0.07 |
  |        serious side effect (SE)             250              safety                      2     142      5.25 |
  |        serious side effect (SE)               .              safety                      2       1      0.04 |
  |     temporary interruption (TI)             280              safety                      2     191      7.06 |
  +--------------------------------------------------------------------------------------------------------------+
*/

replace reason_2_code=160 if reason_2=="cost / co-pay / insurance (CP)" & reason_2_code==.
replace reason_2_code=190 if reason_2=="frequency of administration (FA)" & reason_2_code==.
replace reason_2_code=990 if reason_2=="other reason (OT)" & reason_2_code==.
replace reason_2_code=191 if reason_2=="route of administration (RA)" & reason_2_code==.
replace reason_2_code=270 if reason_2=="subject preference (PP)" & reason_2_code==.

/*
  +---------------------------------------------------------------------------------------------------------------+
  |                         reason_2   reason_2_code   reason_2_category   reason_2_category_~e   Freq.   Percent |
  |---------------------------------------------------------------------------------------------------------------|
  |   cost / co-pay / insurance (CP)             160               other                      9     408     11.38 |
  |   cost / co-pay / insurance (CP)               .               other                      9       1      0.03 |
  |            formulary restriction             162               other                      9       2      0.06 |
  | frequency of administration (FA)             190               other                      9      75      2.09 |
  | frequency of administration (FA)               .               other                      9       1      0.03 |
  |          improve compliance (IC)             200               other                      9      29      0.81 |
  |        improve tolerability (IT)             210               other                      9      43      1.20 |
  |                other reason (OT)             990               other                      9     491     13.70 |
  |                other reason (OT)               .               other                      9       3      0.08 |
  |                  peer suggestion             950               other                      9       1      0.03 |
  |             physician preference             940               other                      9     261      7.28 |
  |            recent journal report             930               other                      9       2      0.06 |
  |                   recent lecture             932               other                      9       2      0.06 |
  |     route of administration (RA)             191               other                      9      63      1.76 |
  |     route of administration (RA)               .               other                      9       1      0.03 |
  |          subject preference (PP)             270               other                      9    2198     61.33 |
  |          subject preference (PP)               .               other                      9       2      0.06 |
  |          withdrawn by FDA / Mfgr             960               other                      9       1      0.03 |
  +---------------------------------------------------------------------------------------------------------------+
  */
  
replace reason_3_code=280 if reason_3=="temporary interruption (TI)" & reason_3_code==.

  /*
  +--------------------------------------------------------------------------------------------------------------+
  |                        reason_3   reason_3_code   reason_3_category   reason_3_category_~e   Freq.   Percent |
  |--------------------------------------------------------------------------------------------------------------|
  |                   drug toxicity             910              safety                      2       4      1.75 |
  | fear of future side effect (FE)             230              safety                      2      78     34.21 |
  |          minor side effect (ME)             240              safety                      2     110     48.25 |
  |        serious side effect (SE)             250              safety                      2      18      7.89 |
  |     temporary interruption (TI)             280              safety                      2      17      7.46 |
  |     temporary interruption (TI)               .              safety                      2       1      0.44 |
  +--------------------------------------------------------------------------------------------------------------+
*/

//////////////////	C4.3 
// 2023-09-21 merge rows with reason and without reason, given other drug info are the same 

cap drop dup_drug6
duplicates tag subject_number report_date drugkey drug_date drug_status drug_plan dose_value freq_value, gen(dup_drug6)
tab dup_drug6 //40

groups study source dw_event_type if dup_drug6==1

sort subject_number report_date drugkey drug_date drug_status drug_plan dose_value freq_value
list study source dw_event_type subject_number report_date drugkey drug_date drug_status drug_plan dose_value freq_value reason_1 if dup_drug6==1, noobs ab(12) sepby(drug_date)

//////////////////////	C4.3 Execution
drop if dup_drug6==1 & reason_1==""
drop dup_drug6 

unique subject_number report_date drugkey drug_plan drug_date drug_status dose_value freq_value
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////	C 5 clean same drug date and drug status reported by different visits 
*use "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table/1_6_RADrugRecord.dta", clear
*save 1_6_tempC4, replace 

// 2024-01-18 update starts 
*use 1_6_tempC4, clear 
// 2023-12-12 save data in case not doing C5 

//////////////////	C5.1 if reported exactly the same drug date across different visits, keep one 
cap drop dup_drug7
duplicates tag subject_number drugkey drug_date drug_plan drug_status dose_status dose_value dose_unit_code  freq_value freq_unit_code reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code, gen(dup_drug7)

tab dup_drug7 // v20231201 : 9% of data 


/////////////////////////////////////////////////////
////////////////////////////////	C5.1	Execution

cap drop dup_drug7
duplicates drop subject_number drugkey drug_date drug_plan drug_status dose_status dose_value dose_unit_code  freq_value freq_unit_code reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code, force 

// v20240701z: n=68,971; v20240601: n=68,868; v20240331: n=68,660; v20240305: 68,571; v20240130: n=63,347 v20231215: n=62,867

//////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// C5.2 check same dose and freq value, different dose/freq/unit code 

duplicates tag subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code, gen(dup_drug8) 
tab dup_drug8 

////////////////////////////////////////////////
//////////////////	C5.2 Execution

cap drop dup_drug8
duplicates drop subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code, force 
//v20240701: n=1,241; v20240601:n=1,235; v20240331: n=1,214; v20240305: n=1,203; v20240202: n=1,071; v20240130: n=920; v20231215: n=903; 907

unique subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code // unique 
unique subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value


/////////////////////////////////////////////////////////
///////////// C5.3 keep later visitdate if all drugs same with different reasons reported at different visitdate 
cap drop dup_drug9
duplicates tag subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value, gen(dup_drug9) 
tab dup_drug9 


cap drop dup_drug9index*
sort subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value report_date 
by subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value : gen dup_drug9indexn=_n if dup_drug9>=1
by subject_number drugkey drug_date drug_plan drug_status dose_status dose_value freq_value : gen dup_drug9indexN=_N if dup_drug9>=1

///////////////////////////////////////////////////////////////////////
//////////////// Execution of C5.3 
drop if dup_drug9indexn<dup_drug9indexN  & dup_drug9>=1
//3,423==>3,403

drop dup_drug9* freq_temp

//2024-04-24 checking Zach's question, 2024-05-02 decided not to use exact date from other drugs if the drug date was imputed from visitdate already.
* for any 055010218: list version study_source dw_event_type subject_number report_date linked_visit generic_key drugkey drug_plan drug_date drug_date_raw visit_indexn if subject_number=="X" , noobs ab(12) sepby(linked_visit)


// to be consistent with generic_key 
rename drugkey drug_key 
// update _code variables 
groups drug_category_code drug_category_code_raw, missing ab(16)
rename drug_category drug_category_raw
rename drug_category_code drug_category

foreach x in dose_unit route freq_unit{
    *groups `x'_code `x', missing ab(16)
	rename `x' `x'_raw
	rename `x'_code `x'
}


drop dif_date2
cap drop ck_extra_start

cap drop parent_study_acronym parent_study_uid study_uid site_id dw_site_uid dw_subject_uid coll_drug_instance_uid coll_map_uid edc_event_ordinal coll_crf_ordinal coll_group_ordinal c_is_suppressed_not_seen x_is_test othra nonra coll_group_type_acronym edc_event_name_raw coll_crf_name_raw drugtxt

lab var drug_category		"drug category"
lab var drug_key		"drug short name"
lab var generic_key		"generic short name"
lab var drug_name		"drug name"
lab var drug_name_txt		"other drug name, specify"
lab var drug_date		"drug date"
lab var drug_plan		"drug changed plan today" //(V15: Drug plan decided at visit)
lab var drug_status		"drug status"
lab var dose_status		"dose status"
lab var dose_value		"dose value"
lab var dose_unit		"dose unit"
lab var dose_txt		"other drug dose specify"
lab var freq_value		"drug frequency" 
lab var freq_unit		"drug frequency unit"
lab var freq_txt		"other frequency specify"
lab var report_date "numeric format of c_effective_date (a drug can be reported multiple times and way later than the linked visit)"
lab var route	"drug route" 
lab var reason_1		"change reason 1 for drug plan decided at visit"
lab var reason_2		"change reason 2 for drug plan decided at visit"
lab var reason_3		"change reason 3 for drug plan decided at visit"
lab var steroid_high_dose_value		"steroid highest dose"
lab var steroid_low_dose_value		"steroid lowest dose"
lab var dose_patient		"patient reported dosage"
lab var dose_v7		"dosage reported at version 7" 
lab var first_dose_at_visit		"Was the first dose administered at the visit?"
lab var most_recent_dose_date		"date of last dose"
lab var at_visit		"represents a drug happening that occurred at the visit"
lab var discontinued_due_to_ae		"discontinued due to adverse event?"
lab var discontinued_due_to_preg		"discontinued due to pregnancy?"
lab var attributed_to_ae		"event attributed to drug?"
lab var tx_changes_due_to_ae		"did this event result in any of the changes to the medication?"
lab var reason_1_category		"category for reason 1"
lab var reason_2_category		"category for reason 2"
lab var reason_3_category		"category for reason 3"

lab var subject_number "subject ID"
lab var site_number	"site ID"
lab var c_effective_event_date	"date of office visit when drug use was reported by MD"
lab var dw_event_type_acronym	"form type" 
lab var full_version "form version"
lab var study "study (RA or CERTAIN)"
lab var source_acronym	"source (preTM, TM, or RCC)"
lab var c_provider_id "provider ID"
// 2025-02-05 var name change 
lab var c_dw_event_instance_key		"event instance UID"
lab var c_event_created_date	"created date"
lab var c_event_last_modified_date	"last modified date"

*save temp\1_6_drugrecord_test_2024-10-30, replace 
// 2024-08-12 checking revised imputation of drug dates
// original issue: in allinits data, adalimumab had stop date but humira did not have stop date. See if the stop date is fixed in 2.1 data. If the stop date is the same as on 2016-12-20 then 2.2 data should not have any problems?  
*for any 101010781: list subject_number drug_key linked_visit visit_indexn drug_date drug_date_raw drug_status if subject_number=="X" & inlist(drug_key,"humira","xeljanz"), sepby(linked_visit) noobs ab(16)
*for any 101010781: list subject_number generic_key linked_visit visit_indexn drug_date drug_date_raw drug_status if subject_number=="X" , sepby(linked_visit) noobs ab(16)
// humira stop and xeljanz start on the same date is ok for 1.6 and 2.1, but making issues for 2.2.
*use "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\2024-08-01\clean_table\1_6_drugrecord.dta", clear 

*for any 100236829:list source dw_event_type subject_number drug_key report_date linked_visit visit_indexn drug_date drug_date_raw drug_plan drug_status if subject_number=="X" & drug_key=="simponi_aria", sepby(linked_visit) noobs ab(16)

codebook linked_visit drug_date

compress 

*save temp\drug_testing_2025-02-17\1_6_drugrecord_$datacut, replace 
*corcf * using clean_table\1_6_drugrecord_$datacut, id(subject_number drug_key drug_date drug_plan drug_status dose_status dose_value freq_value reason_1 reason_2 reason_3 reason_1_code reason_2_code reason_3_code)
// 2025-02-20 try to fix when v15 both start/stop had no drug dates but reported different reason_1, avoid being de-duplicated for 2.1, 
*use temp\drug_testing_2025-02-17\1_6_drugrecord_$datacut, clear 
/*
for any RA-3-0013: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 reason_2 if subject_number=="X" & inlist(drug_key,"actemra","enbrel"), sepby(drug_key linked_visit) noobs ab(10)

count if full_version==15 & drug_date_raw=="" & drug_status_raw=="start" // 103
count if full_version==15 & drug_date_raw=="" & drug_status_raw=="stop" // 37, only find where stop were reported and there is a start prior to it 
count if full_version==15 & drug_date_raw=="" & drug_date==report_date & drug_status_raw=="stop" // 37, only find where stop were reported and there is a start prior to it 
*/
sort subject_number report_date drug_key drug_date drug_status
gen check_stp=. 
by subject_number report_date drug_key drug_date: replace check_stp=1 if full_version==15 & drug_date_raw=="" & drug_date_raw[_n-1]=="" & drug_status_raw=="stop" & drug_status_raw[_n-1]=="start" & reason_1!="" & reason_1[_n-1]!=""
tab check_stp // 29

// check other cases. 
list subject_number drug_key if check_stp==1, noobs clean
/*
    subject_n~r    drug_key  
    RA-100-0135         mtx  
	
    RA-257-0022   inflectra  
    RA-257-0022     orencia  
    RA-257-0022    remicade  
    RA-257-0022      rinvoq  
    RA-257-0022     simponi  
	
      RA-3-0012         mtx  
      RA-3-0012   plaquenil  
	  
      RA-3-0013     actemra  
      RA-3-0013      enbrel  
      RA-3-0013      humira  
      RA-3-0013     orencia  
      RA-3-0013      rinvoq  
      RA-3-0013     xeljanz  
	  
      RA-3-0018   plaquenil  
	  
      RA-3-0020       arava  
	  
      RA-3-0026     actemra  
      RA-3-0026         mtx  
      RA-3-0026     orencia  
      RA-3-0026    remicade  
      RA-3-0026     simponi  
      RA-3-0026     xeljanz  
	  
      RA-3-0030         mtx  
*/
for any RA-3-0013: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 check_stp if subject_number=="X" & inlist(drug_key,"actemra","enbrel","humira","orencia","rinvoq","xeljanz"), sepby(drug_key linked_visit) noobs ab(10)

for any RA-257-0022: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 check_stp if subject_number=="X" & inlist(drug_key,"inflectra","orencia","remicade","rinvoq","simponi"), sepby(drug_key linked_visit) noobs ab(10)


by subject_number report_date drug_key drug_date: replace drug_date=report_date-1 if full_version==15 & drug_date_raw=="" & drug_date_raw[_n+1]=="" & drug_status_raw[_n+1]=="stop" & drug_status_raw=="start" & reason_1!="" & reason_1[_n+1]!="" & check_stp[_n+1]==1

for any RA-3-0013: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 reason_2 if subject_number=="X" & inlist(drug_key,"actemra","enbrel","humira","orencia","rinvoq","xeljanz"), sepby(drug_key linked_visit) noobs ab(10)

for any RA-257-0022: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 reason_2 if subject_number=="X" & inlist(drug_key,"inflectra","orencia","remicade","rinvoq","simponi"), sepby(drug_key linked_visit) noobs ab(10)

cap drop check_stop 
*save temp\drug_testing_2025-02-17\1_6_drugrecord_$datacut, replace
// no change for this one with only 1 reason reported. 
*for any RA-100-0070: list subject_number linked_visit visit_indexn drug_key drug_date drug_date_raw drug_plan drug_status drug_status_raw dose_value freq_value reason_1 if subject_number=="X" & inlist(drug_key,"enbrel"), sepby(drug_key linked_visit) noobs ab(10)
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
*use clean_table\1_6_drugrecord_$datacut, clear
drop created_date check_stp
save clean_table\1_6_drugrecord_$datacut, replace 

mdesc drug_name_raw drug_name_code drug_name_txt drug_name
// drop extra data 1_6_temp2 clean_bv_drugs_of_interest_dose_freq clean_bv_drugs_of_interest_temp 

cap erase temp\1_6_temp.dta
cap erase temp\1_6_temp2.dta
cap erase temp\1_6_tempC4.dta
cap erase temp\1_6_drugrecord_linked_visit.dta 

cap log close
