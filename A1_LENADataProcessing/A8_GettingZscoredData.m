clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%Here, we will create a .csv files with z-scored amplitudes, z-scored log mean f0, and z-scored log duration values (z-scored with respect to all adult and infant data) +  start and
%end times, speaker id, pause data and recording data

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATH ACCORDINGLY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';%This is the base path to the google drive folder that may undergo change
destinationpath = strcat(BasePath,'Data/LENAData/A7_ZscoredTSAcousticsLENA/'); %set destination path
cd(strcat(BasePath,'Data/LENAData/A6_AcousticsTSJoinedwPauses')); %go to folder with Joined Acoustics data
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------

TSFiles = dir('*_AcousticsTSJoined.csv'); %get time series files

%Initialise vectors to store dB, f0, and duration values to zscore all together
dB_ChnAn = []; logf0_ChnAn = []; logDur_ChnAn = [];

%Cell arrays for z-scored values
C_zdB = cell(numel(TSFiles),1);  C_zlogf0 = cell(numel(TSFiles),1); C_zlogDur = cell(numel(TSFiles),1);

%go through TSFiles
for i = 1:numel(TSFiles)

    TSTab = readtable(TSFiles(i).name,'Delimiter',',');
    
    Dur_ChnAn = TSTab.duration; %get duration

%                         %check to make sure that there are no zero duration
%                         %events
%                         if numel(Dur_ChnAn) ~= numel(Dur_ChnAn ~= 0)
%                             i
%                         end
    Dur_ChnAn(Dur_ChnAn == 0) = NaN; %so that when we log, we dont get infinity values; the check in the previous lines tests for this (commented out), so this is a redundant thing    
    dB_ChnAn = [dB_ChnAn; TSTab.dB]; logf0_ChnAn = [logf0_ChnAn; log(TSTab.meanf0)]; logDur_ChnAn = [logDur_ChnAn; log(Dur_ChnAn)]; %concatenate dB, F0, duration:
    NumelChnAn(i) = numel(TSTab.dB); %get number of elements in AN + all CHN vectors
end

%get z-scored values (ignore nan values)
zdB = (dB_ChnAn - mean(dB_ChnAn,'omitnan'))/std(dB_ChnAn,'omitnan'); 
zlogf0 = (logf0_ChnAn - mean(logf0_ChnAn,'omitnan'))/std(logf0_ChnAn,'omitnan'); 
zlogDur = (logDur_ChnAn - mean(logDur_ChnAn,'omitnan'))/std(logDur_ChnAn,'omitnan'); 

csumNumelChnAn = [0 cumsum(NumelChnAn)]; %cumulative sum of vector numels

for i  = 1:length(csumNumelChnAn)-1 %each vector can be put back together by picking out the cumsum(i) + 1 to cumsum(i+1) elements together
   C_zdB{i} =  zdB(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));
   C_zlogf0{i} =  zlogf0(csumNumelChnAn(i)+1:csumNumelChnAn(i+1)); 
   C_zlogDur{i} = zlogDur(csumNumelChnAn(i)+1:csumNumelChnAn(i+1)); 
end

%go through TSFiles
for i = 1:numel(TSFiles)
    %Read in table to add z scored mean f0 and dB values to
    NewTSTab = readtable(TSFiles(i).name,'Delimiter',',');
    NewTSTab = NewTSTab(:,[1:4 8 9]); %remove all columns exceot wavfile segment (for homebank voc cleaned data validation), start, end, speaker label, subrecend, and subrec file name
    
    NewTSTab.logf0_z = C_zlogf0{i}; %add z scored acoustics
    NewTSTab.dB_z = C_zdB{i};
    NewTSTab.logDur_z = C_zlogDur{i};

    NewFn = strcat(destinationpath,erase(TSFiles(i).name,'_AcousticsTSJoined.csv'),'_ZscoredAcousticsTS_LENA.csv');

    writetable(NewTSTab,NewFn)
end


