#Ritwika VPS
#R script to compute correlations between acoustic space step size and intervocalisation interval, accounting for random effects due to 
#recordings from the same infant at different ages

#load required librarues
library(lme4)
library(lmerTest)
library(pracma)
library(sjmisc)

#set working directiro
setwd('~/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/RevisedResultswNewValidationCleanUpJune2023/')

#from basic plotting, it looks like the intervoc interval needs to be logged

#Initialise vectors to store results for result df
Speaker = c()
DataType = c() #human label, matched LENA 5 min, or LENA daylong
DependentVar = c() #2d or 3d space steps

#Effects and p values
Age1Effect = c()
Age1Pvalue = c()
Age2Effect = c()
Age2Pvalue = c()
IntervocIntEffect = c() 
IntervocIntPvalue = c()

Ctr = 0; #counts each lmer test

FilesToLoad = dir(path=".", pattern="*IntervocIntvsAcousticStepSize.csv*") #dir files
#------------------------------------------------------------------------------------------------------------------------------------------------------------
#Make sure that there are no .csv extension files from previous stats runs. If yes, these will also be read in and interfere with the script
#------------------------------------------------------------------------------------------------------------------------------------------------------------
for (i in 1:numel(FilesToLoad)){ #go through files
  
  TempStr <- as.matrix(unlist(strsplit(FilesToLoad[i],"_",fixed=TRUE))) #splits file name, and converts the list to a matrix
  SpeakerStr = toupper(TempStr[1]) #get Speaker type
  DataTypeStr = TempStr[2] #get the data type
  
  mydata = read.csv(FilesToLoad[i], header = TRUE) #read file
  colnames(mydata)
  attach(mydata) #attach data
  
  AgeVar = mydata$ChildAgeDays #Log age age 
  ID = as.factor(mydata$ChildId) #specify ID as a categorical variable
  Xvar = log10((mydata$InterVocInterval) + (10^(-10))) #add a small number so that the log10 of zero isn't infinity; also it appears as if only the 
  
  for (j in 1:2){ #our two dependent vars are the first and second columns, 2d and 3d acoustic space steps
    
    Ctr = Ctr + 1 #update Ctr
    
    Yvar = log10(abs(mydata[,j]) + (10^(-10)))
    
    LmerModelFormula = lmer(scale(Yvar) ~ (1|ID) + scale(Xvar) + poly(AgeVar,2,raw = TRUE)) #do lmer; raw = TRUE makes it so that this is just age + age.^2
    #Without raw = TRUE, there are co-efficients such that this is of the form ax + bx^2, where co-efficients a and b are orthogonal to each other and x = age. This
    #is so that coefficients a, b are the same those for higher order polynomials, eg. ax + bx^2 + cx^3, etc. 
    StatsSummary = summary(LmerModelFormula) #get summary
    
    #update vectors
    Speaker[Ctr] = SpeakerStr
    DataType[Ctr] = DataTypeStr
    DependentVar[Ctr] = colnames(mydata)[j]
    Age1Effect[Ctr] = StatsSummary$coefficients[3,1]
    Age1Pvalue[Ctr] = StatsSummary$coefficients[3,5]
    Age2Effect[Ctr] = StatsSummary$coefficients[4,1]
    Age2Pvalue[Ctr] = StatsSummary$coefficients[4,5]
    IntervocIntEffect[Ctr] = StatsSummary$coefficients[2,1]
    IntervocIntPvalue[Ctr] = StatsSummary$coefficients[2,5]
  }
  
  detach(mydata)
}

#write stats results to csv
StatsResultsTab <- list(as.data.frame(Speaker), as.data.frame(DataType),  as.data.frame(DependentVar),as.data.frame(Age1Effect),
                        as.data.frame(Age1Pvalue),as.data.frame(Age2Effect),as.data.frame(Age2Pvalue),
                        as.data.frame(IntervocIntEffect),as.data.frame(IntervocIntPvalue))
write.csv(StatsResultsTab, file = "AcousticStepSizesVsIntervocInterval_UnscaledRawPolyAgeStats_.csv",row.names=FALSE)

