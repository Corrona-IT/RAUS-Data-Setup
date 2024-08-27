#------------------------------------------------------------------------------
# Program: 17_clean_alllabs_data.R
# Date:    
# Author:  Marie Gurrola
# Purpose: Combine lab and imaging dataset into one
#------------------------------------------------------------------------------


# for hep RNA, if result_int is detected (specify), where does that get placed?
# spoke to victoria, this will get mapped intor results

options(max.print=1000)
options(print = 1000)

# include all packages and file paths that will be used in the script so stata can
# just call one script

#----------------
# Load Libraries
#----------------
library(labelled)
library(lubridate)                         
library(glue)                              
# library(arrow)
library(tidyverse)

#-------------
# Set date parameters
#-------------
tdy_date <- Sys.Date()
# cut date to use while BVs are still in odbc
# LG 2024-08-09 update for new data 
cut_date    <- as.Date("2024-08-01")

# cut_date <- floor_date(Sys.Date(), "month")-1
# test cut_date var
# cut_date <- floor_date(as.Date("2024-02-04"), "month")-1
cut_year <- year(cut_date)


# confirm for RA if there are date parameters that need to be set

#-----------------
# Set Directories
#-----------------

# lin and ying will need to add their directories
sharepoint      <- "~/../../Corrona LLC"
dir_ra_monthly  <- glue("{sharepoint}/Biostat Data Files - RA/monthly")

# update this file path when raw data is in the monthly/raw data folder
bv_raw          <- glue("{dir_ra_monthly}/{cut_year}/{cut_date}/bv_raw/")

# temp bv_raw
# bv_raw          <- glue("{dir_ra_monthly}/ODBC/dwh_db/{cut_date}/") 


dir.exists(bv_raw)

# create indicator variable (i.e., lab_type) for lab vs imaging. 1 = lab; 2 = imaging

# function to loop through result and uln_value; these are text fields that accept any value
spec_char_function <- function(var_name){
  
  non_char         = grepl("[^a-zA-Z0-9.]", var_name)
  has_alphabetical = str_detect(var_name, "[a-zA-Z]")
  decimal_count    = str_count(var_name, "\\b\\d+\\.\\d+\\b|\\.")
  char_n           = nchar(var_name)
  inv_decimal      = if_else(char_n == 1 & decimal_count == 1 |
                               decimal_count > 1, TRUE, FALSE)
  identify_all     = non_char + has_alphabetical + inv_decimal
  
  identify_all     = if_else(identify_all == 0, var_name, NA_character_)
  
  # convert to numeric
  identify_all     = as.numeric(identify_all)
  
  return(identify_all)
  
}

# function to extract "<" from CCP, CRP and RF raw results and keep the result and place an indicator 
# var in uln_less_than which is renamed to lab_uln_value_lt

extract_lt <- function(var_name){
  
  has_alphabetical = str_detect(var_name, "[a-zA-Z]")
  decimal_count    = str_count(var_name, "\\b\\d+\\.\\d+\\b|\\.")
  char_n           = nchar(var_name)
  inv_decimal      = if_else(char_n == 1 & decimal_count == 1 |
                               decimal_count > 1, TRUE, FALSE)
  # identify instances where only < is entered 
  inv_length       = char_n == 1
  # identify other invalid entries like =
  has_oth_spec     = str_detect(var_name, "[^<^0-9^.]")
  
  identify_all     = has_alphabetical + inv_decimal + inv_length + has_oth_spec
  
  identify_all     = if_else(identify_all == 0, var_name, NA_character_)
  
  # convert to numeric
  # identify_all     = as.numeric(identify_all)
  
  return(identify_all)
  
}


# lab unit codes
# Confirmed with Victoria that as of Feb 1, 2024 there is a still a "Known bug with TM EDC - request for 
# ENG to help fix source data quality has been confirmed as a fast-follower. In the meantime, it was 
# agreed that Biostats will address these issues in their set-up code if needed."
# This EDC bug impacts ALT, CPK, and tot bilirubin; incorrect lab unit being assigned to these three

# For Vitamin D and other tests that have ng/mL as a unit: ng/Ml will show up as mcg/L in the bv

