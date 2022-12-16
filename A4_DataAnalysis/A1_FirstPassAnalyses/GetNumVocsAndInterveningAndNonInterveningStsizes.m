clear all
clc

%Ritwika VPS, Sep 2022
%Script to get the number of data points in different annotation methods

%LENA day lobng data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA/')
LENADaylongFiles = dir('*_ZscoredAcousticsTS_LENA.csv');

%Human listener labelled data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/');
HlabelFiles = dir('*_ZscoredAcousticsTS_Hum.csv');

%5 min LENA data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData/')
LENA5minFiles = dir('*_MatchedLENA_ZscoreTS.csv');

%get LENA daylong numbers
for i = 1:numel(LENADaylongFiles)
    TempTab = readtable(LENADaylongFiles(i).name);

    LENADayAnNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'AN')));
    LENADayCHNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'CHNSP')));
    LENADayCHNNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'CHNNSP')));
end

%get LENA 5 min uimbers
for i = 1:numel(LENA5minFiles)
    TempTab = readtable(LENA5minFiles(i).name);

    LENA5minAnNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'AN')));
    LENA5minCHNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'CHNSP')));
    LENA5minCHNNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'CHNNSP')));
end

%get human labelled data numbers
for i = 1:numel(HlabelFiles)
    TempTab = readtable(HlabelFiles(i).name);

    HlabelAnNum(i,1) = numel(TempTab.speaker(contains(TempTab.speaker,'AN')));
    HlabelCHNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.Annotation,{'C','X'})));
    HlabelCHNNSPNum(i,1) = numel(TempTab.speaker(contains(TempTab.Annotation,{'R','L'})));
end

AnnotationMethod{1,1} = 'LENA daylong';
AnnotationMethod{2,1} = 'LENA 5 min';
AnnotationMethod{3,1} = 'Human listener 5 min';

NumVocsAN = [sum(LENADayAnNum); sum(LENA5minAnNum); sum(HlabelAnNum)];
NumVocsCHNSP = [sum(LENADayCHNSPNum); sum(LENA5minCHNSPNum); sum(HlabelCHNSPNum)];
NumVocsCHNNSP = [sum(LENADayCHNNSPNum); sum(LENA5minCHNNSPNum); sum(HlabelCHNNSPNum)];
NumVocsCHN = NumVocsCHNNSP + NumVocsCHNSP;

T_vocnums = table(AnnotationMethod,NumVocsAN,NumVocsCHN,NumVocsCHNSP,NumVocsCHNNSP);

%get numbers for step sizes 9intervening and non intervening)------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%LENA daylong data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/')
LENADaylongStSizeFiles = dir('*InterveningStSize*.csv');
for i = 1:numel(LENADaylongStSizeFiles)

    TempTab = readtable(LENADaylongStSizeFiles(i).name);

    if contains(LENADaylongStSizeFiles(i).name,'NonIntervening')
        if contains (LENADaylongStSizeFiles(i).name,'An_')
            AnNonIntervening(1,1) = numel(TempTab.AmpStep);
        else
            ChnspNonIntervening(1,1) = numel(TempTab.AmpStep);
        end
    else
        if contains (LENADaylongStSizeFiles(i).name,'An_')
            AnIntervening(1,1) = numel(TempTab.AmpStep);
        else
            ChnspIntervening(1,1) = numel(TempTab.AmpStep);
        end
    end
end

%LENA 5 min data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/');
LENA5minStSizeFiles = dir('*InterveningStSize*.csv');
for i = 1:numel(LENA5minStSizeFiles)

    TempTab = readtable(LENA5minStSizeFiles(i).name);

    if contains(LENA5minStSizeFiles(i).name,'NonIntervening')
        if contains (LENA5minStSizeFiles(i).name,'An_')
            AnNonIntervening(2,1) = numel(TempTab.AmpStep);
        else
            ChnspNonIntervening(2,1) = numel(TempTab.AmpStep);
        end
    else
        if contains (LENA5minStSizeFiles(i).name,'An_')
            AnIntervening(2,1) = numel(TempTab.AmpStep);
        else
            ChnspIntervening(2,1) = numel(TempTab.AmpStep);
        end
    end
end

%Human listener labelled data
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/')
HlabelStSizeFiles = dir('*InterveningStSize*.csv');
for i = 1:numel(HlabelStSizeFiles)

    TempTab = readtable(HlabelStSizeFiles(i).name);

    if contains(HlabelStSizeFiles(i).name,'NonIntervening')
        if contains (HlabelStSizeFiles(i).name,'An_')
            AnNonIntervening(3,1) = numel(TempTab.AmpStep);
        else
            ChnspNonIntervening(3,1) = numel(TempTab.AmpStep);
        end
    else
        if contains (HlabelStSizeFiles(i).name,'An_')
            AnIntervening(3,1) = numel(TempTab.AmpStep);
        else
            ChnspIntervening(3,1) = numel(TempTab.AmpStep);
        end
    end
end

T_stsizenums = table(AnnotationMethod,AnNonIntervening,AnIntervening,ChnspNonIntervening,ChnspIntervening);

%write tables
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels/')
writetable(T_vocnums,'NumAnAndChnVocs.xlsx')
writetable(T_stsizenums,'NumInterveningAndNonInterveningStSizes.xlsx')
