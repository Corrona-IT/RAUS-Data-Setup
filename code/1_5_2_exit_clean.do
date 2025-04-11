/*
2025-01-14 place holder for further clean 1.5 exits data 
*/

use temp/1_5_exit_temp, clear

codebook exit_form_dt

count if exit_form_dt>d(31mar2025) // 19
*
count if exit_form_dt>d($cutdate)
drop if exit_form_dt>d($cutdate)

// 2025-04-02 LG added 
drop if site_number>=997
// 2025-03-04 LG drop 4 jr RA subjects 
for any 001010120 019100453 100140636 452722687: count if subject_number=="X"
for any 001010120 019100453 100140636 452722687: drop if subject_number=="X"
compress 
save "clean_table\1_5_exit_$datacut" , replace 
