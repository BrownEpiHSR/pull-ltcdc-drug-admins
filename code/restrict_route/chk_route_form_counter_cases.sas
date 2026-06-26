/***************************************************************************************************************
PURPOSE:
Show cases where unknown medication route can likely be inferred as "oral" based on the medication form being "capsule", "tablet", or "solution".
Show counter-cases where the medication route is something other than "oral" when the medication form is "capsule", "tablet", or "solution".

INPUT DATASETS:
- Raw LTCDC Medication Orders Dataset

OUTPUT DATASETS:
- d_gab: Gabapentin orders from the LTCDC medication orders dataset

NOTE:
The following code can be adapted to medication administrations by modifying the set statement in the data step below.

**************************************************************************************************************/

/* Libraries */

libname raw "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication orders dataset */ 

/* Define a macro variable for subsetting to Gabapentinoid records. */
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

/* Subset to gabapentin records. */
data d_gab;
set raw.medication_orders(where=(&GABSUB.));
run;

title "FORM where ROUTE is 'Unknown' - likely to be orally administered capsule, tablet, or solution";
proc freq data = d_gab;
table MEDICATION_FORM / list missing;
where lowcase(MEDICATION_ROUTE) eq "unknown" or MEDICATION_ROUTE eq "";
run;

title "ROUTE where FORM is a capsule, tablet, or solution, but not orally administered";
proc freq data = d_gab;
table MEDICATION_ROUTE / list missing;
where lowcase(MEDICATION_ROUTE) ne "unknown" and lowcase(MEDICATION_ROUTE) ne "oral" 
	  and (lowcase(MEDICATION_FORM) contains "cap" or lowcase(MEDICATION_FORM) contains "tab" or lowcase(MEDICATION_FORM) contains "solut");
run;


