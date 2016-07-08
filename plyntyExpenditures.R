### Parameters to fill out before running the R script
# Assign a variable for the year for which data will be tabulated
year <- 2014

# Assign a variable for the root directory (where the cloned github repository is)
mydir <- "/Users/aarondyke/Documents/Retirement-Expenses"

# Create income brackets
incomeBreakpoints <- c(-Inf,0,5000,25000,50000,75000,100000,150000,250000)

# Create age range
maxAge <- 64
minAge <- 55

# Create boolean that says to exclude retired CUs or not
excludeRetired <- FALSE

# Create boolean that determines if the R script will create a csv of the tab.out dataframe 
createTabOutCSV <- FALSE

########################################
# Do not edit anything below this line #
########################################
setwd(mydir)
source("Integrated Mean and SE.R", echo = TRUE)
source("createUCCMap.R")
source("Integrated Mean and SE Roll Ups.R", echo = TRUE)