clear all
clc

%Ritwika VPS, August 2022
%This script looks at whether there are correlations between step sizes and
%time from the last vocalisation from the other speaker type, for day-long LENA data
%For now, we only use CHNSP vocs, but we can extend this to include CHNNSP
%vocs as well, or only have CHNNSP vocs.
%Please make sure to edit the script and name outoput files accordingly if
%the voc types are changed

%first, get Z scored values
ZscorePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA';
cd(ZscorePath)

ZscoreFiles = dir('*_ZscoredAcousticsTS_LENA.csv');

%now get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: FileNameRoot,   InfantAgeDays,    InfantAgeMonth,    InfantID; note that infant age
%is in days

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
    ChildID = DataDetails.InfantID(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_LENA.csv')));
    ChildAgeDays = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_LENA.csv')));
    ChildAgeMonth = DataDetails.InfantAgeMonth(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_LENA.csv')));

    %get step sizes
    TableRead = readtable(ZscoreFiles(i).name,'Delimiter',',');
    SubrecEnd = TableRead.SubrecEnd;

    %based on subrecend, generate SectionNumVec: basically, a vector
    %identifying the section number the voc belongs to, if there are
    %subrecs in the recording
    SectionNumValue = 1; %default
    SectionNumVec = zeros(size(SubrecEnd)); %initialise
    for j = 1:numel(SubrecEnd)
        SectionNumVec(j) = SectionNumValue;
        if SubrecEnd(j) == 1
            SectionNumValue = SectionNumValue + 1; %if current voc is end of a subrec, increment section number value
        end
    end

    %pick out CHNSP and AN vocs ONLY
    Pitch = TableRead.logf0_z(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    Amplitude = TableRead.dB_z(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    StartTime = TableRead.start(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    EndTime = TableRead.xEnd(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    SpeakerLabels = TableRead.speaker(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    SectionNumVec = SectionNumVec(contains(TableRead.speaker,{'CHNSP','AN'}),:);
    

    %CHNSP vocs
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'AN'))) %make sure there are OTHER type vocs
        [NonInterveningStruct,InterveningStruct,NonStSizeStruct] =...
            GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amplitude,StartTime,EndTime,SpeakerLabels,SectionNumVec,'CHN','AN',...
            ChildID,ChildAgeDays,ChildAgeMonth);
    
        %cast to tables
        Chnsp_NonInterveningStSizeTab = [Chnsp_NonInterveningStSizeTab; struct2table(NonInterveningStruct)];
        Chnsp_InterveningStSizeTab = [Chnsp_InterveningStSizeTab; struct2table(InterveningStruct)];
        Chnsp_NonStSizeTab = [Chnsp_NonStSizeTab; struct2table(NonStSizeStruct)];
    end
    

    %child direted or unknown direction Adult vocs
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'CHN')))
        [NonInterveningStruct,InterveningStruct,NonStSizeStruct] =...
            GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amplitude,StartTime,EndTime,SpeakerLabels,SectionNumVec,'AN','CHN',...
            ChildID,ChildAgeDays,ChildAgeMonth);
        %cast to tables
        An_NonInterveningStSizeTab = [An_NonInterveningStSizeTab; struct2table(NonInterveningStruct)];
        An_InterveningStSizeTab = [An_InterveningStSizeTab; struct2table(InterveningStruct)];
        An_NonStSizeTab = [An_NonStSizeTab; struct2table(NonStSizeStruct)];
    end

end

%append 2d and 3d distances as well as absolute duration step to the tables
%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats';
cd(destinationpath)

writetable(Chnsp_NonInterveningStSizeTab,'Chnsp_NonInterveningStSize_LenaLabel.csv')
writetable(Chnsp_InterveningStSizeTab,'Chnsp_InterveningStSize_LenaLabel.csv')
writetable(Chnsp_NonStSizeTab,'Chnsp_NonStSize_LenaLabel.csv')
writetable(An_NonInterveningStSizeTab,'An_NonInterveningStSize_LenaLabel.csv')
writetable(An_InterveningStSizeTab,'An_InterveningStSize_LenaLabel.csv')
writetable(An_NonStSizeTab,'An_NonStSize_LenaLabel.csv')


