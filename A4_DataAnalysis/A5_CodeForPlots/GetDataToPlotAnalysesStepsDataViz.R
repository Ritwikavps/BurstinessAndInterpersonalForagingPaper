library(tidyverse); library(lme4) #get libraries

setwd("/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA")

DataTab <- read_csv('CurrPrevStSize_ANRespToCHNSP_2s_IviOnly.csv')
attach(DataTab) #read in data table
SubsetTab <- filter(DataTab, AgeMonths == 18 & InfantID == '009') #subset by filtering for 18 months
detach(DataTab) #detach big data tab
attach(SubsetTab) #attach filtered subsettab

CurrIvi18Mnth <- SubsetTab$CurrInterVocInt; PrevIvi18Mnth <- SubsetTab$PrevInterVocInt #get un-transformed current and previous IVI
CurrIvi18Mnth_ScaleLog <- scale(log10(CurrIvi18Mnth + (10^-10))); PrevIvi18Mnth_ScaleLog <- scale(log10(PrevIvi18Mnth + (10^-10))) #get log-d and scaled versions
InfId <- as_factor(SubsetTab$InfantID) #turn infant ID into a categorical variable
RespVar <- SubsetTab$Response #get response variable

LmerMdl_PrevSt <- lm(CurrIvi18Mnth_ScaleLog ~ PrevIvi18Mnth_ScaleLog,na.action=na.exclude) #do pre step size lmer
PrevStSummary <- summary(LmerMdl_PrevSt); PrevStCIs <- confint(LmerMdl_PrevSt) #get stats summaries
ResidVar <- resid(LmerMdl_PrevSt) #get residuals
ResidVarScale <- scale(ResidVar) #scale residuals

ScaledLogIvivars18Mnth <- tibble(CurrIvi18Mnth,PrevIvi18Mnth,CurrIvi18Mnth_ScaleLog,PrevIvi18Mnth_ScaleLog,ResidVar,ResidVarScale,RespVar,InfId) #generate output tibble 
#write.csv(ScaledLogIvivars18Mnth, file='LENACurrPrevIvi18Mnth_IviOnly.csv', row.names=FALSE)

TabForLm <- tibble(ResidVar,RespVar) #get table for linear model so we can subset only non-NaN responses
LmSubsetTab <- filter(TabForLm,!is.nan(RespVar)) #filter for non-NaN repsonse values ONLY
ResponseNoNA <- as_factor(LmSubsetTab$RespVar) #make response categorical
LmMdl_Resp <- lm(scale(LmSubsetTab$ResidVar) ~ ResponseNoNA) #do lmer
RespSummary <- summary(LmMdl_Resp); RespCIs <- confint(LmMdl_Resp) #get stats summaries

print(PrevStSummary)
print(RespSummary)

detach(SubsetTab)