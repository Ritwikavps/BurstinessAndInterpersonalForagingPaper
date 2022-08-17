clear all
clc

%Ritwika VPS, August 12 2022
%This is a quick sanity checks script that:
%1. Files in the coding spreadsheet with sections that are less than 5
    %minites long or less than 30 minutes apart if at least one of those
    %sections have been annotated (and cleaned-up), per the times in the
    %coding spreadsheet
%3. Files that have been annotated and have more than 3 sections annotated.

%read in coding spreadsheet
opts = detectImportOptions('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/HumanListenerLabelsCodingRound3.csv');
opts.SelectedVariableNames = opts.SelectedVariableNames([1, 2, 3]); %only pick out filename, start and end times
CodingSpreadsheet = readtable('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/HumanListenerLabelsCodingRound3.csv',opts);

%read in csv file with info about eaf files, match old filenames to new filenames; 
opts = detectImportOptions('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv');
opts = setvartype(opts, 'InfantID', 'string');
EAFdetails = readtable('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv',opts);
OldFnVec = EAFdetails.EafFileNameOld;
NewFnVec = EAFdetails.EafFileNameNew;

%cd into folder with human listener labelled acoustics TS files (after
%stitching up subrecs, if any, of the same file)
cd('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/')
HumTSFiles = dir('*_ZscoredAcousticsTS_Hum.csv'); 

%go through HUM TS files and identify the files which have been annotated
Flag_TimeBwSections = 0;
for i = 1:numel(HumTSFiles)

    HumFnRoot = erase(HumTSFiles(i).name,'_ZscoredAcousticsTS_Hum.csv');
    OldFileName = OldFnVec(contains(NewFnVec,HumFnRoot)); %this could be multiple old filenames, becaue each subrec can be different
    opts_HumTS = detectImportOptions(HumTSFiles(i).name);
    opts_HumTS.SelectedVariableNames = {'SectionNum'};
    HumTS_SectionNum = readtable(HumTSFiles(i).name,opts_HumTS);

    %get all instances of matching filenames for old file name of interest
    %from coding spreadsheet, and get start and end times of sections (in
    %sec)
    CodingSubTable = array2table(zeros(0,size(CodingSpreadsheet,2))); %initialise and set variable names
    CodingSubTable.Properties.VariableNames = CodingSpreadsheet.Properties.VariableNames;
    for j = 1:numel(OldFileName)
        CodingSubTable = [CodingSubTable; CodingSpreadsheet(contains(CodingSpreadsheet.File,erase(OldFileName{j},'.eaf')),:)];
    end

    %get start and end times fro coding spreadsheet (in seconds)
    Spreadsheet_SectionStart = unique(seconds(CodingSubTable.StartTime),'stable');
    Spreadsheet_SectionEnd = unique(seconds(CodingSubTable.EndTime),'stable');
    %and make sure that the start time that doesn't get read in is assigned
    %manually
    for j = 1:numel(Spreadsheet_SectionEnd)
        if (Spreadsheet_SectionEnd(j) == 23371) && (strcmp(HumFnRoot,'0425_010611') == 1)
            Spreadsheet_SectionStart(j) = (6*3600) + (24*60) + 31;
        end
    end
    %Now sort
    [Spreadsheet_SectionStart,SpreadsheetSortI] = sort(Spreadsheet_SectionStart);
    Spreadsheet_SectionEnd = Spreadsheet_SectionEnd(SpreadsheetSortI);

    %Now flag any .eaf file whose sections in coding spreadsheet are less
    %than 30 minites apart
    if numel(Spreadsheet_SectionStart) > 1 %first check there is more than one section in the spreadsheet
        SpreadSheet_TimeBwSections = (Spreadsheet_SectionStart(2:end)-Spreadsheet_SectionEnd(1:end-1))/60; %convert to minutes
        if numel(SpreadSheet_TimeBwSections(SpreadSheet_TimeBwSections >= 30)) ~= numel(SpreadSheet_TimeBwSections) %check and flag files
            Flag_TimeBwSections = Flag_TimeBwSections + 1;
            Files_SectionIntervalFlag{Flag_TimeBwSections,1} = HumFnRoot;
            FlaggedSectionIntervals{Flag_TimeBwSections,1} = SpreadSheet_TimeBwSections;
            NumAnnotatedSections(Flag_TimeBwSections,1) = numel(unique(HumTS_SectionNum));
        end
    end
    
    %check if there are sections taht are not 5 minites lonh. All files
    %pass this check, so I haven't gone to the trouble of creating a cell
    %array to store the file names etc.
    if numel(Spreadsheet_SectionStart) >= 1
        SectionDuration = (Spreadsheet_SectionEnd-Spreadsheet_SectionStart)/60;
        if ~isempty(SectionDuration(SectionDuration ~= 5))
            HumFnRoot
        end
    end

    %finally, check if any file has more than 3 sectios
    if numel(unique(HumTS_SectionNum)) > 3
        HumFnRoot
    end

end
