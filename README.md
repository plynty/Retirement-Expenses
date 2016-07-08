# Retirement-Expenses

##### 
<img src="https://pbs.twimg.com/profile_images/730095911687184384/C34I9Sh-.jpg" alt="plynty logo" width="200"> 

Financial planning by your side, on your phone, in a convenient app.

## Background of plynty
plynty&copy; is a rigorous, helpful, and affordable 24/7 application that saves on the fees and middlemen. What most people do not realize is that over a long period of time, middlemen can be receiving amounts almost equal to a quarter of ones retirement savings. The goal of plynty&copy; is to allow everyone the ability to plan for a retirement of their dream without having to waste a lot of money.

##### Why is this necessary?
The current retirement approach does not include everyone, especially those far from the reach of wealth management firms. Many people even if they decide to save, do not have an idea of how much they will need to save so they can live comfortably. This is where intelligent financial plans come into play. By taking individual goals, income amounts, and projected expenses plynty creates individualized planning for investing so that everyone is comfortable in their retirement. We also want to ensure as closely as we can that people continue to live the lifestyle that they had before, if not better, when they retire.

## Goal of this Project
When you create a retirement plan using plynty, the app starts by estimating your expense budget in retirement. The goal of this project is to calculate the best estimate of a person's expenses in retirement . The best source of data for estimating consumer expenditures is the Bureau of Labor and Statistics Consumer Expenditure Survey http://www.bls.gov/cex/. Currently, we are using the 2014 Consumer Expenditure Survey data. However, data in the plynty app  will be updated everytime the BLS releases new data sets from the Consumer Expenditure Survey.

##### Why BLS data?
The BLS collects comprehensive information on the spending habits of Americans. The surveys from the BLS have accurate and impartial data that maps a nationwide and representative analysis. A lot of valuable economic information is obtained from the BLS.

##### The Demographic Selected
We used the expenses of the age group 55-64. We assume these expenses are reflective of the lifestyle that most users will want to be carried into retirement. Using expenses from a younger age would potentially be inaccurate as many of the expenses may be different closer toward retirement age, for example: healthcare.

Check out the Plynty homepage at https://www.plynty.com/#/

##### * Demonstration Views

 
# **We used R to analyze the data.**
### *How to install R*

* Go to CRAN, click download for whatever computer you are using(Linux, MacOS, Windows) and download the installer for the latest R version.
* Click the installer file.
* Select language to be used during installation.
* Follow the instructions of the installer.

### R packages used
##### Integrated Mean and SE.R
+ stringr 
+ reshape2
+ sqldf
+ RSQLite
+ plyr

##### Integrated Mean and SE Roll ups.R
* stringr


# *Data*
##### *How the data was gathered*
The information for consumer expenditure for the year 2014 (the most recent public data from them) was gathered from the Bureau of Labor and Statistics. Both diary and interview survey data was used.

##### *How the BLS gathers its information*
The sample survey guide: 
Interview Survery Information Booklet http://www.bls.gov/cex/2015_information_booklet_ce_305.pdf

##### *A getting started guide for using the data in question is given as below:*
* http://www.bls.gov/cex/pumd_novice_guide.pdf.

We have used the ASCII(Comma-Delimited) data at the bottom of this page.
* http://www.bls.gov/cex/pumd_2014.htm

##### *To understand the variable names the data documentation is as follows:*
* Interview data: http://www.bls.gov/cex/2014/csxintvwdata.pdf
* Diary data: http://www.bls.gov/cex/2014/csxdiarydata.pdf

##### *The Microdata Documentation for 2014*
* Interview data: http://www.bls.gov/cex/2014/csxintvw.pdf
* Diary data: http://www.bls.gov/cex/2014/csxdiary.pdf

# *How to Run this Repository:*
+ Install R
+ Clone this repo at https://github.com/plynty/Retirement-Expenses
+ Edit the parameters portion of the plyntyExpenditures.R file

##### How to edit the parameters in the plyntyExpenditures.R file
+ Assign a variable for the root directory (the location on your computer where you cloned this repository)

                                  mydir <- /Users/tndambakuwa/Retirement-Expenses

+ Create income brackets which you intend to use.*
  + Always keep -Inf and 0 in your incomeBreakpoints
 
                                  incomeBreakpoints <- c(-Inf,0,5000,25000,50000,75000,100000,150000,250000)
+ Choose the minimum and maximum ages of the age range you wish to get expenditures for.
 
                                  maxAge <- 64
                                  minAge <- 55
+ Create boolean that says to exclude retired CUs or not.

                                  excludeRetired <- FALSE
+ Source the plyntyExpenditures.R file
# Data Visualization
To be able to compare the data create a csv file which one can open with Microsoft Excel or Google Sheets so that you can draw graphs ad see the differences in expense percentages for different income brackets.
                                  write.csv<-(plyntyPercentageDF, "plyntyData.csv")


# **R Script modification Reasoning**
##### Integrated Mean and SE.R

The original R script would:
+ Calculate the weighted expenditures of the hardcoded income brackets

Our changes allowed the user to:
+ Create custom income brackets (as long as the -Inf and 0 are kept constant).
+ Create a custom age range to subset by.
+ Toggle whether or not to exclude retired individuals.

### **R Scripts created**
##### Integrated Mean and SE Roll Ups.R
+ Creates the rollup categories for the plynty expenditure categories which we will be focusing on.
+ Uses R objects created by the Integrated Mean and SE.R Script

##### createUCCMap.R
+ Creates a named list called abbreviationMap, which allows the user to see the text that a certain abbreviation within the tab.out file or roll up category stands for. For example:

                                  > abbreviationMap$FOODTO
                                  [1] "Food"

##### plyntyExpenditures.R
+ Comprehensive file with parameters for the chosen Demographics in question and sources the rest of the needed files. For example:

                                 source("Integrated Mean and SE.R", echo = TRUE)
                                 source("createUCCMap.R")
                                 source("Integrated Mean and SE Roll Ups.R", echo = TRUE)



## **Mathematical Formulas Used**
+ To get the mathematical formulas used and analyzing them download the 2014 documentation from this website http://www.bls.gov/cex/pumd/documentation/documentation14.zip and search in the Documentation and Data Dictionary for a file called CE PUMD Interview Users' Documentation.pdf.

## **Ratios obtained**
From the Integrated Mean and SE Roll Ups.R code program we are able to get the ratios of all the expenses for each category, visible in the plyntyPercentageDF). They should add up to 100% for every income bracket.

## **Conclusion**
The whole procedure then gave us a calculation of the expenses in the most accurate way possible. Please feel free to leave us questions and you are welcome to analyze our code.
Thanks.





Builder
Compendium Finance LLC
Licence
Copyright&copy; 2015. Licensed under the MIT license.
