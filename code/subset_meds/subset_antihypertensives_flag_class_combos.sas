/*****************************************************************************
PURPOSE: SAS program to pull antihypertensive drugs, create flags and 
assign  classes (including combination products) from LTCDC
medication administration records.  

INPUT DATASETS:
- Raw LTCDC 2017-2023 Medication Administration Datasets 
	(LTCDCALL.Medication_Admin_2017 - LTCDCALL.Medication_Admin_2023)
	- Note that this program assumes the raw medication administration
	  datasets are separated by year.

OUTPUT DATASETS:
- Shared.eMAR_HTN_Meds_17to23: Antihypertensive medication administration
  records from 2017 through 2023.
- Antihyp.eMAR_HTN_Meds_W_Flag: Antihypertensive medication administration
  records from 2017 through 2023 WITH flags for drug classes and 
  combination products.

*****************************************************************************/

/*Libraries*/

libname LTCDCALL "\\path\to\ltcdc\data";   /* LTCDC source data */
libname Shared   "\\path\to\your\folder";  /* Saves dataset with initial pull of antihypertensive drugs */
libname Antihyp  "\\path\to\your\folder";  /* Saves dataset with antihypertensive drugs that includes flags classes and combo products */

/*Pull antihypertensive medication claims from Medication_Admin from 2017 - 2023*/ 

/*Angiotensin-Converting Enzyme Inhibitors (ACEI)*/ 

%let acei_exact_rx_uncl = %str(  
 \bBENAZEPRIL\b|\bLOTENSIN\b|\bLOTREL\b|\bAMLOBENZ\b|  
 \bCAPTOPRIL\b|\bCAPOTEN\b|\bCAPOZIDE\b|  
 \bENALAPRIL\b|\bVASOTEC\b|\bEPANED\b|\bVASERETIC\b|  
 \bFOSINOPRIL\b|\bMONOPRIL\b|  
\bLISINOPRIL\b|\bZESTRIL\b|\bPRINIVIL\b|\bQBRELIS\b|\bZESTORETIC\b|\bPRINZIDE \b|  
 \bMOEXIPRIL\b|\bUNIVASC\b|\bUNIRETIC\b|  
 \bPERINDOPRIL\b|\bACEON\b|\bPRESTALIA\b|  
 \bQUINAPRIL\b|\bACCUPRIL\b|\bACCURETIC\b|\bQUINARETIC\b|   
 \bRAMIPRIL\b|\bALTACE\b|  
 \bTRANDOLAPRIL\b|\bMAVIK\b|\bTARKA\b  
); 

%let acei_exact_rx_clean = %str(  
 BENAZEPRIL|LOTENSIN|LOTREL|AMLOBENZ|  
 CAPTOPRIL|CAPOTEN|CAPOZIDE|  
 ENALAPRIL|VASOTEC|EPANED|VASERETIC|  
 FOSINOPRIL|MONOPRIL|  
 LISINOPRIL|ZESTRIL|PRINIVIL|QBRELIS|ZESTORETIC|PRINZIDE|   
 MOEXIPRIL|UNIVASC|UNIRETIC|  
 PERINDOPRIL|ACEON|PRESTALIA|  
 QUINAPRIL|ACCUPRIL|ACCURETIC|QUINARETIC|  
 RAMIPRIL|ALTACE|  
 TRANDOLAPRIL|MAVIK|TARKA  
); 

%let acei_wildcard_rx = %str(PRIL\b); 

/*Angiotensin Receptor Blockers (ARB)*/ 

%let arb_exact_rx_uncl = %str(  
 \bLOSARTAN\b|\bCOZAAR\b|\bHYZAAR\b|  
 \bVALSARTAN\b|\bDIOVAN\b|  
 \bIRBESARTAN\b|\bAVAPRO\b|\bAVALIDE\b|  
 \bCANDESARTAN\b|\bATACAND\b|  
 \bOLMESARTAN\b|\bBENICAR\b|\bTRIBENZOR\b|  
 \bTELMISARTAN\b|\bMICARDIS\b|\bTWYNSTA\b|  
 \bAZILSARTAN\b|\bEDARBI\b|\bEDARBYCLOR\b|  
 \bAZOR\b|\bEXFORGE\b  
); 

%let arb_exact_rx_clean = %str( 
 LOSARTAN|COZAAR|HYZAAR|  
 VALSARTAN|DIOVAN|  
 IRBESARTAN|AVAPRO|AVALIDE|  
 CANDESARTAN|ATACAND|  
 OLMESARTAN|BENICAR|TRIBENZOR|  
 TELMISARTAN|MICARDIS|TWYNSTA|  
 AZILSARTAN|EDARBI|EDARBYCLOR|  
 AZOR|EXFORGE  
); 

