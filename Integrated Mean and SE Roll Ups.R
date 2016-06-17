# Assign a variable for the root directory
# The same directory that was used in the Integrated Mean and SE.R file
mydir <- "/Users/aarondyke/CE_PUMD"
yr <- 2014

# Assuming you have setup the Integrated Mean and SE.R file with the parameters you want
#source(paste0(mydir,'/',yr,'/Integrated Mean and SE.R'), echo=TRUE)

# Remove white space from title columns in both tab.out and stubfile
tab.out$title <- str_trim(as.character(tab.out$title))
stubfile$title <- str_trim(as.character(stubfile$title))

# Merging tabout with the stubfile to get the UCC abbreviations
test <- merge(tab.out,stubfile, by = "title")
test <- subset(test, select=-c(survey,count,line,type))

# Creating roll up categories
foodAtHome <- c("FOODHO")
foodAway <- c("FOODAW")
alcoholicDrinks <- c("ALCBEV")
housing <- c("SHELTE","HHOPER","HKPGSU","HHFURN")
utilities <- c("UTILS")
apparelAndServices <- c("APPARE")
transportation <- c("TRANS") #include airfare or not?
healthCare <- c("MEDSER","DRUGS","MEDSUP")
entertainment <- c("ENTRTA","READIN")
personalCare <- c("PERSCA")
miscellaneous <- c("MISC")
charitableAndFamilyGiving <- c("CASHCO")
insurance <- c("HLTHIN","INSPEN")
education <- c("EDUCAT")
tobacco <- c("TOBACC")

breakUps <- list(foodAtHome,foodAway,alcoholicDrinks,housing,utilities,apparelAndServices,transportation,healthCare,entertainment,personalCare,miscellaneous,charitableAndFamilyGiving,insurance,education,tobacco)

# loops through the list to get the rows that have the right accronyms
for(x in 1:length(breakUps)){
  for(y in 1:length(breakUps[[x]])){
    test[which(test$UCC == breakUps[[x]][y]),]
  }
}

#check the abreviation title
abbreviationMap$FOODHO

columnNames <- colnames(tab.out[,2:ncol(tab.out)])




