******************************************************************************
** Code Name:allinf dataset
*Purpose:  generate an allinf tall dataset one row per event per subject
*Programmer: Bernice Gershenson/Nicole Foster
**Input Datasets:
*Final Datasets:
*
* Version#                Date                Description
*
* 1                   11/8/2022
******************************************************************************

/*
local month 05
local day 01
local year 2024
local currentdata 2024-05-01
local rawdata "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\"
local registrydata "~\Corrona LLC\Biostat Data Files - RA\monthly\\`year'\\`year'-`month'-`day'\bv_raw\"
*/



/*
di c(username)

if "`c(username)'" == "bgershenson" {
			*Registry Data download
			local sharepoint "~/Corrona LLC/Biostat Data Files - RA/"
			*Cdrive data
			local cdrive "C:\Users\`c(username)'\Documents\GitHub\RA"
		

			local srcdir "`sharepoint'/monthly/ODBC/dwh_db//`year'-`month'-day/"
			local data "`srcdir'/data"
			local code "`srcdir'/code"
			local output "`srcdir'/output"

			di "`srcdir'"
			di "`data'"
			di "`code'"
			di "`output'"
            }	

*/
**** bring in dataset -  

use "bv_raw\bv_infections", clear

label data "Provider-reported infections collected on Provider forms at Enrollment, Follow-up, and TAE events"
*bv_infections:Provider-reported infections collected on Provider forms at Enrollment, Follow-up, and TAE events
**1 row per infection. Will include TAE's [TAE_C19, TAE_INF, TAE_ZOS] that are confirmed or have no response on confirmation status.
*********************************************************************************




//Variable labels from the specs_view_definition

label variable dw_event_instance_uid "unique id of registry event instance"
label variable parent_study_acronym	"parent study: RA"
*label variable parent_study_uid	"parent study unique id (joining key)"
label variable study_acronym "Study"
label variable source_acronym "EDC source" 
*label variable study_uid "unique id (joining key) for study"
label variable site_number	"public site_number of site at visit"
label variable dw_site_uid	"unique id of site at visit"
label variable subject_number "public facing subject_number (string)"
label variable dw_subject_uid "subject unique id (joining key)"
label variable dw_event_type_acronym "registry event type"
label variable c_effective_event_date "If visit, date of visit or created date when visit date not entered. If TAE, date of event onset, then use date of follow-up visit at which TAE was reported, or created date when neither is entered. If exit, date of exit or created date when exit date not entered."
label variable c_provider_id "provider ID"
label variable full_version "concatenated major_version.minor_version to represent paper form version"
label variable coll_adverse_instance_uid "unique id of comor (or adverse) 'happening' instance"
label variable coll_map_uid	"unique id of 'mapping row'"
*label variable edc_event_name_raw "event label shown in EDC front-end UI"
*label variable edc_event_ordinal "occurrence number of event type in EDC"
label variable coll_crf_name_raw	"CRF or form label shown in EDC front-end UI"
label variable coll_crf_ordinal	"occurrence number of form type in EDC"
label variable coll_group_type_acronym	"EDC back-end group label"
label variable coll_group_ordinal "occurrence number of group type in EDC"
label variable confirm_tae "confirmation status of TAE as reported by site"
label variable confirm_tae_code	"Standardized codification of confirm_tae"
label variable reported_date "Date of Follow-up Visit at which TAE was reported"
label variable infection_type	"Type of infection"
label variable infection_type_code "Standardized codification of infection_type"
label variable infection_type_txt "Free-text entry of infection_type"
label variable onset_date "Date of onset"
label variable location_txt	"Free-text entry of location"
label variable targeted	"Indicates if the infection was a targeted event"
label variable serious	"Indicates if the infection met seriousness criteria"
label variable serious_code	"Standardized codification of serious"
label variable iv_antiinfectives "Indicates if the infection required use of IV anti-infectives"
label variable iv_antiinfectives_code "Standardized codification of iv_antiinfectives"
label variable infection_status	"Status/dormancy of infection (specifically for TB and hepatitis)"
label variable infection_status_code	"Standardized codification of infection_status"
label variable hepatitis_reactivation	"Indicates if this was a reactivation of prior hepatitis infection"
label variable hepatitis_reactivation_code "Standardized codification of hepatitis_reactivation"
label variable drug_attributed	"If the infection was attributable to specific drug use, please enter the drug code"
label variable pathogen_1 "Pathogen 1"
label variable pathogen_1_code "Standardized codification of pathogen_1"
label variable pathogen_txt "Free-text entry of pathogen"
label variable pathogen_txt_2 "Second free-text entry of pathogen (PRE-TM only)"
label variable pathogen_2 "Pathogen 2"
label variable pathogen_2_code	"Standardized codification of pathogen_2"
label variable pathogen_3 "Pathogen 3"
label variable pathogen_3_code "Standardized codification of pathogen_3"
label variable pathogen_4 "Pathogen 4"
label variable pathogen_4_code "Standardized codification of pathogen_4"
label variable pathogen_5 "Pathogen 5"
label variable pathogen_5_code "Standardized codification of pathogen_5"
label variable additional_pathogens "Indicates if more than 5 pathogens were entered in the EDC"


sort subject_number dw_event_instance_uid x_edc_event_ordinal dw_event_instance_uid onset_date c_effective_event_date

//Confirming all the variables are available at a download
*edc_event_name_raw rename to x_edc_event_name_raw edc_event_ordinal rename to x_edc_event_ordinal

local varlist dw_event_instance_uid study_acronym source_acronym site_number ///
subject_number dw_event_type_acronym c_effective_event_date c_provider_id full_version ///
 coll_crf_name_raw coll_crf_ordinal coll_group_type_acronym ///
coll_group_ordinal confirm_tae confirm_tae_code infection_type infection_type_code infection_type_txt onset_date location_txt targeted serious ///
serious_code iv_antiinfectives iv_antiinfectives_code infection_status hepatitis_reactivation hepatitis_reactivation_code drug_attributed ///
pathogen_1 pathogen_1_code pathogen_txt pathogen_txt_2 pathogen_2 pathogen_2_code pathogen_3 pathogen_4 ///
pathogen_4_code pathogen_5 pathogen_5_code additional_pathogens
foreach var in `varlist' {
   *capture noisily confirm variable `var', exact  
     di "`var' exists in bv_infections"
}

** remove test records



* confirm source, study and form 
* v20240530 EDC split study_source_acronym to study_acronym and source_acronym two variables 
*tab source_acronym study_acronym, m
tab dw_event_type_acronym , m
tab full_version, missing
list subject_number site_number full_version study_acronym source_acronym  infection_type onset_date if full_version=="", noobs ab(30)
replace full_version="15.0" if full_version=="" & source_acronym=="RCC" // Ying added one subject missing full version for RCC 

*** confirm # of sites reasonable 
distinct site_number 

*** confirm # distinct patients reasonable (duplicates)
distinct subject_number 


