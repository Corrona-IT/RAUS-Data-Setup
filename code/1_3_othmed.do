/*
global bv "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\ODBC\dwh_db\2024-02-02" 
*global data "~\Corrona LLC\Biostat Data Files - Registry Data\RA\Data Warehouse Project 2020 - 2021\Analytic File\data\clean_table"

date: 2024-11-25 clean duplicates for cholesterol report by different version

*cd "~\Corrona LLC\Biostat Data Files - Registry Data\RA\monthly\Transition\analysis\allvisits" 
*/ 

use "bv_raw\bv_conmeds", clear 

drop if  strpos(dw_event_type_acronym, "TAE") | dw_event_type_acronym=="PREG" 
drop if conmed_name=="" & conmed_name_txt==""  
drop if conmed_name=="osteoporosis drug unknown" 

*drop if c_effective_event_date=="" 

/* to check dictionary vs data 
sort conmed_name full_version
by conmed_name full_version: gen drug1=1 if _n==1
list conmed_name full_version if drug1==1 & strpos(conmed_section, "CV"), noobs ab(20) clean
list conmed_name full_version conmed_section if drug1==1 & strpos(conmed_section, "analge"), noobs ab(20) clean
list conmed_name full_version conmed_section if drug1==1 & strpos(conmed_section, "otc"), noobs ab(20) clean
*/ 

tab dw_event_type_acronym conmed_section  if conmed_status=="continue" & conmed_date=="" 

replace conmed_date=c_effective_event_date if conmed_status=="continue" & conmed_date==""  // continue should consider as curret use, drug date is visitdate 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD 

// 2025-03-04 LG clean visitdate that could entered wrong in RCC
codebook visitdate 
tab dw_event_type_acronym if c_effective_event_date=="" 

* TAEs form can be missing c_effective_event_date 
for any created_date last_modified_date: gen X=dofc(c_event_X) 
for any created_date last_modified_date: format X %tdCCYY-NN-DD 
count if visitdate>d($cutdate)
replace visitdate=created_date if visitdate==. & created_date<. 
replace visitdate=created_date if visitdate>15+d($cutdate)


list subject_number visitdate c_effective_event_date c_event_created_date c_event_last_modified_date if visitdate>d($cutdate), noobs ab(16)


count if visitdate>d($cutdate)
for any 001040564: list subject_number visitdate c_effective_event_date c_event_created_date c_event_last_modified_date if subject_number=="X" & year(visitdate)==2025, noobs ab(16)

for any created_date last_modified_date: drop c_event_X 
for any created_date last_modified_date: rename X c_event_X 


 

replace conmed_status_code=99 if conmed_status_code==9 

destring site_number full_version, replace 

sort subject_number visitdate conmed_section conmed_name conmed_date conmed_status_code 
by subject_number visitdate conmed_section conmed_name conmed_date conmed_status_code : drop if _n>1 // clean duplicate conmed_name 

* preTM incorrect map to analgesics 
replace conmed_section="SU NSAIDs" if (conmed_name=="ibuprofen (Advil)" |  conmed_name=="naproxen (Aleve)" ) & conmed_section=="SU analgesics"  

gen drugkey="" 
*nsaids 
replace drugkey="nsaid_otc" if conmed_name=="NSAID over the counter other"
for any ibuprofen naproxen: replace drugkey = "nsaid_otc" if strpos(conmed_name, "X") 
replace drugkey="aspirin" if strpos(lower(conmed_name),"aspirin") 
replace drugkey="celebrex" if strpos(lower(conmed_name),"celebrex") 
replace drugkey="mobic" if strpos(lower(conmed_name), "mobic") 
replace drugkey="vioxx" if  strpos(lower(conmed_name),"vioxx") 
replace drugkey="bextra" if  strpos(lower(conmed_name),"bextra") 
replace drugkey="nsaid_invest" if conmed_name== "investigational agent" & strpos(conmed_section, "NSAID")
replace drugkey="nsaid_oth" if conmed_name== "NSAID other" 
replace drugkey="nsaid_pres_oth" if strpos(conmed_name, "NSAID prescription other") 
replace drugkey="nsaid_pres_top" if strpos(conmed_name, "NSAID prescription topical") 
replace drugkey="nsaid_pres_oth" if strpos(lower(conmed_name), "voltaren") 
replace drugkey="nsaid_pres_top" if strpos(lower(conmed_name), "voltaren") & strpos(lower(conmed_name), "topical") 

* analgesics
replace drugkey="tylenol" if conmed_name=="acetaminophen (Tylenol)"
replace drugkey="tyleno_cod" if conmed_name=="codeine / acetaminophen (Tylenol with Codeine)"
replace drugkey="darvon" if conmed_name=="dextropropoxyphene (Darvon)"
replace drugkey="lyrica" if conmed_name=="pregabalin (Lyrica)"
for any narcotic hydroconone lortab vicodin oxycodone percocet tramadol ultram conzip opioid: replace drugkey="narcotic" if strpos(lower(conmed_name), "X") 
replace drugkey="pain_oth" if conmed_name=="pain medications / analgesics other" | conmed_name=="pain medications other" 
replace drugkey="pain_patch" if conmed_name=="pain patch"

