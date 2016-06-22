# Retirement-Expenses

##### 
![plynty logo](https://pbs.twimg.com/profile_images/730095911687184384/C34I9Sh-.jpg)

Financial planning by your side, on your phone, in a convenient app.


## Aim
The current retirement approach does not include everyone. However, when we all understand money better, intelligent financial plans can me made by all. By taking individual goals, plynty is here to create individualized planning for investing.

##### Why is this necessary?
plynty(c) is a rigorous, helpful, cheap and affordable 24/7 application that saves on the fees to have middlemen. The goal of creating this financial application is to enable everyone plan for a retirement of their dream.

##### Methodology used
Our goal is to calculate valid expenses using the Bureau of Labor and Statistics Consumer Expenditure information http://www.bls.gov/cex/ from the interview and survey data.
##### Why BLS data?
The BLS collects comprehensive information on the spending habits of Americans.

+ Using the expenses of the age group 55-64, we assume those are the expenses that will be carried onto retirement and that using expenses before then would not be accurate as most of the expenses will be gone eg. college tuition.


Check out the Plynty homepage at https://www.plynty.com/#/
##### * How it works.
One answers a series of questions and then gets directed to how much they need to save. 

##### * Demonstration Views


 
# **We used R to analyze the data.**
====================================

#### *How to install R*

* Go to CRAN, click download for whatever computer you are using(Linux, MacOS, Windows) and download the installer for the latest R version.
* Click the installer file.
* Select language to be used during installation.
* Follow the instructions of the installer.

#### R packages used
### Integrated Mean and SE.R
+ stringr 
+ reshape2
+ sqldf
+ RSQLite
+ plyr

Integrated Mean and SE Roll ups.R
* stringr


# *Data*
===========
##### *How the data was gathered*
The information for consumer expenditure for the year 2014 (the most recent public data from them) was gathered from the Bureau of Labor and Statistics. Both diary and interview survey data was used.

##### *How the BLS gathers its information*
The sample survey guides 
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

##### *Filtering the data*


## **Code used**
==========
##### Integrated Mean and SE.R code
The aim of this was is to:
+ input paramenters for the year whose data we will be using.
+ put the directory from which you will clone the date from.
+ put the income brackets which we want to use but we leave -Inf and 0 as they are and add new incomes we want to use. Reason being in the event that we have data where a company ran a loss we can include the loss in the data frame.
+ age range for the data we are looking into is also inputted.

#### Integrated Mean and SE Roll Ups.R
+ Creating rollup categories.


## **Mathematical Formulas Used**
================================
+ To get the mathematical formulas used download the 2014 documentation from this website http://www.bls.gov/cex/pumd/documentation/documentation14.zip and search in the Documentation and Data Dictionary for a file called CE PUMD Interview Users' Documentation.pdf.

## **Ratios obtained**
=====================
From the Integrated Mean and SE Roll Ups.R code program we are able to get the ratios of all the expenses for each category. They should add up to 100%.

## **Conclusion**
===============
The whole procedure then gave us a calculation of the expenses in the most accurate way possible. Please feel free to leave us questions and you are welcome to analyze our code.
Thanks.





Builder
Compendium Finance LLC
Licence
Copyright(c) 2015. Licensed under the MIT license.

Notes

  
