##
Please make sure that all paths are correct before executing scripts. Please note that some files required for this pipeline are only shared internally with the lab to protect the privacy of the participants in the study.
## 

This folder contains code used to clean up human-listener labelled data (.eaf files) used in this project. The order in which files should be executed is indicated by the prefixes A1, A2, etc. So, the files with the prefix A1 should be executed first followed by the file with teh prefix A2, etc. Files without a prefix of the form 'A<number>' are function files. A summary of how the pipeline operates is provided below:
  - Copy all .its files to to a single folder (A1_CopyItsFilestoFolder.m). This is especially useful if the .its files are stored in multiple folders, but even if all .its files are in a single folder, it is nice to work on a copy instaed of the originals. This .m file copies .its files stored in multiple folders and outputs a summary .csv file stores details of the old file names (available in the .its file) as well as a .csv file with info about file names and infant id. 
  - Compute infant age (A2_RunFolderInfantAge.sh, A3_WriteInfantAgeCsv.m) for all files. A2_RunFolderInfantAge.sh reads out the DOB and the date of the recording into a .csv file while A3_WriteInfantAgeCsv.m reads the .csv files to compute infant age and compile information about all infant ages into a single .csv file. 
  - Get information about sound segments and start and end times as coded by LENA (A4_RunFolderSegments.sh).
  - Get information about recorder pauses (A5_RunFolderRecorderpauses.sh)
  - Get acoustics data for child and adult vocalisations (A6_GetTSBatchProcess.m).
  - Incorporate information about recorder pauses into the .csv files with acoustics and time series data outputed by A6_GetTSBatchProcess.m (A7_IncorporatePauseTimesInTSAcoustics.m).
  - Compute whether a vocalisation received a response from the other speaker type (A8_GetResponseData.m) for response intervals of 1, 2, and 5 seconds. This script also computes response data for adult speakers to child speech related vocalisations and vice-versa; adult speakers to child non-speech related vocalisations and vice-versa; and adult speakers to all child vocalisations and vice-versa.
  - Merge all subrecordings from a given child at a given age (A9_MergingSubrecsFromDeletions.m). Subrecordings are present in cases where there have been deletions in the recordings per participants' requests after the recording was complete. 
