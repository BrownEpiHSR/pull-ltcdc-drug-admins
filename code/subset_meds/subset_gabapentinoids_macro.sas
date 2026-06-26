/***************************************************************************************************************
PURPOSE:
Subset medication administration records to oral forms of gabapentin and pregabalin, sorting 
by master_patient_id and medication_event_date.

INPUT DATASETS:
- Raw LTCDC 2022-2025 Medication Administration Datasets:
	raw.medication_admin_2022
	raw.medication_admin_2023
	raw.medication_admin_2024
	raw.medication_admin_2025

OUTPUT DATASETS: 
- dsets.raw_d_gabapentin: one record per administration, containing all gabapentin and pregabalin administration records.

NOTE:
Best to run on the job board. This can take approximately 13 hours.

**************************************************************************************************************/

/* Specify library paths */
libname raw "path\to\ltcdc\ehr\folder";          /* Path to raw LTCDC medication administration datasets */
libname dsets "path\to\your\derived\datasets";   /* Path to your folder where the subsetted gabapentinoid administrations are saved */

/* Define a macro variable for subsetting each domain to Gabapentinoid (e.g., gabapentin and pregabalin) records. */
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
					   and       
						(index(lowcase(MEDICATION_FORM), "caps")>0
					  or index(lowcase(MEDICATION_FORM), "caplet")>0
					  or index(lowcase(MEDICATION_FORM), "solution")>0
					  or index(lowcase(MEDICATION_FORM), "suspension")>0
					  or index(lowcase(MEDICATION_FORM), "tablet")>0
						  )
					   and 
						 index(lowcase(MEDICATION_ROUTE), "oral")>0
;

/* Subset to oral gabapentin and pregabalin administration records
   - 126,106,753 records
   - (~12 hours). */
data dsets.di_medication_admin;
set raw.medication_admin_2022(where=(&GABSUB.))
	raw.medication_admin_2023(where=(&GABSUB.))
	raw.medication_admin_2024(where=(&GABSUB.))
	raw.medication_admin_2025(where=(&GABSUB.))
;
run;

/* Sort by patient ID and date-time
   - (~22 minutes). */
proc sort data=dsets.di_medication_admin
		  out=dsets.raw_d_gabapentin; 
		  by MASTER_PATIENT_ID MEDICATION_EVENT_DATE; 
run;

/* Remove extra dataset */
proc datasets library= dsets nolist;
delete di_medication_admin;
quit;

