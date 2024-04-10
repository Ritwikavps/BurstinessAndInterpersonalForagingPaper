#Ritwika VPS
##This script takes stats tables with response effects (at teh corpus level) at different ages, and checks whether the CIs overlap

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)
library(tidyverse)

#source necessary functions
source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A6_ResponseAnalyses/GetPairWiseRespEffOlpConfIntChecks.R')

FilePattern = '.*CorpusLvl.csv' #this is the string to pick out relevant files (See user-deifned fn WriteOpToFile_RespEffBetas for details)
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#LENA day-long files
WorkingDir_LENA = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA/'
DataType_LENA = 'LENA'
WriteOpToFile_RespEffBetas(WorkingDir_LENA,FilePattern,DataType_LENA)

#LENA 5 min matched files
WorkingDir_LENA5min = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA5min/'
DataType_LENA5min = 'LENA5min'
WriteOpToFile_RespEffBetas(WorkingDir_LENA5min,FilePattern,DataType_LENA5min)

#human listener labelled files
WorkingDir_Hum = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_H/'
DataType_Hum = 'Hum'
WriteOpToFile_RespEffBetas(WorkingDir_Hum,FilePattern,DataType_Hum)



