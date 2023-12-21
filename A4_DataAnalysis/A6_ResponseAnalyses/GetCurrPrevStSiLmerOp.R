GetCurrPrevStSiLmerOp <- function(FilesToLoad,RespToSpkr){
  
  #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr;
  #eg. ANRespToCHNSP), performs the two-step response effect analysis controlling for the effect of any intrinsic vocalisation pattern of the 
  #target speaker, and outputs the results of stastitical analyses as a tibble
  
  StepVar = c() #initialise vectors to iteratively store output in
  
  PrevStEff = c()
  PrevStP = c()
  PrevStCI_2_5 = c()
  PrevStCI_97_5 = c()
  
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
      
      RespWindowVal = gsub('s.csv','',gsub('.*_','',i)) #get response window value
      
      for (k in c(3, 6, 9, 18)){ #do analyses separately for different ages
        
        SubsetTab = filter(DataTab, AgeMonths == k) #subset for age in months
      
        Age = SubsetTab$AgeDays #get age, ID, and response
        ID = as_factor(SubsetTab$InfantID)
        ResponseVar = SubsetTab$Response
        
        for (j in 1:6){
          
          #print(j)
          
          CurrVar = log10(SubsetTab[,j] + (10^-10)) #log variables
          PrevVar = log10(SubsetTab[,j+8] + (10^-10))
          
          Ctr = Ctr + 1
          
          #run just prev var model and get residuals
          LmerMdl_PrevSt = lmer(scale(CurrVar) ~(1|ID) + scale(PrevVar),na.action=na.exclude)
          PrevStSummary = summary(LmerMdl_PrevSt)
          PrevStCIs = confint(LmerMdl_PrevSt)
          ResidVar = resid(LmerMdl_PrevSt)
          
          TabForLm = tibble(ResidVar,ResponseVar) #get table for linear model so we can subset only non-NaN responses
          LmSubsetTab = filter(TabForLm,!is.nan(ResponseVar)) #filter for non-NaN repsonse values ONLY
          
          Response = as_factor(LmSubsetTab$ResponseVar) 
          
          #run response effect on residuals
          LmMdl_Resp = lm(scale(LmSubsetTab$ResidVar) ~ Response)
          #+ poly(Age,2,raw = TRUE) + poly(Age,2,raw = TRUE)*Response)
          RespSummary = summary(LmMdl_Resp)
          RespCIs = confint(LmMdl_Resp)
          
          StepVar[Ctr] = gsub('Curr','',colnames(SubsetTab)[j])
          RespWindow[Ctr] = RespWindowVal
          AgeMnth[Ctr] = k
          PrevStEff[Ctr] = PrevStSummary$coefficients[2,1] 
          PrevStP[Ctr] = PrevStSummary$coefficients[2,5] 
          PrevStCI_2_5[Ctr] = PrevStCIs[4,1]
          PrevStCI_97_5[Ctr] = PrevStCIs[4,2]
          
          ResponseEff[Ctr] = RespSummary$coefficients[2,1] 
          ResponseP[Ctr] = RespSummary$coefficients[2,4]
          ResponseCI_2_5[Ctr] = RespCIs[2,1]
          ResponseCI_97_5[Ctr] = RespCIs[2,2]
          
          # Age1Eff[Ctr] = RespSummary$coefficients[3,1]
          # Age1P[Ctr] = RespSummary$coefficients[3,5]
          # Age2Eff[Ctr] = RespSummary$coefficients[4,1]
          # Age2P[Ctr] = RespSummary$coefficients[4,5]
          # Age1RespEff[Ctr] = RespSummary$coefficients[5,1]
          # Age1RespP[Ctr] = RespSummary$coefficients[5,5]
          # Age2Resp[Ctr] = RespSummary$coefficients[6,1]
          # Age2RespP[Ctr] = RespSummary$coefficients[6,5]
        } 
      }

      detach(DataTab)
    }
  }
  
  OpTab <- list(as.data.frame(RespWindow),as.data.frame(StepVar), as.data.frame(AgeMnth),
                as.data.frame(PrevStEff),as.data.frame(PrevStP), as.data.frame(PrevStCI_2_5), as.data.frame(PrevStCI_97_5),
                as.data.frame(ResponseEff),as.data.frame(ResponseP),as.data.frame(ResponseCI_2_5),as.data.frame(ResponseCI_97_5))
               # as.data.frame(Age1Eff),
                #as.data.frame(Age1P),as.data.frame(Age2Eff),as.data.frame(Age2P))
                #,as.data.frame(Age1RespEff),as.data.frame(Age1RespP),as.data.frame(Age2Resp),as.data.frame(Age2RespP))
  
  return(OpTab)
}