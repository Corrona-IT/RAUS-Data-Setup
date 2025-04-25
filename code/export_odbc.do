/*
2025-02-03
Update: bv_subjects was empty based on a bad join. It has now been fixed. You can download today’s build from prod. Thank you for your patience!
Jenn

2024-12-29
-	Lookup changes affecting reason code columns in bv_conmeds (these were previously updated in bv_drugs_of_interest but not fully done in bv_conmeds which led to the issues you identified earlier this month). We are updating language that references “patient” to “subject” to reflect CorEvitas standards.
OLD lookup_value	NEW lookup_value	lookup_code (no change)
patient doing well (DW)	subject doing well (DW)	260
patient preference (PP)	subject preference (PP)	270

-	Column name change to bv_subject_demographic_data: “birth_year” will now be “birthyear” per Biostats request. 

Isaias R:
The ra_20240701x build is ready for your team to download. We have reviewed the issues affecting the previous builds and they are good to go in this build. 
Jen O:

The build is ready for download. However, please download ra_20240603. You might have to remove recent visits if there was any activity over the weekend. There is a similarly named build (ra_20240603a) that should not be downloaded. There is a change in that one that has not yet been tested.

2024-09-03 from Jenn:
Please note the ra_20240901 build is ready for download!

As a reminder, there were a few changes as noted previously by the BAs:
•	Views that previously had fv_ now have bv_, for example fv_subjects was changed to bv_subjects
•	Changes to existing lookup codes to align to our standards
o	“azathioprine (Imuran)” from 500 → 501
o	“investigational agent” from 888 → 980
o	“patient preference (PP)” to “subject preference (PP)”
o	“patient doing well (DW)” to “subject doing well (DW)”

*/ 



// 2024-12-04 re-download from prod server, to make sure the dw_event_instance_uid is consistent under the same schema. 

cap log close 

*cd "~\Corrona LLC\Biostat Data Files - RA\monthly\2024\\$datacut\\bv_raw"

log using bv_raw\bv_download.log,append  // replace

*odbc query dwh, schema verbose
odbc query fido, schema verbose


foreach x in death_event_details death_event_details_certain {
		clear 
odbc load, table(ra_`date'.bv_`x') dsn(fido) noquote 		
*odbc load, table(ra_`date'.bv_`x') dsn(dwh_prod_ra) noquote 
*odbc load, table(ra_`date'.bv_`x') dsn(dwh) noquote 
qui compress  
save bv_raw\bv_`x', replace 
}



    //retired_sudrugs_of_interest_certain retired_sudrugs_of_interest_pretm      retired_data

// 2024-12-02 missing both . Brent is looking into them 
// foundational views 


foreach x in haqs cdais wpais{ 
	clear 
odbc load, table(ra_`date'.bvcalc_`x') dsn(fido) noquote 
*odbc load, table(ra_`date'.bvcalc_`x') dsn(dwh_prod_ra) noquote 
*odbc load, table(ra_`date'.bvcalc_`x') dsn(dwh) noquote 
qui compress  
save bv_raw\bvcalc_`x', replace 
} 


foreach x in subjects  event_instances { 
	clear 
odbc load, table(ra_`date'.bv_`x') dsn(fido) noquote
*odbc load, table(ra_`date'.bv_`x') dsn(dwh_prod_ra) noquote 
*odbc load, table(ra_`date'.bv_`x') dsn(dwh) noquote
qui compress  
save bv_raw\bv_`x', replace 
} 


foreach x in views question_mapping view_definitions lookup_mapping  { 
	clear 
odbc load, table(ra_`date'.vw_specs_`x') dsn(fido) noquote 
* odbc load, table(ra_`date'.vw_specs_`x') dsn(dwh_prod_ra) noquote 
* odbc load, table(ra_`date'.vw_specs_`x') dsn(dwh) noquote 
qui compress  
save bv_raw\specs_`x', replace 
use bv_raw\specs_`x', clear
export excel  * using "bv_raw\specs_`x'.xlsx" , firstrow(var) replace
} 


// 2025-04-01 had an error message from stata regarding no memory available, re-started stata (not the computer) just to download bv_labs. 
// medical_problems medical_problems_pretm subject_demographic_data  longitudinal_visit_data infections  drugs_of_interest conmeds exits imaging vaccines tae_ana_details tae_ana_reaction_hx tae_c19_details tae_gen_details tae_gip_details tae_hep_details tae_inf_details tae_neu_details tae_can_details tae_cvd_details tae_ssb_details tae_ssb_transfusions tae_vte_details tae_zos_details te_preg_complications te_preg_details tae_labs_imaging  labs 

local date 20250408

foreach x in comorbidities { 
	clear 
	
odbc load, table(ra_`date'.bv_`x') dsn(fido) noquote
*odbc load, table(ra_`date'.bv_`x') dsn(dwh_prod_ra) noquote 
*odbc load, table(ra_`date'.bv_`x') dsn(dwh) noquote
qui compress  
save bv_raw\bv_`x', replace 
} 


local date 20250408

foreach x in comorbidities { 
	clear 
	
odbc load, table(ra_`date'.bv_`x') dsn(fido) noquote
*odbc load, table(ra_`date'.bv_`x') dsn(dwh_prod_ra) noquote 
*odbc load, table(ra_`date'.bv_`x') dsn(dwh) noquote
qui compress  
save bv_raw\bv_`x'_2nd, replace 
} 

log close 



