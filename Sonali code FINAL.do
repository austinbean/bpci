
set more off 
set trace on 


*set macros 

global datadir "/Users/austinbean/Google Drive/Texas PUDF Zipped Backup Files/other_analyses/DiRienz/"

cap log close
log using "${datadir}sonali_compilation.smcl", replace

foreach nm of numlist 2010(1)2018{
         
foreach qr of numlist 1(1)4{                        
di "YEAR: `nm' QUARTER: `qr'"
quietly use "/Users/austinbean/Google Drive/Texas PUDF Zipped Backup Files/`nm'/CD`nm'Q`qr'/PUDF `qr' Q `nm'.dta", clear

rename *, lower

*gen year and qtr variables from "discharge_qtr"
gen year = substr(discharge,1,4)
label variable year "Discharge year"
destring year, replace
gen dqtr = substr(discharge,-1,1)
label variable dqtr "Discharge quarter"
drop discharge

*gen binary sex variable from "sex_code"
gen female = sex_code=="F"
replace female=. if inlist(sex_code, "U", "", "*")
drop sex_code

*gen insurance type
rename first_payment_src pay1
rename secondary_payment_src pay2
gen medicare=0
replace medicare=1 if inlist(pay1, "MA", "MB", "16")
gen medicaid=0
replace medicaid=1 if pay1=="MC" 
gen private=0
replace private=1 if inlist(pay1, "12", "13", "14", "15", "BL", "CI", "HM")
gen selfpay=0
replace selfpay=1 if inlist(pay1, "09", "ZZ")
gen other=0
replace other=1 if inlist(pay1, "10", "11",  "AM", "CH", "DS", "LI")
replace other=1 if inlist(pay1, "LM", "OF", "TV", "VA", "WC")
gen insurance=0
replace insurance=1 if medicare==1
replace insurance=2 if medicaid==1
replace insurance=3 if private==1
replace insurance=4 if selfpay==1
replace insurance=5 if other==1
replace insurance=. if insurance==0
label variable insurance "Insurance categorical variable"

*gen ethnicity (Race and ethnicity data aren't always collected)
capture replace ethnicity="." if inlist(ethnicity, "`", "*", "") // modified.
label variable ethnicity "Indicates hispanic origin (1) or not of hispanic origin (2)"

*gen race categorical var
capture replace race="." if inlist(race, "", "*", "`") // modified 
destring race, replace force
gen racecat=1 if race==4
replace racecat=2 if race==3
replace racecat=3 if ethnicity==1
replace racecat=4 if inlist(race, 1, 2, 5)
label variable racecat "Indicates race: white (1) black (2) Hispanic (3) or other (4)"



************************************************************************
**CLASSIFYING PATIENT DIAGNOSIS**

gen icd9 = real(princ_diag_code) if year<2016
gen icd10 = substr(princ_diag_code, 1, 5) if year>2015

*patients with major depression
gen major_depression = (icd9 == 2962 | icd9 == 29621 | icd9 == 29622 | icd9 == 29623 | icd9 == 29624 | icd9 == 29625 | icd9 == 29626 | icd9 == 2963 | icd9 == 29631 | icd9 == 29632 | icd9 == 29633 | icd9 == 29634 | icd9 == 29635 | icd9 == 29636)

replace major_depression = 1 if (icd10== "F32" | icd10=="F321" | icd10=="F322" |icd10== "F323" |icd10== "F324" |icd10== "F325" | icd10== "F328" | icd10== "F329"| icd10== "F33" | icd10== "F331" | icd10== "F332" | icd10== "F333" | icd10== "F334" | icd10== "F338" | icd10== "F339" | icd10== "F3341" | icd10== "F3342" )

*patients with bipolar disorder
gen bipolar = (icd9 == 296 | icd9== 29601 | icd9==29602  | icd9==29603 | icd9==29604 | icd9==29605 | icd9==29606 | icd9==2964 | icd9==29641 | icd9==29642 | icd9==29643 | icd9==29644 | icd9==29645 | icd9==29646 | icd9==2965 | icd9==29651 | icd9==29652 | icd9==29653 | icd9==29654 | icd9==29655 | icd9==29656 | icd9==2966 | icd9==29661 | icd9==29662 | icd9==29663 | icd9==29664 | icd9==29665 | icd9==29666 | icd9==2967 | icd9==2968)

replace bipolar = 1 if (icd10== "F31" | icd10=="F311" | icd10=="F3111" |icd10== "F3112" |icd10== "F3113" |icd10== "F312" | icd10== "F313" | icd10== "F3131"| icd10== "F3132" | icd10== "F314" | icd10== "F315" | icd10== "F316" | icd10== "F3161" | icd10== "F3162" | icd10== "F3163" | icd10== "F3164" | icd10== "F317" | icd10== "F3171" | icd10=="F3172" | icd10=="F3173" |icd10== "F3174" |icd10== "F3175" |icd10== "F3176" | icd10== "F3177" | icd10== "F3178"| icd10== "F318" | icd10== "F3181" | icd10== "F3189" | icd10== "F319")

*patients with schizophrenia
gen schizophrenia = icd9 == 295
replace schizophrenia = 1 if (icd10== "F20" | icd10=="F201" | icd10=="F202" |icd10== "F203" |icd10== "F205" |icd10== "F208" | icd10== "F2081" | icd10== "F2089"| icd10== "F209")

*drop everyone except SMI patients
keep if major_depression==1|bipolar==1|schizophrenia==1
tab major_depression 
tab bipolar 
tab schizophrenia



************************************************************************
**CLASSIFYING PROVIDER TYPE**


*gen psych facility indicator
tostring fac_psych_ind if year==2010, replace
gen psychhosp=0
replace psychhosp=1 if inlist(fac_psych_ind, "A", "X", "(A)", "(X)", "1")
replace psychhosp = 2 if strpos(provider_name, "Behavioral")
replace psychhosp = 2 if strpos(provider_name, "Psychiatric")
replace psychhosp =2 if provider_name=="Carrollton Springs" | provider_name=="Cedar Crest Hospital" | provider_name=="Clarity Child Guidance Center" | provider_name=="Devereux Texas Treatment Network" | provider_name=="Glen Oaks Hospital"  | provider_name=="Hickory Trail Hospital"  | provider_name=="Intracare North Hospital"  | provider_name=="Kingwood Pines Hospital"  | provider_name=="Laurel Ridge Treatment Center" | provider_name=="Millwood Hospital" | strpos(provider_name, "Montgomery County Mental Health")  | provider_name=="Red River Regional" | provider_name=="Hospital River Crest Hospital"  | provider_name=="Sunrise Canyon"  | provider_name=="Texas NeuroRehab Center" | provider_name=="Menninger Clinic" | provider_name=="West Oaks Hospital"

label variable psychosp "0 if general, 1 if general with psych ward, 2 if psych hospital"

tab psychhosp

save "${datadir}sonali_data_`nm'_`qr'.dta", replace


}

}

log close

log using "$datadir/sonali_analysis.smcl"

use "${datadir}sonali_data_2010_1.dta", clear 
append using "${datadir}sonali_data_2010_2.dta", force
append using "${datadir}sonali_data_2010_3.dta", force
append using "${datadir}sonali_data_2010_4.dta", force
append using "${datadir}sonali_data_2011_1.dta", force
append using "${datadir}sonali_data_2011_2.dta", force
append using "${datadir}sonali_data_2011_3.dta", force 
append using "${datadir}sonali_data_2011_4.dta", force 
append using "${datadir}sonali_data_2012_1.dta", force 
append using "${datadir}sonali_data_2012_2.dta", force 
append using "${datadir}sonali_data_2012_3.dta", force 
append using "${datadir}sonali_data_2012_4.dta", force 
append using "${datadir}sonali_data_2013_1.dta", force 
append using "${datadir}sonali_data_2013_2.dta", force 
append using "${datadir}sonali_data_2013_3.dta", force 
append using "${datadir}sonali_data_2013_4.dta", force 
append using "${datadir}sonali_data_2014_1.dta", force 
append using "${datadir}sonali_data_2014_2.dta", force 
append using "${datadir}sonali_data_2014_3.dta", force 
append using "${datadir}sonali_data_2014_4.dta", force 
append using "${datadir}sonali_data_2015_1.dta", force 
append using "${datadir}sonali_data_2015_2.dta", force 
append using "${datadir}sonali_data_2015_3.dta", force 
append using "${datadir}sonali_data_2015_4.dta", force 
append using "${datadir}sonali_data_2016_1.dta", force 
append using "${datadir}sonali_data_2016_2.dta", force 
append using "${datadir}sonali_data_2016_3.dta", force 
append using "${datadir}sonali_data_2016_4.dta", force 
append using "${datadir}sonali_data_2017_1.dta", force 
append using "${datadir}sonali_data_2017_2.dta", force 
append using "${datadir}sonali_data_2017_3.dta", force 
append using "${datadir}sonali_data_2017_4.dta", force 
append using "${datadir}sonali_data_2018_1.dta", force 
append using "${datadir}sonali_data_2018_2.dta", force 
append using "${datadir}sonali_data_2018_3.dta", force 
append using "${datadir}sonali_data_2018_4.dta", force 


**************************************************************************
** KEY FINDINGS: CONFIDENCE INTERVALS OF DIAGNOSES BASED ON RACE AND FACILITY TYPE**

table nrace, c(m schizophrenia sem schizophrenia) 
table nrace, c(m bipolar sem bipolar)
table nrace, c(m major_depression sem major_depression)

table nrace psychhosp, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp, c(m bipolar sem bipolar)
table nrace psychhosp, c(m major_depression sem major_depression)


**************************************************************************
** STRATIFY BY GENDER **

table nrace female, c(m schizophrenia sem schizophrenia) 
table nrace female, c(m bipolar sem bipolar)
table nrace female, c(m major_depression sem major_depression)

table nrace psychhosp if female==1, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if female==1, c(m bipolar sem bipolar)
table nrace psychhosp if female==1, c(m major_depression sem major_depression)

table nrace psychhosp if female==0, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if female==0, c(m bipolar sem bipolar)
table nrace psychhosp if female==0, c(m major_depression sem major_depression)



**************************************************************************
** STRATIFY BY INSURANCE TYPE *


table nrace insurance, c(m schizophrenia sem schizophrenia) 
table nrace insurance, c(m bipolar sem bipolar)
table nrace insurance, c(m major_depression sem major_depression)

table nrace if medicaid==1, c(m schizophrenia sem schizophrenia) 
table nrace if medicaid==1, c(m bipolar sem bipolar)
table nrace if medicaid==1, c(m major_depression sem major_depression)

table nrace psychhosp if medicaid==1, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if medicaid==1, c(m bipolar sem bipolar)
table nrace psychhosp if medicaid==1, c(m major_depression sem major_depression)

table nrace if private==1, c(m schizophrenia sem schizophrenia) 
table nrace if private==1, c(m bipolar sem bipolar)
table nrace if private==1, c(m major_depression sem major_depression)

table nrace psychhosp if private==1, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if private==1, c(m bipolar sem bipolar)
table nrace psychhosp if private==1, c(m major_depression sem major_depression)

table nrace if medicare==1, c(m schizophrenia sem schizophrenia) 
table nrace if medicare==1, c(m bipolar sem bipolar)
table nrace if medicare==1, c(m major_depression sem major_depression)

table nrace psychhosp if medicare==1, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if medicare==1, c(m bipolar sem bipolar)
table nrace psychhosp if medicare==1, c(m major_depression sem major_depression)

table nrace if selfpay==1, c(m schizophrenia sem schizophrenia) 
table nrace if selfpay==1, c(m bipolar sem bipolar)
table nrace if selfpay==1, c(m major_depression sem major_depression)

table nrace psychhosp if selfpay==1, c(m schizophrenia sem schizophrenia) 
table nrace psychhosp if selfpay==1, c(m bipolar sem bipolar)
table nrace psychhosp if selfpay==1, c(m major_depression sem major_depression)


**************************************************************************
** SENSITIVITY CHECK: ACUITY? **

table nrace psychhosp if schizophrenia==1, c(m total_charges m illness_severity m length_of_stay)
table nrace psychhosp if bipolar==1, c(m total_charges m illness_severity m length_of_stay)
table nrace psychhosp if major_depression==1, c(m total_charges m illness_severity m length_of_stay)

log close
