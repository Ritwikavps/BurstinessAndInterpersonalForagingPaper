clear all
clc

%Ritwika VPS, Sep 2022
%This script computes steps in 2d and 3d acoustic space as well as
%intervocalisation distances, in order to test whether either 2d or 3d step
%sizes are correlated with intervocalisation distance, for human labelled
%data, matched LENA data, and day long lena data

%Once again, by default, this script will do this for CHNSP vs adult vocs,
%but these can be changed to look at CHNNSP vs adult vocs, all CHN vs adult
%vocs, and CHN/CHNSP/CHNNSP vs any combination of T, U, and N-directed adult vocs. 
%NOTE: as these changes are made, please change output file names and
%relevant portion of the script accordingly

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';

%read in data table with infant age and id
opts = detectImportOptions(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv')); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv'),opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Human labelled data

%first cd into folder
HumlabelZscorePath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/');
cd(HumlabelZscorePath)

%dir all files
HumZscoreFiles = dir('*_ZscoredAcousticsTS_Hum.csv');

[CHNSP_HumlabelTab,AN_TUN_HumlabelTab] = OutputTableForSpaceStepsVsIntervocInt(HumZscoreFiles,DataDetails,'_ZscoredAcousticsTS_Hum.csv','HumanLabels',...
                                         {'T','U','N','X','C'},'CHN','AN');

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Matched LENA data

%first, get Z scored values
LENA5minMatchZscorePath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData');
cd(LENA5minMatchZscorePath)

%dir all files
MatchedLENA_ZscoreFiles = dir('*_MatchedLENA_ZscoreTS.csv');

[CHNSP_MatchedLENA5minTab,AN_MatchedLENA5minTab] = OutputTableForSpaceStepsVsIntervocInt(MatchedLENA_ZscoreFiles,DataDetails,'_MatchedLENA_ZscoreTS.csv','LENAmatch',...
                                         [],'CHNSP','AN');

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Daylong LENA data

%first, get Z scored values
LENAdaylongZscorePath = strcat(BasePath,'Data/LENAData/A8_ZscoredTSAcousticsLENA');
cd(LENAdaylongZscorePath)

LENAdaylongZscoreFiles = dir('*_ZscoredAcousticsTS_LENA.csv');

[CHNSP_LENATab,AN_LENATab] = OutputTableForSpaceStepsVsIntervocInt(LENAdaylongZscoreFiles,DataDetails,'_ZscoredAcousticsTS_LENA.csv','LENAdaylong',[],'CHNSP','AN');

%save files
cd(strcat(BasePath,'Data/AnalysesResults/RevisedResultswNewValidationCleanUpJune2023/'));

writetable(CHNSP_LENATab,'CHNSP_LENA_IntervocIntvsAcousticStepSize.csv');
writetable(AN_LENATab,'AN_LENA_IntervocIntvsAcousticStepSize.csv');

writetable(CHNSP_MatchedLENA5minTab,'CHNSP_LENA5minMatch_IntervocIntvsAcousticStepSize.csv');
writetable(AN_MatchedLENA5minTab,'AN_LENA5minMatch_IntervocIntvsAcousticStepSize.csv');

writetable(CHNSP_HumlabelTab,'CHNSP_Humlabels_IntervocIntvsAcousticStepSize.csv');
writetable(AN_TUN_HumlabelTab,'AN-TUN_Humlabels_IntervocIntvsAcousticStepSize.csv');




















