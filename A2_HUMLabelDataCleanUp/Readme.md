##
Please make sure that all paths are correct before executing scripts. Please also note that some of the .csv files used in the pipeline are only shared internally with the lab. 
## 

This folder contains code used to clean up human-listener labelled data (.eaf files) used in this project. The order in which files should be executed is indicated by the prefixes A1, A2, etc. So, the files with the prefix A1 should be executed first followed by the file with teh prefix A2, etc. Files without a prefix of the form 'A<number>' are function files. A summary of how the pipeline operates is provided below:
  
  - Copy all .eaf files to a single folder (A1_CopyEafFilesToFolder.m). This is especially useful if the .eaf files are stored in multiple folders, but even if all .eaf files are in a single folder, it is nice to work on a copy instaed of the originals. This .m file copies .eaf files stored in multiple folders, renames tham according to the HomeBank naming convention used for this project, and stores details of the old file names as well as info about which .its files (LENA output file) have corresponding .eaf files. Note that this script outputs two .csv files: 'EAFFileDetailsWithOldFN.csv', with info about eaf filenames per renaming convention and corresponding filenames per old file naming convention; 'ItsvsEafFilesDetails.csv', with info about whether there is an .eaf file corresponding to each .its file. 'EAFFileDetailsWithOldFN.csv' is required for scripts further down in the pipeline, so I recommend having a similar .csv file if you choose not to run this script. Also note that this script requires 'ItsFileDetailsWOldFN.csv' which contains .its file names per renaming convention as well as corresponding file names per the old file naming convention. Finally, this script filters out empty .eaf files that do not contain any annotations, so if you choose not to run this script, please make sure that you have manually moved empty .eaf files to a different folder. For data privacy reasons, this file is currently only shared internally with the lab. 
  - Edit out one specific .eaf file that has formatting errors (A2_1_Eaf0225_000602QuickFix.R). These errors are distinct from the errors the rest of the scripts deal with.
  - Parse .eaf files to get details of human listener labels in all tiers (A2_ParseEafFilesAndFlagErrors_Main.R). For each .eaf file, this script outputs a .csv file with the following info: Start time ref and Start time ref line number for each annotation, End time ref and End time ref line number for each annotation, Annotation ID and Annotation ID line number for each annotation, Annotation text and Annotation text line number for each annotation, Tier name for each annotation, Start time value (in ms) for eacha annotation, and End time value (in ms) for each annotation. This script also outputs a summary .txt file with info about whether an .eaf file is missing the adult orthographic annotation tier, adult utterance direction tier or the infant voc type tier.
  
  This script works by picking out the time slot ids and the corresponding time value from the lines that contain that information (eg. ```<TIME_SLOT TIME_SLOT_ID="ts1" TIME_VALUE="172690"/>```), and then matching the time slot ids in the lines containing the annotation details. In addition, this script also picks out the annotation text from the lines containing the annotation details. 
  
  For example, consider this annotation 'block':
  ```
  <ANNOTATION>
      <ALIGNABLE_ANNOTATION ANNOTATION_ID="a37" TIME_SLOT_REF1="ts719" TIME_SLOT_REF2="ts720">
          <ANNOTATION_VALUE>R</ANNOTATION_VALUE>
      </ALIGNABLE_ANNOTATION>
  </ANNOTATION>
  ```
  
  This script extracts the annotation id (a37), the start and end time slot refs (ts719, ts720), and the annotation text (R).
            
  - Check if the parsing worked correctly, and output summary tables detailing the following error types (A4_GetEafFilesDetailsCsvToTestRCode.m; note that these summaries only look at the infant voc type, adult utterance direction, and adult orthographic transcription tiers:
      - Mismatched annotation tiers (eg. adult utterance direction annotation code in the orthographic tier or vice-versa; or adult utternace direction code in the infant voc type tier); empty annotations or annotations without expected annotation text characters (eg. '*' or ' ' instead of T, U, or N in the adult utterance direction tier); annotations with additional white space or other characters in addition to expected annotation text; multiple annotation codes (eg. 'T/U' in the adult utterance direction tier); otherwise incorrect annotations (eg. 'W' in infant voc type tier)
      - Annotations present in the adult orthographic transcription tier but not in the adult utterance direction tier; annotations present in music tier but not in adult utterance dir tier and vice-verse, and similarly for adult uterance direction tier and background overlap tier
      - Annotations with start time > end time
  To run A4_GetEafFilesDetailsCsvToTestRCode.m as it is currently written, you'll need to run A3_RunFolderReadEafFilesAsText.sh, which calls Perl to save .eaf files as .txt files. This is because of a rather hack-y implementation and largely stems from the fact that i) MATLAB doesn't read .eaf files correctly, and ii) it was far easier for me to make MATLAB read the contents of the .txt file version of the .eaf file than have Perl directly read the .eaf files into the same .csv output format from A2_ParseEafFilesAndFlagErrors_Main.R. For what it is worth, I ahve verified that R reads out the .eaf files correctly, so you can edit A4_GetEafFilesDetailsCsvToTestRCode.m such that the A3 step is unnecessary. 
  - Get details of annotations that are outside the bound of the coding spreadsheet that determines the three 5-minute segemnts to be annotated by human listeners (A5_GetAnnotationsOutsideCodingSpreadsheetBounds.m). This script requires the coding spreadsheet (HumanListenerLabelsCodingRound3.csv). This file is currently only shared internally with the lab. 
  - Edit out simple errors in annotations (additional white space or non-text character in annotation text or multiple occurences of the correct annotation code, eg. 'T T' in the adult utterahce direction tier), delete annotations outside coding spreadsheet bounds, and save cleaned-up .eaf files (A6_GetEditedEafFiles.R). I use a simplified version of the spreadsheet with details about annotations that are outside of tehe coding spreadsheet bounds to do this (filename: PreCleanupSummary_AnnotOutsideCodingSpreadsheetBds_Simplified.xlsx). This is a simplified version with only the columns AnnotationLineNum, EafFname, StartTimeLineNum, EndTimeLineNum, and AnnotIdLineNum. I generate this excel sheet manually by deleting all other columns from the relevant summary output file from A5_GetAnnotationsOutsideCodingSpreadsheetBounds.m. Please make sure to do this before executing A6_GetEditedEafFiles.R. 
  - Re-run the parsing code with the appropraite directory locations to get cleaned-up data (A2_ParseEafFilesAndFlagErrors_Main.R)
  - Get summaries of remaining errors in cleaned-up .eaf files and check if the clean-up worked (A7_GetAnnotationsOutsideCodingSpreadsheetBounds_PostCleanup.m, A8_GetSummaryOfErrorsInEafFilesPostCleanUp.m)


  