tictoc::tic()
labs_clean <-  haven::read_dta(glue("{bv_raw}/bv_labs.dta")) %>% 
  # read_parquet(glue("./data/bv_labs_{view_dt_lab}.parquet")) %>% 
  # remove test sites
  # filter(site_number != "999") %>% 
  # remove backend DWH vars
  # LG 2024-07-05 temporarily change from lab_type to coll_subtype
  # LG 2024-07-10 change back to lab_type and lab_type_code
  # LG 2024-07-10 change edc_event_name_raw to x_edc_event_name_raw
  select(
    -c(dw_event_instance_uid,
       dw_site_uid,
       dw_subject_uid, 
       coll_lab_instance_uid,
       coll_map_uid,
       coll_crf_name_raw,
       coll_crf_ordinal,
       coll_group_type_acronym,
       coll_group_ordinal,
       x_edc_event_name_raw  
       )
    ) %>% 
  mutate(lab_img_type       = 1) %>% 
  rename(
    lab_img_dt                     = lab_date, 
    lab_img_name                   = lab_type, 
    lab_img_name_code              = lab_type_code,
    lab_img_result_raw            = result_value,
    # lab_result_code                = result_value_code,
    lab_img_result_intpn           = result_interpretation, # has values for ccp, hep b, hep c, rf, prism RA
    lab_img_result_intpn_code      = result_interpretation_code, 
    lab_result_unit_raw            = result_unit,
    lab_result_unit_code_raw       = result_unit_code, 
    lab_result_lt_or_gt            = less_or_greater_than,
    lab_uln_value_raw              = uln_value, 
    lab_uln_value_lt               = uln_less_than, 
    lab_lipid_meds                 = lipid_meds,
    lab_lipid_meds_code            = lipid_meds_code, 
    lab_lipid_fasting              = lipid_fasting, 
    lab_lipid_fasting_code         = lipid_fasting_code, 
    lab_hep_c_type                 = hepatitis_c_type,
    lab_hep_c_subtype              = hepatitis_c_subtype
    
  ) %>% 
  mutate(
    full_version         = as.numeric(full_version)
  )
tictoc::toc()

