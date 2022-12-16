#Ritwika VPS
#R script to do stats on step sizes since last response and other dependant variables

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

#set working directiro
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/')
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Change path accordingly
#other options for the path:
  #'~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/'
  #'~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/'
  #'~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/'
#------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#from basic plotting, it looks like the absolute values of pitch, amp, duration steps + intervoc int + 2d and 3d space steps + base duration variable need loging both axes
#abs and directional duration step wrt the last RESPONSE voc + base variables pitch and amp require only logging X axis

#Initialise vectors to store results for result df
Speaker = c()
DependentVar = c()

#Effects and p values
LogAgeEffect = c()
AgePvalue = c()
TimeSinceLastResponseEffect = c() #this is for vocs without an intervening OTHER response type as well as for acoustic dimensions (pitch, duration, amplitude), 
#as well as for step sizes of the current speaker type voc from the last OTHER response type
TimeSinceLastResponsePvalue = c()
TimeToLastResponseEffect = c() #these two time vars are for vocs with an intervening OTHER response type
TimeToLastResponsePvalue = c()
TimeFromLastResponseEffect = c()
TimeFromLastResponsePvalue = c()

Ctr = 0; #counts each lmer test

FilesToLoad = dir(path=".", pattern="*.csv*") #dir files
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Make sure that there are no .csv extension files from previous stats runs. If yes, these will also be read in and interfere with the script
#------------------------------------------------------------------------------------------------------------------------------------------------------------


