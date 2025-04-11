#------------------------------------------------------------------------------
# Program: 16_clean_exit_data.R
# Date:    
# Author:  Marie Gurrola
# Purpose: 
#------------------------------------------------------------------------------
#-----------------------------------------------------------
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
library(arrow)
library(tidyverse)

#-------------
# Set date parameters
#-------------
tdy_date <- Sys.Date()
# cut date to use while BVs are still in odbc
cut_date    <- as.Date("2025-04-01")

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

# As of Jan 2024, it's still undecided if exit events will be included in the clean
# exit data

exit_clean <- haven::read_dta(glue("{bv_raw}/bv_exits.dta")) %>% 
  # new variables added with "_tst" suffix -- remove
  select(-ends_with("tst"), -contains("var72")) %>%  
  # remove test site 999
  filter(site_number != "999") %>% 
  mutate(c_effective_event_date = as.Date(c_effective_event_date, format = "%Y-%m-%d")) %>% 
  select(
    -c(# dw_event_instance_uid, # this var can be used to link subs/visits between different data sets
      # 2025-02-04 changed variable names  
      c_site_key,
      c_subject_key, 
       # x_edc_event_instance_uid,
       # dw_event_type_acronym
    )) %>% 
  # standardize var names to what's in RAviews_v15; temporarily keeping the char and *_code vars to ensure
  # things are being mapped correctly
  rename(exit_form_dt                     = c_effective_event_date, 
         exit_reason_code            = reason_discontinuation_code, 
         exit_reason                 = reason_discontinuation,
         # provider_id                 = c_provider_id,
         # created_date                = exit_report_dt,
         last_contact_dt             = reason_fu_last_contact_dt,
         death_dt                    = reason_death_dt,
         exit_comments               = additional_comments, 
         death_drug                  = death_related_ra_tx, 
         death_drug_name             = death_related_ra_tx_spec,
         death_drug_code             = death_related_ra_tx_code,
         diagnosis_death             = death_pt_diagnosis, 
         diagnosis_death_code        = death_pt_diagnosis_code, 
         death_rheum_diag_c1         = death_pt_diagnosis_ra,
         other_spec                  = reason_discontinuation_oth_spec,
         exit_certain_lastvisit_code = exit_certain_last_visit_code,
         exit_certain_lastvisit      = exit_certain_last_visit,
         # discontinue_date            = confirm_subject_exit_dt,
         death_rheum_diag_c1_code    = death_pt_diagnosis_ra_code,
         
         death_hosp                  = death_hospital_setting, 
         death_hosp_code             = death_hospital_setting_code, 
         death_hosp_unk              = death_hospital_setting_unk, 
         death_hosp_unk_code         = death_hospital_setting_unk_code, 
         exit_registry               = confirm_pt_exit_registry,
         exit_registry_code          = confirm_pt_exit_registry_code,
         drug_use                    = event_bio_exp_since_coll, # only for v15
         drug_use_code               = event_bio_exp_since_coll_code,# only for v15

         exit_certain_substudy       = exit_certain, 
         exit_certain_substudy_code  = exit_certain_code, 
         exit_certain                = exit_certain_participant, 
         exit_certain_code           = exit_certain_participant_code,
         exit_substudy               = exit_t2t,
         exit_substudy_code          = exit_t2t_code,
         # id                          = subject_number,
         full_version                 = full_version,
         exit_site_withdrew          = confirm_exit_site_withdrew,
         # site_id                     = site_number, 
         # parent_study                = parent_study_uid, 
         
  )  %>% 
  mutate(
    # other_spec  = i
    site_number       = as.numeric(site_number),
    death_dt          = as.Date(death_dt, format = "%Y-%m-%d"), 
    last_contact_dt   = as.Date(last_contact_dt, format = "%Y-%m-%d"),
    exit_report_dt    = as.Date(exit_report_dt, format = "%Y-%m-%d"),
    
    across(
      .cols    = c(exit_substudy, exit_registry),
      .fns     = ~case_when(
        .x == "yes"  ~ 1L,
        .x == "no"   ~ 0L,
        TRUE                 ~ NA_integer_
      )
    )
  )  %>% 
  mutate(
    # oth_spec has encoding issues; i.e., hidden characters in text
    rsn_disc_encoding_ori = Encoding(other_spec),
    # temporarily change encoding to help identify issues
    text_latin1 = {
      x           <- other_spec
      Encoding(x) <- "latin1"
      x           <-gsub('"|â€\u009d|â€œ', '', x)
      # x           <- gsub('\x93|\x94', '', x) # LG 2024-10-28, giving error message, ignored.
      x           <- gsub('â€“', "-", x)
      x           <- gsub('“|”', "", x)
      
      x
    },
    
    other_spec_temp =  text_latin1,
    
    other_spec_temp = {
      Encoding(other_spec_temp) <- "unknown"
      other_spec_temp
    },
    
    # remove white space
    other_spec_temp = trimws(other_spec_temp), 
    # remove double spaces
    other_spec_temp = gsub("  ", " ", other_spec_temp), 
    
    rsn_disc_encoding = Encoding(other_spec_temp),
    # convert vars to numeric
    across(
      .cols = c(#c_provider_id, 
                # parent_study,
                # study_uid, 
                full_version),
      .fns  = ~as.numeric(.x)
    ),
    # convert "" to NA for character vars
    across(
      .cols  = c(other_spec_temp, 
                 exit_comments,
                 death_drug_name),
      .fns   = ~if_else(.x == "", NA_character_, .x )
    ),
    
    # update diagnosis_death_codes to pTM and TM
    diagnosis_death_code = case_when(
      diagnosis_death_code == 10110 ~ 1L,
      diagnosis_death_code == 10090 ~ 2L,
      diagnosis_death_code == 22040 ~ 3L,
      diagnosis_death_code == 21030 ~ 4L,
      # add op risk; there are no counts but include it 
      diagnosis_death_code == 21033 ~ 5L,
      diagnosis_death_code == 10101 ~ 6L,
    ),
    # all RA values = 2
    # parent_study = if_else(parent_study == 2, 1L, parent_study),
    
    # convert character to numeric to allow for labeling
    # study_source_acronym_temp = case_when(
    #   study_source_acronym == "CERTAIN-PRETM" ~ 1,
    #   study_source_acronym == "CERTAIN-TM"    ~ 2,
    #   study_source_acronym == "RA-PRETM"      ~ 3,
    #   study_source_acronym == "RA-TM"         ~ 4,
    #   study_source_acronym == "RA-RCC"        ~ 5,
    # )
    
  ) %>% 
  # do not have minor or full version in TM/PTM
  select(-c(other_spec, 
            text_latin1, 
            rsn_disc_encoding_ori, 
            rsn_disc_encoding, 
            study_acronym, 
            # study_source_acronym, 
            exit_site_withdrew
            # parent_study_acronym
            )) %>% 
  arrange(subject_number, exit_form_dt) %>% #, study_source_acronym_temp) %>% 
  rename(oth_exit_reason_spec = other_spec_temp,
         # study_acronym        = study_uid,
         # study_source_acronym = study_source_acronym_temp,
         exit_site_withdrew   = confirm_exit_site_withdrew_code) 



