#Ritwika VPS
#This script takes data table (PrevStSizeResids_VarsScaleLog_RecDayLvl_IviOnly.csv) with current and previous IVIs and residuals and computes the 
#lmer results for previous step size betas and intercepts of ther linear regression, for each age, and outputs these results in the table (only 
#for LENA daylong data). These betas are the same betas we report in the paper. However, this script also provides the intercepts to plot the linear 
#fit (for Fig 1 in paper and associated schematics) and also saves current IVI, Previous IVI, log transformed and scaled version of these (at the 
#age block level), as well as residuals (from the age block level currIVI ~ PrevIVI regression). Also includes response data at the 5 s response window.
#The purpose of these outputs is to have plottable data for Fig 1 in main text and associated schematics. 

#load required librarues
library(lme4); library(lmerTest); library(pracma); library(sjmisc); library(tidyverse)

WorkingDir <- '~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/'
setwd(WorkingDir) #set working directory
ReqTab <- read_csv('PrevStSizeResids_VarsScaleLog_RecDayLvl_IviOnly.csv') #read in table
ReqTab <- filter(ReqTab, DataType == 'LENA') #filter for LENA data
ReqTab$InfantID <- as_factor(ReqTab$InfantID) #make infant ID categorical variable
ReqTab <- select(ReqTab, Response_5,CurrIVI,PrevIVI,InfantID,AgeMonths,ResponseType) #pick out required columns ONLY

#Check to make sure that only required ages are present
if (!identical(unique(ReqTab$AgeMonths),c(3,6,9,18))){
  print('List of unique ages not as expected')
}

#initialise vectors to be added to output tibble with IVIs and residuals
Ctr <- 0; #Ctr variable for the intercepts and betas
Intercept <- c(); PrevStBeta <- c(); InfAge <- c(); TypeOfResponse <- c();
FinalOpIVITab <- NULL #table to store scaled current and prev IEIs and residuals from prev IEI control (at the age group level, LENA day long data)

#For loop to do lmer and get residuals and results
for (i_RespType in unique(ReqTab$ResponseType)){ #go through different response types (ANRespToCHNSP, CHNSPRespToAN)
  for (i_Age in unique(ReqTab$AgeMonths)){ #go through different ages
    
    Ctr <- Ctr + 1; #increment Ctr
    
    ReqSubTab <- filter(ReqTab, AgeMonths==i_Age & ResponseType==i_RespType) #subset tibble by age and response type
    attach(ReqSubTab) #attach subsetted tibble
    
    #Transform current and prev IVIs
    ZscoreLog10_CurrIVI = scale(log10(ReqSubTab$CurrIVI + 10^-10)); ZscoreLog10_PrevIVI = scale(log10(ReqSubTab$PrevIVI + 10^-10))
    
    #Run lmer model
    Mdl <- lmer(ZscoreLog10_CurrIVI ~ ZscoreLog10_PrevIVI + (1|ReqSubTab$InfantID),na.action=na.exclude)
    ResidualVec <- resid(Mdl); #ResidVar_Scaled <- scale(ResidVar) #get residuals (optionally scaled residuals, currently commented out)
    
    #get tibble with scaled and logd IVIs and resids from models and bind with tibble with untransformed IVIs, ages, IDs, etc
    ScaledIVIandResidsTab_Temp <- bind_cols(ReqSubTab,tibble(ZscoreLog10_CurrIVI,ZscoreLog10_PrevIVI,ResidualVec)) 
    FinalOpIVITab <- bind_rows(FinalOpIVITab,ScaledIVIandResidsTab_Temp) #bind to full op tab
    
    #get model coeffs and other outputs
    MdlSummary <- summary(Mdl)
    Intercept[Ctr] <- MdlSummary$coefficients[1,1] #intercept
    PrevStBeta[Ctr] <- MdlSummary$coefficients[2,1] #beta
    InfAge[Ctr] <- i_Age
    TypeOfResponse[Ctr] <- i_RespType
    
    detach(ReqSubTab) #detach
  }
}

#get output tibbles
StatsOpTab <- tibble(InfAge,TypeOfResponse,Intercept,PrevStBeta) #get stats tibble

write.csv(FinalOpIVITab, file = 'TransformedIVIsAndResidsFromPrevIVILmer_AgeBlockLvl_LENA.csv',row.names=FALSE) #write files
write.csv(StatsOpTab, file = 'AgeLvlPrevIVIBetaAndIntercept_LENA.csv',row.names=FALSE) 