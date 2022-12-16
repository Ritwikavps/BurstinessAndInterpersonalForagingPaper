clear all
clc

%Ritwika VPS, August 2022
%This script looks at whether there are correlations between transitions between CHNNSP and CHNSP vocs and
%time from the last vocalisation from the other speaker type, for 5 min
%LENA data, corresponding to human labelled 5 min segments. 
%Here, the speaker labels are CHNSP, CHNNSP, MAN and FAN. So, our target
%speaker is CHN (picks out CHNSP and CHNNSP) and Other speaker is AN (picks
%out MAN and FAN) (see function GetCategoricalStepSizeVsTimeSinceLastResponse for details).
%Voc type CHNSP is assigned type1, while CHNNSP is type 0. 

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
Chn_NonInterveningCategoricalStSizeTab = array2table(zeros(0,6));
Chn_NonInterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

Chn_InterveningCategoricalStSizeTab = array2table(zeros(0,7));
Chn_InterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeToResponse','TimeFromResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

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
    StartTime = TableRead.start; EndTime = TableRead.xEnd;
    SpeakerLabels = TableRead.speaker;
    SectionNumVec = TableRead.SectionNum;

    %get categorical step sizes
    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'AN'))) %make sure there are OTHER type vocs
        [NonInterveningStruct,InterveningStruct] = GetCategoricalStepSizeVsTimeSinceLastResponse(StartTime,EndTime,SpeakerLabels,[],...
                                            SectionNumVec,'CHNSP',ChildID,ChildAgeDays,ChildAgeMonths); %AnnotationLabel input is empty, since there aren't
                                            %annotation labels like C, X, etc for LENA data
    
        %cast to tables
        Chn_NonInterveningCategoricalStSizeTab = [Chn_NonInterveningCategoricalStSizeTab; struct2table(NonInterveningStruct)];
        Chn_InterveningCategoricalStSizeTab = [Chn_InterveningCategoricalStSizeTab; struct2table(InterveningStruct)];
    end
end

%append 2d and 3d distances as well as absolute duration step to the tables
%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats';
cd(destinationpath)

writetable(Chn_NonInterveningCategoricalStSizeTab,'Chn_NonInterveningCategoricalStSize_Matched5minLena.csv')
writetable(Chn_InterveningCategoricalStSizeTab,'Chn_InterveningCategoricalStSize_Matched5minLena.csv')


