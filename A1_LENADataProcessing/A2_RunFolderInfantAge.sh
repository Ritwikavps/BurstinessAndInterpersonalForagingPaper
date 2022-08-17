#!/bin/bash

#Ritwika VPS, Feb 2021 (adapted from code by Anne Warlaumont and/or Gina Pretzer) 

#Run perl script to get infant ages from .its files (GetInfantAgeFromItsFile.pl) in a folder of .its files

#Instructions:
# 1.) To use this tool, have all desired .its files in a folder of its own. 
# 2.) In line 19, enter the path to the main folder containing the desired .its files 
# 3.) Specify the .its file
# 5.) Name the output files (lines 24)
#	  This replaces the ".its" ending of the filename to rename the file, and changes the ".its" suffix to ".csv", since the output files are .csv files
# 6.) In line 27, set the path for the "GetInfantAgeFromItsFile.pl" file 
# 7.) Save all changes
# 8.) Launch Terminal
# 9.) Navigate to directory where "F2_RunFolder_InfantAge.sh" is located
# 10.) Run this file (sh F2_RunFolder_InfantAge.sh )

cd ~/Google\ Drive/My\ Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A1_ItsFiles

#go through the .its files
for itsfile in *.its 
	#replace '.its' with 'InfantAge.csv' for o/p file name
	do outfile=`echo $itsfile | sed 's/\.its/InfantAge\.csv/g'`; 
	   #run perl script to get dob and date of recording into csv
	   perl ~/Google\ Drive/My\ Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A1_LENADataProcessing/GetInfantAgeFromItsFile.pl $itsfile $outfile
	   done
