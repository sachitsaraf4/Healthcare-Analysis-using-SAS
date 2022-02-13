ods rtf  "/home/u42024937/fall1_crm/project/health.csv";
PROC IMPORT OUT= x1 
	DATAFILE= "/home/u42024937/fall1_crm/project/health.csv" 
	DBMS=csv REPLACE;
    GETNAMES=YES;
RUN;


proc contents data = x1;
run;

/* split data: 80% train - 20% test */
proc surveyselect data=x1 out=x2 method=srs samprate=0.80
outall seed=12345 noprint;
samplingunit case_id;
run;

data train; set x2;
if selected=1;
run;

data test; set x2;
if selected=0;
run;

/* remove unnecessary column */
data train;
set train;
drop Selected case_id;
run;

data test;
set test;
drop Selected case_id;
run;

/* convert 'bed_grade' and 'city_code_hospital' to character variables */
data train;
set train;
bed_grade2 = put(bed_grade, 1.);
city_code_hospital2 = put(city_code_hospital, 2.);
drop bed_grade city_code_hospital;
rename bed_grade2 = bed_grade city_code_hospital2 = city_code_hospital;
run;

data test;
set test;
bed_grade2 = put(bed_grade, 1.);
city_code_hospital2 = put(city_code_hospital, 2.);
drop bed_grade city_code_hospital;
rename bed_grade2 = bed_grade city_code_hospital2 = city_code_hospital;
run;


proc contents data = train;
run;

/* ordinal logistic regression - hospital-related variables */
proc logistic data = train descending;
class bed_grade city_code_hospital department ward_type;
model stay = bed_grade city_code_hospital department ward_type available_extra_rooms;
score data=work.test out=work.prediction;
run; * acc = 0.2762;

/* accuracy */
proc sql;
select COUNT(*) / (select COUNT(*) from prediction)
from prediction
where F_stay = I_stay;
run;

/* ordinal logistic regression - hospital-related  + patient related variables */
proc logistic data = train;
class age bed_grade city_code_hospital department   
	  severity_of_illness type_of_admission ward_type;
model stay = age bed_grade city_code_hospital department   
	  severity_of_illness type_of_admission ward_type admission_deposit
	  available_extra_rooms visitors_with_patient;
score data=work.test out=work.prediction;
run; * acc = 0.355491;

/* accuracy */
proc sql;
select COUNT(*) / (select COUNT(*) from prediction)
from prediction
where F_stay = I_stay;
run;


