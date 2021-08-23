//****ANALYSIS DO FILE****//

//**MERGE IN AREA RESOURCE FILE DATA AND CREATE VARIABLES**//

*set macros (REQUIRES ACTION)

global datadir "/Users/austinbean/Google Drive/Texas PUDF Zipped Backup Files/other_analyses/DiRienz/"

cap log close
log using "${datadir}BPCI_analysis.smcl", replace 

use "${datadir}DiRienz_data_all.dta", clear


*merge with Area Resource File data
rename county fips
merge m:1 fips using "${datadir}DiRienz_ahrf.dta"
drop _merge

*gen urban variable
destring percenturban, generate(percenturban_x)
drop percenturban
rename percenturban_x percenturban
xtile urban = percenturban, nq(4)
label variable percenturban "Percentage of patient's county that is urban"
replace urban=. if percenturban==.

*gen median household income variable
destring median_householdincome, replace force
xtile income = median_householdincome, nq(4)
label variable median_householdincome "Median household income based on county"
replace median_householdincome = median_householdincome/1000

save "${datadir}DiRienz_data_merged.dta", replace


**-----------------------------------------


//**MERGE WITH ADDTL HOSPITAL DATA**//

*Merge to get discharges, number of beds, and govt control variables
merge m:1 thcic_id using "${datadir}DiRienz_hosp.dta"
drop _merge

*gen bedsize var
label variable beds "Number of hospital beds"
gen bedsize=0
replace bedsize=1 if inrange(beds, 1, 100)
replace bedsize=2 if inrange(beds, 101, 200)
replace bedsize=3 if beds>200
label variable bedsize "Categorical var for number of beds"

*rename total discharges (annual)
label variable totaldisc "Total annual discharges"

*gen hospital control  categorical var
label variable control "Indicates control of hospital: profit, govt"
gen hcontrl=0
replace hcontrl=1 if control=="profit"
replace hcontrl=2 if control=="gov"
replace hcontrl=. if control==""
label variable hcontrl "Categorical variable for hospital control"

save "${datadir}DiRienz_data_merged.dta", replace



**-----------------------------------------


//**CREATE IMPLEMENTATION GROUPS FOR did**//

*gen group of indicator variables to indicate policy start date
*group1 = policy start date 10/1/2013 (just one instance)
gen group1 = 0
replace group1 = 1 if thcic_id==114001 & inlist(drg, 469, 470) 
label variable group1 "BPCI enacted 10/1/2013"

*group2 = policy start date 4/1/2015
gen group2 = 0
replace group2 = 1 if thcic_id==114001 & ///
 inlist(drg, 177, 178, 179, 193, 194, 195, 280, 281, 282, 190, 191, 192, 202, 203)
replace group2 = 1 if thcic_id==349001 & ///
 inlist(drg, 190, 191, 192, 202, 203, 480, 481, 482, 870, 871, 872, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 177, 178, 179, 193, 194, 195, 689, 690, 291, 292, 293, 246, 247, 248, 249, 250, 251, 273, 274, 602, 603)
replace group2 = 1 if thcic_id==212000 & ///
 inlist(drg, 190, 191, 192, 202, 203, 480, 481, 482, 870, 871, 872, 469, 470, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 177, 178, 179, 193, 194, 195, 186, 187, 188, 189, 204, 205, 206, 207, 208, 689, 690, 637, 638, 639, 291, 292, 293, 246, 247, 248, 249, 250, 251, 273, 274, 602, 603)
replace group2 = 1 if thcic_id==336001 & ///
 inlist(drg, 190, 191, 192, 202, 203, 870, 871, 872, 469, 470, 177, 178, 179, 193, 194, 195, 689, 690, 291, 292, 293)
replace group2 = 1 if thcic_id==675000 & ///
 inlist(drg, 61, 62, 63, 64, 65, 66, 329, 330, 331, 190, 191, 192, 202, 203, 870, 871, 872, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 177, 178, 179, 193, 194, 195, 689, 690, 682, 683, 684, 291, 292, 293, 602, 603)
