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
%macro Oken_Percentiles(dset, sepVar, gab, birthweight, excel_path, filename, outdset, type);

    %if &type = sex %then %do;

        /* Pre-Processing Step: Read in the Oken data */
        proc import datafile = "&excel_path.\&filename"
                out = oken_males replace; 
                getnames = YES;
                sheet = "Males";
        run;
        proc import datafile = "&excel_path.\&filename"
                out = oken_females replace; 
                getnames = YES;
                sheet = "Females";
        run;
        proc import datafile = "&excel_path.\&filename"
                out = zscore_data replace; 
                getnames = YES;
                sheet = "zscore";
        run;

        /* Step 1: Transpose the datasets so we have them in wide format for merging to the dataset */
        proc transpose data=Oken_males out=TransposedMales(drop = _LABEL_) prefix = percentile;
        run;
        proc transpose data=Oken_females out=TransposedFemales(drop = _LABEL_) prefix = percentile;
        run;
        proc transpose data=Zscore_data out=TransposedZscores(drop = _LABEL_) prefix = percentile;
        run;

        /* Step 2: Reformat the transposed datasets */
        data growth_males(drop = _NAME_);
            retain gab_rounded;
            set TransposedMales;
            if _N_ eq 1 then delete;
            gab_rounded = input(scan(_NAME_, 2, "_"), 8.);
        run;
        data growth_females(drop = _NAME_);
            retain gab_rounded;
            set TransposedFemales;
            if _N_ eq 1 then delete;
            gab_rounded = input(scan(_NAME_, 2, "_"), 8.);
        run;


        /* Step 1: Prep the dataset for merging */
        data &dset.2;
            set &dset;
            gab_rounded = floor(&gab);
        run;

        /* Step 2: Merge the Cares dataset to the growth chart data */
        proc sort data = &dset.2; by gab_rounded; run; /* Sort the cares data by GAB*/
        proc sort data=growth_females; by gab_rounded; run; /* sort the growth data by GAB*/
        proc sort data=growth_males; by gab_rounded; run; /* Sort the growth data by GAB*/
        /* Merge the female data with the growth chart */
        data female_obs;
            merge &dset.2(where = (&sepVar = 2) in = A) growth_females(in = B);
            by gab_rounded;
            if A;
        run;
        /* Merge the male data with the growth chart */
        data male_obs;
            merge &dset.2(where = (&sepVar = 1) in = A) growth_males(in = B);
            by gab_rounded;
            if A;
        run;
        /* Create a combined dataset that includes all female and male observations*/
        data cares_concat;
            set female_obs male_obs;
        run;
    %end;
        %else %if &type = parity %then %do;

            /* Pre-Processing Step: Read in the Oken data */
            proc import datafile = "&excel_path.\&filename"
                    out = oken_firstborn replace dbms =xlsx; 
                    getnames = YES;
                    sheet = "Firstborn";
            run;
            proc import datafile = "&excel_path.\&filename"
                    out = oken_notfirstborn replace; 
                    getnames = YES;
                    sheet = "NonFirstborn";
            run;
            proc import datafile = "&excel_path.\&filename"
                    out = zscore_data replace; 
                    getnames = YES;
                    sheet = "zscore";
            run;

            /* Step 1: Transpose the datasets so we have them in wide format for merging to the dataset */
            proc transpose data=oken_notfirstborn out=TransposedNotFirst(drop = _LABEL_) prefix = percentile;
            run;
            proc transpose data=oken_firstborn out=TransposedFirst(drop = _LABEL_) prefix = percentile;
            run;
            proc transpose data=Zscore_data out=TransposedZscores(drop = _LABEL_) prefix = percentile;
            run;

            /* Step 2: Reformat the transposed datasets */
            data growth_NonFirst(drop = _NAME_);
                retain gab_rounded;
                set TransposedNotFirst;
                if _N_ eq 1 then delete;
                gab_rounded = input(scan(_NAME_, 2, "_"), 8.);
            run;
            data growth_First(drop = _NAME_);
                retain gab_rounded;
                set TransposedFirst;
                if _N_ eq 1 then delete;
                gab_rounded = input(scan(_NAME_, 2, "_"), 8.);
            run;


            /* Step 1: Prep the dataset for merging */
            data &dset.2;
                set &dset;
                gab_rounded = floor(&gab);
            run;

            /* Step 2: Merge the Cares dataset to the growth chart data */
            proc sort data = &dset.2; by gab_rounded; run; /* Sort the cares data by GAB*/
            proc sort data=growth_First; by gab_rounded; run; /* sort the growth data by GAB*/
            proc sort data=growth_NonFirst; by gab_rounded; run; /* Sort the growth data by GAB*/
            /* Merge the female data with the growth chart */
            data First_obs;
                merge &dset.2(where = (&sepVar = 2) in = A) growth_First(in = B);
                by gab_rounded;
                if A;
            run;
            /* Merge the male data with the growth chart */
            data NotFirst_obs;
                merge &dset.2(where = (&sepVar = 1) in = A) growth_NonFirst(in = B);
                by gab_rounded;
                if A;
            run;
            /* Create a combined dataset that includes all female and male observations*/
            data cares_concat;
                set First_obs NotFirst_obs;
            run;

        %end;
            %else %if &type = all %then %do;
                /* Pre-Processing Step: Read in the Oken data */
                proc import datafile = "&excel_path.\&filename"
                        out = oken_growth replace dbms =xlsx; 
                        getnames = YES;
                        sheet = "AllInfants";
                run;
                proc import datafile = "&excel_path.\&filename"
                        out = zscore_data replace; 
                        getnames = YES;
                        sheet = "zscore";
                run;

                /* Step 1: Transpose the datasets so we have them in wide format for merging to the dataset */
                proc transpose data=oken_growth out=TransposedGrowth(drop = _LABEL_) prefix = percentile;
                run;
                proc transpose data=Zscore_data out=TransposedZscores(drop = _LABEL_) prefix = percentile;
                run;

                /* Step 2: Reformat the transposed datasets */
                data growth(drop = _NAME_);
                    retain gab_rounded;
                    set TransposedGrowth;
                    if _N_ eq 1 then delete;
                    gab_rounded = input(scan(_NAME_, 2, "_"), 8.);
                run;



                /* Step 1: Prep the dataset for merging */
                data &dset.2;
                    set &dset;
                    gab_rounded = floor(&gab);
                run;

                /* Step 2: Merge the Cares dataset to the growth chart data */
                proc sort data = &dset.2; by gab_rounded; run; /* Sort the cares data by GAB*/
                proc sort data=growth; by gab_rounded; run; /* sort the growth data by GAB*/
                /* Merge the female data with the growth chart */
                data cares_concat;
                    merge &dset.2 growth;
                    by gab_rounded;
                run;

            %end;

    /* Step 3: Assign the percentiles to each record in the dataset */
    data percentiles(drop = percentile: i temp);
        set cares_concat; /* Set the data from the previous step */
        array percentiles {*} percentile:; /* Create an array containing all percentile information*/
        do i = 1 to dim(percentiles); /* Loop through each element of the array */
            if missing(&birthweight) then percentiles{i} = .; /* If there is a missing birthweight, declare all elements of the array as missing */
                else percentiles{i} = &birthweight - percentiles{i}; /* Subtract the percentile values from the birthweight and save in the array */
        end;
        bwpercentile_oken = 1; /* Set the counter up that will contain the percentile information */
        do until (temp = 1); /* Create a loop that iterates until the temp condition has been met (this will stop the array and make the bwpercentile_calc value the iteration) */
            if &birthweight eq . then do; /* If the birthweight is missing then...*/
                bwpercentile_oken = .; /* Set the percentile to be missing */
                temp = 1; /* Set the temporary variable to be flagged to 1 and have the iterating stop for this record */
            end;
                else if percentiles{bwpercentile_oken} <= 0 then do; /* Else if the element in the array is at the boundary between the positive and negative, we'll set the percentile to be the number of the first negative (or zero) value */
                    temp = 1; /* Set the temporary variable to be flagged to 1 and have the iterating stop for this record */
                end;
                    else if percentiles{dim(percentiles)} > 0 then do; /* EDGE CASE: if this is the LAST element in the array and the birthweight is beyond the last threshold, we'll manually put this individual in the 99th percentile */
                        bwpercentile_oken = 99; /* Manually establish the birthweight percentile to be 99 */
                        temp = 1; /* Set the temporary variable to be flagged to 1 and have the iterating stop for this record */
                    end;
                        else do; /* If the birthweight was not missing, is larger than the current cutoff and there are still
                                        more boundaries to check, this chunk will be entered */
                            bwpercentile_oken = bwpercentile_oken + 1; /* Update the birthweight percentile and examine the next threshold in the array */
                        end;
        end;
    run;
    
    /* Step 5: Drop unneeded things and concatenate the datasets together */
    proc sort data = percentiles; by bwpercentile_oken; run;
    data &outdset;
        merge   percentiles(in = A)
                zscore_data(rename = (upper  = bwpercentile_oken
                                      zscore = bwzscore_oken) in = B);
        by bwpercentile_oken;
        if A;
        label   bwpercentile_oken   = "Birthweight Percentile, calculated from the method supplied in Oken et al."
                bwzscore_oken       = "Birthweight Z-Score, calculated from the method supplied in Oken et al.";
    run;

%mend;
