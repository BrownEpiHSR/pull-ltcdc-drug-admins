# pull-ltcdc-drug-admins

## License and Citation Notice

This license is publicly available under a GPL-3.0 license.
If you use this code or documentation in your own research, please cite this resource as:

Reich, L., Puleo, J., D'Amico, A., Lo, D., Khan, M., & Zullo, A. (2026). LTCDC Medication Administration Guidance (Version 1.0.0). https://doi.org/10.5281/zenodo.20933081

## Purpose
This repository guides analysts through the Long-Term Care Data Cooperative (LTCDC) medication administration datasets. It serves as both an introductory guide or new users and a reference for establishing consistent analytic standards. Additionally, the repo houses a growing library of reusable code for isolating specific drug classes.

## How to Use
1. Review the following documents:
    * Introductory Material
       * [Data Overview: Working with the LTCDC Medication Administrations Dataset](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/00-data-overview.md)
    * Specific Topics
       * [Guidance Doc: On Completeness of the Medication Administrations](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/Guidance%20Doc%20-%20On%20Data%20Completeness.md)
       * [Guidance Doc: Identifying Drug Classes in the Medication Administrations](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/Guidance%20Doc%20-%20Identifying%20Drug%20Classes.md)
       * [Guidance Doc: Derive Numeric Dose Variable in the Medication Administrations](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/blob/main/docs/Guidance%20Doc%20-%20Derive%20Numeric%20Dose.md)

2. Review the code examples in the `code/` folder, which include:
   * Examples of subsetting medication administrations by medication drug classes (e.g., benzodiazepines, muscle relaxants, etc.)
   * Examples of restricting medication administrations by particular routes (e.g., oral, injection, rectal, etc.)
   * Example of flagging combination products

## Repository Structure

<pre>
docs/
├─ 00-data-overview.md                          # General guidance on working with the LTCDC medication administrations dataset
├─ Guidance Doc - On Data Completeness.md       # Overview of the completeness of the medication administration data (June 2025 data cut)
├─ Guidance Doc - Identifying Drug Classes.md   # Guidance on identifying drug classes in the medication administrations data
├─ Guidance Doc - Derive Numeric Dose.md        # Guidance on deriving numeric doses in the administration data
code/
├─ restrict_route/
  └─ restrict_by_route.sas               # Example code to reduce subsetted medication administrations to particular routes
  └─ chk_route_form_counter_cases.sas    # Example to check which medication forms map to specific medication routes
  └─ compare_OrdersAndAdmins.sas         # Example code to link gabapentin administrations to their associated orders via MEDICATION_ORDER_ID 
├─ subset_meds/
  └─ subset_SGLT2is_macro.sas                         # SAS program that subsets yearly drug admins to SGLT2 inhibitors
  └─ subset_SNRIs_macro.sas                           # SAS program that subsets yearly drug admins to SNRIs
  └─ subset_SSRIs_macro.sas                           # SAS program that subsets yearly drug admins to SSRIs
  └─ subset_antihypertensives_flag_class_combos.sas   # SAS program that subsets yearly drug admins to antihypertensives AND flags combination products
  └─ subset_benzos_macro.sas                          # SAS program that subsets yearly drug admins to benzodiazepines
  └─ subset_muscle_relaxants_macro.sas                # SAS program that subsets yearly drug admins to muscle relaxants
</pre>

## Last Major Update
2026-06-25

## Questions or Suggestions?

See the [CONTRIBUTING.md](https://github.com/BrownEpiHSR/pull-ltcdc-drug-admins/tree/main?tab=contributing-ov-file) file for instructions on how to ask questions, give suggestions, or provide feedback!



