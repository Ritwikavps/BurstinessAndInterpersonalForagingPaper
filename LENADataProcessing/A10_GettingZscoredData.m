clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%Here, we will create a .mat file with z-scored amplitudes and log mean f0
%values (z-scored with respect to all adult and infant data) +  start and
%end times, speaker id, pause data and recording data

%We will have .mat files z-scored with CHNNSP and CHNSP, as well as ONLY
%CHNSP

%set destination path
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_MatFiles/';

%go to folder with Joined Acoustics data
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses'

TSFiles = dir('*_AcousticsTSJoined.csv');

opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%Initialise vectors to store dB and f0 values to zscore all together
dB_ChnAn = []; logf0_ChnAn = [];

dB_ChnspAn = []; logf0_ChnspAn = [];

%To conveniently store in cell arrays, these are the variable names for the
%tables: {'speaker'}    {'start'}    {'xEnd'}    {'duration'}    {'meanf0'}    {'dB'}    {'SubrecEnd'}
        %{'CHNSPRespToAn_1s'}    {'CHNNSPRespToAn_1s'}    {'ChnRespToAn_1s'}    {'AnRespToCHNSP_1s'}
        %{'AnRespToCHNNSP_1s'}    {'AnRespToChn_1s'}    {'CHNSPRespToAn_2s'}    {'CHNNSPRespToAn_2s'}
        %{'ChnRespToAn_2s'}    {'AnRespToCHNSP_2s'}    {'AnRespToCHNNSP_2s'}    {'AnRespToChn_2s'}
        %{'CHNSPRespToAn_5s'}    {'CHNNSPRespToAn_5s'}    {'ChnRespToAn_5s'}    {'AnRespToCHNSP_5s'}
        %{'AnRespToCHNNSP_5s'}    {'AnRespToChn_5s'}

%initliase cell arrays to store these; prefix C_ for cell
C_SpeakerLabel = cell(numel(TSFiles),1);  
C_StartTime = cell(numel(TSFiles),1);   C_EndTime = cell(numel(TSFiles),1);
C_SubrecEnd = cell(numel(TSFiles),1);
C_CHNSPRespToAn_1s = cell(numel(TSFiles),1);  C_CHNNSPRespToAn_1s = cell(numel(TSFiles),1);  
C_ChnRespToAn_1s = cell(numel(TSFiles),1);  C_AnRespToCHNSP_1s = cell(numel(TSFiles),1);
C_AnRespToCHNNSP_1s = cell(numel(TSFiles),1);  C_AnRespToChn_1s = cell(numel(TSFiles),1);    
C_CHNSPRespToAn_2s = cell(numel(TSFiles),1);  C_CHNNSPRespToAn_2s = cell(numel(TSFiles),1);
C_ChnRespToAn_2s = cell(numel(TSFiles),1);  C_AnRespToCHNSP_2s = cell(numel(TSFiles),1); 
C_AnRespToCHNNSP_2s = cell(numel(TSFiles),1);  C_AnRespToChn_2s = cell(numel(TSFiles),1);
C_CHNSPRespToAn_5s = cell(numel(TSFiles),1);  C_CHNNSPRespToAn_5s = cell(numel(TSFiles),1); 
C_ChnRespToAn_5s = cell(numel(TSFiles),1);  C_AnRespToCHNSP_5s = cell(numel(TSFiles),1);
C_AnRespToCHNNSP_5s = cell(numel(TSFiles),1);  C_AnRespToChn_5s = cell(numel(TSFiles),1);

%Cell arrays for z-scored values
C_zdB_ChnAn = cell(numel(TSFiles),1);  C_zlogf0_ChnAn = cell(numel(TSFiles),1);  
C_zdB_ChnspAn = cell(numel(TSFiles),1);  C_zlogf0_ChnspAn = cell(numel(TSFiles),1);  

%initialise additonl AN + CHNSP index cells for those z scored
%vectors; we can pick out all other relevant quantities using these indices
C_AnChnspIndex = cell(numel(TSFiles),1);

