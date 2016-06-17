# Creating the UCC based Expenditure Categories

#Creating the Category vectors
foodAtHome <- vector()
foodAway <- vector()
alcoholicDrinks <- vector()
housing <- vector()
utilities <- vector()
apparelAndServices <- vector()
transportation <- vector()
healthCare <- vector()
entertainment <- vector()
personalCare <- vector()
miscellaneous <- vector()
charitableAndFamilyGiving <- vector()
insurance <- vector()

#function that returns a vector of UCCs given any number of Strings of categories
getUCCs <- function(..., except = c()){
  abbrev <- unlist(list(...))
  rowNumberVector <- vector()
  for(i in 1:length(abbrev)){
    category <- abbrev[i]
    if(!category %in% abbreviations){
      cat(paste0(category," is not a category"))
    }else{
      for(x in 1:nrow(aggfmt1)){
        if(any(aggfmt1[x,1:9]==category)){
          rowNumberVector <- c(rowNumberVector,x)
        }
      }
    }
    UCCs <- unique(as.character(aggfmt1[rowNumberVector,"UCC"]))
  }
  badRowNumberVector <- vector()
  for(i in 1:length(except)){
    category <- except[i]
    if(!category %in% abbreviations){
      cat(paste0(category," is not a category"))
    }else{
      for(x in 1:nrow(aggfmt1)){
        if(any(aggfmt1[x,1:9]==category)){
          badRowNumberVector <- c(badRowNumberVector,x)
        }
      }
    }
    badUCCs <- unique(as.character(aggfmt1[badRowNumberVector,"UCC"]))
  }
  UCCs <- UCCs[which(!UCCs%in%badUCCs)]
  return(UCCs)
}

foodAtHome <- getUCCs("FOODHO",except = "HAM")
# vitamin supplements 180720??? include or not?

foodAway <- getUCCs("FOODAW")
# meals as pay 800700???
alcoholicDrinks <- getUCCs("ALCHOM","ALCAWA")

housing <- getUCCs("SHELTE","HHOTHX")
# housing as pay 800710???

utilities <- getUCCs("UTILS")
# include cellphone service cose 270102???

test[which(test$UCC =="HKPGSU"),]

# what should we do with these categories?
HHOPER{
  HHPERS
  HHOTHX
}
  
HKPGSU{
  LAUNDR
  HKPGOT
  POSTAG
}

HHFURN


apparelAndServices <- getUCCs("APPARE")
transportation <- getUCCs("TRANS")
healthCare <- getUCCs("HEALTH")
entertainment <- getUCCs("ENTRTA","READIN",except = "PETSPL")
# what to do with PETSPL

personalCare <- getUCCs("PERSCA")
miscellaneous <- getUCCs("HKPGSU")
charitableAndFamilyGiving <- getUCCs()
insurance <- getUCCs()

