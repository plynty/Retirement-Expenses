#Removes everything in the environment and re runs the age and retirement restricing process
#!!!TAKES A LONG TIME DO NOT RUN UNLESS NECESSARY!!!
source('~/Documents/Retirement-Expenses/retirement-AgeRestricting.R', echo=TRUE)

#setting the incomebrackets
breakpoint1 <- 20000
breakpoint2 <- 30000
breakpoint3 <- 50000
breakpoint4 <- 75000
breakpoint5 <- 100000
breakpoint6 <- 135000
breakpoint7 <- 175000
breakpoint8 <- 225000
breakpoint9 <- 300000
breakpoint10 <- 750000

###Diary

#potential codes that could be used for income
uccCodes <- c(900000,900010,900020,900040,900060,980000)

#proving that all people in our subset make some income
table(unique(dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC %in% uccCodes)]) %in% unique(dtbd141DoubleRestricted$NEWID))
table(unique(dtbd141DoubleRestricted$NEWID) %in% unique(dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC %in% uccCodes)]))

#proving every person reports an income before taxes the UCC code that applies to income is 980000
length(unique(dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == 980000)]))==length(unique(dtbd141DoubleRestricted$NEWID))

#checking for people who have pensions
which(dtbd141DoubleRestricted$UCC == 900040)

#all UCC codes involving income are added together into the "income before taxes" UCC code
correctUccCode <- 980000

diaryBracket1NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint1)]
diaryBracket2NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint2 & dtbd141DoubleRestricted$AMOUNT > breakpoint1)]
diaryBracket3NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint3 & dtbd141DoubleRestricted$AMOUNT > breakpoint2)]
diaryBracket4NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint4 & dtbd141DoubleRestricted$AMOUNT > breakpoint3)]
diaryBracket5NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint5 & dtbd141DoubleRestricted$AMOUNT > breakpoint4)]
diaryBracket6NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint6 & dtbd141DoubleRestricted$AMOUNT > breakpoint5)]
diaryBracket7NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint7 & dtbd141DoubleRestricted$AMOUNT > breakpoint6)]
diaryBracket8NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint8 & dtbd141DoubleRestricted$AMOUNT > breakpoint7)]
diaryBracket9NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint9 & dtbd141DoubleRestricted$AMOUNT > breakpoint8)]
diaryBracket10NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT <= breakpoint10 & dtbd141DoubleRestricted$AMOUNT > breakpoint9)]
diaryBracket11NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT > breakpoint10)]

#vector containing all incomes before taxes in the diary files
diaryIncomeVector <- dtbd141DoubleRestricted$AMOUNT[which(dtbd141DoubleRestricted$UCC == correctUccCode)]

#Quantitative and qualitative analysis
hist(diaryIncomeVector,breaks = 100)
mean(diaryIncomeVector)
median(diaryIncomeVector)


#Interview