labs_clean_res_units <- labs_clean %>% 
  
   mutate(
     
     # identify "<" in raw uln results for CRP, CCP, RF
     lt_sym = if_else(grepl("CRP|RF|CCP", lab_img_name) & grepl("\u003C|<", lab_uln_value_raw) & full_version <= 14, 1L, 0L, 0L),
     
     
   # convert char vars to numeric
   across(
     .cols   = c(lab_lipid_meds_code),
     .fns    = ~as.numeric(.x)
   ),
   
   # create numeric variables for 
   across(
     .cols = c(lab_result_lt_or_gt, lab_uln_value_lt),
     .fns  = ~case_when(
       .x == "<" ~ 1L,
       .x == ">" ~ 2L, 
       TRUE      ~ NA_integer_
       ),
     .names = "{.col}_code"
     ),
   # create clean version of result and uln variables 
    across(
      .cols = c(lab_uln_value_raw, lab_img_result_raw),
      .fns  = ~spec_char_function(.x),
      .names = "{gsub('_raw', '', .col)}"
      
    ),
   
   # run extract_lt function on crp, ccp, rf
   lab_uln_value_temp = if_else(lt_sym == 1, extract_lt(lab_uln_value_raw), NA_character_),
   # if lab_uln_value_temp has a value, strip the "<" and apply that value to lab_uln_value
   lab_uln_value = if_else(!is.na(lab_uln_value_temp) & is.na(lab_uln_value), as.numeric(gsub("<", "", lab_uln_value_temp)), lab_uln_value),
   # update lan_uln_value_lt_code to relfect the < value
   lab_uln_value_lt_code = if_else(lt_sym == 1 & !is.na(lab_uln_value_temp), 1L, lab_uln_value_lt_code, lab_uln_value_lt_code)
   ) %>% 
  select(-lt_sym, -lab_uln_value_temp) %>% 
  mutate(
    # populate unit values where missing from preTM version 4-7
    # labs with missing units for v4-7 are ALT, albium, AST, CCP (5-7),
    # CRP, creatinine, ESR, platelets, WBC. excluding CRP, all labs only have one
    # unit value; CRP has wrong units only for v12-v14 -- known TM EDC error
    
    lab_result_unit_code = case_when(
      
      # CRP has invalid values in v14; only keep valid values; wrong in TM EDC;
      # allows for %, 10^3/mcl, IU/L, and mm/hr
      lab_img_name_code == 101 & full_version <= 14 &  
        !(lab_result_unit_code_raw %in% c(110, 130, 150, 160))    ~ NA_real_,
      lab_img_name_code == 101 & full_version <= 14 &  
        lab_result_unit_code_raw %in% c(110, 130, 150, 160)       ~ lab_result_unit_code_raw,
      
      # ESR only has mg/dL for labs <= 14
      lab_img_name_code == 102 & full_version <= 14               ~ 170,
      
      # CCP only has U/mL for labs <= 14
      lab_img_name_code == 201 & full_version <= 14               ~ 221,
      
      # WBC only has 10^3/mcL for labs <= 14
      lab_img_name_code == 301 & full_version <= 14               ~ 100,
      
      #neutrophils for labs <= 14
      lab_img_name_code == 302 & full_version <= 14               ~ 1,
      
      # Hemoglobin only has g/dL for labs <= 14
      lab_img_name_code == 303 & full_version <= 14               ~ 110,
      
      # HCT only has % for labs <= 14
      lab_img_name_code == 304 & full_version <= 14               ~ 1,
      
      # platelets only has 10^3/mcl for labs <= 14
      lab_img_name_code == 305 & full_version <= 14               ~ 100,
      
      # lowest vals for WBC and platelets; on form states to report in thousands
      # using same unit code as WBC and platelts which is 10^3/mcL
      lab_img_name_code %in% c(311, 315) & full_version %in% 8:12 ~ 100,
      
      # anemia lowest value
      lab_img_name_code %in% c(316) & full_version %in% 8:12      ~ 1,
      
      # AST only has IU/L for labs <= 14  
      lab_img_name_code == 501 & full_version <= 14               ~ 210,
      
      # ALT only has IU/L for labs <= 14; wrong in TM EDC which allows for mg/dL
      lab_img_name_code == 502 & full_version <= 14               ~ 210,
      
      # bilirubin only has mg/dL for labs <= 14; wrong in TM EDC which allows for IU/L
      lab_img_name_code == 503 & full_version <= 14               ~ 150,
      
      # albium only has g/dL for labs <= 14
      lab_img_name_code == 504 & full_version <= 14               ~ 110,
      
      # creatinine only has mg/dL for labs <= 14
      lab_img_name_code == 601 & full_version <= 14               ~ 150,
      
      # CPK only has IU/L for labs <= 14; wrong in TM EDC with mcg/L as unit
      lab_img_name_code == 602 & full_version <= 14               ~ 210,
    
      # vit d only has mcg/L for labs <= 14; wrong in TM EDC with mcg/L as unit
      lab_img_name_code == 701 & full_version <= 14               ~ 130,
      
      
      TRUE                                                        ~ lab_result_unit_code_raw
    ),
  # if lab_result_unit_code is missing, then lab_result should also be missing
  
  # HDL, LDL, cholestoral, trigylcerides did not have any units from v7 - v14; 
  # these will not have a lab_result value
  # LG 2024-07-05 we need to keep lab img result even when Units are not available
  # lab_img_result = if_else(is.na(lab_result_unit_code), NA_real_, lab_img_result)

  ) 



# assign lab_img_name labels
    
