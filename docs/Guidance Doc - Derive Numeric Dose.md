# Derive Numeric Dose Variable in the Medication Administrations

# PURPOSE:

This document provides guidance for deriving a numeric variable which contains the dose administered per the
LTCDC medication administrations data. The information required to derive a numeric dose variable are contained
in the MEDICATION_STRENGTH and MEDICATION_DOSE variables. These variables contain text fields which are not entered
in a neat and standardized fashion, making them messy and difficult to process. This document aims to provide some
structure and clarity on how best to approach these challenging data fields.

Note: Example code snippets are based on derivations for oral gabapentin.

# STEP 1

Subset the medication administration records to the medication of interest for your study.
Examples [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/tree/main/code/subset_meds).

In the example code snippet below, this dataset is called "d_gab_byAdmin_PreDose0".

# STEP 2
 
Wherever possible, programatically derive a numeric dose variable based on unique combinations of MEDICATION_STRENGTH and MEDICATION_DOSE.

## 2a)
Define LINKVAR which will be used to merge the data back in later. LINKVAR is an identifier for
each unique combination of MEDICATION_STRENGTH and MEDICATION_DOSE. The reason for creating this 
is that when we export the unique combinations to an excel spreadsheet later, some values of 
MEDICATION_STRENGTH and MEDICATION_DOSE get reformatted, making it difficult to merge back into 
the administrations dataset later. This step eliminates that issue because LINKVAR only takes
integer values, which don't get reformatted. In the code snippet below, two output datasets are 
created, both of which contain the variable LINKVAR.

```sas
/* Extract the unique combinations of MEDICATION_STRENGTH and MEDICATION_DOSE and place them in a separate dataset. */
proc sort data=d_gab_byAdmin_PreDose0 out=d_admin_DoseCombos0 nodupkey; by MEDICATION_STRENGTH MEDICATION_DOSE; run;

/* Define LINKVAR for the unique combinations */
data dsets.d_admin_DoseCombos;
set d_admin_DoseCombos0;
LINKVAR = _N_;

/* RECOMMENDATION: remove any leading and trailing spaces, and create a lower-case 
version of the MEDICATION_STRENGTH and MEDICATION_DOSE for easier processing. */
m_dose = strip(lowcase(MEDICATION_DOSE));
m_strength = strip(lowcase(MEDICATION_STRENGTH));

run;

/* Merge LINKVAR back into the administrations */
proc sql;
create table dsets.d_gab_byAdmin_PreDose as
select a.*, b.LINKVAR
from d_gab_byAdmin_PreDose0 as a
left join dsets.d_admin_DoseCombos as b
on a.MEDICATION_STRENGTH = b.MEDICATION_STRENGTH
and a.MEDICATION_DOSE = b.MEDICATION_DOSE;
quit;
```

## 2b)
This is the difficult part. Programatically derive numeric dose wherever possible. The m_strength and m_dose variables 
contain text strings that can be very difficult to process, and there are many different text patterns to interpret. Henceforth, these 
text patterns are referred to as "derivation patterns". 

NOTE: Derivation patterns are not pre-defined. Below are a couple of examples of derivation patterns you may encounter and suggestions 
for how to generate code for processing them using ChatGPT. 

For example, one derivation pattern may look like this:
```
m_strength		m_dose
300 mg			1 po
300 mg			1 po tid
300 mg			1 po tid
300 mg			2 po
300 mg			1 po tid
600 mg			1 po daily
```
Deriving a numeric dose variable for this pattern involves extracting the number of milligrams administered from the m_strength variable 
where the number of milligrams is clearly stated and followed by a space and then the unit "mg"; and where the m_dose gives the number of 
doses given followed by "po" (i.e., orally). For this derivation pattern, we would want to generate SAS or R code which extracts the 300 or 600 from 
m_strength in the example below and puts it into a separate numeric variable, and extracts the 1 or 2 from m_dose and places 
that into another numeric variable. You would ideally produce this:
```
m_strength		m_dose			mg_per_dose	number_of_doses
300 mg			1 po			300			1
300 mg			1 po tid		300			1
300 mg			1 po tid		300			1
300 mg			2 po			300			2
300 mg			1 po tid		300			1
600 mg			1 po daily		600			1
```
If using ChatGPT to generate code to achieve this, a prompt may look something like:
"I have a SAS dataset with a variable called m_strength and a variable called m_dose. m_strength contains the number of milligrams administered 
for a medication, and m_dose contains the number of doses (i.e., capsules or tablets) given. Generate SAS code that will check m_strength for 
cases where a number precedes "mg", and place that number into a numeric variable called mg_per_dose. Also, check m_dose for cases where a number 
precedes "po" and place that number into a numeric variable called number_of_doses. For example, if m_strength = "600 mg" then mg_per_dose should 
equal 600, and if m_dose = "1 po daily" then number_of_doses should equal 1."

