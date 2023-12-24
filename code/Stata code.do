// Nov. 22, 2023
********************************************************************
********************************************************************
* To be consistent with the Data Task instruction, I started with secion 2. 

* Theis code file has 3 parts:
* - Part 2 Data Cleaning
* - Part 3 Analyze Patterns across 4 Years
* - Part 4 Analyze Pattern within Each Year

************************Part 2 Data Cleaning***********************

clear all
set more off 
cap log close 
set maxvar 20000
set scheme cleanplots, perm

// If the reader wants to replicate the results, he/she just needs to change this global path and put the data in raw_data file. 
global path "C:\Users\huhu\Desktop\Code Task\HIL_DataTask_2024"
global D    "$path\data"      //data file
global Out  "$path\out"       //result: graph and table
cd "$D"                       //set current working directory

log using "$Out\task 1.smcl", replace


import delimited " .csv",clear

// Descriptive Statistics
estpost tabstat binding_commission partisan_election retention, statistics(N mean sd min max median) columns(statistics)
esttab using "descriptive_stats.rtf", cells("count mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2)) median(fmt(2))") nonumber noobs nomtitles replace

// Regression whether someone voted on the following controls adding in the 
// order specified one at a time until all controls are included: religion, age, male, less than high school, and year voted
regress vote_pres i.religion [aw=wtssall]
outreg2 using regression_output.tex, replace ctitle("Control Religion") bdec(3) tdec(2) label

* Add age to the model
regress vote_pres i.religion i.age_cat [aw=wtssall]
outreg2 using regression_output.tex, append ctitle("Control Religion and Age") bdec(3) tdec(2) label

* Add gender (male) to the model
regress vote_pres i.religion i.age_cat male [aw=wtssall]
outreg2 using regression_output.tex, append ctitle("Control Religion, Age, and Male") bdec(3) tdec(2) label

* Add education (less than high school) to the model
regress vote_pres i.religion i.age_cat male i.less_highschool [aw=wtssall]
outreg2 using regression_output.tex, append ctitle("Control Religion, Age, Male, and Education") bdec(3) tdec(2) label

* Final model with year voted
regress vote_pres i.religion i.age_cat male i.less_highschool year [aw=wtssall]
outreg2 using regression_output.tex, append ctitle("Full Model") bdec(3) tdec(2) label



// DID
gen post1979 = year > 1979
gen less_than_highschool = educ < 12

regress repub_v_dem post1979 less_than_highschool post1979#less_than_highschool i.religion i.age male i.year [aw=wtssall]

coefplot, keep(post1979 less_than_highschool post1979#less_than_highschool) ciopts(recast(rcap))


// Event Study
foreach year in 72 74 76 80 82 84 88 92 96 {
    gen interaction`year' = (year == `year') * less_than_highschool
}

regress repub_v_dem interaction* i.religion i.age male i.less_highschool [aw=wtssall] if year != 1976

coefplot interaction* if year != 1976, drop(interaction76) ciopts(recast(rcap))




//coefplot
reg log_length_stay i.phys_id pred_lnlos, r
coefplot,keep(*.phys_id) title("Coefficient of Physician, Controlled for pred_los") baselevels ci vertical label xlabel(, angle(45) labsize(vsmall)) yline(0)
graph export "$Out\Coef_phys_control.png", replace

log  close