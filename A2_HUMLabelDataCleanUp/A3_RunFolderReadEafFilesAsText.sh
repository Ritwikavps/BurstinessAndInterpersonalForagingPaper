#!/bin/bash

#Ritwika VPS, Dec 2021; UCLA Dpmt of Comm

#Runs perl script (ReadEafFilesAsText.pl) to read .eaf files to .txt files (to extract labels using MATLAB) on all .eaf files in a folder

#Instructions:
# 1.) To use this tool, have all desired .eaf files in a folder of their own. 
# 2.) In line 19, enter the path to the main folder containing the desired .eaf files 
# 3.) Specify the .eaf file
# 5.) Name the output files (lines 21)
#	  This replaces the ".eaf" ending of the filename to rename the file, adds EAF to the file name, and changes the ".eaf" suffix to ".txt", since the output files are .txt files
# 6.) In line 22, set the path for the "ReadEafFilesAsText.pl" file 
# 7.) Save all changes
# 8.) Launch Terminal
# 9.) Navigate to directory where "A2_RunFolderReadEafFilesAsText.sh" is located
# 10.) Run this file (sh A2_RunFolderReadEafFilesAsText.sh )

cd ~/Google\ Drive/My\ Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A1_EAFFiles
for eaffile in *.eaf         #go through eaf files
	do outfile=`echo $eaffile | sed 's/\.eaf/EAF\.txt/g'`;       
	   perl ~/Google\ Drive/My\ Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/CodeForGitHub/A2_HUMLabelDataCleanUp/ReadEafFilesAsText.pl $eaffile $outfile
	   done
