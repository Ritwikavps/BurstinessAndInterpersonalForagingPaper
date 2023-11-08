clear all
clc

%ritwika VPS, August 2022

%This script adds back annotations tags (T, U, N for adult vocs; R, X, C, L
%for infant vocs) to the csv files with time series and acoustics info
%It also stitches back vocalisations that were processed for overlap and
%chopped into non-overlapping pieces.
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';

OrigLabelsPath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A2_EafLabelsOlpsProcessed/EafLabelsPreOlpProcesswVocIndex/');
LabelsPath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A2_EafLabelsOlpsProcessed');
TSpath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A3_TimeSeries');
destinationpath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A4_TSwAnnotationTags/');

%go to labels path and dir
cd(LabelsPath)
LabelsFiles = dir('*_OlpProcessed.csv');

%go to TSPath and dir
cd(TSpath)
TSfiles = dir('*_TS.csv');

%go to path of labels pre-olp processing and dir (this is to stitch back
%vocs that were chopped up while processing overlaps)
cd(OrigLabelsPath)
OrigLabelsFiles = dir('*_wVocIndex.csv');

for i = 1:numel(TSfiles) %go through TSfiles, match to correpsonding label file, add annotation tags
 
    TSfnroot = erase(TSfiles(i).name,'_TS.csv'); %get file name root
    TStab = readtable(TSfiles(i).name,'Delimiter',','); %read in table

    for j = 1:numel(LabelsFiles) %go through label files and find match 
        if contains(LabelsFiles(j).name,TSfnroot) %match files

            LabelTab = readtable(LabelsFiles(j).name,'Delimiter',','); %read in table

            %check if start and end columns are equal
            if (isequal(TStab.start,LabelTab.StartTimeVal/1000)) && (isequal(TStab.xEnd,LabelTab.EndTimeVal/1000))

                %check to make sure that CHN vocs arent tagged T, U, or N,
                %and vice-versa for adult vocs
                CHN_TagCheck = contains(LabelTab.Annotation(contains(TStab.speaker,'CHN')),{'T','U','N'}); %returns logical 1 or 0 (yes or no)
                %for if any tags corresponding to CHN speaker contains anu
                %adult voc tags
                AN_TagCheck = contains(LabelTab.Annotation(contains(TStab.speaker,'AN')),{'R','X','L','C'}); %sim for AN tags
 
                if (sum([CHN_TagCheck; AN_TagCheck])) == 0 %if both of these checkes sum to 0, add annotation and VocIndex column to table

                    TStab.Annotation = LabelTab.Annotation;
                    TStab.VocIndex = LabelTab.VocIndex;
                else
                    [i j]
                end
            else
                [i j]
            end

        end
    end

    %Now, let's stitch chopped up vocs  back together. First, we will
    %match each voc to its voc index. Then, we will compare the vocs with
    %the same voc index to the vocalisation with the same voc index in the
    %original (pre-overlap processing) table with labels. Then, we will see
    %if the vocalisation has been completely removed by an overlap. If not,
    %we will compute the fraction of the vocalisation duration that is in
    %each chopped-up sub voc. To compute the pitch and amplitude of the
    %full, unchopped-up vocalisation, we will do a weighted average of the
    %sub-vocs whose pitch and amplitude we know.

    %make empty table to store new TS table and set variable names
    NewTStab = array2table(zeros(0,size(TStab,2)));
    NewTStab.Properties.VariableNames = TStab.Properties.VariableNames;
    
    for j = 1:numel(OrigLabelsFiles) %go through original label files and find match 
        if contains(OrigLabelsFiles(j).name,TSfnroot) %match files

            %read table
            OrigLabelTab = readtable(OrigLabelsFiles(j).name,'Delimiter',',');

            %Once file match found, go through each voc of teh original,
            %find corresponding voc(s) in TS
            for k = 1:numel(OrigLabelTab.VocIndex)

                SubTab = TStab(TStab.VocIndex == OrigLabelTab.VocIndex(k),:);

                if size(SubTab,1) == 1 %if there is only one voc

                    NewTStab = [NewTStab; SubTab]; %add to empty table

                   elseif size(SubTab,1) > 1%if there is more than one, get pitch, amplitude, start and end times for teh stitched up voc
                       %This check makes sure that we are excluding any
                       %vocs that are fully overlap

                                                        SubTab
                                                        OrigLabelTab(k,:),

                    %Get start and end times, pitch and amp for stitched back voc                                   
                    [StartTimeOut,EndTimeOut,PitchOut,dBOut] = StitchBackOlpProcessedVocs(OrigLabelTab(k,:),SubTab);
                    NewLine = SubTab(1,:); %Make line to add sticthed-back info to
                    NewLine.start = StartTimeOut; %change start time, end time, duration, meanf0, and dB to values obtained for stitched-back voc   
                    NewLine.xEnd = EndTimeOut;   
                    NewLine.duration = EndTimeOut-StartTimeOut;   
                    NewLine.meanf0 = PitchOut;   
                    NewLine.dB = dBOut;
                    NewTStab = [NewTStab; NewLine]; %add to empty table

                                                        NewLine
                                                        display('------------------------------------------------------------------------------------')

                end
            end
        end
    end

    %Make new table with VocIndex and FileName removed
    TabToSave = NewTStab(:,2:end-1);
    TabToSave = sortrows(TabToSave,'start');

    %save the new table
    writetable(TabToSave,strcat(destinationpath,TSfnroot,'_TSwAnnotationsOlpStitched.csv'))

end
