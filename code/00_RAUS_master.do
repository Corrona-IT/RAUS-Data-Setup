/*
#-----------------------------------------------------------
# Program: 00_main.R
# Author:  Ryan Harrison
# Date:    2021-10-19
# Purpose: Main File for {REG-###} Query
#-----------------------------------------------------------

#----------------
# Load Libraries
#----------------
# Load packages used in the analysis at the very beginning.
# Be mindful of namespace conflicts, and versions of packages being used
# Save session information so you can recreate the environment at a later date

library(tidyverse, warn.conflicts = FALSE) # Recommended packages for data manipulation
library(arsenal)                           # Recommended package for creating tables
library(tidycoRe)                          # Internal package for CorEvitas helper functions, styles, templates
library(lubridate)                         # Recommended package for manipulating dates
library(broom)                             # Recommended package for tidying regression model tables
library(glue)                              # Recommended package for concatenating strings
#library(haven)                            # Recommended package for importing datasets from SAS, STATA, others
#library(tidymodels)                       # Recommended packages for machine learning models in a tidy framework

#------------------
# Session Info Log
#------------------
writeLines(capture.output(sessionInfo()), "sessionInfo.txt")

#-------------
# Freeze Date
#-------------

# Set the date of your data extract for future use
# Recommended to use ISO 8601 format: YYYY-MM-DD or YYYYMMDD
frz_dt <- "2021-11-01"

# Use lubridate to extract  year
frz_yr <- lubridate::as_date(frz_dt) %>% lubridate::year(.)

#-----------------
# Set Directories
#-----------------
# Use relative paths to point to relevant directories


# "~" refers to your HOME directory
# ".." goes up one level in the directory structure
# "." refers to your current working directory
# The current working directory should be the location of your .RProj file for this GitHub repository

# Registry data should be imported directly from its source: either Sharepoint (currently as of 2021) or AWS (future)
sharepoint_dir <- "~/../Corrona LLC/Biostat Data Files - Registry Data"


# Example:
# Set up directory for downloading the IBD Registry data from 2021-11-01
# sharepoint_ibd <- "~/../Corrona LLC/Biostat Data Files - Registry Data/IBD/monthly/2021/2021-11-01/Analytic Data"
# or using paste0 function
# sharepoint_ibd <- paste0(sharepoint_dir, "/IBD/monthly/", frz_yr, "/", frz_dt, "/Analytic Data")
# or using glue function from glue package
# sharepoint_ibd <- glue::glue("{sharepoint_dir}/IBD/monthly/{frz_yr}/{frz_dt}/Analytic Data")

# Check if the directory above exists
dir.exists(sharepoint_dir)

#----------------------
# Source Analysis Code
#----------------------
# Programs should be organized into smaller, separate, modular files
# Use the source() function to run external programs
# Recommended naming convention: use a numeric prefix to indicate the order it should be executed

source("./R/01_create_dataset.R")

source("./R/02_table1.R")

#-------------------------
# Export Analysis Results
#-------------------------

# Send to Markdown - Local output
rmarkdown::render(
  input         = "{}.Rmd",        # Your analysis markdown file
  output_dir    = "./reports",     # Your output directory for markdown file
  output_file   = "",              # Your output file name
  output_format = "word_document", # Output format, word, powerpoint, html, pdf, etc
  envir         = new.env()        # new.env() creates a new environment within the RMarkdown file to improve reproducibility
)

#----------------------------
# Send Results to Sharepoint
#----------------------------

# You may want to share your analysis results with people outside of Biostats
# You can copy files from your project ./reports folder to Sharepoint

# Copy Local output to Sharepoint
file.copy(
  from      = "./reports", # Directory or filename to copy
  to        = "",           # Destination directory or filename
  overwrite = TRUE          # Overwrite files with existing names on Sharepoint? If TRUE and a file exists, it will increment the version number
)



#----------------------------
# THESE ARE WENDI'S TEST CHANGES
#----------------------------

*/

/*
noi run pso_master ///
	"~/Corrona LLC/Biostat Data Files - PsO/datacut/data/prod" ///
  SetDates.dof ///
  connect_report.dof 
*/
****************************************************************************************************************************
*! version 1.0  01dec2023
*! Control program for RAUS

