clear all
clc

%Ritwika VPS, July 2022

%This script joins together files that are from the same recording, and sorts data into sections; 
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';

destinationpath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A5_TimeSerieswSectionMatching/');

%go to folder with Acoustics data (overlaps processed fro acouistics and
%then vocs stitched back together + with annotation tags)
cd(strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A4_TSwAnnotationTags/'));

TSFiles = dir('*_TSwAnnotationsOlpStitched.csv');

opts = detectImportOptions(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv')); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
FnAgeInfantIdDetails = readtable(strcat(BasePath,'Data/LENAData/MergedTSAcousticsMetadata.csv'),opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%go through all hum label TS files and get file roots (without section numbers, a, b, etc.)
for i = 1:numel(TSFiles)
    NewName = strrep(TSFiles(i).name,'_TSwAnnotationsOlpStitched.csv','');
    FileNameRoot_Temp{i,1} = NewName(1:11); %get first 11 characters, because thsi is <4 character infant id>_<Age in YYMMDD>
end

%Now we pick out all the files with the same file root (a, b, etc, provide
%subrec info, so we will merge these)

%Get unique file name roots
U_FileNameRoot = unique(FileNameRoot_Temp); 

%get proprtynames of one of the TSfiles tables to make an empty table so as
%to vertically concatenate tables with the same file name root 
TabToReadVarNames = readtable('0009_000302_TSwAnnotationsOlpStitched.csv','Delimiter',',');
VarNamesForEmptyTab = TabToReadVarNames.Properties.VariableNames;

%go through unique filename roots and match root name to full file names
for i = 1:numel(U_FileNameRoot)

    %New file name
    NewFname = strcat(destinationpath,U_FileNameRoot{i},'_HumLabelsTS_w5minSectionsAndOlpInfo.csv');

    %initialise empty table with same coilumn names to concatenate tables
    %for the recordings from sdame infant on the same day
    T_new = array2table(zeros(0,numel(VarNamesForEmptyTab)),'VariableNames',VarNamesForEmptyTab);

    %counter to get name of files before stitching subrecs together + get number of entries in those tables. We will use this to
    %add a file name (before stitching subrecs together) column to the
    %final table
    PreSticthFnCtr = 0;
    PreStitchFn = {}; %initialise
    PreStitchFileNumRows = [];

    for j = 1:numel(TSFiles) %go through TS file names, and if filename root matches, stack
        if contains(TSFiles(j).name,U_FileNameRoot{i})
            T_new = [T_new; readtable(TSFiles(j).name,'Delimiter',',')];

            PreSticthFnCtr = PreSticthFnCtr + 1; %increment counter
            PreStitchFn{PreSticthFnCtr} = erase(TSFiles(j).name,'_TSwAnnotationsOlpStitched.csv'); %get file name
            PreStitchFileNumRows(PreSticthFnCtr) = size(readtable(TSFiles(j).name,'Delimiter',','),1); %get number of entries for the file
        end
    end

    %get vector to store file name info for all subrecs stitched into one
    %file. Adding this will be useful when we get matching sections from
    %LENA data so that we don't match sections between different subrecs of
    %the same daylong recording
    FnamePreSticthVec = cell(sum(PreStitchFileNumRows),1); %create cell array to store file names corresponding to each file stitched
    PreStitchFileNumelCumsum = [0 cumsum(PreStitchFileNumRows)]; %get vector with info about how many repeats of a file name should be there
    for j = 1:numel(PreStitchFileNumelCumsum)-1
        [FnamePreSticthVec{PreStitchFileNumelCumsum(j)+1:PreStitchFileNumelCumsum(j+1)}] = deal(PreStitchFn{j});
    end
    T_new.FileNameUnMerged = FnamePreSticthVec; %add column

    %add a new column specifiying which 5 minute section the voc belongs to
    %first check if data is sorted by start time
    if ~isequal(T_new.start,sort(T_new.start))
        T_new = sortrows(T_new,'start');
    end

    %intialise
    SecNumVec = zeros(size(T_new.start));
    SecNum = 1;
    SectionEndTime_Temp = T_new.xEnd(1); %assign the first end time. 
    
    for j = 1:numel(T_new.start) %go through start times (already sor
        if (T_new.start(j) - SectionEndTime_Temp)/60 > 5.1 %if difference in the end time of first voc in section and current start time time is more than 5.1 minutes (that gives a 
            %0.1 minute buffer to the start of the last vocalisation)
            SecNum = SecNum + 1; %increment section num
            SectionEndTime_Temp = T_new.xEnd(j);
        end
        SecNumVec(j,1) = SecNum;
    end

    T_new.SectionNum = SecNumVec; %add ot table
    writetable(T_new,NewFname); %write table to destination

                                    %Check # sections in the file
                                    %NumSectionsInHum(i) = numel(unique(T_new.SectionNum));
 
end

%------------------------------------------------------------------------------------------------------------------------------------------
%recordings with less thnan 3 sections:
% '0054_000902' (2 sections),'0054_010617' (2 section),'0099_000307' (1),'0099_000902' (1),'0130_000305' (1),'0196_000607' (1),
% '0225_000301' (1),'0425_000906' (2),'0517_000602' (1),'0644_000909' (1),'0667_000309' (1),'0776_000304' (2),'0776_000613' (2),
% '0932_000301' (2),'0938_010603' (2)
%------------------------------------------------------------------------------------------------------------------------------------------

%%%%%%%%%%%%%%
%The following (lines 89-134) was written to check if there are recorder pauses during
%sections. As of now, there aren't, so I am commenting this out. You can
%uncomment it if you want to check for yourself. THis will need to be
%adapted a but, but the idea remains the same

% %now check if any sections ahve pauses. First, go to directory w pause info and dir
% cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A3_PauseTimes')
% PauseDir = dir('*_PauseTimes.txt');
% 
% %go to directory with saved human listener annotataed files w section info
% cd(savepath)
% HumDir = dir('*_TSwSectionInfo.csv');
% 
% for i = 1:numel(HumDir)
%     for j = 1:numel(PauseDir)
% 
%         %find name matches
%         if contains(PauseDir(j).name,erase(HumDir(i).name,'_TSwSectionInfo.csv')) == 1
% 
%             %check if there are pauses in any section. To do this, first
%             %identify where the pauses are
%             PauseTab = readtable(PauseDir(j).name,'Delimiter','\t'); %delimter is tab
%             HumTab = readtable(HumDir(i).name,'Delimiter',',');
%             
%             if isempty(PauseTab) == 0 %if there ARE pauses
%                 
%                 %get times at which recorder was apused
%                 PauseEndTime = PauseTab.Var2; 
% 
%                 %get start and end time of sections - we can get this by getting the
%                 %uynique start and end times and remoing Nan from this list
%                 SecStart = unique(HumTab.SectionStartTime);
%                 SecStart = SecStart(~isnan(SecStart));
%                 SecEnd = unique(HumTab.SectionEndTime);
%                 SecEnd = SecEnd(~isnan(SecEnd));
% 
%                 for k = 1:numel(SecStart)
%                     for l = 1:numel(PauseEndTime)
%                         %check if there is a pause time between start and
%                         %end of a section
%                         if (PauseEndTime(l) > SecStart(k)) && (PauseEndTime(l) < SecEnd(k))
%                             i
%                         end
%                         %as it turns out, there aren't any pauses, so I am
%                         %not writing code to analyse that condition
%                     end
%                 end
%             end
%         end
%     end
% end

%0054_000902.eaf' has a section in the annotated file about 5 min long that is not in the coding sheet
    %and does not have a section that is in teh coding sheet
 %so I am
%                         %not writing code to analyse that condition
%                     end
%                 end
%             end
%         end
%     end
% end

%0054_000902.eaf' has a section in the annotated file about 5 min long that is not in the coding sheet
    %and does not have a section that is in teh coding sheet
