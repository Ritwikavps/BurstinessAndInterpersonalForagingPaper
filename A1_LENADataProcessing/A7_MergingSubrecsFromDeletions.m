clear all
clc

%Ritwika VPS, March 2022
%UCLA Dpmt of Comm

%This script stitches together TS + pauses from the same recording day. This is because we have recordings that are named:
%<File name root>_Section1, <File name root>_Section2, where these are both from the same infant on the same day.

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATH ACCORDINGLY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';
destinationpath = strcat(BasePath,'Data/LENAData/A6_AcousticsTSJoinedwPauses/'); %set destination path where tables will be written
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------

%read in table with .its file details
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd(strcat(BasePath,'Data/MetadataFiles')); %CHANGE PATH ACCORDINGLY
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
opts = detectImportOptions('MetadataInfAgeAndID.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
FnAgeInfantIdDetails = readtable('MetadataInfAgeAndID.csv',opts);

%cd into folder with TS files and get all files
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd(strcat(BasePath,'Data/LENAData/A5_TimeSeriesWPauses/'));
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
TSFiles = dir('*_TSwPauses.csv');

%go through all files and get file roots (without section numbers, a, b, etc.)
for i = 1:numel(TSFiles)
    NewName = strrep(TSFiles(i).name,'_TSwPauses.csv','');
    FileNameRoot_Temp{i,1} = NewName(1:11); %get first 11 characters, because thsi is <4 character infant id>_<Age in YYMMDD>
end

%Now we pick out all the files with the same file root (a, b, etc, provide subrec info, so we will merge these)
U_FileNameRoot = unique(FileNameRoot_Temp);  %Get unique file name roots

%get proprtynames of one of the TSfiles tables to make an empty table so as to vertically concatenate tables with the same file name root 
TabToReadVarNames = readtable('0009_000302_TSwPauses.csv','Delimiter',',');
VarNamesForEmptyTab = TabToReadVarNames.Properties.VariableNames;

%go through unique filename roots and match root name to full file names
for i = 1:numel(U_FileNameRoot)

    %initialise empty table with same coilumn names to concatenate tables
    %for the recordings from sdame infant on the same day
    T_new = array2table(zeros(0,numel(VarNamesForEmptyTab)),'VariableNames',VarNamesForEmptyTab);

    %line of code to test everything is workinhg
        %sizeAll = 0;

    NewTableName = strcat(destinationpath,U_FileNameRoot{i},'_AcousticsTSJoined.csv');

    u_TabFn = unique(FnAgeInfantIdDetails.FNRoot(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i)))); %table containing filenames corresponding to
    %each unique, cleaned up file name root
    u_TabInfantId = unique(FnAgeInfantIdDetails.InfantID(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i)))); %get corresponding infant ID and age
    u_TabAge = unique(FnAgeInfantIdDetails.InfantAge(contains(FnAgeInfantIdDetails.FNRoot,U_FileNameRoot(i))));

    AgeDiff = u_TabAge - u_TabAge'; %get difference of ages between all elements
    AgeDiff = AgeDiff(AgeDiff > 5); %only keep age differences greater than 5 days. This is to account for subrecordings that has +/1 age diff due to
    %reading in DOBs or recording dates without correcting for local timezone vs. Greenwich

    InfantID{i,1} = unique(u_TabInfantId);
    InfantAgeDays(i,1) = min(u_TabAge);

    %counter to get name of files before stitching subrecs together + get number of entries in those tables. We will use this to
    %add a file name (before stitching subrecs together) column to the
    %final table
    PreSticthFnCtr = 0;
    PreStitchFn = {}; %initialise
    PreStitchFileNumCols = [];

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

                    PreSticthFnCtr = PreSticthFnCtr + 1; %increment counter
                    PreStitchFn{PreSticthFnCtr} = erase(TSFiles(k).name,'_TSwPauses.csv'); %get file name
                    PreStitchFileNumCols(PreSticthFnCtr) = size(readtable(TSFiles(k).name,'Delimiter',','),1); %get number of entries for the file

                end
            end
        end
    else %file names and infant codes of roguye files, test to see everything is working
        u_TabInfantId
        u_TabAge
    end

    %get vector to store file name info for all subrecs stitched into one
    %file. Adding this will be useful when we get matching sections from
    %LENA data for human labelled data so that we don't match sections between different subrecs of
    %the same daylong recording
    FnamePreSticthVec = cell(sum(PreStitchFileNumCols),1); %create cell array to store file names corresponding to each file stitched
    PreStitchFileNumelCumsum = [0 cumsum(PreStitchFileNumCols)]; %get vector with info about how many repeats of a file name should be there
    for j = 1:numel(PreStitchFileNumelCumsum)-1
        [FnamePreSticthVec{PreStitchFileNumelCumsum(j)+1:PreStitchFileNumelCumsum(j+1)}] = deal(PreStitchFn{j});
    end
    T_new.FileNameUnMerged = FnamePreSticthVec; %add column

    %edit wavfile column from table: this column has original file name
    %(and hence, potential id info). This way, only the segment number and
    %speaker ID (chnsp, chnnsp, etc) remains
    T_new.wavfile = regexprep(T_new.wavfile,'.*_Segment','Segment');

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

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd(strcat(BasePath,'Data/MetadataFiles/')); %go to metadata folder; CHANGE PATH ACCORDINGLY
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------
T_Metadata = table(FileNameRoot,InfantAgeDays,InfantAgeMonth,InfantID);
writetable(T_Metadata,'MergedTSAcousticsMetadata.csv')




