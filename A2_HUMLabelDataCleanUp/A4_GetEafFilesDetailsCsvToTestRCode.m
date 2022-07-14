clear all
clc

%Ritwika VPS, JUne 2022
%code to get .csv files from .eaf files EXACTLY as from R code to verify
%that R code is working
%Also check and flag
    %(comparing adult utt dir and adult orthographic transcription tiers) - are there annoations in the ortho tier that are missing from the
            %utterance direction tier?
    %tier mismatch - eg. when adult orth annotations are in adult utterance dir tier and vice-versa
    %missing annotations (annotations are empty)
    %non-sensical annotations (eg. W, O, ~, etc.)

%get files form R to check 
EafDetailsFromR_path = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A3_ParsedEafFilesFromR_PreCleanUp/';

%go to R path and dir, and do the same for MATLAB
cd(EafDetailsFromR_path)
FilesFromR_dir = dir('*.csv');

%cd into file with .txt files written from .eaf files
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A1_EAFFiles'
aa = dir('*EAF.txt');

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

for i = 1:numel(aa)
    TierInfoTable = ParseEafFiles(aa(i).name,FilesFromR_dir);
    %Clumn names: StartTimeRef, StartTimeLineNum, EndTimeRef, EndTimeLineNum, AnnotId, AnnotIdLineNum, Annotation, AnnotationLineNum
    %TierTypeVec, StartTimeVal, EndTimeVal

    %%Looking  at mismatched or otherwise incorrect annotation---------------------------------------------------------------------------------------------------------
    %the function recursively fills out the predefined table with whichever
    %row form a file that has incorrect or mismatched annotation
    %we are only doing this for the infant voc type and adult utt direction
    %tiers
    T_TierMismatchOrIncorrectAnnot = GetMismatchedTierAndIncorrectAnnotations(TierInfoTable,T_TierMismatchOrIncorrectAnnot);

    %%The second layer of finding misisng annottaions: check if all annotations in adult utt dir tier are in orthographic tier and vice-versa--------------------------
    T_AnnotInOrthoTierButNotAdultUttDirTier = GetAnnotInOrthoButNotInUttDir(TierInfoTable,aa(i).name,T_AnnotInOrthoTierButNotAdultUttDirTier);

    for j = 1:numel(TierInfoTable.StartTimeVal)
        if TierInfoTable.StartTimeVal(j) > TierInfoTable.EndTimeVal(j)
            Tnew = TierInfoTable(j,:);
            T_StartTimeGreaterThanEndTime = [T_StartTimeGreaterThanEndTime; Tnew];
        end
    end
end

%save tables
writetable(T_AnnotInOrthoTierButNotAdultUttDirTier,'Summary_AnnotationsForVocsInOrthoTierButMissingInUttDirTier.csv')
writetable(T_TierMismatchOrIncorrectAnnot,'Summary_MissingAnnot_TierMismatch_IncorrectAnnot.csv')
writetable(T_StartTimeGreaterThanEndTime,'Summary_StartTimeGreaterThanEndTime.csv')

delete('*EAF.txt') %delete all eaf.txt files used by MATLAB