clear all
clc

%Ritwika VPS, October 2022
%This script looks at whether there are correlations between transitions between CHNNSP and CHNSP vocs and
%time from the last vocalisation from the other speaker type, for day-long LENA data
%Here, the speaker labels are CHNSP, CHNNSP, MAN and FAN. So, our target
%speaker is CHN (picks out CHNSP and CHNNSP) and Other speaker is AN (picks
%out MAN and FAN) (see function GetCategoricalStepSizeVsTimeSinceLastResponse for details).
%Voc type CHNSP is assigned type1, while CHNNSP is type 0. 

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
Chn_NonInterveningCategoricalStSizeTab = array2table(zeros(0,6));
Chn_NonInterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

Chn_InterveningCategoricalStSizeTab = array2table(zeros(0,7));
Chn_InterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeToResponse','TimeFromResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

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

    %get vectors to input to fn
    StartTime = TableRead.start; EndTime = TableRead.xEnd;
    SpeakerLabels = TableRead.speaker;

    %get categorical step sizes
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'AN'))) %make sure there are OTHER type vocs
        [NonInterveningStruct,InterveningStruct] = GetCategoricalStepSizeVsTimeSinceLastResponse(StartTime,EndTime,SpeakerLabels,[],...
                                            SectionNumVec,'CHNSP',ChildID,ChildAgeDays,ChildAgeMonth); %AnnotationLabel input is empty, since there aren't
                                            %annotation labels like C, X, etc for LENA data
    
        %cast to tables
        Chn_NonInterveningCategoricalStSizeTab = [Chn_NonInterveningCategoricalStSizeTab; struct2table(NonInterveningStruct)];
        Chn_InterveningCategoricalStSizeTab = [Chn_InterveningCategoricalStSizeTab; struct2table(InterveningStruct)];
    end
end

%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats';
cd(destinationpath)

writetable(Chn_NonInterveningCategoricalStSizeTab,'Chn_NonInterveningCategoricalStSize_Lena.csv')
writetable(Chn_InterveningCategoricalStSizeTab,'Chn_InterveningCategoricalStSize_Lena.csv')


