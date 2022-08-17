clear all
clc

%Ritwika VPS, (UCLA, UC Merced)
%Script to get infant age from .csv files with DOB and time of recording
%and write the info into a single .csv file

%go to folder ith .csv files
cd '/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A1_ItsFiles'

aa = dir('*InfantAge.csv'); %get all relevant .csv files

if isempty(aa) %chekc if there are .csv files
    error('There are no .csv files ending with InfantAge.csv') %if this error is thrown, you will have to rerun the Infant Age script (A2_RunFolderInfantAge.sh)
end

%read csv file with its file details to match age and file name to infant ID
%This will be usefiul in writing metadata
%The options are being specified because we want the infant id to be read
%in as string so that infant ID 009 is read in as 009 and not 9 (for
%example)
%Alao because there are IDs 384 A and B
opts = detectImportOptions('ItsFileDetailsShareable.csv');
opts = setvartype(opts, 'InfantID', 'string');
ItsFileTab = readtable('ItsFileDetailsShareable.csv',opts);

for i = 1:numel(aa) %go through .csv files
    AgeTab = readtable(aa(i).name); 
    
    %get recording date; note that it is in year-month-day format
    %strrep replaces substring in first '' by substring in the second ''
    %datenum converts the date to a number, to do arithmetic operations on
    RecDate = datenum(strrep(AgeTab{1,1},'Recording date is',''),'yyyy-mm-dd');
    DOBdate = datenum(strrep(AgeTab.Properties.VariableNames{1},'DOBIs',''),'yyyy_mm_dd'); %get DOB (variable name)
    
    InfantAge(i,1) = abs(RecDate-DOBdate);
    FNRoot{i,1} = strrep(aa(i).name,'InfantAge.csv',''); %get file name root
    
    for j = 1:size(ItsFileTab,1) %loop through the rows to match file names
        if contains(ItsFileTab{j,1},FNRoot{i,1}) %if fileroot matches
            InfantID{i,1} = ItsFileTab{j,2};
        end
    end   
end

%There seems to be a duplicate for '0667_000604'. I am not quite sure why this happens. 
%This (and any other repeats like this, with all the same info) will need to be
%removed manually (for now) after the table is saved, since for now, there
%is only one repeat likle this

T = table(FNRoot,InfantID,InfantAge);
writetable(T,'/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MetadataInfAgeAndID.csv')

%delete all Infant Age files (because of the duplicate file, you'll have to
%do the delete command twice
delete *InfantAge.csv