clear all
clc

%ritwika VPS, August 2022; updated Dec 2023

%This script does the following:
    % -adds back annotations tags (T, U, N for adult vocs; R, X, C, L for infant vocs) to the csv files with time series and acoustics info
    % -recasts speaker labels as CHN and CHNNSP
    % -stitches back vocalisations that were processed for overlap and chopped into non-overlapping pieces.

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------  
%CHANGE PATHS AND STRINGS INSIDE FUNCTION CALL AS NECESSARY.
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_PostCleanUp';

LabelswVocIndPath = strcat(BasePath,'/A3_HlabelsOlpProcessed/');
TSpath = strcat(BasePath,'/A4_HlabelTS_OlpProcessed/');
destinationpath = strcat(BasePath,'/A5_HlabelTS_OlpStitched/');
VocStitchPath = strcat(BasePath,'/A2_HlabelCsvFiles/'); %this is the path with the unprocessed .csv files, so we can check all vocs have
% OLP processed and reconstituted correctly.

%go to directory that has labels w/ voc index and annotation tags, and dir
cd(LabelswVocIndPath); LabelswVocIndFiles = dir('*_OlpProc.csv');

%go to directory with time series and dir
cd(TSpath); TSfiles = dir('*_TSOlpProc.csv');
%---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

%first check that the number of TSfiles and the number of label files are the same, and then, that all TSfiles have a corresponding Label file and vice-vers
if numel(TSfiles) ~= numel(LabelswVocIndFiles)
    error('Different number of files in TS directory (A4_HlabelTS_OlpProcessed) and Label files directory (A3_HlabelsOlpProcessed)')
end

for i = 1:numel(TSfiles)
    TSFnrootVec{i,1} = erase(TSfiles(i).name,'_TSOlpProc.csv'); 
end

for i = 1:numel(LabelswVocIndFiles)
    LabelsFnrootVec{i,1} = erase(LabelswVocIndFiles(i).name,'_OlpProc.csv'); 
end

if ~isempty(setdiff(TSFnrootVec,LabelsFnrootVec))
    setdiff(TSFnrootVec,LabelsFnrootVec)
    error('There are TS files (A4_HlabelTS_OlpProcessed) that are not in the list of Label files (A3_HlabelsOlpProcessed); see above')
end

if ~isempty(setdiff(LabelsFnrootVec,TSFnrootVec))
    setdiff(LabelsFnrootVec,TSFnrootVec)
    error('There are Label files (A3_HlabelsOlpProcessed) that are not in the list of TS files (A4_HlabelTS_OlpProcessed); see above')
end

%proceed once the above checks are passed!!