* CV drug 
replace drugkey="angina" if conmed_name=="angina / nitrate medication(s)"
replace drugkey="angina" if conmed_name=="angina or nitrate medication (e.g. Toprol, Norvasc, Isordil, Imdur, Inderal)"
replace drugkey="anti_clot" if conmed_name=="anti-clotting medication (examples include Plavix, Persantine, Effient, Brilinta)"
replace drugkey="anti_clot" if conmed_name=="clopidogrel (Plavix)"
replace drugkey="bp_lower" if conmed_name=="blood pressure-lowering medication"
replace drugkey="blood_thinner" if conmed_name=="blood thinner (e.g. Eliquis, Pradaxa, Xarelto, Coumadin)"
replace drugkey="blood_thinner" if conmed_name=="warfarin (Coumadin)" 
replace drugkey="cholesterol_oth" if conmed_name=="cholesterol lowering drug other (i.e. Niacin, Niaspan, Zetia)"
replace drugkey="cholesterol" if conmed_name=="cholesterol lowering medication"
replace drugkey="cholesterol" if conmed_name=="cholesterol lowering statin drug (i.e. Lipitor, Lescol, Mevacor, Pravachol, Altocor, Crestor, Zocor, Vytorin, Fenofibrate)"
replace drugkey="cholesterol" if conmed_name=="cholesterol-lowering medication (e.g. Lipitor, Crestor, Pravachol, Niacin, Zetia, Vytorin)"

* OPdrugs
replace drugkey="fosamax" if strpos(conmed_name, "Fosamax") 
replace drugkey="bextra" if conmed_name=="valdecoxib (Bextra)"
replace drugkey="ert_hrt" if conmed_name=="ERT / HRT"
replace drugkey="fosamax" if conmed_name=="alendronate (Fosamax)"
replace drugkey="bisphosphonate" if conmed_name=="bisphosphonate"
replace drugkey="miacalcin" if conmed_name=="calcitonin (Miacalcin)"
replace drugkey="denosumab" if conmed_name=="denosumab"
replace drugkey="prolia" if conmed_name=="denosumab (Prolia)"
replace drugkey="estrogen" if conmed_name=="estrogen replacement therapy (ERT)"
replace drugkey="didronel" if conmed_name=="etidronate (Didronel)"
replace drugkey="hormone" if conmed_name=="hormone replacement therapy (HRT)"
replace drugkey="boniva" if conmed_name=="ibandronate (Boniva)"
replace drugkey="op_invest" if conmed_name=="investigational agent" & strpos(conmed_section, "osteoporosis") 
replace drugkey="op_oth" if conmed_name=="osteoporosis drug other"
replace drugkey="aredia" if conmed_name=="pamidronate (Aredia)"
replace drugkey="evista" if conmed_name=="raloxifene (Evista)"
replace drugkey="actonel" if conmed_name=="risedronate (Actonel)"
replace drugkey="evenity" if conmed_name=="romosozumab-aqqg (Evenity)"
replace drugkey="forteo" if conmed_name=="teriparatide (Forteo)"
replace drugkey="reclast" if conmed_name=="zoledronic acid (Reclast)"
replace drugkey="estrogen" if conmed_name=="estrogen (not a cream)"
replace drugkey="calcium" if conmed_name=="calcium"
replace drugkey="vitamin_d" if conmed_name=="vitamin D"

*GI medications 

replace drugkey="nexium" if conmed_name=="esomeprazole (Nexium)"
replace drugkey="acid_reflux_meds" if conmed_name=="heartburn / acid reflux medication (examples include Aciphex, Nexium, Prevacid, Prilosec, Protonix)"
replace drugkey="acid_reflux_meds" if conmed_name=="lansoprazole (Prevacid)"
replace drugkey="acid_reflux_meds" if conmed_name=="medication(s) for reflux or to prevent peptic ulcer disease"
replace drugkey="cytotec" if conmed_name=="misoprostol (Cytotec)"
replace drugkey="acid_reflux_meds" if conmed_name=="omeprazole (Prilosec)"
replace drugkey="acid_reflux_meds" if conmed_name=="omeprazole (Prilosec) OTC"
replace drugkey="acid_reflux_meds" if conmed_name=="pantoprazole (Protonix)"
replace drugkey="acid_reflux_meds" if conmed_name=="rabeprazole (Aciphex)"

* anti depression 
replace drugkey="elavil" if conmed_name=="amitriptyline (Elavil)"
replace drugkey="anti_depress" if conmed_name=="anti-depression medication"
replace drugkey="wellbutrin" if conmed_name=="bupropion (Wellbutrin)"
replace drugkey="celexa" if conmed_name=="citalopram (Celexa)"
replace drugkey="cymbalta" if conmed_name=="duloxetine HCL (Cymbalta)"
replace drugkey="lexapro" if conmed_name=="ecitalopram oxalate (Lexapro)"
replace drugkey="prozac" if conmed_name=="fluoxetine (Prozac)"
replace drugkey="paxil" if conmed_name=="paroxetine (Paxil)"
replace drugkey="zoloft" if conmed_name=="sertraline (Zoloft)"
replace drugkey="effexor" if conmed_name=="venlaxafine (Effexor)"
replace drugkey="anti_anxiety" if conmed_name=="anti-anxiety medication"