// Convert all string text to lower case
replace infection_type_txt=strtrim(strlower(infection_type_txt)) 
replace location_txt=strtrim(strlower(location_txt)) 
replace pathogen_txt=strtrim(strlower(pathogen_txt)) 


//Onset_date- ******should missing onset_date be dropped or should we replace with c_effective_event_date or one day prior to visitdate?*****
	// c_effective_event_date=tae_date, exit date, visitdate. If all those dates are missing then it is the audit date.

		//Confirm with Ying if this ok.
*groups onset_date, missing

	//replacing missing onset date for visitdate/c_effective_event_date. Atleast gives us some information
	
gen onset_year=strlower(substr(onset_date,1,4))
gen onset_month=strlower(substr(onset_date,6,2))
gen onset_day=strlower(substr(onset_date,9,2))

****************************************************************************************************************
**The following variables gives us a unique case count
sort subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym infection_type_code
quietly by subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym infection_type_code: gen event_instance_dup = cond(_N==1,1,_n)
//This gives us an order for the unique case
by subject_number: gen record_order=_n

*browse subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym infection_type_code event_instance_dup

tab event_instance_dup
*isid subject_number

list subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym infection_type_code if event_instance_dup>1 
*drop event_instance_dup

/*
//checking infection_type, infection_type_txt and infection_type_code
groups infection_type, missing
groups infection_type infection_type_txt

*browse infection_type infection_type_txt onset_date if infection_type==""

groups infection_type infection_type_code
groups infection_type_txt if infection_type==""
*/


********************************************************************************************************************************************************
/*Generating two rows of data for infection_type_txt that includes two or moew events for example "cellulitis and uti" "pneumonia, uti, sepsis"*/
********************************************************************************************************************************************************
*flag the cases
*generate flagpneumonia=1 if uti_pnenimoa
*generate separate datasets
*delete the row from the original data
*append the single row of data. 

*foreach x in joint_bursa cellulitis skinbs herpes otitis sinusitis uri bronchitis pneumonia tbactive tblatent ///
* covid gastro divert uti ostemye mening hiv hepb hepc viralhep pml sepsis other{
*}

foreach x in joint_bursa{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"joint bursa") > 0
} 

foreach x in cellulitis{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"cellulitis") > 0 
	replace x`x'=1 if strpos(lower(infection_type_txt),"cellulits") > 0
} 
foreach x in skinbs{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"skin abcess") > 0
} 
foreach x in herpes{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"herpes") > 0 |  strpos(lower(infection_type_txt),"herrpes zoster") > 0
} 
foreach x in otitis{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"otitis") > 0
} 
foreach x in sinusitis {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"sinusitis") > 0
} 
foreach x in uri{
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"uri") > 0
} 
foreach x in bronchitis {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"bronchitis") > 0
} 

foreach x in pneumonia {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"pneumonia") > 0
} 
foreach x in tbactive {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"tb active") ==1
} 
foreach x in tblatent {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"tb latent") ==1
} 
foreach x in covid {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"covid") > 0
}
foreach x in gastro {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"gastro") > 0
}
foreach x in divert {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"divert") > 0
}
foreach x in uti {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"uti") > 0
} 

foreach x in osteomyelitis {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"osteomyelitis") > 0
} 
foreach x in mening {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"mening") > 0
} 
foreach x in hiv {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"hiv") > 0
} 
foreach x in hepb {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"hepb") > 0
} 
foreach x in hepc {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"hepc") > 0
} 
foreach x in viralhep {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"viralhep") > 0
}
foreach x in pml {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"pml") > 0
} 
foreach x in sepsis {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"sepsis") > 0
} 
foreach x in other {
    gen x`x'=. 
	replace x`x'=1 if strpos(lower(infection_type_txt),"other") > 0
	replace x`x'=1 if strpos(lower(infection_type_txt),"wound infection") > 0
} 


egen sum_events_across=rowtotal(xjoint_bursa xcellulitis xskinbs xherpes xotitis xsinusitis xuri xbronchitis xpneumonia xtbactive xtblatent xcovid xgastro xdivert xuti xosteomyelitis xmening xhiv xhepb xhepc xviralhep xpml xsepsis xother)
 tab sum_events_across
/*

sum_events_ |
     across |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     92,138       93.53       93.53
          1 |      6,291        6.39       99.92
          2 |         79        0.08      100.00
          3 |          4        0.00      100.00
------------+-----------------------------------
      Total |     98,512      100.00


sum_events_ |
     across |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     90,213       93.64       93.64
          1 |      6,056        6.29       99.93
          2 |         69        0.07      100.00--138--new rows
          3 |          2        0.00      100.00--6 new row of events
------------+-----------------------------------144 total
      Total |     96,340      100.00

*/
 *browse subject_number c_effective_event_date infection_type infection_type_txt sum_events_across x* if sum_events_across>1
 
save "temp\rawdata\infection_data_2.dta", replace
*use "temp\rawdata\infection_data_2.dta", clear

 
* Define a list of infection variables
local infections joint_bursa cellulitis skinbs herpes otitis sinusitis uri bronchitis pneumonia tbactive tblatent ///
                    covid gastro divert uti osteomyelitis mening hiv hepb hepc viralhep pml sepsis other

* Loop through each infection variable
foreach x in `infections' {
    preserve
    keep if sum_events_across>1 & x`x' == 1
    replace infection_type = ""
	replace infection_type_code=.
    replace infection_type_txt = "`x'"
    drop x*
    save "temp/rawdata/`x'.dta", replace
    restore
}

/*Bring in the old saved file**/

use "temp\rawdata\infection_data_2.dta", clear
drop if sum_events_across > 1
drop x*
count

save "temp\rawdata\infection_data_3.dta", replace
*use "temp\rawdata\infection_data_3.dta", clear
local sets joint_bursa cellulitis skinbs herpes otitis sinusitis uri bronchitis pneumonia tbactive tblatent ///
                    covid gastro divert uti osteomyelitis mening hiv hepb hepc viralhep pml sepsis other
foreach s of local sets {
append using "temp/rawdata/`s'.dta"
}

count

replace serious="yes" if infection_type=="infection other serious (specify)" // added 20240523

**ADDED 144 new rows
save "temp\rawdata\infection_data_4.dta", replace

