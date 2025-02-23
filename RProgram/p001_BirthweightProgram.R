###############################################################
#
# Program: Oken Birthweight Percentiling
# Author:  Sarah Bird
# Purpose: This program is a template file, demonstrating how
#   to run the function that generates the Oken birthweight
#   percentiles.
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


#######################################################
#
# Step 1) Read in the package required for the function
#
#######################################################
library(readxl)



#######################################################
#
# Step 2) Read in the source file containing the functions for
#   generating the Oken percentiles and z-values
#
#######################################################

# Establish the absolute path to the directory you are working out of
root <- "<insert root to working directory>"

# Set the working directory to the root destination
setwd(root) 

# Call the source functions into the session
source("<path-to-where-this-file-is-saved>/p001_BirthweightFunctionFiles.R")


#######################################################
#
# Step 3) Read in the dataset and rename as needed
#   to generate the percentiles.
#
# * FOR THIS PROGRAM, you will need to rename the following
#     variables in your dataset
#         - GAB: Numeric variable, characterizing the gestational
#             age of the infant when born (in weeks and days, decimal form)
#         - sex: Numeric variable, characterizes whether the infant is 
#             male (value = 1) or female (value = 2)
#         - birthweight: Numeric variable, contains the birthweight of 
#             the infant in grams
#         - parity: Numeric variable, characterizes whether the infant
#             is a firstborn (value = 1) or non-firstborn (value = 2)
#
#######################################################

# Read in the dataset and rename variables as needed to 
#   run the function
dat <- read_spss("<path-to-data>/<file-name>") %>%
  rename("GAB" = "<variable-name-for-GAB>",
         "sex" = "<variable-name-for-sex>",
         "birthweight" = "<variable-name-for-birthweight>",
         "parity" = "<variable-name-for-parity>") 


#######################################################
#
# Step 4) Run the percentile function
#
#   Required Inputs:
#     - dat:  the dataset that the algorithm should be 
#       run on
#     - path: the relative file path that locates the Oken
#       reformatted excel sheets
#     - type: character string of either "parity", "sex",
#       or "allInfants". This is an identifier that tells
#       the function which percentile tables to use for the
#       percentiling.
#
#######################################################

# Run the percentile algorithm, by parity
cleaned_dat <- okenPercentiles(dat = dat,
                               path = "data/Oken_Growth02.xlsx",
                               type = "parity")
# Run the percentile algorithm, by sex
cleaned_dat <- okenPercentiles(dat = dat,
                                   path = "data/Oken_Growth02.xlsx",
                                   type = "sex")
# Run the percentile algorithm for all infant types
cleaned_dat <- okenPercentiles(dat = dat,
                                   path = "data/Oken_Growth02.xlsx",
                                   type = "allInfants")














