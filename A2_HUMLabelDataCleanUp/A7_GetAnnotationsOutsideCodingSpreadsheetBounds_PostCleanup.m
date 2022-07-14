clear all
clc

%Ritwika VPS
%June 2022
%This script outputs a csv file for each eaf file that identifies
%annotations that are outside of the spreadsheet bounds, On .csv files
%generated after cleaning up .eaf files

%read coding spreadsheet info file
opts = detectImportOptions('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/HumanListenerLabelsCodingRound3.csv');
opts.SelectedVariableNames = opts.SelectedVariableNames([1, 2, 3]); %only pick out filename, start and end times
CodingSpreadsheet = readtable('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/HumanListenerLabelsCodingRound3.csv',opts);

%now read in csv file with info about eaf files, match old filenames to new
%filenames; 
opts = detectImportOptions('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv');
opts = setvartype(opts, 'InfantID', 'string');
EAFdetails = readtable('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv',opts);
OldFn = EAFdetails.EafFileNameOld;
NewFn = EAFdetails.EafFileNameNew;

%cd to folder with annotation details .csv files (from R)
AnnotationCsvPath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A5_ParsedEafFilesFromR_PostCleanUp/';
cd(AnnotationCsvPath)

CsvDir = dir('*_Edited.csv');

T_Final = array2table(zeros(0,12));
T_Final.Properties.VariableNames = {'StartTimeRef','StartTimeLineNum','EndTimeRef','EndTimeLineNum','AnnotId',...
                    'AnnotIdLineNum','Annotation','AnnotationLineNum','TierTypeVec','StartTimeVal','EndTimeVal','EafFname'};

fileID = fopen('EafCodingSpreadsheetMissingFilesSummary.txt','w'); %creates new file to write to; 'w' indicates this

for i = 1:numel(CsvDir)
    %get file name
    CsvFnRoot = erase(CsvDir(i).name,'_Edited.csv');

    %find matching old filename from EAFdetails spreadsheet (OldFn, NewFn)
    %+ remove .eaf extension (to match with FnRoot in coding spreadsheet                               
    CorrespOldFnRoot = erase(OldFn{contains(NewFn,CsvFnRoot)},'.eaf'); %

    CorrespCodingSpreadSheet = CodingSpreadsheet(contains(CodingSpreadsheet.File,CorrespOldFnRoot),:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Error checkl block
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Checking to make sure that everything is read in correctly, whether
    %there are .eaf files without a corresponding spreadsheet entry and
    %vice-versa, etc
    if isempty(CorrespCodingSpreadSheet)
        fprintf(fileID,'No coding spreadsheet entry for this file for %s \n',CsvFnRoot);
                                    %DEBUGGING
                                    %         {strcat('i = ',num2str(i)),CsvFnRoot,CorrespOldFnRoot}
                                    %         CorrespCodingSpreadSheet
    else
        CodingSpreadsheetStartTime = seconds(CorrespCodingSpreadSheet.StartTime);
        CodingSpreadsheetEndTime = seconds(CorrespCodingSpreadSheet.EndTime);

        %There is one entry in the coding spreadsheet whose StartTime isnt
        %read in correctly, so we manually input it
        for j = 1:numel(CodingSpreadsheetStartTime) 
            if isnan(CodingSpreadsheetStartTime(j)) || isnan(CodingSpreadsheetEndTime(j))
                if (CodingSpreadsheetEndTime(j) == 23371) && (strcmp(CsvFnRoot,'0425_010611') == 1)
                    CodingSpreadsheetStartTime(j) = (6*3600) + (24*60) + 31; %This start time dooesn't get read in, for some reason, so I am manually inputting this
                                    %DEBUGGING
                                    % strcat('i = ',num2str(i)),'; FnRoot is ',CsvFnRoot)
                end
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    AnnotTable = readtable(CsvDir(i).name,'Delimiter',','); %read csv file with annotation details 
    IndexVec = (1:numel(AnnotTable.StartTimeVal))'; %vector of indices; transpose for column vector
    SegmentNum = zeros(size(IndexVec)); %vector to store the segment number for each 5 minute seg
    %Note that .eaf files have time in milliseconds. So, time in .eaf
    %file/1000 =  time in coding spreadsheet
    %Key table columns: StartTimeVal, EndTimeVal, StartTimeLineNum, EndTimeLineNum, AnnotationLineNum 
    %We will check which annotations fall in each segment. Then, we
    %identify annotations that fall outside of segments and store those in
    %a constantly updated table
    if ~isempty(CodingSpreadsheetStartTime) && ~isempty(CodingSpreadsheetEndTime) %if both have entries
        for j = 1:numel(CodingSpreadsheetStartTime)
            %pick out vocs within a section's start and end time limits and
            %assign section number, for each pair of start and end time. 
            %And assign 1 to all annoattions from each segment
            %We use the rather generous condition
            %that the first voc can start outside of the coding sheet start
            %time, as long as part of the voc is wihthin the coding sheet
            %section start and end times; and that the last voc can end
            %outside of the coding sheet end time, as long as it starts
            %before the coding sheet end time
            Indices = IndexVec((AnnotTable.EndTimeVal/1000 >= CodingSpreadsheetStartTime(j)) & (AnnotTable.StartTimeVal/1000 <= CodingSpreadsheetEndTime(j)));
            SegmentNum(Indices) = 1;
        end
    end

    if sum(SegmentNum) == 0 %if there are no annotations in the eaf file that fall within segment bounds
        fprintf(fileID,'All annotations outside of coding spreadsheet bounds %s \n',CsvFnRoot);
    end


    OutsideSegmentBounds = AnnotTable(~SegmentNum,:); %every row corresponding to annotations that don't fall in the bounds is extracted
    FileNameVec = cell(size(OutsideSegmentBounds.EndTimeVal)); %add file name column
    [FileNameVec{:}] = deal(CsvFnRoot);
    OutsideSegmentBounds.EafFname = FileNameVec; %append to table

    T_Final = [T_Final; OutsideSegmentBounds]; %append table with details about out-of-bounds annotations to larger table

end

writetable(T_Final,'AnnotationsOutsideCodingSpreadsheetBounds.csv')

%finally check if there are cases when there are no eaf files corresponding
%to coding spreadsheet sections
uCodingSpreadsheet_FnVec = unique(CodingSpreadsheet.File); %get unique file names from coding spreadsheet
for i = 1:numel(uCodingSpreadsheet_FnVec) %go through unique filenames

    CodingSpreadsheet_Fn = uCodingSpreadsheet_FnVec{i};

    if sum(contains(OldFn,CodingSpreadsheet_Fn)) == 0 %check if there is an eaf file corresponding to the unique filename 
        %in coding spreadsheet. File names in coding spreadsheet are the
        %non-HOmebank names, so we crossref with OldFn. Check if there are
        %matching OldFn values. If not, an eaf file does not exist. 
        fprintf(fileID,'There is no .eaf file corresponding to coding spreadsheet entries for file %s \n',CodingSpreadsheet_Fn);
    end

end

%As it turns out, there are 61 files in the coding spreadsheet without a
%corresponding eaf file, and one eaf file without corresponding coding
%spreadsheet entry. 

