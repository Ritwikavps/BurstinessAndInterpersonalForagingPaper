clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%Here, We will compute the number of:
    %AN responses to CHNSP as a fraction of total CHNSP vocs, 
    %AN response to CHNNSP as a fraction of total CHNNSP vocs
    %CHNNSP response to AN as a fraction of total CHNNSP vocs
    %CHNSP response to AN as a fraction of total CHNSP vocs

%go to directory with Matfile
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MatFiles'

%load mat file
load ZscoredData.mat
%Your variables are:
%C_AnChnspIndex       C_AnRespToCHNSP_5s   C_CHNNSPRespToAn_5s  C_ChnRespToAn_5s     C_zdB_ChnspAn        
%C_AnRespToCHNNSP_1s  C_AnRespToChn_1s     C_CHNSPRespToAn_1s   C_EndTime            C_zlogf0_ChnAn       
%C_AnRespToCHNNSP_2s  C_AnRespToChn_2s     C_CHNSPRespToAn_2s   C_SpeakerLabel       C_zlogf0_ChnspAn     
%C_AnRespToCHNNSP_5s  C_AnRespToChn_5s     C_CHNSPRespToAn_5s   C_StartTime          InfantAge            
%C_AnRespToCHNSP_1s   C_CHNNSPRespToAn_1s  C_ChnRespToAn_1s     C_SubrecEnd          InfantID             
%C_AnRespToCHNSP_2s   C_CHNNSPRespToAn_2s  C_ChnRespToAn_2s     C_zdB_ChnAn

for i = 1:numel(C_zlogf0_ChnspAn)

    FracAnRespToCHNNSP_1s(i) = ComputeResponseFrac(C_AnRespToCHNNSP_1s{i},'CHNNSP',C_SpeakerLabel{i});
    FracAnRespToCHNSP_1s(i) = ComputeResponseFrac(C_AnRespToCHNSP_1s{i},'CHNSP',C_SpeakerLabel{i});

    FracAnRespToCHNNSP_2s(i) = ComputeResponseFrac(C_AnRespToCHNNSP_2s{i},'CHNNSP',C_SpeakerLabel{i});
    FracAnRespToCHNSP_2s(i) = ComputeResponseFrac(C_AnRespToCHNSP_2s{i},'CHNSP',C_SpeakerLabel{i});

    FracAnRespToCHNNSP_5s(i) = ComputeResponseFrac(C_AnRespToCHNNSP_5s{i},'CHNNSP',C_SpeakerLabel{i});
    FracAnRespToCHNSP_5s(i) = ComputeResponseFrac(C_AnRespToCHNSP_5s{i},'CHNSP',C_SpeakerLabel{i});

    FracCHNSPRespToAn_1s(i) = ComputeResponseFrac(C_CHNSPRespToAn_1s{i},'CHNSP',C_SpeakerLabel{i});
    FracCHNNSPRespToAn_1s(i) = ComputeResponseFrac(C_CHNNSPRespToAn_1s{i},'CHNNSP',C_SpeakerLabel{i});

    FracCHNSPRespToAn_2s(i) = ComputeResponseFrac(C_CHNSPRespToAn_2s{i},'CHNSP',C_SpeakerLabel{i});
    FracCHNNSPRespToAn_2s(i) = ComputeResponseFrac(C_CHNNSPRespToAn_2s{i},'CHNNSP',C_SpeakerLabel{i});

    FracCHNSPRespToAn_5s(i) = ComputeResponseFrac(C_CHNSPRespToAn_5s{i},'CHNSP',C_SpeakerLabel{i});
    FracCHNNSPRespToAn_5s(i) = ComputeResponseFrac(C_CHNNSPRespToAn_5s{i},'CHNNSP',C_SpeakerLabel{i});

end

figure;
set(gcf,'color','white')
subplot(2,3,1)
hold all
title('AN response to CHN, 1s','FontSize',26)
plot(InfantAge,FracAnRespToCHNSP_1s,'b.','MarkerSize',10)
plot(InfantAge,FracAnRespToCHNNSP_1s,'r.','MarkerSize',10)
l1 = legend('CHNSP','CHNNSP');
set(l1,'FontSize',22)
ylabel('Num. responses as fraction of CHN type vocs','FontSize',22)

subplot(2,3,2)
hold all
title('AN response to CHN, 2s','FontSize',26)
plot(InfantAge,FracAnRespToCHNSP_2s,'b.','MarkerSize',10)
plot(InfantAge,FracAnRespToCHNNSP_2s,'r.','MarkerSize',10)

subplot(2,3,3)
hold all
title('AN response to CHN, 5s','FontSize',26)
plot(InfantAge,FracAnRespToCHNSP_5s,'b.','MarkerSize',10)
plot(InfantAge,FracAnRespToCHNNSP_5s,'r.','MarkerSize',10)

subplot(2,3,4)
hold all
title('CHN response to AN, 1s','FontSize',26)
plot(InfantAge,FracCHNSPRespToAn_1s,'b.','MarkerSize',10)
plot(InfantAge,FracCHNNSPRespToAn_1s,'r.','MarkerSize',10)
l1 = legend('CHNSP','CHNNSP');
set(l1,'FontSize',22)

subplot(2,3,5)
hold all
title('CHN response to AN, 2s','FontSize',26)
plot(InfantAge,FracCHNSPRespToAn_2s,'b.','MarkerSize',10)
plot(InfantAge,FracCHNNSPRespToAn_2s,'r.','MarkerSize',10)
xlabel('Infant Age','FontSize',22)

subplot(2,3,6)
hold all
title('CHN response to AN, 5s','FontSize',26)
plot(InfantAge,FracCHNSPRespToAn_5s,'b.','MarkerSize',10)
plot(InfantAge,FracCHNNSPRespToAn_5s,'r.','MarkerSize',10)

function FracResponse = ComputeResponseFrac(ResponseVector,AsFractionOfWhat,SpeakerVec)
    NumResponse = numel(ResponseVector(ResponseVector == 1)); %number of responses for that particular condition
    NumTypeOfFracDenom = numel(SpeakerVec(contains(SpeakerVec,AsFractionOfWhat) == 1)); %number of relevant speakertypes
    FracResponse = NumResponse/NumTypeOfFracDenom; %comput fraction
end