*********************************************************************************************
*********************************************************************************************
//replacing infection_type with infection_type_txt information
use "temp\rawdata\infection_data_4.dta", clear
	//Joint/bursa
	foreach x in "joint bursa" "j bursa" {
replace infection_type="joint / bursa infection" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="joint / bursa infection" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19150 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19150 if infection_type=="joint / bursa infection"
}
	//Cellulitis
	foreach x in "cellulitis" "infection - cellulitis" "cellulitis on elbow" {
replace infection_type="cellulitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="cellulitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19070 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19070 if infection_type=="cellulitis"
}
	//Skin abcess
	foreach x in "skin abcess" "skin, sq abcess" {
replace infection_type="skin abscess" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="skin abscess" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19050 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19050 if infection_type=="skin abscess"
}
	
	//Herpes Zoster	
		foreach x in "herpes zoster"{
replace infection_type="Herpes zoster (specify location)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="Herpes zoster (specify location)" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19250 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19250 if infection_type=="Herpes zoster (specify location)"
}
	
	//Otitis (ear infection)
	foreach x in "otitis" {
replace infection_type="otitis (ear infection)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="otitis (ear infection)" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19180 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19180 if infection_type=="otitis (ear infection)"
}
	
	//Sinusitis
	foreach x in "sinusitis" {
replace infection_type="sinusitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="sinusitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19010 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19010 if infection_type=="sinusitis"
}
	//Upper respiratory infection
	foreach x in "upper respiratory infection" "uri" "acute upper respiratory infection" "cold and uri" {
replace infection_type="upper respiratory infection (URI)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="upper respiratory infection (URI)" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19230 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19230 if infection_type=="upper respiratory infection (URI)"
}	
	
	//Bronchitis
	foreach x in "bronchitis" "acute bronchitis" "acute bronchiolitis" {
replace infection_type="bronchitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="bronchitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19060 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19060 if infection_type=="bronchitis"
}

	//Pneumonia
	foreach x in "pneumonia" "infection,pneumonia" "infection-pneumonia" "walking pneumonia" {
replace infection_type="pneumonia" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="pneumonia" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19200 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19200 if infection_type=="pneumonia"
}

	//Tuberclosis-Active
		foreach x in "tb active" {
replace infection_type="tuberculosis (TB) active" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="tuberculosis (TB) active" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19023 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19023 if infection_type=="tuberculosis (TB) active"
}
	
	//Tuberculosis- Latent
			foreach x in "tb latent" {
replace infection_type="tuberculosis (TB) latent" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="tuberculosis (TB) latent" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19025 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19025 if infection_type=="tuberculosis (TB) latent"
}

//This code take care of cases pulled in from multiple events on one row
replace infection_type="COVID-19 (suspected)" if infection_type_code==19092 & infection_type_txt=="covid" & infection_type==""	
replace infection_type="COVID-19 (confirmed)" if infection_type_code==19091 & infection_type_txt=="covid" & infection_type==""	
	
	
*browse infection_type infection_type_txt if strpos(infection_type_txt, "covid")
	//COVID-19 Suspected
			foreach x in "covid suspected" "covid" "covid-19 (suspected)" "suspected non-serious covid-19" "suspected covid-19 infection" ///
		"suspected covid-19" "suspected covid 19 infection" "covid19" "covid-19" {
replace infection_type="COVID-19 (suspected)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19092 if infection_type_txt=="`x'" & infection_type_code==.
}	

	//COVID-19 Confirmed
				foreach x in "covid confirmed" "covid-19 (confirmed)" "covid  19 confirmed" "covid infection (confirmed)" "positive covid 19" ///
				"covid 19 non serious, confirmed" {
replace infection_type="COVID-19 (confirmed)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19091 if infection_type_txt=="`x'" & infection_type_code==.

}	


	//Gastroenteritis
				foreach x in "gastroenteritis" "viral gastroenteritis" "gastro" {
replace infection_type="gastroenteritis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="gastroenteritis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19110 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19110 if infection_type=="gastroenteritis"
}		
	
	//Diverticulitis
				foreach x in "diverticulitis" "diverticulitus" "divert" "diverticultitis" {
replace infection_type="diverticulitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="diverticulitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19100 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19100 if infection_type=="diverticulitis"
}		
	
	//Urinary Tract Infection
	
				foreach x in "urinary tract infection" "uti" "infection-uti" "uti infection" "urinary tract" ///
		"uti     mrsa" "uti & chronic kidney infection" "uti & mononucleosis 2004" "uti & shingles 2006 ha" "uti (2006 also)" ///
		"uti - c diff" "uti - recurrent" "uti - recurrent" "uti again" "uti and paronychia" "uti and pna" "uti and sputum culture positive for mssa" ///
		"uti infection" "uti while hospitalized for complications of diabet" "uti with hospital admission" "uti's" "uti, yeast, throat"{
replace infection_type="urinary tract infection (UTI)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="urinary tract infection (UTI)" if infection_type_txt=="`x'" & infection_type=="infection other (specify)"
replace infection_type="urinary tract infection (UTI)" if infection_type_txt=="`x'" & infection_type=="infection other serious (specify)"
replace infection_type_code=19240 if (infection_type_txt=="`x'" | location_txt=="`x'") & infection_type_code==.
replace infection_type_code=19240 if infection_type=="urinary tract infection (UTI)"

}
	
	//Osteomyelitis
						foreach x in "osteomyelitis" "osteomyelitis" "osteomyelitis rgt toe" {
replace infection_type="osteomyelitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="osteomyelitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19170 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19170 if infection_type=="osteomyelitis"
}
	
	//Meningitis/encephalitis
					foreach x in "meningitis" "encephalitis" "meningitis" "mening" {
replace infection_type="meningitis / encephalitis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="meningitis / encephalitis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19160 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19160 if infection_type=="meningitis / encephalitis"
}
	
	//HIV/AIDS
					foreach x in "hiv" {
replace infection_type="HIV / AIDS" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="HIV / AIDS" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19130 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19130 if infection_type=="HIV / AIDS"
}	
	
	//Hepatitis B- specify
						foreach x in "hepatitis B (specify)" {
replace infection_type="hepatitis B (specify)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19122 if infection_type_txt=="`x'" & infection_type_code==.
}

	//Hepatitis C- specify
						foreach x in "hepatitis C (specify)" {
replace infection_type="hepatitis C (specify)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19123 if infection_type_txt=="`x'" & infection_type_code==.
}	
	
	//Other viral Hepatitis
					foreach x in "hepatitis viral other (specify)" {
replace infection_type="hepatitis viral other (specify)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19129 if infection_type_txt=="`x'" & infection_type_code==.
}		
	
	
	//Progressive multifocal leukoencephalopathy (PML)
					foreach x in "pml" {
replace infection_type="progressive multifocal leukoencephalopathy (PML)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="progressive multifocal leukoencephalopathy (PML)" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19190 if infection_type_txt=="`x'" & infection_type_code==.
}	
	
	//Sepsis	
				foreach x in "sepsis" "sepsis secondary to acute pyelonephritis" "sepsis related to staph bursitis of the right olecranon" ///
				"sepsis rt knee" "sepsis secondary to acute pyelonephritis" "sepsis with dress syndrome" "sepsis with septic shock" {
replace infection_type="sepsis" if infection_type_txt=="`x'" & infection_type==""
replace infection_type="sepsis" if infection_type_txt=="`x'" & (infection_type=="infection other serious (specify)" | infection_type=="infection other (specify)")
replace infection_type_code=19220 if infection_type_txt=="`x'" & infection_type_code==.
replace infection_type_code=19220 if infection_type=="sepsis"
}	
	
	//infection other (specify)
