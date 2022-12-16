clear all
clc

%Ritwika VPS, August 2022
%This script looks at whether there are correlations between step sizes and
%time from the last vocalisation from the other speaker type, for 5 minute
%LENA segments matched to human labelled data.
%We have the option to use CHNSP only, CHNNSP only, or all CHN vocs,
%whereas adult vocs are not differentiated in any way. By default, we
%compare CHNSP vs AN vocs, but this can be changed. 
%NOTE: make sure to chnage output file names accordingly

%first, get Z scored values
ZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData';
cd(ZscorePath)

ZscoreFiles = dir('*_MatchedLENA_ZscoreTS.csv');

%now get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%initialise tables
Chnsp_NonInterveningStSizeTab = array2table(zeros(0,10));
Chnsp_NonInterveningStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','AmpStep','PitchStep','DurStep','IntVocInt','TwoDimSpaceStep',...
    'ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_NonInterveningStSizeTab = Chnsp_NonInterveningStSizeTab;

Chnsp_InterveningStSizeTab = array2table(zeros(0,11));
Chnsp_InterveningStSizeTab.Properties.VariableNames = {'TimeToResponse','TimeFromResponse','PitchStep','AmpStep','DurStep','IntVocInt',...
    'TwoDimSpaceStep','ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_InterveningStSizeTab = Chnsp_InterveningStSizeTab;

Chnsp_NonStSizeTab = array2table(zeros(0,13));
Chnsp_NonStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','PitchVar','AmpVar','DurationVar',...
    'PitchStepFromLastResponse','AmpStepFromLastResponse','DirectionalDurStepFromLastResponse','AbsDurStepFromLastResponse','TwoDimSpaceStep',...
    'ThreeDimSpaceStep','ChildID','ChildAgeDays','ChildAgeMonths'};
An_NonStSizeTab = Chnsp_NonStSizeTab;

%go through files
for i = 1:numel(ZscoreFiles)

    %get child id, age (month and days): fill in if needed for st
    ChildID = DataDetails.InfantID(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_MatchedLENA_ZscoreTS.csv')));
    ChildAgeMonths = DataDetails.InfantAgeMonth(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_MatchedLENA_ZscoreTS.csv')));
    ChildAgeDays = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_MatchedLENA_ZscoreTS.csv')));

    TableRead = readtable(ZscoreFiles(i).name,'Delimiter',','); %Read in table

    %first check if there are any pauses within a 5 min segment
    UniqSectionNum = unique(TableRead.SectionNum); %get unqiue section numbers
    for j = 1:numel(UniqSectionNum) %pick out subrecend values for each unqiue section number, see if there are any subrecend = 1 values
        TempSubRecEndSum = sum(TableRead.SubrecEnd(TableRead.SectionNum == UniqSectionNum(j)));
        if TempSubRecEndSum > 0
            error('File has pauses during a 5 min section')
        end
    end

    %pick out CHNSP and AN vocs ONLY
    Pitch = TableRead.logf0_z(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    Amplitude = TableRead.dB_z(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    StartTime = TableRead.start(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    EndTime = TableRead.xEnd(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    SpeakerLabels = TableRead.speaker(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    SectionNumVec = TableRead.SectionNum(contains(TableRead.speaker,{'CHNSP','AN'}),:);

    %get step sizes
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
        An_NonInterveningStSizeTab = [An_NonInterveningStSizeTab; struct2table(NonInterveningStruct)];
        An_InterveningStSizeTab = [An_InterveningStSizeTab; struct2table(InterveningStruct)];
        An_NonStSizeTab = [An_NonStSizeTab; struct2table(NonStSizeStruct)];
    end

end

%append 2d and 3d distances as well as absolute duration step to the tables
%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats';
cd(destinationpath)

writetable(Chnsp_NonInterveningStSizeTab,'Chnsp_NonInterveningStSize_MatchedLENA5minlabels.csv')
writetable(Chnsp_InterveningStSizeTab,'Chnsp_InterveningStSize_MatchedLENA5minlabels.csv')
writetable(Chnsp_NonStSizeTab,'Chnsp_NonStSize_MatchedLENA5minlabels.csv')
writetable(An_NonInterveningStSizeTab,'An_NonInterveningStSize_MatchedLENA5minlabels.csv')
writetable(An_InterveningStSizeTab,'An_InterveningStSize_MatchedLENA5minlabels.csv')
writetable(An_NonStSizeTab,'An_NonStSize_MatchedLENA5minlabels.csv')


