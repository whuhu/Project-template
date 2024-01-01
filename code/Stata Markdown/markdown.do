capture log close
log using "markdown", smcl replace
//_1
clear all
set more off 
cap log close 
set maxvar 20000
set scheme cleanplots, perm

// If the reader wants to replicate the results, he/she just needs to change this global path and put the data in raw_data file. 
global path "C:\Users\huhu\Desktop\Code Task\XXX\"
global D    "$path\data"      //data file
global Out  "$path\out"       //result: graph and table
cd "$D"                       //set current working directory

log using "$Out\task.smcl", replace


import delimited "test_data.csv",clear
save raw_data.dta, replace

*********************Question 0***************************************
// summarize data
summarize, detail
duplicates list arrive leave

//_2
*********************Question 1*****************************************
// transfer datetime
gen shift_date_time = date(shift_date, "DMY")
format shift_date_time %td

// extract hour and AM/PM indicator from shift_start and shift_end
// replace noon to 12 pm for conviency
replace shift_start="12 p.m." if shift_start=="noon"
replace shift_end="12 p.m." if shift_end=="noon"

gen hour_start = real(substr(shift_start, 1, strpos(shift_start, " ") - 1))
gen am_pm_start = substr(shift_start, -4, 4)

// do the same for shift_end
gen hour_end = real(substr(shift_end, 1, strpos(shift_end, " ") - 1))
gen am_pm_end = substr(shift_end, -4, 4)

// convert to 24 hour format
replace hour_start = hour_start + 12 if am_pm_start == "p.m." & hour_start != 12
replace hour_end = hour_end + 12 if am_pm_end == "p.m." & hour_end != 12

// combine data with time
gen shift_start_data_time = shift_date + " " + string(hour_start, "%02.0f") + ":00:00"
gen shift_end_data_time = shift_date + " " + string(hour_end, "%02.0f") + ":00:00"
// adjust for across day pattern
gen shift_date_time_1 = string(shift_date_time + 1, "%td")

replace shift_end_data_time = shift_date_time_1 + " " + string(hour_end, "%02.0f") + ":00:00" if shift_start == "7 p.m."


// note, use double to ensure precient
gen double shift_start_time = clock(shift_start_data_time, "DMY hms")
gen double shift_end_time = clock(shift_end_data_time, "DMY hms")
format shift_start_time %tc
format shift_end_time %tc

gen double arrive_time = clock(arrive, "DMY hms")
gen double leave_time = clock(leave, "DMY hms")
format arrive_time %tc
format leave_time %tc

// calculate percentages
// patients arriving before their physician's shift starts
gen arrive_before_shift = arrive_time < shift_start_time

// patients discharged after their physician's shift ends
gen leave_after_shift = leave_time > shift_end_time

// calculate percentages
sum arrive_before_shift
sum leave_after_shift

//_3
qui destring li*, replace force
qui replace li = li1 + li2 + li3 if mi(li) & !mi(li1, li2, li3)

foreach var in li1 li2 li3 {
qui replace `var' = 0 if mi(`var')
}
foreach var in li1 li2 li3 {
qui replace `var' = li*3 - (li1 + li2 + li3) if `var' == 0
}

qui save "$merged_data/cleaning_done_data.dta", replace
//_4
*********************Question 2 (1 h)*****************************************
// get hours and minutes
gen arrive_hour = hh(arrive_time)
gen arrive_minute = mm(arrive_time)

// compute half-hour
gen half_hour_interval = arrive_hour + (arrive_minute >= 30)/2

// calculate average servenity by half hours
bysort half_hour_interval: egen avg_severity = mean(pred_lnlos)

twoway (connected avg_severity half_hour_interval,m(o))(lfit avg_severity half_hour_interval, lpattern(dash)), ///
ytitle("Average Severity") xtitle("Half-Hour Interval of Day") ///
title("Average Severity by Half-Hour of Patient Arrival") ///
legend(ring(0) position(4))
graph export "$Out\Average_Severity.png", replace

// formally test whether patient severity is or is not predicted by hour of the day
reg avg_severity i.arrive_hour,r