foreach x in "other" "other (kidney)" "other-nose fungal" "toe infection" "infection" {
replace infection_type="infection other (specify)" if infection_type_txt=="`x'" & infection_type==""
replace infection_type_code=19900 if infection_type_txt=="`x'" & infection_type_code==.
}




//Updating infection_type to Covid

replace infection_type_txt="confirmed covid-19 infection" if strpos(infection_type_txt, "confirmed covid-19 infection")
replace infection_type_txt="covid-19 (confirmed)" if strpos(infection_type_txt, "covid-19 (confirmed)")


	//COVID-19 Suspected
			foreach x in "covid suspected" "covid" "covid-19 (suspected)" "suspected non-serious covid-19" "suspected covid-19 infection" ///
		"suspected covid-19" "suspected covid 19 infection" "covid19" "covid-19" "covid 19" "suspected covid 19" "covid (suspected)"  ///
		"covid-19 infection" "covid 19 (no hospitalization)" "covid-19 virus" "covid-19 confirmed non-serious." ///
		"covid 19 suspected" "covid_19" "covid19 (suspected)" "covid-19-suspected" "covid_19 suspected" "covid 10" "covid-19-suspected" ///
		"viral infection, unspecified (covid negative)" "unconfirmed covid" "covid 19 (suspected)" "covid-19 (suspected) (non-serious)" ///
		"covid19 (non-serious)" "covid q9" "covid-19/flu a" "covid-19 suspected" "covid -19 (suspected)" "sars covid" "covid 19 non serious,confirmed" ///
		"covid, yeast in groin and mouth" "covid19 suspected" "suspected non serious covid-19" "covid-19 (unspecified)" "flu & covid" "covid 16" ///
		"suspected non-serious covid 19" "covid-19 suspected" "non-serious covid-19" "covid 19 infection" "non-serious covid-19 (unspecified)" "non-serious covid-19" ///
		"non-serious covid 19 (unspecified)" "covid- 19 infection" "covid influenza" "covid-19 (suspected) non serious" "non-serious covid-19-suspected" ///
		"suspected non serious covid-9" "covid-19 (presumed)" "non- serious covid-19 symptoms (suspected)" "non-serious covid-19" ///
		"non-serious covid-19 symptoms (unspecified)" "empyema, covid" "covid-suspected" "covid19 indfection" "covid 19 non-serious" "covid & flu" ///
		"covid tx paxlovid" "covid 19/no symptoms" "covid19 infection" "covid-suspected" "suspected covid19" "covid- 19" "covid-19 (unconfirmed)" ///
		"covid-19 (omicron)" "covid 19/no symptoms" "covid -19" "covid19 infection" "covid -19" "covid-19 infection (unspecified)" "suspectedcovid-19" ///
		"covid-19 ( suspected)" "covid-19(suspected)" "covid-19-suspected with the pcr results" "covid-19 sars-cov-2" "covid-19 unconfirmed" ///
		"c0vid-19 (suspected)"{
replace infection_type="COVID-19 (suspected)" if infection_type_txt=="`x'" 
replace infection_type_code=19092 if infection_type_txt=="`x'"
}	

	//COVID-19 Confirmed
				foreach x in "covid confirmed" "covid-19 (confirmed)" "covid  19 confirmed" "covid infection (confirmed)" "positive covid 19" ///
				"covid 19 non serious, confirmed" "covid-19 confirmed" "covid 19 conf" "confirmed non-serious covid-19" "covid-19 confirmed" ///
				"covid 19 (confirmed)" "confirmed non serious covid-19" "covid 19 confirmed" "covid 19 confirmed home test" ///
				"covid-19 confirmed; also influenza a" "confirmed covid 19" "covid-confirmed x 2" "covid-19(confirmed)" "confirmed covid-19" ///
				"covid-19, confirmed" "covid 19 (confirmed, non serious)" "covid 19, confirmed" "covid-19 (confirmed" "covid-19 comfirmed" ///
				"covid-confirmed" "covid 19 confirmed with test" "covid confirmed non-serious" "covid-19 (conf)" "covid19 (confirmed)" ///
				"covid 19(confirmed, non serious)" "covid confirmed home test" "covid-19 infection (confirmed)" "covid19 confirmed" "covid 19 non serious (confirmed)" ///
				"covid 19-confirmed" "confirmed covid-19 infection non serious" "covid confirmed by home test" "covid-9 (confirmed)" ///
				"covid 19(confirmed)" "covid 19 confirmed non serious" "covid-19 confirmd" "confirm covid-19" "covid-19 (confirmed non serious)" ///
				"covid- 19 (confirmed)" "covid 19(non serious, confirmed)" "covid !9 confirmed" "covid-19 (confirmed) non-serious" "covid 19(confirmed,non serious)" ///
				"positive covid" "covid 19 positive confirmed" "covid 19 comfirmed non serious" "covid 19 comfirmed" "covid 19 confirmed w/paxlovid" ///
				"covid 19 confirmed posituve" "covid-19 (confirmed) non serious" "confirmed covid-19 infection" "confirmed covid-19 infection" "covid-19 confirmed (non serious )" ///
				"confirmed covid-19 infection" "covid-19, flu b" "confirmed covid-19 infection" "confirmed covid" "confirmed case of covid-19" "confirmed case of covid-19" ///
				"sars covid 19 infection confirmed serious" "covid-19 confirmed non serious" "confirmed covid-19 infection" "covid-19 confirmed non serious" "confirmed covid" ///
				"confirmed covid-19 infection" "covid 19 confirmed non serious." "confirmed covid-19 infection" "covid-19 confirmed non serious" "covid-19  confirmed non serious" ///
				"covid- 19 confirmed" "confirmed covid-19 infection" "covid-19 confirmed non-serious" "covid-19 confirmed non-serious" "covid 19 non serious confirmed" ///
				"confirmed covid-19 non serious" "covid 19 infection confirmed" "covid-19 non serious confirmed based on test" "covid 19 (confirmed) monoclonal antibody infusion" ///
				"covid 19 non serious,confirmed" "covid 19 confirmed by home test" "covid 19(confirmed)non serious" "covid19, confirmed" "positive covid-19" ///
				"+ covid-19" "covid-19 (confrirmed)" "covid comfirmed" "covid-19 (confirmed) asymptomatic" "covid/confirmed" "covid 19 confirmed, not serious" ///
				"covid 19 confirmed by hometest" "covid (confirmed)" "covid 19 confrimed" "covid-19 (confirmed) - positive home test" "covid-19 - confirmed" ///
				"covid-19 (cofirmed)" "covid_19 confirmed" "covid-19 positive" "covid-19 (confimed)" "non-serious covid-19 (confirmed)" "covid ( confirmed)" ///
				"salmonella & covid-19 (confirmed)" "covid (confirmed); also pharyngitis 04/2021" "confirmed serious covid 19" "covid 19 positive" "covid-19 (confirmed); also shingles 2020" ///
				"covid (confirmed)" "covid19 positive" "covid-19 (confiremd)" "covid 19 pt reported confirmed by test" "covid 19 (confirmed,non serious)" ///
				"covid -19 (confirmed)" "covid-19 (confirmed), influenza b (confirmed)" "positive covid -19" "covid-19 (confrimed)" "covid-19 (confrmed)" ///
				"covid(confirmed, non serious)" "positive covid testing" "covid 19 (confirmed) (non-serious)" "covid-19  (confirmed)" "tooth infection/covid 19 confirmed by home test" ///
				"covid positive (confirmed)" "covid-19 infection (confirmed) (non-serious)" "covid-19 (confirmed) and influenza b" "confirmed covid-18" "shortness of breath, + covid" ///
				"covid-19 (confirmed) / rsv" "flu & covid-19 (confirmed)" "covid 19  confirmed" "covid 19 (cofirmed)" "covid confirmed by home testing" ///
				"covid-19 confirmed, influenza-a" "covid 19(confirmed,non serious" "confirmed covid19" "covid 19 confirmed / non serious" "postive covid-19 (confirmed)" ///
				"covid - confirmed" "covid 19 - confirmed" "covid_19(confirmed)" "covid-19 infection confirmed" "covid-19 confirmed-" "covid-19 confirmed by pt" ///
				"covid 19 confirmed, treated in er" "covid-19 (confirmed) with acute hypoxic respiratory failure" "covid-19  confirmed" "covid19 infection confirmed" ///
				"covid-19 with acute hypoxic respiratory failure" "covid19 infection - confirmed" "confirmed covid 19 infection" "covid-19 (confirmed) (persistent covid-19 infection)" ///
				"covid-19 death" "serious covid-19 (confirmed)" "covid-19-confirmed" "covid-19 (confirmed)" "covid-19 (confirmed event)" "covid-19 (comfirmed)" ///
				"covid-19 requiring hospitalization" "covid-19 (confirmed event)" "covid-19 (comfirmed)" "covid-19 requiring hospitalization" "+covid-19 confirmed" ///
				"covid-19-confirmed" "covid 19 - confirmed" "covid-19 confirmed by pt" "confirmed covid19 infection" "covid 19 - confirmd" "covid 19 c0nfirmed" ///
				"covid-19 confirmed not serious" "covid-confirm" "covid confirmed non serious" "covid0-19 (confirmed)" "covid/ conf" "covid 19 c0nfirmed" ///
				"(confirmed) covid-19"{
replace infection_type="COVID-19 (confirmed)" if infection_type_txt=="`x'" 
replace infection_type_code=19091 if infection_type_txt=="`x'" 
}