replace group2 = 1 if thcic_id==214000 & ///
 inlist(drg, 61, 62, 63, 64, 65, 66, 190, 191, 192, 202, 203, 870, 871, 872, 469, 470, 537, 538, 551, 552, 553, 554, 555, 556, 557, 558, 559, 560, 561, 562, 563, 177, 178, 179, 193, 194, 195, 689, 690, 69, 291, 292, 293, 246, 247, 248, 249, 250, 251, 273, 274, 602, 603)
replace group2 = 1 if thcic_id==340000 & ///
 inlist(drg, 61, 62, 63, 64, 65, 66, 190, 191, 192, 202, 203, 469, 470, 177, 178, 179, 193, 194, 195, 291, 292, 293, 246, 247, 248, 249, 250, 251, 273, 274)
replace group2 = 1 if thcic_id==477000 & ///
 inlist(drg, 61, 62, 63, 64, 65, 66, 190, 191, 192, 202, 203, 870, 871, 872, 469, 470, 177, 178, 179, 193, 194, 195, 689, 690, 682, 683, 684, 291, 292, 293, 602, 603)
label variable group2 "BPCI enacted 4/1/2015"

*group3 = policy start date 7/1/2015
gen group3 = 0
replace group3 = 1 if thcic_id==653001 & ///
 inlist(drg, 280, 281, 282, 231, 232, 233, 234, 235, 236)
replace group3 = 1 if thcic_id==124000 & inlist(drg, 469, 470)
label variable group3 "BPCI enacted 7/1/2015"

*group4 = policy start date 10/1/2015
gen group4 = 0
replace group4 = 1 if thcic_id==349001 & ///
 inlist(drg, 280, 281, 282, 637, 638, 639)
replace group4 = 1 if thcic_id==212000 & ///
 inlist(drg, 280, 281, 282, 308, 309, 310)
replace group4 = 1 if thcic_id==336001 & ///
 inlist(drg, 313, 61, 62, 63, 64, 65, 66)
replace group4 = 1 if thcic_id==675000 & ///
 inlist(drg, 280, 281, 282, 391, 392, 312) 
replace group4 = 1 if thcic_id==214000 & ///
 inlist(308, 309, 310, 388, 389, 390, 312)
replace group4 = 1 if thcic_id==340000 & ///
 inlist(drg, 689, 690)
replace group4 = 1 if thcic_id==477000 & ///
 inlist(471, 472, 473, 459, 460)
label variable group4 "BPCI enacted 10/1/2015"

**-----------------------------------------


//**CREATE VARIABLES FOR EVENT STUDY & did**//

egen time = group(year dqtr)
gen post=0
replace post=1 if group1==1 & time>15
replace post=1 if group2==1 & time>21
replace post=1 if group3==1 & time>22
replace post=1 if group4==1 & time>23

save "${datadir}DiRienz_data_merged.dta", replace

**-----------------------------------------

**SAVE SUBSAMPLE FOR AIM2**
keep if medicare==1
keep if bpci_drg==1
*interaction var
gen did=post*bpci
label variable did "Interaction variable that indicates 1 if under BPCI contract and occurred after implementation"

save "${datadir}DiRienz_AIM2.dta", replace
clear

**SAVE SUBSAMPLE FOR AIM1**
use "${datadir}DiRienz_data_merged.dta"
keep if bpci==1
*interaction var
gen did=post*medicare
label variable did "Interaction variable that indicates 1 if under BPCI contract and occurred after implementation"

save "${datadir}DiRienz_AIM1.dta", replace

**-----------------------------------------


//**AIM 1 RESULTS**//
//SAMPLE = BPCI HOSPITALS (treatment = MEDICARE)

