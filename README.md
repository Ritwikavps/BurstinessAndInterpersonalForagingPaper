# San Joaquin Valley corpus: data processing and analysis code for 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated projects

This directory contains code that does the following:
- extracts, cleans, processes, and analyses day-long recordings of infant and adult caregiver vocalisations for the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated projects
- performs validation of the LENA automatic labelling using human listener-labelled data
- plots all figures in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file

Languages: MATLAB (R2024b), R (version 4.2.0 (2022-04-22) -- "Vigorous Calisthenics"), Bash, Perl

The directory names are indexed as A1, A2, etc. to indicate the suggested order to follow. 

`A1_LENADataProcessing` contains code to extract LENA labels as well as acoustics from .wav and .its files (MATLAB, Bash, and R). Code in this directory also generates a metadata file for the LENA data. For details, see `README` in the directory. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A2_HUMLabelDataCleanUp` contains code to clean-up human listener annotated data (R, MATLAB, Bash, and Perl; for details, see `README` in the directory).

`A3_HUMLabelDataProcessing` contains code (MATLAB) to extract human listener labels and acoustics of labelled vocalisations from cleaned-up human listener annotation files (.eaf files). Code in `A2_HUMLabelDataCleanUp` and `A1_LENADataProcessing` MUST be executed before executing code in this directory. If you have cleaned up .eaf files, you can also work directly with those in lieu of executing code in `A2_HUMLabelDataCleanUp`. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A4_DataAnalysis` contains code (R, MATLAB) to analyse data presented in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file. 

`A5_Plotting` contains code (MATLAB) to generate all plots presented in the paper 'Burstiness and Interpersonal Foraging Betweeen Human Infants and Caregivers in the Vocal Domain' and associated supplementary file.

##
Please make sure that all paths are correct before executing scripts. 

To the best of the author's knowledge, lines of code where paths might need changing or other important notes are present have been demarcated by `%-------------------------------------------` (in MATLAB) or `#########################################################` (in R) above and below the block of code/comments that require the reader's attention. 
##
