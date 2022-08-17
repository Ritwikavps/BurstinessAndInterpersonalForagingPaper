clear all
clc

%Ritwika VPS
%April 2022

%code to get corresponding 5 minute sections from LENA data for annotated 5 minute sections per coding spreadsheet 

%Steps:
%- match file name (human labelled data, subrecs merged) to old file name, get all
    %corresponding coding spreadsheet entries (even for subrecs. Note that subrecs are parts of a whole day recording separated due to recorder pauses or deletions)
%-get start and end times for each 5 min section (hereafter called section) per human listener annotation
%-get start and end times for each section per coding spreadsheet
%-pick out sections that HAVE been annotated and match sections between
    %human labelled data and coding spreadsheet info
%-pick out corresponding start and end times from LENA data (with the
    %boundary straddling a voc being ok)
%-Read corresponding LENA tables and Get corresponding LENA data with
    %section info etc.
%-save new table 

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
%dir all TS files (note that these are files after we join subrecs from the same infant on the same day but are in different files due to pauses, etc.)
%Also note that the coding spreadsheet has subrecs separately. 

%path to save files
savepath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData/';
%path to LENA tables
LENAPath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA/';

for i = 1:numel(HumTSFiles)

    %first, get file name root and match to old file name
    HumFnRoot = erase(HumTSFiles(i).name,'_ZscoredAcousticsTS_Hum.csv'); 
    OldFileName = OldFnVec(contains(NewFnVec,HumFnRoot)); %this could be multiple old filenames, becaue each subrec can be different

    %now, get matching LENA acoustics TS table
    LenaFName = strcat(LENAPath,HumFnRoot,'_ZscoredAcousticsTS_LENA.csv');
    LenaTab = readtable(LenaFName,'Delimiter',',');

    %initialise table to store matched LENA data
    LenaMatchTab = array2table(zeros(0,size(LenaTab,2)));
    LenaMatchTab.Properties.VariableNames = LenaTab.Properties.VariableNames;  
    %-----------------------------------------------------------------------------------

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
    %-----------------------------------------------------------------------------------

    %read in corresponding human listener labels - this is so we only pick
    %out sections that *have* been annotated
    HumLabTS = readtable(HumTSFiles(i).name,'Delimiter',',');

    %get vector of annotated sections and get the start and end times of
    %the sections
    AnnotatedSections = unique(HumLabTS.SectionNum);
    Hum_SectionStart = zeros(numel(AnnotatedSections),1); %initialise vectors to store start and end times
    Hum_SectionEnd = zeros(numel(AnnotatedSections),1);
    for j = 1:numel(AnnotatedSections) %get start and end times
        Hum_SectionStart(j) = min(HumLabTS.start(HumLabTS.SectionNum == AnnotatedSections(j)));
        Hum_SectionEnd(j) = max(HumLabTS.xEnd(HumLabTS.SectionNum == AnnotatedSections(j)));
    end

    %sort both start times (both are in seconds)
    [Spreadsheet_SectionStart,SpreadsheetSortI] = sort(Spreadsheet_SectionStart);
    Spreadsheet_SectionEnd = Spreadsheet_SectionEnd(SpreadsheetSortI);
    [Hum_SectionStart,HumSortI] = sort(Hum_SectionStart);
    Hum_SectionEnd = Hum_SectionEnd(HumSortI);
    %-----------------------------------------------------------------------------------

%------DEBUGGING BIT-----------------------------------------------------------------------------------
    %AnnotatedSections %Ctr = 0;
%------DEBUGGING BIT-----------------------------------------------------------------------------------

    %Now, do the matching:
    %initalise cell array to store the section number 
    SectionNumForLena = cell(1,numel(Spreadsheet_SectionStart));
    for j = 1:numel(Hum_SectionStart)%go through and match sections

%------DEBUGGING BIT-----------------------------------------------------------------------------------
        %Flag = 0; 
        %MatchInd = NaN; %this bit flags if there are section start and end times that
        %don't match between the annotation file and the coding
        %spreadsheet, upto a toerance. We set this tolerance to 80 seconds,
        %after checking different tolerances. This means that the section
        %start time per coding spreadsheet and the human listener labels
        %can have a difference of up to 80 seconds (and similarly for end
        %times)
        %Feel free to uncomment to verify 
%------DEBUGGING BIT-----------------------------------------------------------------------------------

        for k = 1:numel(Spreadsheet_SectionStart) 
            if (abs(Hum_SectionStart(j)-Spreadsheet_SectionStart(k))<300)...
                    && (abs(Hum_SectionEnd(j)-Spreadsheet_SectionEnd(k))<300)

%------DEBUGGING BIT-----------------------------------------------------------------------------------
                %Ctr = Ctr + 1; %Flag = 1; %MatchInd = k;
