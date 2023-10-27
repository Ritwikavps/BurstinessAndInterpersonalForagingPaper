#Ritwika VPS, Oct 2023
#code to parse .its files and save infant age details in a .csv file (this is a far less clunky implementation of code of the same 
#concept that uses a combo of bash, perl, and MATLAB

################################################################################################################################################################################################################################
#set working directory; CHANGE ACCORDINGLY
setwd('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A1_ItsFiles/')
################################################################################################################################################################################################################################

#load required librarues
library(pracma) #lots fo basic functions
library(stringr)
library(sjmisc)
library(tidyverse)

################################################################################################################################################################################################################################
#read metadata file; CHNAGE PATH ACCORDINGLY
ItsFileTab = read_csv('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/MetadataFiles/ItsFileDetailsShareable.csv')

#source all user-defined functions; CHNAGE PATHA CCORDINGLY
source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A1_LENADataProcessing/ItsParsingFnsForInfantAge.R')
################################################################################################################################################################################################################################

CurrPath = getwd() #get current path
aa <- dir(CurrPath, pattern = ".its") #dir .eaf files

FNRoot = c()
InfantAge = c()
InfantID = c()

#go through files dir-d
for (i in 1:numel(aa)){ #
  
  #inputs
  ItsFilename = aa[i] #set ItsFilename variable as .its file name 
  
  FNRoot[i] = gsub('.its','',ItsFilename)
  InfantAge[i] = GetInfAge(ItsFilename)
  InfantID[i] = GetInfantID(ItsFileTab,ItsFilename)
}

AgeTbl = tibble(FNRoot,InfantID,InfantAge)
write_csv(AgeTbl,'~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/MetadataFiles/MetadataInfAgeAndID.csv')