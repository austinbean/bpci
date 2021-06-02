///****EVALUATION OF MEDICARE'S BPCI IN TEXAS****///

set more off 
set trace on 
//**AIM 1**//
//SAMPLE = BPCI Hospitals 
//TREATMENT GROUP = Medicare patients, 65-84 (medicare=1)
//CONTROL GROUP = private and/or Medicaid patients, 45-64


//**AIM 2**//
//SAMPLE = All hospitals, Medicare patients with BPCI-eligible DRGs only (bpci_drg==1)
//TREATMENT GROUP = BPCI hospital (bpci=1)
//CONTROL GROUP = non-BPCI hospital 


*set macros (REQUIRES ACTION)

global datadir "/Users/austinbean/Google Drive/Texas PUDF Zipped Backup Files/other_analyses/DiRienz/"

cap log close
log using "${datadir}BPCI_dataconstruction.smcl", replace


foreach nm of numlist 2010(1)2018{
         
foreach qr of numlist 1(1)4{                        
di "YEAR: `nm' QUARTER: `qr'"
quietly use "/Users/austinbean/Google Drive/Texas PUDF Zipped Backup Files/`nm'/CD`nm'Q`qr'/PUDF `qr' Q `nm'.dta", clear

rename *, lower

	
**-----------------------------------------

// rename //
capture rename patient_status pat_status 


//*CLEANUP DATA*//
/*
	foreach varl of varlist fac_* {
		capture confirm string variable `varl'
			if !_rc {
				replace `varl' = "X" if `varl' != "" 
				destring `varl', replace
				}
			}
*/
*rename, label, and drop variables
label variable fac_teaching_ind "Teaching facility indicator"
label variable fac_rehab_ind "Rehabilitation facility indicator"
label variable fac_acute_care_ind "Acute care facility indicator"
label variable fac_snf_ind "Skilled nursing facility indicator"
label variable fac_long_term_ac_ind "Long term acute care facility indicator"
label variable fac_other_ltc_ind "other long term care facility indicator"
rename length_of_stay los


**-----------------------------------------


//*GENERATE NEW VARIABLES AND CLEAN*//

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
label variable female "Indicates patient is female (1) or male (0)"
drop sex_code

*gen "died" variable from "pat_status"
gen died=0
capture replace died=1 if pat_status=="20" | pat_status=="40" | pat_status=="41" | pat_status=="42"
capture replace died=1 if pat_status==20 | pat_status==40 | pat_status==41 | pat_status==42 // added
label variable died "Died"

*gen and consolidate payer type

**MC: 14 is EPO, which should be private

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

*gen dual eligible variable "dual" for discharges with both medicare and medicaid
gen dual=0
replace dual=1 if medicare==1 & pay2=="MC"
replace dual=1 if medicaid==1 & pay2=="MA" 
replace dual=1 if medicaid==1 & pay2=="MB" 
replace dual=1 if medicaid==1 & pay2=="16" 
label variable medicare "Primary expected payer is medicare"
label variable medicaid "Primary expected payer is medicaid"
label variable private "Primary expected payer is private"
label variable selfpay "Primary expected payer is Self-pay"
label variable other "Primary expected payer is other"
label variable dual "Dual eligible"

**MC: likely irrelevant to your sample, but how are 22-26 categories (HIV, SUD) handled? 

*generate age variables
rename pat_age age
destring age, replace force // sometimes a string.  
gen age1 = inlist(age, 02, 03, 04, 05)
label variable age1 "Age: 1-17 years old"
gen age2 = inlist(age, 06, 07, 08, 09, 10, 11)
label variable age2 "Age: 18-44 years old"
gen age3 = inlist(age, 12, 13, 14, 15)
label variable age3 "Age: 45-64 years old"
gen age4 = inlist(age, 16, 17, 18, 19)
label variable age4 "Age: 65-84 years old"
gen age5 = inlist(age, 20, 21)
label variable age5 "Age: 85 years and older"
drop if age==. | age==0 | age==1 | age>21

*gen age categorical var
gen agecat=1 if age1==1
replace agecat=2 if age2==1
replace agecat=3 if age3==1
replace agecat=4 if age4==1
replace agecat=5 if age5==1
replace agecat=. if age==.
label variable agecat "Age categorical variable"

*gen ethnicity (Race and ethnicity data aren't always collected)
capture replace ethnicity="." if inlist(ethnicity, "`", "*", "") // modified.
label variable ethnicity "Indicates hispanic origin (1) or not of hispanic origin (2)"

*gen race categorical var
capture replace race="." if inlist(race, "", "*", "`") // modified 
destring race, replace force
gen racecat=1 if race==4
replace racecat=2 if race==3
replace racecat=3 if inlist(race, 1, 2, 5)
label variable racecat "Indicates race: white (1) black (2) or other (3)"

*gen insurance categorical var
gen insurance=0
replace insurance=1 if medicare==1
replace insurance=2 if medicaid==1
replace insurance=3 if private==1
replace insurance=4 if selfpay==1
replace insurance=5 if other==1
replace insurance=. if insurance==0
label variable insurance "Insurance categorical variable"

*gen post-acute care discharge dummy var
capture replace pat_status="*" if pat_status=="`" | pat_status=="" // modified
gen postcare=0
capture replace postcare=1 if inlist(pat_status, "03", "04", "06", "08", "50", "51") 
capture replace postcare=1 if inlist(pat_status, "62", "63", "64", "71", "72")
capture replace postcare=1 if inlist(pat_status, 03, 04, 06, 08, 50, 51) 
capture replace postcare=1 if inlist(pat_status, 62, 63, 64, 71, 72)
capture replace postcare=. if pat_status=="*"
label variable postcare "Indicates discharge to snf, ltc, hospice, rehab, etc"

*gen severity risk variables (include highsev in reg)
gen lowsev = illness_severity==1 | illness_severity==2
gen highsev = illness_severity==3 | illness_severity==4
label variable lowsev "Severity risk: Minor or moderate loss of function"
label variable highsev "Severity risk: Major  of extreme loss of function"


// FROM HERE // 

*gen teaching facility indicator
gen teach=0
foreach v of varlist fac_teaching_ind {
                capture confirm string variable `v'
                if !_rc {
                        replace teach=1 if inlist(fac_teaching_ind, "A", "X", "(A)", "(X)")
                }
                else {
                        replace teach=1 if fac_teaching_ind==1 
                }
        }
label variable teach "Indicates teaching hospital"

*gen snf indicator
gen snf=0
foreach v of varlist fac_snf_ind {
                capture confirm string variable `v'
                if !_rc {
                        replace fac_snf=1 if inlist(fac_snf_ind, "A", "X", "(A)", "(X)")
                }
                else {
                        replace snf=1 if fac_snf_ind==1 
                }
        }
label variable snf "Indicates snf"

*gen rehab indicator
gen rehab=0
foreach v of varlist fac_rehab_ind {
                capture confirm string variable `v'
                if !_rc {
                        replace rehab=1 if inlist(fac_rehab_ind, "A", "X", "(A)", "(X)")
                }
                else {
                        replace rehab=1 if fac_rehab_ind==1 
                }
        }
label variable rehab "Indicates rehab"

*gen long term care indicator
gen ltc=0
foreach v of varlist fac_long_term_ac_ind {
                capture confirm string variable `v'
                if !_rc {
                        replace ltc=1 if inlist(fac_long_term_ac_ind, "A", "X", "(A)", "(X)")
                }
                else {
                        replace ltc=1 if fac_long_term_ac_ind==1 
                }
        }
label variable ltc "Indicates long term care"

*gen var indicating that patient spent most days in icu  
gen icu=0
capture rename spec_unit_1 spec_unit  // prior solution gives an error if spec_unit_1 does not exist.  
replace icu=1 if spec_unit=="I" 
label variable icu "Indicates ICU was where patient spent most days during stay" 




**-----------------------------------------


//*CREATE BPCI VARIABLE*// 

*BPCI is a dummy variable that indicates (1) if discharge has an eligible DRG & hospital
capture rename cms_drg ms_drg // 
rename ms_drg drg
gen bpci=0
label variable bpci "Indicates episode covered by BPCI"

*Use CMS excel file to determine all bpci contracts by DRG and hospital
*Acute myocardial infarction 
replace bpci=1 if inlist(drg, 280, 281, 282) & inlist(thcic_id, 114001, 653001, 349001, 212000, 675000)

*Coronary artery bypass graft
replace bpci=1 if inlist(drg, 231, 232, 233, 234, 235, 236) & thcic_id==653001

*Cardiac arrhythmia 
replace bpci=1 if inlist(drg, 308, 309, 310) ///
& inlist(thcic_id, 212000, 214000) 

*Cellulitis
replace bpci=1 if inlist(drg, 602, 603) ///
& inlist(thcic_id, 349001, 212000, 675000, 214000, 477000)
 
*Cervical spinal fusion
replace bpci=1 if inlist(drg, 471, 472, 473) & thcic_id==477000

*Chest pain
replace bpci=1 if drg==313 & thcic_id==336001

*Congestive Heart Failure
replace bpci=1 if inlist(drg, 291, 292, 293) ///
& inlist(thcic_id,349001, 212000, 336001, 675000, 214000, 340000, 477000) 

*Chronic obstructive pulmonary disease, bronchitis, asthma
replace bpci=1 if inlist(drg, 190, 191, 192, 202, 203) ///
& inlist(thcic_id, 114001, 349001, 212000, 336001, 675000, 214000, 340000, 477000) 

*Diabetes  
replace bpci=1 if inlist(drg, 637, 638, 639) ///
& inlist(thcic_id, 212000, 349001)

*Esophagitis, gastroenteritis and other digestive disorders  
replace bpci=1 if inlist(drg, 391, 392) & thcic_id==675000

*Gastrointestinal obstruction
replace bpci=1 if inlist(drg, 388, 389, 390) & thcic_id==214000

*Hip and femur procedures except major joint
replace bpci=1 if inlist(drg, 480, 481, 482) ///
& inlist(thcic_id, 349001, 212000)

*Major bowel procedure
replace bpci=1 if inlist(drg, 329, 330, 331) & thcic_id==675000

*Major joint replacement of the lower extremity
replace bpci=1 if inlist(drg, 469, 470) ///
& inlist(thcic_id, 114001, 212000, 336001, 214000, 340000, 477000, 124000, 154000)

*Medical non-infectious orthopedic
replace bpci=1 if inlist(drg, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563) ///
 & inlist(thcic_id, 349001, 212000, 675000, 214000)

*other respiratory
replace bpci=1 if inlist(drg, 186, 187, 188, 189, 204, 205, 206, 207, 208) & ///
 thcic_id==212000

*Percutaneous coronary intervention
replace bpci=1 if inlist(drg, 246, 247, 248, 249, 250, 251, 273, 274) & ///
inlist(thcic_id, 349001, 212000, 214000, 340000)

*Renal failure
replace bpci=1 if inlist(drg, 682, 683, 684) & inlist(thcic_id, 675000, 477000)

*Sepsis
replace bpci=1 if inlist(drg, 870, 871, 872) & ///
inlist(thcic_id, 349001, 212000, 336001, 675000, 214000, 477000)

*Simple pneumonia and respiratory infections
replace bpci=1 if inlist(drg, 177, 178, 179, 193, 194, 195) & ///
inlist(thcic_id, 114001,  349001, 212000, 336001, 675000, 214000, 340000, 477000)

*Spinal fusion (non-cervical 
replace bpci=1 if inlist(drg, 459, 460) & thcic_id==477000

*Stroke
replace bpci=1 if inlist(drg, 61, 62, 63, 64, 65, 66) & ///
inlist(thcic_id, 675000, 214000, 340000, 477000, 336001)

*Syncope and collapse
replace bpci=1 if drg==312 & inlist(thcic_id, 675000, 214000)

*Transient ischemia
replace bpci=1 if drg==69 & thcic_id==214000

*Urinary tract infection
replace bpci=1 if inlist(drg, 689, 690) & ///
inlist(thcic_id, 349001, 212000, 336001, 675000, 214000, 477000, 340000)

*gen dummy variable to indicate (1) if discharge WOULD be eligible for bpci coverage 
gen bpci_drg=0
replace bpci_drg=1 if inlist(drg, 280, 281, 282, 231, 232, 233, 234, 235, 236, 308, 309, 310)
replace bpci_drg=1 if inlist(drg, 602, 603, 471, 472, 473, 313, 291, 292, 293, 190, 191, 192, 202, 203)
replace bpci_drg=1 if inlist(drg, 637, 638, 639, 391, 392, 388, 389, 390, 480, 481, 482)
replace bpci_drg=1 if inlist(drg, 329, 330, 331, 469, 470, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563)
replace bpci_drg=1 if inlist(drg, 186, 187, 188, 189, 204, 205, 206, 207, 208, 246, 247, 248, 249, 250, 251, 273, 274)
replace bpci_drg=1 if inlist(drg, 682, 683, 684, 870, 871, 872, 177, 178, 179, 193, 194, 195, 459, 460)
replace bpci_drg=1 if inlist(drg, 61, 62, 63, 64, 65, 66, 312, 69, 689, 690)
label variable bpci_drg "Indicates DRG of discharge would be eligible for bpci coverage, but does not indicate actual bpci contract"


**MC: I'd add a couple of sums and tabs here to quality check

tab drg
tab bpci_drg 
tab bpci
tab drg bpci
tab drg bpci_drg

**-----------------------------------------


//**CREATE ANALYSIS VARIABLES AND PREPARE FOR ANALYSIS*//

*winsorize los and total charges 
winsor2 los, cuts(0 99) by(year) // need ssc install winsor2
label variable los_w "Length of stay, days, winsorized"
rename los los_r
winsor2 total_charges, cuts(0 99) 
rename total_charges_w totchg_w
label variable totchg_w "Total charges, winsorized, not inflation adjusted"
label variable total_charges "Total charges, raw"

*gen winsorized and inflation adjusted total charges var
*adjust for inflation to the 2018 dollar using the CPI for Hospital Services
gen float adjtotchg_w = 0 
replace adjtotchg_w = totchg_w * 1.427 if year==2010
replace adjtotchg_w = totchg_w * 1.351 if year==2011
replace adjtotchg_w = totchg_w * 1.290 if year==2012
replace adjtotchg_w = totchg_w * 1.236 if year==2013
replace adjtotchg_w = totchg_w * 1.181 if year==2014
replace adjtotchg_w = totchg_w * 1.138 if year==2015
replace adjtotchg_w = totchg_w * 1.090 if year==2016
replace adjtotchg_w = totchg_w * 1.042 if year==2017
label variable adjtotchg_w "Total charges, winsorized, inflation adjusted (2018)"
rename totchg_w unadjtotchg_w
rename adjtotchg_w totchg_w

*gen non-winsorized inflation adjusted total charges var
*adjust for inflation 
gen float adjtotchg_r = 0 
replace adjtotchg_r = total_charges * 1.427 if year==2010
replace adjtotchg_r = total_charges * 1.351 if year==2011
replace adjtotchg_r = total_charges * 1.290 if year==2012
replace adjtotchg_r = total_charges * 1.236 if year==2013
replace adjtotchg_r = total_charges * 1.181 if year==2014
replace adjtotchg_r = total_charges * 1.138 if year==2015
replace adjtotchg_r = total_charges * 1.090 if year==2016
replace adjtotchg_r = total_charges * 1.042 if year==2017
label variable adjtotchg_r "Total charges, non-winsorized, inflation adjusted (2018)"
rename adjtotchg_r totchg_r

*gen log total charges var
gen totchg_rlog = log(totchg_r)
label variable totchg_rlog "Log of raw total charges, inflation adjusted (2018)"

*gen log length of stay
gen los_rlog = log(los_r)
label variable los_rlog "Log of length of stay"

*Restrict sample 
keep if medicare==1&age4==1 | medicaid==1&age3==1 | private==1&age3==1
drop if bpci_drg==0

* County variable changes name

capture rename pat_county county 

*Keep variables
keep total_charges totchg_r totchg_w totchg_rlog los_r los_w los_rlog bpci bpci_drg medicare medicaid private insurance age* female highsev dual icu ethnicity racecat illness_severity year dqtr thcic_id snf teach rehab ltc icu drg postcare county

save "${datadir}DiRienz_data_`nm'_`qr'.dta", replace


}

}

use "${datadir}DiRienz_data_2010_1.dta", clear 
append using "${datadir}DiRienz_data_2010_2.dta", force
append using "${datadir}DiRienz_data_2010_3.dta", force
append using "${datadir}DiRienz_data_2010_4.dta", force
append using "${datadir}DiRienz_data_2011_1.dta", force
append using "${datadir}DiRienz_data_2011_2.dta", force
append using "${datadir}DiRienz_data_2011_3.dta", force 
append using "${datadir}DiRienz_data_2011_4.dta", force 
append using "${datadir}DiRienz_data_2012_1.dta", force 
append using "${datadir}DiRienz_data_2012_2.dta", force 
append using "${datadir}DiRienz_data_2012_3.dta", force 
append using "${datadir}DiRienz_data_2012_4.dta", force 
append using "${datadir}DiRienz_data_2013_1.dta", force 
append using "${datadir}DiRienz_data_2013_2.dta", force 
append using "${datadir}DiRienz_data_2013_3.dta", force 
append using "${datadir}DiRienz_data_2013_4.dta", force 
append using "${datadir}DiRienz_data_2014_1.dta", force 
append using "${datadir}DiRienz_data_2014_2.dta", force 
append using "${datadir}DiRienz_data_2014_3.dta", force 
append using "${datadir}DiRienz_data_2014_4.dta", force 
append using "${datadir}DiRienz_data_2015_1.dta", force 
append using "${datadir}DiRienz_data_2015_2.dta", force 
append using "${datadir}DiRienz_data_2015_3.dta", force 
append using "${datadir}DiRienz_data_2015_4.dta", force 
append using "${datadir}DiRienz_data_2016_1.dta", force 
append using "${datadir}DiRienz_data_2016_2.dta", force 
append using "${datadir}DiRienz_data_2016_3.dta", force 
append using "${datadir}DiRienz_data_2016_4.dta", force 
append using "${datadir}DiRienz_data_2017_1.dta", force 
append using "${datadir}DiRienz_data_2017_2.dta", force 
append using "${datadir}DiRienz_data_2017_3.dta", force 
append using "${datadir}DiRienz_data_2017_4.dta", force 
append using "${datadir}DiRienz_data_2018_1.dta", force 
append using "${datadir}DiRienz_data_2018_2.dta", force 
append using "${datadir}DiRienz_data_2018_3.dta", force 
append using "${datadir}DiRienz_data_2018_4.dta", force 

save "${datadir}DiRienz_data_all.dta", replace

*check how many BPCI hospitals drop out and when
keep if bpci==1
duplicates drop thcic_id year, force
xtset thcic year
xtdescribe

log close
