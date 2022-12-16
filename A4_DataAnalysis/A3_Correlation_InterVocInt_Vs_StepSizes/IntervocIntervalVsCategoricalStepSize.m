clear all
clc

%Ritwika VPS, Oct 2022
%This script computes categorical steps (steps between CHNSP and CHNNSP, or X and C) as well as
%intervocalisation distances, in order to test whether categorical steps
%are correlated with intervocalisation distance, for human labelled
%data, matched LENA data, and day long lena data

%This script will do this for steps between X and C type vocs for
%human-listener annotated data, as well as CHNSP and CHNNSP types for
%LENA-labelled data (and teh equivalent for human-labelled data: steps
%between {X,C}, and {R,L} types)

%read in data table with infant age and id
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Human labelled data-X/C

%first cd into folder
HumlabelZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/';
cd(HumlabelZscorePath)

%dir all files
HumZscoreFiles = dir('*_ZscoredAcousticsTS_Hum.csv');

[XC_CategoricalStepsHumLabelTab] = OutputTableForCategoricalStepsVsIntervocInt(HumZscoreFiles,DataDetails,'_ZscoredAcousticsTS_Hum.csv','HumanLabels',{'X','C'},'C');

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Human labelled data-CHNSP/CHNNSP
[ChnspChnnsp_CategoricalStepsHumLabelTab] = OutputTableForCategoricalStepsVsIntervocInt(HumZscoreFiles,DataDetails,'_ZscoredAcousticsTS_Hum.csv',...
                                                                                        'HumanLabels',{'X','C','R','L'},{'X','C'});

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Matched LENA data

%first, get Z scored values
LENA5minMatchZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData';
cd(LENA5minMatchZscorePath)

%dir all files
MatchedLENA_ZscoreFiles = dir('*_MatchedLENA_ZscoreTS.csv');

[ChnspChnnsp_CategoricalStepsMatchedLENA5minTab] = OutputTableForCategoricalStepsVsIntervocInt(MatchedLENA_ZscoreFiles,DataDetails,'_MatchedLENA_ZscoreTS.csv',...
                                                                                            'LENAmatch','CHN','CHNSP');

%---------------------------------------------------------------------------------------------------------------------------------------------------------
%Daylong LENA data

%first, get Z scored values
LENAdaylongZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA';
cd(LENAdaylongZscorePath)

LENAdaylongZscoreFiles = dir('*_ZscoredAcousticsTS_LENA.csv');

[ChnspChnnsp_CategoricalStepsLENATab] = OutputTableForCategoricalStepsVsIntervocInt(LENAdaylongZscoreFiles,DataDetails,'_ZscoredAcousticsTS_LENA.csv',...
                                                                                            'LENAdaylong','CHN','CHNSP');

%save files
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/DataTablesForCategoricalStepSizesvsInterVocInterval'

writetable(ChnspChnnsp_CategoricalStepsLENATab,'ChnspChnnsp_LENA_CategoricalStSizvsInterVocInt.csv');

writetable(ChnspChnnsp_CategoricalStepsMatchedLENA5minTab,'ChnspChnnsp_LENA5minMatch_CategoricalStSizvsInterVocInt.csv');

writetable(XC_CategoricalStepsHumLabelTab,'XC_Humlabels_CategoricalStSizvsInterVocInt.csv');
writetable(ChnspChnnsp_CategoricalStepsHumLabelTab,'ChnspChnnsp_Humlabels_CategoricalStSizvsInterVocInt.csv');




