%go through TSFiles
for i = 1:numel(TSFiles)
    TSTab = readtable(TSFiles(i).name,'Delimiter',',');
    TSTabIndex = transpose(1:numel(TSTab.speaker)); %so that this is acolumn vector; we will use this to get indices of CHNSP + AN vocs

    %Store vectors in designated cell arrays
    C_SpeakerLabel{i,1} = TSTab.speaker;  
    C_StartTime{i,1} = TSTab.start;   C_EndTime{i,1} = TSTab.xEnd;
    C_SubrecEnd{i,1} = TSTab.SubrecEnd;
    C_CHNSPRespToAn_1s{i,1} = TSTab.CHNSPRespToAn_1s;  C_CHNNSPRespToAn_1s{i,1} = TSTab.CHNNSPRespToAn_1s;  
    C_ChnRespToAn_1s{i,1} = TSTab.ChnRespToAn_1s;  C_AnRespToCHNSP_1s{i,1} = TSTab.AnRespToCHNSP_1s;
    C_AnRespToCHNNSP_1s{i,1} = TSTab.AnRespToCHNNSP_1s;  C_AnRespToChn_1s{i,1} = TSTab.AnRespToChn_1s;    
    C_CHNSPRespToAn_2s{i,1} = TSTab.CHNSPRespToAn_2s;  C_CHNNSPRespToAn_2s{i,1} = TSTab.CHNNSPRespToAn_2s;
    C_ChnRespToAn_2s{i,1} = TSTab.ChnRespToAn_2s;  C_AnRespToCHNSP_2s{i,1} = TSTab.AnRespToCHNSP_2s; 
    C_AnRespToCHNNSP_2s{i,1} = TSTab.AnRespToCHNNSP_2s;  C_AnRespToChn_2s{i,1} = TSTab.AnRespToChn_2s;
    C_CHNSPRespToAn_5s{i,1} = TSTab.CHNSPRespToAn_5s;  C_CHNNSPRespToAn_5s{i,1} = TSTab.CHNNSPRespToAn_5s; 
    C_ChnRespToAn_5s{i,1} = TSTab.ChnRespToAn_5s;  C_AnRespToCHNSP_5s{i,1} = TSTab.AnRespToCHNSP_5s;
    C_AnRespToCHNNSP_5s{i,1} = TSTab.AnRespToCHNNSP_5s;  C_AnRespToChn_5s{i,1} = TSTab.AnRespToChn_5s;

    %concatenate dB and F0: for AN + CHNSP only and for AN + all CHN
    dB_ChnAn = [dB_ChnAn; TSTab.dB]; logf0_ChnAn = [logf0_ChnAn; log(TSTab.meanf0)];

    dB_ChnspAn = [dB_ChnspAn; TSTab.dB(contains(TSTab.speaker,{'CHNSP','AN'}) == 1)];
    logf0_ChnspAn = [logf0_ChnspAn; log(TSTab.meanf0(contains(TSTab.speaker,{'CHNSP','AN'}) == 1))];

    C_AnChnspIndex{i,1} = TSTabIndex(contains(TSTab.speaker,{'CHNSP','AN'}) == 1);

    %get number of elements in AN + all CHN vectors, and AN + CHNSP vectors
    NumelChnAn(i) = numel(TSTab.dB);
    NumelChnspAn(i) = numel(TSTab.dB(contains(TSTab.speaker,{'CHNSP','AN'}) == 1)); %doing this twice is a little inefficient but I dont want to add another variable name

    %for file name, age, and ID
    FNameFromTab = erase(TSFiles(i).name,'_AcousticsTSJoined.csv');

    for j = 1:numel(DataDetails.FileNameRoot)
        if strcmp(FNameFromTab,DataDetails.FileNameRoot{j}) == 1
            InfantID{i,1} = DataDetails.InfantID(j);
            InfantAgeDays(i,1) = DataDetails.InfantAgeDays(j);
            InfantAgeMonth(i,1) = DataDetails.InfantAgeMonth(j);
        end
    end
end

%get z-scored values
zdB_ChnAn = (dB_ChnAn - nanmean(dB_ChnAn))/nanstd(dB_ChnAn); 
zlogf0_ChnAn = (logf0_ChnAn - nanmean(logf0_ChnAn))/nanstd(logf0_ChnAn); 

zdB_ChnspAn = (dB_ChnspAn - nanmean(dB_ChnspAn))/nanstd(dB_ChnspAn); 
zlogf0_ChnspAn = (logf0_ChnspAn - nanmean(logf0_ChnspAn))/nanstd(logf0_ChnspAn); 

csumNumelChnspAn = [0 cumsum(NumelChnspAn)]; %cumulative sum of vector numels
csumNumelChnAn = [0 cumsum(NumelChnAn)]; %cumulative sum of vector numels

for i  = 1:length(csumNumelChnspAn)-1 %each vector can be put back together by picking out the cumsum(i) + 1 to cumsum(i+1) elements together
   C_zdB_ChnAn{i} =  zdB_ChnAn(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));
   C_zlogf0_ChnAn{i} = zlogf0_ChnAn(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));

   C_zdB_ChnspAn{i} =  zdB_ChnspAn(csumNumelChnspAn(i)+1:csumNumelChnspAn(i+1));
   C_zlogf0_ChnspAn{i} = zlogf0_ChnspAn(csumNumelChnspAn(i)+1:csumNumelChnspAn(i+1));   
end


MatFileName = strcat(destinationpath,'ZscoredData.mat');
save(MatFileName,...
    'C_SpeakerLabel', 'C_StartTime', 'C_EndTime', 'C_SubrecEnd',...
    'C_CHNSPRespToAn_1s', 'C_CHNNSPRespToAn_1s', 'C_ChnRespToAn_1s',...
    'C_AnRespToCHNSP_1s', 'C_AnRespToCHNNSP_1s', 'C_AnRespToChn_1s',...
    'C_CHNSPRespToAn_2s', 'C_CHNNSPRespToAn_2s', 'C_ChnRespToAn_2s',...
    'C_AnRespToCHNSP_2s', 'C_AnRespToCHNNSP_2s', 'C_AnRespToChn_2s',...
    'C_CHNSPRespToAn_5s', 'C_CHNNSPRespToAn_5s', 'C_ChnRespToAn_5s',...
    'C_AnRespToCHNSP_5s', 'C_AnRespToCHNNSP_5s', 'C_AnRespToChn_5s',...
    'C_zdB_ChnAn', 'C_zlogf0_ChnAn',...
    'C_AnChnspIndex', 'C_zdB_ChnspAn', 'C_zlogf0_ChnspAn',...
    'InfantID', 'InfantAgeDays','InfantAgeMonth')


