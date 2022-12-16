#Ritwika VPS
#R script to do stats on absolute 'categorical' step sizes since last response  (ie, steps from X -> C are |+1| = 1 and C -> X are |-1| = 1, for example)
#That is, we are only looking at whether the infant remains in the same state or not

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

#get files to be read from all relevant directories
FilesDaylongLENA <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_ChnCategoricalStsiz_LENA', pattern="*InterveningCategoricalStSize.*csv", recursive=TRUE, full.names=TRUE)
Files5minHumLabel <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_ChnCategoricalStsiz_HumLabel',
                                pattern="*InterveningCategoricalStSize.*csv", recursive=TRUE, full.names=TRUE)
Files5minLENAmatch <- list.files('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_ChnCategoricalStsiz_MatchedLENA5minLabels',
                                 pattern="*InterveningCategoricalStSize.*csv", recursive=TRUE, full.names=TRUE)
FilesToLoad = c(FilesDaylongLENA,Files5minLENAmatch,Files5minHumLabel)

#Initialise vectors to store results for result df
StepSizeType = c() #CHNSP vs CHNNSP; or X vs C (the latter only for human labelled data)
DataType = c() #what is the data type? LENA daylong labels, etc. 

#Effects and p values
AgeEffect = c()
AgePvalue = c()
TimeSinceLastResponseEffect = c() #this is for vocs without an intervening OTHER response type as well as for acoustic dimensions (pitch, duration, amplitude), 
#as well as for step sizes of the current speaker type voc from the last OTHER response type
TimeSinceLastResponsePvalue = c()
TimeToLastResponseEffect = c() #these two time vars are for vocs with an intervening OTHER response type
TimeToLastResponsePvalue = c()
TimeFromLastResponseEffect = c()
TimeFromLastResponsePvalue = c()
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Make sure that there are no .csv extension files from previous stats runs. If yes, these will also be read in and interfere with the script
#------------------------------------------------------------------------------------------------------------------------------------------------------------
for (i in 1:numel(FilesToLoad)){ #go through files
  
  TempStr <- strsplit(gsub('.*/','',FilesToLoad[i]),'_') #removes everything before and including /, which gives us only the File Name, and then splits
  #the filename wherever there is a '_'
  
  StepSizeTypeStr = 'Chnsp to Chnnsp' #default string
  if (str_contains(TempStr[[1]][1],'Vs',ignore.case = TRUE)){ #data tables where there is adistinction in the categorical step size (Chnsp to Chnnsp; or X to C)
    #are only for human label data, and these file names have this info in the first portion of the output of the string split, so we only need
    #to do this if the condition is met
    StepSizeTypeStr = TempStr[[1]][1]
  }
  
  DataTypeStr = gsub('.csv','',TempStr[[1]][numel(TempStr[[1]])]) #the last string from the strsplit has info abot the data type; get that
  
  mydata = read.csv(FilesToLoad[i], header = TRUE) #read file
  #colnames(mydata)
  attach(mydata) #attach data
  
  if (str_contains(StepSizeTypeStr,'XvsC')){ #subset mydata if we are looking at X vs C, since this will largely be infant aged 9 and 18 months. 
    mydata = subset(mydata, ChildAgeMonths >= 8) 
  }
  
  AgeVar = mydata$ChildAgeDays
  ID = as.factor(mydata$ChildID) #specify ID as a categorical variable
  
  #Get indices of fixed effects (other than age)
  if (str_contains(colnames(mydata)[1],'Since',ignore.case = TRUE)){ #if yes, then we are dealing with non intervening step sizes, and only require the first column 
    #for the time varaible
    
    YVar = abs(mydata[,2]) #get Y variable
    
    TimeSinceVar = mydata$TimeSinceLastResponse #get time variable
    
    LmerModelFormula = glmer((YVar) ~ (1|ID) + scale(log10(TimeSinceVar + (10^(-10)))) + scale(AgeVar), family=binomial()) #do lmer
    StatsSummary = summary(LmerModelFormula) #get summary
    
    #update vectors storing results
    StepSizeType[i] = StepSizeTypeStr 
    DataType[i] = DataTypeStr
    
    TimeSinceLastResponseEffect[i] = StatsSummary$coefficients[2,1]
    TimeSinceLastResponsePvalue[i] = StatsSummary$coefficients[2,4]
    AgeEffect[i] = StatsSummary$coefficients[3,1]
    AgePvalue[i] = StatsSummary$coefficients[3,4]
    TimeToLastResponseEffect[i] = '-' #these two time vars are for vocs with an intervening OTHER response type
    TimeToLastResponsePvalue[i] = '-'
    TimeFromLastResponseEffect[i] = '-'
    TimeFromLastResponsePvalue[i] = '-'
    
  } else { #if data is for intervening step sizes
    
    YVar = abs(mydata[,3]) #get Y variable
    
    TimeToResponseVar = mydata$TimeToResponse
    TimeFromResponseVar = mydata$TimeFromResponse
    
    LmerModelFormula = glmer((YVar) ~ (1|ID) + scale(log10(TimeToResponseVar + (10^(-10)))) + scale(log10(TimeFromResponseVar + (10^(-10)))) + scale(AgeVar), family=binomial()) 
    StatsSummary = summary(LmerModelFormula) #get summary
    
    #update vectors storing results
    StepSizeType[i] = StepSizeTypeStr 
    DataType[i] = DataTypeStr
    
    TimeSinceLastResponseEffect[i] = '-' #this timevar is for vocs without an intervening OTHER response type
    TimeSinceLastResponsePvalue[i] = '-'
    AgeEffect[i] = StatsSummary$coefficients[4,1]
    AgePvalue[i] = StatsSummary$coefficients[4,4]
    TimeToLastResponseEffect[i] = StatsSummary$coefficients[2,1]  
    TimeToLastResponsePvalue[i] = StatsSummary$coefficients[2,4]
    TimeFromLastResponseEffect[i] = StatsSummary$coefficients[3,1]
    TimeFromLastResponsePvalue[i] = StatsSummary$coefficients[3,4]
    
  }
  
  detach(mydata)
  
}

#write stats results to csv
StatsResultsTab <- list(as.data.frame(StepSizeType),  as.data.frame(DataType),
                        as.data.frame(AgeEffect),as.data.frame(AgePvalue),
                        as.data.frame(TimeSinceLastResponseEffect),as.data.frame(TimeSinceLastResponsePvalue),
                        as.data.frame(TimeToLastResponseEffect),as.data.frame(TimeToLastResponsePvalue), 
                        as.data.frame(TimeFromLastResponseEffect),as.data.frame(TimeFromLastResponsePvalue))
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/')
write.csv(StatsResultsTab, file = " TimeSinceLastResponseVsNonDirectionalCategoricalStSizeStats.csv",row.names=FALSE)
