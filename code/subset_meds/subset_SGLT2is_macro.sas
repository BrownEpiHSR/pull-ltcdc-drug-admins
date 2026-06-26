/**************************************************************************************************************************************************************************
PURPOSE: Extract LTCDC SGLT2 inhibitor medication administrations from the June 2025 LTCDC data cut

INPUT DATASETS:
- Raw LTCDC Medication Administration Datasets (raw.medication_admin_&year.)
	- Note that this program assumes the raw medication administration datasets are separated by year.

%SUBSET_SGLT2I MACRO INPUTS:
- output_name: name to give the file created from this macro
- start_date: earliest date of medication administrations to pull, preferably in SAS date9 format like '01jan2019'd
- end_date: latest date of medication administrations to pull, preferably in SAS date9 format like '31dec2024'd

OUTPUT DATASETS:
- &output_name dataset: SGLT2 inhibitor medication administration records for the specified years of interest

OTHER NOTES:
    - There are six SGLT2 inhibitors as of the time of this script's creation: bexagliflozin, canagliflozin, dapagliflozin, empagliflozin, ertugliflozin, and sotagliflozin
    - This script searches for medications by both generic and brand name, including combination meds like empagliflozin/metformin
    - In this data cut, generic & brand names can both appear in either medication_generic_name or medication_name
    - Regardless of start_date and end_date, this script will not pull SGLT2i administrations before January 1, 2019 ('01jan2019'd) or after December 31, 2024 ('31dec2024'd). 
	  See the medication administration completeness guidance doc in this repo for why.
****************************************************************************************************************************************************************************/

libname ehr     "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication administrations datasets */
libname subset  "\\path\to\your\folder"; /* Path to folder where the &output_name dataset will be saved */

%macro subset_sglt2i(output_name, start_date, end_date);
	%let start_year = %sysfunc(year(&start_date));
	%let end_year = %sysfunc(year(&end_date));

	data &output_name;
		set ehr.medication_admin_&start_year.-ehr.medication_admin_&end_year.;
		where 
			&start_date <= datepart(medication_event_date) <= &end_date and
			(
				/* bexagliflozin generic & brand names - this medication has no combination drugs as of time of this script's creation */
				find(medication_generic_name, 'bexagliflozin', 'i') or
				find(medication_name, 'bexagliflozin', 'i') or
				find(medication_generic_name, 'brenzavvy', 'i') or
				find(medication_name, 'brenzavvy', 'i') or
				/* canagliflozin generic & brand names for both the medication alone & its combinations like canagliflozin/metformin (Invokamet) */
				find(medication_generic_name, 'canagliflozin', 'i') or
				find(medication_name, 'canagliflozin', 'i') or
				find(medication_generic_name, 'invokana', 'i') or
				find(medication_name, 'invokana', 'i') or
				find(medication_generic_name, 'invokamet', 'i') or
				find(medication_name, 'invokamet', 'i') or
				/* dapagliflozin generic & brand names for both the medication alone & its combinations like dapagliflozin/metformin (Xigduo) */
				find(medication_generic_name, 'dapagliflozin', 'i') or
				find(medication_name, 'dapagliflozin', 'i') or
				find(medication_generic_name, 'farxiga', 'i') or
				find(medication_name, 'farxiga', 'i') or
				find(medication_generic_name, 'xigduo', 'i') or
				find(medication_name, 'xigduo', 'i') or
				find(medication_generic_name, 'qtern', 'i') or
				find(medication_name, 'qtern', 'i') or
				/* empagliflozin generic & brand names for both the medication alone & its combinations like empagliflozin/metformin (Synjardy) */
				find(medication_generic_name, 'empagliflozin', 'i') or
				find(medication_name, 'empagliflozin', 'i') or
				find(medication_generic_name, 'jardiance', 'i') or
				find(medication_name, 'jardiance', 'i') or
				find(medication_generic_name, 'glyxambi', 'i') or
				find(medication_name, 'glyxambi', 'i') or
				find(medication_generic_name, 'synjardy', 'i') or
				find(medication_name, 'synjardy', 'i') or
				find(medication_generic_name, 'trijardy', 'i') or
				find(medication_name, 'trijardy', 'i') or
				/* ertugliflozin generic & brand names for both the medication alone & its combinations like ertugliflozin/metformin (Segluromet) */
				find(medication_generic_name, 'ertugliflozin', 'i') or
				find(medication_name, 'ertugliflozin', 'i') or
				find(medication_generic_name, 'steglatro', 'i') or
				find(medication_name, 'steglatro', 'i') or
				find(medication_generic_name, 'segluromet', 'i') or
				find(medication_name, 'segluromet', 'i') or
				find(medication_generic_name, 'steglujan', 'i') or
				find(medication_name, 'steglujan', 'i') or
				/* sotagliflozin generic & brand names - this medication has no combination drugs as of time of this script's creation */
				find(medication_generic_name, 'sotagliflozin', 'i') or
				find(medication_name, 'sotagliflozin', 'i') or
				find(medication_generic_name, 'inpefa', 'i') or
				find(medication_name, 'inpefa', 'i')
			)
		;
		/* store the actual date of administration since many analyses rely on the date component rather than the exact time */
		med_adm_date = datepart(medication_event_date);
		format med_adm_date date9.;
	run;
%mend;

/* %subset_sglt2i(subset.sglt2i_admins_in_time_frame, '01jan2022'd, '31dec2023'd); */

/*
This code will take a very long time to run, potentially over 24 hours. Using the Job Board may make things faster.
*/