**TABLES** (assorted, won't be using all but good info to have)

table year medicare, stat(mean totchg_w)
table year medicare, stat(mean los_w)
table year medicare, stat(mean postcare)
*table year medicare, stat(sum age3)
tabstat totchg_r totchg_w totchg_rlog, by(year) stat(mean sem)
tabstat los_r los_w los_rlog, by(year) stat(mean sem)
tabstat teach snf rehab ltc, by(year) stat(count mean sem)
tabstat totchg_w los_w postcare female highsev dual icu racecat percenturban median_householdincome bedsize hcontrl teach snf rehab ltc totaldisc, stat(mean sd min max) col(stat)
tabstat los_w totchg_w postcare, by(year) stat(mean sem min max)
tabstat los_w totchg_w postcare, by(year) stat(mean sem min max)
tabstat los_w totchg_w postcare, by(medicare) stat(mean sem min max)

*tabstat record_id, by(year) stat(count)
*bysort year : inspect thcic_id
*display r(N_unique)

tab ethnicity, m
tab racecat, m
table year racecat, stat(mean totchg_w)
table year racecat, stat(mean los_w)
table year racecat, stat(mean postcare)
table year insurance, stat(mean totchg_w)
table year insurance, stat(mean los_w)
table year insurance, stat(mean postcare)
*table year agecat, stat(mean totchg_w)
*table year agecat, stat(mean los_w)
*table year agecat, stat(mean postcare)

table year medicare, stat(mean teach)
table year medicare, stat(mean snf)
table year medicare, stat(mean rehab)
table year medicare, stat(mean ltc)

table year medicare if inlist(drg, 469, 470), stat(mean totchg_w)
table year medicare if inlist(drg, 391, 392), stat(mean totchg_w)
table year medicare if inlist(drg, 870, 871, 872), stat(mean totchg_w)
table year medicare if inlist(drg, 469, 470), stat(mean los_w)
table year medicare if inlist(drg, 391, 392), stat(mean los_w)
table year medicare if inlist(drg, 870, 871, 872), stat(mean los_w)
table year medicare if inlist(drg, 469, 470), stat(mean postcare)
table year medicare if inlist(drg, 391, 392), stat(mean postcare)
table year medicare if inlist(drg, 870, 871, 872), stat(mean postcare)


**look at facility characteristics

table bpci, stat(mean icu urban income bedsize hcontr)

*Parallel trends means: Medicare 65+ vs Private/Medicaid 45-64
table year medicare, stat(mean totchg_w)
table year medicare, stat(mean los_w)
table year medicare, stat(mean postcare)

table year medicare, stat(mean totchg_r)
table year medicare, stat(mean los_r)


**REGRESSIONS**
//stratified for snf, rehab, ltc, and teaching hospitals
//stratified for 3 most common BPCI drgs: Major Joint Replacement, Esophagitis, gastroenteritis and other digestive disorders, Sepsis 
//stratified for race and ethnicity

//total charges
reg totchg_r medicare post did, vce(cluster thcic_id)
reg totchg_w medicare post did, vce(cluster thcic_id)
reg totchg_rlog medicare post did, vce(cluster thcic_id)

reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

//length of stay
reg los_r medicare post did, vce(cluster thcic_id)
reg los_w medicare post did, vce(cluster thcic_id)
reg los_rlog medicare post did, vce(cluster thcic_id)

reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_r medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_w medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl if died==0, vce(cluster thcic_id)

reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_rlog medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

//postcare
logit postcare medicare post did, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, or vce(cluster thcic_id)
logit postcare medicare post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, or vce(cluster thcic_id)

clear
use "${datadir}DiRienz_AIM2.dta"

//**AIM 2 RESULTS**//
//SAMPLE = ALL HOSPITALS (treatment = BPCI)

**TABLES**

*codebook record_id
table year bpci, stat(mean totchg_w)
table year bpci, stat(mean los_w)
table year bpci, stat(mean postcare)
tabstat totchg_r totchg_w totchg_rlog, by(year) stat(mean sem)
tabstat los_r los_w los_rlog, by(year) stat(mean sem)
tabstat teach snf rehab ltc, by(year) stat(count mean sem)
tabstat totchg_w los_w postcare female highsev dual icu ethnicity racecat percenturban median_householdincome bedsize hcontrl teach snf rehab ltc totaldisc, stat(mean sd min max) col(stat)
tabstat los_w totchg_w postcare, by(year) stat(mean sem min max)
tabstat los_w totchg_w postcare, by(year) stat(mean sem min max)
tabstat los_w totchg_w postcare, by(bpci) stat(mean sem min max)

*tabstat record_id, by(year) stat(count)
*bysort year : inspect thcic_id
*display r(N_unique)

table year racecat, stat(mean totchg_w)
table year racecat, stat(mean los_w)
table year racecat, stat(mean postcare)
table year insurance, stat(mean totchg_w)
table year insurance, stat(mean los_w)
table year insurance, stat(mean postcare)
*table year agecat, stat(mean totchg_w)
*table year agecat, stat(mean los_w)
*table year agecat, stat(mean postcare)

table year bpci, stat(mean teach)
table year bpci, stat(mean snf)
table year bpci, stat(mean rehab)
table year bpci, stat(mean ltc)

table year bpci if inlist(drg, 469, 470), stat(mean totchg_w)
table year bpci if inlist(drg, 391, 392), stat(mean totchg_w)
table year bpci if inlist(drg, 870, 871, 872), stat(mean totchg_w)
table year bpci if inlist(drg, 469, 470), stat(mean los_w)
table year bpci if inlist(drg, 391, 392), stat(mean los_w)
table year bpci if inlist(drg, 870, 871, 872), stat(mean los_w)
table year bpci if inlist(drg, 469, 470), stat(mean postcare)
table year bpci if inlist(drg, 391, 392), stat(mean postcare)
table year bpci if inlist(drg, 870, 871, 872), stat(mean postcare)

*Parallel trends means: (ages 65+ Medicare patients, by bpci)
table year bpci, stat(mean totchg_w)
table year bpci, stat(mean los_w)
table year bpci, stat(mean postcare)

table year bpci, stat(mean totchg_r)
table year bpci, stat(mean los_r)


**REGRESSIONS**

reg totchg_r bpci post did, vce(cluster thcic_id)
reg totchg_w bpci post did, vce(cluster thcic_id)
reg totchg_rlog bpci post did, vce(cluster thcic_id)

reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg totchg_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

//length of stay
reg los_r bpci post did, vce(cluster thcic_id)
reg los_w bpci post did, vce(cluster thcic_id)
reg los_rlog bpci post did, vce(cluster thcic_id)

reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_r bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_w bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, vce(cluster thcic_id)
reg los_rlog bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if died==0, vce(cluster thcic_id)

//postcare
logit postcare bpci post did, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if snf==1, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if teach==1, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if rehab==1, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if ltc==1, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 469, 470), or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 391, 392), or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year if inlist(drg, 870, 871, 872), or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year if racecat==2 & ethnicity==1, or vce(cluster thcic_id)
logit postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if died==0, or vce(cluster thcic_id)

//postcare
reg postcare bpci post did,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year ,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if snf==1,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if teach==1,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if rehab==1,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if ltc==1,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if inlist(drg, 469, 470),   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if inlist(drg, 391, 392),   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if inlist(drg, 870, 871, 872),   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year  if racecat==2,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu i.urban i.income i.bedsize i.hcontrl i.year  if racecat==2 & ethnicity==1,   vce(cluster thcic_id)
reg postcare bpci post did female highsev dual icu ethnicity i.racecat i.urban i.income i.bedsize i.hcontrl i.year  if died==0,   vce(cluster thcic_id)



log close