# 2025-04-02 LG removed 2 c_is variables from the list, not available
exit_labelled <- exit_clean %>% 
  # remove the char vars & intermediary bv vars
  select(-c(exit_reason, 
            death_drug, 
            diagnosis_death,
            exit_certain_lastvisit,
            death_rheum_diag_c1,
            death_hosp,
            exit_registry,
            drug_use, 
            exit_certain_substudy, 
            exit_substudy,
            death_hosp_unk,
            exit_certain,
            c_is_suppressed_exit,
            c_is_redundant_enrollment,
            # c_is_redundant_followup,
            # c_is_enrollment_out_of_order,
            # study_uid,
            parent_study_acronym #,
            # parent_study_uid,
            # confirm_data_entry,
            # confirm_data_entry_code,
            # dw_event_instance_uid
            )) %>%
  rename(exit_reason            = exit_reason_code,
         death_drug             = death_drug_code,
         diagnosis_death        = diagnosis_death_code,
         exit_certain_lastvisit = exit_certain_lastvisit_code,
         death_rheum_diag_c1    = death_rheum_diag_c1_code,
         death_hosp             = death_hosp_code,
         exit_registry          = exit_registry_code,
         drug_use               = drug_use_code,
         exit_certain_substudy  = exit_certain_substudy_code,
         exit_substudy          = exit_substudy_code,
         death_hosp_unk         = death_hosp_unk_code,
         exit_certain           = exit_certain_code) %>% 
  # use *_code variables to create clean version of the data
  set_value_labels(
  #   NEED TO CONFIRM THE OTHER EXIT REASON VALUES WITH ISAIAS
  exit_reason    = c("Patient withdrew consent"                                                               = 1,
                     "Patient lost to follow-up (unknown vital status)"                                       = 2,
                     "Patient died"                                                                           = 3,
                     "Patient  moved"                                                                         = 5,
                     "Administrative reasons"                                                                 = 6,
                     "Patient enrolled into a double-blind, randomized drug trial for an RA medication"       = 7,
                     "Change in insurance (loss of coverage or plan no longer accepted by registry provider)" = 8,
                     "Patient was misdiagnosed (does not have rheumatoid arthritis)"                          = 9,
                     "Patient switched to another provider"                                                   = 10,
                     "Site withdrew from registry and none of the other exit reasons apply"                   = 88,
                     "Other reason for exit (specify)"                                                        = 99 ),
 
  diagnosis_death = c("Rheumatoid Arthritis (RA)"                 = 1,
                           "Psoriatic Arthritis (PSA)"            = 2,
                           "Osteoarthritis"                       = 3,
                           "Osteoporosis"                         = 4,
                           "Osteoporosis (OP) risk"               = 5,
                           "Undifferentiated Arthritis New Onset" = 6 ),
  exit_certain_lastvisit = c("Screening enrollment"  = 1,
                                  "Baseline"              = 2,
                                  "3-month follow-up"     = 3,
                                  "6-month follow-up"     = 4,
                                  "9-month follow-up"     = 5),
  # parent_study                = c("RA" = 1),
  # study_acronym               = c("CERTAIN" = 1, "RA" = 2),
  # study_source_acronym        = c("CERTAIN-PRETM" = 1,
  #                                 "CERTAIN-TM"    = 2,
  #                                 "RA-PRETM"      = 3,
  #                                 "RA-TM"         = 4,
  #                                 "RA-RCC"        = 5)
  ) %>% 
  mutate(
  # Loop through all value lables with yes/no/unk
    across(
      .cols   = c(death_drug),
      .fns    = ~set_value_labels(., .labels = c("Yes" = 1, 
                                                "No" = 0, 
                                                "Unknown" = 99)),
      .names = "{.col}"
    ),
  
  # Loop through all value lables with yes/no

    across(
      .cols   = c(death_hosp,
                  drug_use,
                  exit_certain_substudy,
                  death_hosp_unk),
      .fns    = ~set_value_labels(., .labels = c("Yes" = 1, "No" = 0)),
      .names = "{.col}"
    ),
    # Loop through all value lables with yes
    across(
      .cols   = c(death_rheum_diag_c1, 
                  exit_registry,
                  exit_site_withdrew,
                  exit_substudy,
                  exit_certain),
      .fns    = ~set_value_labels(., .labels = c("Yes" = 1)),
      .names = "{.col}"
    )
  )  %>% 
  # order vars
  # 2025-02-04 changed variable name and do not include c_dw_event_instance_key
  # 2025-03-05 LG adding created/modified date to further clean exit_form_dt
  select(c_dw_event_instance_key,
         # parent_study, 
         # study_acronym, 
         subject_number, 
         site_number,
         exit_form_dt,
         c_event_created_date, 
         c_event_last_modified_date,
         dw_event_type_acronym,
         full_version,
         # study_source_acronym,
         c_provider_id,
         death_dt,
         last_contact_dt,
         exit_reason, 
         oth_exit_reason_spec,
         drug_use, 
         exit_comments,
         death_drug, 
         death_drug_name,
         death_hosp, 
         death_hosp_unk,
         everything()
         
         )  %>% 
  # identify duplicates; 0rder by full_version; 
  arrange(subject_number, exit_form_dt, full_version) %>% 
  group_by(subject_number, exit_form_dt) %>% 
  mutate(
    tot                  = n(),
    row_n                = row_number()
  ) %>% 
  ungroup()

