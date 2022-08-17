clear all
clc

%Ritwika VPS, UCLA
%July 2022

%This file checks which files can be analysed (i.e., list of files
%to exclude based on complex errors present) and copies non-excluded 
% files into teh working directory; then checks if there are overlapping vocalisations, splits
%overlapping vocs into non-overlapping sub-vocs where possible, and
%otherwise tags those vocs as overlapping so they are not used in acoustic
%analysis. 

%first, get list of files that need to be excluded
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles'

%read out tables with details of errors (E standing for error) (not adding
%summary spreadsheet for start time > end time because post clean up, that
%is empty)
E1 = readtable('PostCleanup_Summary_AnnotationsForVocsInOrthoTierButMissingInUttDirTier.csv');
E2 = readtable('PostCleanup_Summary_MissingAnnot_TierMismatch_IncorrectAnnot.csv');

%Add file which doesn't have coding spreadsheet counterpart to this liest,
%and pick out unique filenames
ExcludedFiles = unique([E1.EafFname; E2.EafFname; {'0193_010605a'}]);

%Copy files that can be used to folder with data to work with
CopyTo = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A1_EafLabels/';
CopyFrom = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A5_ParsedEafFilesFromR_PostCleanUp/';

%get path to write original tables with voc index (see below for details;
%but basically, we use the vocalisation index to stitch together vocs
%split into overlapping bits after we run acoustics)
SourceTabwVocIndexPath =...
    '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A2_EafLabelsOlpsProcessed/EafLabelsPreOlpProcesswVocIndex/';

%go to sopurce directory (CopyFrom)
cd(CopyFrom)

%dir all potential files to copy (this will be refined using ExcludedFiles
FilesToCopy = dir('*_Edited.csv');

%copy files that are ok to working directory
for i = 1:numel(FilesToCopy) %go through list of potential files to copy 
    if sum(contains(ExcludedFiles,erase(FilesToCopy(i).name,'_Edited.csv'))) == 0  %if filein question is not excluded
        if ~isfile(strcat(CopyTo,FilesToCopy(i).name)) %if file doesn't already exist in destination
            copyfile(FilesToCopy(i).name,CopyTo);
        else
            fprintf('File %s already exists in destination directory \n',FilesToCopy(i).name)
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now read in human listner labelled data and id and process overlaps
cd(CopyTo)
FilesToWork = dir('*_Edited.csv');

%File path to save files post processing for overlaps
OlpProcessPath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A2_EafLabelsOlpsProcessed/';

clc %just to clear the console for debugging

for i = 1:numel(FilesToWork) %go through the listof files to work on

    i

    EafTab = readtable(FilesToWork(i).name,'Delimiter',','); %read table
    FnameToSave = strcat(OlpProcessPath,erase(FilesToWork(i).name,'_Edited.csv'),'_OlpProcessed.csv'); %filename (and path) to save .csv files after 
    %processing overlaps

    %To identify vocs that are overlapping, we order adult utterance
    %direction and infant voc type annotations linearly (in increasing
    %order) by start time
    %Then we take each voc in sequence, check if there are other vocs that
    %start before the current voc ends. If yes, we flag the current voc as
    %well as the voc(s) that start before the current one ends and so on
    %and so forth. 
    %Then, we use recursively use a function that processes overlapping
    %vocs into non-overlapping chunks and flags overlapped portions (see
    %below and function used for details)

    %Get Inf Voc type and Adult Utt dir portion of the table
    InfVocTypeSubTable = EafTab(contains(EafTab.TierTypeVec,'Infant Voc Type','IgnoreCase',true),:);
    AnUttDirSubTable = EafTab(contains(EafTab.TierTypeVec,'Adult Utterance','IgnoreCase',true),:);
    
    %merge these subtables
    NewSubTable = [InfVocTypeSubTable; AnUttDirSubTable];
    
    %sort by starttime and get overlap flag vector
    StartTimeSortTable = sortrows(NewSubTable,'StartTimeVal');
    OverLapFlag = DetectOverlap(StartTimeSortTable);
    VocIndex = (1:numel(OverLapFlag))'; %get vector of voc indices. We'll use this to stitch vocs back together
    StartTimeSortTable.VocIndex = VocIndex; %this will help with reconstitutuing vocalisations 
    %DEBUGGING BIT: ss = StartTimeSortTable(OverLapFlag == 1,:); ss(:,[7,10,11]); Ctr = 0;

    %Write original table into folder EafLabelsPreOlpProcesswVocIndex to
    %compare and stitch back vocs after acoustics are run. 
    SourceTabName = strcat(SourceTabwVocIndexPath,erase(FilesToWork(i).name,'_Edited.csv'),'_wVocIndex.csv');
    writetable(StartTimeSortTable,SourceTabName);

    while sum(OverLapFlag) > 0  %as long as there are overlap flags

        %DEBUGGING BIT: display('----------------------------'); Ctr = Ctr + 1; size(StartTimeSortTable)
        %ss = StartTimeSortTable(OverLapFlag == 1,:); ss(:,[7,10,11]);
        [TableWithOverlapProcessed] = GetNonOverlapVocs(StartTimeSortTable,OverLapFlag); %get table with overlapping vocs flagged 
        % and/or chopped into overlapping and non-overlapping sub-vocs.
        % Note that this needs to be donoe recursively till we get to a
        % table with no overlaps (see function for details)
        OverLapFlag = DetectOverlap(TableWithOverlapProcessed); %detect overlap flag for new table
        
        for j = 1:numel(OverLapFlag) %if a voc in the new table is tagged as a full overlap, ignore its overlap flag = 1
            if strcmp(TableWithOverlapProcessed.Annotation{j},'OLP')
                OverLapFlag(j) = 0;
            end
        end

        %DEBUGGING BIT:setdiff(StartTimeSortTable,TableWithOverlapProcessed); size(TableWithOverlapProcessed)
        StartTimeSortTable = TableWithOverlapProcessed; %recast new table with the old table name so the while loop can continue

    end

    %Once we get a stable table, remove all overlapping vocs and resort
    Final_NoOlpTable= sortrows(StartTimeSortTable(~contains(StartTimeSortTable.Annotation,'OLP'),:),'StartTimeVal');
    writetable(Final_NoOlpTable,FnameToSave);

    

end