imaging_clean <-  haven::read_dta(glue("{bv_raw}/bv_imaging.dta")) %>% 
  # read_parquet(glue("./data/bv_imaging_{view_dt_lab}.parquet")) %>% 
  # remove test sites
  filter(site_number != "999") %>%
  # remove backend DWH vars
  # LG 2024-07-10 edc_event_name_raw and edc_event_ordinal were changed to x_*
  select(
    -c(dw_event_instance_uid,
       dw_site_uid,
       dw_subject_uid, 
       coll_imaging_instance_uid,
       coll_map_uid,
       coll_crf_name_raw,
       coll_crf_ordinal,
       coll_group_type_acronym,
       coll_group_ordinal,
       x_edc_event_name_raw,
       # dw_event_type_acronym,
       x_edc_event_ordinal
    )
  ) %>% 
  # MRI only option available before version 7; currently given the imaging type of MRI / Ultrasound - joint
  mutate(
    imaging_type_code = if_else(imaging_type_code == 5215 & full_version < 7, 5210, imaging_type_code, imaging_type_code )
  ) %>% 
  # filter rows where it's unclear if the test result is MRI or ultrasound
  filter(imaging_type != "MRI / Ultrasound - joint ") %>% 
  mutate(lab_img_type = 2) %>% 
  rename(
    lab_img_dt                     = imaging_date,
    lab_img_name                   = imaging_type, 
    lab_img_name_code              = imaging_type_code,
    lab_img_result_raw             = result,
    img_result_code_raw            = result_code,
    img_finding                    = imaging_finding,
    img_finding_code               = imaging_finding_code, 
    img_us_tot_joints              = jus_total_number_of_joints, 
    img_cxr_evidence_of_tb         = cxr_evidence_of_tb_code,
    img_mri_field_strength_code    = mri_field_strength_code,
    img_mri_field_strength         = mri_field_strength,
    img_dxa_tscore_sign_code       = dxa_tscore_sign_code,
    img_dxa_tscore_sign            = dxa_tscore_sign,
    img_dxa_bmd                    = dxa_bmd,
    img_dxa_machine_type_code      = dxa_machine_type_code,
    img_dxa_machine_type           = dxa_machine_type
  ) %>% 
  # keep img_result as numeric so it can be stacekd with lab results
  # move pos, neg, etc, to lab_img_result_int
  mutate(
    full_version              = as.numeric(full_version),
    lab_img_result_intpn      = if_else(grepl("pres|new|old|normal", lab_img_result_raw, ignore.case = TRUE), lab_img_result_raw, NA_character_, NA_character_),
    lab_img_result_intpn_code = case_when(
      lab_img_result_intpn == "abnormal"        ~ 1L,
      lab_img_result_intpn == "new"             ~ 2L,
      lab_img_result_intpn == "normal"          ~ 3L,
      lab_img_result_intpn == "not present"     ~ 4L,
      lab_img_result_intpn == "old"             ~ 5L,
      lab_img_result_intpn == "old and new"     ~ 6L,
      lab_img_result_intpn == "present"         ~ 7L,
      TRUE                                      ~ NA_integer_
    ),
    # convert non-character values to numeric
    lab_img_result            = if_else(is.na(lab_img_result_intpn), lab_img_result_raw, NA_character_, NA_character_), 
    lab_img_result            = as.numeric(lab_img_result)

  )
  


# bind lab and imaging
all_labs <- bind_rows(labs_clean_res_units, imaging_clean)  %>% 
  # identify duplicates
  group_by(subject_number,
           c_effective_event_date, 
           lab_img_name, 
           lab_img_dt, 
           img_finding
           # lab_img_result_raw,
           ) %>% 
  mutate(
    dupe = n()
  ) %>% 
  ungroup() %>% 
  group_by(subject_number,
           c_effective_event_date, 
           lab_img_name, 
           lab_img_dt, 
           img_finding,
           lab_img_result_raw,
           lab_img_result_intpn
  ) %>% 
  mutate(
    dupe_res = n()
  ) %>% 
  ungroup() %>% 
  # awaiting guidance on how to handle duplicates
  select(-contains("dupe"))