ChatGPT will give you some code such as pasted below. Paste it into your SAS program and run (or modify as needed). When the derivations are completed 
for this derivation pattern, output those records to separate dataset (see last two lines in the pasted code below) and then give a new prompt for the 
next derivation pattern. 
```sas
data dose_not_yet_derived dose_derived;
    set dsets.d_admin_DoseCombos;

    length mg_per_dose number_of_doses 8;

    /* Initialize */
    mg_per_dose = .;
    number_of_doses = .;

    /* Extract number before 'mg' */
    if prxmatch('/\b(\d+)\s*mg\b/i', m_strength) then do;
        mg_per_dose = input(prxchange('s/.*\b(\d+)\s*mg\b.*/\1/i', -1, m_strength), 8.);
    end;

    /* Extract number before 'po' */
    if prxmatch('/\b(\d+)\s*po\b/i', m_dose) then do;
        number_of_doses = input(prxchange('s/.*\b(\d+)\s*po\b.*/\1/i', -1, m_dose), 8.);
    end;

    /* Output rows with newly derived variables to a separate dataset. */
    if not missing(mg_per_dose) and not missing(number_of_doses) then output dose_derived_pattern_1;
    else 							      output dose_not_yet_derived;

run;
```
Another derivation pattern may look like this: 
```
m_strength		m_dose
300 mg			cap 1
300 mg			cap 2
300 mg			tab 1
100 mg			cap 1
100 mg			cap 2
600 mg			tab 2
75 mg			cap 1
```
Deriving a numeric dose variable for this pattern involves extracting the number of milligrams administered from the m_strength variable just as for
the first pattern. However, the m_dose gives the number of doses administered after "cap", "capsule", "tab", or "tablet". For this derivation pattern,
we would want to generate SAS or R code which extracts the 300 or 600 from m_strength and puts it into a separate numeric variable (same as the 
first pattern), and extracts the 1 or 2 from m_dose and places that into another numeric variable. The result would look like this:
```
m_strength		m_dose		mg_per_dose	number_of_doses
300 mg			cap 1		300			1
300 mg			cap 2		300			2
300 mg			tab 1		300			1
100 mg			cap 1		100			1
100 mg			cap 2		100			2
600 mg			tab 2		600			2
75 mg			cap 1		75			1
```
If using ChatGPT to generate code to achieve this, a prompt may look something like:
"I have a SAS dataset with a variable called m_strength and a variable called m_dose. m_strength contains the number of milligrams administered 
for a medication, and m_dose contains the number of doses (i.e., capsules or tablets) given. Generate SAS code that will check m_strength for 
cases where a number precedes "mg", and place that number into a numeric variable called mg_per_dose. Also, check m_dose for cases where a number 
immediately follows "cap", "capsule", "tab", or "tablet" and place that number into number_of_doses. For example, if m_strength = "600 mg" then 
mg_per_dose should equal 600, and if m_dose = "cap 2" then number_of_doses should equal 2."

As before, this will produce SAS (or R) code that you can paste into your program and run. Output the rows with newly derived variables into a separate
dataset and continue this process for the unprocessed rows of data.

NOTE: The purpose for separating by derivation pattern is so that they can each be displayed separately in an excel spreadsheet later for review. 
This will make it easier for the study PIs to review these derivations and give feedback. It also makes it easier for ChatGPT to generate code that 
only handles a specific pattern at a time, rather than trying to handle many derivation patterns at once. The derivations and corresponding prompts can 
become very complicated, so ChatGPT tends to generate more reliable code by giving prompts one derivation pattern at a time.

When you have finished deriving mg_per_dose and number_of_doses for as many m_strength and m_dose combinations as possible, put the underived edge cases 
into their own derivation pattern. Set all the derivation pattern datasets (derived and underived) together into one final dataset and calculate total_mg 
as mg_per_dose*number_of_doses.

At the end of this process, you should have a dataset where:
	i)   every row contains a unique combination of m_strength and m_dose
	ii)  every row contains a unique value of LINKVAR
	iii) there is a column for pattern (representing derivation pattern)
	iv)  there is a column for mg_per_dose (if "mg" is appropriate the medication of interest)
	v)   there is a column for number_of_doses (this might be the number of capsules or tablets)
	vi)  there is a column for total_mg (if "mg" is appropriate for the medication of interest; this would be equal to mg_per_dose times the number_of_doses)

