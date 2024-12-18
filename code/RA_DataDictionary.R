# 2024-10-28 improve data format transfer process by using a loop to transfer all stata data
# in the same folder to R. Testing using 2024-09-01 datacut.Time difference of 3.006759 hours
# save analytic data into DQ folder
# 2024-10-25 data dictionary only==> 
# Note: the clean table folder takes Time difference of 55.40355 mins
# Load/install Libraries
library(magrittr)
library(arrow, warn.conflicts = FALSE)
library(tidyverse)
library(lubridate)
library(zoo)
library(arsenal)
library(haven) #  transforming stata data file to R 
library(huxtable)
library(DataCombine)
library(labelled)
#library(RODBC)
library(XML)
library(DBI)
library(glue)

library(readxl) # read excel data 

# Save starting time to measure how long to run code
start_time <- Sys.time()
# Get Today's date
tdy_date <- Sys.Date()
tdy_year  <- sprintf("%04d", year(tdy_date))
tdy_day   <- sprintf("%02d", day(tdy_date))
tdy_month <- sprintf("%02d", month(tdy_date))

# Put in standard naming format (updated)
tdy <- glue("{tdy_year}-{tdy_month}-{tdy_day}")

# setwd("C:/Users/lguo/Documents/R-learning/data_dictionary")
sharepoint <- "~/../../Corrona LLC/"
# shared_data  <- glue("{sharepoint}Biostat Data Files - RA/monthly/")
# testthat::expect_true(dir.exists(shared_data),  label = "shared_data directory must exist")

clean_table  <- glue("{sharepoint}Biostat Data Files - RA/monthly/{tdy_year}/{tdy_year}-{tdy_month}-01/clean_table")
testthat::expect_true(dir.exists(clean_table),  label = "clean_table directory must exist")

analytic_data  <- glue("{sharepoint}Biostat Data Files - RA/monthly/{tdy_year}/{tdy_year}-{tdy_month}-01")
testthat::expect_true(dir.exists(analytic_data),  label = "analytic_data directory must exist")

bv_raw  <- glue("{sharepoint}Biostat Data Files - RA/monthly/{tdy_year}/{tdy_year}-{tdy_month}-01/bv_raw")
testthat::expect_true(dir.exists(bv_raw),  label = "raw data directory must exist")

dq_data  <- glue("{sharepoint}Biostat Data Files - RA/DQ checks/Data/{tdy_year}/{tdy_year}-{tdy_month}-01")
testthat::expect_true(dir.exists(dq_data),  label = "dq_data directory must exist")


# Get a list of all .dta files in the directory
file_list <- list.files(clean_table, pattern = "\\.dta$", full.names = TRUE)

# Loop over each file: import, then save as .RDS
for (file in file_list) {
  # Extract the base name of the file (without directory and extension)
  file_name <- tools::file_path_sans_ext(basename(file))
  
  # Import the file using haven
  data <- read_dta(file)
  
  # Save each dataset as an RDS file
  saveRDS(data, file = file.path(clean_table, paste0(file_name, ".rds")))
}

# Now each dataset is saved as an individual .rds file in the specified save directory

# 2024-10-28 also save the 2.X data into clean_table folder to test data dictionary
# put RDS data into DQ folder
# Get a list of all .dta files in the directory
file_list <- list.files(analytic_data, pattern = "\\.dta$", full.names = TRUE)
# Loop over each file: import, then save as .RDS
for (file in file_list) {
  # Extract the base name of the file (without directory and extension)
  file_name <- tools::file_path_sans_ext(basename(file))
  
  # Import the file using haven
  data <- read_dta(file)
  
  # Save each dataset as an RDS file
  saveRDS(data, file = file.path(dq_data, paste0(file_name, ".rds")))
}
# 2024-11-05: column K has quotation marks, deleted and renamed as _simple 
# Raw spec staging data
specs_condensed <- read_excel(glue("{bv_raw}/specs_view_definitions.xlsx")) %>% 
  # still seeing multiple rows for the same variable since the question text is different 
  # between forms e.g., md_cod; this happens when no applying distinct to QUESTEXT, Datamart_Variable, FormTypeName;
  # assuming if there is significant change to a question, a new variable would be created and not recycled
  distinct(specs_column_name, specs_view_name, .keep_all = TRUE) %>% 
  select(description, specs_column_name, specs_view_name) %>% #, is_released
  group_by(specs_column_name) %>%
  mutate(
    FormTypeName2 = paste(specs_view_name, collapse = ", "),
    #current_crf   = max(LastREV)
  ) %>% 
  ungroup() %>% 
  distinct(FormTypeName2, specs_column_name, .keep_all = TRUE) %>%
  select(-specs_view_name) %>% #, -LastREV
  rename(specs_view_name = FormTypeName2)