%let arb_wildcard_rx = %str(SARTAN\b); 

/*Dihydropyridine Calcium Channel Blockers (DHP CCB)*/ 

%let dhp_ccb_exact_rx_uncl = %str(  
 \bAMLODIPINE\b|\bNORVASC\b|\bKATERZIA\b|\bCADUET\b|  
 \bNIFEDIPINE\b|\bPROCARDIA\b|\bADALAT\b|  
 \bFELODIPINE\b|\bPLENDIL\b|  
 \bNICARDIPINE\b|\bISRADIPINE\b|\bNISOLDIPINE\b|\bSULAR\b  ); 

%let dhp_ccb_exact_rx_clean = %str(  
 AMLODIPINE|NORVASC|KATERZIA|CADUET|  
 NIFEDIPINE|PROCARDIA|ADALAT|  
 FELODIPINE|PLENDIL|  
 NICARDIPINE|ISRADIPINE|NISOLDIPINE|SULAR  
); 

%let dhp_ccb_wildcard_rx = %str(DIPINE\b); 

/*Non-Dihydropyridine Calcium Channel Blockers (NON-DHP CCB)*/ 

%let non_dhp_ccb_exact_rx_uncl = %str(  
 \bDILTIAZEM\b|\bCARDIZEM\b|\bCARTIA\b|\bTIAZAC\b|\bTAZTIA\b|   
 \bVERAPAMIL\b|\bCALAN\b|\bISOPTIN\b|\bVERELAN\b|\bCOVERA\b  ); 

%let non_dhp_ccb_exact_rx_clean = %str(  
 DILTIAZEM|CARDIZEM|CARTIA|TIAZAC|TAZTIA|  
 VERAPAMIL|CALAN|ISOPTIN|VERELAN|COVERA  
); 

%let non_dhp_ccb_wildcard_rx = %str(DILTIAZEM|VERAPAMIL); 

/*Thiazide Diuretics (THIAZIDE)*/ 

%let thiazide_exact_rx_uncl = %str(  
 \bHYDROCHLOROTHIAZIDE\b|\bHCT\b|\bHCTZ\b|\bMICROZIDE\b|\bHYDRODIURIL\b|   
 \bCHLORTHALIDONE\b|\bHYGROTON\b|\bTHALITONE\b|  
 \bINDAPAMIDE\b|\bLOZOL\b|  
 \bMETOLAZONE\b|\bZAROXOLYN\b|  
 \bDYAZIDE\b|\bMAXZIDE\b|\bMODURETIC\b  
);

%let thiazide_exact_rx_clean = %str(  
 HYDROCHLOROTHIAZIDE|HCT|HCTZ|MICROZIDE|HYDRODIURIL|   CHLORTHALIDONE|HYGROTON|THALITONE|  
 INDAPAMIDE|LOZOL|  
 METOLAZONE|ZAROXOLYN|  
 DYAZIDE|MAXZIDE|MODURETIC  
); 

%let thiazide_wildcard_rx = %str(THIAZ|HCT|ZIDE\b); 

/*Beta Blockers (BB)*/ 

%let bb_exact_rx_uncl = %str(  
 \bMETOPROLOL\b|\bTOPROL\b|\bKAPSPARGO\b|   \bATENOLOL\b|\bTENORMIN\b|  
 \bCARVEDILOL\b|\bCOREG\b|  
 \bLABETALOL\b|\bTRANDATE\b|  
 \bPROPRANOLOL\b|\bINDERAL\b|  
 \bBISOPROLOL\b|\bZEBETA\b|  
 \bNADOLOL\b|\bCORGARD\b|  
 \bNEBIVOLOL\b|\bBYSTOLIC\b  
); 

%let bb_exact_rx_clean = %str(  
 METOPROLOL|TOPROL|KAPSPARGO|  
 ATENOLOL|TENORMIN|  
 CARVEDILOL|COREG|  
 LABETALOL|TRANDATE|  
 PROPRANOLOL|INDERAL|  
 BISOPROLOL|ZEBETA|  
 NADOLOL|CORGARD|  
 NEBIVOLOL|BYSTOLIC  
); 

%let bb_wildcard_rx = %str(OLOL\b); 

/*Other - Not Loop Diuretics (OTHER NOTLOOP)*/ 

