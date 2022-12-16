***
Please note that this is a directory that is actively being modified. Once the contents of this directory is stable, the README will be updated to reflect
that. 
***

**
For more details regarding code in each directory, see README files in the pertinent directory. 
**

A1_FirstPassAnalyses contains code used for first pass analyses. Outputs from this directory provides broad insights into the data. Some examples:
    
    1. What is the total number of AN vocs across the day-long LENA dataset? 
    2. What is the total number of CHNSP vocs across the 5 minute human listener labelled dataset?
    
A2_RecordingLvlSummaryMeasures contains code used to get recording level summaries (eg. mean, median, and 90th percentile values of various acoustic
measures for different speaker classes) of data (day-long LENA, 5 min human listener labelled data, and corresponding 5 min LENA labelled data), and 
to do statistical analyses on these summary measures.

A3_Correlation_InterVocInt_Vs_StepSizes contains code used to test whether 2d and 3d acoustic step sizes as well categorical step sizes (steps between 
different vocalisation class types; eg. steps CHNNSP between CHNSP types, steps between C and X annotation types for human-listener annotated data). 

A4_RecordingLvlCorrelations contains code used to test whether patterns at the recording level are correlated across temporal scales (eg. day-long LENA vs
5 min LENA) and annotation type (eg. 5 min human listener annotated data vs. corresponding 5 min LENA labelled data). 

    [Note to self: This folder should come after Time since last interaction analyses]

A4_TimeFromLastInteraction_Vs_NonCategoricalStepSize contains code used to test whether elapsed time since the last interaction between different speaker
types predict acoustic step sizes between consecutive vocalisations by the same speaker type. 

A5_TimeFromLastInteraction_Vs_CategoricalStepSize contains code used to test whether elapsed time since the last infant-adult interaction predict 
categorical step sizes between consecutive vocalisations by infant speakers.

    [Note to self: Link schematics and data tables (either on OSF or here) and refer to them]
    
    
