rm(list=ls())

#The location of the cloned github repo on your machine
#ex. "~/Documents/SuperCool/Retirement-Expenses
directoryOfRepo <- "~/Documents/Retirement-Expenses"
setwd(directoryOfRepo)

#Source only necessary if you are lacking the AgeRestricted dataframes
#source('ageRestricting.R', echo=TRUE)
load("ageRestrictedDiaryDataframes.RData")


#Retirement Restriction
#Diary
#for both anyone in the CU
#WHYNWRK1 - reason why reference person did not work during the past 12 months 1 = Retired
#WHYNWRK2 - reason why spouse did not work during the past 12 months 1 = Retired
diaryNonRetiredAgedNEWIDs1 <- filter(fmld141AgeRestricted, WHYNWRK1 != 1 | WHYNWRK2 != 1)$NEWID
diaryNonRetiredAgedNEWIDs2 <- filter(fmld142AgeRestricted, WHYNWRK1 != 1 | WHYNWRK2 != 1)$NEWID
diaryNonRetiredAgedNEWIDs3 <- filter(fmld143AgeRestricted, WHYNWRK1 != 1 | WHYNWRK2 != 1)$NEWID
diaryNonRetiredAgedNEWIDs4 <- filter(fmld144AgeRestricted, WHYNWRK1 != 1 | WHYNWRK2 != 1)$NEWID
diaryNonRetiredAgedNEWIDs5 <- filter(memd141AgeRestricted, OCCUEARN != 930)$NEWID
diaryNonRetiredAgedNEWIDs6 <- filter(memd142AgeRestricted, OCCUEARN != 930)$NEWID
diaryNonRetiredAgedNEWIDs7 <- filter(memd143AgeRestricted, OCCUEARN != 930)$NEWID
diaryNonRetiredAgedNEWIDs8 <- filter(memd144AgeRestricted, OCCUEARN != 930)$NEWID

#setting the NEWIDs to subset by
diaryNonRetiredAgeRestrictedNEWIDs <- unique(c(diaryNonRetiredAgedNEWIDs1,diaryNonRetiredAgedNEWIDs2,diaryNonRetiredAgedNEWIDs3,diaryNonRetiredAgedNEWIDs4,diaryNonRetiredAgedNEWIDs5,diaryNonRetiredAgedNEWIDs6,diaryNonRetiredAgedNEWIDs7,diaryNonRetiredAgedNEWIDs8))

