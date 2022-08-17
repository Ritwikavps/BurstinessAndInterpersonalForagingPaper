clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%This script stitches together TS + pauses + response data from the same
%recording day. This is because we have recordings that are named:
%297332_w789127_1738973_Section1, 297332_w789127_1738973_Section2, where
%these are both from the same infant on the same day.

%set destination path where tables and metadata will be written
destinationpath = '/Volumes/GoogleDrive-104060580022184327356//My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A7_AcousticsTSJoinedwPausesAndResponses/';

%read in table with .its file details
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData'
opts = detectImportOptions('MetadataInfAgeAndID.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
FnAgeInfantIdDetails = readtable('MetadataInfAgeAndID.csv',opts);

%cd into folder
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A6_ResponseData'

%get all files
TSFiles = dir('*Responses.csv');

%go through all files and get file roots (without section numbers, a, b, etc.)
for i = 1:numel(TSFiles)
    NewName = strrep(TSFiles(i).name,'_Responses.csv','');
    FileNameRoot_Temp{i,1} = NewName(1:11); %get first 11 characters, because thsi is <4 character infant id>_<Age in YYMMDD>
end

%Now we pick out all the files with the same file root (a, b, etc, provide
%subrec info, so we will merge these)

%Get unique file name roots
U_FileNameRoot = unique(FileNameRoot_Temp); 

%get proprtynames of one of the TSfiles tables to make an empty table so as
%to vertically concatenate tables with the same file name root 
TabToReadVarNames = readtable('0009_000302_Responses.csv','Delimiter',',');
VarNamesForEmptyTab = TabToReadVarNames.Properties.VariableNames;

%go through unique filename roots and match root name to full file names
for i = 1:numel(U_FileNameRoot)

    %initialise empty table with same coilumn names to concatenate tables
    %for the recordings from sdame infant on the same day
    T_new = array2table(zeros(0,numel(VarNamesForEmptyTab)),'VariableNames',VarNamesForEmptyTab);

    %line of code to test everything is workinhg
        %sizeAll = 0;

    NewTableName = strcat(destinationpath,U_FileNameRoot{i},'_AcousticsTSJoined.csv');

    u_TabFn = FnAgeInfantIdDetails.FNRoot(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i))); %table containing filenames corresponding to
    %each unique, cleaned up file name root
    u_TabInfantId = FnAgeInfantIdDetails.InfantID(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i))); %get corresponding infant ID and age
    u_TabAge = FnAgeInfantIdDetails.InfantAge(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i)));

    AgeDiff = u_TabAge - u_TabAge'; %get difference of ages between all elements
    AgeDiff = AgeDiff(AgeDiff > 5); %only keep age differences greater than 5 days
    %This is to account for subrecordings that has +/1 age diff due to
    %reading in DOBs or recording dates without correcting for local
    %timezone vs. Greenwich

    InfantID{i,1} = unique(u_TabInfantId);
    InfantAgeDays(i,1) = min(u_TabAge);

    if (numel(unique(u_TabInfantId)) == 1) && (numel(AgeDiff) == 0)%if this corresponds to a single age and id 
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
        u_TabInfantId
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

%Get age in months: separate into 3,6,9 and 18, and others
for i = 1:numel(InfantAgeDays)
    if (InfantAgeDays(i)/30 > 2.5) && (InfantAgeDays(i)/30 < 4)
        InfantAgeMonth(i,1) = 3;
    elseif (InfantAgeDays(i)/30 > 5.5) && (InfantAgeDays(i)/30 < 7)
        InfantAgeMonth(i,1) = 6;
    elseif (InfantAgeDays(i)/30 > 8.5) && (InfantAgeDays(i)/30 < 10)
        InfantAgeMonth(i,1) = 9;
    elseif (InfantAgeDays(i)/30 > 17.5) && (InfantAgeDays(i)/30 < 19)
        InfantAgeMonth(i,1) = 18;
    else
        InfantAgeMonth(i,1) = round(InfantAgeDays(i)/30); 
    end
end

FileNameRoot = U_FileNameRoot;
T_Metadata = table(FileNameRoot,InfantAgeDays,InfantAgeMonth,InfantID);
writetable(T_Metadata,strcat(destinationpath,'MergedTSAcousticsMetadata.csv'))




