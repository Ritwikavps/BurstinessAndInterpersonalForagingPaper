#Ritwika VPS
#R script to compute correlations between categorical step sizes (eg. steps between X and C type, or CHNSP and CHNNSP) and intervocalisation interval, 
#accounting for random effects due to recordings from the same infant at different ages

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/DataTablesForCategoricalStepSizesvsInterVocInterval/')

FilesToLoad = dir(path=".", pattern="*.csv*")

#Initialise vectors to store results for result df
StepSizeType = c() #CHNSP vs CHNNSP; or X vs C (the latter only for human labelled data)
DataType = c() #what is the data type? LENA daylong labels, etc. 

#Effects and p values
AgeEffect = c()
AgePvalue = c()
IntervocIntEffect = c() 
IntervocIntPvalue = c()

for (i in 1:numel(FilesToLoad)){ #go through the files
  
  TempStr <- strsplit(FilesToLoad[i],'_') #splits filename string at _; all file names are of the form <steptype>_<datatype>_CategoricalStSizvsInterVocInt.csv
  #So this strsplit will provide the step type and data type as the first two parts of the splot string
  
  StepSizeType[i] = TempStr[[1]][1] #assign step size type and data type
  DataType[i] = TempStr[[1]][2]
  
  mydata = read.csv(FilesToLoad[i], header = TRUE) #read file
  
  attach(mydata) #attach data
  
  if (str_contains(TempStr[[1]][1],'XC')){ #subset mydata if we are looking at X vs C, since this will largely be infant aged 9 and 18 months. 
    mydata = subset(mydata, ChildAgeMonth >= 8) 
  }
  
  AgeVar = mydata$ChildAgeDays
  ID = as.factor(mydata$ChildId)
  Yvar = mydata$CategoricalSteps
  Xvar = mydata$InterVocInterval
  
  LmerModelFormula = glmer((Yvar) ~ (1|ID) + scale(Xvar) + scale(AgeVar), family=binomial()) #do lmer
  StatsSummary = summary(LmerModelFormula) #get summary
  
  AgeEffect[i] = StatsSummary$coefficients[3,1]
  AgePvalue[i] = StatsSummary$coefficients[3,4]
  IntervocIntEffect[i] = StatsSummary$coefficients[2,1]
  IntervocIntPvalue[i] = StatsSummary$coefficients[2,4]
  
  detach(mydata)
}

#write stats results to csv
StatsResultsTab <- list(as.data.frame(StepSizeType),  as.data.frame(DataType),
                        as.data.frame(IntervocIntEffect),as.data.frame(IntervocIntPvalue),
                        as.data.frame(AgeEffect),as.data.frame(AgePvalue))
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/')
write.csv(StatsResultsTab, file = "CategoricalStepSizesVsIntervocInterval_Stats.csv",row.names=FALSE)