fmld141DoubleRestricted <- fmld141AgeRestricted[which(fmld141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
fmld142DoubleRestricted <- fmld142AgeRestricted[which(fmld142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
fmld143DoubleRestricted <- fmld143AgeRestricted[which(fmld143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
fmld144DoubleRestricted <- fmld144AgeRestricted[which(fmld144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]

memd141DoubleRestricted <- memd141AgeRestricted[which(memd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
memd142DoubleRestricted <- memd142AgeRestricted[which(memd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
memd143DoubleRestricted <- memd143AgeRestricted[which(memd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
memd144DoubleRestricted <- memd144AgeRestricted[which(memd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]

expd141DoubleRestricted <- expd141AgeRestricted[which(expd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #Below are files that were not applicable to the ageRestricting
# expd142DoubleRestricted <- expd142AgeRestricted[which(expd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# expd143DoubleRestricted <- expd143AgeRestricted[which(expd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# expd144DoubleRestricted <- expd144AgeRestricted[which(expd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #**************************************************************************************************************************

dtbd141DoubleRestricted <- dtbd141AgeRestricted[which(dtbd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #Below are files that were not applicable to the ageRestricting
# dtbd142DoubleRestricted <- dtbd142AgeRestricted[which(dtbd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# dtbd143DoubleRestricted <- dtbd143AgeRestricted[which(dtbd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# dtbd144DoubleRestricted <- dtbd144AgeRestricted[which(dtbd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #**************************************************************************************************************************

dtid141DoubleRestricted <- dtid141AgeRestricted[which(dtid141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #Below are files that were not applicable to the ageRestricting
# dtid142DoubleRestricted <- dtid142AgeRestricted[which(dtid142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# dtid143DoubleRestricted <- dtid143AgeRestricted[which(dtid143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# dtid144DoubleRestricted <- dtid144AgeRestricted[which(dtid144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# #**************************************************************************************************************************

### Interview files

#loading in the ageRestricted Data Frames
load("ageRestrictedInterviewDataframes.RData")

interviewNonRetiredAgedNEWIDs1 <- filter(fmli141xAgeRestricted, INCNONW1 != 1 | INCNONW2 != 1)$NEWID
interviewNonRetiredAgedNEWIDs2 <- filter(fmli142AgeRestricted, INCNONW1 != 1 | INCNONW2 != 1)$NEWID
interviewNonRetiredAgedNEWIDs3 <- filter(fmli143AgeRestricted, INCNONW1 != 1 | INCNONW2 != 1)$NEWID
interviewNonRetiredAgedNEWIDs4 <- filter(fmli144AgeRestricted, INCNONW1 != 1 | INCNONW2 != 1)$NEWID
interviewNonRetiredAgedNEWIDs5 <- filter(fmli151AgeRestricted, INCNONW1 != 1 | INCNONW2 != 1)$NEWID
interviewNonRetiredAgedNEWIDs6 <- filter(memi141xAgeRestricted, INCNONWK != 1)$NEWID
interviewNonRetiredAgedNEWIDs7 <- filter(memi142AgeRestricted, INCNONWK != 1)$NEWID
interviewNonRetiredAgedNEWIDs8 <- filter(memi143AgeRestricted, INCNONWK != 1)$NEWID
interviewNonRetiredAgedNEWIDs9 <- filter(memi144AgeRestricted, INCNONWK != 1)$NEWID
interviewNonRetiredAgedNEWIDs10 <- filter(memi151AgeRestricted, INCNONWK != 1)$NEWID

interviewNonRetiredAgedNEWIDs <- unique(c(interviewNonRetiredAgedNEWIDs1,interviewNonRetiredAgedNEWIDs2,interviewNonRetiredAgedNEWIDs3, interviewNonRetiredAgedNEWIDs4, interviewNonRetiredAgedNEWIDs5,interviewNonRetiredAgedNEWIDs6,interviewNonRetiredAgedNEWIDs7,interviewNonRetiredAgedNEWIDs8, interviewNonRetiredAgedNEWIDs9, interviewNonRetiredAgedNEWIDs10))

fmli141xDoubleRestricted <- fmli141xAgeRestricted[which(fmli141xAgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
fmli142DoubleRestricted <- fmli142AgeRestricted[which(fmli142AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
fmli143DoubleRestricted <- fmli143AgeRestricted[which(fmli143AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
fmli144DoubleRestricted <- fmli144AgeRestricted[which(fmli144AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
fmli151DoubleRestricted <- fmli151AgeRestricted[which(fmli151AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]

memi141xDoubleRestricted <- memi141xAgeRestricted[which(memi141xAgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
memi142DoubleRestricted <- memi142AgeRestricted[which(memi142AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
memi143DoubleRestricted <- memi143AgeRestricted[which(memi143AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
memi144DoubleRestricted <- memi144AgeRestricted[which(memi144AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
memi151DoubleRestricted <- memi151AgeRestricted[which(memi151AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]

mtbi141xDoubleRestricted <- mtbi141xAgeRestricted[which(mtbi141xAgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
mtbi142DoubleRestricted <- mtbi142AgeRestricted[which(mtbi142AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
mtbi143DoubleRestricted <- mtbi143AgeRestricted[which(mtbi143AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
mtbi144DoubleRestricted <- mtbi144AgeRestricted[which(mtbi144AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
mtbi151DoubleRestricted <- mtbi151AgeRestricted[which(mtbi151AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]

itbi141xDoubleRestricted <- itbi141xAgeRestricted[which(itbi141xAgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itbi142DoubleRestricted <- itbi142AgeRestricted[which(itbi142AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itbi143DoubleRestricted <- itbi143AgeRestricted[which(itbi143AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itbi144DoubleRestricted <- itbi144AgeRestricted[which(itbi144AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itbi151DoubleRestricted <- itbi151AgeRestricted[which(itbi151AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]

itii141xDoubleRestricted <- itii141xAgeRestricted[which(itii141xAgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itii142DoubleRestricted <- itii142AgeRestricted[which(itii142AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itii143DoubleRestricted <- itii143AgeRestricted[which(itii143AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itii144DoubleRestricted <- itii144AgeRestricted[which(itii144AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]
itii151DoubleRestricted <- itii151AgeRestricted[which(itii151AgeRestricted$NEWID %in% interviewNonRetiredAgedNEWIDs),]

# #Saving Double restricted dataframes as RData files
# save(fmld141DoubleRestricted,fmld142DoubleRestricted,fmld143DoubleRestricted,fmld144DoubleRestricted,memd141DoubleRestricted,memd142DoubleRestricted,memd143DoubleRestricted,memd144DoubleRestricted,expd141DoubleRestricted,dtbd141DoubleRestricted,dtid141DoubleRestricted, file = "doubleRestrictedDiaryDataframes.RData")
# save(fmli141xDoubleRestricted,fmli142DoubleRestricted,fmli143DoubleRestricted,fmli144DoubleRestricted,fmli151DoubleRestricted,memi141xDoubleRestricted,memi142DoubleRestricted,memi143DoubleRestricted,memi144DoubleRestricted,memi151DoubleRestricted,mtbi141xDoubleRestricted,mtbi142DoubleRestricted,mtbi143DoubleRestricted,mtbi144DoubleRestricted,mtbi151DoubleRestricted,itbi141xDoubleRestricted,itbi142DoubleRestricted,itbi143DoubleRestricted,itbi144DoubleRestricted,itbi151DoubleRestricted,itii141xDoubleRestricted,itii142DoubleRestricted,itii143DoubleRestricted,itii144DoubleRestricted,itii151DoubleRestricted, file = "doubleRestrictedInterviewDataframes.RData")
