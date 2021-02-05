clear all
clc

%Ritwika VPS
%Feb2021

%Code to go to IVFCR folder, go into all folders that have LENA data,
%copy all .its in all folders into a new folder so pre-processing can be
%done

%WOULD BE IDEAL TO WRITE THIS INTO A .sh CODE

cd ~/Box/'IVFCR Coding'/LENAExports %Insert your path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The commented out cbit of code should only be run once because once stuff
%is saved into this directory, we really don't want the directory to get
%overwritten
%In my case, I have already done this
    mkdir ~/Box/'IVFCR Coding'/LENA_segmentsextracted_RVPS/ItsFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

destinationpath = '/Users/ritu/Box/IVFCR Coding/LENA_segmentsextracted_RVPS/ItsFiles'; %Insert your destination path

%All folders with LENA data are in here. Use dir to get these
aa = dir;
%identify the elements of aa that are folders/directories
dirFlags = [aa.isdir]; %logical vector: 1 means the item is, indeed, a directory

%get path to each relevant directory
counter = 0;
for i = 1:numel(aa)
    if dirFlags(i) == 1 %if it is a directory, find path, etc.

        i
        
        s = what(aa(i).name); %what gets the path to the directory if its name is shown
        %I am not sure how foolproof this is, like what happens when there
        %are 2 distinct directories with the same name?
        %Not quite clear from the help page: https://www.mathworks.com/help/matlab/ref/what.html
        %But, it works, so this is how it shall be
        
        cd(s.path); %go into the relevant directory
        
        newaa = dir('*.its'); %This is just to have a .txt file that has file names and corresponding Infant codes, just in case;
        %also helps to check if there are no .its files
        if isempty(newaa) == 0 %Proceed if there ARE .its files
            for j = 1:numel(newaa)
               counter = counter + 1;
               FileName{counter,1} = newaa(j).name;
               InfantCode{counter,1} = aa(i).name;
            end

            copyfile('*.its',destinationpath); %copy all .its files to teh destination
        end
        
      %Go back to IVFCR Coding folder so the loop can repeat  
      cd ~/Box/'IVFCR Coding'/LENAExports
      
    end
end

%Go to destination
cd(destinationpath);

%write table with files names and infant codes
table1 = table(FileName,InfantCode);
writetable(table1,'ItsFileDetails.csv')
        