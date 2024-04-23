#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 1: This function takes the data table that has the recording level stats for prev st size effect and response effect, and does a linear 
#mixed effects model with Age and Age^2 on the previous step size effect. That is, we get how the previous step size effect changes with age
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetAgeEffectsOnPrevStBeta_IviOnly <-function(InputTabs){
  
  #Note that we only need to do this for one data table each for ANRespToCHNSP and CHNSPRespToAN, since the previous step size effect is independent of response window
  
  #initialise vectors to iteratively store output in
  DataType <- c(); RespType <- c()
  Age1Eff <- c(); Age1P <- c(); Age1CI_2_5 <- c(); Age1CI_97_5 <- c() #age (linear) results
  Age2Eff <- c(); Age2P <- c(); Age2CI_2_5 <- c(); Age2CI_97_5 <- c() #age^2 results
  InterceptVal <- c(); InterceptCI_2_5 <- c(); InterceptCI_97_5 <- c();
  
  Ctr <- 0 #intialise counter variable
  
  for (i in InputTabs){
    
    DataTab = read_csv(i); attach(DataTab) #read in table
    
    Ctr <- Ctr + 1 #increment counter variable
    SubsetTab <- filter(DataTab, StepType == 'InterVocInt' & RespWindow_s == 1) #we only need one response window
    SubsetTabFiltered <- filter(SubsetTab,!is.na(PrevStEff)) #Remove NAs
    IDvar <- as_factor(SubsetTabFiltered$ID) #make infant ID categorical variable
    LmerMdl <- lmer(SubsetTabFiltered$PrevStEff ~  (1|IDvar) + poly(SubsetTabFiltered$InfAgeMnth,2, raw = TRUE)) #note that we are not scaling anything
    LmerSummary <- summary(LmerMdl); LmerCIs <- confint(LmerMdl) #get stats results
    
    #store results
    DataType[Ctr] <-  gsub('_.*','',i)#remove everything after the first _; ex. file name = 'Hum_CHNSPRespToAN_RespEff_W_CurrPrevStSizCtrl_VarsScaleLog_RecDayLvl_IviOnly'
    RespType[Ctr] <- gsub('.*_','',gsub('_RespEff.*','',i)) #the first gsub remove eveything after (and including) '_RespEff', which, for the aboev example, leaves us 
    #with 'Hum_CHNSPRespToAN'. The second gsub everything before and including the underscore, which, in this case, removes the 'Hum_
      
    InterceptVal[Ctr] <- LmerSummary$coefficients[1,1]
    InterceptCI_2_5[Ctr] <- LmerCIs[3,1]
    InterceptCI_97_5[Ctr] <- LmerCIs[2,2]
    
    Age1Eff[Ctr] <- LmerSummary$coefficients[2,1]
    Age1P[Ctr] <- LmerSummary$coefficients[2,5]
    Age1CI_2_5[Ctr] <- LmerCIs[4,1]
    Age1CI_97_5[Ctr] <- LmerCIs[4,2]
    
    Age2Eff[Ctr] <- LmerSummary$coefficients[3,1]
    Age2P[Ctr] <- LmerSummary$coefficients[3,5]
    Age2CI_2_5[Ctr] <- LmerCIs[5,1]
    Age2CI_97_5[Ctr] <- LmerCIs[5,2]
  
    detach(DataTab)
  }
  
  OpTab <- tibble(DataType,RespType,
                  InterceptVal,InterceptCI_2_5,InterceptCI_97_5,
                  Age1Eff,Age1P,Age1CI_2_5,Age1CI_97_5,
                  Age2Eff,Age2P,Age2CI_2_5,Age2CI_97_5)
  return(OpTab)
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 2: This function takes the list of files to run the analyses on, runs the prev functions, and gets the output
#Inputs are - the working directory path (WorkingDir)
#- the string pattern to match to get the required files (FilePattern)
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetOpTab_RecLvlRespBeta_AgeEffOnRespBeta <- function(WorkingDir,FilePattern){
  
  setwd(WorkingDir) #set working directory
  InputTabs <- list.files(path = getwd(),pattern = FilePattern)  #get list of required files, and append the list from the current working directory to the running list
  OpTab <- GetAgeEffectsOnPrevStBeta_IviOnly(InputTabs)
  
  return(OpTab)
}
  