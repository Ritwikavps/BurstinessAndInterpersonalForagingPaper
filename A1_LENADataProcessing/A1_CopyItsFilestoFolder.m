clear all
clc

%Ritwika VPS, UC Merced
%Feb2021
%Edited: March 2022
%changes made to go to IVFCR Study Renamed folder and get the more complete corpus of .its files from there. Also make two .csv files: one
    %with filenames and infant code, and the other with renamed and old file names + infant code. Also added code to compute infant age from file
    %name (file name is <4-character child ID>_<age in YYMMDD>.

%This script goes into the IVFCR folder, goes into all folders that have LENA data, copy all .its in all folders into a new folder so pre-processing can be done

%SOME NOTES:
    %-%If you don't have all your .its files in a single folder, this is the first script you schould run. YOU WILL NOT NEED THIS IF YOUR DATA IS ALREADY ORGANISED INTO A FOLDER OF
      %.its FILES (%WOULD BE IDEAL TO WRITE THIS INTO A .sh CODE)
    %-Also note, as of April 2021, there is NOT_IVFCR folder in LENA_Exports (not named as such in renamed folder). i have coded in not including the .its files for this. If there are
     %other .its file syou would liek to not include, please delete them manually after copying, or adapot this script accordingly

NotIvfcrId = '941'; %specifiy which infant ID is NOT-IVFCR
    
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Study'/LENAExports_Renamed/ %Insert your path; CHANGE PATH ACCORDINGLY

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';%This is the base path to the google drive folder that may undergo change; PLEASE CHANGE ACCORDINGLY
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
destinationpath = strcat(BasePath,'Data/LENAData/A1_ItsFiles/'); %Insert your destination path

%All folders with LENA data are in here. Use dir to get these
aa = dir;
%identify the elements of aa that are folders/directories
dirFlags = [aa.isdir]; %logical vector: 1 means the item is, indeed, a directory

%get path to each relevant directory
counter = 0; %initialise counter variable

for i = 1:numel(aa) %loop through directory list

    i

    if (dirFlags(i) == 1) && (contains(aa(i).name,NotIvfcrId)~=1) %if it is a directory, AND
        %if it is not the NOT_IVFCR folder, which is folder 0941, go in, find path, etc.
        
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
                FNRoot{counter,1} = strrep(newaa(j).name,'.its',''); %remove .its from file name

                %optional code to use file name to compute age
                        % AgeStringPre = strsplit(FNRoot{counter,1},'_'); %split filename at the underscore; Age is the second substing
                        % AgeString = AgeStringPre{2};
                        % AgeString = AgeString(isletter(AgeString) ~= 1); %remove any letters from string
                        % %the first two of this is the year, the second two
                        % %characters teh month, and the last two the age in days
                        % InfantAge(counter,1) = str2num(AgeString(1:2))*365 + str2num(AgeString(3:4))*30 + str2num(AgeString(5:6));
                
                TempInfCode = strtrim(aa(i).name); %get infant code from folder name

                if strcmp(TempInfCode(1),'0') == 1 %remove extra 0 from the start of infant code string
                    TempInfCode(1) = [];
                end
                InfantID{counter,1} = TempInfCode;
                
                fileID = fopen(newaa(j).name); %get file id for each file
    
                while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks
                
                    myline = fgetl(fileID); %goes through line by line
                    
                    if contains(myline,'<ITS fileName="')
                        myline = strrep(myline,'<ITS fileName="','');
                        mylineSplit = strsplit(myline,'"');
                        OldFNRoot{counter,1} = strcat('e',mylineSplit{1}); %add e to the front of old fiile name
                        break
                    end
                end
            end
            
            copyfile('*.its',destinationpath); %copy all .its files to teh destination
        end
        
      %Go back to IVFCR Coding folder so the loop can repeat  
      cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Study'/LENAExports_Renamed/
      
    end
end

%Another note: for now, there is one folder that contains data from an
%older sibling (labelled NOT IVFCR) in the LENAExports folder. I simply
%moved the folder out of LENAExports before running this script (and returned it after). 

%Go to destination
cd(destinationpath);

%write table with files names and infant codes
TablewOldFn = table(FNRoot,OldFNRoot,InfantID);
TableToShare = table(FNRoot,InfantID);

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd(strcat(BasePath,'Data/MetadataFiles/')); %path for metadata files; CHANGE ACCORDINGLY
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
writetable(TablewOldFn,'ItsFileDetailsWOldFN.csv')
writetable(TableToShare,'ItsFileDetailsShareable.csv')

        