capture log close 
clear

// version notes

// Part 0: Set macro values
    // 0a: Values from user
local pso `1'   // where date-based "Monthly Line Listing" is created    

    // 0b: Values with defaults if user did not specify
local dates `2'
local cdbinfo `3' 
local offsched "`4'"

    // 0c: Fixed values 
        // directory for site data
local psosites "~/Corrona LLC/Biostat Data Files - PsO/datacut/data/prod/sites"

    // Set defaults
        // dates
if "`dates'"=="" | "`dates'"=="default" {
    local dates SetDates.dof
}

        // CDB connection
if "`cdbinfo'"=="" | "`cdbinfo'"=="default" {
	* v2.6.4: changed default to new reporting connection
    local cdbinfo connect_report.dof
}

    // Stata sets dates based on when file is run
include `dates'

// Part 1: Error checking
run checks.do "`pso'" "`cdbinfo'" `dates'

// Part 2: Run site creation file if needed
capture confirm file `"`psosites'/PSOsites_`sitedt'.dta"'
if _rc {
    noi run ../site_import/v2/sites-import_v2.do "`psosites'"
}

// Part 3: Import main data from CDB
    // Import MD data
noi run main/impt_DrugInstances.do "`pso'" "`cdbinfo'" `dates'
noi run main/impt_md.do "`pso'" "`cdbinfo'" `dates' 
noi run main/impt_su.do "`pso'" "`cdbinfo'" `dates'
noi run main/impt_LongMD.do "`pso'" "`cdbinfo'" `dates'
noi run main/impt_LongINF.do "`pso'" "`cdbinfo'" `dates'

// Part 4: Clean main data
    // Drug data (EN+FU)
log using "`pso'/`offrun'/logs/drug_instances.txt", text replace
noi run main/DrugInstances.do "`pso'" `dates'
log close

	// infection data (MiaoY 10/21/21)
log using "`pso'/`offrun'/logs/infection.txt", text replace
noi run main/infection.do "`pso'" `dates'
log close

log using "`pso'/`offrun'/logs/exinfection.txt", text replace
noi run main/exinfection.do "`pso'" `dates'
log close

    // MDEN (with common MD code)
log using "`pso'/`offrun'/logs/mden.txt", text replace
noi run main/mden_v3.do "`pso'" `dates'
log close

	// MDFU (with common MD code)
log using "`pso'/`offrun'/logs/mdfu.txt", text replace
noi run main/mdfu_v3.do "`pso'" `dates'
log close

	// SUEN (with common SU code) 
log using "`pso'/`offrun'/logs/suen.txt", text replace
noi run main/suen_v3.do "`pso'" "`psosites'" `dates'
log close

	// SUFU (with common SU code)
log using "`pso'/`offrun'/logs/sufu.txt", text replace
noi run main/sufu_v3.do "`pso'" `dates'
log close

	// comorbidity data
log using "`pso'/`offrun'/logs/comor.txt", text replace
noi run main/comor.do "`pso'" `dates'
log close

log using "`pso'/`offrun'/logs/excomorbidity.txt", text replace
noi run main/excomorbidity.do "`pso'" `dates'
log close

// Part 5: Monthly ancillary files
	// Import+clean EXIT data
log using "`pso'/`offrun'/logs/exit.txt", text replace
noi run main/exit_v3.do "`pso'" "`cdbinfo'" `dates' 
log close

// Part 6: Derived datasets
    // Combined enrollment
log using "`pso'/`offrun'/logs/Enrollment.txt", text replace
noi run main/Enrollment_v3.do "`pso'" `dates'
log close

	// Import+clean LAB data
log using "`pso'/`offrun'/logs/labs.txt", text append
noi run qtr/labs_v3.do "`pso'" "`cdbinfo'" `dates'
log close

    // Combined Follow-up
log using "`pso'/`offrun'/logs/Followup.txt", text replace
noi run main/fu.do "`pso'" `dates' "`psosites'"
log close

    // Subjects summary file
