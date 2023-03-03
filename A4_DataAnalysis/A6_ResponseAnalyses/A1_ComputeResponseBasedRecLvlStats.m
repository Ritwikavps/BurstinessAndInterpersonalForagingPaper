clear all
clc

tic

%Ritwika VPS, UCLA Comm, Feb 2023

%This script and associated functions will analyse infant and adult step
%size distribution median, mean, std dev and 90th percentile values for WR
%and WOR categories, using a 1 s response interval

BasePath = '/Users/ritwikavps/Library/CloudStorage/GoogleDrive-ritwikavps@alumni.iisertvm.ac.in/My Drive/';%This is the base path to the google drive folder that may undergo change
DestinationPath = strcat(BasePath,'research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/DataTabsForStats/R6_DataTablesForResponseAnalyses/RecLvlSummaryStatistics/');

%The zscored data and the response data are in two different folders, so
%instead of creating another folder with those two stitched together, I am
%opting to sticth them in the script. 
ZscoreDataPath = strcat(BasePath,'research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA/');
ResponseDataPath = strcat(BasePath,'research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses/');

%read in table with .its file details
cd(strcat(BasePath,'research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData'));
opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
MetadataTab = readtable('MergedTSAcousticsMetadata.csv',opts);

%dir files
cd(ZscoreDataPath)
ZscoreDir = dir('*_ZscoredAcousticsTS_LENA.csv');

VocType = {'AN','AN','AN','CHNSP','CHNNSP','CHN'};
RespType = {'CHNSPRespToAn','CHNNSPRespToAn','ChnRespToAn','AnRespToCHNSP','AnRespToCHNNSP','AnRespToChn'};
ResponseWindowStr = {'1s','2s','5s','10s'};
statType = {'median','percentile','mean','std'};

p = parpool(6);

parfor i = 1:numel(RespType)
    for j = 1:numel(ResponseWindowStr)
        for k = 1:numel(statType)

            [WR_Tab, WOR_Tab] = GetTabForLmer_WR_WOR_RecLvlStats(ZscoreDir, ResponseDataPath, VocType{i} ,ResponseWindowStr{j} ,RespType{i}, statType{k},MetadataTab);
            NewTab = [WR_Tab; WOR_Tab];
            ResponseVec = [ones(size(WR_Tab,1),1); zeros(size(WOR_Tab,1),1)];
            NewTab.ResponseVec = ResponseVec;

            FileNameToSave = strcat(DestinationPath,statType{k},'_',RespType{i},'_',ResponseWindowStr{j},'.csv');
            writetable(NewTab,FileNameToSave)

        end
    end
end

delete(p) %delete parallel pool
toc

%Run R -- This needs to be sorted better
%!/usr/local/bin/Rscript Test.R

