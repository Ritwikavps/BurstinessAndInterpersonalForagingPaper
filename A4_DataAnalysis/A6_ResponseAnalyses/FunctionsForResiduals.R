#functions to get residuals of curr stp as a function of prev st size

###########################################################################################################################
#fn 1: get residual for any given input current and previous st size
###########################################################################################################################
GetCurrPrevRes <- function(CurrSt,PrevSt,LogOrNo){
  
  if (LogOrNo){ #checks if vars have to be logged (for inter voc int)
    Currst = log10(CurrSt)
    PrevSt = log10(PrevSt)
  }
  
  CurrPrevFit = lm(CurrSt ~ PrevSt,na.action = na.exclude) #get fit
  StSiRes = resid(CurrPrevFit) #get residuals
  
  return(StSiRes)
}

###########################################################################################################################
#fn 2: gets residuals for all relevant vars and reconstitutes the op table
###########################################################################################################################
GetResTab <- function(InputTab){
  
  for (i in 1:6){ #go through relevant vars
    
    if (str_contains(colnames(InputTab)[i],'InterVocInt')){
      LogOrNo = TRUE
    }else{
      LogOrNo = FALSE
    }
    
    Xvar = as.matrix(InputTab[,i+8]) #Not sure why I have to unlist; I have never had this problem, but if I don't I get an error
    Yvar = as.matrix(InputTab[,i])
    
    InputTab = cbind(InputTab,GetCurrPrevRes(Yvar,Xvar,LogOrNo))
    
    print(i)
  }
  
  return(InputTab)
}
  
  
###########################################################################################################################  
GetCurrPrevStResiduals <- function(InputTab){
  
  
  
  OpTab <- list(as.data.frame(RespWindow),as.data.frame(StepVar),
                as.data.frame(PrevStEff),as.data.frame(PrevStP),as.data.frame(ResponseEff),as.data.frame(ResponseP),as.data.frame(Age1Eff),
                as.data.frame(Age1P),as.data.frame(Age2Eff),as.data.frame(Age2P),as.data.frame(Age1RespEff),as.data.frame(Age1RespP),as.data.frame(Age2Resp),as.data.frame(Age2RespP))
  
  return(OpTab)
  
}