coefplot,keep(*.arrive_hour) title("Coefficient of Arrival Hours") baselevels ci vertical label xlabel(, angle(45) labsize(vsmall)) yline(0)
graph export "$Out\Coef_Hours.png", replace
//_5
*********************Question 3*****************************************
// extend shift end by 4 hours
gen double shift_end_4h_more = shift_end_time + 60*60*4000
format shift_end_4h_more %tc

save temp.dta, replace

use temp.dta, clear
// creat hourly interval for time shift
gen hours_of_shift = (shift_end_4h_more - shift_start_time) / 3600000

// create an index for each shift
gen shift_index = _n 

// expand the dataset for each hour of each shift
expand hours_of_shift

// generate hour_id for each hour within the shift
bysort shift_index: gen hour_id = _n

gen double hour_lb = shift_start_time + (hour_id-1)*3600000
gen double hour_ub = hour_lb + 3600000

format hour_lb %tc
format hour_ub %tc

// lower bound census: counts only throught whole hours
gen patient_under_care_lb = (arrive_time <= hour_lb) & (leave_time > hour_ub)

bysort phys_id shift_date hour_id: egen census_lb = sum(patient_under_care_lb)

// upper bound census: counts if intersects within hours
gen patient_under_care_ub = (arrive_time <= hour_ub) & (leave_time > hour_lb)

bysort phys_id shift_date hour_id: egen census_ub = sum(patient_under_care_ub)

// finer bound census
gen patient_under_care_fb = (arrive_time <= hour_ub) & (leave_time > hour_lb)
replace patient_under_care_fb = 0 if (arrive_time <= hour_ub) & (leave_time > hour_lb) & (leave_time < hour_lb + 900000)
replace patient_under_care_fb = 0 if (arrive_time <= hour_ub) & (arrive_time > hour_ub - 900000) & (leave_time > hour_lb)

bysort phys_id shift_date hour_id: egen census_fb = sum(patient_under_care_fb)

// end of shift
gen end_of_shift = hour_id - hours_of_shift + 4
save patients_all.dta, replace

use patients_all.dta, clear
duplicates drop phys_id shift_date shift_start shift_end end_of_shift, force
keep phys_id shift_date shift_start shift_end hour_id patient_under_care_lb patient_under_care_ub patient_under_care_fb end_of_shift
rename hour_id hour
save census.dta, replace

use census.dta, clear
// How does the census vary with time relative to end of shift
bysort end_of_shift: egen sum_patient_under_care_fb = sum(patient_under_care_fb)
bysort end_of_shift: egen sum_patient_under_care_lb = sum(patient_under_care_lb)
bysort end_of_shift: egen sum_patient_under_care_ub = sum(patient_under_care_ub)

duplicates drop end_of_shift, force
twoway (connected sum_patient_under_care_fb end_of_shift) ///
(connected sum_patient_under_care_lb end_of_shift) (connected sum_patient_under_care_ub end_of_shift), xline(0, lpattern(dash)) ///
ytitle("Census Count") xtitle("Time Relative to End of Shift (Hours)") ///
title("Census Variation Relative to End of Shift") xtick(-9(1)4) ///
legend(ring(0) pos(11))
graph export "$Out\Census_Variation.png", replace

//_6
*********************Question 4 (50 min)*****************************************
use temp.dta, clear

// gen length of stay(seconds)
gen double log_length_stay = log((leave_time - arrive_time)/1000)

reg log_length_stay i.phys_id, r
coefplot,keep(*.phys_id) title("Coefficient of Physician") baselevels ci vertical label xlabel(, angle(45) labsize(vsmall)) yline(0)
graph export "$Out\Coef_phys.png", replace

// control pred_lnlos
reg log_length_stay i.phys_id pred_lnlos, r
coefplot,keep(*.phys_id) title("Coefficient of Physician, Controlled for pred_los") baselevels ci vertical label xlabel(, angle(45) labsize(vsmall)) yline(0)
graph export "$Out\Coef_phys_control.png", replace


// los versus time to shift
use patients_all.dta, clear
gen double log_length_stay = log((leave_time - arrive_time)/1000)

reg log_length_stay i.phys_id##i.hour_id, r
coefplot,keep(*.phys_id) title("Coefficient of Physician, Controlled for time to shift") baselevels ci vertical label xlabel(, angle(45) labsize(vsmall)) yline(0)

graph export "$Out\Interaction_coef.png", replace

log  close
//_^
log close
