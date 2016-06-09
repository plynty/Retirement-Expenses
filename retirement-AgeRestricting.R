rm(list=ls())

#The location of the cloned github repo on your machine
#ex. "~/Documents/SuperCool/Retirement-Expenses
directoryOfRepo <- "~/Documents/Retirement-Expenses"
setwd(directoryOfRepo)

#Source only necessary if you are lacking the AgeRestricted dataframes
source('ageRestricting.R', echo=TRUE)

#Retirement Restriction
#Diary
#for both anyone in the CU
#WHYNWRK1 - reason why reference person did not work during the past 12 months 1 = Retired
#WHYNWRK2 - reason why spouse did not work during the past 12 months 1 = Retired
diaryNonRetiredAgedNEWIDs1 <- fmld141AgeRestricted[which(fmld141AgeRestricted$WHYNWRK1 != 1 | fmld141AgeRestricted$WHYNWRK2 != 1),"NEWID"]
diaryNonRetiredAgedNEWIDs2 <- fmld142AgeRestricted[which(fmld142AgeRestricted$WHYNWRK1 != 1 | fmld142AgeRestricted$WHYNWRK2 != 1),"NEWID"]
diaryNonRetiredAgedNEWIDs3 <- fmld143AgeRestricted[which(fmld143AgeRestricted$WHYNWRK1 != 1 | fmld143AgeRestricted$WHYNWRK2 != 1),"NEWID"]
diaryNonRetiredAgedNEWIDs4 <- fmld144AgeRestricted[which(fmld144AgeRestricted$WHYNWRK1 != 1 | fmld144AgeRestricted$WHYNWRK2 != 1),"NEWID"]
diaryNonRetiredAgedNEWIDs5 <- memd141AgeRestricted[which(memd141AgeRestricted$OCCUEARN != 930),"NEWID"]
diaryNonRetiredAgedNEWIDs6 <- memd142AgeRestricted[which(memd142AgeRestricted$OCCUEARN != 930),"NEWID"]
diaryNonRetiredAgedNEWIDs7 <- memd143AgeRestricted[which(memd143AgeRestricted$OCCUEARN != 930),"NEWID"]
diaryNonRetiredAgedNEWIDs8 <- memd144AgeRestricted[which(memd144AgeRestricted$OCCUEARN != 930),"NEWID"]

#proving that all NEWIDs form the same dataframe type are equal
table(diaryNonRetiredAgedNEWIDs1 %in% diaryNonRetiredAgedNEWIDs2)
table(diaryNonRetiredAgedNEWIDs2 %in% diaryNonRetiredAgedNEWIDs3)
table(diaryNonRetiredAgedNEWIDs3 %in% diaryNonRetiredAgedNEWIDs4)
table(diaryNonRetiredAgedNEWIDs4 %in% diaryNonRetiredAgedNEWIDs1)

table(diaryNonRetiredAgedNEWIDs5 %in% diaryNonRetiredAgedNEWIDs6)
table(diaryNonRetiredAgedNEWIDs6 %in% diaryNonRetiredAgedNEWIDs7)
table(diaryNonRetiredAgedNEWIDs7 %in% diaryNonRetiredAgedNEWIDs8)
table(diaryNonRetiredAgedNEWIDs8 %in% diaryNonRetiredAgedNEWIDs5)

#checking which NEWIDs to use
table(diaryNonRetiredAgedNEWIDs8 %in% diaryNonRetiredAgedNEWIDs1)
table(diaryNonRetiredAgedNEWIDs1 %in% diaryNonRetiredAgedNEWIDs8)

#setting the NEWIDs to subset by
diaryNonRetiredAgeRestrictedNEWIDs <- diaryNonRetiredAgedNEWIDs8

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


