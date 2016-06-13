rm(list=ls())

#The location of the cloned github repo on your machine
#ex. "~/Documents/SuperCool/Retirement-Expenses
directoryOfRepo <- "~/Documents/Retirement-Expenses"
setwd(directoryOfRepo)

###Code below creates the dataframes of BLS CES data that contains every member of a CU that is within an age range 

maxAge <- 64 #inclusive top range for the age group to study
minAge <- 55 #inclusive bottom range for the age group to study
validAgeVecotr <- seq(minAge,maxAge)

#Diary Files

#loading original files
load("originalDiaryDataframes.RData")

## Creating age restriction for memd files
#Restricts based on anyone in the CU's age
memd141AgeRestricted <- filter(memd141, AGE >= minAge & AGE <= maxAge)
memd142AgeRestricted <- filter(memd142, AGE >= minAge & AGE <= maxAge)
memd143AgeRestricted <- filter(memd143, AGE >= minAge & AGE <= maxAge)
memd144AgeRestricted <- filter(memd144, AGE >= minAge & AGE <= maxAge)

## Creating age restriction for fmld files
#restricts only based on the reference person's age
fmld141AgeRestricted <- filter(fmld141,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld142AgeRestricted <- filter(fmld142,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld143AgeRestricted <- filter(fmld143,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld144AgeRestricted <- filter(fmld144,AGE_REF >= minAge & AGE_REF <= maxAge)

#Creating vector of new ids of which to use for other dataframes
diaryAgeRestrictedNEWIDs <- unique(c(fmld141AgeRestricted$NEWID,fmld142AgeRestricted$NEWID,fmld143AgeRestricted$NEWID,fmld144AgeRestricted$NEWID,memd141AgeRestricted$NEWID,memd142AgeRestricted$NEWID,memd143AgeRestricted$NEWID,memd144AgeRestricted$NEWID))

expd141AgeRestricted <- expd141[which(expd141$NEWID %in% diaryAgeRestrictedNEWIDs),]
# #all files below do not contain the NEWIDs that are within the age range
# expd142AgeRestricted <- expd142[which(expd142$NEWID %in% diaryAgeRestrictedNEWIDs),]
# expd143AgeRestricted <- expd143[which(expd143$NEWID %in% diaryAgeRestrictedNEWIDs),]
# expd144AgeRestricted <- expd144[which(expd144$NEWID %in% diaryAgeRestrictedNEWIDs),]
# rm(expd142AgeRestricted,expd143AgeRestricted,expd144AgeRestricted)
# #*********************************************************************************

dtbd141AgeRestricted <- dtbd141[which(dtbd141$NEWID %in% diaryAgeRestrictedNEWIDs),]
# #all files below do not contain the NEWIDs that are within the age range
# dtbd142AgeRestricted <- dtbd142[which(dtbd142$NEWID %in% diaryAgeRestrictedNEWIDs),]
# dtbd143AgeRestricted <- dtbd143[which(dtbd143$NEWID %in% diaryAgeRestrictedNEWIDs),]
# dtbd144AgeRestricted <- dtbd144[which(dtbd144$NEWID %in% diaryAgeRestrictedNEWIDs),]
# rm(dtbd142AgeRestricted,dtbd143AgeRestricted,dtbd144AgeRestricted)
# #*********************************************************************************

dtid141AgeRestricted <- dtid141[which(dtid141$NEWID %in% diaryAgeRestrictedNEWIDs),]
# #all files below do not contain the NEWIDs that are within the age range
# dtid142AgeRestricted <- dtid142[which(dtid142$NEWID %in% diaryAgeRestrictedNEWIDs),]
# dtid143AgeRestricted <- dtid143[which(dtid143$NEWID %in% diaryAgeRestrictedNEWIDs),]
# dtid144AgeRestricted <- dtid144[which(dtid144$NEWID %in% diaryAgeRestrictedNEWIDs),]
# rm(dtid142AgeRestricted,dtid143AgeRestricted,dtid144AgeRestricted)
# #*********************************************************************************

###Interview Files with Fixed Age

#loading in original files
load("originalInterviewDataframes.RData")

#creating age restriction for fmli dataframes
fmli141xAgeRestricted <- filter(fmli141x, AGE_REF >= minAge & AGE_REF <= maxAge)
fmli142AgeRestricted <- filter(fmli142, AGE_REF >= minAge & AGE_REF <= maxAge)
fmli143AgeRestricted <- filter(fmli143, AGE_REF >= minAge & AGE_REF <= maxAge)
fmli144AgeRestricted <- filter(fmli144, AGE_REF >= minAge & AGE_REF <= maxAge)
fmli151AgeRestricted <- filter(fmli151, AGE_REF >= minAge & AGE_REF <= maxAge)

#creating age restriction for memi dataframes
memi141xAgeRestricted <- filter(memi141x,AGE >= minAge & AGE <= maxAge)
memi142AgeRestricted <- filter(memi142,AGE >= minAge & AGE <= maxAge)
memi143AgeRestricted <- filter(memi143,AGE >= minAge & AGE <= maxAge)
memi144AgeRestricted <- filter(memi144,AGE >= minAge & AGE <= maxAge)
memi151AgeRestricted <- filter(memi151,AGE >= minAge & AGE <= maxAge)

#creating a vector of new ids to use to filter the rest of the interview dataframes
interviewAgeRestrictedNEWIDs <- unique(c(fmli141xAgeRestricted$NEWID,fmli142AgeRestricted$NEWID,fmli143AgeRestricted$NEWID,fmli144AgeRestricted$NEWID,fmli151AgeRestricted$NEWID,memi141xAgeRestricted$NEWID,memi142AgeRestricted$NEWID,memi143AgeRestricted$NEWID,memi144AgeRestricted$NEWID,memi151AgeRestricted$NEWID))

#creating age restriction for mtbi dataframes
mtbi141xAgeRestricted <- mtbi141x[which(mtbi141x$NEWID %in% interviewAgeRestrictedNEWIDs),]
mtbi142AgeRestricted <- mtbi142[which(mtbi142$NEWID %in% interviewAgeRestrictedNEWIDs),]
mtbi143AgeRestricted <- mtbi143[which(mtbi143$NEWID %in% interviewAgeRestrictedNEWIDs),]
mtbi144AgeRestricted <- mtbi144[which(mtbi144$NEWID %in% interviewAgeRestrictedNEWIDs),]
mtbi151AgeRestricted <- mtbi151[which(mtbi151$NEWID %in% interviewAgeRestrictedNEWIDs),]

#creating age restriction for itbi dataframes
itbi141xAgeRestricted <- itbi141x[which(itbi141x$NEWID %in% interviewAgeRestrictedNEWIDs),]
itbi142AgeRestricted <- itbi142[which(itbi142$NEWID %in% interviewAgeRestrictedNEWIDs),]
itbi143AgeRestricted <- itbi143[which(itbi143$NEWID %in% interviewAgeRestrictedNEWIDs),]
itbi144AgeRestricted <- itbi144[which(itbi144$NEWID %in% interviewAgeRestrictedNEWIDs),]
itbi151AgeRestricted <- itbi151[which(itbi151$NEWID %in% interviewAgeRestrictedNEWIDs),]

#creating age restriction for itii dataframes
itii141xAgeRestricted <- itii141x[which(itii141x$NEWID %in% interviewAgeRestrictedNEWIDs),]
itii142AgeRestricted <- itii142[which(itii142$NEWID %in% interviewAgeRestrictedNEWIDs),]
itii143AgeRestricted <- itii143[which(itii143$NEWID %in% interviewAgeRestrictedNEWIDs),]
itii144AgeRestricted <- itii144[which(itii144$NEWID %in% interviewAgeRestrictedNEWIDs),]
itii151AgeRestricted <- itii151[which(itii151$NEWID %in% interviewAgeRestrictedNEWIDs),]

# #Creating the RDatafiles for ageRestricted Dataframes
# save(fmld141AgeRestricted,fmld142AgeRestricted,fmld143AgeRestricted,fmld144AgeRestricted,memd141AgeRestricted,memd142AgeRestricted,memd143AgeRestricted,memd144AgeRestricted,expd141AgeRestricted,dtbd141AgeRestricted,dtid141AgeRestricted, file = "ageRestrictedDiaryDataframes.RData")
# save(fmli141xAgeRestricted,fmli142AgeRestricted,fmli143AgeRestricted,fmli144AgeRestricted,fmli151AgeRestricted,memi141xAgeRestricted,memi142AgeRestricted,memi143AgeRestricted,memi144AgeRestricted,memi151AgeRestricted,mtbi141xAgeRestricted,mtbi142AgeRestricted,mtbi143AgeRestricted,mtbi144AgeRestricted,mtbi151AgeRestricted,itbi141xAgeRestricted,itbi142AgeRestricted,itbi143AgeRestricted,itbi144AgeRestricted,itbi151AgeRestricted,itii141xAgeRestricted,itii142AgeRestricted,itii143AgeRestricted,itii144AgeRestricted,itii151AgeRestricted, file = "ageRestrictedInterviewDataframes.RData")