###############################################################################
###############################################################################
# Program Name: CE Integrated Surveys Sample Program (R)                      #
# Purpose: Create an integrated survey expenditure table by income class      #
#          using microdata from the Bureau of Labor Statistics' Consumer      #
#          Expenditure Survey.                                                #
#                                                                             #
# Written By: Bureau of Labor Statistics            August 2014               #
#                                                                             #
# Many thanks to Anthony Damico whose publicly available R script contributed #
# largely to this script. His original script can be found at                 #
# http://www.asdfree.com/search/label/consumer expenditure survey %28ce%29    #
#                                                                             #
# Note: Written in R Version 3.1.1                                            #
#                                                                             #
# Data and input files used in this sample program were unzipped or copied to #
# the locations below:                                                        #
#                                                                             #
# Interview data -- "C:\CE_PUMD\2014\intrvw                                   #
# Diary data -- "C:\CE_PUMD\2014\diary                                        #
# IntStub2014.txt -- "C:\CE_PUMD\2014\documentation                           #
#                                                                             #
###############################################################################
###############################################################################

### Parameters to fill out before running the R script
# Assign a variable for the year for which data will be tabulated
year <- 2014

# Assign a variable for the root directory
mydir <- "/Users/tndambakuwa/Retirement-Expenses"

#create new income brackets
incomeBreakpoints <- c(-Inf,0,5000,25000,50000,75000,100000,150000,250000)

# Create age range
maxAge <- 64
minAge <- 55

# Create boolean that says to exclude retired CUs or not
excludeRetired <- FALSE

# Create boolean that determines if the R script will create a csv of the tab.out dataframe 
createTabOutCSV <- FALSE

###############################################################################
# Note: The below code converts required files from ".csv" to ".Rda". Comment #
# it out if your files are already in ".Rda format                            #
###############################################################################

# ########################## Start conversion code ##############################
# 
# # Save the names of the folders with the files to convert
# folders <- c("intrvw", "diary")
# 
# # Save the names of the vectors of files type from the interview and diary
# types <- c("i.types", "d.types")
# 
# # Save the names of interview file types to convert in a vector
# i.types <- c("fmli", "itbi", "mtbi")
# 
# # Save the names of diary file types to convert in a vector
# d.types <- c("dtbd", "expd", "fmld")
# 
# #!# Converting files into Rda files
# 
# # loop through the folder names, set each as the working directory, and select
# # the required files to save as ".Rda"
# for(f in 1:2){
#   setwd(paste0(mydir, "/", year, "/", folders[f]))
#   csvfiles <- dir(pattern=".csv")
#   
#   for(t in get(types[f])){
#     files2convert <- csvfiles[grep(t, csvfiles)]
#     
#     for(p in files2convert){
#       dfname <- unlist(strsplit(p, "[.]"))[1]
#       rfname <- paste0(dfname, ".Rda")
#       assign(dfname, read.csv(p, header=TRUE))
#       save(list=dfname, file=rfname)
#     }
#   }
# }
# 
# ########################### End conversion code ###############################
# ###############################################################################

# set the working directory to the path saved above
setwd( mydir )

# turn off scientific notation in most output
options( scipen = 20 )

# create a vector of the names of required packages
reqPkgs <- c( "stringr" , "reshape2" , "sqldf" , "RSQLite" , "plyr" )

# loop through the vector of package names
for(pkg in reqPkgs){
  
  # check whether a package has been installed
  if(!(pkg %in% rownames(installed.packages()))){
    
    # install it if not yet installed
    install.packages(pkg)
  } 
}

library(stringr) 	# load stringr package (manipulates character strings easily)
library(reshape2)	# load reshape2 package (transposes data frames quickly)
library(sqldf)		# load the sqldf package (enables sql queries on data frames)
library(RSQLite) 	# load RSQLite package (creates database files in R)
library(plyr); library(dplyr)     # load plyr package (manipulates databases easily in R)





############################################
# no need to edit anything below this line #

# # # # # # # # #
# program start #
# # # # # # # # #

# create vector of ages between the max and min age
ageRange <- seq(minAge,maxAge)

incomeBreakpoints <- sort(incomeBreakpoints)

# pull the last two digits of the year variable into a separate string
yr <- substr( year , 3 , 4 )


