#Ritwika VPS
#R script to compute correlations between acoustic space step size and intervocalisation interval, accounting for random effects due to 
#recordings from the same infant at different ages

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)
library(tidyverse)

setwd('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/DataTabsForStats/R6_DataTablesForResponseAnalyses/CurrPrevStSi')
source('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A4_DataAnalysis/A6_ResponseAnalyses/GetCurrPrevStSiLmerOp.R')

FilesToLoad = list.files(path = getwd(),pattern='LENA5min.*s.csv')

OpTab = GetCurrPrevStSiLmerOp(FilesToLoad,'ANRespToCHNSP')

write.csv(OpTab, file = "CurrPrevStSizResp_LENA5min_ANRespToCHNSP_DurLogZ_RespAnalysesOnResid_VarsScaleLog_Oct192023.csv",row.names=FALSE)

OpTab = GetCurrPrevStSiLmerOp(FilesToLoad,'CHNSPRespToAN')

write.csv(OpTab, file = "CurrPrevStSizResp_LENA5min_CHNSPRespToAN_DurLogZ_RespAnalysesOnResid_VarsScaleLog_Oct192023.csv",row.names=FALSE)

