clear all
clc

%Ritwika VPS
%Feb2021

%Code to go to IVFCR folder, go into all folders that have human-labelled data,
%copy all .eaf in all folders into a new folder so pre-processing can be
%done, and rename according to Homebank convention

%I have tried to remove backupfiles, etc. using string searches, but whatever
% get trhough these filters, I delete manually. There are still some rogue back-up filess with RA initials and date of
%annotation (but without the substring 'BackupAnnotationFile' or variation
%of it) that make it through to the EAFfiles folder. Since there are only a
%few of them, I manually delete them instead of trying to code the
%exclusion of those in as well

%WOULD BE IDEAL TO WRITE THIS INTO A .sh CODE

cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Coding' %Go to folder with .eaf folders

%Insert your destination path
EAFpath = '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A1_EAFFiles/';

%All folders with human labelled data are in folders pre-fixed with 'IVFCR' (This detail may change later?).
%Use dir to get these
aa = dir('IVFCR*');
%identify the elements of aa that are folders/directories
dirFlags = [aa.isdir]; %logical vector: 1 means the item is, indeed, a directory

RA_AnnotPatt = lettersPattern(2) + digitsPattern(8); %for file names that contains RA initials and date (eg. ZA10122020), which are backups

%get path to each relevant directory
counter = 0;
for i = 1:numel(aa)
    if dirFlags(i) == 1 %if it is a directory, find path, etc.
        
        s = what(aa(i).name); %what gets the path to the directory if its name is shown
        %I am not sure how foolproof this is, like what happens when there
        %are 2 distinct directories with the same name?
        %Not quite clear from the help page: https://www.mathworks.com/help/matlab/ref/what.html
        %But, it works, so this is how it shall be
        
        cd(s.path); %go into the relevant directory
        
        newaa = dir('*.eaf'); %This is just to have a .txt file that has file names and corresponding Infant codes, just in case;
        %also helps to check if there are no .eaf files
         
        if isempty(newaa) == 0 %Proceed if there ARE .eaf files
            for j = 1:numel(newaa)
               %Check if it is a backup file and ONLY proceed if not a
               %backup file
               %Also check if file is greater than 3 kb. We only want files
               %that are greater than 3 kb, because anything less will not
               %have any annotations
               if (contains(newaa(j).name,RA_AnnotPatt) == 0) && ...
                   (contains(newaa(j).name,{'BackupAnnotation','Backup','Annotation','Bacup','@','('},'IgnoreCase',true) == 0) ...
                       && (newaa(j).bytes/1000 > 3)
                   
                   %exclude files not included in further analyses
                   %(recording corresponding to e20171107_102544_010585.eaf
                   %was replaced by a re-recording;
                   %e20161103_151445_010572.eaf potentially contains
                   %portions of recording that has since been deleted)
                   %Finally, 'e20181231_104022_010581.eaf' has a missing
                   %file and cannot be used for comparisons with LENA data
                   if (strcmp(newaa(j).name,'e20171107_102544_010585.eaf') == 0)...
                           && (strcmp(newaa(j).name,'e20161103_151445_010572.eaf') == 0)...
                            && (strcmp(newaa(j).name,'e20181231_104022_010581.eaf') == 0)
                       
                       counter = counter + 1;
                       EafFileNameOld{counter,1} = newaa(j).name;
                       EafInfantCode{counter,1} = strtrim(erase(aa(i).name,'IVFCR')); %removes IVFCR and any trailing and leading spaces

                       copyfile(newaa(j).name,EAFpath); %copy all .its files to teh destination

                   elseif strcmp(newaa(j).name,'e20181231_104022_010581.eaf') == 1 %move this to folder: NotIncludedInThisAnalysis
                       
                       copyfile(newaa(j).name,...
                       '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/A1_EAFFiles/NotIncludedInThisAnalysis');
                        %I rename this file to homebank convention
                        %manually, in this folder
                   end
               end
            end
        end
        
      %Go back to IVFCR Coding folder so the loop can repeat  
      cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Coding' %Insert your path
      
    end
end

%finally, we rename all the files per HomeBank convention
%go to LENA its file doler
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A1_ItsFiles'

opts = detectImportOptions('ItsFileDetailsWOldFN.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
ItsFileDetails = readtable('ItsFileDetailsWOldFN.csv',opts);
ItsOldRoot =ItsFileDetails.OldFNRoot;
ItsNewRoot = ItsFileDetails.FNRoot; 

%go back to eaf file folder
cd(EAFpath);

%go through eaf file names, match with old file name roots, and rename
for i = 1:numel(EafFileNameOld)
    for j = 1:numel(ItsOldRoot)
        if (strcmp(erase(EafFileNameOld{i},'.eaf'),ItsOldRoot{j}) == 1) && ...
            (strcmp(ItsFileDetails.InfantID{j},erase(EafInfantCode{i},'-')) == 1) %in the .eaf folders, 384-A and 384-B have hyphens, while not in Its filespreadsheet
            OldName = strcat(EAFpath,'/',EafFileNameOld{i});
            NewName = strcat(EAFpath,'/',ItsNewRoot{j},'.eaf');
            EafFileNameNew{i,1} = strcat(ItsNewRoot{j},'.eaf');
            movefile(OldName,NewName); %renmame files
        end
    end
end

InfantID = EafInfantCode; %rename vector
FileNameOld = EafFileNameNew;
FileNameNew = EafFileNameOld;
%write table with files names and infant codes
table1 = table(EafFileNameOld,EafFileNameNew,InfantID);
writetable(table1,'EAFFileDetailsWithOldFN.csv')

%finally have a spreadsheet with info about which .its files have
%corresponding (usable) .eaf files
IndexVec = 1:numel(ItsNewRoot);
for i = 1:numel(EafFileNameNew)
    if sum(contains(ItsNewRoot,erase(EafFileNameNew{i},'.eaf'))) == 1
        MatchingEafFileInd(i) = IndexVec(contains(ItsNewRoot,erase(EafFileNameNew{i},'.eaf')));
    else
        i %to find any eaf files without matching its file names
    end
end

EafFileMatch = zeros(numel(ItsNewRoot),1);
EafFileMatch(MatchingEafFileInd) = 1;

table2 = table(ItsNewRoot,EafFileMatch);
writetable(table2,'ItsvsEafFilesDetails.csv')

        