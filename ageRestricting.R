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
fmld141 <- read.csv("diary14/fmld141.csv", stringsAsFactors=FALSE)
fmld142 <- read.csv("diary14/fmld142.csv", stringsAsFactors=FALSE)
fmld143 <- read.csv("diary14/fmld143.csv", stringsAsFactors=FALSE)
fmld144 <- read.csv("diary14/fmld144.csv", stringsAsFactors=FALSE)

memd141 <- read.csv("diary14/memd141.csv", stringsAsFactors=FALSE)
memd142 <- read.csv("diary14/memd142.csv", stringsAsFactors=FALSE)
memd143 <- read.csv("diary14/memd143.csv", stringsAsFactors=FALSE)
memd144 <- read.csv("diary14/memd144.csv", stringsAsFactors=FALSE)

## Creating age restriction for memd files

#Restricts based on anyone in the CU's age
memd141AgeRestricted <- filter(memd141, AGE >= minAge & AGE <= maxAge)
memd142AgeRestricted <- filter(memd142, AGE >= minAge & AGE <= maxAge)
memd143AgeRestricted <- filter(memd143, AGE >= minAge & AGE <= maxAge)
memd144AgeRestricted <- filter(memd144, AGE >= minAge & AGE <= maxAge)
#vector of NEWIDs of CU's that are within the age range (The number of times the NEWID is present represents the number of people in the CU that are within that age range)
memdAgeRestrictedNEWIDs <- memd141AgeRestricted$NEWID
table(memdAgeRestrictedNEWIDs)

#creating age restriction for fmld files
#restricts only based on the reference person's age
fmld141AgeRestricted <- filter(fmld141,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld142AgeRestricted <- filter(fmld142,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld143AgeRestricted <- filter(fmld143,AGE_REF >= minAge & AGE_REF <= maxAge)
fmld144AgeRestricted <- filter(fmld144,AGE_REF >= minAge & AGE_REF <= maxAge)

#creating vector of new ids of which to use for other dataframes
diaryAgeRestrictedNEWIDs <- unique(c(fmld141AgeRestricted$NEWID,fmld142AgeRestricted$NEWID,fmld143AgeRestricted$NEWID,fmld144AgeRestricted$NEWID,memd141AgeRestricted$NEWID,memd142AgeRestricted$NEWID,memd143AgeRestricted$NEWID,memd144AgeRestricted$NEWID))

#loading in the last three types of diary survey data files
expd141 <- read.csv("diary14/expd141.csv", stringsAsFactors=FALSE)
expd142 <- read.csv("diary14/expd142.csv", stringsAsFactors=FALSE)
expd143 <- read.csv("diary14/expd143.csv", stringsAsFactors=FALSE)
expd144 <- read.csv("diary14/expd144.csv", stringsAsFactors=FALSE)

dtbd141 <- read.csv("diary14/dtbd141.csv", stringsAsFactors=FALSE)
dtbd142 <- read.csv("diary14/dtbd142.csv", stringsAsFactors=FALSE)
dtbd143 <- read.csv("diary14/dtbd143.csv", stringsAsFactors=FALSE)
dtbd144 <- read.csv("diary14/dtbd144.csv", stringsAsFactors=FALSE)

dtid141 <- read.csv("diary14/dtid141.csv", stringsAsFactors=FALSE)
dtid142 <- read.csv("diary14/dtid142.csv", stringsAsFactors=FALSE)
dtid143 <- read.csv("diary14/dtid143.csv", stringsAsFactors=FALSE)
dtid144 <- read.csv("diary14/dtid144.csv", stringsAsFactors=FALSE)


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
fmli141x <- read.csv("intrvw14/interview14/fmli141x.csv", stringsAsFactors=FALSE)
fmli142 <- read.csv("intrvw14/interview14/fmli142.csv", stringsAsFactors=FALSE)
fmli143 <- read.csv("intrvw14/interview14/fmli143.csv", stringsAsFactors=FALSE)
fmli144 <- read.csv("intrvw14/interview14/fmli144.csv", stringsAsFactors=FALSE)
fmli151 <- read.csv("intrvw14/interview14/fmli151.csv", stringsAsFactors=FALSE)

memi141x <- read.csv("intrvw14/interview14/memi141x.csv", stringsAsFactors=FALSE)
memi142 <- read.csv("intrvw14/interview14/memi142.csv", stringsAsFactors=FALSE)
memi143 <- read.csv("intrvw14/interview14/memi143.csv", stringsAsFactors=FALSE)
memi144 <- read.csv("intrvw14/interview14/memi144.csv", stringsAsFactors=FALSE)
memi151 <- read.csv("intrvw14/interview14/memi151.csv", stringsAsFactors=FALSE)

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

#loading in dataframes
mtbi141x <- read.csv("intrvw14/interview14/mtbi141x.csv", stringsAsFactors=FALSE)
mtbi142 <- read.csv("intrvw14/interview14/mtbi142.csv", stringsAsFactors=FALSE)
mtbi143 <- read.csv("intrvw14/interview14/mtbi143.csv", stringsAsFactors=FALSE)
mtbi144 <- read.csv("intrvw14/interview14/mtbi144.csv", stringsAsFactors=FALSE)
mtbi151 <- read.csv("intrvw14/interview14/mtbi151.csv", stringsAsFactors=FALSE)

itbi141x <- read.csv("intrvw14/interview14/itbi141x.csv", stringsAsFactors=FALSE)
itbi142 <- read.csv("intrvw14/interview14/itbi142.csv", stringsAsFactors=FALSE)
itbi143 <- read.csv("intrvw14/interview14/itbi143.csv", stringsAsFactors=FALSE)
itbi144 <- read.csv("intrvw14/interview14/itbi144.csv", stringsAsFactors=FALSE)
itbi151 <- read.csv("intrvw14/interview14/itbi151.csv", stringsAsFactors=FALSE)

itii141x <- read.csv("intrvw14/interview14/itii141x.csv", stringsAsFactors=FALSE)
itii142 <- read.csv("intrvw14/interview14/itii142.csv", stringsAsFactors=FALSE)
itii143 <- read.csv("intrvw14/interview14/itii143.csv", stringsAsFactors=FALSE)
itii144 <- read.csv("intrvw14/interview14/itii144.csv", stringsAsFactors=FALSE)
itii151 <- read.csv("intrvw14/interview14/itii151.csv", stringsAsFactors=FALSE)

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