all_labs_labelled <- all_labs %>% 
  mutate(#visitidate = as.Date(c_effective_event_date, format = "%Y-%m-%d"),
         # convert XX values in lab_img_dt to 01; retain original date
         lab_img_dt_raw = lab_img_dt,
         lab_img_dt  = gsub("XX", "01", lab_img_dt),
         lab_img_dt = as.Date(lab_img_dt, format = "%Y-%m-%d"),
         
         # lab_img_dt_raw & lab_img_result_raw have "" instead of NA
         lab_img_dt_raw     = if_else(lab_img_dt_raw == "", NA_character_, lab_img_dt_raw, lab_img_dt_raw),
         lab_img_result_raw = if_else(lab_img_result_raw == "", NA_character_, lab_img_result_raw, lab_img_result_raw),
         
         # convert character to numeric to allow for labeling
         # study_source_acronym_temp = case_when(
         #   study_source_acronym == "CERTAIN-PRETM" ~ 1,
         #   study_source_acronym == "CERTAIN-TM"    ~ 2,
         #   study_source_acronym == "RA-PRETM"      ~ 3,
         #   study_source_acronym == "RA-TM"         ~ 4,
         #   study_source_acronym == "RA-RCC"        ~ 5,
         # ),
         
         across(
           .cols = c(lab_result_unit_code, lab_result_unit_code_raw),
           .fns  = ~set_value_labels(., .labels = c(
             "%"             =	1,
             "10^3/mcL"      =	100,
             "10^3/mm^3"     =	101,
             "10^9/L"        =	102,
             "cells/mcL"     =	230,
             "cells/mm^3"    =	231,
             "g/dL"          =	110,
             "g/L"           =	120,
             "IU/L"          =	210,
             "IU/mL"         =	220,
             "mcg/L"         =	130,
             "mcmol/L"       =	140,
             "mg/dL"         =	150,
             "mg/L"          =	160,
             "mm/hr"         =	170,
             "mmol/L"        =	180,
             "nkat/L"        =	190,
             "nmol/L"        =	200,
             "U/L"           =	211,
             "U/mL"          =	221
           )),
           .names = "{.col}"
         ),
         
         # use character values for lab_img codes
         
         lab_img_name_clean = case_when(
           
           lab_img_name_code  == 101  ~ "crp",
           lab_img_name_code  == 102  ~ "esr",
           lab_img_name_code  == 201  ~ "ccp",
           lab_img_name_code  == 202  ~ "rf",
           lab_img_name_code  == 203  ~ "vectra_da",
           lab_img_name_code  == 204  ~ "prism_ra",
           lab_img_name_code  == 301  ~ "wbc",
           lab_img_name_code  == 302  ~ "neutrophils",
           lab_img_name_code  == 303  ~ "hgb",
           lab_img_name_code  == 304  ~ "hct",
           lab_img_name_code  == 305  ~ "platelets",
           lab_img_name_code  == 311  ~ "wbc_low",
           lab_img_name_code  == 315  ~ "plat_low",
           lab_img_name_code  == 316  ~ "anemia_low",
           lab_img_name_code  == 401  ~ "hdl",
           lab_img_name_code  == 402  ~ "ldl",
           lab_img_name_code  == 403  ~ "cholesterol",
           lab_img_name_code  == 404  ~ "triglycerides",
           lab_img_name_code  == 501  ~ "ast",
           lab_img_name_code  == 502  ~ "alt",
           lab_img_name_code  == 503  ~ "tot_bilirubin",
           lab_img_name_code  == 504  ~ "albumin",
           lab_img_name_code  == 505  ~ "alp",
           lab_img_name_code  == 506  ~ "inr",
           lab_img_name_code  == 601  ~ "creatinine",
           lab_img_name_code  == 602  ~ "cpk",
           lab_img_name_code  == 701  ~ "vit_d",
           lab_img_name_code  == 711  ~ "hbv_sag",
           lab_img_name_code  == 712  ~ "hbv_cab",
           lab_img_name_code  == 713  ~ "hbv_sab",
           lab_img_name_code  == 714  ~ "jbv_igm",
           lab_img_name_code  == 721  ~ "hcv_rna",
           lab_img_name_code  == 722  ~ "hcv_ab",
           lab_img_name_code  == 723  ~ "hcv_genotype",
           lab_img_name_code  == 724  ~ "hcv_rav",
           lab_img_name_code  == 5210 ~ "mri_joint",
           lab_img_name_code  == 5310 ~ "ultrasound_joint",
           lab_img_name_code  == 5410 ~ "xray_chest",
           lab_img_name_code  == 5420 ~ "xray_joint",
           lab_img_name_code  == 5500 ~ "dxa"
         )
         ) %>% 
  # select(-study_source_acronym) %>% 
  # rename(study_source_acronym = study_source_acronym_temp) %>% 
  set_value_labels(
    
    lab_img_type = c(
      "Lab"     = 1,
      "Imaging" = 2
    ),
    
    lab_img_name_clean = c(
      "C-Reactive Protein"                           = "crp",
      "Erythrocyte Sedimentation Rate"               = "esr",
      "CCP Antibody"                                 = "ccp",
      "Rheumatoid Factor"                            = "rf",
      "Vectra® DA Score"                             = "vectra_da",
      "PrismRA"                                      = "prism_ra",
      "White Blood Count "                           = "wbc",
      "Neutrophils"                                  = "neutrophils",
      "Hemoglobin"                                   = "hgb",
      "Hematocrit"                                   = "hct",
      "Platelets"                                    = "platelets",
      "White Blood Count  - Lowest Value Ever Had"   = "wbc_low",
      "Platelets - Lowest Value Ever Had"            = "plat_low",
      "Anemia - Lowest Value Ever Had"               = "anemia_low",
      "High-Density Lipoprotein"                     = "hdl",
      "Low-Density Lipoprotein "                     = "ldl",
      "Total Cholesterol"                            = "cholesterol",
      "Triglycerides"                                = "triglycerides",
      "Aspartate Aminotransferase"                   = "ast",
      "Alanine Aminotransferase"                     = "alt",
      "Bilirubin - Total"                            = "tot_bilirubin",
      "Albumin"                                      = "albumin",
      "Alkaline Phosphatase"                         = "alp",
      "International Normalized Ratio"               = "inr",
      "Creatinine"                                   = "creatinine",
      "Serum Creatinine Kinase"                      = "cpk",
      "Vitamin D"                                    = "vit_d",
      "Hepatitis B Surface Antigen"                  = "hbv_sag",
      "Hepatitis B Core Antibody"                    = "hbv_cab",
      "Hepatitis B Surface Antibody"                 = "hbv_sab",
      "Igm Antibody To Hep B Core Antigen"           = "jbv_igm",
      "Hepatitis C Total Viral Load"                 = "hcv_rna",
      "Hepatitis C Virus Serology Antibody"          = "hcv_ab",
      "Hepatitis C Genotyping"                       = "hcv_genotype",
      "Hepatitis C Resistance Testing"               = "hcv_rav",
      "Magnetic Resonance Imaging - Joint"           = "mri_joint",
      "Ultrasound - Joint"                           = "ultrasound_joint",
      "Radiograph - Chest"                           = "xray_chest",
      "Radiograph - Joint"                           = "xray_joint",
      "Bone Density Scan"                            = "dxa"
      
    ),
    # lab_img_name_code = c(
    #  "c-reactive protein (CRP)"                           =	101,
    #  "erythrocyte sedimentation rate (ESR)"               = 102,
    #  "CCP antibody (anti-CCP)"                            = 201,
    #  "Rheumatoid factor (RF)"                             =	202,
    #  "Vectra® DA score"                                   =	203,
    #  "PrismRA"                                            = 204	,
    #  "white blood count (WBC)"                            =	301,
    #  "neutrophils"                                        =	302,
    #  "hemoglobin (Hb)"                                    = 303,
    #  "hematocrit (Hct)"                                   =	304,
    #  "platelets"                                          =	305,
    #  "white blood count (WBC) - lowest value ever had"    =	311,
    #  "platelets - lowest value ever had"                  = 315,
    #  "anemia - lowest value ever had"                     = 316,
    #  "high-density lipoprotein (HDL)"                     =	401,
    #  "low-density lipoprotein (LDL)"                      =	402,
    #  "total cholesterol"                                  =	403,
    #  "triglycerides"                                      =	404,
    #  "aspartate aminotransferase (AST)"                   =	501,
    #  "alanine aminotransferase (ALT)"                     =	502,
    #  "bilirubin - total"                                  =	503,
    #  "albumin"                                            =	504,
    #  "alkaline phosphatase (ALP)"                         =	505,
    #  "international normalized ratio (INR)"               =	506,
    #  "creatinine"                                         =	601,
    #  "serum creatinine kinase (CK/CPK)"                   =	602,
    #  "vitamin D"                                          =	701,
    #  "Hepatitis B surface antigen (HBsAg)"                =	711,
    #  "Hepatitis B core antibody (HBcAb)"                  =	712,
    #  "Hepatitis B surface antibody (HBsAb)"               =	713,
    #  "IgM antibody to Hep B core antigen (IgM anti-HBc)"  =	714,
    #  "Hepatitis C total viral load (HCV RNA)"             =	721,
    #  "Hepatitis C virus serology, antibody (HCV Ab)"      =	722,
    #  "Hepatitis C genotyping"                             =	723,
    #  "Hepatitis C resistance testing (RAV testing)"       =	724,
    #  "magnetic resonance imaging (MRI) - joint"           =	5210,
    #  "ultrasound (US) - joint"                            =	5310,
    #  "radiograph (X-ray) - chest"                         =	5410,
    #  "radiograph (X-ray) - joint"                         =	5420,
    #  "bone density scan (DXA)"                            =	5500
    # ),
    
    img_finding_code = c(
      "bone marrow edema"         =	1,
      "deformity"                 =	2,
      "doppler signal"            =	3,
      "erosions"	                = 4,
      "joint space narrowing"	    = 5,
      "osteitis"	                = 6,
      "synovitis"	                = 7,
      "other changes"	            = 8,
      "1/3 radius t-score"	      = 11,
      "femoral neck t-score"	    = 12,
      "lumbar spine t-score"	    = 13),
    
    lab_img_result_intpn_code = c(
      # imaging
      "abnormal"                  = 1L,
      "new"                       = 2L,
      "normal"                    = 3L,
      "not present"               = 4L,
      "old"                       = 5L,
      "old and new"               = 6L,
       "present"                  = 7L,
      # labs
      "positive"	                = 1000,
      "reactive"	                = 1100,
      "detected (specify)"	      = 1399,
      "negative"	                = 2000,
      "non-reactive"              =	2100,
      "not detected"	            = 2300,
      "high non-response"         = 2500,
      "very high non-response"	  = 2600,
      "result unknown"            =	9771
      
    ), 
    
    lab_lipid_meds_code    = c("yes" = 1),
    lab_lipid_fasting_code = c(
      "non-fasting"            = 0,
      "fasting"                = 1,
      "fasting status unknown" = 97
    ),
    

    lab_result_lt_or_gt_code  = c(
      "<"      = 1,
      ">"      = 2
    ), 
    
    lab_uln_value_lt_code = c("<"  = 1), 
    
    img_cxr_evidence_of_tb = c(
      "no"    = 0,
      "yes"   = 1
    ),
    
    img_mri_field_strength_code = c(
      "high field (>=1.0T)"  = 11,
      "low field (<1.0T)"    = 12
    ),
    img_dxa_tscore_sign_code = c(
      "-"  = 1,
      "+"  = 2
    ),
    img_dxa_machine_type_code = c(
      "Hologic"  = 1,
      "Lunar"    = 2,
      "Norland"  = 3
    ),
    # study_source_acronym        = c("CERTAIN-PRETM" = 1,
    #                                 "CERTAIN-TM"    = 2,
    #                                 "RA-PRETM"      = 3,
    #                                 "RA-TM"         = 4,
    #                                 "RA-RCC"        = 5)
  )  %>% 
  # drop vars that have a *_code var 
  select(-c(
    lab_img_name,
    lab_img_result_intpn,
    lab_lipid_meds,
    lab_lipid_fasting,
    lab_result_lt_or_gt, 
    lab_uln_value_lt,
    cxr_evidence_of_tb,
    img_mri_field_strength,
    img_dxa_tscore_sign,
    img_dxa_machine_type,
    parent_study_acronym, 
    # parent_study_uid,
    # study_uid,
    x_edc_event_ordinal,
    lab_result_unit_raw,
    img_finding,
    lab_img_name_code
    
  )) %>% 
  rename(
    lab_img_name             = lab_img_name_clean,
    lab_img_result_intpn     = lab_img_result_intpn_code,
    lab_lipid_meds           = lab_lipid_meds_code,
    lab_lipid_fasting        = lab_lipid_fasting_code,
    lab_result_lt_or_gt      = lab_result_lt_or_gt_code, 
    lab_uln_value_lt         = lab_uln_value_lt_code,
    # cxr_evidence_of_tb       = cxr_evidence_of_tb_code  ,
    img_mri_field_strength   = img_mri_field_strength_code,
    img_dxa_tscore_sign      = img_dxa_tscore_sign_code,
    img_dxa_machine_type     = img_dxa_machine_type_code,
    img_finding              = img_finding_code
  ) %>% 


  mutate(
    # per ying, remove obs where lab date and lab result are missing. if lab date 
    miss_dt_result_raw = if_else(is.na(lab_img_dt_raw) & is.na(lab_img_result_raw), 1L, 0L, 0L),
  ) %>% 
  filter(miss_dt_result_raw == 0) %>% 
  select(-miss_dt_result_raw)%>% 
  select(subject_number, 
         site_number,
         c_effective_event_date,
         dw_event_type_acronym,
         full_version,
         # study_source_acronym,
         c_provider_id,
         lab_img_type,
         lab_img_dt,
         lab_img_name,
         img_finding, 
         lab_result_lt_or_gt,
         lab_img_result,
         lab_result_unit_code,
         lab_img_result_intpn,
         lab_uln_value_lt,
         lab_uln_value,
         lab_lipid_meds,
         lab_lipid_fasting,
         lab_hep_c_type,
         lab_hep_c_subtype,
         img_cxr_evidence_of_tb,
         img_mri_field_strength,
         img_us_tot_joints,
         img_dxa_tscore_sign,
         img_dxa_bmd,
         img_dxa_machine_type,
         lab_img_dt_raw,
         lab_img_result_raw,
         lab_result_unit_code_raw,
         img_result_code_raw,
         lab_uln_value_raw
         
         )%>% 
  arrange(subject_number, c_effective_event_date, lab_img_name, lab_img_dt, img_finding, full_version) %>% 
  group_by(subject_number, c_effective_event_date, lab_img_name, lab_img_dt, img_finding) %>% 
  mutate(
    tot                  = n(),
    row_n                = row_number()
  ) %>% 
  ungroup()
  

