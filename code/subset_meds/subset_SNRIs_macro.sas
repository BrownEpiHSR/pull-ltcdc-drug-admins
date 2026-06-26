/*********************************************************************************************************************
PURPOSE: Output yearly SNRI medication administrations from yearly LTCDC medication administration files.

INPUT DATASETS:
- Raw LTCDC Medication Administrations Datasets (raw.medication_admin_&year.)
	- Note that this program assumes the raw medication administration datasets are separated by year

%SUBSET_SNRIS MACRO INPUTS:
- out_prefix: Prefix for the output yearly administration datasets
- start_date: Earliest date that you want drug admins for
- end_date: Latest date that you want drug admins for

OUTPUT DATASETS:
- &out_prefix._&year.: SNRI medication administration records for the specified year.
	- Note that this program does not stack the medication administrations across years. 

*******************************************************************************************************************/

/*****************/
/*** Libraries ***/
/*****************/

libname raw     "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication administration datasets */
libname subset  "\\path\to\your\folder"; /* Path to your folder where the &out_prefix._&year. datasets will be saved */

/***************************************************************************/
/*** Subset yearly medication administration files to only include SNRIs ***/
/***************************************************************************/

%macro subset_SNRIs(
	out_prefix=,
	start_date=,
	end_date=
	);

	%do year = %sysfunc(year(&start_date.)) %to %sysfunc(year(&end_date.));

		data &out_prefix.&year.;
			set raw.medication_admin_&year.;

			/* Include records where either medication_generic_name or medication_name have non-missing values */
			where medication_generic_name^=" " or medication_name^=" ";
		
			if 
			index(lowcase(medication_generic_name), "desvenlafaxine")>0 or
			index(lowcase(medication_generic_name), "khedezla")>0 or
			index(lowcase(medication_generic_name), "pristiq")>0 or
			index(lowcase(medication_name), "desvenlafaxine")>0 or
			index(lowcase(medication_name), "khedezla")>0 or
			index(lowcase(medication_name), "pristiq")>0 
			then SNRI_desve=1; else SNRI_desve=0;
		
			if 
			index(lowcase(medication_generic_name), "duloxetine")>0 or
			index(lowcase(medication_generic_name), "cymbalta")>0 or
			index(lowcase(medication_name), "duloxetine")>0 or
			index(lowcase(medication_name), "cymbalta")>0 
			then SNRI_dulox=1; else SNRI_dulox=0;
		
			if 
			index(lowcase(medication_generic_name), "levomilnacipran")>0 or
			index(lowcase(medication_generic_name), "fetzima")>0 or
			index(lowcase(medication_name), "levomilnacipran")>0 or
			index(lowcase(medication_name), "fetzima")>0 
			then SNRI_levom=1; else SNRI_levom=0;
		
			if 
			prxmatch('/(?i)\bmilnacipran\b/i',medication_generic_name) or
			index(lowcase(medication_generic_name), "savella")>0 or
			prxmatch('/(?i)\bmilnacipran\b/i',medication_name) or
			index(lowcase(medication_name), "savella")>0 
			then SNRI_milna=1; else SNRI_milna=0;	
		
			if 
			prxmatch('/(?i)\bvenlafaxine\b/i',medication_generic_name)  or
			index(lowcase(medication_generic_name), "effexor")>0 or
			prxmatch('/(?i)\bvenlafaxine\b/i',medication_name) or
			index(lowcase(medication_name), "effexor")>0 
			then SNRI_venla=1; else SNRI_venla=0;
		
		
			*count drugs;
					SNRI_count = sum(SNRI_desve,
									SNRI_dulox,
									SNRI_levom,
									SNRI_milna,
									SNRI_venla
									);
					*only write record to new dataset if the count is greater than or equal to 1;
					if SNRI_count >=1 then output;
		
		label 
			SNRI_desve="desvenlafaxine"
			SNRI_dulox="duloxetine"
			SNRI_levom="levomilnacipran"
			SNRI_milna="milnacipran"
			SNRI_venla="venlafaxine"
			;

		run;

	%end;

	%put NOTE: subset macro finished on %sysfunc(today(), worddate.).;

%mend;

/* Example macro call */

%subset_SNRIs(
	out_prefix=subset.SNRIs_,
	start_date='01jul2019'd,
	end_date='21dec2023'd
);

/* End of subset_SNRIs macro */
