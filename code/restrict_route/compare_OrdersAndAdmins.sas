/***************************************************************************************************************
PURPOSE:
Compare _frequency, _strength, _dose, _form and _route between all gabapentin orders and administrations.

INPUT DATASETS:
- Raw LTCDC Medication Orders Dataset (raw.medication_orders)
- Raw LTCDC Medication Administrations Datasets (raw.medication_admin_&YEARV.)
	- Note that this program assumes the raw medication administration datasets are separated by year

OUTPUT DATASETS:
- dsets.d_OrdersAdminsCompare_&YEARV.: Annual gabapentin administrations matched to their corresponding medication orders using MEDICATION_ORDER_ID.

NOTE: This take approximately one day to run.
	  Need to set up the libnames below.
	  Enter one year at a time for each macro run.

HOW THIS PROGRAM WORKS:
1) Subset the medication orders to gabapentinoids and derive some variables.
2) Separately for each year, subset the administrations to gabapentinoids and derive some variables - save intermediate dataset 1.
3) Merge the orders and administrations - save final dataset 1 and delete intermediate dataset 1.
4) Repeat steps 1 through 3 for each year you're interested in.

**************************************************************************************************************/

/* Set up libnames */
libname raw    "\\path\to\ltcdc\data";            /* Directory for source data */
libname inter  "\\path\to\your\inter\folder";     /* Directory for intermediate dataset storage */
libname dsets  "\\path\to\your\final\folder";     /* Directory for final datasets */

/* Define a macro variable for subsetting each dataset to Gabapentinoid records. */
%let GABSUB = 
						 (index(lowcase(MEDICATION_NAME), "gabapentin")>0 
				  	   or index(lowcase(MEDICATION_NAME), "gabarone")>0
				       or index(lowcase(MEDICATION_NAME), "neurontin")>0
					   or index(lowcase(MEDICATION_NAME), "gralise")>0
					   or index(lowcase(MEDICATION_NAME), "horizant")>0
					   or index(lowcase(MEDICATION_NAME), "pregabalin")>0
					   or index(lowcase(MEDICATION_NAME), "lyrica")>0

					   or index(lowcase(MEDICATION_GENERIC_NAME), "gabapentin")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "gabarone")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "neurontin")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "gralise")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "horizant")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "pregabalin")>0
					   or index(lowcase(MEDICATION_GENERIC_NAME), "lyrica")>0
						 )
;

/* Rename variables in the orders to have the prefix "o_". */
%let o_RENAMEV = MEDICATION_FREQUENCY = o_MEDICATION_FREQUENCY
			   MEDICATION_STRENGTH = o_MEDICATION_STRENGTH
			   MEDICATION_DOSE = o_MEDICATION_DOSE
			   MEDICATION_ROUTE = o_MEDICATION_ROUTE
			   MEDICATION_FORM = o_MEDICATION_FORM
;

/* Rename variables in the administrations to have the prefix "a_". */
%let a_RENAMEV = MEDICATION_FREQUENCY = a_MEDICATION_FREQUENCY
			   MEDICATION_STRENGTH = a_MEDICATION_STRENGTH
			   MEDICATION_DOSE = a_MEDICATION_DOSE
			   MEDICATION_ROUTE = a_MEDICATION_ROUTE
			   MEDICATION_FORM = a_MEDICATION_FORM
;

/*******************************/
/* Subset to gabapentin orders */
/*******************************/

data d_gab_byOrder0;
set raw.medication_orders(rename = (&o_RENAMEV.) where = (&GABSUB.));

ODT = datepart(MEDICATION_ORDER_DATE);
format ODT date9.;
OYR = YEAR(ODT);
;
/* Missingness indicators. */
if missing(o_MEDICATION_FREQUENCY) then o_FREQUENCY_miss = "Y";
else									o_FREQUENCY_miss = "N";

if missing(o_MEDICATION_STRENGTH) then o_STRENGTH_miss = "Y";
else								   o_STRENGTH_miss = "N";

