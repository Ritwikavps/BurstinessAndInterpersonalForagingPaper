#Ritwika VPS, Feb 2024
#This script generates a table with current and previous IEIs (raw and transformed) as well residuals of the previous IEI control analysis at the 
#recording level. This table is also used (using a different .R script) to estimate the slopes and intercepts for the Curr IEI vs prev IEI plot 
#in the main text by grouping the LENA daylong IEIs by age and performing the previous IEI regression (which is admittedly a roundabout way of
#doing this, but this is what the pipeline ended up being and I am not inclined to change this now xD)

library(tidyverse); library(lme4); library(pracma); library(sjmisc); #get libraries
#source user-defined function
source('/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A1_ResponseAnalyses_IEIs/GetPrevStCtrlResids_RecLvl.R')

FilePattern <- '.*IviOnly.csv' #this is the string to pick out relevant files (See user-deifned fn WriteOpToFile_RespEffBetas for details)
WriteOpPath <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/'

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#LENA day-long files
WorkingDir_LENA <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA/'
DataType_LENA <- 'LENA'

#LENA 5 min matched files
WorkingDir_LENA5min <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA5min/'
DataType_LENA5min <- 'LENA5min'

#human listener labelled files: all adult utterances
WorkingDir_Hum_AllAd <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_H/'
DataType_Hum_AllAd <- 'Hum-AllAd'

#human listener labelled files with child directed AN utterances only
WorkingDir_Hum_ChildDirAd <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_H_ChildDirANOnly/'
DataType_Hum_ChildDirAd <- 'HumChildDirAdOnly'

#put together lists for working directories and data types
WorkingDir <- c(WorkingDir_LENA,  WorkingDir_LENA5min,  WorkingDir_Hum_AllAd,   WorkingDir_Hum_ChildDirAd)
DataType <- c(DataType_LENA,      DataType_LENA5min,    DataType_Hum_AllAd,     DataType_Hum_ChildDirAd)

WriteResidsToFile_RecLvl(WorkingDir,FilePattern,DataType,WriteOpPath)




