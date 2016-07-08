# Remove white space from title columns in both tab.out and stubfile
tab.out$title <- str_trim(as.character(tab.out$title))
stubfile$title <- str_trim(as.character(stubfile$title))

# Merging tabout with the stubfile to get the UCC abbreviations
test <- merge(tab.out,stubfile, by = "title")
test <- subset(test, select=-c(survey,count,line,type))
test$UCC<- str_trim(test$UCC)

# Creating roll up categories
foodAtHome <- c("FOODHO")
foodAway <- c("FOODAW","ALCBEV")
housing <- c("SHELTE","HHOPER","HKPGSU","HHFURN")
utilities <- c("UTILS")
clothingAndBeauty <- c("APPARE","PERSCA")
transportation <- c("TRANS") 
healthCare <- c("MEDSER","DRUGS","MEDSUP")
entertainment <- c("ENTRTA","READIN","TOBACC")
miscellaneous <- c("MISC")
charitableAndFamilyGiving <- c("CASHCO")
insurance <- c("HLTHIN")
education <- c("EDUCAT")

breakUps <- list(foodAtHome,foodAway,housing,utilities,clothingAndBeauty,transportation,healthCare,entertainment,miscellaneous,charitableAndFamilyGiving,insurance,education)
names(breakUps) <- c("foodAtHome","foodAway","housing","utilities","clothingAndBeauty","transportation","healthCare","entertainment","miscellaneous","charitableAndFamilyGiving","insurance","education")

print("creating data frame")
rollUpDF <- as.data.frame(matrix(rep(0, 7 + length(incomeLabels)), nrow=1))

names(rollUpDF) <- colnames(test)

# loops through the list to get the rows that have the right accronyms
for(x in 1:length(breakUps)){
  for(y in 1:length(breakUps[[x]])){
    rollUpDF <- rbind(rollUpDF,test[which(test$UCC == breakUps[[x]][y]),])
  }
}
dropColumns <- c("estimate","level","group")
rollUpDF <- rollUpDF[-c(1,which(rollUpDF$estimate == "SE")),!(names(rollUpDF)%in%dropColumns)]
rownames(rollUpDF)<-NULL


# creating names for plynty dataframe
plyntyDFNamesString <- "category, all consumer units, all consumer units percentages, less than $0, Income bracket 0 percentages"
for(x in 1:length(incomeLabels)){
  plyntyDFNamesString <- paste0(plyntyDFNamesString,", ",incomeLabels[x],", Income bracket ",x," percentages")
}

plyntyDFNamesVector <-str_split(plyntyDFNamesString,", ")
plyntyDF <- as.data.frame(matrix(rep(0, (5 + 2*length(incomeLabels)) * (length(breakUps)+1)), nrow=length(breakUps)+1))
colnames(plyntyDF) <- plyntyDFNamesVector[[1]]
plyntyDF[,1] <- c("total expenditures",names(breakUps))

#filling the dataframe $ excluding totals
for(x in 1:length(breakUps)){
  plyntyDF[which(plyntyDF$category == names(breakUps)[x]),seq(2,ncol(plyntyDF),2)]<-colSums((rollUpDF[which(rollUpDF$UCC %in% breakUps[[x]]),2:(ncol(rollUpDF)-1)]))
}

# filling in the totals
for(x in seq(2,ncol(plyntyDF),2)){
  total <- 0
  for(y in 2:nrow(plyntyDF)){
    total <- total + plyntyDF[y,x]
  }
  plyntyDF[1,x] <- total
}

# calculating the percentages
for(y in seq(3,ncol(plyntyDF),2)){
  totalExpnd <- plyntyDF[1,y-1]
  for(x in 1:nrow(plyntyDF)){
    plyntyDF[x,y]<-round(plyntyDF[x,y-1]/totalExpnd, digits = 3)
  }
}


plyntyPercentageDF <- plyntyDF[,c(1,seq(3,ncol(plyntyDF),2))]

names(plyntyPercentageDF) <- names(plyntyDF)[c(1,seq(2,ncol(plyntyDF),2))]

rownames(plyntyPercentageDF) <- NULL

plyntyPercentageDF <- plyntyPercentageDF[2:nrow(plyntyPercentageDF),]
#print(plyntyDF[,1])
#rownames(plyntyPercentageDF) <- plyntyDF[1:nrow(plyntyDF),]



