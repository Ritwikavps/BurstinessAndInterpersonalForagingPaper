clear all
clc

%Ritwika VPS, July 2022

%This script gets age and infant id, and zscores the human label dataset (CHN and AN data z-scored together)

%Now, z score data
%set destination path
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';
destinationpath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/');

%go to folder with Joined Acoustics data
cd(strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A5_TimeSerieswSectionMatching/' ));

TSFiles = dir('*_HumLabelsTS_w5minSectionsAndOlpInfo.csv');

opts = detectImportOptions(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv')); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv'),opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%Initialise vectors to store dB, f0, and duration values to zscore all together
dB_ChnAn = []; logf0_ChnAn = []; logDur_ChnAn = [];

%To conveniently store in cell arrays, these are the variable names for the
%tables: {'speaker'}    {'start'}    {'xEnd'}    {'duration'}    {'meanf0'}    {'dB'}    {'SectionNum'}

%Cell arrays for z-scored values
C_zdB = cell(numel(TSFiles),1);  C_zlogf0 = cell(numel(TSFiles),1); C_zlogDur = cell(numel(TSFiles),1);

%go through TSFiles
for i = 1:numel(TSFiles)

    TSTab = readtable(TSFiles(i).name,'Delimiter',',');
    
    Dur_ChnAn = TSTab.xEnd-TSTab.start; %get duration

%                         %check to make sure that there are no zero duration
%                         %events
%                         if numel(Dur_ChnAn) ~= numel(Dur_ChnAn ~= 0)
%                             i
%                         end

    Dur_ChnAn(Dur_ChnAn == 0) = NaN; %so that when we log, we dont get infinity values; the check in the previous lines tests for this (commented out), so this is a redundant thing

    %concatenate dB, F0, duration:
    dB_ChnAn = [dB_ChnAn; TSTab.dB]; logf0_ChnAn = [logf0_ChnAn; log(TSTab.meanf0)]; logDur_ChnAn = [logDur_ChnAn; log(Dur_ChnAn)];

    %get number of elements in AN + all CHN vectors
    NumelChnAn(i) = numel(TSTab.dB);
   
end

%get z-scored values
zdB_ChnAn = (dB_ChnAn - mean(dB_ChnAn,'omitnan'))/std(dB_ChnAn,'omitnan'); 
zlogf0_ChnAn = (logf0_ChnAn - mean(logf0_ChnAn,'omitnan'))/std(logf0_ChnAn,'omitnan'); 
zlogDur = (logDur_ChnAn - mean(logDur_ChnAn,'omitnan'))/std(logDur_ChnAn,'omitnan'); 

csumNumelChnAn = [0 cumsum(NumelChnAn)]; %cumulative sum of vector numels

for i  = 1:length(csumNumelChnAn)-1 %each vector can be put back together by picking out the cumsum(i) + 1 to cumsum(i+1) elements together
   C_zdB{i} =  zdB_ChnAn(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));
   C_zlogf0{i} = zlogf0_ChnAn(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));
   C_zlogDur{i} = zlogDur(csumNumelChnAn(i)+1:csumNumelChnAn(i+1)); 
end

%go through TSFiles
for i = 1:numel(TSFiles)

    %Read in table to add z scored mean f0 and dB values to
    NewTSTab = readtable(TSFiles(i).name,'Delimiter',',');
    NewTSTab = removevars(NewTSTab,{'meanf0','dB','duration'}); %remove meanf0 and dB columns. We will replace this with the z-scored values

    NewTSTab.logf0_z = C_zlogf0{i}; %add z scored acoustics
    NewTSTab.dB_z = C_zdB{i};
    NewTSTab.logDur_z = C_zlogDur{i};

    NewFn = strcat(destinationpath,erase(TSFiles(i).name,'_HumLabelsTS_w5minSectionsAndOlpInfo.csv'),'_ZscoredAcousticsTS_Hum.csv');

    writetable(NewTSTab,NewFn)
end

% 