*browse infection_type infection_type_txt if strpos(infection_type_txt, "covid")

*tab infection_type if strpos(infection_type_txt, "covid")

//Updating infection_type to latent and active
*browse infection_type infection_status if strpos(infection_type, "TB") 
	//Tuberclosis-Active
		foreach x in "tuberculosis (TB) (specify)" {
replace infection_type="tuberculosis (TB) active" if infection_type=="`x'" & infection_status=="active"
replace infection_type_code=19023 if infection_type=="`x'" & infection_status=="active"
		}
	//Tuberculosis- Latent
			foreach x in "tuberculosis (TB) (specify)" {
replace infection_type="tuberculosis (TB) latent" if infection_type=="`x'" & infection_status=="latent"
replace infection_type_code=19025 if infection_type=="`x'" & infection_status=="latent"
}


//Herpes Zoster

replace infection_type="herpes zoster" if infection_type=="infection other (specify)" & strpos(infection_type_txt, "herpes")
replace infection_type="herpes zoster" if infection_type=="infection other (specify)" & strpos(infection_type_txt, "shingles")
replace infection_type="herpes zoster" if infection_type=="infection other serious (specify)" & strpos(infection_type_txt, "herpes")
foreach x in "hsv" "shingles" "h.zoster" "chicken pox" "zoster" "h zoster (shingles" "h zoster" "h. zoster" "shingles h.zoster" ///
"zoster/shingles" "zoster infection" "diseminated ha zoster" "varicella zoster" "uti (herrpes zoster 2002 ha)" "zoster/face" ///
"zoster x 2 (1989 also)" "h.zoster/vzv" "h.zoster r  ue" "herpez zoster" "herps zoster" "h. zoster abd" "zoster eye" ///
"h-zoster" "disseminated herpes zoster" "zoster  (skin)" "h.zoster recurrent" "cutaneous hzoster, followed by zoster men. & encep" ///
"herpies zoster" "shingles/zoster" "hzoster rabd" "zoster lt eye" "zoster skin" "hzoster" "zoster rue/atypical," "h. zoster shingles" ///
"tio zoster" "zoster in eye" "zosters" "lyme disease 2003 (non-opp)/ zoster" "h. zoster - skin" "zoster outbreak" "h. zoster vzv" ///
"r leg zoster" "zoster of throat" "shingles/zoster" "zoster - skin" "disseminated zoster" "zoster of the eye" "h. zoster/vzv infection" "zoster of throat" ///
"h. simplex" "shigles" "shigles (l) side arm" "shingels" "shingle" "shingle right arm" "zoster" "zoter" "shingles" "shingles (requiring hospitalization)" ///
"shingles l-spine" "shingles left flank" "shingles on face" "shingles recurrence" "shingls" "shinhles" "shinlges" "shinles" "shingles" "herpes" {
replace infection_type="herpes zoster" if infection_type=="infection other (specify)" & infection_type_txt=="`x'"
replace infection_type="herpes zoster" if infection_type=="infection other serious (specify)" & infection_type_txt=="`x'"
replace infection_type_code=19250 if infection_type=="infection other (specify)" & infection_type_txt=="`x'"
replace infection_type_code=19250 if infection_type=="infection other serious (specify)" & infection_type_txt=="`x'"
}

//Edited: 07May2024-- Enrollment Herpes Zoster Case
replace infection_type="herpes zoster" if strpos(infection_type_txt, "herpes") & infection_type==""
replace infection_type_code=19250 if strpos(infection_type_txt, "herpes") & infection_type==""

*browse infection_type infection_type_txt if strpos(infection_type_txt, "zoster")>0
*browse infection_type infection_type_txt if strpos(infection_type_txt, "shingels") >0

******************************************************************************************
/*Replacing TAE infection_type_txt-- all TAE's should have a infection_type_code*/
***********************************************************************************************
replace infection_type="infection other (specify)" if infection_type=="" & dw_event_type_acronym=="TAE_INF" & infection_type_txt~=""
replace infection_type="infection other (specify)" if infection_type=="" & dw_event_type_acronym=="TAE_INF" & location_txt~=""
replace infection_type_code=19900 if infection_type=="" & dw_event_type_acronym=="TAE_INF" & infection_type_txt~=""
replace infection_type="infection other (specify)" if infection_type=="" & dw_event_type_acronym=="TAE_INF" & infection_type_txt~=""
replace infection_type="infection other (specify)" if infection_type=="" & dw_event_type_acronym=="TAE_INF" & location_txt~=""