log using "`pso'/`offrun'/logs/subj.txt", text replace
noi run main/exsubject.do "`pso'" `dates'
log close

    // Drug instances
log using "`pso'/`offrun'/logs/inst.txt", text replace
noi run main/exinstances.do "`pso'" `dates'
log close

* v2.6.4: add exvisit
log using "`pso'/`offrun'/logs/visit.txt", text replace
noi run main/exvisit.do "`pso'" `dates'
log close

* v2.6.4: add drug supplement to exsubject
    // Drug and visit appendix to subjects summary
log using "`pso'/`offrun'/logs/subj.txt", text replace
noi do suppl/exsubj_drugs.do "`pso'" `dates'
log close

// Part 7: PV-specific files
	// Part 7a: Import+clean INF data
log using "`pso'/`offrun'/logs/inf.txt", text replace
noi run main/tae-inf_v3.do "`pso'" "`cdbinfo'" `dates'
log close

    // Part 7b: TAE files
log using "`pso'/`offrun'/logs/tae.txt", text replace
    foreach tae in sib {
        noi run qtr/tae-`tae'.do "`pso'" "`cdbinfo'" `dates'
    }
    foreach tae in ana cm cvd gen gi hep ibd neu ssb {
        noi run qtr/tae-`tae'_v2.do "`pso'" "`cdbinfo'" `dates'
    }
log close

*v2.6.2: split LAI out of TAE conditional logic
log using "`pso'/`offrun'/logs/lai.txt", text replace
	foreach lai in anc {
		noi run qtr/lai-`lai'.do "`pso'" "`cdbinfo'" `dates'
	}
log close

    // Part 7c: Pregnancy file
log using "`pso'/`offrun'/logs/preg.txt", text append
noi run qtr/tae-preg_v2.do "`pso'" "`cdbinfo'" `dates'
log close

// Part 8: Error report
run pso_ereport.do "`pso'" `dates'

// Part 9: Make bundle of datasets for distribution
foreach pvf in Enrollment FU EXIT exsubject exinstances exvisit excomorbidity exinfection LABS {
   noi run suppl/make_analytic_bundle.do "`pso'" `pvf' `dates'
}

local taefiles ANA CM CVD GEN GI HEP IBD INF NEU SSB SIB PG
foreach tae of local taefiles {
	noi run suppl/make_analytic_bundle.do "`pso'" "`tae'_TAE" `dates'
}

noi run suppl/make_analytic_bundle.do "`pso'" "ANC_LAI" `dates'

log using "`pso'/`offrun'/logs/drugexp.txt", text replace
noi run main/exdrugexp.do "`pso'" `dates'
log close

noi run suppl/make_analytic_bundle.do "`pso'" "exdrugexp" `dates'
 

// Part 10: Update data dictionary
* Date format update (MYU,01/27/22)
local path "`pso'/`yr'/`offrun1'"
* v3.0.0: exsubject is now first dataset in data dictionary
use "`path'/exsubject_`run1'.dta", clear
* v3.0.2: added sheet modify (ram)
cordd *, saving("`path'/PsO Data Dictionary_`run1'", replace) sheet(exsubject) 

foreach d in exdrugexp exvisit exinstances excomorbidity exinfection EN FU EXIT LABS {
	noi capture confirm file "`path'/`d'_`run1'.dta"
	if !_rc {
		use "`path'/`d'_`run1'.dta", clear
		* v3.0.2: added sheet modify (ram)
		cordd *, saving("`path'/PsO Data Dictionary_`run1'") sheet(`d') sheetmodify
	}
}

* Date format update (MYU,01/27/22)
local path "`path'/pv/`offrun1'"	
local taefiles INF ANA CM CVD GEN GI HEP IBD NEU SSB SIB PG
foreach tae of local taefiles {
	noi capture confirm file "`path'/`tae'_TAE_`run1'.dta"
	if !_rc {
		* 3.0.2: added sheet modify (ram)
		cordd * using "`path'/`tae'_TAE_`run1'.dta", ///
			saving("`path'/PsO Data Dictionary_`run1'") sheet(`tae') sheetmodify
	}
}

* Date format update (MYU,01/27/22)
noi capture confirm file "`path'/ANC_LAI_`run1'.dta"
if !_rc {
	* 3.0.2: added sheet modify (ram)
	cordd * using "`path'/ANC_LAI_`run1'.dta", ///
		saving("`path'/PsO Data Dictionary_`run1'") sheet(ANC) sheetmodify
}

*<end>
