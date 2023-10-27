#functions used to extract infant age from .its files and write to a .csv file
########################################################################################################################################################################
#Function 1: Gets Infant DOB
########################################################################################################################################################################

GetInfantDob <- function(ItsFileName){ 
  
  #first, establish a connection (which is an interface to the file) to the desires .eaf file
  myCon = file(description = ItsFilename, open="r", blocking = TRUE) #establish connection
  
  repeat{ #repeat till line is the empty vector or till DoB is found
    myLine = str_trim(readLines(myCon, n = 1)) # Read one line from the connection.
    
    #find target string corresponding to Dob info and extract Dob
    if(str_contains(myLine,'ChildInfo dob=')){
      DoB = gsub(pattern='".*', replacement='', x = gsub(pattern='.*ChildInfo dob="', replacement='', x = myLine)) #extract DOB (yyyy-mm-dd)
      break 
    }
    
    if(identical(myLine, character(0))){
      DoB = '' #if, for some reason, the DOB target string doesnt exist
      break
    } # If the line is empty, exit.
    #print(myLine) # Otherwise, print and repeat next iteration.
  }
  
  #Explicitly opened connection needs to be explicitly closed.
  close(myCon)
  rm(myCon)
  
  return(DoB)
}

########################################################################################################################################################################
#Function 1: Gets recording date
########################################################################################################################################################################

GetRecDate <- function(ItsFileName){ 
  
  #first, establish a connection (which is an interface to the file) to the desires .eaf file
  myCon = file(description = ItsFilename, open="r", blocking = TRUE) #establish connection
  
  repeat{ #repeat till line is the empty vector or till the recording date is obtained
    myLine = str_trim(readLines(myCon, n = 1)) # Read one line from the connection.
    
    #find target string corresponding to recoding date info and extract
    if(str_contains(myLine,'startClockTime="')){
      RecDate = gsub(pattern='T.*', replacement='', x = gsub(pattern='.*startClockTime="', replacement='', x = myLine))
      break
    }
    
    if(identical(myLine, character(0))){
      RecDate = '' #if, for some reason, the recording date target string doesnt exist
      break
    } # If the line is empty, exit.
    #print(myLine) # Otherwise, print and repeat next iteration.
  }
  
  #Explicitly opened connection needs to be explicitly closed.
  close(myCon)
  rm(myCon)
  
  return(RecDate)
}

########################################################################################################################################################################
#Function 3: Get infant age at time of recording in days
########################################################################################################################################################################

GetInfAge = function(ItsFilename){
  
  DoB = GetInfantDob(ItsFilename) #get date of birth
  RecDate = GetRecDate(ItsFilename) #get recording date
  InfantAge = round(as.numeric(difftime(RecDate,DoB,units = 'days'))) #get difference, convert to a number, and round
  
  return(InfantAge)
}

########################################################################################################################################################################
#Function 4: Get infant ID from metadatafile
########################################################################################################################################################################

GetInfantID = function(ItsFileTab,ItsFilename){
  
  FileNameRoot = gsub('.its','',ItsFilename) #get filename root
  TargetRow = filter(ItsFileTab, FNRoot == FileNameRoot) #get corresponding row from metadata file
  InfID = TargetRow$InfantID #get infant ID

  return(InfID)
}