tab infection_type, m

*browse if infection_type==""


//List of cases with no infection_type and non-missing infection_type_txt 
	//This should be sent to PV to categorize or delete from EDC
*browse subject_number onset_date infection_type dw_event_type_acronym infection_type_code infection_type_txt onset_date serious targeted ///
*full_version pathogen_1 if infection_type=="" & infection_type_txt~=""



//Recoding infection_type to Ying/Lin specification
replace infection_type=strtrim(strlower(infection_type))

gen infkey=infection_type
replace infkey="joint_bursa" if infection_type=="joint / bursa infection"
replace infkey="skin_abscess" if infection_type=="skin abscess"
replace infkey="hz" if infection_type=="herpes zoster"
replace infkey="hz_oth" if infection_type=="herpes zoster (specify location)"
replace infkey="otitis" if infection_type=="otitis (ear infection)"
replace infkey="uri" if infection_type=="upper respiratory infection (uri)"
replace infkey="bronch" if infection_type=="bronchitis"
replace infkey="pne" if infection_type=="pneumonia"
replace infkey="pne_pyo" if infection_type=="pneumonia pyogenic"
replace infkey="pne_non_pyo" if infection_type=="pneumonia non-pyogenic"
replace infkey="tb_active" if infection_type=="tuberculosis (tb) active (specify location)" | infection_type=="tuberculosis (tb) active"
replace infkey="tb_latent" if infection_type=="tuberculosis (tb) latent (specify location)" | infection_type=="tuberculosis (tb) latent"
replace infkey="tb_spec" if infection_type=="tuberculosis (tb) (specify)"
replace infkey="covid_suspected" if infection_type=="covid-19 (suspected)"
replace infkey="covid_confirm" if infection_type=="covid-19 (confirmed)"
replace infkey="gastro" if infection_type=="gastroenteritis"
replace infkey="div" if infection_type=="diverticulitis"
replace infkey="uti" if infection_type=="urinary tract infection (uti)"
replace infkey="mening" if infection_type=="meningitis / encephalitis"
replace infkey="hiv_aids" if infection_type=="hiv / aids"
replace infkey="hbv" if infection_type=="hepatitis b (specify)"
replace infkey="hcv" if infection_type=="hepatitis c (specify)"
replace infkey="hep_oth" if infection_type=="hepatitis viral other (specify)"
replace infkey="pml" if infection_type=="progressive multifocal leukoencephalopathy (PML)" | infection_type=="progressive multifocal leukoencephalopathy (pml)"
replace infkey="inf_oth_spec" if infection_type=="infection other (specify)"
replace infkey="inf_oth_spec" if infection_type=="infection other serious (specify)"


tab infkey infection_type, m

//infection_other_serious--
//TB(active or latent)-- update serious=1

*save "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\1_8_allinf.dta", replace
save "temp\rawdata\infection_data_5.dta", replace

******************************************************************
//No need to include dw_event_instance_uid-- we want to flag the same duplicate events every download
******************************************************************

*sort subject_number c_effective_event_date
*browse subject_number c_effective_event_date dw_event_type_acronym infection_type onset_date onset_year pathogen_1 location_txt pathogen_txt


******************************************************************
* 1. :  deduplicate by id, infection type, infection_type_txt, onset year, onset_month pathogen 1, location txt pathogen_txt
*dw_event_type_acronym==TAE_INF doesn't have pathogen code populated
******************************************************************

* Flaging duplicates between En/FU
//Dup- not a duplicate receives 0
	//Duplicates- receive 1, 2,3 numbers for subsquent duplicate observations
	
*tab dw_event_type_acronym, m	
*tab dw_event_type_acronym record_order, m

**************************************************
//Removing duplicates within En/FU visits*********
**************************************************
*local rawdata "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\"
*use "temp\rawdata\infection_data_5.dta", clear
gen visit=1 if dw_event_type_acronym=="EN" | dw_event_type_acronym=="FU" | dw_event_type_acronym=="RFU"
replace visit=0 if dw_event_type_acronym=="TAE_INF"
tab dw_event_type_acronym visit, m
preserve
keep if visit==1
save "temp\rawdata\1visits.dta", replace
restore
preserve
keep if visit==0
save "temp\rawdata\1tae.dta", replace
restore


use "temp\rawdata\1visits.dta", clear
bysort subject_number: generate enfirstfusecond=0 if dw_event_type_acronym=="EN"
bysort subject_number: replace enfirstfusecond=1 if dw_event_type_acronym~="EN"

sort subject_number infection_type_code infection_type_txt onset_year onset_month pathogen_1 location_txt pathogen_txt enfirstfusecond
by subject_number infection_type_code infection_type_txt onset_year onset_month pathogen_1 location_txt pathogen_txt : gen infevent_dup1 = cond(_N==1,0,_n)
by subject_number: gen conscount=1 if infevent_dup1<=1
//For each episode of duplicate cases with a subject- we get a distinct number
by subject_number: gen Count_conscount=sum(conscount)

*browse if infevent_dup1>0

local updatevar serious_code iv_antiinfectives_code hepatitis_reactivation_code confirm_tae_code ///
pathogen_1 serious iv_antiinfectives onset_date hepatitis_reactivation infection_status targeted infection_status confirm_tae
foreach v of local updatevar {
  sort subject_number Count_conscount infevent_dup1
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number Count_conscount miss_flag -c_effective_event_date 
  by subject_number Count_conscount: replace `v' = `v'[1] if infevent_dup1>0
  drop miss_flag
}


*browse if infevent_dup1>0
*tab infevent_dup1
drop conscount Count_conscount

keep if infevent_dup1<=1
count
save "temp\rawdata\1visits_nodup.dta", replace


********************************************
//Removing duplicates within the TAE data***
*********************************************

use "temp\rawdata\1tae.dta", clear

sort subject_number infection_type_code infection_type_txt onset_year onset_month pathogen_1 location_txt pathogen_txt onset_day
by subject_number infection_type_code infection_type_txt onset_year onset_month pathogen_1 location_txt pathogen_txt : gen infevent_dup1 = cond(_N==1,0,_n)
tab infevent_dup1, m
*browse if infevent_dup1>0
by subject_number: gen conscount=1 if infevent_dup1<=1
//For each episode of duplicate cases with a subject- we get a distinct number
by subject_number: gen Count_conscount=sum(conscount)

drop conscount Count_conscount
keep if infevent_dup1<=1
save "temp\rawdata\1tae_nodups.dta", replace

//Append the 1taes with deduplicates visits
use "temp\rawdata\1tae_nodups.dta", clear
append using "temp\rawdata\1visits_nodup.dta"
drop infevent_dup1 
save "temp\rawdata\infection_data_6.dta", replace


