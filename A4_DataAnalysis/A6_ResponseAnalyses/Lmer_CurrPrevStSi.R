#Ritwika VPS
#R script to compute correlations between acoustic space step size and intervocalisation interval, accounting for random effects due to 
#recordings from the same infant at different ages

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)
library(tidyverse)

setwd('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl/')
source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A6_ResponseAnalyses/GetCurrPrevStSiLmerOp.R')
source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A6_ResponseAnalyses/GetRespEffNoPrevStSiCtrlLmerOp.R')
FilesToLoad = list.files(path = getwd(),pattern='.*s.csv')

OpTab = GetRespEffNoPrevStSiCtrlLmerOp(FilesToLoad,'ANRespToCHNSP')

write.csv(OpTab, file = "RespEffNoCurrPrevStSizCtrl_LENA_ANRespToCHNSP_DurLogZ_VarsScaleLog_Dec142023.csv",row.names=FALSE)

OpTab = GetRespEffNoPrevStSiCtrlLmerOp(FilesToLoad,'CHNSPRespToAN')

write.csv(OpTab, file = "RespEffNoCurrPrevStSizCtrl_LENA_CHNSPRespToAN_DurLogZ_VarsScaleLog_Dec142023.csv",row.names=FALSE)

