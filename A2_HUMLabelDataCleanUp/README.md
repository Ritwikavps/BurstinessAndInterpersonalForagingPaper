This directory contains code written to clean up human-listener labelled data used in this study. 

Only files with the prefixes A1, A2, etc. are executables, while all other files are supporting functions. Executable files need to be executed in the order of prefixes A1 to A4. Finally, there are three optional executable files (with the additional prefix `Optl`) that don’t need to be executed. Clean-up processes in these scripts target the `Infant Voc Type` and `Adult Utterance Direction` tiers (see comments in the individual files for more details), since these are the relevant tiers for the paper in question. However, the code provided here can be adapted to more comprehensively clean up other tiers.

The first of these optional scripts, `A0_OBSOLETE_Eaf0225_000602QuickFix.R`, was intended to quickly edit systematic textual errors in `0225_000602.eaf`. This script was written during the first round of the .eaf file clean-up process, and these files have gone through multiple rounds of clean-up (both using the pipeline provided here, as well as with a trained graduate student researcher manually cleaning up flagged issues). As such, this optional script is now obsolete. 

The second optional script (also obsolete now), `A0_OBSOLETE_Optl_FlagFileswIncorrectAudioFile.R` goes through .eaf files to identify any .eaf annotation file that was originally opened with and annotated with respect to an incorrect audio file. This issue was flagged in July 2024; as of that time, only `0776_000613.eaf` has this issue, and this file has since been excluded from all subsequent analyses. 

The last optional script, `A1Optl_GetUniqueTierNames.m` simply extracts the set of unique tier names cumulatively present the set of human-listener annotation files (.eaf files). This is to identify incorrect tier names (eg. `Adult Utt Dir` instead of `Adult Utterance Direction`). The output of this script is simply the list of unique tier names displayed in the console, and only serve easy visualisation. 

Data required to execute the scripts in this directory contain potentially identifying information and as such, access to this data is restricted, and the provided code is intended to orient the reader. See the OSF repository associated with this project for details on data organisation and what data is available/not available publicly. For details on output files for each executable script (and which of those output files are shared publicly), see `OpFileMasterMetadata.xlsx` in the main repository. 

`A1_ParseEafFilesAndFlagErrors.R` parses annotation details and relevant line numbers from each .eaf file into a corresponding .csv file (the `AndFlagErrors` is a relic of the naming from when I first started writing this script. However, the error-flagging occurs in the next step.). This script is set up so that it can be executed on .eaf files before and after each round of data clean-up and generate output files with appropriate file names and/or in appropriate directories. Requires ` EafParsingFunctions.R`. 

`A2_GetErrorSummaryFromCsvFiles.m` flags errors in the .csv files parsed from .eaf files and outputs different types of errors as separate .csv files. Also set up to be able to be executed pre- and post-clean up and generate appropriately named output files. Requires `GetAnnotInOrthoButNotInUttDir.m`, `GetAnnotOutsideCodingSheetBds.m`, `GetMismatchedTierAndIncorrectAnnotations.m`, and `GetRogueInfOrAdultAnnotsInOtherTiers.m`.

`A3_GetEditedEafFiles.R` edits .eaf files with errors (that are systematic and can be edited without further human-listener intervention; see relevant code for more details) based on outputs from `A2_GetErrorSummaryFromCsvFiles.m` and saves the edited .eaf files. Requires `EafSimpleErrorEditingFunctions.`, `EafDeleteAnnotsOutsideCodingSheetBounds_Functions.`, `EafTierNameEditingFunctions.R`.

At this point of running the clean-up pipeline, all errors in the .eaf files that require a trained human-listener to listen to audio and make corrections to annotations, should be addressed. This would complete one round of (non-human listenrr) data clean-up. 

Executing `A1_ParseEafFilesAndFlagErrors.R` on the cleaned-up .eaf files (by indicating the post-clean up status of files in the script) will generate .csv files based on the cleaned-up human-listener labelled files, on which further pre-processing is carried out. As a check-and-balance step, I also recommend running `A2_GetErrorSummaryFromCsvFiles.m` on this set of files, so that any additional errors that may have crept up can be addressed. 

For more specific details, please read comments about paths and other notes in the files before executing them.

