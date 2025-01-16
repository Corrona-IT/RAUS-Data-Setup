/*
2025-01-14 place holder for further clean 1.5 exits data 
*/

use temp/1_5_exit_temp, clear

codebook exit_form_dt

count if exit_form_dt>d(31dec2024) // 38

count if exit_form_dt>d($cutdate)
drop if exit_form_dt>d($cutdate)

compress 
save "clean_table\1_5_exit_$datacut" , replace 