## 2c)
Print the dataset in an excel document where each derivation pattern is printed on its own sheet for sharing with study PIs and clinicians. This is optional, 
but may be helpful for their review.

Also print the dataset in an excel document where the whole dataset is on one sheet. This will be the versions used to enter the manual derivations.

Below is a snippet of code for this. In this example, the dataset derived above is called d_dose and is in the intermediate library.

```sas
/* Output to excel spreadsheet with separate sheets for each pattern */

/* 0: Sort by pattern (i.e., the by-variable) */
proc sort data=inter.d_dose out=d_dose; by pattern; run;

/* 1: Extract distinct numeric values of pattern into a macro variable */
proc sql noprint;
    select distinct pattern into :pattern_list separated by ' ' 
    from d_dose
    order by pattern;
quit;

/* 2: Open Excel file */
ods excel file="<output_location>\admins_DoseVarPartiallyDerivedByPattern.xlsx" style=pearl;

/* 3: Macro to loop over pattern values */
%macro freq_by_pattern;

  %local i pattern_val;
  %let i = 1;
  %let pattern_val = %scan(&pattern_list, &i); 

  %do %while(%length(&pattern_val) > 0);

    /* Sheet name: pattern 1, pattern 2, etc. */
    ods excel options(sheet_name="Pattern &pattern_val" embedded_titles="no");

    proc freq data=d_dose order=freq;
      where pattern = &pattern_val;
      tables linkvar * medication_strength * medication_dose * mg_per_dose * number_of_doses * total_mg / list missing nocum;
    run;

    %let i = %eval(&i + 1);
    %let pattern_val = %scan(&pattern_list, &i);

  %end;

%mend;

%freq_by_pattern;

/* 4: Close the Excel file */
ods excel close;

/* 5: Create one excel document not separated by sheets. */
ods excel file="<output_location>\admins_DoseVarPartiallyDerivedOneList.xlsx" style=pearl;
options(embedded_titles='no");
proc freq data=d_dose order=freq;
      tables linkvar * medication_strength * medication_dose * mg_per_dose * number_of_doses * total_mg * pattern / list missing nofreq nopercent nocum;
    run;
ods excel close;
```

# STEP 3: Manual review.

Export the spreadsheet from the Enclave. 

Share with study PIs and clinicians for review of derived variables by pattern.

Ask study PIs and clinicians to review derivation patterns with rows where the numeric dose could not be programatically derived and manually enter the dose where possible.
It is recommended to do this step on the version of the excel file where the derivation patterns are not separated by sheets. That way, it will be ready for upload back into SAS.
You can also do this on the version where the derivation patterns are separated by sheets, but you will have to take the extra step of combining all the separate sheets into one.
Either way, the idea is to take the programmatically derived (and reviewed) doses as well as the manually entered doses that are in the excel spreadsheet and load 
them back into SAS (or R) as a dataset to merge back with the administrations.

# STEP 4: Merge derived dose information back into the administrations.

Import the spreadsheet with the manually derived dose to the Enclave and load the spreadsheet as a SAS dataset.

```sas
/* Load the newly derived dose data. */
proc import datafile="<your_documents>\admins_DoseVarDerivedAll.xlsx"
    out=d_DoseCombosDerived
    dbms=xlsx
    replace;
    getnames=yes;
run;
```

Sort the administrations dataset and the derived dose dataset by LINKVAR and merge. After this step, you should have the your original by-administration dataset with your newly derived numeric dose variable included.

```sas
proc sort data= dsets.d_gab_byAdmin_PreDose out=d_gab_byAdmin_PreDose_sorted; by LINKVAR; run;
proc sort data= d_DoseCombosDerived out=d_DoseCombosDerived_sorted; by LINKVAR; run;

/* Merge derived numeric dose into the administrations data. */
data dsets.d_gab_byAdmin;
merge d_gab_byAdmin_PreDose_sorted(in=ina)
	d_DoseCombosDerived_sorted(keep= LINKVAR total_mg number_of_doses mg_per_dose  
			rename=(total_mg=total_mg0 number_of_doses=number_of_doses0 mg_per_dose=mg_per_dose0));
by LINKVAR;
if ina;

/* Make numeric versions of total_mg, number_of_doses, and mg_per_dose. */
total_mg 		= input(total_mg0, best9.);
number_of_doses = input(number_of_doses0, best9.);
mg_per_dose 	= input(mg_per_dose0, best9.);

if missing(total_mg) then MISS = "Y";
else 					  MISS = "N";
run;
```