for i = 1:numel(TSFnrootVec) %go through TSfiles, match to correpsonding label file, add annotation tags
 
    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
    LabelsFname = strcat(LabelswVocIndPath,TSFnrootVec{i},'_OlpProc.csv'); %get labels and TS filenames; CHANGE STRINGS INSIDE FUNCTION CALL AS NECESSARY.
    TSFname = strcat(TSpath,TSFnrootVec{i},'_TSOlpProc.csv');
    %---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

    if ~isfile(LabelsFname) %error checks (redundant but better safe than sorry :) Also, this way, we are sure that the filenames match
        disp(strcat('Labels file corresponding to fnroot ',TSFnrootVec{i},' does not exist.'))
    end

    if ~isfile(TSFname)
        disp(strcat('TS file corresponding to fnroot ',TSFnrootVec{i},' does not exist.'))
    end

    TStab = readtable(TSFname,'Delimiter',','); %read in tables
    LabelsTab = readtable(LabelsFname,'Delimiter',',');

    %check that TS and Labels tables have the same number of rows
    if size(TStab,1) ~= size(LabelsTab,1)
        disp(strcat('Number of rows for TS and Labels files for ',TSFnrootVec{i},' do not match'))
    end

    %check if start and end columns are equal for TS and Labels tables
    if (isequal(TStab.start,LabelsTab.StartTimeVal/1000)) && (isequal(TStab.xEnd,LabelsTab.EndTimeVal/1000))

        %check to make sure that CHN vocs arent tagged T, U, or N, and vice-versa for adult vocs
        CHN_TagCheck = contains(LabelsTab.Annotation(contains(TStab.speaker,'CHN')),{'T','U','N'}); %returns logical 1 or 0 (yes or no)
        %for all annotation tags corresponding to CHN speaker that contains annotation tags that should be for AN
        AN_TagCheck = contains(LabelsTab.Annotation(contains(TStab.speaker,'AN')),{'R','X','L','C'}); %sim for AN tags
        OLP_TagCheck = isequal(LabelsTab.Annotation(contains(LabelsTab.Annotation,'OLP')),TStab.speaker(contains(TStab.speaker,'OLP'))); %checks that the vectors of all OLP tags
        %are the same for TS and Labels tables

        if ((sum([CHN_TagCheck; AN_TagCheck])) == 0) && (OLP_TagCheck == 1) %if both of these checkes sum to 0 AND if the OLP tag check checks out,
            % add annotation and VocIndex column to table
            TStab.Annotation = LabelsTab.Annotation;
            TStab.VocIndex = LabelsTab.VocIndex;
        else
            disp(strcat('Tag checks for CHN, AN and/or OLP speaker labels for ',TSFnrootVec{i},' return error.'))
        end
    else
        disp(strcat('Vectors of start and end times for TS and Labels files for ',TSFnrootVec{i},' do not match'))
    end

    %Now, let's stitch chopped up vocs back together. First, we will match each voc to its voc index. Then, we will compare the vocs with
    %the same voc index to the vocalisation with the same voc index in the original (pre-overlap processing) table with labels. Then, we will see
    %if the vocalisation has been completely removed by an overlap. If not,
    %we will compute the fraction of the vocalisation duration that is in
    %each chopped-up sub voc. To compute the pitch and amplitude of the
    %full, unchopped-up vocalisation, we will do a weighted average of the
    %sub-vocs whose pitch and amplitude we know.

    %make empty table to store new TS table and set variable names
    NewTStab = array2table(zeros(0,size(TStab,2))); NewTStab.Properties.VariableNames = TStab.Properties.VariableNames;
    
    %get unique Voc Indices
    U_VocInd = unique(TStab.VocIndex);

    for j = 1:numel(U_VocInd) %go through list of unique voc indices
        SubTab = TStab(TStab.VocIndex == U_VocInd(j),:); %get sub-table for each voc index
    
        if size(SubTab,1) == 1 %if there is only one voc with a given voc index, then we don't to reconstitute any vocs
            NewTStab = [NewTStab; SubTab]; %add to empty table
        elseif size(SubTab,1) > 1 %if there is more than one voc with the same voc index, get pitch, amplitude, start and end times for teh stitched up voc
            NewLine = StitchBackOlpProcessedVocs(SubTab);
            NewTStab = [NewTStab; NewLine]; %add new line to empty table
        end
    end

    NewTStab = sortrows(NewTStab,'start'); %sort by start time

    %final checks: 1. check that there are no two vocs with the same voc-index
    if numel(NewTStab.VocIndex) ~= numel(unique(NewTStab.VocIndex))
        error('More than one voc with the same voc index after stitching vocs back together.')
    end
    %2. Check to make sure that the start and end times of unprocessed vocs are the same as post-OLP processing and stitcthing back together.
    StitchCheckTab = readtable(strcat(VocStitchPath,TSFnrootVec{i},'_EditedMay2023.csv'),'Delimiter',','); %read initial csv table (parsed from eaf)
    StitchCheckTab = StitchCheckTab(contains(StitchCheckTab.TierTypeVec,{'Infant Voc Type','Adult Utterance Direction'}),:); %get Inf Voc and Adult utt dir tiers ONLY
    StitchCheckTab = sortrows(StitchCheckTab,'StartTimeVal'); %sort table by start time
    if ~isequal(StitchCheckTab.StartTimeVal/1000,NewTStab.start) || ~isequal(StitchCheckTab.EndTimeVal/1000,NewTStab.xEnd)
        error(sprintf('Unprocessed start and or end time vectors do not match processed ones for %s',TSFnrootVec{i}))
    end
%     %3. Check that duration has been computed correctly; NOTE that this is a sanity check bit that I have looked at the output for.
%     FracDurErr = (NewTStab.duration-(NewTStab.xEnd-NewTStab.start))./NewTStab.duration;
%     if ~isempty(FracDurErr(FracDurErr > 0.001))
%         TSFnrootVec{i}
%         FracDurErr(FracDurErr > 0.001)
%     end

    %Make new table with VocIndex and FileName removed
    TabToSave = NewTStab(:,2:end-1);
    TabToSave.speaker(contains(TabToSave.Annotation,{'L','R'}) & contains(TabToSave.speaker,'CHN')) = {'CHNNSP'}; %recast CHN speaker labels as CHNSP and CHNNSP
    TabToSave.speaker(contains(TabToSave.Annotation,{'X','C'}) & contains(TabToSave.speaker,'CHN')) = {'CHNSP'};
    TabToSave = TabToSave(~contains(TabToSave.speaker,'OLP'),:); %remove OLPs
    if ~isempty(TabToSave.Annotation(contains(unique(TabToSave.Annotation),'OLP'))) || ~isempty(TabToSave.speaker(contains(unique(TabToSave.speaker),'OLP')))
        error('Not all OLP labels removed')
    end

    writetable(TabToSave,strcat(destinationpath,TSFnrootVec{i},'_TS_OlpStitched.csv')) %save the new table
end