%------DEBUGGING BIT-----------------------------------------------------------------------------------

                LenaMatchSubTab = LenaTab(LenaTab.xEnd >= Spreadsheet_SectionStart(k) & LenaTab.start <= Spreadsheet_SectionEnd(k),:);
                %Note that we allow for all vocs that end after the start
                %time of the section and start before the end time of the
                %section
                LenaMatchTab = [LenaMatchTab; LenaMatchSubTab];
                SectionNumForLena{j,1} = j*ones(size(LenaMatchSubTab,1),1);
            end
        end

%------DEBUGGING BIT-----------------------------------------------------------------------------------
        %This bit checks if the matched start times from the annotations
        %files are before the the coding spreadsheet (and if the
        %matched end times from the annottaion files are after the coding
        %spreadsheet). We an tolerate a few seconds, but anything more than
        %a couple seconds is a problem. We tested this and made sure that
        %there were no such outliers. 
        %if ((Hum_SectionStart(j)-Spreadsheet_SectionStart(MatchInd))<0)...
                   % || ((Hum_SectionEnd(j)-Spreadsheet_SectionEnd(MatchInd))>0)
                %Flag = 1;
        %end
        %if Flag ~= 1
            %[i j] %[Hum_SectionStart(j) Hum_SectionEnd(j)] %[Spreadsheet_SectionStart Spreadsheet_SectionEnd]
        %end
%------DEBUGGING BIT-----------------------------------------------------------------------------------

    end

%------DEBUGGING BIT-----------------------------------------------------------------------------------
    %if Ctr ~= numel(AnnotatedSections)
        %i
    %end
%------DEBUGGING BIT-----------------------------------------------------------------------------------

    %add section number to the table
    LenaMatchTab.SectionNum = cell2mat(SectionNumForLena);

    %save new file
    NewFnToSave = strcat(savepath,HumFnRoot,'_MatchedLENA_ZscoreTS.csv');  
    writetable(LenaMatchTab,NewFnToSave);

end

%TODOOOOOOOO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%also need summary info abt num of sections in spreadsheet for each voc
%file  + whether all such sections have been coded + how many 5 min
%segments each recording has in spreadsheet and in the actual eaf file
%We can do this when we match segments to LENA segments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%
%The following (lines 89-134) was written to check if there are recorder pauses during
%sections. As of now, there aren't, so I am commenting this out. You can
%uncomment it if you want to check for yourself. 

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

%some notes: the following files have what I consider a non-insiginificant
%number of annotated vocalisations that are not specified in the coding
%spreadsheet, specified below in order:
%(index i from the first for loop in thsi script, filename)
%(34 0193_010605a.eaf) (41 0223_000226.eaf) (57 0274_010611.eaf)
%(60 0275_000908.eaf) (70 0344_000606.eaf) (74 0425_000306.eaf)
%(79 0425_010611.eaf) (84 0441_000312b.eaf) (86 0517_000602.eaf)
%(92 0534_000307.eaf) (121 0776_000613.eaf) (138 0848_000600.eaf)
%(143 0919_000900.eaf) (15 0054_000902.eaf) (1 0009_000302.eaf) 
%(55 0274_000605.eaf) (69 0344_000300.eaf) (72 0344_010605.eaf)
%(98 0583_000605.eaf) (102 0623_000607.eaf) (128 0804_000602.eaf)
%(155 0969_000304.eaf) Of these: 
 %- index 34, 0193_010605a.eaf has no sections in the coding sheet, but, this is part a of a recordings and all 5 min 
  %sections are in part 2
 %- index 86, 0517_000602.eaf has a section in annotated file that is not in coding sheet that is less than a minute long, 
  %and another that is 5.09 minutes long, also not in coding sheet. We cannot be sure if this is because only these 1.6 minutes have CHN/AN vocs 
  %or even whether this 'section' is a continuous section because onset/offset times are also annotated by listeners. 
  %This is, in fact, an issue for all 'sections' that are in the annotated file but not in the coding sheet
 %- index 84, 0441_000312b.eaf has an issue because there are duplicates in the sheet, and one section in the sheet 
  %is less than 30 minutes away from another section, but in the annotated file, there is an additional section
  %that is roughly 1.6 minutes long. 
 %- index 15, '0054_000902.eaf' has a section in the annotated file about 5 min long that is not in the coding sheet
    %and does not have a section that is in teh coding sheet
 %- index 121, 0776_000613.eaf has a section in annotated file about 2.5 minutes long, about a minute long, and 
  %one, also not in coding sheet, that's about 3 minutes long
 %- index 79, 0425_010611.eaf had an issue because a start time was not being read in, and i have fixed that
  %by hard coding that info in
 %- indices 155, 128, 102, 72, 69, 55, 41, 60, 70, 92, 138, 143 has three sections in coding sheet + one section of vocs not in coding sheet
 %- indices 98, 1, 57, 74 has three sections in coding sheet + several not in

%altogether, tehre are roughly 1300 vocs that will be excluded from analysis in the human listener annotated data because 
%they are outside of designated sections

