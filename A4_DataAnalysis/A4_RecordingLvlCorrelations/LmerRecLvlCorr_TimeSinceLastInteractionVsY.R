#Ritwika VPS
#R script to compurte correlations between recording-level correlations for human listener labelled data and corresponding matched LENA data

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

#source functions needed
source('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A6_GeneralAnalysis/GetLmerCoefs_RevLvlCorrelations.R')

#get files to be read from all relevant directories
Tab_Lday <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats',pattern="RecLevel.*.csv", recursive=TRUE, full.names=TRUE)
Tab_H <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats',
                                pattern="RecLevelCorr_TimeSinceLastInteractionVsY_Hlabel.csv", recursive=TRUE, full.names=TRUE)
Tab_L5min <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats',
                                 pattern="RecLevelCorr_TimeSinceLastInteractionVsY_L5min.csv", recursive=TRUE, full.names=TRUE)

######do lmer
RecLvlCorrelation_Lday_H = GetLmerCoefs_RecLvlCorrelations(Tab_Lday[1],Tab_H[1])
RecLvlCorrelation_Lday_L5min = GetLmerCoefs_RecLvlCorrelations(Tab_Lday[1],Tab_L5min[1])
RecLvlCorrelation_L5min_H = GetLmerCoefs_RecLvlCorrelations(Tab_L5min[1],Tab_H[1])

#save final table
#AgeEffect_Lday_H = RecLvlCorrelation_Lday_H$AgeEffect
#AgePvalue_Lday_H = RecLvlCorrelation_Lday_H$AgePvalue
RecLvlCorrelationBeta_Lday_H = RecLvlCorrelation_Lday_H$RecLvlCorrelationBeta
RecLvlCorrelationBetaPvalue_Lday_H = RecLvlCorrelation_Lday_H$RecLvlCorrelationPvalue

#AgeEffect_Lday_L5min = RecLvlCorrelation_Lday_L5min$AgeEffect
#AgePvalue_Lday_L5min= RecLvlCorrelation_Lday_L5min$AgePvalue
RecLvlCorrelationBeta_Lday_L5min = RecLvlCorrelation_Lday_L5min$RecLvlCorrelationBeta
RecLvlCorrelationBetaPvalue_Lday_L5min = RecLvlCorrelation_Lday_L5min$RecLvlCorrelationPvalue

#AgeEffect_L5min_H = RecLvlCorrelation_L5min_H$AgeEffect
#AgePvalue_L5min_H = RecLvlCorrelation_L5min_H$AgePvalue
RecLvlCorrelationBeta_L5min_H = RecLvlCorrelation_L5min_H$RecLvlCorrelationBeta
RecLvlCorrelationBetaPvalue_L5min_H = RecLvlCorrelation_L5min_H$RecLvlCorrelationPvalue

Ymeasure = RecLvlCorrelation_L5min_H$Ymeasure
Speaker = RecLvlCorrelation_L5min_H$Spkr

#ResultsTab = data.frame(Ymeasure,Speaker,
                        #RecLvlCorrelationBeta_Lday_H, RecLvlCorrelationBetaPvalue_Lday_H,
                        #AgeEffect_Lday_H, AgePvalue_Lday_H,
                        #RecLvlCorrelationBeta_Lday_L5min, RecLvlCorrelationBetaPvalue_Lday_L5min,
                        #AgeEffect_Lday_L5min, AgePvalue_Lday_L5min,
                        #RecLvlCorrelationBeta_L5min_H, RecLvlCorrelationBetaPvalue_L5min_H,
                        #AgeEffect_L5min_H, AgePvalue_L5min_H)

ResultsTab = data.frame(Ymeasure,Speaker,
                        RecLvlCorrelationBeta_Lday_H, RecLvlCorrelationBetaPvalue_Lday_H,
                        RecLvlCorrelationBeta_Lday_L5min, RecLvlCorrelationBetaPvalue_Lday_L5min,
                        RecLvlCorrelationBeta_L5min_H, RecLvlCorrelationBetaPvalue_L5min_H)

setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/')
write.csv(ResultsTab, file = "RecLvlCorrStats_TimeSinceLastInteractionVsY1.csv",row.names=FALSE)