* SU otc 
replace drugkey="borage_seed_oil" if conmed_name=="borage seed oil"
replace drugkey="chontroitin" if conmed_name=="chondroitin"
replace drugkey="fish_oil" if conmed_name=="fish oil"
replace drugkey="limbrel" if conmed_name=="flavocoxid (Limbrel)"
replace drugkey="flaxseed" if conmed_name=="flaxseed oil"
replace drugkey="folic_acid" if conmed_name=="folic acid"
replace drugkey="glucosamine" if conmed_name=="glucosamine"
replace drugkey="otc_oth" if conmed_name=="non-prescription remedies other"
replace drugkey= "primrose_oil" if conmed_name== "primrose oil"

*SU other 
replace drugkey="birth_control" if conmed_name=="birth control prescription (pill, shots, ring, implant, or IUD)"
replace drugkey="diabetes_oth" if conmed_name=="diabetes medication other"
replace drugkey="diabetes" if conmed_name=="diabetes medication(s)"
replace drugkey="insulin" if conmed_name=="insulin"
replace drugkey="medrol" if conmed_name=="prednisone taper or medrol dose pack"
replace drugkey="pres_meds_oth" if conmed_name=="prescription medication(s) other" 

drop conmed_use_code conmed_section_code conmed_status_code conmed_name_code freq_unit_code

assert drugkey!=""  
sort subject_number visitdate drugkey conmed_status conmed_date conmed_section 
by subject_number visitdate drugkey conmed_status: drop if _n>1 // clean duplicate drugkey 

unique subject_number visitdate drugkey conmed_status 

lab var subject_number  "Subject ID"
lab var site_number  "Site ID"
lab var visitdate  "date of office visit"
lab var dw_event_type_acronym  "form type "
lab var full_version  "form version"
lab var study_acronym  "Study type"
lab var source_acronym  "EDC data source"
lab var c_provider_id  "Provider ID"
// 2025-02-05 changed variable name 
lab var c_dw_event_instance_key "Event instance UID"
*lab var dw_event_instance_uid  "Event instance UID"
lab var c_event_created_date  "Created date"
lab var c_event_last_modified_date  "Last modified date"
lab var conmed_name  "CheckBox for each drug/item"
lab var conmed_name_txt  "text field if other drug specify"
lab var conmed_section  "form section/category"
lab var conmed_status  "Drug status"
lab var conmed_date  "drug  date"
lab var conmed_use  "Drug use status"
lab var dose_value  "drug dose value"
lab var dose_unit  "drug dose unit"
lab var dose_txt  "drug dose if specify "
lab var freq_value  "drug frequency "
lab var freq_unit  "drug frequency unit"
lab var freq_txt  "drug freqncy if specify "
lab var route  "drug taking route"
lab var reason_1  "change reason 1"
lab var reason_2  "change reason 2"
lab var reason_3  "change reason 3"
lab var reason_1_category  "change reason category for reason 1"
lab var reason_2_category   "change reason category for reason 2"
lab var reason_3_category  "change reason category for reason 3"
lab var drugkey  "drug key" 

// 2025-02-04 changed var names 
drop parent_study c_site_key c_subject_key coll_conmed_instance_uid coll_map_uid 
*drop parent_study dw_site_uid dw_subject_uid coll_conmed_instance_uid coll_map_uid 
drop discontinued_due_to_ae attributed_to_ae c_is_suppressed_not_seen x_is_test indication_txt 
drop *_code 
drop c_effective_event_date  most_recent_dose_date 
drop coll_* 

*2024-11-25 clean duplicates if same conmed_name and conmed_name_txt and conmed_section, keep if duplicate reported by SU and MD 

sort subject_number visitdate conmed_section conmed_name conmed_name_txt full_version 
by subject_number visitdate conmed_section conmed_name conmed_name_txt: drop if _n<_N 

unique subject_number visitdate conmed_section conmed_name conmed_name_txt 
unique subject_number visitdate conmed_section drugkey conmed_name_txt 

 // 29 cholesterol lowering medication reported on different version map to different name, keep later version 
sort subject_number visitdate conmed_section drugkey conmed_name_txt full_version 
by subject_number visitdate conmed_section drugkey conmed_name_txt: drop if _n<_N 

drop if site_number>=997 

// 2025-01-14, drop data out of cutdate and compress to save space 

codebook visitdate // [01oct2001,17dec2025]
count if visitdate>d(31mar2025) // 270
*
count if visitdate>d($cutdate)
drop if visitdate>d($cutdate)
// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"
compress 

save "clean_table\1_3_conmeds_$datacut" , replace 

cap log close
log using temp\test_conmeds.log, replace
use clean_table\1_3_conmeds_$datacut, clear 
corcf *  using "$pdata\clean_table\1_3_conmeds_$pdatacut", id(subject_number visitdate drugkey conmed_status) 
log close 
