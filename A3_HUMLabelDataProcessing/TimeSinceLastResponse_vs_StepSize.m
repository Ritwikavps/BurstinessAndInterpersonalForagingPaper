clear all
clc

%Ritwika VPS, August 2022
%This script looks at whether there are correlations between step sizes and
%time from the last vocalisation from the other speaker type

%first, get Z scored values
ZscorePath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/';
cd(ZscorePath)

ZscoreFiles = dir('*_ZscoredAcousticsTS.csv');

%now get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%go through files
for i = 1:numel(ZscoreFiles)

    %get step sizes

    %get child id, age (month and days)
    ChildID{i,1} = DataDetails.InfantID(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS.csv')));
    ChildAgeMonths(i,1) = DataDetails.InfantAgeMonth(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS.csv')));
    ChildAgeDays(i,1) = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS.csv')));



end
