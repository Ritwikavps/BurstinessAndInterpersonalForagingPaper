#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 1: #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr;
#eg. ANRespToCHNSP), performs the two-step response effect analysis controlling for the effect of any intrinsic vocalisation pattern of the 
#target speaker, and outputs the results of stastitical analyses as a tibble
#Here, we implement two steps: get the previous step size beta values, and then, response effect beta values based on residuals of the Current step size ~ Previous step size analyses.
#Note that this is done in two steps because the CurrStepSi ~ PrevStSi analyses are carried out on all non-NaN steps, but the response analyses are only done on steps
#associated with non-NA responses
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GetRespEff_w_PrevStSiCtrl_100sCutOff <- function(FilesToLoad,RespToSpkr){
  
  StepVar <- c(); AgeMnth <- c(); RespWindow <- c(); IviSubset <- c() #initialise vectors to iteratively store output in
  PrevStEff <- c(); PrevStP <- c(); PrevStCI_2_5 <- c(); PrevStCI_97_5 <- c()
  ResponseEff <- c(); ResponseP <- c(); ResponseCI_2_5 <- c(); ResponseCI_97_5 <- c()
  
  Ctr <- 0; #initialise counter variable
  LessOrGreaterThan100IvI <- c('LessThan100','GreaterThan100')
  
  for (i in FilesToLoad){ #go through file list
    if (str_contains(i,RespToSpkr)){ #check if file name has the target string
      
      DataTab <- read_csv(i); attach(DataTab) #read table
      
      RespWindowVal <- gsub('.*_','',gsub('s_IviOnly.csv','',i)) #get response window value
      
      for (k in c(3, 6, 9, 18)){ #do analyses separately for different ages
        for (IviCutOff in LessOrGreaterThan100IvI){
          
          if (strcmpi(IviCutOff,'LessThan100')){ #implement testing for current Ivis less than 100s and greater than 100s (less than 100s is about the order of mag of Ivis in the validation 
            #dataset, while after 100s is only in the LENA daylong set, so this is the 'tail', so to say
            Ivi100SubTab <- filter(DataTab, CurrInterVocInt <= 100)
          }else if (strcmpi(IviCutOff,'GreaterThan100')){
            Ivi100SubTab <- filter(DataTab, CurrInterVocInt > 100)
          }
        
          SubsetTab <- filter(Ivi100SubTab, AgeMonths == k) #subset for age in months
          ID <- as_factor(SubsetTab$InfantID); ResponseVar <- SubsetTab$Response #get ID and response
          
          for (j in 2){#1:6
            
            #print(j)
            CurrVar <- log10(SubsetTab[,j] + (10^-10)); PrevVar <- log10(SubsetTab[,j+1] + (10^-10)) #log variables #PrevVar <- log10(SubsetTab[,j+7] + (10^-10))
            
            Ctr <- Ctr + 1
            
            #run just prev var model and get residuals
            LmerMdl_PrevSt <- lmer(scale(CurrVar) ~(1|ID) + scale(PrevVar),na.action=na.exclude)
            PrevStSummary <- summary(LmerMdl_PrevSt); PrevStCIs <- confint(LmerMdl_PrevSt)
            ResidVar <- resid(LmerMdl_PrevSt)
            
            TabForLm <- tibble(ResidVar,ResponseVar) #get table for linear model so we can subset only non-NaN responses
            LmSubsetTab <- filter(TabForLm,!is.nan(ResponseVar)) #filter for non-NaN repsonse values ONLY
            
            Response <- as_factor(LmSubsetTab$ResponseVar) 
            
            #run response effect on residuals
            LmMdl_Resp <- lm(scale(LmSubsetTab$ResidVar) ~ Response) #+ poly(Age,2,raw = TRUE) + poly(Age,2,raw = TRUE)*Response)
            RespSummary <- summary(LmMdl_Resp); RespCIs <- confint(LmMdl_Resp)
            
            #store results
            StepVar[Ctr] <- gsub('Curr','',colnames(SubsetTab)[j]); RespWindow[Ctr] <- RespWindowVal; AgeMnth[Ctr] <- k; IviSubset[Ctr] <- IviCutOff
            PrevStEff[Ctr] <- PrevStSummary$coefficients[2,1] 
            PrevStP[Ctr] <- PrevStSummary$coefficients[2,5] 
            PrevStCI_2_5[Ctr] <- PrevStCIs[4,1]
            PrevStCI_97_5[Ctr] <- PrevStCIs[4,2]
            
            ResponseEff[Ctr] <- RespSummary$coefficients[2,1] 
            ResponseP[Ctr] <- RespSummary$coefficients[2,4]
            ResponseCI_2_5[Ctr] <- RespCIs[2,1]
            ResponseCI_97_5[Ctr] <- RespCIs[2,2]
          } 
        }   
      }
      detach(DataTab)
    }
  }
  
  OpTab <- tibble(RespWindow,StepVar,AgeMnth,IviSubset,
                  PrevStEff,PrevStP,PrevStCI_2_5,PrevStCI_97_5,
                  ResponseEff,ResponseP,ResponseCI_2_5,ResponseCI_97_5)
  return(OpTab)
}