# create a new function that reads in quarterly R data files (.rda)
read.in.qs <- 
	function( 
		# define the function parameters..
		filestart , 	# the start of the filename (skipping year, quarter, and any x's)
		filefolder , 	# the path within the current working directory
		four 			# does this file type contain four quarterly files, or five?  set TRUE for four, FALSE for five.
	){
	
	# if there are four quarterly files to read in..
	if ( four ){

		# load all four
		
		load( paste0( "./" , filefolder , "/" , filestart , yr , "1.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "2.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "3.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "4.rda" ) )

		# stack them on top of each other into a new data frame called x
		x <- rbind.fill( 
			get( paste0( filestart , yr , "1" ) ) ,
			get( paste0( filestart , yr , "2" ) ) ,
			get( paste0( filestart , yr , "3" ) ) ,
			get( paste0( filestart , yr , "4" ) ) 
		)
		
	} else {

		# load all five
		
		# note the first will contain an x in the filename
		load( paste0( "./" , filefolder , "/" , filestart , yr , "1x.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "2.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "3.rda" ) )
		load( paste0( "./" , filefolder , "/" , filestart , yr , "4.rda" ) )
		# note the fifth will be from the following year's first quarter
		load( paste0( "./" , filefolder , "/" , filestart , as.numeric( yr ) + 1 , "1.rda" ) )

		# stack them on top of each other into a new data frame called x
		x <- 
			rbind.fill( 
				get( paste0( filestart , yr , "1x" ) ) ,
				get( paste0( filestart , yr , "2" ) ) ,
				get( paste0( filestart , yr , "3" ) ) ,
				get( paste0( filestart , yr , "4" ) ) ,
				get( paste0( filestart , as.numeric( yr ) + 1 , "1" ) )
			)
			
	}

	# return the four or five combined data frames
	# as a single, stacked data frame
	x
	}

# creating a function that will return an Income class vector based on a vector of income braket breakpoints
# income class 0 is individuals making less than 0 dollars
getINCLASSvector <- function(incomes,breakpoints){
  breakpoints <- sort(breakpoints)
  inClasses <- vector()
  for(i in 1:length(incomes)){
    for(x in length(breakpoints):1){
      if(incomes[i]>=breakpoints[x]){
        inClasses <- c(inClasses,x-1)
        break
      }
    }
  }
  return(inClasses)
}



# alter the current working directory to include the current analysis year
# ..instead of "C:/My Directory/CE/" use "C:/My Directory/CE/2014"
setwd( paste( mydir , year , sep = "/" ) )


# designate a temporary file to store a temporary database
temp.db <- tempfile()


# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP1: READ IN THE STUB PARAMETER FILE AND CREATE FORMATS               */
  # /* ----------------------------------------------------------------------- */
  # /* 1 CONVERTS THE STUB PARAMETER FILE INTO A LABEL FILE FOR OUTPUT         */
  # /* 2 CONVERTS THE STUB PARAMETER FILE INTO AN EXPENDITURE AGGREGATION FILE */
  # /* 3 CREATES FORMATS FOR USE IN OTHER PROCEDURES                           */
  # /***************************************************************************/


# find the filepath to the IntStubYYYY.txt file
sf <- paste0(mydir, "/", year, "/docs/Programs/Intstub", year, ".txt")

# create a temporary file on the local disk..
tf <- tempfile()

# read the IntStubYYYY.txt file into memory
# in order to make a few edits
st <- readLines( sf )

# only keep rows starting with a one
st <- st[ substr( st , 1 , 1 ) == '1' ]

# replace these two tabs with seven spaces instead
st <- gsub( "\t\t" , "       " , st )

# save to the temporary file created above
writeLines( st , tf )

# read that temporary file (the slightly modified IntStubYYYY.txt file)
# into memory as an R data frame
stubfile <- 
	read.fwf( 
		tf , 
		width = c( 1 , -2 , 1 , -2 , 60 , -3 , 6 , -7 , 1 , -5 , 7 ) ,
		col.names = c( "type" , "level" , "title" , "UCC" , "survey" , "group" )
	)

# eliminate all whitespace (on both sides) in the group column
stubfile$group <- str_trim( as.character( stubfile$group ) )
	
# subset the stubfile to only contain records
# a) in the four groups below
# b) where the survey column isn't "T"
stubfile <- 
	subset( 
		stubfile , 
		group %in% c( "CUCHARS" , "FOOD" , "EXPEND" , "INCOME") &
		survey != "T"
	)

# remove the rownames from the stubfile
# (after subsetting, rows maintain their original numbering.
# this action wipes it out.)
rownames( stubfile ) <- NULL

# create a new count variable starting at 10,000
stubfile$count <- 9999 + ( 1:nrow( stubfile ) )

# create a new line variable by concatenating the count and level variables
stubfile$line <- paste0( stubfile$count , stubfile$level )


# start with a character vector with ten blank strings..
curlines <- rep( "" , 10 )

# initiate a matrix containing the line numbers of each expenditure category
aggfmt1 <- matrix( nrow = nrow( stubfile ) , ncol = 10 )

# loop through each record in the stubfile..
for ( i in seq( nrow( stubfile ) ) ){

	# if the 'UCC' variable is numeric (that is, as.numeric() does not return a missing NA value)
	if ( !is.na( as.numeric( as.character( stubfile[ i , "UCC" ] ) ) ) ){
		
		# save the line number as the last element in the character vector
		curlines[ 10 ] <- stubfile[ i , "line" ]
	
	# otherwise blank it out
	} else curlines[ 10 ] <- ""

	# store the current line and level in separate atomic variables
	curlevel <- stubfile[ i , "level" ]
	curline <- stubfile[ i , "line" ]

	# write the current line inside the length-ten character vector
	curlines[ curlevel ] <- curline
	
	# if the current level is 1-8, blank out everything above it up to nine
	if ( curlevel < 9 ) curlines[ (curlevel+1):9 ] <- ""

	# remove actual value
	savelines <- curlines
	savelines[ curlevel ] <- ""
	
	# overwrite the entire row with the character vector of length ten
	aggfmt1[ i , ] <- savelines
}

# convert the matrix to a data frame..
aggfmt1 <- data.frame( aggfmt1 )

# ..and name its columns line1 - line10
names( aggfmt1 ) <- paste0( "line" , 1:10 )

# tack on the UCC and line columns from the stubfile (which has the same number of records)
aggfmt1 <- cbind( aggfmt1 , stubfile[ , c( "UCC" , "line" ) ] )

# remove records where the UCC is not numeric
aggfmt1 <- subset( aggfmt1 , !is.na( as.numeric( as.character( UCC ) ) ) )

# order the data frame by UCC
aggfmt1 <- aggfmt1[ order( aggfmt1$UCC ) , ]

# rename line to compare
aggfmt1$compare <- aggfmt1$line
aggfmt1$line <- NULL

# reset the row names/numbers
rownames( aggfmt1 ) <- NULL

# transpose the data, holding UCC and compare
aggfmt2 <- melt(aggfmt1, id=c("UCC","compare")) 
names( aggfmt2 )[ 4 ] <- "line"

# retain the UCC-to-line crosswalk wherever the 'line' variable is not blank
aggfmt <- subset( aggfmt2 , line != "" , select = c( "UCC" , "line" ) )

# re-order the data frame by UCC
aggfmt <- aggfmt[ order( aggfmt$UCC ) , ]


# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP2: READ IN ALL NEEDED DATA                                          */
  # /* ----------------------------------------------------------------------- */
  # /* 1 READ IN THE INTERVIEW AND DIARY FMLY FILES & CREATE MO_SCOPE VARIABLE */
  # /* 2 READ IN THE INTERVIEW MTAB/ITAB AND DIARY EXPN/DTAB FILES             */
  # /* 3 MERGE FMLY AND EXPENDITURE FILES TO DERIVE WEIGHTED EXPENDITURES      */
  # /***************************************************************************/


# use the read.in.qs (read-in-quarters) function (defined above)
# to read in the four 'fmld' files in the diary folder
# this contains all family diary records
d <- read.in.qs( "fmld" , "diary" , TRUE )

# creating custom income classes
d$INCLASS <- getINCLASSvector(d$FINCBEFM, incomeBreakpoints)

# create age restriction
d <- d[which(d$AGE_REF %in% minAge:maxAge),]

# Determine if Retired CUs should be excluded
if(excludeRetired){
  # Exclude Retired CUs
  d <- d[which(d$WHYNWRK1 != 1),]
}

# clear up RAM
gc()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# read in the five quarters of family data files (fmli)
# perform this by hand (as opposed to with the read.in.qs() function)
# because of the large number of exceptions for these five files

# load all five R data files (.rda)
load( paste0( "./intrvw/fmli" , yr , "1x.rda" ) )
load( paste0( "./intrvw/fmli" , yr , "2.rda" ) )
load( paste0( "./intrvw/fmli" , yr , "3.rda" ) )
load( paste0( "./intrvw/fmli" , yr , "4.rda" ) )
load( paste0( "./intrvw/fmli" , as.numeric( yr ) + 1 , "1.rda" ) )

# copy the fmliYY1x data frame to another data frame 'x'
x <- get( paste0( "fmli" , yr , "1x" ) )

# create an 'high_edu' column containing all missings
x$HIGH_EDU<- NA

# add a quarter variable
x$qtr <- 1

# copy the x data frame to a third data frame 'fmli1'
assign( "fmli1" , x )

# loop through the second, third, and fourth fmli data frames
for ( i in 2:4 ){

	x <- get( paste0( "fmli" , yr , i ) )

	# add a quarter variable (2, 3, then 4)
	x$qtr <- i
	
	# copy the data frame over to fmli#
	assign( paste0( "fmli" , i ) , x )
}

# repeat the steps above on the fifth quarter (which uses the following year's first quarter of data)
x <- get( paste0( "fmli" , as.numeric( yr ) + 1 , "1" ) )

#add quarter variable
x$qtr <- 5
assign( "fmli5" , x )

# stack all five fmli# files together, into a large single data frame 'f'
f <- rbind.fill( fmli1 , fmli2 , fmli3 , fmli4 , fmli5 )

# delete all of the independent data frames from memory
rm( fmli1 , fmli2 , fmli3 , fmli4 , fmli5 , x )

# also delete the data frames loaded by the five load() function calls above
rm( 
	list = 
		c( 
			paste0( "fmli" , yr , "1x" ) , 
			paste0( "fmli" , yr , 2:4 ) ,
			paste0( "fmli" , as.numeric( yr ) + 1 , "1" )
		)
)

# add custom income classes to f
f$INCLASS <- getINCLASSvector(f$FINCBTXM,incomeBreakpoints)

# create age restriction
f <- f[which(f$AGE_REF %in% minAge:maxAge),]

if(excludeRetired){
  f <- f[which(f$INCNONW1 != 1),]
}

# clear up RAM
gc()

# create a mo_scope variable in this large new family data frame

f <- 
	transform( 
		f ,
		mo_scope = 
			# the first quarter should be interview month minus one
			ifelse( qtr %in% 1 , as.numeric( QINTRVMO ) - 1 ,
			# the final quarter should be four minus the interview month
			ifelse( qtr %in% 5 , ( 4 - as.numeric( QINTRVMO )  ) ,
			# all other quarters should have a 3
				3 ) ) 
	)

# the source column for family records should be "I" (interview) throughout
f$src <- "I"
	
# the mo_scope variable for the 'd' (fmld) data frame should be 3 for all records
d$mo_scope <- 3
# ..and the source should be "D" throughout
d$src <- "D"

# create a character vector containing 45 variable names (wtrep01, wtrep02, ... wtrep44 and finlwt21)
wtrep <- c( paste0( "WTREP" , str_pad( 1:44 , 2 , pad = "0" ) ) , "FINLWT21" )

# create a second character vector containing 45 variable names (repwt1, repwt2, .. repwt44, repwt45)
repwt <- paste0( "repwt" , 1:45 )

# create a third character vector that will be used to define which columns to keep
f.d.vars <- c( wtrep , "mo_scope" , "INCLASS" , "NEWID" , "src" )

# stack the family interview and diary records together,
# keeping only the 45 wtrep columns, plus the additional four written above
fmly <- rbind( f[ , f.d.vars ] , d[ , f.d.vars ] )

# remove data frames 'f' and 'd' from memory
rm( f , d )

# clear up RAM
gc()


# loop through the 45 wtrep variables in the newly-stacked fmly data frame..
for ( i in 1:45 ){

	# convert all columns to numeric
	fmly[ , wtrep[ i ] ] <- as.numeric( as.character( fmly[ , wtrep[ i ] ] ) )
	
	# replace all missings with zeroes
	fmly[ is.na( fmly[ , wtrep[ i ] ] ) , wtrep[ i ] ] <- 0
	
	# multiply by months in scope, then divide by 12 (months)
	fmly[ , repwt[ i ] ] <- ( fmly[ , wtrep[ i ] ] * fmly[ , "mo_scope" ] / 12 )
}


# read in the expenditure files..
expd <- read.in.qs( "expd" , "diary" , TRUE )
dtbd <- read.in.qs( "dtbd" , "diary" , TRUE )
mtbi <- read.in.qs( "mtbi" , "intrvw" , FALSE )
itbi <- read.in.qs( "itbi" , "intrvw" , FALSE )

# clear up RAM
gc()

# copy (effectively rename) the 'amount' and 'value' columns to 'COST'
dtbd$COST <- dtbd$AMOUNT
itbi$COST <- itbi$VALUE

# limit the itbi and mtbi (interview) data frames to records from the current year with pubflags of two
expend.itbi <- subset( itbi , PUBFLAG == 2 & REFYR == year )
expend.mtbi <- subset( mtbi , PUBFLAG == 2 & REF_YR == year )

# choose which columns to keep when stacking these data frames
edmi.vars <- c( "NEWID" , "UCC" , "COST" )

# stack the itbi and mtbi files
expend.im <- 
	rbind( 
		expend.itbi[ , edmi.vars ] , 
		expend.mtbi[ , edmi.vars ] 
	)

# create a new 'source' column, with "I" (interview) throughout
expend.im$src <- "I"

# multiply the 'COST' column by 4 whenever the UCC code is 710110
expend.im <- 
	transform( 
		expend.im , 
		COST = ifelse( UCC == '710110' , COST * 4 , COST )
	)
	
# limit the expenditure diary to the same short list of variables, and only with a pubflag of two
expend.expd <- subset( expd , PUB_FLAG == 2 , select = edmi.vars )

# create a new 'source' column, with "D" (diary) throughout
expend.expd$src <- "D"

# multiply the diary records' COST column by 13
expend.expd$COST <- expend.expd$COST * 13

# stack the interview and diary expenditure records together
expend <- rbind( expend.im , expend.expd )

# add leading zeroes to UCC's to ensure proper format
expend$UCC <- str_pad(expend$UCC, 6, pad="0")

# remove all of these smaller R data frames from memory
rm( itbi , mtbi , expend.itbi , expend.mtbi , expend.im , expend.expd )

# clear up RAM
gc()

# order the expenditure data frame by the unique consumer unit id (NEWID)
expend <- expend[ order( expend$NEWID ) , ]

# note: merging the family and expenditure files will overload RAM on smaller machines
# therefore, the following database (db) commands use sql to avoid memory issues

# create a new connection to the temporary database file (defined above)
db <- dbConnect( SQLite() , temp.db )

# store the family data frame in that database
dbWriteTable( db , 'fmly' , fmly , row.names = FALSE )

# create an index on the fmly table to drastically speed up future queries
dbSendQuery( db , "CREATE INDEX nsf ON fmly ( NEWID , src )" )

# store the expenditure data frame in that database as well
dbWriteTable( db , 'expend' , expend , row.names = FALSE )

# create an index on the expend table to drastically speed up future queries
dbSendQuery( db , "CREATE INDEX nse ON expend ( NEWID , src )" )

# create a character vector rcost1 - rcost45
rcost <- paste0( "rcost" , 1:45 )

# partially build the sql string, multiply each 'wtrep##' variable by 'COST' and rename it 'rcost##'
wtrep.cost <- paste0( "( b.COST * a." , wtrep , " ) as " , rcost , collapse = ", " )

# build the entire sql string..
sql.line <- 
	paste( 
		# creating a new 'pubfile' table, saving a few columns from each table
		"create table pubfile as select a.NEWID , a.INCLASS , b.src , b.UCC ," ,
		wtrep.cost ,
		# joining the family and expenditure tables on two fields
		"from fmly as a inner join expend as b on a.NEWID = b.NEWID AND a.src = b.src" 
	)

# execute that sql query
dbSendQuery( 
	db , 
	sql.line
)
  
# create an index on the pubfile table to drastically speed up future queries
dbSendQuery( db , "CREATE INDEX isu ON pubfile ( INCLASS , src , UCC )" )


# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP3: CALCULATE POPULATIONS                                            */
  # /* ----------------------------------------------------------------------- */
  # /*  SUM ALL 45 WEIGHT VARIABLES TO DERIVE REPLICATE POPULATIONS            */
  # /*  FORMATS FOR CORRECT COLUMN CLASSIFICATIONS                             */
  # /***************************************************************************/


# create a character vector containing 45 variable names (rpop1, rpop2, ... rpop44, rpop45)
rpop <- paste0( "rpop" , 1:45 )

# partially build the sql string, sum each 'repwt##' variable into 'rpop##'
rpop.sums <- paste( "sum( " , repwt , ") as " , rpop , collapse = ", " )

# partially build the sql string, sum each 'rcost##' variable into the same column name, 'rcost##'
rcost.sums <- paste( "sum( " , rcost , ") as " , rcost , collapse = ", " )

# create a total population sum (not grouping by 'INCLASS' -- instead assigning everyone to '99')
pop.all <- dbGetQuery( db , paste( "select 99 as INCLASS, src, " , rpop.sums , "from fmly group by src" ) )

# create a population sum, grouped by INCLASS (the income class variable)
pop.by <- dbGetQuery( db , paste( "select INCLASS, src," , rpop.sums , "from fmly group by INCLASS, src" ) )

# stack the overall and grouped-by population tables
pop <- rbind( pop.all , pop.by )


# notes from the "Integrated Mean and SE.sas" file about this section: 
  # /***************************************************************************/
  # /* STEP4: CALCULATE WEIGHTED AGGREGATE EXPENDITURES                        */
  # /* ----------------------------------------------------------------------- */
  # /*  SUM THE 45 REPLICATE WEIGHTED EXPENDITURES TO DERIVE AGGREGATES/UCC    */
  # /*  FORMATS FOR CORRECT COLUMN CLASSIFICATIONS                             */
  # /***************************************************************************/

  
# create the right hand side of the aggregate expenditures table
aggright <-
	# use a sql query from the temporary database (.db) file
	dbGetQuery( 
		db , 
		paste( 
			# group by INCLASS (income class) and a few other variables
			"select INCLASS, src, UCC," , 
			rcost.sums , 
			"from pubfile group by src , INCLASS , UCC" ,
			# the 'union' command stacks the grouped data (above) with the overall data (below)
			"union" ,
			# do not group by INCLASS, instead assign everyone as an INCLASS of ninety nine
			"select '99' as INCLASS, src , UCC," , 
			rcost.sums , 
			"from pubfile group by src , UCC" 
		)
	)

# disconnect from the temporary database (.db) file
dbDisconnect( db )

# delete that temporary database file from the local disk
file.remove( temp.db )

# create three character vectors containing every combination of..

# the expenditure table's source variable
so <- names( table( expend$src ) )
# the expenditure table's UCC variable
uc <- names( table( expend$UCC ) )
# the family table's INCLASS (income class) variable
cl <- names( table( fmly[ , 'INCLASS' ] ) )
# add a '99' - overall category to the INCLASS variable
cl <- c( cl , "99" )

# now create a data frame containing every combination of every variable in the above three vectors
# (this matches the 'COMPLETETYPES' option in a sas proc summary call
aggleft <- expand.grid( so , uc , cl )

# name the columns in this new data frame appropriately
names( aggleft ) <- c( 'src' , 'UCC' , 'INCLASS' )

# perform a left-join, keeping all records in the left hand side, even ones without a match
agg <- merge( aggleft , aggright , all.x = TRUE )


# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP5: CALCULTATE MEAN EXPENDITURES                                     */
  # /* ----------------------------------------------------------------------- */
  # /* 1 READ IN POPULATIONS AND LOAD INTO MEMORY USING A 3 DIMENSIONAL ARRAY  */
  # /*   POPULATIONS ARE ASSOCIATED BY INCLASS, SOURCE(t), AND REPLICATE(j)    */
  # /* 2 READ IN AGGREGATE EXPENDITURES FROM AGG DATASET                       */
  # /* 3 CALCULATE MEANS BY DIVIDING AGGREGATES BY CORRECT SOURCE POPULATIONS  */
  # /*   EXPENDITURES SOURCED FROM DIARY ARE CALULATED USING DIARY POPULATIONS */
  # /*   WHILE INTRVIEW EXPENDITURES USE INTERVIEW POPULATIONS                 */
  # /* 4 SUM EXPENDITURE MEANS PER UCC INTO CORRECT LINE ITEM AGGREGATIONS     */
  # /***************************************************************************/

# create a character vector containing mean1, mean2, ... , mean45
means <- paste0( "mean" , 1:45 )

# merge the population and weighted aggregate data tables together
avgs1 <- merge( pop , agg )

# loop through all 45 weights..
for ( i in 1:45 ){
	# calculate the new 'mean##' variable by dividing the expenditure (rcost##) by the population (rpop##) variables
	avgs1[ , means[ i ] ] <- ( avgs1[ , rcost[ i ] ] / avgs1[ , rpop[ i ] ] )
	
	# convert all missing (NA) mean values to zeroes
	avgs1[ is.na( avgs1[ , means[ i ] ] ) , means[ i ] ] <- 0
}

# keep only a few columns, plus the 45 'mean##' columns
avgs1 <- avgs1[ , c( "src" , "INCLASS" , "UCC" , means ) ]

# partially build the sql string, sum each 'mean##' variable into the same column name, 'mean##'
avgs.sums <- paste( "sum( " , means , ") as " , means , collapse = ", " )

# merge on the 'line' column from the 'aggfmt' data frame
avgs3 <- merge( avgs1 , aggfmt )

# remove duplicate records from the data frame
avgs3 <- sqldf( 'select distinct * from avgs3' )

# construct the full sql string, grouping each sum by INCLASS (income class) and line (expenditure category)
sql.avgs <- paste( "select INCLASS, line," , avgs.sums , "from avgs3 group by INCLASS, line" )

# execute the sql string
avgs2 <- sqldf( sql.avgs )

##################################################################################################################################

# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP6: CALCULTATE STANDARD ERRORS                                       */
  # /* ----------------------------------------------------------------------- */
  # /*  CALCULATE STANDARD ERRORS USING REPLICATE FORMULA                      */
  # /***************************************************************************/

# copy the avgs2 table over to a new data frame named 'se'
se <- avgs2

# create a character vector containing 44 strings, diff1, diff2, .. diff44
diffs <- paste0( "diff" , 1:44 )

# loop through the numbers 1-44, and calculate the diff column as the square of the difference between the current mean and the 45th mean
for ( i in 1:44 ) se[ , diffs[ i ] ] <- ( se[ , means[ i ] ] - se[ , "mean45" ] )^2
# for example, when i is 30, diff30 = ( mean30 - mean45 )^2

# save the 45th mean as the overall mean
se$mean <- se$mean45

# sum the differences, divide by 44 to calculate the variance,
# then take the square root to calculate the standard error
se$se <- sqrt( rowSums( se[ , diffs ] ) / 44 )

# retain only a few important columns in the se data frame
se <- se[ , c( "INCLASS" , "line" , "mean" , "se" ) ]


# notes from the "Integrated Mean and SE.sas" file about this section: 

  # /***************************************************************************/
  # /* STEP7: TABULATE EXPENDITURES                                            */
  # /* ----------------------------------------------------------------------- */
  # /* 1 ARRANGE DATA INTO TABULAR FORM                                        */
  # /* 2 SET OUT INTERVIEW POPULATIONS FOR POPULATION LINE ITEM                */
  # /* 3 INSERT POPULATION LINE INTO TABLE                                     */
  # /* 4 INSERT ZERO EXPENDITURE LINE ITEMS INTO TABLE FOR COMPLETENESS        */
  # /***************************************************************************/


# transpose the se data frame by line and INCLASS, storing the value of the mean column
# save this result into a new data frame 'tab1m'
tab1m <- dcast( se , line ~ INCLASS , mean , value.var = "mean" )

# transpose the se data frame by line and INCLASS, storing the value of the se column
# save this result into a new data frame 'tab1s'
tab1s <- dcast( se , line ~ INCLASS , mean , value.var = "se" )

# create new columns in each data table, designating 'mean' and 'se'
tab1m$estimate <- "MEAN"
tab1s$estimate <- "SE"

# stack the mean and se tables together, into a new data frame called tab1
tab1 <- rbind( tab1m , tab1s )

# add the text 'INCLASS' in front of each column containing income class-specific values
names( tab1 )[2:(ncol(tab1)-1)] <- paste0( "INCLASS" , names( tab1 )[2:(ncol(tab1)-1)] )

# create a separate data frame with the total population sizes of each cu (consumer unit) in each income class
cus <- 
	dcast( 
		pop[ pop$src == "I"  , c( "INCLASS" , "rpop45" ) ] , 
		1 ~ INCLASS 
	)

# add the starting line number (see in the stubfile) to denote the weighted consumer unit count
cus[ , 1 ] <- "100001"

# rename all other columns by income class
names( cus ) <- paste0( "INCLASS" , names( cus ) )

# rename the first column 'line'
names( cus )[ 1 ] <- "line"

# add an 'estimate' column, different from the 'MEAN' or 'SE' values above
cus$estimate <- "N"

# stack this weighted count single-row table on top of the other counts
tab2 <- rbind( cus , tab1 )

# re-merge this tabulation with the stubfile
tab <- merge( tab2 , stubfile , all = TRUE )

# loop through each column in the 'tab' data frame specific to an income class, and convert all missing values (NA) to zero
for ( i in names( tab )[ grepl( 'INCLASS' , names( tab ) ) ] ) tab[ is.na( tab[ , i ] ) , i ] <- 0

# if the estimate is also missing, it was a record from the stubfile that did not have a match in the 'tab2' data frame,
# so label its 'estimate' column as 'MEAN' instead of leaving it missing
tab[ is.na( tab[ , "estimate" ] ) , "estimate" ] <- "MEAN"

# throw out standard error 'SE' records from stubfile categories CUCHARS (consumer unit characteristics) and INCOME
tab <- tab[ !( tab$estimate %in% 'SE' & tab$group %in% c( "CUCHARS" , "INCOME" ) ) , ]

# order the entire tab file by the line, then estimate columns
tab <- tab[ order( tab$line , tab$estimate ) , ]

# the data frame 'tab' matches the final 'tab' table created by the "Integrated Mean and SE.sas" example program

# this table can be viewed on the screen..
head( tab , 10 )				# view the first 10 records


# sort the columns to match the "Integrated Mean and SE.lst" file #

# make a copy of the tab data frame that will be re-sorted
tab.out <- tab

tab.out <- tab.out[ , c( "title" , "estimate" , "INCLASS99" , paste0( "INCLASS" , 0:max(fmly$INCLASS) ) ) ]

# create dynamic income labels
incomeLabels <- vector()
for(i in 2:length(incomeBreakpoints)){
  if(i+1 <= length(incomeBreakpoints)){
    incomeLabels <- c(incomeLabels, paste0("$",incomeBreakpoints[i]," to $",incomeBreakpoints[i+1]))
  }else{
    incomeLabels <- c(incomeLabels, paste0("$",incomeBreakpoints[i]," and over"))
  }
}

# label the columns of the output file
names( tab.out )[ 3:ncol(tab.out) ] <- 
	c( 
		"all consumer units" , 
		"less than $0" ,
		incomeLabels
	)

# remove the first row which tabulates the mean # number of households
tab.out <- tab.out[-1,]

# represent the number of consumer units in thousands
tab.out[1, 3:ncol(tab.out)] <- tab.out[1, 3:ncol(tab.out)]/1000

# round all numeric columns to two decimal places
tab.out[,3:ncol(tab.out)] <- round(tab.out[,3:ncol(tab.out)], 2)

if(createTabOutCSV){
  # ..and save to a comma separated value file on the local disk
  if(excludeRetired){
    write.csv( tab.out , paste0(year, " Integrated Mean And SE Aged ", minAge,"-",maxAge," Non-Retired.csv") , row.names = FALSE )
  }else{
    write.csv( tab.out , paste0(year, " Integrated Mean And SE Aged ", minAge,"-",maxAge,".csv") , row.names = FALSE )
  }
}