interviewNonRetiredAgedNEWIDs1 <- fmli141xAgeRestricted[which(fmli141xAgeRestricted$INCNONW1 != 1 | fmli141xAgeRestricted$INCNONW2 != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs2 <- fmli142AgeRestricted[which(fmli142AgeRestricted$INCNONW1 != 1 | fmli142AgeRestricted$INCNONW2 != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs3 <- fmli143AgeRestricted[which(fmli143AgeRestricted$INCNONW1 != 1 | fmli143AgeRestricted$INCNONW2 != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs4 <- fmli144AgeRestricted[which(fmli144AgeRestricted$INCNONW1 != 1 | fmli144AgeRestricted$INCNONW2 != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs5 <- fmli151AgeRestricted[which(fmli151AgeRestricted$INCNONW1 != 1 | fmli151AgeRestricted$INCNONW2 != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs6 <- memi141xAgeRestricted[which(memi141xAgeRestricted$INCNONWK != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs7 <- memi142AgeRestricted[which(memi142AgeRestricted$INCNONWK != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs8 <- memi143AgeRestricted[which(memi143AgeRestricted$INCNONWK != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs9 <- memi144AgeRestricted[which(memi144AgeRestricted$INCNONWK != 1),"NEWID"]
interviewNonRetiredAgedNEWIDs10 <- memi151AgeRestricted[which(memi151AgeRestricted$INCNONWK != 1),"NEWID"]

table(interviewNonRetiredAgedNEWIDs1 %in% interviewNonRetiredAgedNEWIDs2)
table(interviewNonRetiredAgedNEWIDs2 %in% interviewNonRetiredAgedNEWIDs3)
table(interviewNonRetiredAgedNEWIDs3 %in% interviewNonRetiredAgedNEWIDs4)
table(interviewNonRetiredAgedNEWIDs4 %in% interviewNonRetiredAgedNEWIDs5)
table(interviewNonRetiredAgedNEWIDs5 %in% interviewNonRetiredAgedNEWIDs1)

fmliNonRetiredAgedNEWIDs <- c(interviewNonRetiredAgedNEWIDs1,interviewNonRetiredAgedNEWIDs2,interviewNonRetiredAgedNEWIDs3, interviewNonRetiredAgedNEWIDs4, interviewNonRetiredAgedNEWIDs5)

table(interviewNonRetiredAgedNEWIDs6 %in% interviewNonRetiredAgedNEWIDs7)
table(interviewNonRetiredAgedNEWIDs7 %in% interviewNonRetiredAgedNEWIDs8)
table(interviewNonRetiredAgedNEWIDs8 %in% interviewNonRetiredAgedNEWIDs9)
table(interviewNonRetiredAgedNEWIDs9 %in% interviewNonRetiredAgedNEWIDs10)
table(interviewNonRetiredAgedNEWIDs10 %in% interviewNonRetiredAgedNEWIDs6)

memiNonRetiredAgedNEWIDs <- c(interviewNonRetiredAgedNEWIDs6,interviewNonRetiredAgedNEWIDs7,interviewNonRetiredAgedNEWIDs8, interviewNonRetiredAgedNEWIDs9, interviewNonRetiredAgedNEWIDs10)

table(fmliNonRetiredAgedNEWIDs %in% memiNonRetiredAgedNEWIDs)
table(memiNonRetiredAgedNEWIDs %in% fmliNonRetiredAgedNEWIDs)

interviewNonRetiredAgedNEWIDs <- unique(c(fmliNonRetiredAgedNEWIDs,memiNonRetiredAgedNEWIDs))

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


##############################################################################################################################################
# Code for reference person only
# 
# #Retirement Restriction
# #Diary
# #for both anyone in the CU
# #WHYNWRK1 - reason why reference person did not work during the past 12 months 1 = Retired
# #WHYNWRK2 - reason why spouse did not work during the past 12 months 1 = Retired
# diaryNonRetiredAgedNEWIDs1 <- fmld141AgeRestricted[which(fmld141AgeRestricted$WHYNWRK1 != 1),"NEWID"]
# diaryNonRetiredAgedNEWIDs2 <- fmld142AgeRestricted[which(fmld142AgeRestricted$WHYNWRK1 != 1),"NEWID"]
# diaryNonRetiredAgedNEWIDs3 <- fmld143AgeRestricted[which(fmld143AgeRestricted$WHYNWRK1 != 1),"NEWID"]
# diaryNonRetiredAgedNEWIDs4 <- fmld144AgeRestricted[which(fmld144AgeRestricted$WHYNWRK1 != 1),"NEWID"]
# diaryNonRetiredAgedNEWIDs5 <- memd141AgeRestricted[which(memd141AgeRestricted$OCCUEARN != 930),"NEWID"]
# diaryNonRetiredAgedNEWIDs6 <- memd142AgeRestricted[which(memd142AgeRestricted$OCCUEARN != 930),"NEWID"]
# diaryNonRetiredAgedNEWIDs7 <- memd143AgeRestricted[which(memd143AgeRestricted$OCCUEARN != 930),"NEWID"]
# diaryNonRetiredAgedNEWIDs8 <- memd144AgeRestricted[which(memd144AgeRestricted$OCCUEARN != 930),"NEWID"]
# 
# #proving that all NEWIDs form the same dataframe type are equal
# table(diaryNonRetiredAgedNEWIDs1 %in% diaryNonRetiredAgedNEWIDs2)
# table(diaryNonRetiredAgedNEWIDs2 %in% diaryNonRetiredAgedNEWIDs3)
# table(diaryNonRetiredAgedNEWIDs3 %in% diaryNonRetiredAgedNEWIDs4)
# table(diaryNonRetiredAgedNEWIDs4 %in% diaryNonRetiredAgedNEWIDs1)
# 
# table(diaryNonRetiredAgedNEWIDs5 %in% diaryNonRetiredAgedNEWIDs6)
# table(diaryNonRetiredAgedNEWIDs6 %in% diaryNonRetiredAgedNEWIDs7)
# table(diaryNonRetiredAgedNEWIDs7 %in% diaryNonRetiredAgedNEWIDs8)
# table(diaryNonRetiredAgedNEWIDs8 %in% diaryNonRetiredAgedNEWIDs5)
# 
# #checking which NEWIDs to use
# table(diaryNonRetiredAgedNEWIDs8 %in% diaryNonRetiredAgedNEWIDs1)
# table(diaryNonRetiredAgedNEWIDs1 %in% diaryNonRetiredAgedNEWIDs8)
# 
# #setting the NEWIDs to subset by
# diaryNonRetiredAgeRestrictedNEWIDs <- diaryNonRetiredAgedNEWIDs8
# 
# fmld141DoubleRestricted <- fmld141AgeRestricted[which(fmld141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# fmld142DoubleRestricted <- fmld142AgeRestricted[which(fmld142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# fmld143DoubleRestricted <- fmld143AgeRestricted[which(fmld143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# fmld144DoubleRestricted <- fmld144AgeRestricted[which(fmld144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# 
# memd141DoubleRestricted <- memd141AgeRestricted[which(memd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# memd142DoubleRestricted <- memd142AgeRestricted[which(memd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# memd143DoubleRestricted <- memd143AgeRestricted[which(memd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# memd144DoubleRestricted <- memd144AgeRestricted[which(memd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# 
# expd141DoubleRestricted <- expd141AgeRestricted[which(expd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #Below are files that were not applicable to the ageRestricting
# # expd142DoubleRestricted <- expd142AgeRestricted[which(expd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # expd143DoubleRestricted <- expd143AgeRestricted[which(expd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # expd144DoubleRestricted <- expd144AgeRestricted[which(expd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #**************************************************************************************************************************
# 
# dtbd141DoubleRestricted <- dtbd141AgeRestricted[which(dtbd141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #Below are files that were not applicable to the ageRestricting
# # dtbd142DoubleRestricted <- dtbd142AgeRestricted[which(dtbd142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # dtbd143DoubleRestricted <- dtbd143AgeRestricted[which(dtbd143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # dtbd144DoubleRestricted <- dtbd144AgeRestricted[which(dtbd144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #**************************************************************************************************************************
# 
# dtid141DoubleRestricted <- dtid141AgeRestricted[which(dtid141AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #Below are files that were not applicable to the ageRestricting
# # dtid142DoubleRestricted <- dtid142AgeRestricted[which(dtid142AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # dtid143DoubleRestricted <- dtid143AgeRestricted[which(dtid143AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # dtid144DoubleRestricted <- dtid144AgeRestricted[which(dtid144AgeRestricted$NEWID %in% diaryNonRetiredAgeRestrictedNEWIDs),]
# # #**************************************************************************************************************************