# List of all analytic datasets
# Local Analytic data folder
# analytic_data <- "C:/Users/lguo/Documents/R-learning/data_dictionary"

# 2024-11-05 LG: use the R data in DQ initiative folder 
ds_list <- tools::file_path_sans_ext(list.files(dq_data, pattern = "\\.rds$"))

# Create base codebook/data dictionary from labelled ----
cb_dd_list <- ds_list %>% 
  map(~labelled::look_for(readRDS(glue("{dq_data}/{.x}.rds")), details = "full") %>% 
        # collapse variable values to one row
        convert_list_columns_to_character()) %>% 
  set_names(ds_list) 



# Create workbooks to add formatted sheets to, one for codebook, one for data dictionary ----
wb_dd <- openxlsx::createWorkbook()
# add title worksheet to WB
openxlsx::addWorksheet(wb_dd, sheetName = "Title Page")

# Pull data attributes ----LG: not used for DD?
# attr_list <- ds_list %>% 
#   map(~ lapply(readRDS(glue("{analytic_data}/{.x}.rds")), attributes)) %>% 
#   set_names(ds_list)


# Create title page
dd_title_page <- data.frame(label    = c("RA US Data Dictionary", "", "", "", ""),
                            var      = c("", "", "", "Generated On", "Current CRF Version"),
                            data     = rep("", 5),
                            v3       = rep("", 5)) %>%
  mutate(
    data = case_when(var == "Generated On" ~ as.character(tdy_date),
                     var == "Current CRF Version" ~ as.character(15),
                     TRUE ~ "")) %>%
  rename(
    " " = label,
    "  " = var,
    "   " = data,
    "    " = v3
  )

# output title page to WB
openxlsx::writeDataTable(wb_dd, "Title Page", dd_title_page, withFilter = FALSE)

## Data Dictionary ----
# Function to create data dictionaries for each analytic dataset
dd_func <- function(df) {
  
  # add a sheet to workbook that will be saved
  openxlsx::addWorksheet(wb = wb_dd, sheetName = df)
  
  # subset to correct dataset in list
  dd <- as.data.frame(cb_dd_list[[df]]) %>%
    mutate(
      range = ifelse((col_type == "chr" | value_labels != ""), "", range),
    ) %>%
    select(variable:col_type, value = value_labels, range) %>%
    left_join(., specs_condensed %>%
                # duplicate rows coming through since variable can exist on more than one form
                # e.g., visitdate on MDFU, MDEN
                distinct(specs_column_name,
                         specs_view_name,
                         description),
              by = c("variable" = "specs_column_name")) %>%
    # Create optional columns
    mutate(
      `Analytic Measurement unit` = NA,
      `Analytic validation`       = NA,
      `Important notes`           = NA,
      `Analytic Range expected`   = NA,
    ) %>%
    select(`Analytic File Variable name` = variable, 
           `Current CRF form` = specs_view_name,
           `Question text` = description,
           `Analytic Variable label` = label, 
           `Analytic Variable values` = value, 
           `Analytic Range expected`,
           `Analytic Range observed` = range, 
           `Analytic format` = col_type,
           `Analytic Measurement unit`,
           `Analytic validation`,
           `Important notes`) 
  
  # Add in expected ranges for calculated variables==> LG: not applicable to RA
  # dd <- dd %>%
  #   mutate(
  #     `Analytic Range expected` = case_when(
  #       `Analytic File Variable name` == "mayo_index_part"         ~ "range: 0-9",
  #       `Analytic File Variable name` == "SCCAI"                   ~ "range: 0-19",
  #       
  #       
  #       TRUE ~ NA_character_)
  #   )  
  
  # add file to workbook
  openxlsx::writeDataTable(wb_dd, df, x = dd)
}

# Apply dd function to all analytic datasets
data_dictionaries <- ds_list %>%
  map(~dd_func(.x)) %>% 
  set_names(ds_list)
# Save ----
openxlsx::saveWorkbook(wb_dd, glue("{analytic_data}/RA_datadictionary_{tdy_year}-{tdy_month}-01.xlsx"), overwrite = TRUE)
# Time to Run
end_time <- Sys.time()
total_time <- end_time - start_time
print(total_time)