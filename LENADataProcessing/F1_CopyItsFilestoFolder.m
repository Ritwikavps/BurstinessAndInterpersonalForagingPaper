clear all
clc

%Ritwika VPS, UC Merced
%Feb2021

%Code to go to IVFCR folder, go into all folders that have LENA data,
%copy all .its in all folders into a new folder so pre-processing can be
%done

%If you don't have all your .its files in a single folder, this is the
%first script you schould run

%SOME NOTES:
    %-YOU WILL NOT NEED THIS IF YOUR DATA IS ALREADY ORGANISED INTO A FOLDER OF
      %.its FILES (%WOULD BE IDEAL TO WRITE THIS INTO A .sh CODE)
    %-Also not, as of April 2021, there is NOT_IVFCR folder in LENA_Exports. 
     %i have coded in not including the .its files for this. If there are
     %other .its file syou would liek to not include, please delete them
     %manually after copying, or adapot this script accordingly
    
cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Coding'/LENAExports/ %Insert your path

destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/ItsFiles'; %Insert your destination path

%All folders with LENA data are in here. Use dir to get these
aa = dir;
%identify the elements of aa that are folders/directories
dirFlags = [aa.isdir]; %logical vector: 1 means the item is, indeed, a directory

%get path to each relevant directory
counter = 0; %initialise counter variable

for i = 1:numel(aa) %loop through directory list
    if (dirFlags(i) == 1) && (contains(aa(i).name,'NOT_IVFCR')~=1) %if it is a directory, AND
        %if it is not the NOT_IVFCR folder, go in, find path, etc.
        
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
               InfantCode{counter,1} = strtrim(erase(erase(aa(i).name,'(All'),{'Months)','Month)'}));
               %THis removes the 'All', 'Months', and 'Month' substrings in two steps
               %and then rmeoves all trailing and leading white space, so
               %that only infant ID is stored. The removal of substrings in
               %two steps is so that we don't trip up on variations such as
               %'AllMonths', 'All Months', etc. The case is uniform for
               %these substrings in the dataset we have, so there is no
               %needto control for that. 
            end
            
            copyfile('*.its',destinationpath); %copy all .its files to teh destination
        end
        
      %Go back to IVFCR Coding folder so the loop can repeat  
      cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Coding'/LENAExports/
      
    end
end

%Another note: for now, there is one folder that contains data from an
%older sibling (labelled NOT IVFCR) in the LENAExports folder. I simply
%moved the folder out of LENAExports before running this script (and returned it after). 

%Go to destination
cd(destinationpath);

%write table with files names and infant codes
table1 = table(FileName,InfantCode);
writetable(table1,'ItsFileDetails.csv')
%Note that if you open this table in Excel, it might show infant IDs as 9
%instead of 009, etc.
        