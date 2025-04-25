/*
Aim: Created monthly report for Executive slides 
Date: 2024 08 06
Programmer: Ying Shan
Do file: revised from Monthly_excutive_slides_2024-07-10.do 
data use: monthly updated keyvisitvars 

report SharePint location: Biostat and Epi Team Site - Documents\Publications & Quarterly Reports\Quarterly Reports and Counts\Registry_Slides\data\2024\

2024-08-20 LG: corrected typos for row #28, States to states, preffectures to prefectures.
*/


*

// tab "overview"

putexcel set "RA-$rptdt.xlsx", sheet(overview) modify 
putexcel A1=("Variable") B1=("Total")  A2=("visits")  A3=("patients") A4=("sites")   A5=("investigators") A6=("md") A7=("providers") A8=("states") A9=("provinces") A10=("prefectures") 

unique subject_number 
putexcel B2=(r(N))  B3=(r(unique)) 
unique site_number 
putexcel  B4=(r(unique)) 
unique md_id 
putexcel   B7=(r(unique)) 
unique state 
putexcel   B8=(r(unique)) 

// tab "follow-up" 
sort subject_number visitdate
by subject_number: gen fuyr=(visitdate-visitdate[1])/365.25 if _n==_N & _N>1  

sum fuyr 

putexcel set "RA-$rptdt.xlsx", sheet(follow-up)  modify 
putexcel A1=("Variable") B1=("Total")  A2=("n")  A3=("total_years") A4=("mean")  
putexcel B2=(r(N)) B3=(r(sum)) B4=(r(mean)) 

cap log close 

