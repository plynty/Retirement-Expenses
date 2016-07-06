if(!("stringr" %in% rownames(installed.packages()))){
  # install it if not yet installed
  install.packages(pkg)
} 
library(stringr) 	# load stringr package (manipulates character strings easily)

# Assign a variable for the year for which data will be tabulated
year <- 2014

# Assign a variable for the root directory
mydir <- "/Users/tndambakuwa/Retirement-Expenses"

# Create the root directory if it doesn't exist
try(dir.create(mydir, showWarnings=FALSE))

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
abbrevDF <- matrix( nrow = nrow( stubfile ) , ncol = 10 )

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
  abbrevDF[ i , ] <- savelines
}

# convert the matrix to a data frame..
abbrevDF <- data.frame( abbrevDF )

# ..and name its columns line1 - line10
names( abbrevDF ) <- c(paste0( "heading" , 1:9 ), "Ref_Line")


# tack on the UCC and line columns from the stubfile (which has the same number of records)
abbrevDF <- cbind( abbrevDF , stubfile[ , c( "UCC" , "line" ) ] )

# mapping the line number to the heading
lines <- abbrevDF$line[which(is.na( as.numeric( as.character( abbrevDF$UCC ) ) ))]
headings <- as.character(abbrevDF$UCC[which(is.na( as.numeric( as.character( abbrevDF$UCC ) ) ))])

abbrevDF$heading1 <- as.character(abbrevDF$heading1)
abbrevDF$heading2 <- as.character(abbrevDF$heading2)
abbrevDF$heading3 <- as.character(abbrevDF$heading3)
abbrevDF$heading4 <- as.character(abbrevDF$heading4)
abbrevDF$heading5 <- as.character(abbrevDF$heading5)
abbrevDF$heading6 <- as.character(abbrevDF$heading6)
abbrevDF$heading7 <- as.character(abbrevDF$heading7)
abbrevDF$heading8 <- as.character(abbrevDF$heading8)
abbrevDF$heading9 <- as.character(abbrevDF$heading9)

for(x in 1:nrow(abbrevDF)){
  for(y in 1:9){
    if(abbrevDF[x,y] == ""){
      break
    }else{
      abbrevDF[x,y] <- headings[which(lines == abbrevDF[x,y])]
    }
  }
}

abbrevDF$title <- stubfile$title

#creating a reference list to find the title of category abbreviations
abbreviations <- vector()
titles <- vector()

for(x in 1:nrow(abbrevDF)){
  if(is.na( as.numeric(as.character( abbrevDF$UCC[x])))){
    abbreviations <- c(abbreviations,as.character(abbrevDF$UCC[x]))
    titles <- c(titles,str_trim(as.character(abbrevDF$title[x])))
  }
}
abbreviationMap <- as.list(titles)
names(abbreviationMap) <- abbreviations

#to find out the heading abbreviation just enter abbreviationMap$ABBREV. where ABBREV is the abbrevation you wish to look up
abbreviationMap$INCBFT

# remove records where the UCC is not numeric
abbrevDF <- subset( abbrevDF , !is.na( as.numeric( as.character( UCC ) ) ) )

# reset the row names/numbers
rownames( abbrevDF ) <- NULL

abbrevDF$Ref_Line <- NULL