%let other_notloop_exact_rx_uncl = %str(   \bCLONIDINE\b|\bCATAPRES\b|  
 \bGUANFACINE\b|\bTENEX\b|  
 \bMETHYLDOPA\b|\bALDOMET\b|  
 \bHYDRALAZINE\b|\bAPRESOLINE\b|  
 \bMINOXIDIL\b|\bLONITEN\b|  
 \bSPIRONOLACTONE\b|\bALDACTONE\b|  
 \bEPLERENONE\b|\bINSPRA\b|  
 \bDOXAZOSIN\b|\bCARDURA\b|  
 \bTERAZOSIN\b|\bHYTRIN\b|  
 \bPRAZOSIN\b|\bMINIPRESS\b  
); 

%let other_notloop_exact_rx_clean = %str(   CLONIDINE|CATAPRES|  
 GUANFACINE|TENEX|  
 METHYLDOPA|ALDOMET| 
 HYDRALAZINE|APRESOLINE|  
 MINOXIDIL|LONITEN|  
 SPIRONOLACTONE|ALDACTONE|  
 EPLERENONE|INSPRA|  
 DOXAZOSIN|CARDURA|  
 TERAZOSIN|HYTRIN|  
 PRAZOSIN|MINIPRESS  
); 

%let other_notloop_wildcard_rx = %str(ZOSIN\b); 

/*Other - Loop Diuretics (OTHER LOOP)*/ 

%let other_loop_exact_rx_uncl = %str(  
 \bFUROSEMIDE\b|\bLASIX\b|  
 \bTORSEMIDE\b|\bDEMADEX\b|\bSOAANZ\b|  
 \bBUMETANIDE\b|\bBUMEX\b|  
 \bETHACRYNIC\b|\bEDECRIN\b  
); 

%let other_loop_exact_rx_clean = %str(  
 FUROSEMIDE|LASIX|  
 TORSEMIDE|DEMADEX|SOAANZ|  
 BUMETANIDE|BUMEX|  
 ETHACRYNIC|EDECRIN  
); 

%let other_loop_wildcard_rx = %str(SEMIDE\b); 

/*Combination Drugs (COMBINATION)*/ 

/*Note: This is only for eMAR pull. Creating the Combination class will be  
done later using another logic*/ 

%let combo_exact_rx_uncl = %str(  
 ZESTORETIC|PRINZIDE|ACCURETIC|CAPOZIDE|VASERETIC|UNIRETIC|LOTREL|AMLOBENZ|   
 TARKA|PRESTALIA|HYZAAR|AVALIDE|ATACANDHCT|BENICARHCT|MICARDISHCT|   
 DIOVANHCT|EDARBYCLOR|EXFORGE|AZOR|TWYNSTA|TRIBENZOR|EXFORGEHCT|   
 TENORETIC|ZIAC|LOPRESSORHCT|DUTOPROL|MODURETIC|DYAZIDE|MAXZIDE|ALDACTAZIDE  ); 

***************************************************************************** 
***************************************************************************** 
***************************************************************************** 
*********************************; 

/*eMAR Pull (2017 - 2023)*/ 

%let htn_pull_rx = %str(  
 (&acei_exact_rx_uncl.|&acei_wildcard_rx.) |  
 (&arb_exact_rx_uncl.|&arb_wildcard_rx.) |  
 (&dhp_ccb_exact_rx_uncl.|&dhp_ccb_wildcard_rx.) |  
 (&non_dhp_ccb_exact_rx_uncl.|&non_dhp_ccb_wildcard_rx.) | 
 (&thiazide_exact_rx_uncl.|&thiazide_wildcard_rx.) |  
 (&bb_exact_rx_uncl.|&bb_wildcard_rx.) |  
 (&other_notloop_exact_rx_uncl.|&other_notloop_wildcard_rx.) |   (&other_loop_exact_rx_uncl.|&other_loop_wildcard_rx.) |   (&combo_exact_rx_uncl.)  
); 

