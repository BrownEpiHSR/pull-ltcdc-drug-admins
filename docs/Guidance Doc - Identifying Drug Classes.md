# Identifying Drug Classes in the Medication Administrations

## Step 1: Query ChatGPT for all potential drug names

Because the LTCDC captures generic and brand name drugs in free text fields, you need to search those fields for every possible way a drug may be entered. The first step in doing this is identifying all the generic and brand names of drugs within your class of interest. AI tools such as ChatGPT can assist in generating such a table for your drug class of interest.

Copy and paste the following prompt into ChatGPT, filling in the drug class and years of interest:

---

Create tables with information about drugs in the **\[drug class\]** drug class that were on the market in the **United States from \[start year\]–\[end year\]**.

**Scope and inclusion rules**

* Include **all possible drugs** in the specified drug class that had at least one marketed product in the US during the specified years.  
* Exclude drugs that are not in the class, even if they are commonly confused with it.  
* Include both **generic and brand-name products**.  
* Include **combination products**.

**Combination product rule (important)**

* Whenever a combination product is listed, **always include the full list of active ingredients in parentheses after the product name**, in lower case (e.g., brandname (drug a \+ drug b)).

**Formatting requirements**

* Make **everything lower case**.  
* Be precise and consistent with naming.

**Table 1 — Wide format**

* One row per **generic name**  
* Columns:  
  * generic name  
  * brand names (including combination products)  
* List multiple brand names separated by semicolons.

**Table 2 — Long format**

* One row per **drug name** (both generic and brand names)  
* Columns:  
  * drug name  
  * generic name  
* Map all brand names and combination products to the corresponding generic.

**Output requirements**

* Deliver the results as an **Excel file**.  
* Put each table on a **separate worksheet**:  
  * wide\_format  
  * long\_format  
* Add a **title row** at the top of each worksheet that references:  
  * the drug class  
  * the US market  
  * the year range (e.g., “drugclass on the us market (\[start year\]–\[end year\]) – wide format”).

**Do not**

* Do not include explanatory text inside the tables.  
* Do not capitalize names.  
* Do not omit combination product components.

**Generate the Excel file and provide a download link.**

---

This should give you something that looks like this:
<img width="717" height="283" alt="Image" src="https://github.com/user-attachments/assets/f6c888f1-dd4f-437c-be60-2c06fbce5f09" />
<img width="532" height="728" alt="Image" src="https://github.com/user-attachments/assets/606d1c47-2072-45e8-83d4-5ee180cc4ad3" />

## Step 2: Review by clinical expert

Send the wide version of the table to a clinical expert on your team for review. Request that the reviewer(s) check if the list looks complete and if there are any drugs that should be added or removed. 

## Step 3: Clean up the drug tables

Now you want to clean up your long format drug list to only include the drug names that you will include in your search in the administrations data. The text that remains should be distilled down to its most basic form.

1. Implement changes based on feedback from Step 2

2. Remove unnecessary duplicates (for example: there is no need to search “luvox cr” when you are already searching “luvox”).

3. Remove any unnecessary text (e.g., the combination product symbyax may be listed as “symbyax (olanzapine \+ fluoxetine)” – you should remove the parenthetical.)

4. Deal with salt forms of the same drug

   * In a list of benzodiazepines, you may have both “clorazepate dipotassium” and “clorazepate” – searching for the substring “clorazepate” should capture both. Therefore you can eliminate the longer salt from the list.

<img width="1252" height="640" alt="Image" src="https://github.com/user-attachments/assets/99dd1edd-3fd2-4da1-958c-356b6eb1064e" />


## Step 4: Flag special cases

You will also want to flag any substrings that may **not be completely unique** for more careful handling. 

For example, searching for the substring “citalopram” with the index() function in SAS will return drug administrations for “citalopram.” However, it will also return drug administration for “escitalopram” which is a different drug. In these instances, you will need to use search functions that can properly distinguish these two words (e.g., prxmatch()). This kind of problem typically occurs within drugs of the same class, so you should review those drug names carefully. 

Why don’t we use prxmatch all the time? You certainly can\! In practice, the syntax for prxmatch doesn’t put the search term in quotation marks, making it harder to review and easier to incorporate typos. 

<img width="932" height="246" alt="Image" src="https://github.com/user-attachments/assets/17e44c0f-939b-4139-b47a-6b4cdc8786f9" />

**Very short brand names** are also worth flagging. For example, the muscle relaxant carisoprodol sometimes goes by the brand name “**soma**” which could easily be part of a longer drug name in an entirely different class. When a drug name is very short or non-distinct, it’s best to handle it with care. 

## Step 5: Import into the LTCDC project desktop

To import file into the enclave:

1. Open communications portal

2. Select project folder

3. Select To Project Desktop

4. Click on Files

5. Click on New Transfer

6. Upload your file and press submit

The imported file will be available at: Project desktop-\>Transfer Directory-\>To\_Project Desktop.
After importing the file into the enclave, copy and paste drug names into your code or import the table directly into SAS.

