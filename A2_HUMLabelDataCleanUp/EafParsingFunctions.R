#Ritwika VPS, June 2022
#This script contains functions used to parse .eaf files
#Required libraries: sjmisc, stringr, pracma
#also make sure to be in the correct directory

########################################################################################################################################################################
#Function 1: Gets Time ref and corresponding time values from the block before annotations start
########################################################################################################################################################################
GetEafTimeRefTimeValue <- function(EafFileName){ 
  
  #Ritwiks VPS; May 2022
  #function to read in time slot refs for start and end times,
  #and time values
  
  #first, establish a connection (which is an interface to the file) to the desires .eaf file
  myCon = file(description = EafFilename, open="r", blocking = TRUE) #establish connection
  
  #initialise counter variable as well as vectors to store info in
  TimeSlotRef <- c()
  TimeVal <- c()
  TSref_ctr = 0
  
  repeat{ #repeat till line is the empty vector
    myLine = str_trim(readLines(myCon, n = 1)) # Read one line from the connection.
    
    #time slot ref and time matching block
    if(str_contains(myLine,'<TIME_SLOT TIME_SLOT_ID="')){
      
      #get time slot ref
      TSref_ctr = TSref_ctr + 1
      
      #first, sub <TIME_SLOT TIME_SLOT_ID=" with empty, then sub everything from and after" TIME_VALUE="
      #with empty, and finally
      TimeSlotRef[TSref_ctr] = gsub('" TIME_VALUE=".*',"",gsub('<TIME_SLOT TIME_SLOT_ID="',"",myLine))
      
      #get corresponding time
      #remove everything up to .*" TIME_VALUE=", then remove "/>' and convert to numeric
      TimeVal[TSref_ctr] = as.numeric(gsub('"/>',"",gsub('.*" TIME_VALUE="',"",myLine)))
      
    }
    
    if(identical(myLine, character(0))){
      break
    } # If the line is empty, exit.
    #print(myLine) # Otherwise, print and repeat next iteration.
  }
  
  #Explicitly opened connection needs to be explicitly closed.
  close(myCon)
  rm(myCon)
  
  #create output dataframe
  TimeRefVal_df <- data.frame(TimeSlotRef,TimeVal)
  
  return(TimeRefVal_df)
}