%macro eMAR_Annual_Updt (Year); 

	%local in_ds; 

	%let in_ds = LTCDCALL.Medication_Admin_&Year; 

	/*Make sure input exists*/ 
	%if %sysfunc(exist(&in_ds)) = 0 %then %do; 
	 %put ERROR: Input dataset &in_ds does not exist. Check the  library/name/year.; 
	 %return; 
	%end; 

	data Shared.eMAR_HTN_Meds_&Year; 
		 set &in_ds; 
		 length _name $800. _rx $32767.; 
		 retain _rxid; 
		  
		 _name = upcase(catx(' ',  
		 coalescec(MEDICATION_GENERIC_NAME,''),   coalescec(MEDICATION_NAME,''))); 
		  
		/*Build regex at runtime, NOT in macro quoting context*/ 
		 if _n_ = 1 then do; 
			 _rx = cats(  
				 '/(',  
				"&acei_exact_rx_uncl.|&acei_wildcard_rx.|",  
				"&arb_exact_rx_uncl.|&arb_wildcard_rx.|",  
				"&dhp_ccb_exact_rx_uncl.|&dhp_ccb_wildcard_rx.|",    
				"&non_dhp_ccb_exact_rx_uncl.|&non_dhp_ccb_wildcard_rx.|",   
		        "&thiazide_exact_rx_uncl.|&thiazide_wildcard_rx.|",  
		        "&bb_exact_rx_uncl.|&bb_wildcard_rx.|",  
				"&other_notloop_exact_rx_uncl.|&other_notloop_wildcard_rx.|",    
				"&other_loop_exact_rx_uncl.|&other_loop_wildcard_rx.|",  
				 "&combo_exact_rx_uncl.",  
				')/xi' 
			 ); 
			  
			 _rxid = prxparse(_rx); 

			 if missing(_rxid) or _rxid <= 0 then do;  putlog "ERROR: PRXPARSE failed for Year=&Year..";  putlog "ERROR: Regex used follows (may be long):";  putlog _rx;
			 	stop; 
			 end; 

		 end; 

		 /*Keep only matches*/  
		 if prxmatch(_rxid, _name) > 0; 

		 drop _name _rx _rxid ; 

	 run; 

%mend; 

%eMAR_Annual_Updt (2017); 
%eMAR_Annual_Updt (2018); 
%eMAR_Annual_Updt (2019); 
%eMAR_Annual_Updt (2020); 
%eMAR_Annual_Updt (2021); 
%eMAR_Annual_Updt (2022); 
%eMAR_Annual_Updt (2023); 

/*Concatenate 2017 - 2023 eMAR antihypertenive medication claims*/ 

data Shared.eMAR_HTN_Meds_17to23; 
	set Shared.eMAR_HTN_Meds_2017 Shared.eMAR_HTN_Meds_2018  
	Shared.eMAR_HTN_Meds_2019 Shared.eMAR_HTN_Meds_2020  
	Shared.eMAR_HTN_Meds_2021 Shared.eMAR_HTN_Meds_2022  
	Shared.eMAR_HTN_Meds_2023;  
run; 

/*Create new variables to fix medication name and date*/ 

data Shared.eMAR_HTN_Meds_17to23; 
	set Shared.eMAR_HTN_Meds_17to23; 
	length MEDICATION_NAME_CLEAN $244. MEDICATION_GENERIC_NAME_CLEAN $244.; 

	/*Clean and standardize medication names*/ 
	 MEDICATION_NAME_CLEAN = upcase(compress(MEDICATION_NAME,,'kdas'));  MEDICATION_GENERIC_NAME_CLEAN =  
	upcase(compress(MEDICATION_GENERIC_NAME,,'kdas')); 

	/*Create a new date variable in the appropriate SAS date format*/ 
	MEDICATION_EVENT_DATE_CLEAN = datepart(MEDICATION_EVENT_DATE); 

	format MEDICATION_EVENT_DATE_CLEAN date9.; 
run; 

***************************************************************************** 
***************************************************************************** 
***************************************************************************** 
*********************************;

