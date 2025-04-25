install.packages("RODBC")
install.packages("odbc")
install.packages("DBI")
library(DBI)
library(odbc)
library(glue)
library(foreign)
library(haven)
# Establish a connection
conn <- dbConnect(odbc::odbc(), dsn = "dwh")

# Load the data from the specified table
# bv_labs <- dbReadTable(conn, "ra_20250108.bv_labs")
bv_labs <- dbGetQuery(conn, "SELECT * FROM ra_20250108.bv_labs")
# Close the connection
dbDisconnect(conn)
sharepoint <- "~/../../Corrona LLC/"
bv_raw  <- glue("{sharepoint}Biostat Data Files - RA/monthly/2025/2025-01-01/bv_raw")
dir.exists(bv_raw)
write_dta(bv_labs, glue("{bv_raw}/bv_labs.dta"))
