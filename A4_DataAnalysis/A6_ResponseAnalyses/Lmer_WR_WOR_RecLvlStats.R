#Ritwika VPS
#R script to do linear mixed effects analysis on recording level summary measures (mean, median,std dev, 90 prctile) 
#with infant age and response (WR/WOR) as fixed effects and infant id as random effect

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

#set working directiro
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/DataTabsForStats/R6_DataTablesForResponseAnalyses/RecLvlSummaryStatistics/')

FilesToLoad = dir(path=".", pattern="*.csv*") #dir files
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Make sure that there are no .csv extension files from previous stats runs. If yes, these will also be read in and interfere with the script
#------------------------------------------------------------------------------------------------------------------------------------------------------------

Responder = c() #CHNSP, CHNNSP, AN, CHN
Speaker = c() #CHNSP, CHNNSP, AN, CHN
ResponseWindow = c() #1s, 2s, 5s
DependentVar = c() #2d or 3d space steps

#Effects and p values
AgeEffect = c()
AgePvalue = c()
ResponseEffect = c() 
ResponsePvalue = c()
AgeResponseInteractionEffect = c()
AgeResponseInteractionPvalue = c()

Ctr = 0 #counts each lmer test

for (i in 1:numel(FilesToLoad)){ #go through files
  
  #File names are of the form: mean_AnRespToChn_1s
  
  TempStr <- as.matrix(unlist(strsplit(FilesToLoad[i],"_",fixed=TRUE))) #splits file name, and converts the list to a matrix
  
  Spkr_str = gsub('.*RespTo','',TempStr[2]) #remove <>RespTo to get speaker
  Responder_str = gsub('RespTo.*','',TempStr[2]) # remove RespTo<> to get responder
  ResponseWin_str = gsub('.csv','',TempStr[3]) 
  
  mydata = read.csv(FilesToLoad[i], header = TRUE) #read file
  colnames(mydata)
  attach(mydata) #attach data
  
  AgeVar = mydata$AgeDays #Log age age 
  ResponseVar = as.factor(mydata$ResponseVec)
  ID = as.factor(mydata$InfantID) #specify ID as a categorical variable
  Xvar = log10((mydata$InterVocInterval) + (10^(-10)))
  
  for (j in 1:6){
    
    Yvar = mydata[,j]
    
    Ctr = Ctr + 1 #without age-respnse interaction
    LmerModelFormula = lmer(scale(Yvar) ~ (1|ID) + ResponseVar + scale(AgeVar)) 
    StatsSummary = summary(LmerModelFormula)
    
    Responder[Ctr] = Responder_str
    Speaker[Ctr] = Spkr_str
    ResponseWindow[Ctr] = ResponseWin_str
    DependentVar[Ctr] = colnames(mydata)[j]
    
    #Effects and p values
    AgeEffect[Ctr] = StatsSummary$coefficients[3,1]
    AgePvalue[Ctr] = StatsSummary$coefficients[3,5]
    ResponseEffect[Ctr] = StatsSummary$coefficients[2,1]
    ResponsePvalue[Ctr] = StatsSummary$coefficients[2,5]
    AgeResponseInteractionEffect[Ctr] = '_'
    AgeResponseInteractionPvalue[Ctr] = '_'
    
    Ctr = Ctr + 1 #with age-response interaction
    LmerModelFormula_wInterac = lmer(scale(Yvar) ~ (1|ID) + ResponseVar + scale(AgeVar) + scale(AgeVar)*ResponseVar)
    StatsSummary_wInterac = summary(LmerModelFormula_wInterac)
    
    Responder[Ctr] = Responder_str
    Speaker[Ctr] = Spkr_str
    ResponseWindow[Ctr] = ResponseWin_str
    DependentVar[Ctr] = colnames(mydata)[j]
    
    #Effects and p values
    AgeEffect[Ctr] = StatsSummary_wInterac$coefficients[3,1]
    AgePvalue[Ctr] = StatsSummary_wInterac$coefficients[3,5]
    ResponseEffect[Ctr] = StatsSummary_wInterac$coefficients[2,1]
    ResponsePvalue[Ctr] = StatsSummary_wInterac$coefficients[2,5]
    AgeResponseInteractionEffect[Ctr] = StatsSummary_wInterac$coefficients[4,1]
    AgeResponseInteractionPvalue[Ctr] = StatsSummary_wInterac$coefficients[4,5]
    
  }
  detach(mydata)
}

StatsResultsTab <- list(as.data.frame(Speaker), as.data.frame(Responder),  as.data.frame(ResponseWindow),as.data.frame(DependentVar),
                        as.data.frame(ResponseEffect),as.data.frame(ResponsePvalue),as.data.frame(AgeEffect),as.data.frame(AgePvalue),
                        as.data.frame(AgeResponseInteractionEffect),as.data.frame(AgeResponseInteractionPvalue))
write.csv(StatsResultsTab, file = "ResponseAnalyses_RecLvlLmerStats.csv",row.names=FALSE)
