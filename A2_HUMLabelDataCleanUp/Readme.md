##
Please make sure that all paths are correct before executing scripts
## 

This folder contains code used to clean up human-listener labelled data (.eaf files) used in this project. The order in which files should be executed is indicated by the prefixes A1, A2, etc. So, the files with the prefix A1 should be executed first followed by the file with teh prefix A2, etc. Files without a prefix of the form 'A<number>' are function files. A summary of how the pipeline operates is provided below:
  
  - Copy all .eaf files to a single folder (A1_CopyEafFilesToFolder.m). This is especially useful if the .eaf files are stored in multiple folders, but even if all .eaf files are in a single folder, it is nice to work on a copy instaed of the originals. This .m file copies .eaf files stored in multiple folders, renames tham according to the HomeBank naming convention used for this project, and stores details of the old file names as well as info about which .its files (LENA output file) have corresponding .eaf files. 
  - Parse .eaf files to get details of human listener labels in all tiers (A2_ParseEafFilesAndFlagErrors_Main.R). For each .eaf file, this script outputs a .csv file with the following info: Start time ref and Start time ref line number for each annotation, End time ref and End time ref line number for each annotation, Annotation ID and Annotation ID line number for each annotation, Annotation text and Annotation text line number for each annotation, Tier name for each annotation, Start time value (in ms) for eacha annotation, and End time value (in ms) for each annotation. This script also outputs a summary .txt file with info about whether an .eaf file is missing the adult orthographic annotation tier, adult utterance direction tier or the infant voc type tier
  - Check if the parsing worked correctly, and output summary tables detailing the following error types (A4_GetEafFilesDetailsCsvToTestRCode.m; note that these summaries only look at the infant voc type, adult utterance direction, and adult orthographic transcription tiers:
      - Mismatched annotation tiers (eg. adult utterance direction annotation code in the orthographic tier or vice-versa; or adult utternace direction code in the infant voc type tier); empty annotations or annotations without expected annotation text characters (eg. '*' or ' ' instead of T, U, or N in the adult utterance direction tier); annotations with additional white space or other characters in addition to expected annotation text; multiple annotation codes (eg. 'T/U' in the adult utterance direction tier); otherwise incorrect annotations (eg. 'W' in infant voc type tier)
      - Annotations present in the adult orthographic transcription tier but not in the adult utterance direction tier
      - Annotations with start time > end time
  - Get details of annotations that are outside the bound of the coding spreadsheet that determines the three 5-minute segemnts to be annotated by human listeners (A5_GetAnnotationsOutsideCodingSpreadsheetBounds.m)
  - Edit out simple errors in annotations (additional white space or non-text character in annotation text or multiple occurences of the correct annotation code, eg. 'T T' in the adult utterahce direction tier), delete annotations outside coding spreadsheet bounds, and save cleaned-up .eaf files (A6_GetEditedEafFiles.R)
  - Get summaries of remaining errors in cleaned-up .eaf files and check if the clean-up worked (A7_GetAnnotationsOutsideCodingSpreadsheetBounds_PostCleanup.m, A8_GetSummaryOfErrorsInEafFilesPostCleanUp.m)

Once the clean-up is done, the steps to parse info from the .eaf files and write to .csv can be repeated to obtain clean data. 
  