# keep the latest version
# if data is missing from the latest version, fill using previous version
exit_dupes <- exit_labelled %>% 
  filter(tot > 1) %>% 
  fill(everything(), 
       .direction = "down") %>% 
 filter(tot == row_n) 


# append deduped data 
exit_labelled_deduped <- exit_labelled %>% 
  # keep instances where there are no dupes
  filter(tot == 1) %>% 
  bind_rows(., exit_dupes) %>% 
  select(-tot, -row_n) %>% 
  arrange(subject_number, exit_form_dt, full_version)%>% 
  # add variable labels 
  set_variable_labels(
    exit_form_dt                    = "Date exit date completed",
    # study_acronym                 = "Study acronym",
    dw_event_type_acronym           = "Form type",
    # parent_study                  = "Parent study",
    site_number                     = "Site ID",
    subject_number                  = "Subject ID",
    full_version                    = "Form version",
    c_provider_id                   = "Provider ID",
    # study_source_acronym            = "Study source",
    exit_report_dt                  = "Available only on version 11. CRF text: 'Date of this report'",
    exit_comments                   = "Additional exit comments",
    exit_registry                   = "Patient exited from CORRONA",
    # exit_site_withdrew              = "Exit site withdrew",
    death_hosp                      = "Death occurred in a hospital",
    death_hosp_unk                  = "Death of hospital unknown",
    diagnosis_death                 = "Patient diagnosis at death",
    death_rheum_diag_c1             = "Cause of death by RA",
    death_drug                      = "Death related to a particular drug for treatment of RA",
    death_drug_name                 = "If death related to drug, name of drug(s)",
    drug_use                        = "Received DMARD, JAKs or corticosterioid since last visit",
    exit_certain                    = "CERTAIN participant at exit",
    exit_certain_substudy           = "CERTAIN sub-study exit only",
    exit_certain_lastvisit          = "CERTAIN subject last visit type",
    exit_substudy                   = "Exiting from T2T sub-study",
    death_dt                        = "Date of death",
    exit_reason                     = "Reason for discontinuation",
    oth_exit_reason_spec            = "Other reason for exit",
    last_contact_dt                 = "Date of last contact with subject",
    c_dw_event_instance_key         = "Event instance UID",
    exit_site_withdrew              = "Subject exited by CorEvitas after site withdrew from registry"
    
  ) %>% 
  select(-death_rheum_diag_c1)

# temp_location <- glue("{sharepoint}/Biostat Data Files - RA/Data Warehouse Project 2020 - 2021/Analytic File/data/clean_table")
# 2025-01-14 save temp data then use stata to delete visitdate beyond cutdate and save with $datacut
ra_monthly <- glue("{sharepoint}/Biostat Data Files - RA/monthly/{cut_year}/{cut_date}/temp")
dir.exists(ra_monthly)

# exit_codebook <- look_for(exit_labelled_deduped, details = "full") %>% 
#   convert_list_columns_to_character() %>% 
#   print()
# 
# write.csv(exit_codebook, "./data/exit_codebook.csv")

# haven::write_dta(exit_labelled, "./data/1_5_exit.dta")

haven::write_dta(exit_labelled_deduped, glue("{ra_monthly}/1_5_exit_temp.dta"))
#saveRDS(exit_labelled_deduped, glue("{ra_monthly}/1_5_exit.rds"))
