###############################################################
#
# Program: p001_BirthweightFunctionFiles
# Author:  Sarah Bird
# Purpose: This program contains the functions required to run the
#   birthweight percentile algorithm.
#
###############################################################
# Copywrite Notice: 
#
# This program is free software: you can redistribute it and/or modify it under 
#     the terms of the GNU General Public License as published by the Free 
#     Software Foundation, either version 3 of the License, or (at your option) 
#     any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT 
#     ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
#     FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. 
#     If not, see <https://www.gnu.org/licenses/>.
#
###############################################################


######################################################
#
#
#   Function: format_percentile_table
#   Purpose:  The purpose of this function is to 
#     take in an input, the Oken sheets from the
#     excel file, and to output a data frame that
#     can be used to obtain birthweight percentiles
#
######################################################
format_percentile_table <- function(dataset) {
  # Step 1) Transpose the dataset, assign the column names, remove the first row that 
  #   corresponds with the numeric percentile identifiers
  table2 <- t(as.matrix(dataset))
  colnames(table2) <- paste0("percentile_", table2[1,])
  table3 <- table2[-1,]
  # Step 2) Create a column identifying which gestational age is associated with each row
  table4 <- cbind(gab = as.integer(substr(noquote(rownames(table3)), 
                                          nchar(noquote(rownames(table3))) - 1,
                                          nchar(noquote(rownames(table3))))),
                  table3)
  # Step 3) Transform this matrix into a data frame
  table5 <- as.data.frame(table4,
                          row.names = colnames(table4))
  # Step 4) Return this dataset
  return(table5)
}



okenPercentiles_sex <- function(dat, path, type) {
  
  # Preprocessing step) Check if the required package is installed
  if ( !require(readxl, quietly = TRUE) ) {
    print("Please install the readxl package to proceed!")
    if (menu(c("Yes", "No"),
             title= paste0("Would you like to install this package, readxl, now?")) == "1") {
      install.packages("readxl")
    } else { 
      print("Cancelling installation")
      return("Cannot run this function without the package, readxl.")
    }
  }
  
  library(readxl)
  
  if (type == "sex") {
    # Step 1) Read both the female and male tables in 
    female_table <- read_excel(path,
                               sheet = "Females")
    male_table <- read_excel(path,
                             sheet = "Males")
    zscores <- read_excel(path,
                          sheet = "zscore")
    colnames(zscores) <- c("percentile_range", "percentile_oken", "zscore")
    
    # Step 2) Reformat the percentile tables
    female_percentiles <- format_percentile_table(female_table)
    male_percentiles   <- format_percentile_table(male_table)
    
    # Step 3) Take the floor of the GAB variable
    dat$gab <- floor(dat$GAB)
    
    # Step 4) Separate and merge the female 
    dat_female <- dat[(dat$sex == 2) & !is.na(dat$sex),]
    dat_female2 <- merge(dat_female, female_percentiles,
                         by = "gab",
                         all.x = TRUE)
    dat_male <- dat[(dat$sex == 1) & !is.na(dat$sex),]
    dat_male2 <- merge(dat_male, male_percentiles,
                       by = "gab",
                       all.x = TRUE)
    
    # Step 5) Concatenate the two datasets together
    dat_merged <- rbind(dat_female2, dat_male2)
    
  } else if (type == "parity") {
    # Step 1) Read both the female and male tables in 
    firstborn_table <- read_excel(path,
                                  sheet = "Firstborn")
    nonfirstborn_table <- read_excel(path,
                                     sheet = "Nonfirstborn")
    zscores <- read_excel(path,
                          sheet = "zscore")
    colnames(zscores) <- c("percentile_range", "percentile_oken", "zscore")
    
    # Step 2) Reformat the percentile tables
    firstborn_percentiles      <- format_percentile_table(firstborn_table)
    nonfirstborn_percentiles   <- format_percentile_table(nonfirstborn_table)
    
    # Step 3) Take the floor of the GAB variable
    dat$gab <- floor(dat$GAB)
    
    # Step 4) Separate and merge the female 
    dat_firstborn  <- dat[(dat$parity == 1) & !is.na(dat$parity),]
    dat_firstborn2 <- merge(dat_firstborn, firstborn_percentiles,
                            by = "gab",
                            all.x = TRUE)
    dat_nonfirstborn  <- dat[(dat$parity == 0) & !is.na(dat$parity),]
    dat_nonfirstborn2 <- merge(dat_nonfirstborn, nonfirstborn_percentiles,
                               by = "gab",
                               all.x = TRUE)
    
    # Step 5) Concatenate the two datasets together
    dat_merged <- rbind(dat_firstborn2, dat_nonfirstborn2)
  } else if (type == "allInfants") {
    # Step 1) Read both the female and male tables in 
    allInfants_table <- read_excel(path,
                                   sheet = "AllInfants")
    zscores <- read_excel(path,
                          sheet = "zscore")
    colnames(zscores) <- c("percentile_range", "percentile_oken", "zscore")
    
    # Step 2) Reformat the percentile tables
    allInfants_percentiles      <- format_percentile_table(allInfants_table)
    
    # Step 3) Take the floor of the GAB variable
    dat$gab <- floor(dat$GAB)
    
    # Step 4) Separate and merge the female 
    dat_merged <- merge(dat, allInfants_percentiles,
                            by = "gab",
                            all.x = TRUE)
  }
  
  # Step 6) Determine the percentiles from the Oken data
  
  # Extract the percentile columns
  percentile_cols <- dat_merged[grep("^percentile", colnames(dat_merged), value = TRUE)]
  # Take the difference between the birthweight and the percentile thresholds 
  differences <- dat_merged$birthweight - percentile_cols
  # Assign the percentiles using the following logic:
  #   1) In a matrix full of boolean values that represent if the difference is
  #       either the first negative or less than 0,
  #           - If any of the boolean values are true, we assign the percentile 
  #               value to be the first value that satisfies this logic
  #           - If all percentile differences are missing, we'll return a 
  #               missing observations
  #           - If there are no negatives or 0s, that means the baby's birthweight
  #               surpasses the last threshold. In this case, we will assign a 
  #               value of 999, to indicate that this baby is beyond the 99th 
  #               percentile
  dat_merged$percentile_oken <- apply((differences <= 0),
                                      MARGIN = 1,
                                      FUN = function(row) if(any(row, na.rm = TRUE)){
                                        which(row)[1]
                                      } else if (all(is.na(row))){
                                        NA
                                      } else {
                                        999
                                      })
  # Step 7) Remove created columns
  dat_final <- dat_merged[,-grep("^percentile_\\d+", colnames(dat_merged))]
  dat_final2 <- dat_final[,-grep("gab", colnames(dat_final))]
  dat_final3 <- merge(dat_final2,
                      zscores,
                      by = "percentile_oken",
                      all.x = TRUE) 
  
  # Step 8) Return the final dataset
  return(dat_final3)
}

