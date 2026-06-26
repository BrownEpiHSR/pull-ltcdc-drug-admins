# 💊 Data Overview: Working with the LTCDC Medication Administrations Dataset

## 🥅 Purpose

This document provides standardized guidance for working with the Long-Term Data Cooperative (LTCDC) medication administrations data. 
It is intended both as an introduction for analysts new to this dataset and as a reference for establishing consistent analytic practices across projects.

>You can find the LTCDC data dictionary [HERE](https://www.ltcdatacooperative.org/Researchers/pages/default.aspx) (under RESOURCES AND FILES), which provides detailed information on LTCDC datasets and their variables. This document is intended as a supplement to the data dictionary, capturing additional insights and practical considerations that analysts have identified while working with the medication administrations data.

---
# 🍱 Table of Contents

- [Background](#background)
- [Working with Large LTCDC Medication Administration Files](#working-with)
- [Key Variables and Known Data Nuances](#key-variables)
   - [Identifier Variables](#identifier-vars)
   - [Medication Name Fields](#medication-name-fields)
   - [Medication Event Date](#medication-event-date)
   - [Route and Form of Administration](#route-form)
   - [Dose, Strength, and Frequency](#dose-strength-frequency)

---

<a name="background"></a> 
## 🏞️ Background

### What Does the LTCDC Medication Administrations Dataset Capture?
The LTCDC medication administration records capture medications and treatments administered by facility staff or providers, including prescription and over-the-counter products.

### Advantages and Tradeoffs of the LTCDC Medication Administration Data
The LTCDC medication administrations dataset differs in important ways from Medicare Part D data. These differences introduce both analytic advantages and additional complexity.

#### Advantages
* **Observed medication use:**
  * Unlike Part D data, which reflects medication dispensings, medication administration records capture medications that were actually administered to residents.
* **Precise timing:**
  * Medication administrations are recorded with exact dates and times.
* **Inclusion of non-Part D medications:**
  * The dataset includes both prescription and over-the-counter medications and treatments, allowing for more comprehensive capture of medication use than Part D alone.
* **Facility-level administration context:**
  * Medication administrations can be directly linked to the specific facility where care was delivered.
 
#### Tradeoffs and Considerations
* **Reliance on free-text fields:**
  * Many key variables (e.g., medication name) are captured as free text rather than standardized codes. This introduces variability in naming conventions, abbreviations, and formatting, requiring additional cleaning.
* **Intepretation requires context:**
  * While administrations indicate that a medication was given, they may not fully capture clinical intent or duration in a standardized way.    

With these general advantages and considerations in mind, the sections below highlight key variables and known data nuances in the medication administrations data.

</details>

---

<a name="working-with"></a> 
## 🎪 Working with Large LTCDC Medication Administration Files

### 1. File Organization

In most of the LINKAGE Enclave workspaces, you'll see that the medication administrations dataset are partitioned by **calendar year**. 

In the June 2025 and later data cuts, there are separate files for 2018-2025. Medication administration records from pre-2018 are recorded in a file named `medication_admin_all_other_years.sas7bdat`. 

If you're working on a multi-year study, you will need to pull medications from each partitioned file and then combine. For a code example, see [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/code/subset_meds/subset_gabapentinoids_macro.sas).

### 2. Running Large Jobs Efficiently (Job Board Guidance)

The medication administration datasets contains millions (and sometimes billions) of records per year. Subsetting the raw files to the administrations of interest can take several days (e.g., 10-12 days, depending on complexity).

To improve performance and reduce the risk of interrupted runs, we recommend the following:
* **Submit programs to the job board** rather than running them in an interactive SAS session
  * Jobs submitted to the job board will continue running even if your SAS session closes or you log out of the Enclave.
* **Process each calendar year separately**
  * Instead of subsetting multiple years within a single program, create and submit separate programs for each yearly medication administration file. Running these jobs concurrently via the job board can substantially reduce total processing time. Once complete, the yearly outputs can be combined into a final analytic dataset.

### 3. Storage Management Best Practices

To minimize disk usage and avoid storage quota issues when running large jobs, we recommend the following best practices:
* Use `compress=binary` when saving permanent datasets, especially those with mostly numeric variables.
* Drop unnecessary variables as early as possible using `keep=` or `drop=` in data steps.
* Limit the use of variable labels and formats, and remove them when not needed.
* Avoid unnecessary sorting; if sorting is required, consider using `tagsort`.
* Use the WORK library for intermediate datasets whenever possible.
* Consider using the `PROC DATASETS` for dataset management to reduce unnecessary input/output operations.

### 4. Determining Which Yearly Files to Use

It is expected that more medication administrations will be observed in some years than in others. See [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/Guidance%20Doc%20-%20On%20Data%20Completeness.md) for guidance and further commentary on data completeness across years.

---

<a name="key-variables"></a> 
## 💻 Key Variables and Known Data Nuances

<a name="identifier-vars"></a> 
### 1. Identifier Variables

There are several identifier fields in the medication administrations file. See the table below for some key identifier descriptions and potential uses:

| Variable Name | Description | Potential Uses / Considerations |
|---|---| ---|
|`MASTER_PATIENT_ID`|Uniform patient identifier that allows researchers to link LTCDC records across domains and years of data beginning with the release of the April 2025 LTCDC Core Data Model (CDM).|Primary identifier for linking to any other LTCDC dataset. Recommended for all patient-level analyses.|
|`MEDICATION_ID`|Unique medication record identifier. It serves as the primary key for the medication administrations dataset.|Useful for uniquely identifying individual administration records. Not intended for linking across datasets. <br> <br> This variable is not generally used for analysis.|
|`MEDICATION_ORDER_ID`|Unique identifier for the corresponding medication order associated with the medication administration record.|Can be used to link to the `medication_orders` dataset and to group multiple administrations belonging to the same order. Approximately 7.7% missing in the September 25, 2025 data cut.|
|`EPISODE_ID`|Episode identifier that is associated with the medication administration record.|Useful for restricting analyses to a specific episode of care within a facility. Note that there is a small amount of missingness in this variable in some data cuts (e.g., the September 25, 2025 data cut). Can be linked to the `episode` file or other datasets where `EPISODE_ID` is present.|
|`FACILITY_ID`|Unique identifier associated with the facility where the resident resides. This identifier is consistent across domains within a data cut but NOT consistent between cuts of data.|Useful for facility-level analyses or restricting to specific facilities. Can be used to link to the `facility` file and other datasets within the same data cut.|
|`MEDICATION_EVENT_PROVIDER_ID`|Unique identifier of the provider who administered the medication.| At present, it is unclear whether this identifier can be reliably linked to `PROVIDER_ID` in the provider dataset; analysts should use caution when attempting provider-level analyses using this field. Approximately 68.7% missing in the September 25, 2025 data cut. <br> <br> This variable is generally not used for analysis.|

<a name="medication-name-fields"></a> 
### 2. Medication Name Fields

There are two medication name fields analysts should jointly use when identifying medications administered to residents:

| Variable Name | Description | Potential Uses / Considerations |
|---|---| ---|
|`MEDICATION_NAME`|Medication Name (Brand or Generic)|Free text field. May contain brand names, abbreviations, or other non-standard formatting. Approximately 5.5% missing in the September 25, 2025 data cut|
|`MEDICATION_GENERIC_NAME`|Medication Name (Generic)|Free text field. Despite the variable name, this field may contain brand names or other non-generic text. Approximately 5.5% missing in the September 25, 2025 data cut|

#### Analytic Guidance and Considerations
* **Search across both fields:**
  * When identifying administrations of a specific medication, analysts should search across both `MEDICATION_NAME` and `MEDICATION_GENERIC_NAME`. Relevant medication information may appear in either field.
* **Handle missing medication names:**
  * Administrations where *both* `MEDICATION_NAME` and `MEDICATION_GENERIC_NAME` are missing should generally be excluded from medication-specific analyses.
* **Expect free-text variability:**
  * Because both fields are free text, medication names may include abbreviations, inconsistent capitalization, or misspellings. Analysts should plan for this variability when constructing medication search logic.
* **Misspelled medication names:**
  * Decisions about handling misspelled medication names should be made in consultation with the study PI. Misspelled medication names have typically been excluded in prior analyses.
* **Combination products and compounded formulations**
  * The medication administrations dataset does not provide indicators for **combination products** or **compounded formulations.**
    * **Combination products** are FDA-approved, mass-manufactured, and blend drugs.
      * **Examples:** `lisinopril/hydrochlorothiazide`, `amlodipine/valsartan`, and `trandolapril/verapamil`
      * Flagging combination products involves manual review and guidance from clinicians / the study PI.
      * For a code example that flags specific combination products, see [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/code/subset_meds/subset_antihypertensives_flag_class_combos.sas). 
    * **Compounded formulations** are customized, non-FDA-approved mixtures created by pharmacists for specific patients.
      * **Examples of compounded formulations with gabapentin found under `MEDICATION_NAME`**: `"Baclofen-Lidocaine-Gabapentin compound cream"` & `"Diclofenac Sodium 3%/Gabapentin 10% in Lidoderm topical CMPD"`
      * Flagging compounded formulations also involves manual review and guidance from clinicians / the study PI. Depending on the study, the team may decide to remove compounded formulations from the administrations of interest. 
* **Medication classes**
  * The medication administrations dataset does not provide variables that list a given medication's drug class. Flagging drug classes involves manual review and guidance from clinicians / the study PI.
  * For examples of code that identify specific drug classes, see [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/tree/main/code/subset_meds). 
* **Manual review:**
  * It's recommended to manually review the administrations you pull.
    * For example, you can output a `PROC FREQ` of `MEDICATION_NAME * MEDICATION_GENERIC_NAME` to ensure you are capturing the intended medications:

     ```sas
     proc freq data = subsetted_meds;
      tables MEDICATION_GENERIC_NAME*MEDICATION_NAME / list missing out = out_drug_freq;
     run;
     ```
    
* **Code examples:**
  * There are several functions you can use to identify medications based on string matching. Each function has different strengths and limitations, and the appropriate choice depends on the analytic context:
    * `index()`:
      * Searches for exact, literal string matches
      * Case-sensitive by default. To perform a case-insensitive search, wrap the variable in `lowcase()`
      * Returns `0` if the substring is not found
      * SAS code example:

      ```sas
      /* Using the index function to identify desvenlafaxine (generic and brand names) */
      if index(lowcase(medication_generic_name), "desvenlafaxine")>0 or
         index(lowcase(medication_generic_name), "khedezla")>0 or
      	  index(lowcase(medication_generic_name), "pristiq")>0 or
      	  index(lowcase(medication_name), "desvenlafaxine")>0 or
      	  index(lowcase(medication_name), "khedezla")>0 or
      	  index(lowcase(medication_name), "pristiq")>0
      then SNRI_desve=1; else SNRI_desve=0;
      ```
    * `find()`:
      * Searches for exact, literal string matches
      * Can perform case-insensitive searches using the `i` argument
      * Returns `0` if the substring is not found
      * SAS code example:

      ```sas
      /* Using the find function to find bexagliflozin (generic and brand names) */
      where 
        &start_date <= datepart(medication_event_date) <= &end_date and
        (
         /* bexagliflozin generic & brand names
            - this medication has no combination drugs as of time of this script's creation */
         find(medication_generic_name, 'bexagliflozin', 'i') or
         find(medication_name, 'bexagliflozin', 'i') or
         find(medication_generic_name, 'brenzavvy', 'i') or
         find(medication_name, 'brenzavvy', 'i')
        );
      ``` 

    * `prxmatch()`:
      * Searches a character string for a specified pattern
      * Returns `0` if match is not found
      * Most flexible of the functions listed here
      * Particularly useful for avoiding unintended substring matches (e.g., matching `"morphine"` with `"apomorphine"`, which are distinct medications)
      * SAS code example:
      
      ```sas
      prxmatch('/(?i)\bonfi\b/i', MEDICATION_GENERIC_NAME)
      ```
     
     In this example:
      * `prxmatch()` identifies the word `"onfi"`
      * `(?i)` is an embedded modifier flag that makes the match case-insensitive
      * `\b` represents a word boundary, ensuring that `"onfi"`is matched as a complete, standalone word and not as part of a larger string. 
         
  * Examples by drug class:
     * For examples of code that identify specific drug classes, see [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/tree/main/code/subset_meds)



<a name="medication-event-date"></a> 
### 3. Medication Event Date

The medication administration dataset has one variable that defines the timing of administration:

| Variable Name | Description | Potential Uses / Considerations |
|---|---| ---|
|`MEDICATION_EVENT_DATE`|Date and time of the medication administration.|Stored in DATETIME21.2 format, providing timing of administration down to the second (with two decimal places). Enables fine-grained temporal analyses when needed.|

#### Analytic Guidance and Considerations
For many studies, it is not useful to retain the exact time of medication administration. In these cases, `MEDICATION_EVENT_DATE` can be used to derive a date-only variable representing the calendar date of administration. This approach is useful when aggregating administrations by day.

**Example: Create a Date-Only Variable (SAS)**
 ```sas
 MEDICATION_EVENT_DATE_ONLY = datepart(MEDICATION_EVENT_DATE);
 format MEDICATION_EVENT_DATE_ONLY date9.;
 ```

 For other studies, analysts may wish to categorize medication administrations by **time of day** (e.g., morning vs. afternoon) rather than using the exact timestamp. These time-of-day cut points should be defined based on study aims.

 **Example: Create Morning vs. Afternoon Indicator (SAS)**
 ```sas
 length time_of_day $9;
  
 hour_admin = hour(MEDICATION_EVENT_DATE);

 if 0 <= hour_admin < 12 then time_of_day = "Morning";
 else if 12 <= hour_admin < 24 then time_of_day = "Afternoon";
```
<a name="route-form"></a> 
### 4. Route and Form of Administration

There are two variables that define the route and form of the medication:

| Variable Name | Description | Potential Uses / Considerations |
|---|---| ---|
|`MEDICATION_ROUTE`|The method by which the medication was administered.|Structured (non-free-text) field with generally standardized values (e.g., `"Oral"`, `"Injection"`, `"Rectal"`).|
|`MEDICATION_FORM`|The formulation of the medication administered.|Free-text field with substantial variability (e.g., `"capsule"`, `"kit, cream and capsule"`, `"solution"`, `"liquid"`). May be useful for refining route information in certain cases. Approximately 5.5% missing in the September 25, 2025 data cut.|

#### Analytic Guidance and Considerations
* **Restricting by Route**
  * In some studies, analysts may wish to restrict analyses to medications administered via specific routes (e.g, oral only).
  * Decisions about which routes to include should be guided by study aims and, when appropriate, informed by consultation with clinicians or the study PI.
 
You can check the routes of administration for your subsetted administrations dataset using a simple `PROC FREQ`:
```sas
proc freq data = subsetted_drug_admins;
 tables MEDICATION_ROUTE / list missing out = subset_med_routes;
run;
```
* **Handling Unknown Routes**
  * Some medication administration records have a route listed as `"Unknown"`.
  * In certain cases, it may be reasonable to infer or retain these records based on information in `MEDICATION_FORM`.
    * For example, if restricting to oral or gastric administrations of gabapentin, records with an `"Unknown"` route but a medication form of `"Capsule"`, `"Tablet"`, or `"Solution"` may reasonably be retained. It is advised to examine counter-cases and share with your study PI before inferring the unknown medication route based on the documented medication form.
* **Code Examples**
  * See code example to restrict medication route and check the documented medication form of unknown routes [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/code/restrict_route/restrict_by_route.sas).
  * See code example to examine counter-cases when attempting to infer unknown medication route [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/code/restrict_route/chk_route_form_counter_cases.sas).

<a name="dose-strength-frequency"></a> 
### 5. Dose, Strength, and Frequency

There are several variables related to the medication dose, strength, and frequency. While these fields may be useful for certain research questions, they are often challenging to use due to inconsistent formatting and reliance on free-text entries.

| Variable Name | Description | Potential Uses / Considerations |
|---|---| ---|
|`MEDICATION_DOSE`|The dose (amount) of medication administered.|Free-text field with substantial variability. Multiple values often have the same meaning (e.g., `"1 tablet"`, `"1 tab"`, `"(1) tablet"`), requiring normalization before use.|
|`MEDICATION_STRENGTH`|The strength of the medication used for the administration.|Free-text field with substantial variability. Multiple values have the same meaning (e.g., `"100"`, `"100 MG"`, `"100 mg"`). ~5.5% missing in the September 25, 2025 data cut.|
|`MEDICATION_FREQUENCY`|A description of the frequency with which the medication should be administered.|Free-text field with substantial variability. This variable reflects intended frequency rather than observed administrations (e.g., `"Give twice a day"`, `"Every 8 hours"`, etc.). Approximately 5.5% missing in the September 25, 2025 data cut.|

#### Analytic Guidance and Considerations
* **Free Text Fields:**
  * Deriving standardized, numeric dose or strength variables from these fields typically requires substantial preprocessing, including text parsing, unit standardization, and manual review of edge cases.
* **Prior experience:**
  * In prior work, numeric dose variables (such as mg per dose, number of doses, or total daily mg) were derived through a combination of programmatic parsing and manual review.
  * This process has involved:
    * Generating frequency tables (e.g, `PROC FREQ`) for combinations of `MEDICATION_STRENGTH` and `MEDICATION_DOSE`
    * Programmatically deriving numeric values where possible (with the help of ChatGPT)
    * Manually reviewing and resolving unsuccessful or ambiguous cases
    * Merging derived variables back into the medication administrations dataset
  * See additional guidance for deriving numeric doses [HERE](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/Guidance%20Doc%20-%20Derive%20Numeric%20Dose.md). 

