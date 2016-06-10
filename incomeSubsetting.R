#The location of the cloned github repo on your machine
#ex. "~/Documents/SuperCool/Retirement-Expenses
directoryOfRepo <- "~/Documents/Retirement-Expenses"
setwd(directoryOfRepo)

#Removes everything in the environment and re runs the age and retirement restricing process
#!!!TAKES A LONG TIME DO NOT RUN UNLESS NECESSARY!!!
source('retirement-AgeRestricting.R', echo=TRUE)

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
diaryBracket2NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint2 & dtbd141DoubleRestricted$AMOUNT > breakpoint1))]
diaryBracket3NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint3 & dtbd141DoubleRestricted$AMOUNT > breakpoint2))]
diaryBracket4NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint4 & dtbd141DoubleRestricted$AMOUNT > breakpoint3))]
diaryBracket5NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint5 & dtbd141DoubleRestricted$AMOUNT > breakpoint4))]
diaryBracket6NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint6 & dtbd141DoubleRestricted$AMOUNT > breakpoint5))]
diaryBracket7NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint7 & dtbd141DoubleRestricted$AMOUNT > breakpoint6))]
diaryBracket8NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint8 & dtbd141DoubleRestricted$AMOUNT > breakpoint7))]
diaryBracket9NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint9 & dtbd141DoubleRestricted$AMOUNT > breakpoint8))]
diaryBracket10NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & (dtbd141DoubleRestricted$AMOUNT <= breakpoint10 & dtbd141DoubleRestricted$AMOUNT > breakpoint9))]
diaryBracket11NEWIDs <- dtbd141DoubleRestricted$NEWID[which(dtbd141DoubleRestricted$UCC == correctUccCode & dtbd141DoubleRestricted$AMOUNT > breakpoint10)]

#vector containing all incomes before taxes in the diary files
diaryIncomeVector <- dtbd141DoubleRestricted$AMOUNT[which(dtbd141DoubleRestricted$UCC == correctUccCode)]

#Quantitative and qualitative analysis of whole sample
hist(diaryIncomeVector,breaks = 100, probability = TRUE, main = "Income Distribution of Diary Sample", xlab = "Annual Income", yaxt='n',col="seagreen1")
lines(density(diaryIncomeVector, adjust = 1),lwd=2, col = "deeppink")
lines(density(diaryIncomeVector, adjust = 2),lwd=2, col = "purple")
lines(density(diaryIncomeVector, adjust = 3),lwd=2)
summary(diaryIncomeVector)

#Creating income vectors for brackets
bracket1IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket1NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket2IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket2NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket3IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket3NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket4IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket4NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket5IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket5NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket6IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket6NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket7IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket7NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket8IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket8NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket9IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket9NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket10IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket10NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]
bracket11IncomeVector <- dtbd141DoubleRestricted[which(dtbd141DoubleRestricted$NEWID %in% diaryBracket11NEWIDs & dtbd141DoubleRestricted$UCC == correctUccCode),"AMOUNT"]

#Analysis of brackets
hist(bracket1IncomeVector, breaks = 50)
summary(bracket1IncomeVector)

hist(bracket2IncomeVector, breaks = 50)
summary(bracket2IncomeVector)

hist(bracket3IncomeVector, breaks = 50)
summary(bracket3IncomeVector)

hist(bracket4IncomeVector, breaks = 50)
summary(bracket4IncomeVector)

hist(bracket5IncomeVector, breaks = 50)
summary(bracket5IncomeVector)

hist(bracket6IncomeVector, breaks = 50)
summary(bracket6IncomeVector)

hist(bracket7IncomeVector, breaks = 50)
summary(bracket7IncomeVector)

hist(bracket8IncomeVector, breaks = 50)
summary(bracket8IncomeVector)

hist(bracket9IncomeVector, breaks = 50)
summary(bracket9IncomeVector)

hist(bracket10IncomeVector, breaks = 50)
summary(bracket10IncomeVector)

hist(bracket11IncomeVector, breaks = 50)
summary(bracket11IncomeVector)

###Interview

#The problem with itii files min < 0
min(itii141xDoubleRestricted[which(itii141xDoubleRestricted$UCC==980000),"VALUE"])

##creating the incomem column
#for each NEWID
for(x in 1:length(unique(itii141xDoubleRestricted$NEWID))){
  for(y in 1:length(itii141xDoubleRestricted))
}