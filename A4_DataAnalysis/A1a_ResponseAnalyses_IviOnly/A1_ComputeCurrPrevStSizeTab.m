clear all
clc

%Ritwika VPS, UCLA Comm, Sep 2023; updated Dec 2023

% This script and associated functions take vocalisation data, compute response recived or not for a specified response interval, and output 
% current step size, previous step size, whether current step is WOR or WR, and writes the table for further statsitical analyses

%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%PLEASE CHANGE PATHS AND STRINGS IN FUNCTION CALL APPROPRIATELY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/';%This is the base path to the google drive folder that may undergo change
%read in table with .its file details
cd(strcat(BasePath,'MetadataFiles/'));
opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
MetadataTab = readtable('MergedTSAcousticsMetadata.csv',opts);

%LENA (day-long) specific inputs; 
LENA_ZscoreDataPath = strcat(BasePath,'LENAData/A7_ZscoredTSAcousticsLENA/');
LENA_DestinationPath = strcat(BasePath,'ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA/');
LENA_StringToRemoveFromFname = '_ZscoredAcousticsTS_LENA.csv';

%human listener labelled data specific inputs
H_ZscoreDataPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A7_HlabelTS_Zscored/');
H_DestinationPath = strcat(BasePath,'ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_H/');
H_StringToRemoveFromFname = '_ZscoredAcousticsTS_Hum.csv';

%match ed 5 min LENA data specific inputs
LENA_5min_ZscoreDataPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A8_MatchedLENAZscoreSections/');
LENA_5min_DestinationPath = strcat(BasePath,'ResultsTabs/ResponseAnalyses/ResponseEffect_w_CurrPrevStSizeControl_LENA5min/');
LENA_5min_StringToRemoveFromFname = '_MatchedLENA_ZscoreTS.csv';

%This is currently set up such that we are only looking at CHNSP responses to AN, and AN responses to CHNSP; but the scope of this can be expanded to
%other utterance types, eg. AN responses to all CHN utterances, etc
SpkrType = {'AN','CHNSP'};
OtherType = {'CHNSP','AN'};
NAType = {'AN','CHN'};

IviOnly = 1; %Flag for when we are only looking at Ivis (No coustics); 0 for when looking at BOTH Ivis and acoustics
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ResponseWindow = 1:10; %specify response window

%get outputs for LENA day-long, human-listener labelled, and matched LENA 5 min data
ComputeCurrPrevStSizeTabAndSave(LENA_ZscoreDataPath,LENA_DestinationPath,LENA_StringToRemoveFromFname,...
                                                                SpkrType,OtherType,NAType,ResponseWindow,MetadataTab,IviOnly) %LENA
ComputeCurrPrevStSizeTabAndSave(LENA_5min_ZscoreDataPath,LENA_5min_DestinationPath,LENA_5min_StringToRemoveFromFname,...
                                                                SpkrType,OtherType,NAType,ResponseWindow,MetadataTab,IviOnly) %LENA 5 min matched
%ComputeCurrPrevStSizeTabAndSave(H_ZscoreDataPath,H_DestinationPath,H_StringToRemoveFromFname,...
                                                                %SpkrType,OtherType,NAType,ResponseWindow,MetadataTab,IviOnly) % human listener labelled data


%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%this function generates and saves the data tables to do the curr-prev step size control response analyses for response windows of 1 to 10 s, for AN speakers (CHNSP) response, 
% and CHNSP speakers (AN response)
function [] = ComputeCurrPrevStSizeTabAndSave(ZscoreDataPath,DestinationPath,StringToRemoveFromFname,...
                                                                SpkrType,OtherType,NAType,ResponseWindow,MetadataTab,IviOnly)


%Inputs: - ZscoreDataPath: path with z-scored acoustics and time series data
        %- DestinationPath: path to save results data tables
        %- StringToRemoveFromFname: the specific string to remove from the z-scored file names to get the file name root
        %- SpkrType, OtherType, NAType: the cell arrays with the list of speakers of interest, responders, as well as the speaker tag that triggers an NA response.
            %So, if the i-th combination of speaker and responder is AN responses to CHNSP, then SpkrType{i} = CHNSP, OtherType{i} = AN, and NAType{i} = CHN.
            % This is because for AN responses to CHNSP, both CHNSP and CHNNSP triggers an NA response.
        %- ResponseWindow: the vector of response window values
        %- MetadataTab: table with metadata
        %- IviOnly: toggle 1 or 0 depending on whether we are only looking at Ivi (1) or both Ivi and acoustics (0).  

    %Get Zscored data
    cd(ZscoreDataPath); ZscoreDir = dir(strcat('*',StringToRemoveFromFname));
    
    p = parpool(5); %open parallel pool                       %p = parpool(numel(OtherType)); %open paralle pool
    
    for i = 1:numel(OtherType) %loop for OtherType (since the index for each OtherType speaker tag serves as the index for the corresponding Speaker and responder type, we only need
        %to index for one of these three vectors, in the for loop
        parfor j = 1:numel(ResponseWindow)
            if j == 1 %we only need to save the merge details table for one response window value
                [OpTab, ZeroIviMergeDetailsTab] = GetTabForLmer_CurrPrevStSize(ZscoreDir,ResponseWindow(j), SpkrType{i}, OtherType{i}, NAType{i}, StringToRemoveFromFname, MetadataTab,IviOnly); %get aggregated table with
                %current and prev step size info for each recording, as well as infant id and age details, for each combo of <Responder>_response to_<speaker> and response window
                FileNameToSave_ZeroIviMergeDetails = strcat(DestinationPath,'ZeroIviMergeDetails','_',OtherType{i},'RespTo',SpkrType{i},'.csv');
                writetable(ZeroIviMergeDetailsTab,FileNameToSave_ZeroIviMergeDetails)
            else
                [OpTab, ~] = GetTabForLmer_CurrPrevStSize(ZscoreDir,ResponseWindow(j), SpkrType{i}, OtherType{i}, NAType{i}, StringToRemoveFromFname, MetadataTab,IviOnly); %get aggregated table with
            end
           
            FileNameToSave_StepSiTab = strcat(DestinationPath,'CurrPrevStSize','_',OtherType{i},'RespTo',SpkrType{i},'_',num2str(ResponseWindow(j)),'s_IviOnly.csv');
            writetable(OpTab,FileNameToSave_StepSiTab)     
        end
    end
    delete(p) %delete parallel pool
end