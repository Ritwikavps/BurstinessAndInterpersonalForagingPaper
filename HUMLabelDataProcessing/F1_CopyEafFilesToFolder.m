clear all
clc

%Ritwika VPS
%Feb2021

%Code to go to IVFCR folder, go into all folders that have human-labelled data,
%copy all .eaf in all folders into a new folder so pre-processing can be
%done

%There are still some rogue back-up filess with RA initials and date of
%annotation (but without the substring 'BackupAnnotationFile' or variation
%of it) that make it through to the EAFfiles folder. Since there are only a
%few of them, I manually delete them instead of trying to code the
%exclusion of those in as well

%WOULD BE IDEAL TO WRITE THIS INTO A .sh CODE

cd ~/Box/'IVFCR Coding' %Go to folder with .eaf folders

destinationpath = '/Volumes/GoogleDrive/My Drive/research/vocalisation/Pre_registration_followu/Data/EAFfiles'; %Insert your destination path

%All folders with human labelled data are in folders pre-fixed with 'IVFCR' (This detail may change later?).
%Use dir to get these
aa = dir('IVFCR*');
%identify the elements of aa that are folders/directories
dirFlags = [aa.isdir]; %logical vector: 1 means the item is, indeed, a directory

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
               if (contains(newaa(j).name,{'BackupAnnotation','Backup','Annotation','Bacup'},'IgnoreCase',true) == 0) ...
                       && (newaa(j).bytes/1000 > 3)
                   
                   %exclude files not included in further analyses
                   %(recording corresponding to e20171107_102544_010585.eaf
                   %was replaced by a re-recording;
                   %e20161103_151445_010572.eaf potentially contains
                   %portions of recording that has since been deleted)
                   if (strcmp(newaa(j).name,'e20171107_102544_010585.eaf') == 0)...
                           && (strcmp(newaa(j).name,'e20161103_151445_010572.eaf') == 0)
                       
                       counter = counter + 1;
                       FileName{counter,1} = newaa(j).name;
                       InfantCode{counter,1} = strtrim(erase(aa(i).name,'IVFCR')); %removes IVFCR and any trailing and leading spaces

                       copyfile(newaa(j).name,destinationpath); %copy all .its files to teh destination
                   end
               end
            end
        end
        
      %Go back to IVFCR Coding folder so the loop can repeat  
      cd ~/Box/'IVFCR Coding' %Insert your path
      
    end
end

%Go to destination
cd(destinationpath);

%write table with files names and infant codes
table1 = table(FileName,InfantCode);
writetable(table1,'EAFFileDetails.csv')
        