# #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# #Fn 2: #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr;
# #eg. ANRespToCHNSP), performs the response effect analysis *WITHOUT* controlling for the effect of any intrinsic vocalisation pattern of the 
# #target speaker, and outputs the results of stastitical analyses as a tibble
# #---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# GetRespEffNoPrevStSiCtrl <- function(FilesToLoad,RespToSpkr){
#   
#   StepVar <- c(); AgeMnth <- c(); RespWindow <- c() #initialise vectors to iteratively store output in
#   ResponseEff <- c(); ResponseP <- c(); ResponseCI_2_5 <- c(); ResponseCI_97_5 <- c()
#   
#   Ctr <- 0; #initialise counter variable
#   
#   for (i in FilesToLoad){ #go through file list
#     if (str_contains(i,RespToSpkr)){ #check if file name has the target string
#       
#       DataTab <- read_csv(i); attach(DataTab) #read table
#       
#       DataTab <- filter(DataTab,!is.nan(Response)) #filter NaN responses
#       RespWindowVal <- gsub('.*_','',gsub('s_IviOnly.csv','',i)) #get response window value
#       
#       for (k in c(3, 6, 9, 18)){ #do analyses separately for different ages
#         
#         SubsetTab <- filter(DataTab, AgeMonths == k) #subset for age in months
#         ID <- as_factor(SubsetTab$InfantID); ResponseVar <- as_factor(SubsetTab$Response) #get age, ID, and response
#         
#         for (j in 2){#1:6
#           
#           #print(j)
#           CurrVar <- log10(SubsetTab[,j] + (10^-10)) #log variables
#           
#           Ctr <- Ctr + 1
#           
#           LmerMdl_Resp <- lmer(scale(CurrVar) ~ ResponseVar + (1|ID))  #run response effect on residuals
#           RespSummary <- summary(LmerMdl_Resp); RespCIs <- confint(LmerMdl_Resp)
#           
#           StepVar[Ctr] <- gsub('Curr','',colnames(SubsetTab)[j]) #save results
#           RespWindow[Ctr] <- RespWindowVal
#           AgeMnth[Ctr] <- k
#           
#           ResponseEff[Ctr] <- RespSummary$coefficients[2,1] 
#           ResponseP[Ctr] <- RespSummary$coefficients[2,5]
#           ResponseCI_2_5[Ctr] <- RespCIs[4,1]
#           ResponseCI_97_5[Ctr] <- RespCIs[4,2]
#         } 
#       }
#       detach(DataTab)
#     }
#   }
#   
#   OpTab <- tibble(RespWindow,StepVar, AgeMnth,
#                   ResponseEff,ResponseP,ResponseCI_2_5,ResponseCI_97_5)
#   return(OpTab)
# }

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 2: #This function takes the list of files to run the analyses on, runs the prev two functions, and writes output.
#Inputs are - the working directory path (WorkingDir)
#- the string pattern to match to get the required files (FilePattern)
#- the type of data we are dealing with (eg. LENA, LENA5min, Hum) (DataType)

#Note that all inputs are strings
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteOpToFile_RespEffBetas_100sCutOff <- function(WorkingDir,FilePattern,DataType){
  
  setwd(WorkingDir) #set working directory
  FilesToLoad <- list.files(path = getwd(),pattern = FilePattern)  #get list of required files
  
  for (RespType in c('ANRespToCHNSP','CHNSPRespToAN')){ #go through the response-to-speaker types
    
    wCtrl_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_RespEff_W_PrevStSizCtrl_VarsScaleLog_CorpusLvl_100sCutOff_IviOnly.csv'))) #get file names to save
    #woCtrl_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_RespEff_NoPrevStSizCtrl_DurLogZ_VarsScaleLog_CorpusLvl_IviOnly.csv')))
    
    #WITH prev step size control
    Stats_wStSiCtrl <- GetRespEff_w_PrevStSiCtrl_100sCutOff(FilesToLoad,RespType) #Get rec level response effect and prev step size effect stats (these are betas)
    write.csv(Stats_wStSiCtrl, file = wCtrl_Fname,row.names=FALSE) #write file
    
    #WITHOUT prev step size control
    #Stats_No_StSiCtrl = GetRespEffNoPrevStSiCtrl(FilesToLoad,RespType) #get age effects on response betas (these are B's because we are not doing scale(age))
    #write.csv(Stats_No_StSiCtrl, file = woCtrl_Fname,row.names=FALSE) #write file
  }
}
