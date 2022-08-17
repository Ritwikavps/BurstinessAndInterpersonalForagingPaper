# IVFCR_ExtendedStudy_LENAValidation

This directory contains code that extracts, cleans up, processes, and analyses day-long recordings of infant and adult caregiver vocalisations to validate findings from our previous study (Ritwika et al. 2020) and to test the validity of the LENA automatic labelling using an extended collection of human-labelled data

(The directory names are--or should be--indexed as A1, A2, etc. to indicate the suggested order to follow. If all directories are not currently named with a prefix of the form 'A<number>', they will be in future updates)

LENADataProcessing (should be A1_LENADataProcessing) contains code to extract LENA labels as well as acoustics from .wav and .its files (MATLAB, Bash, and Perl). 

A2_HUMLabelDataCleanUp contains code to clean-up human listener annotated data (R, MATLAB, Bash, and Perl)

HUMLabelDataProcessing (should be A3_HUMLabelDataProcessing) contains code to extract human listener labels and acoustics of labelled vocalisations from cleaned-up human listener annotation files (.eaf files). Code in A2_HUMLabelDataCleanUp MUST be executed before executing code in this directory. Alternatively, you can also work directly with .eaf files that have been cleaned-up. 

LENADataAnalysis (should be A4_LENADataAnalysis) contains code to analyse data (acoustics and speaker labels) obtained from the LENADataProcessing pipeline. 

##
Please make sure that all paths are correct before executing scripts
##
