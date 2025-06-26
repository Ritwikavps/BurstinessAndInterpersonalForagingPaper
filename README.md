# San Joaquin Valley corpus: data processing and analysis code for 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated projects  

***Please direct all questions about the code in this repository to ritwika@ucmerced.edu***  

This directory contains code that does the following:
- extracts, cleans, processes, and analyses day-long recordings of infant and adult caregiver vocalisations for the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain', the pre-print for the same paper (https://arxiv.org/abs/2505.01545), and associated projects
- performs validation of the LENA automatic labelling using human listener-labelled data
- plots all figures in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file

Languages: MATLAB (R2024b), R (version 4.2.0 (2022-04-22) -- "Vigorous Calisthenics"), Bash, Perl

Data files with potentially identifying information are not available publicly. As such, some code in the `A1_LENADataProcessing` and `A2_HUMLabelDataCleanUp` folders are only provided to orient the reader since the data to run some scripts are not publicly shared. See the OSF repository associated with this project for all publicly shared data and metadata files associated with this project. For details on output files for each executable script (and which of those output files are shared publicly) as well as data organisation, see `Metadata_CodeAndFiles.xlsx` and `README_FileAndDirectoryDetails.docx` (available in this repository as well as in the associated OSF repository).

The directory names are indexed as A1, A2, etc. to indicate the suggested order to follow. See relevant `README` files in each directory for details about the contents of each directory. See below for a broad overview of the contents of each directory.

Some processing scripts before `A4_DataAnalysis` will only write output files only if the file does not exist in the specified location. As such, I recommend deleting or moving previously existing files before executing scripts in folder before `A4_DataAnalysis`.

`A1_LENADataProcessing` contains code to extract LENA labels as well as acoustics from .wav and .its files (MATLAB, Bash, and R). Code in this directory also generates a metadata file for the LENA data. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A2_HUMLabelDataCleanUp` contains code to clean-up human listener annotated data (R, MATLAB, Bash, and Perl).

`A3_HUMLabelDataProcessing` contains code (MATLAB) to extract human listener labels and acoustics of labelled vocalisations from cleaned-up human listener annotation files (.eaf files). Code in `A2_HUMLabelDataCleanUp` and `A1_LENADataProcessing` MUST be executed before executing code in this directory. If you have cleaned up .eaf files, you can also work directly with those in lieu of executing code in `A2_HUMLabelDataCleanUp`. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A4_DataAnalysis` contains code (R, MATLAB) to analyse data presented in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file. 

`A5_Plotting` contains code (MATLAB) to generate all plots presented in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file.

##
Please make sure that all paths are correct before executing scripts. 

To the best of the author's knowledge, lines of code where paths might need changing or other important notes are present have been demarcated by `%-------------------------------------------` (in MATLAB) or `#########################################################` (in R) above and below the block of code/comments that require the reader's attention. 
##

Some notes about terminology used in the code:  
- The terms IEI and IVI are used interchangeably to mean inter-event intervals (as described in teh Burstiness paper and pre-print) and equivalents, inter-vocalisation intervals, in that the relevant events are vocalisations.
- The Burstiness paper and pre-print use the short-hands `ChSp` (infant speech-related), `ChNsp` (infant non-speech-realated), and `Ad` (adult) for vocalisation types analysed in or relevant to the study. Throughout the code, however, these vocalisations are indicated using the short-hands `CHNSP` (infant speech-related), `CHNNSP` (infant non-speech-realated), and `AN` (adult). In addition, `CHN` indicates the combined `CHNSP` (infant speech-related) and `CHNNSP` (infant non-speech-realated) category.


