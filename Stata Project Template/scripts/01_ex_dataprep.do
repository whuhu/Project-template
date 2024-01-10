
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

// recode var
sort wage
gen g_wage = group(5)
recode age (min/39 = 1) (39/42 = 2) (42/max = 3), ///
gen(g_age)

// gen xgroup
ssc install xgroup
xgroup race married, gen(race_marr2) label lname(race_marr_lab)

// different 'sum' in gen and egen

help collapse
sysuse nlsw88.dta,clear
collapse (mean) wage hours ///
(count) n_w=wage n_h=hours, ///
by(industry)

// bar graph
sysuse nlsw88.dta, clear
graph bar (mean) wage, over(smsa) over(married) over(collgrad)
graph hbar (mean) hours, over(union) over(married) ///
over(race) percent asyvars
graph bar wage hours, over(race) over(married) stack
graph box wage, over(race)

// duplicate obs

//END
log close
exit