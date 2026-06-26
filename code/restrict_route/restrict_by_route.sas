/********************************************************************************************
PURPOSE: Restrict subsetted medication administrations to specific routes and review
         routes, including "Unknown" route, using PROC FREQs.

INPUT DATASETS:
&in_med_admin.: Medication administrations already subsetted to the drugs of interest and
                  stacked across years.

%RESTRICT_BY_ROUTE MACRO INPUTS:
- in_med_admin: The medication administrations dataset already subsetted to the drugs
                of interest and stacked across years.
- routes: The routes you'd like to restrict the administrations to. 
          Written as: ("Oral", "Gastric")
- out_med_admin: Subsetted medication administrations restricted to the 
                 routes of interest.
- xlsx_out: Path to the outputted Excel file.

OUTPUT DATASETS:
&out_med_admin.: Subsetted medication administrations restricted to the 
                 routes of interest.

OUTPUT EXCEL:
&xslx_out.: Excel spreadsheet where PROC FREQ medication_route results are
            exported to.

NOTE: This program assumes that the raw yearly medication administration datasets have
      already been subsetted to the medication names of interest and subsequently
      stacked across years.

*******************************************************************************************/

/* Library where your subsetted medication administration dataset lives */
libname med "your/path/here";

%macro restrict_by_route(
	in_med_admin=,
	routes=,
	out_med_admin=,
	xlsx_out=
);

	/********************************************************/
	/*** 1. Restrict medication routes in &in_med_admin.  ***/
	/********************************************************/

	data &out_med_admin.;
		set &in_med_admin.;

		if medication_route in &routes. ;

	run;

	/*************************************************************************************************/
	/*** 2. Export results and check medication forms for administrations with an "Unknown" route  ***/
	/*************************************************************************************************/

	ods excel file = "&xlsx_out." 
	          options(embedded_titles="yes" autofilter="yes" frozen_headers="yes");

	ods excel options(sheet_name="routes_before_restrict");

	title1 "Routes for subsetted medication administrations before restriction"
	title2 "Dataset: &in_med_admin.";
	proc freq data = &in_med_admin.;
		tables medication_route / list missing;
	run;

	ods excel options(sheet_name="routes_after_restrict");

	title1 "Routes for subsetted medication administrations after restriction"
	title2 "Dataset: &out_med_admin.";
	proc freq data = &out_med_admin.;
		tables medication_route / list missing;
	run;

	ods excel options(sheet_name="forms_with_unknown_route");

	title1 "medication_name*medication_generic_name*medication_form combinations with unknown route";
	title2 "Dataset: &out_med_admin.";
	proc freq data = &out_med_admin.;
		where medication_route = 'Unknown';
		tables medication_name*medication_generic_name*medication_form*medication_route / list missing;
	run;

	ods excel close;

%mend;

/* Example macro call */
%restrict_by_route(
	in_med_admin=med.subset_admin,                     /* Input dataset: subsetted medication administrations */
	routes=("Oral", "Gastric", "Unknown"),             /* Routes to restrict administrations to. Include "Unknown" for now to determine likely route */
	out_med_admin=med.subset_admin_route,              /* Output dataset: subsetted medication administrations restricted by route */
	xlsx_out=your\path\restricted_med_route.xlsx       /* Excel spreadsheet where PROC FREQ output is exported to */
);
