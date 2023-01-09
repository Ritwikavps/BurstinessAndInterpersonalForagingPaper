##
Please make sure that all paths are correct before executing scripts.
## 

This folder contains code used to extract and pre-process human-listener labelled data used in this project. The order in which files should be executed 
is indicated by the prefixes A1, A2, etc. So, the files with the prefix A1 should be executed first followed by the file with teh prefix A2, etc. Files 
without a prefix of the form 'A' are function files. A summary of how the pipeline operates is provided below:

- Copy cleaned-up .eaf files that are free of errors to the working folder (A1_IdOverlapAndFilesWErrors.m). This script also identified overlaps in vocalisations based on onsets and offsets as determined by human listeners, and chops up overlapping vocalisations into overlapping and non-overlapping subvocalisations. 
- Get acoustics data (mean pitch and amplitude) for human-listener annotated data (A2_TSAcousticsBatchProcessHUMlabel.m).
- Add human-listener annotation tags (T, U, N for adult vocalisation; and R, X, C, L for infant vocalisations) to the acoustics time series (A3_AddingAnnotationToTS.m). This script also recasts the sub-vocalisations obtained from overlapping vocalisations (from A1_IdOverlapAndFilesWErrors.m) into the original vocalisations and computes estimates of mean pitch and amplitude for the re-constituted vocalisations based on the fraction of the full vocalisation's duration occupied by each sub-vocalisation for which acoustics have been computed. This is a little hard to explain without the code, so please make sure to check the script. A schematic describing how the overlaps are processed is shown in HumLabelOlpProcessingSchematic.pdf. 
- Merge any subrecordings that are from the same infant on the same day and assign section numbers to each vocalisation (A4_MergeSubRecs_GetSectionNum.m). Thus, all vocalisations in the first 5 miniute section in a file will be identified by section number 1, and so on and so forth.
- Get z-scored acoustics data (A5_GetZscoredData_HumLabels.m).
- Get LENA data corresponding to the human-listener labelled 5 minute sections (A6_MatchingSectionsToCodingSheet.m).
- Optional script to flag files with 5 minute sections that are less than 30 minutes apart and files with annotated sections that are longer than 5 miniutes (Flags_SectionsNot30MinApartAndOtherChecks.m) 


