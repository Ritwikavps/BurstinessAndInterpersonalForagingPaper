#Ritwika VPS, June 2022
#This script contains functions used to edit simple errors in .eaf files
#Required libraries: sjmisc, stringr, pracma
#also make sure to be in the correct directory

########################################################################################################################################################################
#Function 1: Checks if the line contains an annotation
########################################################################################################################################################################
CheckIfAnnotLine <- function(myLine){
  
  #Ritwika VPS
  #June 2022 
  #function to check if the line is an annotation
  
  if (str_contains(myLine,'<ANNOTATION_VALUE')){ #we use this string because some annotation lines <ANNOTATION_VALUE/>X</ANNOTATION_VALUE>
    #instead of <ANNOTATION_VALUE>X</ANNOTATION_VALUE>
    AnnotFlag = TRUE
  } else {
    AnnotFlag = FALSE
  }
  
  return(AnnotFlag)
}

########################################################################################################################################################################
#Function 2: Function to extract list of tiers in eaf file + start and end line num of each tier
########################################################################################################################################################################
GetTierListInfo <- function(EafFileName){
  
  #Ritwika VPS
  #June 2022
  #Function to find list of annoation tiers and start and end line numbers of tiers given eaf file
  
  #Required libraries: sjmisc, stringr
  #also make sure to be in the correct directory
  
  #Ideally, there should be an error block if the file is empty or if file doesnt exist
  
  ####################################################################################
  #first get list of tiers in the file
  myCon_TierIdList = file(description = EafFileName, open="r", blocking = TRUE) #establish connection
  
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
  #Now get corresponding start and end line numbers for each tier
  
  #initialise vectors to store start and end line nums
  TierStartLineNum = c()
  TierEndLineNum = c()
  
  #first, establish a connection (which is an interface to the file) to the desires .eaf file
  myCon_TierLineNum = file(description = EafFileName, open="r", blocking = TRUE) #establish connection
  
  #initialise line number
  LineNum = 0
  
  repeat{ #repeat till line is the empty vector
    
    myLine = str_trim(readLines(myCon_TierLineNum, n = 1)) # Read one line from the connection.
    #print(myLine)
    
    LineNum = LineNum + 1 #update line number
    
    if ((str_contains(myLine,'LINGUISTIC_TYPE_REF="')) && (str_contains(myLine,'TIER_ID="'))){ #check if it is a tier identifying line
      
      #now check if it has the tier identifying line, and if it contains, assign that as tier start num
      for (i in 1:numel(TierIdVec)){
        if (str_contains(myLine,TierIdVec[i])){ 
          TierStartLineNum[i] = LineNum
        }
      }
    }
    
    if (identical(myLine, character(0))){

      break
      
    } # If the line is empty, exit. Assign last line in the file as the tier end line num
  }
      
  #Explicitly opened connection needs to be explicitly closed.
  close(myCon_TierLineNum)
  rm(myCon_TierLineNum)
  
  #for tier end num, we will assign the start of next tier - 1 as the end line num for tiers, except for the last tier
  #For the last tier, we will assign the last line num in the document
  #Since we only need these numbers as rough demarcations for which annotations belong to which tier, this is fine. 
  
  for (j in 1:numel(TierIdVec)-1){ #go thropugh list and assign end line num
    
    TierEndLineNum[j] = TierStartLineNum[j+1] - 1
    
  }
  
  TierEndLineNum[numel(TierIdVec)] = LineNum
  
  TierList_df = data.frame(TierIdVec,TierStartLineNum,TierEndLineNum)
  
  return(TierList_df)
  
}

########################################################################################################################################################################
#Function 3: Function to get the tier of an annotation given the line number of the annotation
########################################################################################################################################################################

GetAnnotationTier <- function(LineNum,TierIdVec,TierStartLineNum,TierEndLineNum){
  
  #Ritwika VPS
  #June 2022
  #Get annotation tier given line number
  
  for (i in 1:numel(TierStartLineNum)){
    
    if ((LineNum >= TierStartLineNum[i]) && (LineNum <= TierEndLineNum[i])){
      
      AnnotTier = TierIdVec[i]
      
    }
  }
  
  return(AnnotTier)
  
}

########################################################################################################################################################################
#Function 4: Function to check if the annotation needs editing or not (i.e., if there is a simple error)
########################################################################################################################################################################

