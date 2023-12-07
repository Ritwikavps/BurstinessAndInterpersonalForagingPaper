#Ritwika VPS, April 2023
#This script contains functions used to edit simple errors in .eaf files
#Required libraries: sjmisc, stringr, pracma
#also make sure to be in the correct directory

########################################################################################################################################################################
#Function 1: Checks if the line contains tier label
########################################################################################################################################################################
CheckIfTierLine <- function(myLine){
  
  if (str_contains(myLine,'<TIER LINGUISTIC_TYPE_REF=')){ #string to ID line at the start of a tier (the line with the tier label)
    TierFlag = TRUE
  } else {
    TierFlag = FALSE
  }
  return(TierFlag)
}

########################################################################################################################################################################
#Function 2: Check if tier label needs editing
########################################################################################################################################################################
TierLabelEditCheck <- function(myLine){
  
  TierName = gsub('">','',gsub('/','',gsub('.*TIER_ID="','',myLine))) #remove parts before and including TIER_ID=", and the substring ">, to get the tier name
  #The string is of the form <TIER LINGUISTIC_TYPE_REF="default-lt" TIER_ID="Affirmation">
  
  if (sum(str_contains(tolower(TierName),c('adult ortho','adult utt')))){ #these are the two labels that have typos (this is from running A2Optl_GetUniqueTierNames.m)
    if ((strcmp(TierName,'Adult Orthographic Transcription')) | (strcmp(TierName,'Adult Utterance Direction'))){ #if the names are properly spelled, don't edit
      TierNameEditFlag = FALSE
    } else{
      TierNameEditFlag = TRUE
    }
  } else {
    TierNameEditFlag = FALSE
  }
  
  return(TierNameEditFlag)
}

########################################################################################################################################################################
#Function 3: Edit tier label as necessary
########################################################################################################################################################################
EditTierName <- function(myLine){
  
  TierName = gsub('">','',gsub('/','',gsub('.*TIER_ID="','',myLine))) #remove parts before and including TIER_ID=", and the substring ">, to get the tier name
  #The string is of the form <TIER LINGUISTIC_TYPE_REF="default-lt" TIER_ID="Affirmation">
  
  #There are only three cases that need editing
  if (str_contains(myLine,'Adult Ortho',ignore.case = TRUE)){
    newLine = gsub('"Adult Ortho.*"','"Adult Orthographic Transcription"',myLine)
  } else if (str_contains(myLine,'Adult Utt',ignore.case = TRUE)){
    newLine = gsub('"Adult Utt.*"','"Adult Utterance Direction"',myLine)
  } else if (str_contains(myLine,'affirmation')){
    newLine = gsub("affirmation",'Affirmation',myLine)
  } 
  
  return(newLine)
}