*******************************************************************
//Checking and removing duplicates within Enrollment and TAE data**
********************************************************************

use "temp\rawdata\infection_data_6.dta", clear
gen enrollandtae=.
replace enrollandtae=1 if dw_event_type_acronym=="EN"
replace enrollandtae=0 if dw_event_type_acronym=="TAE_INF"
tab dw_event_type_acronym enrollandtae, m

keep if enrollandtae==1 | enrollandtae==0
save "temp\rawdata\enrollandTAE.dta", replace
use "temp\rawdata\enrollandTAE.dta", clear
sort subject_number infection_type infection_type_txt onset_year onset_month
quietly by subject_number infection_type infection_type_txt onset_year onset_month:  gen infevent_dup2 = cond(_N==1,0,_n)
*browse if infevent_dup2>0
**These flagged cases are not duplicates
**Nothing is dropped



*********************************************************
//Removing duplicates within the TAE and FU visit data***
*********************************************************
use "temp\rawdata\infection_data_6.dta", clear
gen fuandtae=.
replace fuandtae=0 if dw_event_type_acronym=="FU" |  dw_event_type_acronym=="RFU"
replace fuandtae=1 if dw_event_type_acronym=="TAE_INF"
tab dw_event_type_acronym fuandtae, m
*save "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\infection_data_5.dta", replace
*use "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\infection_data_5.dta", clear
preserve 
keep if fuandtae==.
save "temp\rawdata\enrollonly.dta", replace 
restore

keep if fuandtae==1 | fuandtae==0
save "temp\rawdata\fuandTAE.dta", replace
use "temp\rawdata\fuandTAE.dta", clear
sort subject_number infection_type infection_type_txt onset_year onset_month fuandtae
quietly by subject_number infection_type infection_type_txt onset_year onset_month:  gen infevent_dup3 = cond(_N==1,0,_n)
*browse if infevent_dup3>0
tab infevent_dup3

by subject_number: gen conscount=1 if infevent_dup3<=1
//For each episode of duplicate cases with a subject- we get a distinct number
by subject_number: gen Count_conscount=sum(conscount)


*browse if infevent_dup3>0
//Edited: 07May2024
 //Removed: onset date
local updatevar serious_code iv_antiinfectives_code hepatitis_reactivation_code confirm_tae_code ///
pathogen_1 serious iv_antiinfectives hepatitis_reactivation infection_status targeted infection_status confirm_tae pathogen_2
foreach v of local updatevar {
  sort subject_number Count_conscount infevent_dup3
  gen miss_flag=0 if !missing(`v')
  replace miss_flag=1 if missing(`v')

  gsort subject_number Count_conscount miss_flag -c_effective_event_date 
  by subject_number Count_conscount: replace `v' = `v'[1] if infevent_dup3>0
  drop miss_flag
}
//Edited: 07May2024
bysort subject_number infection_type onset_year onset_month fuandtae: gen tae_date=onset_date if infevent_dup3>0 & dw_event_type_acronym=="TAE_INF"
sort subject_number infection_type onset_year fuandtae
by subject_number infection_type onset_year: replace tae_date=tae_date[_n+1] if tae_date==""
gen tae_day=strlower(substr(tae_date,9,2))
gsort subject_number infection_type onset_year onset_month 
by subject_number infection_type onset_year onset_month: replace onset_date = tae_date if infevent_dup3>0 & dw_event_type_acronym~="TAE_INF"	 
by subject_number infection_type onset_year onset_month: replace onset_day = tae_day if infevent_dup3>0 & dw_event_type_acronym~="TAE_INF"	

*browse subject_number infection_type onset_year onset_date onset_month onset_day pathogen_1 dw_event_type_acronym tae_date infevent_dup3 if subject_number=="001020416"


*browse if infevent_dup3>0
drop conscount Count_conscount
keep if infevent_dup3<=1
count
*60,250
save "temp\rawdata\fuandTAE_nodup.dta", replace

use "temp\rawdata\fuandTAE_nodup.dta", clear
append using "temp\rawdata\enrollonly.dta"
drop visit enfirstfusecond fuandtae infevent_dup3 

count
*90,076

drop event_instance_dup record_order sum_events_across
sort subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym infection_type_code
save "temp\rawdata\infection_data_7.dta", replace



///Update onset date
*local rawdata "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\Biostats PV\Bernice\data\"
use "temp\rawdata\infection_data_7.dta", clear

** bring in visit_date from fv_event_instances 
merge m:1 subject_number dw_event_instance_uid subject_number c_effective_event_date dw_event_instance_uid dw_event_type_acronym  using "bv_raw\fv_event_instances", keepusing(dw_event_instance_uid visit_date tae_date)
keep if _merge==3
drop _merge 

save "temp\rawdata\infection_data_8.dta", replace
use "temp\rawdata\infection_data_8.dta", clear


gen visit_date_formatted = date(visit_date, "YMD")
format visit_date_formatted %tdCCYY-NN-DD  


//Convert dates from string to numeric format

rename c_effective_event_date c_effective_event_date_orig
gen c_effective_event_date=date(c_effective_event_date_orig, "YMD") 
format c_effective_event_date %tdCCYY-NN-DD  

rename reported_date reported_date_orig
gen reported_date=date(reported_date_orig, "YMD") 
format reported_date %tdCCYY-NN-DD 

** use onset_date as imputed date if not missing
gen imp_onset_date = onset_date if !missing(onset_date)

** enrollment visit events: use visit_date - 1 day
gen enroll_minus1 = visit_date_formatted - 1 if dw_event_type_acronym=="EN"
format enroll_minus1 %tdCCYY-NN-DD

tostring enroll_minus1, g(enroll_minus1_full) format("%tdCCYY-NN-DD")force
replace imp_onset_date = enroll_minus1_full if missing(onset_date) & !missing(enroll_minus1_full) & dw_event_type_acronym=="EN"
** fu and tae events with non-missing visit_date - use visit_date 
replace imp_onset_date = visit_date if missing(onset_date) & !missing(visit_date) & dw_event_type_acronym!="EN"


** independent tae - use c_effective_event_date
replace imp_onset_date = c_effective_event_date_orig if missing(onset_date) & !missing(c_effective_event_date) & missing(visit_date) & dw_event_type_acronym=="TAE_INF"


** set flag for imputed onset_date 
gen imp_onset_date_flag = 1 if onset_date != imp_onset_date 

** create date-parts of imputed onset date (month, day, year)
gen imp_onset_year = strlower(substr(imp_onset_date,1,4))
gen imp_onset_month = strlower(substr(imp_onset_date,6,2))
gen imp_onset_day = strlower(substr(imp_onset_date,9,2))


*drop visit_date

recast str75 infection_type
recast str200 infection_type_txt
recast str100 pathogen_1
recast str100 pathogen_txt
format %75s infection_type
format %200s infection_type_txt
format %100s pathogen_1
format %100s pathogen_txt 

drop if site_number=="999" | site_number=="998" | site_number=="1440" |site_number=="1019" // test sites 

cap drop visitdate 
clonevar visitdate=c_effective_event_date 
replace visitdate=visit_date_formatted if c_effective_event_date!=visit_date_formatted & visit_date_formatted<. 

replace visitdate=dofc(c_event_created_date) if visitdate==.
assert visitdate<. 

des visit_date*
lab var visitdate "Date of office/event"  

*Ying added on 20240813 to clean duplicates 
sort subject_number visitdate infkey onset_date infection_type_txt confirm_tae_code serious_code targeted 
by subject_number visitdate infkey onset_date infection_type_txt: gen vN=_N 

list subject_number visitdate infkey onset_date infection_type_txt confirm_tae serious targeted if vN>1, noobs ab(20) 

by subject_number visitdate infkey onset_date infection_type_txt: drop if _n>1 
drop vN 

unique subject_number visitdate infkey onset_date infection_type_txt

save "clean_table\1_8_allinf.dta", replace

*****************************





/*

use clean_table\1_8_allinf.dta, clear


*save "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table\1_8_allinf.dta", replace
*use "~\Corrona LLC\Biostat Data Files - RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table\1_8_allinf.dta", clear


/*********************************************
*create data dictionary for all_inf data set
*********************************************/

*global dpath "~/Corrona LLC/Biostat Data Files - Biostat PV/AD/Eventfilecreation/PVSourced"
*use "$dpath/Data/clean//`curr_year'//`mon'/1_8_allinf.dta",clear

*cordd * using "$dpath/Data/clean//`curr_year'//`mon'/1_8_allinf `cutday'`cutmon'`cutyear'cut.xlsx") sheet("All infection vars", replace)



