GetRespEffNoPrevStSiCtrlLmerOp <- function(FilesToLoad,RespToSpkr){
  
  #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr;
  #eg. ANRespToCHNSP), performs the response effect analysis *WITHOUT* controlling for the effect of any intrinsic vocalisation pattern of the 
  #target speaker, and outputs the results of stastitical analyses as a tibble
  
  StepVar = c() #initialise vectors to iteratively store output in
  
  ResponseEff = c()
  ResponseP = c()
  ResponseCI_2_5 = c()
  ResponseCI_97_5 = c()
  
  AgeMnth = c()
  
  RespWindow = c()
  
  Ctr = 0; #initialise counter variable
  
  for (i in FilesToLoad){ #go through file list
    if (str_contains(i,RespToSpkr)){ #check if file name has the target string
      
      DataTab = read_csv(i) #read table
      attach(DataTab)
      
      DataTab = filter(DataTab,!is.nan(Response)) #filter NaN responses
      RespWindowVal = gsub('s.csv','',gsub('.*_','',i)) #get response window value
      
      for (k in c(3, 6, 9, 18)){ #do analyses separately for different ages
        
        SubsetTab = filter(DataTab, AgeMonths == k) #subset for age in months
        
        Age = SubsetTab$AgeDays #get age, ID, and response
        ID = as_factor(SubsetTab$InfantID)
        ResponseVar = as_factor(SubsetTab$Response)
        
        for (j in 1:6){
          
          #print(j)
          
          CurrVar = log10(SubsetTab[,j] + (10^-10)) #log variables
          
          Ctr = Ctr + 1
          
          #run response effect on residuals
          LmerMdl_Resp = lmer(scale(CurrVar) ~ ResponseVar + (1|ID))
          #+ poly(Age,2,raw = TRUE) + poly(Age,2,raw = TRUE)*Response)
          RespSummary = summary(LmerMdl_Resp)
          RespCIs = confint(LmerMdl_Resp)
          
          StepVar[Ctr] = gsub('Curr','',colnames(SubsetTab)[j])
          RespWindow[Ctr] = RespWindowVal
          AgeMnth[Ctr] = k
          
          ResponseEff[Ctr] = RespSummary$coefficients[2,1] 
          ResponseP[Ctr] = RespSummary$coefficients[2,5]
          ResponseCI_2_5[Ctr] = RespCIs[4,1]
          ResponseCI_97_5[Ctr] = RespCIs[4,2]
        } 
      }
      detach(DataTab)
    }
  }
  
  OpTab <- list(as.data.frame(RespWindow),as.data.frame(StepVar), as.data.frame(AgeMnth),
                as.data.frame(ResponseEff),as.data.frame(ResponseP),as.data.frame(ResponseCI_2_5),as.data.frame(ResponseCI_97_5))
  # as.data.frame(Age1Eff),
  #as.data.frame(Age1P),as.data.frame(Age2Eff),as.data.frame(Age2P))
  #,as.data.frame(Age1RespEff),as.data.frame(Age1RespP),as.data.frame(Age2Resp),as.data.frame(Age2RespP))
  
  return(OpTab)
}