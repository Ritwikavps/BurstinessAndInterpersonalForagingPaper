clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%Here, we will create a .csv files with z-scored amplitudes and log mean f0
%values (z-scored with respect to all adult and infant data) +  start and
%end times, speaker id, pause data and recording data

%set destination path
destinationpath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA/';

%go to folder with Joined Acoustics data
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses'

TSFiles = dir('*_AcousticsTSJoined.csv');

%Initialise vectors to store dB and f0 values to zscore all together
dB_ChnAn = []; logf0_ChnAn = [];

%Cell arrays for z-scored values
C_zdB = cell(numel(TSFiles),1);  C_zlogf0 = cell(numel(TSFiles),1);  

%go through TSFiles
for i = 1:numel(TSFiles)

    TSTab = readtable(TSFiles(i).name,'Delimiter',',');
    %concatenate dB and F0:
    dB_ChnAn = [dB_ChnAn; TSTab.dB]; logf0_ChnAn = [logf0_ChnAn; log(TSTab.meanf0)];
    %get number of elements in AN + all CHN vectors
    NumelChnAn(i) = numel(TSTab.dB);

end

%get z-scored values
zdB_ChnAn = (dB_ChnAn - mean(dB_ChnAn,'omitnan'))/std(dB_ChnAn,'omitnan'); 
zlogf0_ChnAn = (logf0_ChnAn - mean(logf0_ChnAn,'omitnan'))/std(logf0_ChnAn,'omitnan'); 

csumNumelChnAn = [0 cumsum(NumelChnAn)]; %cumulative sum of vector numels

for i  = 1:length(csumNumelChnAn)-1 %each vector can be put back together by picking out the cumsum(i) + 1 to cumsum(i+1) elements together
   C_zdB{i} =  zdB(csumNumelChnAn(i)+1:csumNumelChnAn(i+1));
   C_zlogf0{i} =  zlogf0(csumNumelChnAn(i)+1:csumNumelChnAn(i+1)); 
end

%go through TSFiles
for i = 1:numel(TSFiles)

    %Read in table to add z scored mean f0 and dB values to
    NewTSTab = readtable(TSFiles(i).name,'Delimiter',',');
    NewTSTab = NewTSTab(:,[1 2 3 4 7]); %remove all columns exceot start, end, duration, speaker label, and subrecend
    
    NewTSTab.logf0_z = C_zlogf0{i}; %add z scored acoustics
    NewTSTab.dB_z = C_zdB{i};

    NewFn = strcat(destinationpath,erase(TSFiles(i).name,'_AcousticsTSJoined.csv'),'_ZscoredAcousticsTS_LENA.csv');

    writetable(NewTSTab,NewFn)

end


