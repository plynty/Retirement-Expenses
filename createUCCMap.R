rm(list=ls())

if(!("stringr" %in% rownames(installed.packages()))){
  # install it if not yet installed
  install.packages(pkg)
} 
library(stringr) 	# load stringr package (manipulates character strings easily)

# Assign a variable for the year for which data will be tabulated
year <- 2014

# Assign a variable for the root directory
mydir <- "/Users/aarondyke/CE_PUMD"

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
names( aggfmt1 ) <- c(paste0( "heading" , 1:9 ), "Ref_Line")


# tack on the UCC and line columns from the stubfile (which has the same number of records)
aggfmt1 <- cbind( aggfmt1 , stubfile[ , c( "UCC" , "line" ) ] )

# mapping the line number to the heading
lines <- aggfmt1$line[which(is.na( as.numeric( as.character( aggfmt1$UCC ) ) ))]
headings <- as.character(aggfmt1$UCC[which(is.na( as.numeric( as.character( aggfmt1$UCC ) ) ))])

aggfmt1$heading1 <- as.character(aggfmt1$heading1)
aggfmt1$heading2 <- as.character(aggfmt1$heading2)
aggfmt1$heading3 <- as.character(aggfmt1$heading3)
aggfmt1$heading4 <- as.character(aggfmt1$heading4)
aggfmt1$heading5 <- as.character(aggfmt1$heading5)
aggfmt1$heading6 <- as.character(aggfmt1$heading6)
aggfmt1$heading7 <- as.character(aggfmt1$heading7)
aggfmt1$heading8 <- as.character(aggfmt1$heading8)
aggfmt1$heading9 <- as.character(aggfmt1$heading9)

for(x in 1:nrow(aggfmt1)){
  for(y in 1:9){
    if(aggfmt1[x,y] == ""){
      break
    }else{
      aggfmt1[x,y] <- headings[which(lines == aggfmt1[x,y])]
    }
  }
}

aggfmt1$title <- stubfile$title

#creating a reference list to find the title of category abbreviations
abbreviations <- vector()
titles <- vector()

for(x in 1:nrow(aggfmt1)){
  if(is.na( as.numeric(as.character( aggfmt1$UCC[x])))){
    abbreviations <- c(abbreviations,as.character(aggfmt1$UCC[x]))
    titles <- c(titles,as.character(aggfmt1$title[x]))
  }
}
abbreviationMap <- as.list(titles)
names(abbreviationMap) <- abbreviations

#to find out the heading abbreviation just enter abbreviationMap$ABBREV. where ABBREV is the abbrevation you wish to look up
str_trim(abbreviationMap$CONSUN)

# remove records where the UCC is not numeric
aggfmt1 <- subset( aggfmt1 , !is.na( as.numeric( as.character( UCC ) ) ) )

# reset the row names/numbers
rownames( aggfmt1 ) <- NULL

aggfmt1$Ref_Line <- NULL

# # order the data frame by UCC
# aggfmt1 <- aggfmt1[ order( aggfmt1$UCC ) , ]
# 
# # rename line to compare
# aggfmt1$compare <- aggfmt1$line
# aggfmt1$line <- NULL
# 
# # reset the row names/numbers
# rownames( aggfmt1 ) <- NULL
# 
# # transpose the data, holding UCC and compare
# aggfmt2 <- melt(aggfmt1, id=c("UCC","compare")) 
# names( aggfmt2 )[ 4 ] <- "line"
# 
# # retain the UCC-to-line crosswalk wherever the 'line' variable is not blank
# aggfmt <- subset( aggfmt2 , line != "" , select = c( "UCC" , "line" ) )
# 
# # re-order the data frame by UCC
# aggfmt <- aggfmt[ order( aggfmt$UCC ) , ]