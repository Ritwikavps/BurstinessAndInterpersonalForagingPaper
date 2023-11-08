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

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';

%read in coding spreadsheet
CodingSpreadsheet = readtable(strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/ListOfAnnotatedSections.csv')); %this file has info 
%about all the sections that have actually been annotated (outputed by the CheckFlagsForHumLabelling.m script)

Fn_CodingSheet = regexprep(CodingSpreadsheet.FileName,'[a-zA-Z\s]',''); %remove a, b, c etc to get just the day-level filename
u_FnCodingSheet = unique(Fn_CodingSheet); %get unique

savepath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData/'); %path to save files
LENAPath = strcat(BasePath,'Data/LENAData/A8_ZscoredTSAcousticsLENA/'); %path to LENA tables

for i = 1:numel(u_FnCodingSheet)
    
    %now, get matching LENA acoustics TS table
    LenaFName = strcat(LENAPath,u_FnCodingSheet{i},'_ZscoredAcousticsTS_LENA.csv');
    LenaTab = readtable(LenaFName,'Delimiter',',');
    SectionNumVec = GetSectionNumVec(LenaTab); %add section number info to LENA, so we dont take step sizes between two subrecs
    LenaTab.SectionNum = SectionNumVec;

    %initialise table to store matched LENA data
    LenaMatchTab = array2table(zeros(0,size(LenaTab,2)));
    LenaMatchTab.Properties.VariableNames = LenaTab.Properties.VariableNames;  
    SectionNum5min_Temp = [];
    %-----------------------------------------------------------------------------------
    %get all instances of matching filenames for old file name of interest from coding spreadsheet, and pick out only those sections that have been annotated
    CodingSubTable = CodingSpreadsheet(contains(CodingSpreadsheet.FileName,u_FnCodingSheet{i}) & CodingSpreadsheet.SectionAnnotated == 1,:); 

    %get matched LENA 5 min sections for all annotated sections
    for j = 1:numel(CodingSubTable.StartTimeSS)
        if CodingSubTable.SectionAnnotated(j) == 1 %check to make sure that the section has been annotated (this is redundant, but just in case)
            LenaMatchSubTab = LenaTab(strcmp(LenaTab.FileNameUnMerged,CodingSubTable.FileName(j)),:); %match the subrec names
            LenaMatchSubTab = LenaMatchSubTab(LenaMatchSubTab.xEnd >= CodingSubTable.StartTimeSS(j) & LenaMatchSubTab.start <= CodingSubTable.EndTimeSS(j),:);
            SectionNum5min_Temp = [SectionNum5min_Temp; j*ones(size(LenaMatchSubTab,1),1)];
            LenaMatchTab = [LenaMatchTab; LenaMatchSubTab];
        end
    end

    LenaMatchTab.SectionNum5min = SectionNum5min_Temp;

    %save new file
    NewFnToSave = strcat(savepath,u_FnCodingSheet{i},'_MatchedLENA_ZscoreTS.csv');  
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

