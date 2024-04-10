#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 1: function to test whether pair-wise response effects at different ages are different from each other or not, using lmer to control for random effects
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CompareRespEffCIsAtDiffAges <- function(FilesToLoad,RespToSpkr){

  #This functions takes the list of files in the directory (FilesToLoad) as well as a string identifying the target speaker and responder (RespToSpkr; eg. ANRespToCHNSP), 
  #performs pair-wise testing on response effects from two different infant ages to see if response effect at age A falls between CIs of response effect at age B 
  
  #initialise vectors to iteratively store output in
  StepType <- c(); InfAgeMnth_A <- c(); InfAgeMnth_B <- c(); RespWindow_s <- c(); #Non-stats identifiers; eg. step type, infant age etc
  Age1EffOlpwAge2CIs <- c(); RespEff_AgeA <- c(); RespEff_AgeB <- c() #stats results; note that RespEff_AgeA and RespEff_AgeB are simply the response beta values for a given age, and are inherited 
  #directly from the table(s) being read in
  
  Ctr <- 0; #initialise counter variable
  
  for (i in FilesToLoad){ #go through file list
    
    DataTab <- read_csv(i); attach(DataTab) #read table and attach
    
    u_Age <- c(3,6,9,18); u_Step <- unique(DataTab$StepVar); u_RespWin <- unique(DataTab$RespWindow) #get unique ages etc; note that we are only using ages 3, 6, 9, and 18 months
    Step_RespWin <- expand_grid(u_Step,u_RespWin)# #get all combos of step type and response window (to filter DataTab for each combo type)
    
    for (j in 1:nrow(Step_RespWin)){ #go through the list of all combos of step type and response window
      
      FilteredTab <- filter(DataTab, StepVar == Step_RespWin[[j,1]] & RespWindow == Step_RespWin[[j,2]]) #filter DataTab
      
      for (Age1Ind in 1:nrow(FilteredTab)){ #Go through ages (AgeA)
        if (Age1Ind != nrow(FilteredTab)){ #Now, check of the age index is the same as the total number of rows in the filtered tibble. If not, we go through 
          #all the other ages
          for (Age2Ind in (Age1Ind+1):nrow(FilteredTab)){
            #essentially, what we are doing is this: say number of rows in the filtered tibble is 4 (it usually is, because we have four ages), then, we start with Age1Ind = 1. Then, 
            #for Age2Ind, we have 2, 3, and 4. This way, we compare month 3 to months 6, 9, and 18. Going on like this, if Age1Ind = 3, then this corresponds to month 9 (usually), and we 
            #only need to compare month 9 to months 18. This is what the if statement above controls for. Finally, if Age1Ind = 4, then the rest of the loop isn't executed.
            
            #print(c(FilteredTab$AgeMnth[Age1Ind],FilteredTab$AgeMnth[Age2Ind])) #error check; uncomment as necessary
            Ctr <- Ctr + 1 #increment Ctr variable
            StepType[Ctr] <- Step_RespWin[[j,1]]; RespWindow_s[Ctr] <- Step_RespWin[[j,2]] #Populate initialised lists to store in output tibble
            InfAgeMnth_A[Ctr] <- FilteredTab$AgeMnth[Age1Ind]; InfAgeMnth_B[Ctr] <- FilteredTab$AgeMnth[Age2Ind]
            RespEff_AgeA[Ctr] <- FilteredTab$ResponseEff[Age1Ind]; RespEff_AgeB[Ctr] <- FilteredTab$ResponseEff[Age2Ind]
            Age1EffOlpwAge2CIs[Ctr] <- 1 #default; 1 for truw, ie, Age 1 effect falls between Age 2 CIs
            
            if (!between(FilteredTab$ResponseEff[Age1Ind],  FilteredTab$ResponseCI_2_5[Age2Ind],  FilteredTab$ResponseCI_97_5[Age2Ind])){ #check if Response effect for Age A is between CIs 
              #for the response effect for Age B
              
              Age1EffOlpwAge2CIs[Ctr] <- 0 # 0 for false
            }
          }
        }
      }
#LmerMdl <- lmer(FilteredTab$ResponseEff ~ AgeCateg + (1|IDVar)) #for each pair of ages
    }
    detach(DataTab)
  }
  OpTab <- tibble(StepType, RespWindow_s, InfAgeMnth_A, RespEff_AgeA, InfAgeMnth_B,  RespEff_AgeB, Age1EffOlpwAge2CIs)
  return(OpTab)
}

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Fn 2: This function takes the list of files to run the analyses on, runs the prev function, and writes output.
#Inputs are - the working directory path (WorkingDir)
#- the string pattern to match to get the required files (FilePattern)
#- the type of data we are dealing with (eg. LENA, LENA5min, Hum) (DataType)

#Note that all inputs are strings
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteOpToFile_AgeNonOlpCIsCheck <- function(WorkingDir,FilePattern,DataType){
  
  setwd(WorkingDir) #set working directory
  FilesToLoad <- list.files(path = getwd(),pattern = FilePattern)  #get list of required files
  
  for (RespType in c('ANRespToCHNSP','CHNSPRespToAN')){ #go through the response-to-speaker types
    
    Op_Fname <- strcat(DataType,strcat('_',strcat(RespType,'_RespEff_CIsOlpCheckForDiffAges.csv'))) #get file names to save
    OpTab <- CompareRespEffCIsAtDiffAges(FilesToLoad,RespType) #Get results checking if different response effects overlap with CIs at different ages
    write.csv(OpTab, file = Op_Fname,row.names=FALSE) #write file
  }
}