#Ritwika VPS
#June 2022
#0225_000602.eaf has an issue where several annotation lines are of the form
#<ANNOTATION_VALUE>X
# (new line)</ANNOTATION_VALUE>
#This is a quick and dirty script to fix that

#set working directory
setwd('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A1_EAFFiles/')

#load required librarues
library(pracma) #lots fo basic functions
library(stringr)
library(sjmisc)

#source functions needed
source('~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A2_HUMLabelDataCleanUp/EafSimpleErrorEditingFunctions.R')

EafFileName = '0225_000602.eaf'

#open connection
myEditCon = file(description = EafFileName, open="r", blocking = TRUE) #establish connection

LineNum = 0 #initialise line num
PrevLineWasAnnot = 0 #check if previous linehad an annotation
CurrLineAnnot = 0

#initialise list to save text as well as filename to save
FN_AndLocationToSave = '~/Google Drive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/0225_000602.eaf'
TextToWrite = c()

repeat{ #repeat till line is the empty vector
  
  LineNum = LineNum + 1
  
  myLine = readLines(myEditCon, n = 1) # Read one line from the connection.
  
  if(identical(myLine, character(0))){
    break
  } # If the line is empty, exit.
  #print(myLine) # Otherwise, print and repeat next iteration.
  
  #first, check if line contains annotation
  IsAnnot = CheckIfAnnotLine(myLine)
  
  if (IsAnnot){ #update CurrLineAnnot
    CurrLineAnnot = 1
  } else {
    CurrLineAnnot = 0
  }
  
  if ((CurrLineAnnot == 1) && (!str_contains(myLine,'</ANNOTATION_VALUE>'))){ #if current line has annotation but not the '</ANNOTATION_VALUE>' text
    myLine = strcat(myLine,'</ANNOTATION_VALUE>') #add the '</ANNOTATION_VALUE>' text to the line
  }
  
  if ((PrevLineWasAnnot == 1) && str_contains(myLine,'</ANNOTATION_VALUE>')){ #if prev line had an annotation and current line has string </ANNOTATION_VALUE>, this means the annotation line is split
    print('This line will be deleted because this is the second hald of the annotation line split into two lines')
  } else {
    #WRITE NEW LINE
    TextToWrite = append(TextToWrite,myLine)
  } 
  
  if (IsAnnot){ #update PrevLineWasAnnot
    PrevLineWasAnnot = 1
  } else {
    PrevLineWasAnnot = 0 
  }
  
}

close(myEditCon)
rm(myEditCon)

closeAllConnections() #close all connections, just to be safe

writeLines(TextToWrite, FN_AndLocationToSave) 

closeAllConnections() #close all connections, just to be safe