*eof

tab infkey infection_type, m
*90,994 
tab infkey, m
/*
        infkey |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                        |         78        0.09        0.09
                              arthritis |        172        0.19        0.27
                                 bronch |      9,052        9.95       10.22
                               bursitis |        243        0.27       10.49
                             cellulitis |      5,573        6.12       16.61
                          covid_confirm |      2,424        2.66       19.28
                        covid_suspected |      1,294        1.42       20.70
                                    div |      1,397        1.54       22.24
                                 gastro |      1,408        1.55       23.78
                                    hbv |          6        0.01       23.79
                                    hcv |         10        0.01       23.80
                                hep_oth |          3        0.00       23.80
                               hiv_aids |         11        0.01       23.82
                                     hz |      1,663        1.83       25.64
                                 hz_oth |        199        0.22       25.86
                           inf_oth_spec |     14,556       16.00       41.86
                            joint_bursa |      1,527        1.68       43.54
                                 mening |        170        0.19       43.72
                          osteomyelitis |        133        0.15       43.87
                                 otitis |         70        0.08       43.95
                                    pml |          5        0.01       43.95
                                    pne |     10,513       11.55       55.51
                            pne_non_pyo |      1,318        1.45       56.95
                                pne_pyo |      1,159        1.27       58.23
                                 sepsis |      1,562        1.72       59.94
                              sinusitis |     13,901       15.28       75.22
                           skin_abscess |         21        0.02       75.24
                              tb_active |         45        0.05       75.29
                              tb_latent |        237        0.26       75.55
                                tb_spec |         49        0.05       75.61
                                    uri |     12,008       13.20       88.80
                                    uti |     10,187       11.20      100.00
----------------------------------------+-----------------------------------
                                  Total |     90,994      100.00


*90,147
tab infkey, m
/*
                                 infkey |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                        |         78        0.09        0.09
                              arthritis |        172        0.19        0.28
                                 bronch |      8,981        9.96       10.24
                               bursitis |        243        0.27       10.51
                             cellulitis |      5,533        6.14       16.65
                          covid_confirm |      2,234        2.48       19.13
                        covid_suspected |      1,278        1.42       20.54
                                    div |      1,351        1.50       22.04
                                 gastro |      1,379        1.53       23.57
                                    hbv |          5        0.01       23.58
                                    hcv |          5        0.01       23.58
                                hep_oth |          3        0.00       23.59
                               hiv_aids |          3        0.00       23.59
                                 hz_oth |         12        0.01       23.60
                           inf_oth_spec |     17,585       19.51       43.11
                            joint_bursa |      1,520        1.69       44.80
                                 mening |        147        0.16       44.96
                          osteomyelitis |         14        0.02       44.97
                                 otitis |          9        0.01       44.98
                                    pml |          5        0.01       44.99
                                    pne |     10,429       11.57       56.56
                            pne_non_pyo |      1,318        1.46       58.02
                                pne_pyo |      1,159        1.29       59.31
                                 sepsis |      1,514        1.68       60.99
                              sinusitis |     13,785       15.29       76.28
                           skin_abscess |          6        0.01       76.28
                              tb_active |         40        0.04       76.33
                              tb_latent |        233        0.26       76.59
                                tb_spec |         49        0.05       76.64
                                    uri |     11,278       12.51       89.15
                                    uti |      9,779       10.85      100.00
----------------------------------------+-----------------------------------
                                  Total |     90,147      100.00
*/

*90,085
/*
tab infkey, m

                                 infkey |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                        |         78        0.09        0.09
                              arthritis |        172        0.19        0.28
                                 bronch |      8,982        9.97       10.25
                               bursitis |        243        0.27       10.52
                             cellulitis |      5,534        6.14       16.66
                          covid_confirm |      2,243        2.49       19.15
                        covid_suspected |      1,279        1.42       20.57
                                    div |      1,351        1.50       22.07
                                 gastro |      1,382        1.53       23.60
                                    hbv |          5        0.01       23.61
                                    hcv |          5        0.01       23.62
                                hep_oth |          3        0.00       23.62
                               hiv_aids |          3        0.00       23.62
                                     hz |      1,760        1.95       25.58
                                 hz_oth |         14        0.02       25.59
                           inf_oth_spec |     15,714       17.44       43.03
                            joint_bursa |      1,520        1.69       44.72
                                 mening |        147        0.16       44.89
                          osteomyelitis |         14        0.02       44.90
                                 otitis |         10        0.01       44.91
                                    pml |          5        0.01       44.92
                                    pne |     10,434       11.58       56.50
                            pne_non_pyo |      1,318        1.46       57.96
                                pne_pyo |      1,159        1.29       59.25
                                 sepsis |      1,519        1.69       60.94
                              sinusitis |     13,790       15.31       76.24
                           skin_abscess |          6        0.01       76.25
                              tb_active |         40        0.04       76.29
                              tb_latent |        233        0.26       76.55
                                tb_spec |         49        0.05       76.61
                                    uri |     11,285       12.53       89.13
                                    uti |      9,788       10.87      100.00
----------------------------------------+-----------------------------------
                                  Total |     90,085      100.00

*/
browse if infkey==""
*there is nothing in the infection_type_txt or any addtional information