########################################################################################################################################################################
#Function 2: Gets all the details of annotations
########################################################################################################################################################################
GetAnnotationDetails <- function(EafFileName){ 
  
  #Ritwika VPS, June 2022
  #function to get details of annotations for all Tier iDs
  #outputs timeref 1 and 2, annotation, and annotation id, as well as line numbers for each
  
  #Required libraries: sjmisc, stringr
  #also make sure to be in the correct directory
  
  #define empty output df. This ca  be redefined if there *is* valid output
  TierInfo_df <- data.frame(matrix(ncol = 0, nrow = 0))
  
  #list of key tiers
  KeyTierList = c('Infant Voc Type', 'Adult Utterance Dir', 'Adult Ortho')
  
  ####################################################################################
  #we do this in three blocks: first, we identify all the tiers in the file, then we identify the line numbers associated with the
  #start and end of each annotation tier, and then, we parse out annotation details in each tier
  #first, establish a connection (which is an interface to the file) to the desires .eaf file
  myCon_TierIdList = file(description = EafFilename, open="r", blocking = TRUE) #establish connection
  
  #id all tier IDs
  TierIdIndexNum = 0 #initialise index variable for vector to store tier IDs
  TierIdVec = c() #initialise vector to store tier IDs
  
  repeat{ #repeat till line is the empty vector
    
    myLine = str_trim(readLines(myCon_TierIdList, n = 1)) # Read one line from the connection.
    
    #time slot ref and time matching block
    if ((str_contains(myLine,'LINGUISTIC_TYPE_REF="')) && (str_contains(myLine,'TIER_ID="'))){
      
      #get tier id for the tier
      TierIdCurrent = gsub(">","",gsub('.*TIER_ID="',"",myLine))
      
      #check if the tier id has already been stored (and that it is not the default id)
      if ((!(TierIdCurrent %in% TierIdVec)) && (!(str_contains(TierIdCurrent,'default',ignore.case = TRUE)))){ #checks if the current tier id is already in the vector of tier ids present in the file
        #TierIdCurrent %in% TierIdVec checks this. We only proceed if it isn't present, that is, if this condition is FALSE. 
        #Or, alternatively, if the negatve of this condition is true
        #we also don't want to include the defauilt tier, so that is the second condition (only proceed if current tier id does not conatin 'default')
        
        #update vector and counter variable
        TierIdIndexNum = TierIdIndexNum + 1;
        TierIdVec[TierIdIndexNum] = gsub('".*',"",gsub('.*TIER_ID="',"",myLine))
        
      }
    } else if (identical(myLine, character(0))){
      
      break
      
    } # If the line is empty, exit. Assign last line in the file as the tier end line num
  }
  
  #Explicitly opened connection needs to be explicitly closed.
  close(myCon_TierIdList)
  rm(myCon_TierIdList)
  
  ####################################################################################
  #go through the tier list, get start and end line nums for each tier, and get annotation details
  
  #first, initialise counter variables, line number variable, as well as vectors to store annotation info in
  StartTimeRef <- c()
  StartTimeLineNum <- c()
  StartTime_ctr = 0
  EndTimeRef <- c()
  EndTimeLineNum <- c()
  EndTime_ctr = 0
  AnnotId <- c()
  AnnotIdLineNum <- c()
  AnnotId_ctr = 0
  Annotation <- c()
  AnnotationLineNum <- c()
  Annotation_ctr = 0
  TierTypeVec <- c() #vector with the tier type string repeated
  
  for (i in 1:numel(TierIdVec)){
    
    TierIdQuery = TierIdVec[i]
    
    rm(TierStartLineNum)
    rm(TierEndLineNum)
    
    #Here, we get start and end line numbers for each tier
    
    #first, establish a connection (which is an interface to the file) to the desires .eaf file
    myCon_TierLineNum = file(description = EafFilename, open="r", blocking = TRUE) #establish connection
    
    #initialise line number
    LineNum = 0
    
    repeat{ #repeat till line is the empty vector
      
      myLine = str_trim(readLines(myCon_TierLineNum, n = 1)) # Read one line from the connection.
      #print(myLine)
      
      LineNum = LineNum + 1 #update line number
      
      #time slot ref and time matching block
      if (str_contains(myLine,TierIdQuery)){
        
        TierStartLineNum = LineNum #get line number at which desired tier starts
        
      } else if ((exists('TierStartLineNum')) && (str_contains(myLine,TierIdQuery) == 0) && 
                 (str_contains(myLine,'LINGUISTIC_TYPE_REF="'))){
        #These conditions make it so that this block is only executed if there is a value 
        #asisgned to TierStartLineNum, AND if the line is the start of a new Tier ID
        #('<TIER LINGUISTIC_TYPE_REF="' check), AND if said new Tier is not the desired Tier.
        #This makes it so that this will only be triggered at the tier after the start of the 
        #desired tier
        #we make sure that we don't go past this next tier by terminating the repeat loop after this
        #else if condition is satisfied
        
        TierEndLineNum = LineNum
        
        break #exit once the end of the required tier is noted
        
      } else if (identical(myLine, character(0))){
        
        TierEndLineNum = LineNum
        
        break
        
      } # If the line is empty, exit. Assign last line in the file as the tier end line num
    }
    
    #Explicitly opened connection needs to be explicitly closed.
    close(myCon_TierLineNum)
    rm(myCon_TierLineNum)
    
    ####################################################################################
    #Now that we have the start and end line numbers of the desired tier, we can work on 
    #getting the annotation details
    
    #reopen the connection. This time, we will get annotation details. This may not be the most
    #efficient way to do this, but it tackles one thing at a time, so we can make sure that wires are not
    #getting crossed, and it works!
    
    #first, establish a connection (which is an interface to the file) to the desires .eaf file
    myCon_AnnotDeets = file(description = EafFilename, open="r", blocking = TRUE) #establish connection
    
    LineNum = 0
    
    repeat{ #repeat till line is the empty vector
      
      myLine = str_trim(readLines(myCon_AnnotDeets, n = 1)) # Read one line from the connection.
      LineNum = LineNum + 1 #update line number
      
      if (LineNum >= TierStartLineNum){ #start extracting info once desired tier starts
        
        #we will check for each type of info (time slot refs, annotation id, annotation) independelty
        #annotation ID
        #Note that if a specific condition is not satisfied in detecting each of these items,
        #the vector to store the item will be populated by NA by default
        #This is another reason why we want to check for each item separately
        if (str_contains(myLine,'ALIGNABLE_ANNOTATION ANNOTATION_ID="')){ 
          
          AnnotId_ctr = AnnotId_ctr  + 1
          AnnotId[AnnotId_ctr] = gsub('" TIME_SLOT_REF1=".*',"",
                                      gsub('<ALIGNABLE_ANNOTATION ANNOTATION_ID="',"",myLine))
          AnnotIdLineNum[AnnotId_ctr] = LineNum
        }
        
        #time slot ref1
        if (str_contains(myLine,'TIME_SLOT_REF1="')){
          
          StartTime_ctr = StartTime_ctr + 1
          StartTimeRef[StartTime_ctr] = gsub('" TIME_SLOT_REF2=.*',"",
                                             gsub('.*TIME_SLOT_REF1="',"",myLine))
          StartTimeLineNum[StartTime_ctr] = LineNum
        }
        
        #time slot ref1
        if (str_contains(myLine,'TIME_SLOT_REF2="')){
          
          EndTime_ctr = EndTime_ctr + 1
          EndTimeRef[EndTime_ctr] = gsub('">',"",
                                         gsub('.*TIME_SLOT_REF2="',"",myLine))
          EndTimeLineNum[EndTime_ctr] = LineNum
        }
        
        #Annotation
        if (str_contains(myLine,'<ANNOTATION_VALUE')){ #we ue this stribg because some files have <ANNOTATION_VALUE/>
          #instead of <ANNOTATION_VALUE>X</ANNOTATION_VALUE> where X is a sample annotation
          
          Annotation_ctr = Annotation_ctr + 1
          Annotation[Annotation_ctr] = gsub('>',"",gsub('</ANNOTATION_VALUE>',"",
                                                        gsub('<ANNOTATION_VALUE',"",myLine)))
          AnnotationLineNum[Annotation_ctr] = LineNum
          TierTypeVec[Annotation_ctr] = TierIdQuery
        }
      }
      
      #finally if we get past the line number for the tier, break
      if (LineNum >= TierEndLineNum){
        break
      }
    }
    
    #Explicitly opened connection needs to be explicitly closed.
    close(myCon_AnnotDeets)
    rm(myCon_AnnotDeets)
    
  } 
  
  #check whether the numel of starttimeref, endtimeref, annotId and annotation are the same
  CtrNumCheck = abs(StartTime_ctr-EndTime_ctr) + abs(EndTime_ctr-AnnotId_ctr) + abs(AnnotId_ctr-Annotation_ctr)
  if (CtrNumCheck == 0){ #if these counter numbers are the same, implying that the number of instances
    #of start times, end times, annotation ids and annotations are the same, create output dfr if else
    
    TierInfo_df <- data.frame(StartTimeRef,StartTimeLineNum,EndTimeRef,EndTimeLineNum,AnnotId,AnnotIdLineNum,Annotation,AnnotationLineNum,TierTypeVec)
    
  } else { #if not, create empty df + output error message
    
    print(sprintf('mismatch in number of start time ref, end time ref, annotation id, and/or annotation in eaf file %s',EafFilename))
    
  }
  
  #check if file has key tiers
  for (j in 1:numel(KeyTierList)){
    
    if (sum(grepl(KeyTierList[j],TierIdVec)) != 1){#if there isn't a block for desired tier, print error message
      
      print(sprintf('No %s tier in file %s',KeyTierList[j],EafFilename))
      
    }
  }
  
  return(TierInfo_df)
}

