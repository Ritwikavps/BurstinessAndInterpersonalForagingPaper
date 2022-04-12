clear all
clc

%Ritwika VPS, Feb 2022
%UCLA, Dpmt of Comm

%script to get response data for: 
    % Adult response to CHNSP only; CHNNSP only; and all CHN speaker types
    %CHNSP only, CHNNSP only, and all CHN speaker type responses to adult; for
        %1s, 2s, and 5 s response definition intervals 

%go to Acoustics TS with pause times incorporated folder
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A5_TimeSeriesWPauses'

%gat paths to response folder
ResponsePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A6_ResponseData/';

%get all TS .csv files (read ub wuth delimiter)
TSwPausesdir = dir('*TSwPauses.csv');

for i = 1:numel(TSwPausesdir) %go through these files

    TSwPausesTab = readtable(TSwPausesdir(i).name,'Delimiter',',');
    FileNameRoot = strrep(TSwPausesdir(i).name,'_TSwPauses.csv','');

    %get start time, end time, and speaker type         
    StartTime = TSwPausesTab.start; 
    EndTime = TSwPausesTab.xEnd;
    SpeakerVector = TSwPausesTab.speaker;
   
    %1s Interval Time
    %ResponseVector = ComputeResponseVector(StartTime, EndTime, SpeakerVec, SpeakerType, OtherType, NAType, IntervalTime)
    CHNSPRespToAn_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNSP','AN',1); %speaker = adult; other = CHNSP only; NAType = adult 
    CHNNSPRespToAn_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNNSP','AN',1); %speaker = adult; other = CHNNSP only;
    ChnRespToAn_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHN','AN',1); %speaker = adult; other = all CHN types
    AnRespToCHNSP_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNSP','AN','CHN',1); %speaker = CHNSP; other = adult; NAType = both CHN types
    AnRespToCHNNSP_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNNSP','AN','CHN',1); %speaker = CHNNSP; other = adult; 
    AnRespToChn_1s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHN','AN','CHN',1); %speaker = all CHN types; other = adult; 
    
    %2s Interval Time
    CHNSPRespToAn_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNSP','AN',2); %speaker = adult; other = CHNSP only; NAType = adult
    CHNNSPRespToAn_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNNSP','AN',2); %speaker = adult; other = CHNNSP only
    ChnRespToAn_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHN','AN',2); %speaker = adult; other = all CHN types
    AnRespToCHNSP_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNSP','AN','CHN',2); %speaker = CHNSP; other = adult; NAType = both CHN types
    AnRespToCHNNSP_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNNSP','AN','CHN',2); %speaker = CHNNSP; other = adult; 
    AnRespToChn_2s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHN','AN','CHN',2); %speaker = all CHN types; other = adult; 
    
    %5s Interval Time
    CHNSPRespToAn_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNSP','AN',5); %speaker = adult; other = CHNSP only; NAType = adult
    CHNNSPRespToAn_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHNNSP','AN',5); %speaker = adult; other = CHNNSP only
    ChnRespToAn_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'AN','CHN','AN',5); %speaker = adult; other = all CHN types
    AnRespToCHNSP_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNSP','AN','CHN',5); %speaker = CHNSP; other = adult; NAType = both CHN types
    AnRespToCHNNSP_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHNNSP','AN','CHN',5); %speaker = CHNNSP; other = adult; 
    AnRespToChn_5s = ComputeResponseVector(StartTime,EndTime,SpeakerVector,'CHN','AN','CHN',5); %speaker = all CHN types; other = adult; 

    %compile response table 
    ResponseTable = table(CHNSPRespToAn_1s,CHNNSPRespToAn_1s,ChnRespToAn_1s,AnRespToCHNSP_1s,AnRespToCHNNSP_1s,AnRespToChn_1s,...
        CHNSPRespToAn_2s,CHNNSPRespToAn_2s,ChnRespToAn_2s,AnRespToCHNSP_2s,AnRespToCHNNSP_2s,AnRespToChn_2s,...
        CHNSPRespToAn_5s,CHNNSPRespToAn_5s,ChnRespToAn_5s,AnRespToCHNSP_5s,AnRespToCHNNSP_5s,AnRespToChn_5s);

    AcousticTSwResponses = [TSwPausesTab ResponseTable];

    %write tables
    writetable(AcousticTSwResponses,strcat(ResponsePath,FileNameRoot,'_Responses.csv'));

end
