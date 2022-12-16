clear all
clc

%Ritwika VPS, August 2022
%This script looks at whether there are correlations between step sizes and
%time from the last vocalisation from the other speaker type, for 5 minute
%human labelled data
%Any combination of child and adult voc types (C,X,R,L; and T,U,N, respectiveluy) can be
%selected for this analysis.
%For eg. picking out X and C type child vocs and T, U, and N type adult
%vocs will provide the closest match to LENA, since LENA picks out child
%speech-related vocs (X and C) but does not distinguish between adult vocs.
%Remember to name the output files accordingly, based on the selection of
%voc types. If child X and C types and adult T, U and N types are selected,
%I prefix the files with Chnsp and An_TUN
%NOTE: Please make sure to change the output and file names

%first, get Z scored values
ZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/';
cd(ZscorePath)

ZscoreFiles = dir('*_ZscoredAcousticsTS_Hum.csv');

%now get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%initialise tables
Chnsp_NonInterveningStSizeTab = array2table(zeros(0,10));
Chnsp_NonInterveningStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','AmpStep','PitchStep','DurStep','IntVocInt','TwoDimSpaceStep',...
    'ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_TUN_NonInterveningStSizeTab = Chnsp_NonInterveningStSizeTab;

Chnsp_InterveningStSizeTab = array2table(zeros(0,11));
Chnsp_InterveningStSizeTab.Properties.VariableNames = {'TimeToResponse','TimeFromResponse','PitchStep','AmpStep','DurStep','IntVocInt',...
    'TwoDimSpaceStep','ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_TUN_InterveningStSizeTab = Chnsp_InterveningStSizeTab;

Chnsp_NonStSizeTab = array2table(zeros(0,13));
Chnsp_NonStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','PitchVar','AmpVar','DurationVar',...
    'PitchStepFromLastResponse','AmpStepFromLastResponse','DirectionalDurStepFromLastResponse','AbsDurStepFromLastResponse','TwoDimSpaceStep',...
    'ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_TUN_NonStSizeTab = Chnsp_NonStSizeTab;

%go through files
for i = 1:numel(ZscoreFiles)

    %get child id, age (month and days): fill in if needed for st
    ChildID = DataDetails.InfantID(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));
    ChildAgeMonths = DataDetails.InfantAgeMonth(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));
    ChildAgeDays = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));

    %get step sizes
    TableRead = readtable(ZscoreFiles(i).name,'Delimiter',',');
    %pick out CHNSP and child directed or direction unknown AN vocs ONLY
    Pitch = TableRead.logf0_z(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);
    Amplitude = TableRead.dB_z(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);
    StartTime = TableRead.start(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);
    EndTime = TableRead.xEnd(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);
    SpeakerLabels = TableRead.speaker(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);
    SectionNumVec = TableRead.SectionNum(contains(TableRead.Annotation,{'T','U','N','X','C'}),:);

    %CHNSP vocs
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'AN'))) %make sure there are OTHER type vocs
        [NonInterveningStruct,InterveningStruct,NonStSizeStruct] =...
            GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amplitude,StartTime,EndTime,SpeakerLabels,SectionNumVec,'CHN','AN',...
            ChildID,ChildAgeDays,ChildAgeMonths);
    
        %cast to tables
        Chnsp_NonInterveningStSizeTab = [Chnsp_NonInterveningStSizeTab; struct2table(NonInterveningStruct)];
        Chnsp_InterveningStSizeTab = [Chnsp_InterveningStSizeTab; struct2table(InterveningStruct)];
        Chnsp_NonStSizeTab = [Chnsp_NonStSizeTab; struct2table(NonStSizeStruct)];
    end
    

    %child direted or unknown direction Adult vocs
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'CHN')))
        [NonInterveningStruct,InterveningStruct,NonStSizeStruct] =...
            GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amplitude,StartTime,EndTime,SpeakerLabels,SectionNumVec,'AN','CHN',...
            ChildID,ChildAgeDays,ChildAgeMonths);
        %cast to tables
        An_TUN_NonInterveningStSizeTab = [An_TUN_NonInterveningStSizeTab; struct2table(NonInterveningStruct)];
        An_TUN_InterveningStSizeTab = [An_TUN_InterveningStSizeTab; struct2table(InterveningStruct)];
        An_TUN_NonStSizeTab = [An_TUN_NonStSizeTab; struct2table(NonStSizeStruct)];
    end

end

%append 2d and 3d distances as well as absolute duration step to the tables
%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats';
cd(destinationpath)

writetable(Chnsp_NonInterveningStSizeTab,'Chnsp_NonInterveningStSize_HumLabel.csv')
writetable(Chnsp_InterveningStSizeTab,'Chnsp_InterveningStSize_HumLabel.csv')
writetable(Chnsp_NonStSizeTab,'Chnsp_NonStSize_HumLabel.csv')
writetable(An_TUN_NonInterveningStSizeTab,'An_TUN_NonInterveningStSize_HumLabel.csv')
writetable(An_TUN_InterveningStSizeTab,'An_TUN_InterveningStSize_HumLabel.csv')
writetable(An_TUN_NonStSizeTab,'An_TUN_NonStSize_HumLabel.csv')