# keep the latest version
# if data is missing from the latest version, fill using previous version
all_labs_labelled_dupes <- all_labs_labelled  %>% 
  filter(tot > 1)%>% 
  fill(everything(), 
       .direction = "down") %>% 
  filter(tot == row_n) %>% 
  arrange(subject_number, c_effective_event_date, lab_img_name, lab_img_dt, img_finding, full_version)  

all_labs_labelled_deduped <- all_labs_labelled %>% 
  # keep instances where there are no dupes
  filter(tot == 1) %>% 
  bind_rows(., all_labs_labelled_dupes) %>% 
  select(-tot, -row_n)%>% 
  # apply variable labels here; they are dropped if set earlier
  set_variable_labels(
    c_effective_event_date          = "Registry visit date",
    dw_event_type_acronym           = "Form type",
    site_number                     = "Site ID",
    subject_number                  = "Subject ID",
    full_version                    = "Form version",
    c_provider_id                   = "Provider ID",
    # study_source_acronym            = "Study source",
    lab_img_name                    = "Lab or imaging name",
    lab_img_result_intpn            = "Lab or imaging result interpretation",
    lab_img_result_raw              = "Raw result value for lab or imaging",
    lab_result_unit_code_raw        = "Raw unit code value for lab tests",
    lab_img_dt                      = "Date of lab or imaging test",
    lab_uln_value_raw               = "Raw upper limit normal value for lab tests",
    lab_lipid_meds                  = "On lipid lowering medications at time of testing",
    lab_lipid_fasting               = "Subject fasting for lipid panel",
    lab_hep_c_type                  = "Heptitis C genotyping types 1-6",
    lab_hep_c_subtype               = "Heptitis C genotyping subtype",
    lab_img_type                    = "Lab or imaging indicator",
    lab_result_lt_or_gt             = "Lab result less or greater than",
    lab_uln_value_lt                = "Upper Limit of Normal less than",
    lab_uln_value                   = "Upper Limit of Normal value",
    lab_img_result                  = "Lab or imaging result",
    lab_result_unit_code            = "Lab result unit code",
    img_finding                     = "Imaging finding",
    img_cxr_evidence_of_tb          = "Evidence of TB in abnormal chest x-ray",
    img_us_tot_joints               = "Total number of joints in ultrasound",
    img_mri_field_strength          = "MRI field strength",
    img_dxa_tscore_sign             = "T-score sign for bone density imaging",
    img_dxa_bmd                     = "Bone densitometry for bone imaging",
    img_dxa_machine_type            = "Machine type used for bone imaging",
    lab_img_dt_raw                  = "Raw lab or imaging date",
    img_result_code_raw             = "Raw imaging result code"
  ) 

# all_labs_codebook <- look_for(all_labs_labelled_deduped, details = "full") %>% 
#   convert_list_columns_to_character() %>% 
#   print()
# 
# write.csv(all_labs_codebook, "./data/alllabs_codebook.csv")

# temp_location <- glue("{sharepoint}/Biostat Data Files - RA/Data Warehouse Project 2020 - 2021/Analytic File/data/clean_table")
# LG 2024-07-05 use temp test folder instead of clean_table folder 
# LG 2024-07-10 save to clean_table folder
ra_monthly <- glue("{sharepoint}/Biostat Data Files - RA/monthly/{cut_year}/{cut_date}/clean_table")
dir.exists(ra_monthly)


haven::write_dta(all_labs_labelled_deduped, glue("{ra_monthly}/1_4_alllabs.dta"))
# LG not saving R data for now. Only keep the stata file
#saveRDS(all_labs_labelled_deduped, glue("{ra_monthly}/1_4_alllabs.rds"))

