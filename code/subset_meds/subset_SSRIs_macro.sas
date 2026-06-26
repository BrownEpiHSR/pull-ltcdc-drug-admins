/***************************************************************************************************************
PURPOSE: Output yearly SSRI medication administrations from yearly LTCDC medication administration files.

INPUT DATASETS:
- Raw LTCDC Medication Administrations Datasets (raw.medication_admin_&year.)
	- Note that this program assumes the raw medication administration datasets are separated by year

%SUBSET_SSRIS MACRO INPUTS:
- out_prefix: Prefix for the output yearly administration datasets
- start_date: Earliest date that you want drug admins for
- end_date: Latest date that you want drug admins for

OUTPUT DATASETS:
- &out_prefix._&year.: SSRI medication administration records for the specified year.
	- Note that this program does not stack the medication administrations across years. 
	
**************************************************************************************************************/

/*****************/
/*** Libraries ***/
/*****************/

libname raw     "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication administration datasets */
libname subset  "\\path\to\your\folder"; /* Path to your folder where the &out_prefix._&year. datasets will be saved */

/***************************************************************************/
/*** Subset yearly medication administration files to only include SSRIs ***/
/***************************************************************************/

%macro subset_SSRIs(
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
			prxmatch('/(?i)\bcitalopram\b/i',medication_generic_name)	or /*need to use prxmatch because escitalopram contains the substring citalopram)*/
			index(lowcase(medication_generic_name), "celexa")>0 or
			prxmatch('/(?i)\bcitalopram\b/i',medication_name)	or 
			index(lowcase(medication_name), "celexa")>0 
			then SSRI_cital=1; else SSRI_cital=0;
		
			if 
			index(lowcase(medication_generic_name), "escitalopram")>0 or
			index(lowcase(medication_generic_name), "lexapro")>0 or
			index(lowcase(medication_name), "escitalopram")>0 or
			index(lowcase(medication_name), "lexapro")>0
			then SSRI_escit=1; else SSRI_escit=0;
		
			if 
			index(lowcase(medication_generic_name), "fluoxetine")>0 or
			index(lowcase(medication_generic_name), "prozac")>0 or
			index(lowcase(medication_generic_name), "sarafem")>0 or
			index(lowcase(medication_generic_name), "symbyax")>0 or
			index(lowcase(medication_name), "fluoxetine")>0 or
			index(lowcase(medication_name), "prozac")>0 or
			index(lowcase(medication_name), "sarafem")>0 or
			index(lowcase(medication_name), "symbyax")>0 
			then SSRI_fluox=1; else SSRI_fluox=0;
		
			if 
			index(lowcase(medication_generic_name), "fluvoxamine")>0 or
			index(lowcase(medication_generic_name), "luvox")>0 or
			index(lowcase(medication_name), "fluvoxamine")>0 or
			index(lowcase(medication_name), "luvox")>0
			then SSRI_fluvo=1; else SSRI_fluvo=0;
		
			if 
			index(lowcase(medication_generic_name), "paroxetine")>0 or
			index(lowcase(medication_generic_name), "brisdelle")>0 or
			index(lowcase(medication_generic_name), "paxil")>0 or
			index(lowcase(medication_generic_name), "pexeva")>0 or
			index(lowcase(medication_name), "paroxetine")>0 or
			index(lowcase(medication_name), "brisdelle")>0 or
			index(lowcase(medication_name), "paxil")>0 or
			index(lowcase(medication_name), "pexeva")>0 
			then SSRI_parox=1; else SSRI_parox=0;
		
			if 
			index(lowcase(medication_generic_name), "sertraline")>0 or
			index(lowcase(medication_generic_name), "zoloft")>0 or
			index(lowcase(medication_name), "sertraline")>0 or
			index(lowcase(medication_name), "zoloft")>0 
			then SSRI_sertr=1; else SSRI_sertr=0;
		
					*count MRs;
					SSRI_count = sum(SSRI_cital,
									SSRI_escit,
									SSRI_fluox,
									SSRI_fluvo,
									SSRI_parox,
									SSRI_sertr
									);
					*only write record to new dataset if the count is greater than or equal to 1;
					if SSRI_count >=1 then output;
		
		label 
			SSRI_cital="citalopram"
			SSRI_escit="escitalopram"
			SSRI_fluox="fluoxetine"
			SSRI_fluvo="fluvoxamine"
			SSRI_parox="paroxetine"
			SSRI_sertr="sertraline"
			;

		run;

	%end;

	%put NOTE: subset macro finished on %sysfunc(today(), worddate.).;

%mend;

/* Example macro call */

%subset_SSRIs(
	out_prefix=subset.SSRIs_,
	start_date='01jul2019'd,
	end_date='21dec2023'd
);

/* End of subset_SSRIs macro */
