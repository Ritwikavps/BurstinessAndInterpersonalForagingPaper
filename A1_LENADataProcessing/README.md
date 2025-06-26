This directory contains all pre-processing code used to prepare LENA data for analyses reported in this study. 

Please note that only files with the prefix A1, A2, etc. are executables, while all other files are supporting functions. Please also note that the executable files need to be executed in the order of prefixes A1 to A7. Finally, files with prefixes A1-A7 require access to data that has potentially identifying information and hence, is only provided to orient the reader, since access to this data is restricted. See the OSF repository associated with this project for all publicly shared data and metadata files associated with this project. For details on output files for each executable script (and which of those output files are shared publicly) as well as data organisation, see `Metadata_CodeAndFiles.xlsx` and `README_FileAndDirectoryDetails.docx` (available in this repository as well as in the associated OSF repository). 

`A1_CopyItsFilestoFolder.m` copies .its files for each infant to a single common directory. Also creates .csv files with filename and infant ID info.

`A2_WriteInfantAgeCsv.R` parses .its files to compute infant age and write this information to a .csv file. Requires supporting function file `ItsParsingFnsForInfantAge.R`

`A3_RunFolderSegments.sh` runs `segments.pl` on .its files to get sound segments as identified by LENA.

`A4_RunFolderRecorderpauses.sh` runs `recorderpauses.pl` on .its files to get info about incidences of the recorder being paused so that utterances from different sub-recordings aren't treated as temporally sequential.

`A5_GetTSBatchProcess.m` extracts time series info from each .its file. Requires `getAcousticsTS.m`, `getPraatAcoustics.m`, and `getIndividualAudioSegments.m`. Note that a few files that are parts of day long recordings (with the suffix a, b, etc) don't find a wave file match, because the wave files aren't necessarily split up into a, b, etc. Make sure to check for this and do those manually if necessary. This script is parallelised at the infant ID folder level and takes about 24 hours to run. Please make sure to adjust the number of parallelisation cores according to your system capabilities. 

`A6_IncorporatePauseTimesInTSAcoustics.m` incorporates recorder pause time info into the time series files so that different sub-recordings can be identified.

`A7_MergingSubrecsFromDeletions.m` merges sub-recordings resulting from deletions (which are separate files in the raw .its data) but are from the same recording day for an infant into a single file. Also identifies sub-recordings from deletions and incorporates that information (similar to A6). Requires `GetSectionNumVec.m`.

For more specific details, please read comments about paths and other notes in the files before executing them. 
