clear all
clc

%Ritwika VPS, October 2022
%This script looks at whether there are correlations between transitions between (X,C) type infant vocs and (R,L) type infant vocs, and
%time from the last vocalisation from the other speaker type, for human-listener labelled data. 
% While we cna specify what combo of adult annotation types (T,U,N) and
% child annotation types (R,X,L,C) are used here, the most meaningful ones
% are arguably:
%i) Child X,C as the categories with adult T,U,N as Other speaker type.
%This lets us look at how time since last response affects transitions
%between X and C types. While we can specfiically look at adult T 9towards
%child) vocs only, this would mean using an even smaller subset of data +
%there is no direct comparison we can make to LENA
%ii) Child (X,C) vs child (R,L) as the child categories with adult T,U,N as
%Other speaker typem which provides an opportunity to directly compare with
%LENA.
%In this script, we stick to case ii) and execute case i) in its own file. 

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
Chn_NonInterveningCategoricalStSizeTab = array2table(zeros(0,6));
Chn_NonInterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeSinceLastResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

Chn_InterveningCategoricalStSizeTab = array2table(zeros(0,7));
Chn_InterveningCategoricalStSizeTab.Properties.VariableNames = {'TimeToResponse','TimeFromResponse','CategoricalStep','IntervocInt','ChildID','ChildAgeDays','ChildAgeMonths'};

%go through files
for i = 1:numel(ZscoreFiles)

    %get child id, age (month and days): fill in if needed for st
    ChildID = DataDetails.InfantID(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));
    ChildAgeMonths = DataDetails.InfantAgeMonth(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));
    ChildAgeDays = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(ZscoreFiles(i).name,'_ZscoredAcousticsTS_Hum.csv')));

    %get step sizes
    TableRead = readtable(ZscoreFiles(i).name,'Delimiter',',');
    %No need to specifically pick out any voc types. All voc types and all
    %annotation types for those voc types in the human labels are used
    StartTime = TableRead.start; EndTime = TableRead.xEnd;
    SpeakerLabels = TableRead.speaker;
    SectionNumVec = TableRead.SectionNum;
    AnnotationLabel = TableRead.Annotation;

    if ~isempty(SpeakerLabels(contains(SpeakerLabels,'AN'))) %make sure there are OTHER type vocs
        [NonInterveningStruct,InterveningStruct] = GetCategoricalStepSizeVsTimeSinceLastResponse(StartTime,EndTime,SpeakerLabels,AnnotationLabel,...
                                            SectionNumVec,{'C','X'},ChildID,ChildAgeDays,ChildAgeMonths); 
    
        %cast to tables
        Chn_NonInterveningCategoricalStSizeTab = [Chn_NonInterveningCategoricalStSizeTab; struct2table(NonInterveningStruct)];
        Chn_InterveningCategoricalStSizeTab = [Chn_InterveningCategoricalStSizeTab; struct2table(InterveningStruct)];
    end
end

%save tables
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats';
cd(destinationpath)

writetable(Chn_NonInterveningCategoricalStSizeTab,'ChnspVsChnnsp_NonInterveningCategoricalStSize_HumLabel.csv')
writetable(Chn_InterveningCategoricalStSizeTab,'ChnspVsChnnsp_InterveningCategoricalStSize_HumLabel.csv')


