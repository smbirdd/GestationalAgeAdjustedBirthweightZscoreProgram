/*******************************************************************/
/*
/*  Program: Birthweight Program
/*  Purpose: The purpose of this program is to generate birthweight
/*      adjusted for GAB z-scores and percentiles using the Oken data
/*
/*******************************************************************/





/************************************************************************************/
/*
/*  Step 1) Generate the percentiles 
/*
/*
/************************************************************************************/
/* Include the macro needed to generate the Oken birthweight percentiles and z-scores */
%include "C:\path-to-macro-function\BirthweightMacro.sas";

/* Create a personal path to where the data folder system will be located at */
%let personal_path = path-to-data-folder;

/* Pre-Processing Step: Read in the dataset that you wish to perform calculations for */
proc import out=WORK.peids
  datafile = "&Personal_Path.\dataset-you-wish-to-read-in.sav"
  dbms = SAV replace;
run;


/******************************************************************************************************/
/*
/*  Macro: Oken_Percentiles
/*  Purpose: The purpose of this program is to generate percentiles and z-scores for birthweight data
/*      that is adjusted for gestational age at birth (GAB). 
/*  Inputs:     
/*          - dset:         The dataset that you wish to produce percentiles and z-scores for
/*          - sepVar:       The name of the variable that contains the sex information. Must be in the format
/*                              of 1 for males and 2 for females if specifying type = sex. Must be in the format
/*                              of 1 for firstborns and 2 for non-firstborns if specifying type = parity. Can be 
/*                              left as 0 if using type = all.
/*
/*          - gab:          The name of the variable containing the gestational age at birth for the baby.
/*          - birthweight:  The name of the variable containing the birthweight in grams for the baby at birth.
/*          - excel_path:   Path to the excel spreadsheet. Must be in the form of "C::User\path..." with no
/*                              backslash at the end of the string.
/*          - filename:     Name of Oken's excel sheet in your directory that includes the extension (.xlsx, .xls, etc)
/*          - outDset:  Desired name of output dataset        
/*          - type:         Desired percentiles to use. Should be one of either: "sex", "parity", or "all"
/*
/******************************************************************************************************/

%Oken_Percentiles(dset = /*INSERT NAME OF DSET TO BE CLEANED*/ , 
                    sepVar = /* INSERT NAME OF SEPARATOR VARIABLE */, 
                    gab = /* INSERT NAME OF VARIABLE CONTAINING GESTATIONAL AGE AT BIRTH IN DECIMAL FORM */, 
                    birthweight = /* INSERT NAME OF VARIABLE SPECIFYING BIRTHWEIGHT IN GRAMS */,
                    excel_path = /* INSERT ABSOLUTE PATH TO THE FOLDER CONTAINING THE OKENGROWTH02.XLSX FILE*/, 
                    filename = Oken_Growth02.xlsx /* LEAVE AS IS, THIS IS THE EXCEL FILE THAT CONTAINS OKEN'S CUTOFFS */,
                    outDset = /* INSERT DESIRED NAME OF THE OUTPUT DATASET */,
                    type = /* INSERT ONE OF: "SEX", "PARITY", "ALL", MAKE SURE NOT TO INCLUDE QUOTATIONS WITH THE ENTRY, JUST THE TEXT ITSELF */);






quit;
