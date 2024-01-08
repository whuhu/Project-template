
// Nov. 22, 2023
********************************************************************
********************************************************************
* To be consistent with the Data Task instruction, I started with secion 2. 

* Theis code file has 3 parts:
* - Part 1 Data Cleaning
* - Part 3 Analyze Patterns across 4 Years
* - Part 4 Analyze Pattern within Each Year

************************Part 1 Data Cleaning***********************
log using "$logs/dataprep.smcl", replace


import delimited "$data/ .csv",clear
import excel auto1.xls, firstrow clear

sysuse auto,clear
label define repair 1 "好" 2 "较 好" 3 "中" 4 "较差" 5 "差"
label values rep78 repair

tabstat price weight length, s(mean sd p25 med p75 min max) c(s) f(%6.2f) by(foreign)



//END
log close
exit