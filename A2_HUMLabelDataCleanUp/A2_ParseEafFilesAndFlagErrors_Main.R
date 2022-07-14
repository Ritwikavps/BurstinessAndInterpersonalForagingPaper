#Ritwika VPS, May 2022
#code to parse .eaf files and save annotation details (start time ref, start time ref linenum, start time value; 
#end time ref, end time ref line num, end time value; 
#annotation id, annotation id line num, annotation value, anotation value line num;
#tier id type)

#In addition, also output summary files for any flags (missing infant voc type, adult utt dir, and adult orthographic transcription tiers + info about when the
#or if there is a mismatch in the number of different details corresponding to each annottaion (see functio Rfn_GetAnnottationDetails.R for details))

################################################################################################################################################################################################################################
#set working directory; CHANGE ACCORDINGLY
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A4_EditedEafFiles/')
################################################################################################################################################################################################################################

#load required librarues
library(pracma) #lots fo basic functions
library(stringr)
library(sjmisc)

#source all user-defined functions
source('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A2_HUMLabelDataCleanUp/EafParsingFunctions.R')

################################################################################################################################################################################################################################
#start writing to o/p file (flags for if a certain tier doesn't exist in a file or if there aren't the same number of 
#annotations, annotation ids, start time refs, and end time refs within each tier we look at in a file)
sink('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/PostCleanUp_EafFileMissingTiersAndOtherGeneralErrorSummary.txt') #any console o/p between the two calls of sink will go into the file
#CHANGE SINK FILE NAME ACCORDINGLY
################################################################################################################################################################################################################################

CurrPath = getwd() #get current path
aa <- dir(CurrPath, pattern = ".eaf") #dir .eaf files

#go through files dir-d
for (i in 1:numel(aa)){ #
  
  #inputs
  EafFilename = aa[i] #set EafFilename variable as eaf file name (for reasons I do not quite understand, the actual file name
  #has to be stored as the 'EafFilename' variable to be passed on to the function, presumably because the input
  #for the function is a variable names EafFilename? I thought this could be a placeholder for a string but apparently not?)
  #Key tiers are : 'Infant Voc Type', 'Adult Utterance Dir' (because some files only have this much of the string),
  #'Adult Ortho' (for the orthograohic transcription tier; some files only have 'Adult Orthographic' in this tier label)
  
  #get annotation time ref ids and times
  TimeRefTimeVal_df = GetEafTimeRefTimeValue(EafFilename)
  TierInfo_df = GetAnnotationDetails(EafFileName) 
          #print(i) #debug bit
  
  #match time ref id to actual times
  TimeMatched_df <- MatchAnnotTimeRefToTime(TierInfo_df$StartTimeRef,TierInfo_df$EndTimeRef,
                                            TimeRefTimeVal_df$TimeSlotRef,TimeRefTimeVal_df$TimeVal)
  
  #merge both dataframes
  EafDetails_df <- cbind(TierInfo_df,TimeMatched_df)
  
  ################################################################################################################################################################################################################################
  #write to csv
  FnEafRemoved = strsplit(EafFilename,'.eaf')
  #I have to do the following in two steps because for some reason, R cannot seem to handle if I do this as strcat(a,b,c)
  #It works if I do strcat(c('a','b','c')), which makes me a little mad
  FnCsv = strcat(strcat('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A5_ParsedEafFilesFromR_PostCleanUp/',FnEafRemoved[[1]][1]),'.csv')
  #CHANGE DESTINATION FOLDER ACCORDINGLY
  ################################################################################################################################################################################################################################
  write.csv(EafDetails_df,FnCsv,row.names = FALSE)
  #note that the indexing of FnEafRemoved is [[1]][1] because it is a list. The [[1]] indexes the first row, and [1] is the first element of that row
  
}

sink() #close sink


