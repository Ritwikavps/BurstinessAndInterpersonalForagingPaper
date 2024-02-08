clear all
clc

%Ritwika VPS, UCLA; July 2022

%Updated June 2023, post the clean-up effort by Ritwika and Jeffrey in May 2023
% Prior to this clean-up effort, there were files which contained errors (see relevnt directory; A2_HUMLabelDataCleanUp), so it was necessary to exclude those files, 
% and so, this script contained some code to do that. Post- the May 2023 clean-up effort, this is no longer necessary, and  have removed those portions of code, and 
% am leaving this note here to sort of point to the fact that extensive data cleanup has been performed, and also, in case the need to add similar portions of code 
% ever arises. 

% As of now, this script checks if there are overlapping vocalisations, splits overlapping vocs into non-overlapping sub-vocs where possible, and
% otherwise tags those vocs as overlapping so they are not used in acoustic analysis

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
%set BasePath and working directory; CHNAGE PATH AS NECESSARY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_PostCleanUp/';
WorkingDir = strcat(BasePath,'A2_HlabelCsvFiles/');
cd(WorkingDir)
FilesToWork = dir('*_Edited*.csv'); %Now read in human listner labelled data and id and process overlaps
DestinationPath = strcat(BasePath,'A3_HlabelsOlpProcessed/'); %File path to save files post processing for overlaps
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------

%The basic idea is to pick out all CHN and AN vocs, sort them by start time into a single table, index each voc with an sequential index (1, 2, 3....), identify
% and flag overlapping vocs (see below; utilises user-defined function), and chop up all overlapping vocs into overlapping and non-overlapping sub-vocs while
% also storing the info about the voc index of the original un-chopped up vocalisation. So, if Voc 3 is chopped up into 3 sub-vocs, they will all have the voc
% index 3. Note that this chopping up of overlapping vocs is done recursively (see below; utilises user-defined function). We will later use this voc index info 
% to stitch back vocs together after acoustic processing.

for i = 1:numel(FilesToWork) %go through the listof files to work on

    i

    HlabelTab = readtable(FilesToWork(i).name,'Delimiter',','); %read table
    %----------------------------------------------------------------------------------------------------------------------------------------------------------------------
    FnameToSave = strcat(DestinationPath,regexprep(FilesToWork(i).name,'_Edited.*csv',''),'_OlpProc.csv'); %filename (and path) to save .csv files after 
    %processing overlaps; %CHANGE STRINGS INSIDE FUNCTION CALL TO MATCH ANY CHANGES IN FILENAMING CONVENTIONS
    %----------------------------------------------------------------------------------------------------------------------------------------------------------------------

    %Get Inf Voc type and Adult Utt dir portion of the table to generate relevant voc data table
    NewSubTable = HlabelTab(contains(HlabelTab.TierTypeVec,{'Infant Voc Type','Adult Utterance'},'IgnoreCase',true),:);
    
    StartTimeSortTable = sortrows(NewSubTable,'StartTimeVal'); %sort by start time 
    OlpFlag = DetectOverlap(StartTimeSortTable); %get overlap flag vector (see function DetectOverlap for details)
    VocIndex = (1:numel(OlpFlag))'; %get vector of voc indices. We'll use this to stitch vocs back together
    StartTimeSortTable.VocIndex = VocIndex; %Add voc index info to table
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %DEBUGGING BIT: ss = StartTimeSortTable(OverLapFlag == 1,:); ss(:,[7,10,11]); Ctr = 0; This basically picks out the annotation,
    %start and end times for vocs flagges as overlapping, so we can do a visual check
    %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    while sum(OlpFlag) > 0  %as long as there are overlap flags
        %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        %DEBUGGING BIT: display('----------------------------'); Ctr = Ctr + 1; size(StartTimeSortTable)
        %ss = StartTimeSortTable(OverLapFlag == 1,:); ss(:,[7,10,11]);
        %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        [TableWithOverlapProcessed] = GetNonOverlapVocs(StartTimeSortTable,OlpFlag); %get table with overlapping vocs flagged and/or chopped into overlapping and 
        % non-overlapping sub-vocs. Note that this needs to be donoe recursively till we get to a table with no overlaps (see function for details)
        OlpFlag = DetectOverlap(TableWithOverlapProcessed); %detect overlap flag for new table
        
        for j = 1:numel(OlpFlag) %if a voc in the new table is tagged as a full overlap, ignore its overlap flag = 1
            if strcmpi(TableWithOverlapProcessed.Annotation{j},'OLP')
                OlpFlag(j) = 0;
            end
        end

        %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        %DEBUGGING BIT:setdiff(StartTimeSortTable,TableWithOverlapProcessed); size(TableWithOverlapProcessed)
        %--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        StartTimeSortTable = TableWithOverlapProcessed; %recast new table with the old table name so the while loop can continue
    end

    %Once we get a stable table, resort
    FinalTab = sortrows(StartTimeSortTable,'StartTimeVal');
    writetable(FinalTab,FnameToSave);
end