########################################################################################################################################################################
#Function 3: Matches Time ref to time value imn the annotation detail df
########################################################################################################################################################################
MatchAnnotTimeRefToTime <- function(StartTimeRef,EndTimeRef,TimeRefVec,TimeValVec){ 
  
  #Ritwika VPS, June 2022
  #function to metch start and end time slot refs in Tierinfodf to actual times from TimeRefTimeVal_df
  
  #initialise vectors to store values
  StartTimeVal <- vector(mode="double",length=numel(StartTimeRef))
  EndTimeVal <- vector(mode="double",length=numel(EndTimeRef))
  
  #go through start time ref and time value vectors and match
  for (i in 1:numel(StartTimeRef)){
    for (j in 1:numel(TimeRefVec)){
      
      #check if string matched and match; we can do this for start and end time refs in the same for loop block
      #because both have the same number of elements. But, to be extra paranoid, I am doing this in two blocks
      if (strcmp(StartTimeRef[i],TimeRefVec[j])==1){
        StartTimeVal[i] = TimeValVec[j]
      }
    }
  }
  
  #go through end time ref and time value vectors and match
  for (i in 1:numel(EndTimeRef)){
    for (j in 1:numel(TimeRefVec)){
      
      #check if string matched and match; 
      if (strcmp(EndTimeRef[i],TimeRefVec[j])==1){
        EndTimeVal[i] = TimeValVec[j]
      }
    }
  }
  
  TimeMatched_df <- data.frame(StartTimeVal,EndTimeVal)
  
  return(TimeMatched_df) 
}