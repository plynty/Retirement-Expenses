#The location of the cloned github repo on your machine
#ex. "~/Documents/SuperCool/Retirement-Expenses
directoryOfRepo <- "~/Documents/Retirement-Expenses"
setwd(directoryOfRepo)


#Loading the original Diary files

fmld141 <- read.csv("diary14/fmld141.csv", stringsAsFactors=FALSE)
fmld142 <- read.csv("diary14/fmld142.csv", stringsAsFactors=FALSE)
fmld143 <- read.csv("diary14/fmld143.csv", stringsAsFactors=FALSE)
fmld144 <- read.csv("diary14/fmld144.csv", stringsAsFactors=FALSE)

memd141 <- read.csv("diary14/memd141.csv", stringsAsFactors=FALSE)
memd142 <- read.csv("diary14/memd142.csv", stringsAsFactors=FALSE)
memd143 <- read.csv("diary14/memd143.csv", stringsAsFactors=FALSE)
memd144 <- read.csv("diary14/memd144.csv", stringsAsFactors=FALSE)

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

#Loading the original Interview files

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

save(fmld141,fmld142,fmld143,fmld144,memd141,memd142,memd143,memd144,expd141,expd142,expd143,expd144,dtbd141,dtbd142,dtbd143,dtbd144,dtid141,dtid142,dtid143,dtid144, file = "originalDiaryDataframes.RData")
save(fmli141x,fmli142,fmli143,fmli144,fmli151,memi141x,memi142,memi143,memi144,memi151,mtbi141x,mtbi142,mtbi143,mtbi144,mtbi151,itbi141x,itbi142,itbi143,itbi144,itbi151,itii141x,itii142,itii143,itii144,itii151, file = "originalInterviewDataframes.RData")