data Antihyp.eMAR_HTN_Meds_W_Flag; 
	set Shared.eMAR_HTN_Meds_17to23; 
	length name $600. drug_class_list $400. drug_class $40. combo_label  $200.; 
	retain rx_acei rx_arb rx_dhp_ccb rx_non_dhp_ccb rx_thiazide rx_bb  rx_other_notloop rx_other_loop; 

	/*Combine cleaned generic + trade names into one searchable string*/ 
	 name = upcase(catx(' ',  
	 compress(MEDICATION_GENERIC_NAME_CLEAN,,'kdas'),   compress(MEDICATION_NAME_CLEAN,,'kdas'))); 

	if _n_ = 1 then do; 
		 rx_acei = prxparse(  
		 cats('/(', "&acei_exact_rx_clean.|&acei_wildcard_rx.",  ')/xi')  
		 ); 
		 rx_arb = prxparse(  
		 cats('/(', "&arb_exact_rx_clean.|&arb_wildcard_rx.",  ')/xi')  
		 ); 
		 rx_dhp_ccb = prxparse(  
		 cats('/(',  
		"&dhp_ccb_exact_rx_clean.|&dhp_ccb_wildcard_rx.", ')/xi')   ); 
		 rx_non_dhp_ccb = prxparse(  
		 cats('/(',  
		"&non_dhp_ccb_exact_rx_clean.|&non_dhp_ccb_wildcard_rx.", ')/xi')   ); 
		 rx_thiazide = prxparse(  
		 cats('/(',  
		"&thiazide_exact_rx_clean.|&thiazide_wildcard_rx.", ')/xi')   ); 
		 rx_bb = prxparse(  
		 cats('/(', "&bb_exact_rx_clean.|&bb_wildcard_rx.", ')/xi')   ); 
		 rx_other_notloop = prxparse(  
		 cats('/(',  
		"&other_notloop_exact_rx_clean.|&other_notloop_wildcard_rx.", ')/xi')   ); 
		 rx_other_loop = prxparse(  
		 cats('/(',  
		"&other_loop_exact_rx_clean.|&other_loop_wildcard_rx.", ')/xi')   ); 
	end;

	/*Initialize flags*/ 
	 acei_flag = 0; 
	 arb_flag = 0; 
	 dhp_ccb_flag = 0; 
	 non_dhp_ccb_flag = 0; 
	 thiazide_flag = 0; 
	 bb_flag = 0; 
	 other_notloop_flag = 0; 
	 other_loop_flag = 0; 
	 combination_flag = 0; 

	/*Class flags (explicit list + wildcard safety net)*/ 

	 if prxmatch(rx_acei, name) then acei_flag = 1; 
	 if prxmatch(rx_arb, name) then arb_flag = 1; 
	 if prxmatch(rx_dhp_ccb, name) then dhp_ccb_flag = 1; 
	 if prxmatch(rx_non_dhp_ccb, name) then non_dhp_ccb_flag = 1; 
	 if prxmatch(rx_thiazide, name) then thiazide_flag = 1;  
	 if prxmatch(rx_bb, name) then bb_flag = 1; 
	 if prxmatch(rx_other_notloop, name) then other_notloop_flag = 1;  
     if prxmatch(rx_other_loop, name) then other_loop_flag = 1; 

	/*Build list of component classes*/ 

	 drug_class_list = ""; 
	 if acei_flag then drug_class_list = catx("|", drug_class_list,  "ACEI"); 
	 if arb_flag then drug_class_list = catx("|", drug_class_list,  "ARB"); 
	 if dhp_ccb_flag then drug_class_list = catx("|", drug_class_list,  "DHP_CCB"); 
	 if non_dhp_ccb_flag then drug_class_list = catx("|", drug_class_list,  "NON_DHP_CCB"); 
	 if thiazide_flag then drug_class_list = catx("|", drug_class_list,  "THIAZIDE"); 
	 if bb_flag then drug_class_list = catx("|", drug_class_list,  "BB"); 
	 if other_notloop_flag then drug_class_list = catx("|", drug_class_list,  "OTHER_NOTLOOP"); 
	 if other_loop_flag then drug_class_list = catx("|", drug_class_list,  "OTHER_LOOP"); 

	/*Count classes (n_class)*/ 
	 n_class = countw(drug_class_list, '|', 'm'); 

	/*Combination flag + final drug_class */ 

	 if n_class >= 2 then do; 
		 combination_flag = 1; 
		 drug_class = "COMBINATION"; 
	 end; 

	 else do;
		 combination_flag = 0; 
		 drug_class = drug_class_list; 
	 end; 

	/*Combination label ordered consistently*/ 
	 combo_label = ""; 
	 if combination_flag then do; 
		 if acei_flag then combo_label = catx("+", combo_label, "ACEI");  if arb_flag then combo_label = catx("+", combo_label, "ARB");  if dhp_ccb_flag then combo_label = catx("+", combo_label,  "DHP_CCB"); 
		 if non_dhp_ccb_flag then combo_label = catx("+", combo_label,  "NON_DHP_CCB"); 
		 if thiazide_flag then combo_label = catx("+", combo_label,  "THIAZIDE"); 
		 if bb_flag then combo_label = catx("+", combo_label, "BB");  if other_notloop_flag then combo_label = catx("+", combo_label,  "OTHER_NOTLOOP"); 
		 if other_loop_flag then combo_label = catx("+", combo_label,  "OTHER_LOOP"); 
	 end; 

	drop rx_acei rx_arb rx_dhp_ccb rx_non_dhp_ccb rx_thiazide rx_bb  rx_other_notloop rx_other_loop; 

run;