if missing(o_MEDICATION_DOSE) then o_DOSE_miss = "Y";
else							   o_DOSE_miss = "N";

if missing(o_MEDICATION_ROUTE) then o_ROUTE_miss = "Y";
else							    o_ROUTE_miss = "N";

if missing(o_MEDICATION_FORM) then o_FORM_miss = "Y";
else							   o_FORM_miss = "N";

keep MEDICATION_ORDER_ID ODT OYR
	 o_MEDICATION_FREQUENCY o_FREQUENCY_miss 
	 o_MEDICATION_STRENGTH 	o_STRENGTH_miss
	 o_MEDICATION_DOSE 		o_DOSE_miss
	 o_MEDICATION_ROUTE 	o_ROUTE_miss
	 o_MEDICATION_FORM 		o_FORM_miss;
run;

/* Remove duplicates and save the orders dataset in the intermediate directory. */
proc sort data=d_gab_byOrder0 noduprecs out = d_gab_byOrder0_dupless; by _all_; run;
proc sort data=d_gab_byOrder0_dupless out=inter.di_gab_byOrder; by MEDICATION_ORDER_ID; run;

/************************************************/
/* Subset to gabapentin administration records. */
/* Macro to handle each year separately.        */
/************************************************/

%macro AdminYr(yearv = );
data inter.di_gab_byAdmin_&YEARV.;
set raw.medication_admin_&YEARV.(rename = (&a_RENAMEV.) where=(&GABSUB.))
;

/* Missingness indicators for administration records. */
if missing(a_MEDICATION_FREQUENCY) then a_FREQUENCY_miss = "Y";
else									a_FREQUENCY_miss = "N";

if missing(a_MEDICATION_STRENGTH) then a_STRENGTH_miss = "Y";
else								   a_STRENGTH_miss = "N";

if missing(a_MEDICATION_DOSE) then a_DOSE_miss = "Y";
else							   a_DOSE_miss = "N";

if missing(a_MEDICATION_ROUTE) then a_ROUTE_miss = "Y";
else							    a_ROUTE_miss = "N";

if missing(a_MEDICATION_FORM) then a_FORM_miss = "Y";
else							   a_FORM_miss = "N";

keep MEDICATION_ORDER_ID 
	 a_MEDICATION_FREQUENCY a_FREQUENCY_miss 
	 a_MEDICATION_STRENGTH  a_STRENGTH_miss
	 a_MEDICATION_DOSE 		a_DOSE_miss
	 a_MEDICATION_ROUTE 	a_ROUTE_miss
	 a_MEDICATION_FORM 		a_FORM_miss;
run;

/*****************************************/
/* Link the orders and administrations   */
/* and save a final dataset. 			 */
/*****************************************/

proc sort data=inter.di_gab_byAdmin_&YEARV.; by MEDICATION_ORDER_ID; run;
data dsets.d_OrdersAdminsCompare_&YEARV.;
merge inter.di_gab_byOrder(in=ino)
	  inter.di_gab_byAdmin_&YEARV.(in=ina);
by MEDICATION_ORDER_ID;
if ino and ina;
if first.MEDICATION_ORDER_ID then subsetvar = 1;
run;

/* Delete intermediate administrations dataset. */
proc datasets library= inter nolist;
delete di_gab_byAdmin_&YEARV.;
quit;

%mend AdminYr;

%AdminYr(yearv = 2011);
%AdminYr(yearv = 2012);
%AdminYr(yearv = 2013);
%AdminYr(yearv = 2014);
%AdminYr(yearv = 2015);
%AdminYr(yearv = 2016);
%AdminYr(yearv = 2017);
%AdminYr(yearv = 2018);
%AdminYr(yearv = 2019);
%AdminYr(yearv = 2020);
%AdminYr(yearv = 2021);
%AdminYr(yearv = 2022);
%AdminYr(yearv = 2023);
%AdminYr(yearv = 2024);
%AdminYr(yearv = 2025);
%AdminYr(yearv = no_year);

/* Delete intermediate orders dataset. */
proc datasets library= inter nolist;
delete di_gab_byorder;
quit;
