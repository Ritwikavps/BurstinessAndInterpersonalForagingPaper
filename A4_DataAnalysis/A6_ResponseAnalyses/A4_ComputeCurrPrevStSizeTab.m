clear all
clc

%#This script and associated functions take vocalisation data, computes response recived or not for a specified response interval, and outputs 
% current step size, previous step size, whether current step is WOR or WR
% to be saved for further statsitical analyses

%Ritwika VPS, UCLA Comm, Sep 2023

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';%This is the base path to the google drive folder that may undergo change
DestinationPath = strcat(BasePath,'Data/AnalysesResults/DataTabsForStats/R6_DataTablesForResponseAnalyses/CurrPrevStSi/');
%Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData'

%The zscored data and the response data are in two different folders, so
%instead of creating another folder with those two stitched together, I am
%opting to sticth them in the script. 
ZscoreDataPath = strcat(BasePath,'Data/LENAData/A8_ZscoredTSAcousticsLENA/');
ResponseDataPath = strcat(BasePath,'Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses/');

%read in table with .its file details
cd(strcat(BasePath,'Data/LENAData'));
opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
MetadataTab = readtable('MergedTSAcousticsMetadata.csv',opts);

%dir files
cd(ZscoreDataPath)
ZscoreDir = dir('*_ZscoredAcousticsTS_LENA.csv');

ResponseWindow = 1:10; %specify response window
SpkrType = {'AN','CHNSP'};
OtherType = {'CHNSP','AN'};
NAType = {'AN','CHN'};
StringToRemoveFromFname = '_ZscoredAcousticsTS_LENA.csv';

p = parpool(2);

parfor i = 1:numel(OtherType)
    for j = 1:numel(ResponseWindow)

        [OpTab] = GetTabForLmer_CurrPrevStSize(ZscoreDir,ResponseWindow(j), SpkrType{i}, OtherType{i}, NAType{i}, StringToRemoveFromFname, MetadataTab);
       
        FileNameToSave = strcat(DestinationPath,'CurrPrevStSize','_',OtherType{i},'RespTo',SpkrType{i},'_',num2str(ResponseWindow(j)),'s.csv');
        writetable(OpTab,FileNameToSave)

    end
end
