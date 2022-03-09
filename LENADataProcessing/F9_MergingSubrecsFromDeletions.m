clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%This script stitches together TS + pauses + response data from the same
%recording day. This is because we have recordings that are named:
%297332_w789127_1738973_Section1, 297332_w789127_1738973_Section2, where
%these are both from the same infant on the same day.

%set destination path where tables and metadata will be written
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/AcousticsTSJoinedwPausesAndResponses/';

%read in table with .its file details
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData'
opts = detectImportOptions('MetadataInfAgeAndID.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
FnAgeInfantCodeDetails = readtable('MetadataInfAgeAndID.csv',opts);

%cd into folder
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/ResponseData'

%get all files
TSFiles = dir('*Responses.csv');

%go through all files
for i = 1:numel(TSFiles)

    FnameStr = TSFiles(i).name; %get file name

    if contains(FnameStr,'section') %remove section number (accounting for case)
        FnameStr = eraseBetween(FnameStr,'_section','_Responses.csv');
        FnameStr = erase(FnameStr,'_section');
    elseif contains(FnameStr,'Section')
        FnameStr = eraseBetween(FnameStr,'_Section','_Responses.csv');
        FnameStr = erase(FnameStr,'_Section');
    end

    if contains(FnameStr,'original') %(remove '_original', accounting for case)
        FnameStr = erase(FnameStr,'_original');
    elseif contains(FnameStr,'Original')
        FnameStr = erase(FnameStr,'_Original');
    end

    FnameStr = erase(FnameStr,'_Responses.csv'); %remove _Responses.csv

    FileNameRoot_Temp{i,1} = FnameStr; %store file name

end

%Get unique file name roots
U_FileNameRoot = unique(FileNameRoot_Temp); 

%get proprtynames of one of the TSfiles tables to make an empty table so as
%to vertically concatenate tables with the same file name root 
TabToReadVarNames = readtable('e20151207_200648_010576_Responses.csv','Delimiter',',');
VarNamesForEmptyTab = TabToReadVarNames.Properties.VariableNames;

%go through unique filename roots and match root name to full file names
for i = 1:numel(U_FileNameRoot)

    %initialise empty table with same coilumn names to concatenate tables
    %for the recordings from sdame infant on the same day
    T_new = array2table(zeros(0,numel(VarNamesForEmptyTab)),'VariableNames',VarNamesForEmptyTab);

    %line of code to test everything is workinhg
        %sizeAll = 0;

    NewTableName = strcat(destinationpath,U_FileNameRoot{i},'_AcousticsTSJoined.csv');

    u_TabFn = FnAgeInfantCodeDetails.FileNameRoot(contains(FnAgeInfantCodeDetails.FileNameRoot,U_FileNameRoot(i))); %table containing filenames corresponding to
    %each unique, cleaned up file name root
    u_TabInfantCode = FnAgeInfantCodeDetails.InfantID(contains(FnAgeInfantCodeDetails.FileNameRoot,U_FileNameRoot(i))); %get corresponding infant ID and age
    u_TabAge = FnAgeInfantCodeDetails.InfantAge(contains(FnAgeInfantCodeDetails.FileNameRoot,U_FileNameRoot(i)));

    AgeDiff = u_TabAge - u_TabAge'; %get difference of ages between all elements
    AgeDiff = AgeDiff(AgeDiff > 5); %only keep age differences greater than 5 days
    %This is to account for subrecordings that has +/1 age diff due to
    %reading in DOBs or recording dates without correcting for local
    %timezone vs. Greenwich

    InfantID(i,1) = unique(u_TabInfantCode);
    InfantAge(i,1) = min(u_TabAge);

    if (numel(unique(u_TabInfantCode)) == 1) && (numel(AgeDiff) == 0)%if this corresponds to a single age and id 
        %go through matching file names and stitch together
        for j = 1:numel(u_TabFn) %match these to files names of TS files
            for k = 1:numel(TSFiles)
                if contains(TSFiles(k).name,u_TabFn(j))
                    T_temp = readtable(TSFiles(k).name,'Delimiter',',');

                    %set the last entry in SubrecEnd variable to 1,
                    %indicating this is the end of a recording (or
                    %subrecording), so in case this gets stitched to
                    %another subrec, we know this is the end point and
                    %account for that in step sizes
                    T_temp.SubrecEnd(end) = 1;

                    %Stitch together
                    T_new = [T_new; T_temp];

                    %line of code to test everything is workinhg
                        %sizeAll = sizeAll + size(T_temp,1);

                end
            end
        end
    else %file names and infant codes of roguye files, test to see everything is working
        u_TabInfantCode
        u_TabAge
    end

    %remove wavfile column from table: this column has original file name
    %(and hence, potential id info)
    T_new.wavfile = [];

    %write table to file
    writetable(T_new,NewTableName)

    %line of code to test everything is workinhg
        %size(T_new,1)-sizeAll
 
end

FileNameRoot = U_FileNameRoot;
T_Metadata = table(FileNameRoot,InfantAge,InfantID);
writetable(T_Metadata,strcat(destinationpath,'MergedTSAcousticsDetails.csv'))




