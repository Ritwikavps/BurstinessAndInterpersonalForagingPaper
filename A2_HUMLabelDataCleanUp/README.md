This directory contains code written to clean up human-listener labelled data used in this study. 

Please note that only files with the prefix A1, A2, etc. are executables, while all other files are supporting functions. Please also note that the executable files need to be executed in the order of prefixes A1 to A4. Finally, there are two optional executable files (with the additional prefix `Optl`) that don’t need to be executed. Data required to execute the scripts in this directory contain potentially identifying information and as such, access to this data is restricted, and the provided code is intended to orient the reader. 

The first of these, `A2Optl_Eaf0225_000602QuickFix.R`, was intended to quickly edit systematic textual errors in 0225_000602.eaf. This script was written during the first round of the .eaf file clean-up process, and these files have gone through multiple rounds of clean-up (both using the pipeline provided here, as well as with a trained graduate student researcher manually cleaning up flagged issues). As such, this optional script is now obsolete. 

The second optional script, ` A2Optl_GetUniqueTierNames.m` simply extracts the set of unique tier names cumulatively present the set of human-listener annotation files (.eaf files). This is in order to identify incorrect tier names (eg. `Adult Utt Dir` instead of `Adult Utterance Direction`). The output of this script is simply the list of unique tier names displayed in the console, and only serve easy visualisation. 

`A1_CopyEafFilesToFolder.m` copies .eaf files for each infant to a single common directory. Also creates .csv files with filename and infant ID info.

`A2_ParseEafFilesAndFlagErrors.R` parses annotation details and relevant line numbers from each .eaf file into a corresponding .csv file (the `AndFlagErrors` is a relic of the naming from when I first started writing this script. However, the error-flagging occurs in the next step.). This script is set up so that it can be executed on .eaf files before and after each round of data clean-up and generate output files with appropriate file names and/or in appropriate directories. Requires ` EafParsingFunctions.R`. 

`A3_GetErrorSummaryFromCsvFiles.m` flags errors in .eaf files and outputs different types of errors as separate .csv files. Also set up to be able to be executed pre- and post-clean up and generate appropriately named output files. Requires `GetAnnotInOrthoButNotInUttDir.m`, `GetAnnotOutsideCodingSheetBds.m`, `GetMismatchedTierAndIncorrectAnnotations.m`, and `GetRogueInfOrAdultAnnotsInOtherTiers.m`.

`A4_GetEditedEafFiles.R` edits .eaf files with errors (that are systematic and can be edited without further human-listener intervention; see relevant code for more details) based on outputs from `A3_GetErrorSummaryFromCsvFiles.m` and saves the edited .eaf files. Requires `EafSimpleErrorEditingFunctions.`, `EafDeleteAnnotsOutsideCodingSheetBounds_Functions.`, `EafTierNameEditingFunctions.R`.

At this point, all errors in the .eaf files that require a trained human-listener to listen to audio and make corrections to annotations, should be addressed. This would complete one round of data clean-up. 

Executing `A2_ParseEafFilesAndFlagErrors.R` on the cleaned-up .eaf files (by indicating the post-clean up status of files in the script) will generate .csv files based on the cleaned-up human-listener labelled files, on which further pre-processing is carried out. As a check-and-balance step, I also recommend running `A3_GetErrorSummaryFromCsvFiles.m` on this set of files, so that any additional errors that may have crept up can be addressed. 

For more specific details, please read comments about paths and other notes in the files before executing them.