CheckAnnotationForSimpleError <- function(Annotation,AllowedAnnot){
  
  #Ritwika VPS
  #June 2022
  #checks if annotations has simple errors (eg. 'C C' or 'C/C'  or 'c' or 'C*' or 'C~', in inf voc type tier, or extra tabs or spaces
  #or other white space)
  
  #The way this is written, this would TRUE for editing is required if the annotation is correct
  #I am choosing to circumvent that by implementing something that only passes to this function if the annotation is NOT prefectly correct
  
  #Also, this is currently only designed for infant voc type and Adult uterance dir tier (but could also apply to other tiers where target annotation is a single alphabet)
  
  NeedsEdit = FALSE #default
  
  #Conditions to determien if editing is required
  #####################################################################
  #Case 1: annotation is correct but has repeats or case change (eg. 'x' or 'XX'). In this case, there won't be any spaces of extra characters
  #To id this, we can just check if the annotation contains a target annotation code AND if after removing the code, annotation is empty
  
  #####################################################################
  #Case 2: Annotation is correct but there is an extra space or tab character (eg. 'X ' or 'X X' or 'X x')
  #To id this, we can check if the annotation contain a target annotation code, AND if after removing the code and trimming any white space, annotation is empty
  
  #####################################################################
  #Case 3: Annotation is correct but has additional non-alphabetic, non-numeric character AND space/tab (we can expand this to allow numerics but we don't have such an error as of now)
  #(eg. 'X*' or 'X/X' or 'X/x' or 'X *' or 'X *X')
  #To id this, we can check if the annotation contains a target annotation code, AND if after removing the code and special characters and trimming, is the annotation is empty
  
  for (i in 1:numel(AllowedAnnot)){
    
    IsAnnotationPerfect = strcmp(Annotation,AllowedAnnot[i]) #first check if annotation is as expected
    
    DoesAnnotContainTarget = str_contains(Annotation,AllowedAnnot[i],ignore.case = TRUE)
    AnnotAfterTargetRemoved = gsub(AllowedAnnot[i],'',Annotation,ignore.case = TRUE)
    CaseOneCheck = is_empty(AnnotAfterTargetRemoved)
    
    AnnotAfterTargetRemovedAndStrTrim = str_trim(AnnotAfterTargetRemoved)
    CaseTwoCheck = is_empty(AnnotAfterTargetRemovedAndStrTrim)
    
    AnnotAfterSpecialCharacRemoved = str_replace_all(AnnotAfterTargetRemoved, '[^[:alnum:]]','')
    CaseThreeCheck = is_empty(str_trim(AnnotAfterSpecialCharacRemoved))
    
    
    if (IsAnnotationPerfect){
      break #if annotation is perfect, don't check further, break
    } else if (DoesAnnotContainTarget && CaseOneCheck){ #Case I
      NeedsEdit = TRUE
      break #if condition met for any one target annotationm break out of for loop
    } else if (DoesAnnotContainTarget && CaseTwoCheck){ #Case II
      NeedsEdit = TRUE
      break #if condition met for any one target annotationm break out of for loop
    } else if (DoesAnnotContainTarget && CaseThreeCheck){ #Case III
      NeedsEdit = TRUE
      break
    }
  }

  return(NeedsEdit)
}

########################################################################################################################################################################
#Function 5: Function to get edited annotation
########################################################################################################################################################################

GetEditedAnnotation <- function(Annotation){
  
  #Ritwika VPS
  #June 2022
  #Function to get edited annotation
  
  #All we need is extract the alphabet and make sure that it is uppercase (or convert to uppercase if it is lowercase)
  #Firstb uppercase the annotation
  AnnotTemp = toupper(Annotation)
  
  #extract the alphabet. To do this, we first get every unique character out
  AnnotTempUniqs = unique(strsplit(AnnotTemp, "")[[1]])  #This is very much copied straight from stackexcahnge but I imagine what is happening is 
  #the strsplit splits the string at every character. We output is indexed as [[1]]. And unique pulls out the unique characters
  
  Ctr = 0; #initialise check for whether there are multiple unique alphabets
  #Pick out the alphabet from this list
  for (i in 1:numel(AnnotTempUniqs)){
    if (str_detect(AnnotTempUniqs[i], "^[:alpha:]+$")){ #thsi checks if each unique character is an alphabet
      Ctr = Ctr + 1
      NewAnnot = AnnotTempUniqs[i] #get new annotation if conditions satisfued
    } 
  }
  
  #if there is more than one unique alphabet, error
  if (Ctr != 1){
    stop('Multiple unique alphabets in input annotation. Make sure all user-defined fns work as intended')
  }

  return(NewAnnot)
}