for (i in 1:numel(FilesToLoad)){ #go through files
  
  TempStr <- as.matrix(unlist(strsplit(FilesToLoad[i],"_",fixed=TRUE))) #splits file name, and converts the list to a matrix
  SpeakerStr = toupper(TempStr[1]) #get Speaker type
  
  mydata = read.csv(FilesToLoad[i], header = TRUE) #read file
          #colnames(mydata)
  attach(mydata) #attach data
  
  AgeVar = log10(mydata$ChildAgeDays) #Log age age 
  ID = as.factor(mydata$ChildID) #specify ID as a categorical variable
  
  #Get indices of fixed effects (other than age)
  if (str_contains(colnames(mydata)[1],'Since',ignore.case = TRUE)){ #if yes, then we are dealing with non intervening step sizes, and only require the first column 
    #for the time varaible
    for (j in 2:(numel(colnames(mydata))-3)){ # go through all dependent vars
      
                    #print(j) #DEBUGGING
      
      Ctr = Ctr + 1 #update Ctr
      
      YVar = log10(abs(mydata[,j]) + (10^(-10))) #get Y variable; we will add exceptions to this in the next few lines; add small number so log10 of this won't be inf
      
      if ((str_contains(colnames(mydata)[j],'DurStepFromLastResponse',ignore.case = TRUE)) ||
          (str_contains(colnames(mydata)[j],'PitchVar',ignore.case = TRUE)) || 
          (str_contains(colnames(mydata)[j],'AmpVar',ignore.case = TRUE))){ # if the variable is not an directional duration step or acoustic space variable
           
           YVar = mydata[,j] #if Yvar is one of the ones that need to be not logged and abs values, get Y variable accordingly
           
      } 
      
      TimeSinceVar = mydata$TimeSinceLastResponse #get time variable
      
      #TimeSinceVar[!is.finite(log10(TimeSinceVar))] = NA #remove all infinite values after transformation
      #YVar[!is.finite(YVar)] = NA #Instead of doing this, add a smol number, say 10^-6 to the zero
      
      LmerModelFormula = lmer(scale(YVar) ~ (1|ID) + scale(log10(TimeSinceVar + (10^(-10)))) + scale(AgeVar)) #do lmer
      StatsSummary = summary(LmerModelFormula) #get summary
      
      #update vectors storing results
      Speaker[Ctr] = SpeakerStr 
      DependentVar[Ctr] = colnames(mydata)[j] #save dependent variable name; if there is directional in the name, replace it with Abs
      
      TimeSinceLastResponseEffect[Ctr] = StatsSummary$coefficients[2,1]
      TimeSinceLastResponsePvalue[Ctr] = StatsSummary$coefficients[2,5]
      LogAgeEffect[Ctr] = StatsSummary$coefficients[3,1]
      AgePvalue[Ctr] = StatsSummary$coefficients[3,5]
      TimeToLastResponseEffect[Ctr] = '-' #these two time vars are for vocs with an intervening OTHER response type
      TimeToLastResponsePvalue[Ctr] = '-'
      TimeFromLastResponseEffect[Ctr] = '-'
      TimeFromLastResponsePvalue[Ctr] = '-'
      
    }
    
  } else { #if data is for intervening step sizes
    for (j in 3:(numel(colnames(mydata))-3)){ # go through all dependent vars
      
                #print(j)
      
      Ctr = Ctr + 1 #update Ctr
      
      YVar = log10(abs(mydata[,j]) + (10^(-10))) #get Y variable; we will add exceptions to this in the next few lines
      
      if ((str_contains(colnames(mydata)[j],'DurStepFromLastResponse',ignore.case = TRUE)) ||
          (str_contains(colnames(mydata)[j],'PitchVar',ignore.case = TRUE)) || 
           (str_contains(colnames(mydata)[j],'AmpVar',ignore.case = TRUE))){ # if the variable is not an acoustic space dimension
             
        YVar = mydata[,j] #if Yvar is one of the ones that need to be not logged and abs values, get Y variable accordingly
             
      } 
           
      TimeToResponseVar = mydata$TimeToResponse
      TimeFromResponseVar = mydata$TimeFromResponse
      
      #TimeToResponseVar[!is.finite(log10(TimeToResponseVar))] = NA #remove all infinite values after transformation
      #TimeFromResponseVar[!is.finite(log10(TimeFromResponseVar))] = NA
      #YVar[!is.finite(YVar)] = NA
      
      LmerModelFormula = lmer(scale(YVar) ~ (1|ID) + scale(log10(TimeToResponseVar + (10^(-10)))) + scale(log10(TimeFromResponseVar + (10^(-10)))) + scale(AgeVar)) #do lmer
      StatsSummary = summary(LmerModelFormula) #get summary
      
      #update vectors storing results
      Speaker[Ctr] = SpeakerStr 
      DependentVar[Ctr] = colnames(mydata)[j] #save dependent variable name
      
      TimeSinceLastResponseEffect[Ctr] = '-' #this timevar is for vocs without an intervening OTHER response type
      TimeSinceLastResponsePvalue[Ctr] = '-'
      LogAgeEffect[Ctr] = StatsSummary$coefficients[4,1]
      AgePvalue[Ctr] = StatsSummary$coefficients[4,5]
      TimeToLastResponseEffect[Ctr] = StatsSummary$coefficients[2,1]  
      TimeToLastResponsePvalue[Ctr] = StatsSummary$coefficients[2,5]
      TimeFromLastResponseEffect[Ctr] = StatsSummary$coefficients[3,1]
      TimeFromLastResponsePvalue[Ctr] = StatsSummary$coefficients[3,5]
           
    }
  }
  
  detach(mydata)

}

#write stats results to csv
StatsResultsTab <- list(as.data.frame(Speaker), as.data.frame(DependentVar),  as.data.frame(LogAgeEffect),as.data.frame(AgePvalue),
                        as.data.frame(TimeSinceLastResponseEffect),as.data.frame(TimeSinceLastResponsePvalue),as.data.frame(TimeToLastResponseEffect),
                        as.data.frame(TimeToLastResponsePvalue), as.data.frame(TimeFromLastResponseEffect),as.data.frame(TimeFromLastResponsePvalue))
write.csv(StatsResultsTab, file = "TimeSinceLastResponseStats_5minLENALabel.csv",row.names=FALSE)
#other options: TimeSinceLastResponseStats_LENALabel.csv, TimeSinceLastResponseStats_5minLENALabel.csv, TimeSinceLastResponseStats_HumLabel.csv
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Rename results table accordingly
#------------------------------------------------------------------------------------------------------------------------------------------------------------


