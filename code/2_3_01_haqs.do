


cd "~/Corrona LLC/Biostat Data Files - RA/monthly/2024/2024-08-01" 



********************************************************
use "bv_raw\bvcalc_haqs", clear 

keep if dw_event_type_acronym== "EN" | dw_event_type_acronym== "FU" | dw_event_type_acronym =="RFU"
drop if c_effective_event_date=="" & haq_di6_non_missing_components==0 // missing visitdate and missing all haq fields 

*deduplicates by RFU 
sort dw_event_instance_uid c_effective_event_date dw_event_type_acronym 
by dw_event_instance_uid c_effective_event_date: drop if _N==2 & dw_event_type_acronym=="RFU" & dw_event_type_acronym[1]=="EN" 

gen visitdate=date(c_effective_event_date, "YMD") 
format visitdate %tdCCYY-NN-DD 

keep dw_event_instance_uid subject_number visitdate full_version haq_*  mhaq_* 
destring full_version, replace 
unique dw_event_instance_uid 

rename haq_dress_yourself_code dress_self
rename haq_shampoo_hair_code shampoo_hair
rename haq_stand_up_chair_code stand_up_chair
rename haq_get_in_out_bed_code get_in_out_bed
rename haq_cut_meat_code cut_meat
rename haq_lift_cup_glass_code lift_cup_glass
rename haq_open_carton_code open_cartons
rename haq_walk_outdoors_code walk_outdoors
rename haq_climb_5_steps_code climb_5_steps
rename haq_wash_dry_body_code wash_dry_body
rename haq_take_bath_code take_tub_bath
rename haq_on_off_toilet_code get_on_off_seat
rename haq_reach_get_down_code reach_get_down
rename haq_bend_down_pick_up_code bend_down
rename haq_open_car_door_code open_car_doors
rename haq_open_jars_code open_jars
rename haq_turn_faucets_code turn_faucets
rename haq_run_errands_code run_errands
rename haq_get_in_out_car_code get_in_out_car
rename haq_chores_code vacuuming

rename haq_aids_cane_code aids1_cane
rename haq_aids_crutches_code aids1_crutches
rename haq_aids_walker_code aids1_walker
rename haq_aids_wheelchair_code aids1_wheelchair
rename haq_aids_special_chair_code aids1_special_chair
rename haq_aids_special_utensils_code aids1_spec_utensils
rename haq_aids_dressing_devices_code aids1_dev_dressing 

rename haq_aids_raised_toilet_seat_code aids2_raised_toilet
rename haq_aids_bathtub_seat_code aids2_bathtub_seat
rename haq_aids_jar_opener_code aids2_jar_opener
rename haq_aids_bathtub_bar_code aids2_bathtub_bar
rename haq_aids_longhandled_reach_code aids2_long_ap_reach
rename haq_aids_longhand_bathroom_code aids2_long_ap_bath 

rename haq_help_dressing_code act1_dress_groom
rename haq_help_arising_code act1_arising
rename haq_help_eating_code act1_eating
rename haq_help_walking_code act1_walking

rename haq_help_hygiene_code act2_hygiene
rename haq_help_reach_code act2_reach
rename haq_help_gripping_code act2_grip_and_open
rename haq_help_errands_code act2_errands

rename haq_walk_miles_km_code walk_2_milies 
rename haq_rec_activities_sports_code activities_sports 

 
* mHAQ score (di) 
gen haqraw=0
gen dinmiss=0
local list dress_self get_in_out_bed lift_cup_glass walk_outdoors wash_dry_body bend_down turn_faucets get_in_out_car 
foreach x of local list{
qui replace haqraw=haqraw + `x' if `x' > 0 & `x'<=3 
qui replace dinmiss=dinmiss+1 if `x'>=0 & `x'<=3 
} 

gen double di=haqraw/dinmiss if dinmiss>=6  
format di %9.4f 
lab var di "mHAQ"  


drop haqraw dinmiss 

* full HAQ -haq_id

***dress****
egen dress=rowmax(dress_self shampoo_hair) 
replace dress=2 if (aids1_dev_dressing==1 | act1_dress_groom==1) & (dress<2 | dress==.) 

***arising****
egen arising=rowmax(stand_up_chair get_in_out_bed)
replace arising=2 if (aids1_special_chair==1 |act1_arising==1) & (arising<2 | arising==.) 

***eating****
egen eating=rowmax(cut_meat lift_cup_glass open_cartons ) 
replace eating=2 if (aids1_spec_utensils==1 |act1_eating==1) & (eating<2 | eating==.)  

***walking***
egen walking=rowmax(walk_outdoors climb_5_steps )
egen walk_aids=rowmax(aids1_cane aids1_walker aids1_crutches aids1_wheelchair) 
replace walking=2 if (walk_aids==1 |act1_walking==1) & (walking<2 | walking==.)

***hygiene*** 
egen hygiene=rowmax(wash_dry_body take_tub_bath get_on_off_seat)
egen hygiene_aids=rowmax(aids2_raised_toilet aids2_bathtub_seat aids2_bathtub_bar aids2_long_ap_bath) 
replace hygiene=2 if (hygiene_aids==1 |act2_hygiene==1) & (hygiene<2 | hygiene==.) 

***reach***
egen reach=rowmax(reach_get_down bend_down) 
replace reach=2 if (aids2_long_ap_reach==1 |act2_reach==1) & (reach<2 | reach==.) 

***grip*** 
egen grip=rowmax(open_car_doors open_jars turn_faucets) 
replace grip=2 if (aids2_jar_opener==1 |act2_grip_and_open==1) & (grip<2 | grip==.) 

***activities*** 
egen activities=rowmax(run_errands get_in_out_car vacuuming) 
replace activities=2 if act2_errands==1 & (activities<2 | activities==.) 

egen dinmiss=rownonmiss(dress arising eating walking hygiene reach grip activities) 
egen haqraw=rsum(dress arising eating walking hygiene reach grip activities)

gen haq_di=haqraw/dinmiss 
replace haq_di=. if dinmiss< 6

replace haq_di=. if full_version>4 & full_version<8 // full HAQ only collected in version 4 and 8-15 

lab var haq_di "HAQ-DI" 

drop haqraw dinmiss walking

* version 15 with two new fields for walking, created new variable: haq_di_v15
***walking***
egen walking=rowmax(walk_outdoors climb_5_steps walk_2_milies activities_sports )
replace walking=2 if (walk_aids==1 | act1_walking==1) & (walking<2 | walking==.)

egen dinmiss=rownonmiss(dress arising eating walking hygiene reach grip activities) 
egen haqraw=rsum(dress arising eating walking hygiene reach grip activities)

gen haq_di_v15=haqraw/dinmiss 
replace haq_di_v15=. if dinmiss< 6
replace haq_di_v15=. if full_version>4 & full_version<8 // full HAQ only collected in version 4 and 8-15 
lab var haq_di_v15 "HAQ-DI (new)" 

drop dinmiss haqraw dress arising eating walking hygiene reach grip activities hygiene_aids walk_aids  

notes haq_di_v15: version 15 add two new variables (walk two miles and participate in sports) in walking domain

save temp\bv_haqs_clean, replace 











