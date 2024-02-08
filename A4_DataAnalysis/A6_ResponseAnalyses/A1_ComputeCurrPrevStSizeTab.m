clear all
clc

%Ritwika VPS, UCLA Comm, Sep 2023

% This script and associated functions take vocalisation data, compute response recived or not for a specified response interval, and output 
% current step size, previous step size, whether current step is WOR or WR, and writes the table for further statsitical analyses

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';%This is the base path to the google drive folder that may undergo change
DestinationPath = strcat(BasePath,'Data/ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_NanStExcluded/');

%read in table with .its file details
cd(strcat(BasePath,'Data/MetadataFiles'));
opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
MetadataTab = readtable('MergedTSAcousticsMetadata.csv',opts);

%Get Zscored data
ZscoreDataPath = strcat(BasePath,'Data/LENAData/A7_ZscoredTSAcousticsLENA/');
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

        [OpTab] = GetTabForLmer_CurrPrevStSize(ZscoreDir,ResponseWindow(j), SpkrType{i}, OtherType{i}, NAType{i}, StringToRemoveFromFname, MetadataTab); %get aggregated table with
        %current and prev step size info for each recording, as well as infant id and age details, for each combo of <Responder>_response to_<speaker> and response window
       
        FileNameToSave = strcat(DestinationPath,'CurrPrevStSize','_',OtherType{i},'RespTo',SpkrType{i},'_',num2str(ResponseWindow(j)),'s.csv');
        writetable(OpTab,FileNameToSave)
    end
end

delete(p) %delete parallel pool