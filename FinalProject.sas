libname data1 '/home/rtripat/EPG194/output';

/* Importing data into SAS Table */

/* Importing Total Deaths so Far for United States - 1997-2017 */
options VALIDVARNAME=V7;
proc import datafile = '/home/rtripat/EPG194/data/NCHSData.xlsx'
DBMS=XLSX
out = data1.total_all_causes REPLACE;
sheet='All Causes';
run; 


/* Importing Total Deaths so Far for United States & Each State
  by each disease - 1997-2017 */
options VALIDVARNAME=V7;
proc import datafile = '/home/rtripat/EPG194/data/NCHSData.xlsx'
DBMS=XLSX
out = data1.death_by_diseases REPLACE;
sheet='NCHS_-_Leading_Causes_of_Death_';
run; 


/* Restructing the sas table and renaming/dropping columns */
data data1.total_all_cases;
	set data1.total_all_causes;
	label  _113_Cause_Name = 'Cause Name'
	  Cause_Name = 'Common Name';
	drop Age_adjusted_Death_Rate;
run;

proc contents data= data1.total_all_cases;
run;


/* Restructing the sas table and renaming/dropping columns for USA*/
data data1.total_deaths_usa_overall;
set data1.total_all_cases;
where State = 'United States';
run;

/* Restructing the sas OVERALL table and renaming/dropping columns for each state */
data data1.total_deaths_state_overall;
set data1.total_all_cases;
where State NE 'United States';
run;

/* Restructing the death_by_disease table by filtering out USA for each diseases */
data data1.deaths_usa_each_cause;
set data1.death_by_diseases;
where State = 'United States';
label  _113_Cause_Name = 'Cause Name'
	  Cause_Name = 'Common Name';
	drop Age_adjusted_Death_Rate;
run;

/* Restructing the death_by_disease table and renaming/dropping columns for each state (EXCEPT usa) */
data data1.deaths_each_state_cause;
set data1.death_by_diseases;
where State NE 'United States';
label  _113_Cause_Name = 'Cause Name'
	  Cause_Name = 'Common Name';
	drop Age_adjusted_Death_Rate;
run;


/* means procedure to analyze max, mean, avg cases in USA for last 20 years */
%let outpath = /home/rtripat/EPG194/output;
ods pdf file =  "&outpath/USAOverallDeath.pdf" startpage=no;

ods noproctitle;
ods proclabel "Statistical Report of the above graph";
title 'Overall Statistical Report of USA from the period of 1997-2017';
proc means data= data1.total_deaths_usa_overall;
var Deaths;
run;
title;


/* Graph of Deaths by all causes in USA from 1999-2017 */
title "Deaths by all causes in USA from 1999-2017";
PROC SGPLOT DATA = data1.total_deaths_usa_overall noborder;
format Deaths COMMA8.;
vbar Year/ response=Deaths
datalabel dataskin=matte
baselineattrs=(thickness=0)
fillattrs=(color=red);
yaxis display=(noline noticks) grid;
run;
title;
ods pdf close;

/* Graph of Deaths in each state for 2017,2016,2015 */
ods rtf file='/home/rtripat/EPG194/output/Deaths2015_2017.rtf';

ods graphics on / width=20in height=6in;
title "Deaths by all causes in all states from 2015-2017";
proc sgplot data = data1.total_deaths_state_overall(where=(Year>=2015));
scatter x=State y=Deaths / datalabel=Deaths markerattrs=(symbol=CircleFilled size=8)
group= Year;
xaxis display=(noline noticks) grid;
run;
title;

ods rtf close;

/* Graph of death by each diseae from 1999-2017 in top 3 states (California, Texas and Florida) */
ods excel file='/home/rtripat/EPG194/output/StateDeath1999_2017.xlsx';
%let state_name = California;
ods graphics on / width=20in height=6in;
title "Deaths by each causes in &state_name from 1999-2017";
proc sgplot data = data1.deaths_each_state_cause(where=(State="&state_name"));
series x=Year y=Deaths / datalabel=Deaths group=Common_Name;
xaxis display=(noline noticks) grid;
run;
title;

/* means data for each cause from 1999-2007 */
ods noproctitle;
title "Statistical Report of deaths by each disease in &state_name over the period of 1999-2017";
PROC MEANS DATA = data1.deaths_each_state_cause(where=(State="&state_name"))  ;
var Deaths;
class Common_Name;
run;
title;
ODS excel close;

/* Graph of death by each diseae from 1999-2017 in the USA */

ods excel file='/home/rtripat/EPG194/output/OverallStatsGraph.xlsx';

ods graphics on / width=20in height=6in;
title "Deaths by each causes in the USA from 1999-2017";
proc sgplot data = data1.deaths_usa_each_cause;
series x=Year y=Deaths / datalabel=Deaths group=Common_Name;
xaxis display=(noline noticks) grid;
run;
title;


/* means data for each cause from 1999-2007 for USA*/
/* ods noproctitle; */
title 'Statistical Report of Overall Deaths in USA from the period of 1999-2017 by each disease';
PROC MEANS DATA = data1.deaths_usa_each_cause;
var Deaths;
class Common_Name;	
run;
title;
ODS excel close;


proc print data=data1.death_by_diseases (obs=10) label;
run;


PROC print data = data1.deaths_usa_each_cause (obs=20) label;
run;


libname data1 clear;