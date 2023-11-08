clear all
clc

%Ritwika VPS, JUne 2022
%code to check and flag
    %(comparing adult utt dir and adult orthographic transcription tiers) - are there annoations in the ortho tier that are missing from the
            %utterance direction tier?
    %tier mismatch - eg. when adult orth annotations are in adult utterance dir tier and vice-versa
    %missing annotations (annotations are empty)
    %non-sensical annotations (eg. W, O, ~, etc.)
    %annotations outside coding sporeadsheet bds

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHNAGE PATH(S) ACCORDINGLY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/';%This is the base path to the google drive folder that may undergo change
%read coding spreadsheet info file
CodingSpreadsheet = readtable(strcat(BasePath,'A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/FNSTETSimplified.csv'));
CleanUpStatus = 'PostCleanUp'; %CHANGE TO 'PostCleanUp' ACCORDINGLY
if strcmpi(CleanUpStatus,'PreCleanUp')
    EafDetailsFromR_path = strcat(BasePath,'A1_HUMLabelData_CleanupPipeline/A2_ParsedEafFilesFromR_PreCleanUp/'); 
elseif strcmpi(CleanUpStatus,'PostCleanUp')
    EafDetailsFromR_path = strcat(BasePath,'A1_HUMLabelData_CleanupPipeline/A4_ParsedEafFilesFromR_PostCleanUp/'); 
end
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------

cd(EafDetailsFromR_path)
FilesFromR_dir = dir('*.csv'); %get list of files

%create empaty table to populate with mismatched or missing/incorrect annotations
T_TierMismatchOrIncorrectAnnot = array2table(zeros(0,12));
T_TierMismatchOrIncorrectAnnot.Properties.VariableNames = {'StartTimeRef','StartTimeLineNum','EndTimeRef','EndTimeLineNum','AnnotId',...
                    'AnnotIdLineNum','Annotation','AnnotationLineNum','TierTypeVec','StartTimeVal','EndTimeVal','EafFname'};

%create empaty table to populate with annotations that are not present in orthographic tier but not utterance dir tier
T_AnnotInOrthoTierButNotAdultUttDirTier = array2table(zeros(0,12));
T_AnnotInOrthoTierButNotAdultUttDirTier.Properties.VariableNames = {'StartTimeRef','StartTimeLineNum','EndTimeRef','EndTimeLineNum','AnnotId',...
                    'AnnotIdLineNum','Annotation','AnnotationLineNum','TierTypeVec','StartTimeVal','EndTimeVal','EafFname'};

%finally, empty table to store start time greater than end time instances
T_StartTimeGreaterThanEndTime = array2table(zeros(0,12));
T_StartTimeGreaterThanEndTime.Properties.VariableNames = {'StartTimeRef','StartTimeLineNum','EndTimeRef','EndTimeLineNum','AnnotId',...
    'AnnotIdLineNum','Annotation','AnnotationLineNum','TierTypeVec','StartTimeVal','EndTimeVal','EafFname'};

for i = 1:numel(FilesFromR_dir)
    TierInfoTable = readtable(FilesFromR_dir(i).name,'Delimiter',','); %Clumn names: StartTimeRef, StartTimeLineNum, EndTimeRef, EndTimeLineNum, AnnotId, AnnotIdLineNum, Annotation, AnnotationLineNum
    %TierTypeVec, StartTimeVal, EndTimeVal, 

    %add column with file name to table
    EafFnRoot = erase(FilesFromR_dir(i).name,'.csv'); %get file name root
    FileNameVec = cell(size(TierInfoTable.StartTimeRef));
    [FileNameVec{:}] = deal(EafFnRoot);
    TierInfoTable.EafFname = FileNameVec;

    %%Looking  at mismatched or otherwise incorrect annotation---------------------------------------------------------------------------------------------------------
    %the function recursively fills out the predefined table with whichever row form a file that has incorrect or mismatched annotation
    %we are only doing this for the infant voc type and adult utt direction tiers
    T_TierMismatchOrIncorrectAnnot = GetMismatchedTierAndIncorrectAnnotations(TierInfoTable,T_TierMismatchOrIncorrectAnnot);

    %%The second layer of finding misisng annottaions: check if all annotations in adult utt dir tier are in orthographic tier and vice-versa--------------------------
    T_AnnotInOrthoTierButNotAdultUttDirTier = GetAnnotInOrthoButNotInUttDir(TierInfoTable,FilesFromR_dir(i).name,T_AnnotInOrthoTierButNotAdultUttDirTier);

    for j = 1:numel(TierInfoTable.StartTimeVal)
        if TierInfoTable.StartTimeVal(j) > TierInfoTable.EndTimeVal(j)
            Tnew = TierInfoTable(j,:);
            T_StartTimeGreaterThanEndTime = [T_StartTimeGreaterThanEndTime; Tnew];
        end
    end
end

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHNAGE PATH(S) ACCORDINGLY
cd(strcat(BasePath,'A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/')) %go to destination
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------

fileID = fopen(strcat(CleanUpStatus,'EafCodingSpreadsheetMissingFilesSummary.txt'),'w'); %creates new file to write to; 'w' indicates this
T_AnnotOutsideCodingSheetBds = GetAnnotOutsideCodingSheetBds(CodingSpreadsheet,FilesFromR_dir,fileID,'.csv'); %gte summary table with info about annots outside codingsheet bds
fclose(fileID);
T_RogueInfAdultAnnots = GetRogueInfOrAdultAnnotsInOtherTiers(FilesFromR_dir,'.csv');

%save tables
writetable(T_AnnotInOrthoTierButNotAdultUttDirTier,strcat(CleanUpStatus,'Summary_AnnotsForVocsInOrthoButMissingInUttDir.csv'))
writetable(T_TierMismatchOrIncorrectAnnot,strcat(CleanUpStatus,'Summary_MissingAnnot_TierMismatch_IncorrectAnnot.csv'))
writetable(T_StartTimeGreaterThanEndTime,strcat(CleanUpStatus,'Summary_StartTGreaterThanEndT.csv'))
writetable(T_AnnotOutsideCodingSheetBds,strcat(CleanUpStatus,'AnnotsOutsideCodingSheetBds.csv'))
writetable(T_RogueInfAdultAnnots,strcat(CleanUpStatus,'Summary_RogueInfAdultAnnotsInOtherTiers.csv'))