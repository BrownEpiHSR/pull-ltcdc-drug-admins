/**************************************************************************
PURPOSE: Output yearly benzodiazepine medication administrations
from yearly LTCDC medication administration files.

INPUT DATASETS: 
- Raw LTCDC Medication Administrations Datasets (raw.medication_admin_&year.)
	- Note that this program assumes the raw medication administration datasets are separated by year

%SUBSET_BENZOS MACRO INPUTS:
- out_prefix: Prefix for the output yearly administration datasets
- start_date: Earliest date that you want drug admins for
- end_date: Latest date that you want drug admins for

OUTPUT DATASETS:
- &out_prefix._&year.: SSRI medication administration records for the specified year.
	- Note that this program does not stack the medication administrations across years. 

**************************************************************************/

/*****************/
/*** Libraries ***/
/*****************/

libname raw     "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication administration datasets */
libname subset  "\\path\to\your\folder"; /* Path to your folder where the &out_prefix._&year. datasets will be saved */

/****************************************************************************/
/*** Subset yearly medication administration files to only include benzos ***/
/****************************************************************************/

%macro subset_benzos(
	out_prefix=,
	study_lookback_start_date=,
	study_end_date=
	);

	%do year = %sysfunc(year(&start_date.)) %to %sysfunc(year(&end_date.));

		data &out_prefix.&year.;
			set raw.medication_admin_&year.;

			/* Include records where either medication_generic_name or medication_name have non-missing values */
			where medication_generic_name^=" " or medication_name^=" ";

			if 
			index(lowcase(medication_generic_name), "lorazepam")>0 or
			index(lowcase(medication_generic_name), "ativan")>0 or
			index(lowcase(medication_generic_name), "loreev")>0 or
			index(lowcase(medication_name), "lorazepam")>0 or
			index(lowcase(medication_name), "ativan")>0 or
			index(lowcase(medication_name), "loreev")>0 
			then ben_loraz=1; else ben_loraz=0;

			if 
			index(lowcase(medication_generic_name), "clonazepam")>0 or
			index(lowcase(medication_generic_name), "klonopin")>0 or
			index(lowcase(medication_name), "clonazepam")>0 or
			index(lowcase(medication_name), "klonopin")>0 
			then ben_clona=1; else ben_clona=0;

			if 
			index(lowcase(medication_generic_name), "alprazolam")>0 or
			index(lowcase(medication_generic_name), "xanax")>0 or
			index(lowcase(medication_generic_name), "niravam")>0 or
			index(lowcase(medication_name), "alprazolam")>0 or
			index(lowcase(medication_name), "xanax")>0 or
			index(lowcase(medication_name), "niravam")>0
			then ben_alpra=1; else ben_alpra=0;

			if 
			index(lowcase(medication_generic_name), "diazepam")>0 or
			index(lowcase(medication_generic_name), "valium")>0 or
			index(lowcase(medication_generic_name), "diastat")>0 or
			index(lowcase(medication_generic_name), "valtoco")>0 or
			index(lowcase(medication_name), "diazepam")>0 or
			index(lowcase(medication_name), "valium")>0 or
			index(lowcase(medication_name), "diastat")>0 or
			index(lowcase(medication_name), "valtoco")>0 
			then ben_diaze=1; else ben_diaze=0;

			if 
			index(lowcase(medication_generic_name), "temazepam")>0 or
			index(lowcase(medication_generic_name), "restoril")>0 or
			index(lowcase(medication_name), "temazepam")>0 or
			index(lowcase(medication_name), "restoril")>0
			then ben_temaz=1; else ben_temaz=0;

			if 
			index(lowcase(medication_generic_name), "chlordiazepoxide")>0 or
			index(lowcase(medication_generic_name), "librium")>0 or
			index(lowcase(medication_generic_name), "librax")>0 or
			index(lowcase(medication_generic_name), "limbitrol")>0 or
			index(lowcase(medication_name), "chlordiazepoxide")>0 or
			index(lowcase(medication_name), "librium")>0 or
			index(lowcase(medication_name), "librax")>0 or
			index(lowcase(medication_name), "limbitrol")>0
			then ben_chlor=1; else ben_chlor=0;

			if 
			index(lowcase(medication_generic_name), "oxazepam")>0 or
			index(lowcase(medication_generic_name), "serax")>0 or 
			index(lowcase(medication_name), "oxazepam")>0 or
			index(lowcase(medication_name), "serax")>0
			then ben_oxaze=1; else ben_oxaze=0;

			if 
			index(lowcase(medication_generic_name), "clorazepate")>0 or
			index(lowcase(medication_generic_name), "tranxene")>0 or 
			index(lowcase(medication_generic_name), "tranxilium")>0 or
			index(lowcase(medication_generic_name), "gen-xene")>0 or 
			index(lowcase(medication_name), "clorazepate")>0 or
			index(lowcase(medication_name), "tranxene")>0 or
			index(lowcase(medication_name), "tranxilium")>0 or
			index(lowcase(medication_name), "gen-xene")>0
			then ben_clora=1; else ben_clora=0;

			if 
			index(lowcase(medication_generic_name), "clobazam")>0 or
			prxmatch('/(?i)\bonfi\b/i',medication_generic_name) or /*this identifies whole word onfi that appears in the string and wont catch a substring thats part of another word*/ 
			index(lowcase(medication_generic_name), "sympazan")>0 or
			index(lowcase(medication_name), "clobazam")>0 or
			prxmatch('/(?i)\bonfi\b/i',medication_name)	or 
			index(lowcase(medication_name), "sympazan")>0 
			then ben_cloba=1; else ben_cloba=0;

			if 
			index(lowcase(medication_generic_name), "estazolam")>0 or
			index(lowcase(medication_generic_name), "prosom")>0 or 
			index(lowcase(medication_name), "estazolam")>0 or
			index(lowcase(medication_name), "prosom")>0
			then ben_estaz=1; else ben_estaz=0;

			if 
			index(lowcase(medication_generic_name), "flurazepam")>0 or
			index(lowcase(medication_generic_name), "dalmane")>0 or 
			index(lowcase(medication_name), "flurazepam")>0 or
			index(lowcase(medication_name), "dalmane")>0
			then ben_flura=1; else ben_flura=0;

			if 
			index(lowcase(medication_generic_name), "quazepam")>0 or
			prxmatch('/(?i)\bdoral\b/i',medication_generic_name) or 
			index(lowcase(medication_name), "quazepam")>0 or
			prxmatch('/(?i)\bdoral\b/i',medication_name) 
			then ben_quaze=1; else ben_quaze=0;

			if 
			index(lowcase(medication_generic_name), "triazolam")>0 or
			index(lowcase(medication_generic_name), "halcion")>0 or 
			index(lowcase(medication_name), "triazolam")>0 or
			index(lowcase(medication_name), "halcion")>0
			then ben_triaz=1; else ben_triaz=0;

			if 
			index(lowcase(medication_generic_name), "midazolam")>0 or
			prxmatch('/(?i)\bversed\b/i',medication_generic_name) or
			index(lowcase(medication_generic_name), "nayzilam")>0 or
			index(lowcase(medication_generic_name), "seizalam")>0 or 
			index(lowcase(medication_name), "midazolam")>0 or
			prxmatch('/(?i)\bversed\b/i',medication_name)or
			index(lowcase(medication_name), "nayzilam")>0 or
			index(lowcase(medication_name), "seizalam")>0
			then ben_midaz=1; else ben_midaz=0;

			*count benzos;
			benzo_count = sum(	ben_loraz,
								ben_clona,
								ben_alpra,
								ben_diaze,
								ben_temaz,
								ben_chlor,
								ben_oxaze,
								ben_clora,
								ben_cloba,
								ben_estaz,
								ben_flura,
								ben_quaze,
								ben_triaz,
								ben_midaz );
			*only write record to new dataset if the count is greater than or equal to 1;
			if benzo_count >=1 then output;

			*add labels;
			label 
				ben_loraz="lorazepam"
				ben_clona="clonazepam"
				ben_alpra="alprazolam"
				ben_diaze="diazepam"
				ben_temaz="temazepam"
				ben_chlor="chlordiazepoxide"
				ben_oxaze="oxazepam"
				ben_clora="clorazepate"
				ben_cloba="clobazam"
				ben_estaz="estazolam"
				ben_flura="flurazepam"
				ben_quaze="quazepam"
				ben_triaz="triazolam"
				ben_midaz="midazolam"
				;

		run;

	%end;

	%put NOTE: subset_benzos macro finished on %sysfunc(today(), worddate.).;

%mend;

/* Example macro call */

%subset_benzos(
	out_prefix=inter.benzos_,
	start_date='01jul2019'd,
	end_date='21dec2023'd
);
