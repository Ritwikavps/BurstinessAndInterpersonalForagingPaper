#Ritwika VPS
#This script takes data tables with current and previous step sizes (acoustics as well 2 and 3d space) and IVIs, for each recording day at different rersponse window thresholds, and gets the
#beta values for previous step size effect and response effect at the recording day level. These beta values are then used to compute the age effect for how these response betas change with
#infant age. This is done for LENA day-long data, human-listener labelled 5 min sections, and corresponding LENA 5 min sections

#load required libraries
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)
library(tidyverse)

source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A6_ResponseAnalyses_IVIOnly/GetLmerCoeffsForAgeEffectsForPrevStSiBetas.R')   

FilePattern = '.*_RespEff_W_.*RecDayLvl_IviOnly.csv'
Destinationpath = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/'
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WorkingDir_LENA = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA/'
WorkingDir_LENA5min = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA5min/'
WorkingDir_Hum = '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_H/'

LENAOp <- GetOpTab_RecLvlRespBeta_AgeEffOnRespBeta(WorkingDir_LENA,FilePattern) #get output tables
LENA5minOp <- GetOpTab_RecLvlRespBeta_AgeEffOnRespBeta(WorkingDir_LENA5min,FilePattern)
HumOp <- GetOpTab_RecLvlRespBeta_AgeEffOnRespBeta(WorkingDir_Hum,FilePattern)

AgeEffOnPrevStSiBeta_Tab = bind_rows(LENAOp,LENA5minOp,HumOp)
setwd(Destinationpath)
write.csv(AgeEffOnPrevStSiBeta_Tab, file = 'AgeEffOnPrevStSiBeta_RawPolyAge_IviOnly.csv',row.names=FALSE) #write file