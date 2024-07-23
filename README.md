# IVFCR_ExtendedStudy_LENAValidation

This directory contains code that extracts, cleans up, processes, and analyses day-long recordings of infant and adult caregiver vocalisations and to test the validity of the LENA automatic labelling using human listener-labelled data

The directory names are indexed as A1, A2, etc. to indicate the suggested order to follow. If all directories are not currently named with a prefix of the form 'A<number>', they will be in future updates.

`A1_LENADataProcessing` contains code to extract LENA labels as well as acoustics from .wav and .its files (MATLAB, Bash, and R). Code in this directory also generates a metadata file as well as z-scored acoustics and time series data for the LENA data. For details, see `README` in the directory. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A2_HUMLabelDataCleanUp` contains code to clean-up human listener annotated data (R, MATLAB, Bash, and Perl; for details, see README in the directory).

`A3_HUMLabelDataProcessing` contains code to extract human listener labels and acoustics of labelled vocalisations from cleaned-up human listener annotation files (.eaf files). Code in `A2_HUMLabelDataCleanUp` and `A1_LENADataProcessing` MUST be executed before executing code in this directory. Alternatively, you can also work directly with .eaf files that have been cleaned-up. The final processed data obtained from the pipeline in this directory can be found at https://osf.io/5xp7z/

`A4_DataAnalysis` contains code to analyse data (acoustics and speaker labels). 

##
Please make sure that all paths are correct before executing scripts. 

To the best of the authors' knowledge, lines of code where paths might need changing or other important notes are present have been demarcated by '%-------------------------------------------' (in MATLAB) or '#########################################################' (in R) above and below the block of code/comments that require the reader's attention. 
##
