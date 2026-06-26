/*******************************************************************************************
PURPOSE: Output yearly muscle relaxants (MRs) medication administrations
from yearly LTCDC medication administration files.

INPUT DATASETS:
- Raw LTCDC Medication Administrations Datasets (raw.medication_admin_&year.)
	- Note that this program assumes the raw medication administration datasets are separated by year

%SUBSET_MRS MACRO INPUTS:
- out_prefix: Prefix for the output yearly administration datasets
- start_date: Earliest date that you want drug admins for
- end_date: Latest date that you want drug admins for

OUTPUT DATASETS:
- &out_prefix._&year.: SSRI medication administration records for the specified year.
	- Note that this program does not stack the medication administrations across years. 

*******************************************************************************************/

/*****************/
/*** Libraries ***/
/*****************/

libname raw     "\\path\to\ltcdc\data";  /* Path to raw LTCDC medication administration datasets */
libname subset  "\\path\to\your\folder"; /* Path to your folder where the &out_prefix._&year. datasets will be saved */

/*************************************************************************/
/*** Subset yearly medication administration files to only include MRs ***/
/*************************************************************************/

%macro subset_MRs(
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
			index(lowcase(medication_generic_name), "baclofen")>0 or
			index(lowcase(medication_generic_name), "lioresal")>0 or
			index(lowcase(medication_generic_name), "gablofen")>0 or
			index(lowcase(medication_generic_name), "ozobax")>0 or
			index(lowcase(medication_generic_name), "kemstro")>0 or
			index(lowcase(medication_generic_name), "lyvispah")>0 or
			index(lowcase(medication_generic_name), "fleqsuvy")>0 or
			index(lowcase(medication_name), "baclofen")>0 or
			index(lowcase(medication_name), "lioresal")>0 or
			index(lowcase(medication_name), "gablofen")>0 or
			index(lowcase(medication_name), "ozobax")>0 or
			index(lowcase(medication_name), "kemstro")>0 or
			index(lowcase(medication_name), "lyvispah")>0 or
			index(lowcase(medication_name), "fleqsuvy")>0 
			then MR_baclo=1; else MR_baclo=0;
		
			if 
			index(lowcase(medication_generic_name), "cyclobenzaprine")>0 or
			index(lowcase(medication_generic_name), "amrix")>0 or
			index(lowcase(medication_generic_name), "fexmid")>0 or
			index(lowcase(medication_generic_name), "flexeril")>0 or
			index(lowcase(medication_generic_name), "fusepaq")>0 or
			index(lowcase(medication_generic_name), "tabradol")>0 or
			index(lowcase(medication_name), "cyclobenzaprine")>0 or
			index(lowcase(medication_name), "amrix")>0 or
			index(lowcase(medication_name), "fexmid")>0 or
			index(lowcase(medication_name), "flexeril")>0 or
			index(lowcase(medication_name), "fusepaq")>0 or
			index(lowcase(medication_name), "tabradol")>0
			then  MR_cyclo=1; else MR_cyclo=0;
		
			if 
			index(lowcase(medication_generic_name), "methocarbamol")>0 or
			index(lowcase(medication_generic_name), "robaxin")>0 or
			index(lowcase(medication_generic_name), "robaxisal")>0 or
			index(lowcase(medication_name), "methocarbamol")>0 or
			index(lowcase(medication_name), "robaxin")>0 or
			index(lowcase(medication_generic_name), "robaxisal")>0 
			then MR_metho=1; else MR_metho=0;
		
			if
			index(lowcase(medication_generic_name), "tizanidine")>0 or
			index(lowcase(medication_generic_name), "zanaflex")>0 or
			index(lowcase(medication_generic_name), "ontralfy")>0 or
			index(lowcase(medication_name), "tizanidine")>0 or
			index(lowcase(medication_name), "zanaflex")>0 or
			index(lowcase(medication_name), "ontralfy")>0 
			then MR_tizan=1; else MR_tizan=0;
		
			if
			index(lowcase(medication_generic_name), "carisoprodol")>0 or
			prxmatch('/(?i)\bsoma\b/i',medication_generic_name)	or
			index(lowcase(medication_name), "carisoprodol")>0 or
			prxmatch('/(?i)\bsoma\b/i',medication_name)	
			then MR_caris=1; else MR_caris=0;
		
			if
			index(lowcase(medication_generic_name), "metaxalone")>0 or
			index(lowcase(medication_generic_name), "skelaxin")>0 or
			index(lowcase(medication_generic_name), "metaxal")>0 or
			index(lowcase(medication_name), "metaxalone")>0 or
			index(lowcase(medication_name), "skelaxin")>0 or
			index(lowcase(medication_name), "metaxal")>0 
			then MR_metax=1; else MR_metax=0;
		
			if
			index(lowcase(medication_generic_name), "chlorzoxazone")>0 or
			index(lowcase(medication_generic_name), "lorzone")>0 or
			index(lowcase(medication_generic_name), "relaxazone")>0 or
			index(lowcase(medication_generic_name), "remular-s")>0 or
			index(lowcase(medication_name), "chlorzoxazone")>0 or
			index(lowcase(medication_name), "lorzone")>0 or
			index(lowcase(medication_name), "relaxazone")>0 or
			index(lowcase(medication_name), "remular-s")>0 
			then MR_chlor=1; else MR_chlor=0;
		
			if
			index(lowcase(medication_generic_name), "orphenadrine")>0 or
			index(lowcase(medication_generic_name), "norflex")>0 or
			index(lowcase(medication_generic_name), "norgesic")>0 or
			index(lowcase(medication_generic_name), "orphengesic")>0 or
			index(lowcase(medication_name), "orphenadrine")>0 or
			index(lowcase(medication_name), "norflex")>0 or
			index(lowcase(medication_name), "norgesic")>0 or
			index(lowcase(medication_name), "orphengesic")>0 
			then MR_orphe=1; else MR_orphe=0;
		
			if
			index(lowcase(medication_generic_name), "dantrolene")>0 or
			index(lowcase(medication_generic_name), "dantrium")>0 or
			index(lowcase(medication_generic_name), "ryanodex")>0 or
			index(lowcase(medication_generic_name), "revonto")>0 or
			index(lowcase(medication_name), "dantrolene")>0 or
			index(lowcase(medication_name), "dantrium")>0 or
			index(lowcase(medication_name), "ryanodex")>0 or
			index(lowcase(medication_name), "revonto")>0 
			then MR_dantr=1; else MR_dantr=0;
		
			*count MRs;
			MR_count = sum(	MR_baclo,
							MR_cyclo,
							MR_metho,
							MR_tizan,
							MR_caris,
							MR_metax,
							MR_chlor,
							MR_orphe,
							MR_dantr);
			*only write record to new dataset if the count is greater than or equal to 1;
			if MR_count >=1 then output;
		
		label 
			MR_baclo="baclofen"
			MR_cyclo="cyclobenzaprine"
			MR_metho="methocarbamol"
			MR_tizan="tizanidine"
			MR_caris="carisoprodol"
			MR_metax="metaxalone"
			MR_chlor="chlorzoxazone"
			MR_orphe="orphenadrine"
			MR_dantr="dantrolene"
			;

		run;

	%end;

	%put NOTE: subset_MRs macro finished on %sysfunc(today(), worddate.).;

%mend;

/* Example macro call */

%subset_MRs(
	out_prefix=inter.MRs_,
	start_date='01jul2019'd,
	end_date='21dec2023'd
);

/* End of subset_MRs macro */
