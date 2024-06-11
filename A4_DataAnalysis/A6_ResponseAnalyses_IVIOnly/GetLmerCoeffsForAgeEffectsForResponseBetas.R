#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 1: function to get previous step size beta values, and then, response effect beta values based on residuals of the Current step size ~ Previous step size analyses.
#Note that this is done in two steps because the CurrStepSi ~ PrevStSi analyses are carried out on all non-NaN steps, but the response analyses are only done on steps
#associated with non-NA responses
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetRespEff_w_PrevStSiCtrl_RecordingLevel <- function(FilesToLoad,RespToSpkr){
  
  #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr; eg. ANRespToCHNSP), performs the two-step 
  #response effect analysis controlling for the effect of any intrinsic vocalisation pattern of the target speaker, and outputs the results of stastitical analyses as a tibble.
  
  #Note that in this version of the function, we do the analyses at the recording-day level
  
  #initialise vectors to iteratively store output in
  StepType <- c(); InfAgeMnth <- c(); RespWindow_s <- c(); ID <- c() #Non-stats identifiers; eg. infant ID, infant age etc
  PrevStEff <- c(); PrevStP <- c(); PrevStCI_2_5 <- c(); PrevStCI_97_5 <- c() #Previous step size stats results
  ResponseEff = c(); ResponseP = c(); ResponseCI_2_5 = c(); ResponseCI_97_5 = c() #response effect stats results
  
  Ctr <- 0; #initialise counter variable
  
  for (i in FilesToLoad){ #go through file list
    
    #print(i)
    
    RespWinVal <- gsub('.*_','',gsub('s_IviOnly.csv','',i)) #get response window value
    if (str_contains(i,RespToSpkr)){ #check if file name has the target string
      
      DataTab <- read_csv(i); attach(DataTab) #read table and attach
      
      u_Age <- c(3,6,9,18); u_ID <- unique(DataTab$InfantID) #Get unique ages and infant IDs; note that we are only using ages 3, 6, 9, and 18 months
      
      for (i_age in u_Age){ #do analyses separately for different ages
        for (i_ID in u_ID){ #and for different IDs, so we have effect sizes at the recording day level
          
          #print(i_ID); print(i_age)  
          
          SubsetTab <- filter(DataTab, AgeMonths == i_age & InfantID == i_ID) #subset for age in months and child id
          if (nrow(SubsetTab) > 1){ #continue if there are at least two non-empty rows
            
            ResponseVar = SubsetTab$Response #get response variable
            for (j in 2){ #:6

              CurrVar <- log10(SubsetTab[,j] + (10^-10)); PrevVar = log10(SubsetTab[,j+1] + (10^-10))#log variables #PrevVar = log10(SubsetTab[,j+7] + (10^-10))
              
              if(nrow(na.omit(CurrVar)) > 1 & nrow(na.omit(PrevVar)) > 1){ #proceed only if there is more than one row (after removing NAN) in botb Curr and Prev variables
                Ctr <- Ctr + 1 #increment counter
                LmMdl_PrevSt <- lm(scale(CurrVar) ~  scale(PrevVar),na.action=na.exclude) #run just prev var model and get residuals; exclude Steps that are NA
                PrevStSummary <- summary(LmMdl_PrevSt); PrevStCIs <- confint(LmMdl_PrevSt) #get stats summaries
                ResidVar <- resid(LmMdl_PrevSt)
                
                TabForLm <- tibble(ResidVar,ResponseVar) #get table for linear model so we can subset only non-NaN responses
                LmSubsetTab <- filter(TabForLm,!is.nan(ResponseVar) & !is.na(ResidVar)) #filter for non-NaN repsonse values ONLY and non-NA residuals
                ResponseVarForLm <- as_factor(LmSubsetTab$ResponseVar) 
                
                if (nlevels(ResponseVarForLm) > 1){ #Proceed only if there are both Yes (1) and No (0) responses
                  LmMdl_Resp <- lm(scale(LmSubsetTab$ResidVar) ~ ResponseVarForLm) #run response effect on residuals
                  RespSummary <- summary(LmMdl_Resp); RespCIs <- confint(LmMdl_Resp) #get stats summaries
                  
                  ResponseEff[Ctr] <- RespSummary$coefficients[2,1] 
                  ResponseP[Ctr] <- RespSummary$coefficients[2,4]
                  ResponseCI_2_5[Ctr] <- RespCIs[2,1]
                  ResponseCI_97_5[Ctr] <- RespCIs[2,2]
                }else{
                  ResponseEff[Ctr] <- NA 
                  ResponseP[Ctr] <- NA
                  ResponseCI_2_5[Ctr] <- NA
                  ResponseCI_97_5[Ctr] <- NA
                }
              
                #store results
                StepType[Ctr] <- gsub('Curr','',colnames(SubsetTab)[j]) 
                RespWindow_s[Ctr] <- RespWinVal; InfAgeMnth[Ctr] <- i_age; ID[Ctr] <- i_ID
                
                PrevStEff[Ctr] <- PrevStSummary$coefficients[2,1] 
                PrevStP[Ctr] <- PrevStSummary$coefficients[2,4] 
                PrevStCI_2_5[Ctr] <- PrevStCIs[2,1]
                PrevStCI_97_5[Ctr] <- PrevStCIs[2,2]
              }
            }
          }
        } 
      }
      detach(DataTab)
    }
  }
  
  OpTab <- tibble(RespWindow_s,StepType,InfAgeMnth,ID,
                PrevStEff,PrevStP,PrevStCI_2_5,PrevStCI_97_5,
                ResponseEff,ResponseP,ResponseCI_2_5,ResponseCI_97_5)
  return(OpTab)
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 2: function to get response effect beta values WITHOUT the precdeing Current step size ~ Previous step size analysis, at the recording level.
#Note that this is done in two steps because the CurrStepSi ~ PrevStSi analyses are carried out on all non-NaN steps, but the response analyses are only done on steps
#associated with non-NA responses
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetRespEffNoPrevStSiCtrl_RecordingLevel <- function(FilesToLoad,RespToSpkr){
  
  #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr; eg. ANRespToCHNSP), performs the
  #response effect analysis WITHOUT controlling for the effect of any intrinsic vocalisation pattern of the target speaker, and outputs the results of stastitical analyses as a tibble.
  
  #Note that in this version of the function, we do the analyses at the recording-day level
  
  #initialise vectors to iteratively store output in
  StepType <- c(); InfAgeMnth <- c(); RespWindow_s <- c(); ID <- c() #Non-stats identifiers; eg. infant ID, infant age etc
  ResponseEff = c(); ResponseP = c(); ResponseCI_2_5 = c(); ResponseCI_97_5 = c() #response effect stats results
  
  Ctr <- 0; #initialise counter variable
  
  for (i in FilesToLoad){ #go through file list
    if (str_contains(i,RespToSpkr)){ #check if file name has the target string
      
      DataTab <- read_csv(i); attach(DataTab) #read table
      DataTab <- filter(DataTab,!is.nan(Response)) #filter NaN responses
      
      RespWindowVal <- gsub('.*_','',gsub('s_IviOnly.csv','',i)) #get response window value
      u_Age <- c(3,6,9,18); u_ID <- unique(DataTab$InfantID) #Get unique ages and infant IDs; note that we are only using ages 3, 6, 9, and 18 months
      
      for (i_age in u_Age){ #do analyses separately for different ages
        for (i_ID in u_ID){ #and for different IDs, so we have effect sizes at the recording day level
        
          SubsetTab <- filter(DataTab, AgeMonths == i_age & InfantID == i_ID) #subset for age in months and child id
          if (nrow(SubsetTab) > 1){ #continue if there are at least two non-empty rows
            
            ResponseVar <- as_factor(SubsetTab$Response) #get age, ID, and response
            
            for (j in 2){#1:6
              
              #print(j)
              CurrVar <- log10(SubsetTab[,j] + (10^-10)) #log variables
              
              if(nrow(na.omit(CurrVar)) > 1 & nlevels(ResponseVar) > 1){ #proceed only if there is more than one row (after removing NAN) in CurrVar 
                #AND if there are both Yes (1) and No (0) responses
              
                Ctr <- Ctr + 1
                
                LmMdl_Resp <- lm(scale(CurrVar) ~ ResponseVar)  #run response effect on residuals
                RespSummary <- summary(LmMdl_Resp); RespCIs <- confint(LmMdl_Resp)
                
                StepType[Ctr] <- gsub('Curr','',colnames(SubsetTab)[j]) #save results
                RespWindow_s[Ctr] <- RespWindowVal; InfAgeMnth[Ctr] <- i_age; ID[Ctr] <- i_ID
                
                ResponseEff[Ctr] <- RespSummary$coefficients[2,1] 
                ResponseP[Ctr] <- RespSummary$coefficients[2,4]
                ResponseCI_2_5[Ctr] <- RespCIs[2,1]
                ResponseCI_97_5[Ctr] <- RespCIs[2,2]
              }
            }
          }
        } 
      }
      detach(DataTab)
    }
  }
  
  OpTab <- tibble(RespWindow_s,StepType, InfAgeMnth, ID,
                  ResponseEff,ResponseP,ResponseCI_2_5,ResponseCI_97_5)
  return(OpTab)
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 3: This function takes the data table that has the recording level stats outputed by the previous function (GetRespEff_w_PrevStSiCtrl), and does an linear 
#mixed effects model with Age and Age^2. That is, we get how the response effect changes with age
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetLmerAgeEffOnRespBeta <- function(DataTab,PrevStCtrlFlag){
  
  #initialise vectors to iteratively store output in
  StepType_Temp <- c(); RespWindow_Temp <- c(); PrevStCtrl <- c() #Non-stats identifiers; eg. infant ID, infant age etc
  Age1Eff <- c(); Age1P <- c(); Age1CI_2_5 <- c(); Age1CI_97_5 <- c() #age (linear) results
  Age2Eff <- c(); Age2P <- c(); Age2CI_2_5 <- c(); Age2CI_97_5 <- c() #age^2 results
  InterceptVal <- c(); InterceptCI_2_5 <- c(); InterceptCI_97_5 <- c()
  
  Ctr <- 0 #intialise counter variable
  
  attach(DataTab)
  
  u_RespWin <- unique(DataTab$RespWindow_s); u_StepType <- unique(DataTab$StepType) #get unique values of responsewindow and step varible
  
  for (i_respwin in u_RespWin){
    for (i_step in u_StepType){
      
      #print(i_respwin); print(i_step)
      
      Ctr <- Ctr + 1 #increment counter variable
      SubsetTab <- filter(DataTab, StepType == i_step & RespWindow_s == i_respwin) #subset for each combo of response window and step type
      SubsetTabFiltered <- filter(SubsetTab,!is.na(ResponseEff)) #Remove NAs
      IDvar <- as_factor(SubsetTabFiltered$ID) #make infant ID categorical variable
      LmerMdl <- lmer(SubsetTabFiltered$ResponseEff ~  (1|IDvar) + poly(SubsetTabFiltered$InfAgeMnth,2, raw = TRUE)) #note that we are not scaling anything
      LmerSummary <- summary(LmerMdl); LmerCIs <- confint(LmerMdl) #get stats results
      
      #store results
      StepType_Temp[Ctr] <- i_step; RespWindow_Temp[Ctr] <- i_respwin; PrevStCtrl[Ctr] <- PrevStCtrlFlag
      
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
    }
  }
  detach(DataTab)
  
  RespWindow_s <- RespWindow_Temp; StepType <- StepType_Temp #rename vars
  OpTab <- tibble(StepType,RespWindow_s,PrevStCtrl,
                  InterceptVal,InterceptCI_2_5,InterceptCI_97_5,
                  Age1Eff,Age1P,Age1CI_2_5,Age1CI_97_5,
                  Age2Eff,Age2P,Age2CI_2_5,Age2CI_97_5)
  return(OpTab)
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 3: This function takes the list of files to run the analyses on, runs the prev two functions, and writes output.
#Inputs are - the working directory path (WorkingDir)
           #- the string pattern to match to get the required files (FilePattern)
           #- the type of data we are dealing with (eg. LENA, LENA5min, Hum) (DataType)

#Note that all inputs are strings
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteOpToFile_RecLvlRespBeta_AgeEffOnRespBeta <- function(WorkingDir,FilePattern,DataType){
  
  setwd(WorkingDir) #set working directory
  FilesToLoad <- list.files(path = getwd(),pattern = FilePattern)  #get list of required files
  
  for (RespType in c('ANRespToCHNSP','CHNSPRespToAN')){ #go through the response-to-speaker types
  
    RecLvlStats_wCtrl_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_RespEff_W_CurrPrevStSizCtrl_VarsScaleLog_RecDayLvl_IviOnly.csv'))) #get file names to save
    RecLvlStats_NoCtrl_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_RespEff_NoPrevStSizCtrl_VarsScaleLog_RecDayLvl_IviOnly.csv'))) #get file names to save
    AgeEff_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_AgeEffOnRespEff_wAndWo_CurrPrevStSizCtrl_RawPolyAge_IviOnly.csv')))
    
    RecLvlRespStats_wStSiCtrl <- GetRespEff_w_PrevStSiCtrl_RecordingLevel(FilesToLoad,RespType) #Get rec level response effect and prev step size effect stats (these are betas)
    write.csv(RecLvlRespStats_wStSiCtrl, file = RecLvlStats_wCtrl_Fname,row.names=FALSE) #write file
    
    RecLvlRespStats_NoStSiCtrl <- GetRespEffNoPrevStSiCtrl_RecordingLevel(FilesToLoad,RespType) #Get rec level response effect w/o prev step size effect (these are betas)
    write.csv(RecLvlRespStats_NoStSiCtrl, file = RecLvlStats_NoCtrl_Fname,row.names=FALSE) #write file
    
    AgeEffForRespBeta_w_PrevStSiCtrl = GetLmerAgeEffOnRespBeta(RecLvlRespStats_wStSiCtrl,PrevStCtrlFlag = 'Yes') #get age effects on response betas (these are B's because we are not doing scale(age))
    AgeEffForRespBeta_No_PrevStSiCtrl = GetLmerAgeEffOnRespBeta(RecLvlRespStats_NoStSiCtrl,PrevStCtrlFlag = 'No') #get age effects on response betas (these are B's because we are not doing scale(age))
    AgeEffForRespBeta = bind_rows(AgeEffForRespBeta_No_PrevStSiCtrl,AgeEffForRespBeta_w_PrevStSiCtrl)
    write.csv(AgeEffForRespBeta, file = AgeEff_Fname,row.names=FALSE) #write file
  }
}

