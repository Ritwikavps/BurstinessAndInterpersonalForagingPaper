%Ritwika
%UCLA, Department of Communiction
%Dec 2021

%Script to read text files generated from eaf files and get time series,
%infant vocal type annotation and adult utterance direction annotation from
%5 minute segmenets annotated by human listeners

%A couple errors:
    %e20160919_115521_010572EAF.txt: annotation id a438 for inf voc type tier doesn't have an annotation (ts 601 to
        %ts 602). In fact, the annotation value line only has '<ANNOTATION_VALUE/>' 
        %instead of the standard '<ANNOTATION_VALUE>X</ANNOTATION_VALUE>' (here X
        %is a sample annotataion)
    %e20170512_113934_010576EAF.txt: annotation id a27 for adult utt dir tier doesn't have an annotation (ts 631 to
        %ts 632). In fact, the annotation value line only has '<ANNOTATION_VALUE/>' 
        %instead of the standard '<ANNOTATION_VALUE>T</ANNOTATION_VALUE>' (here T
        %is a sample annotataion)
%I have a quick fix for this that doesn't really affect any of the
%other files, but if, in the future, this is an error that is present in
%several files, you may want to code a more rigorous exception in
              
clear all
clc

%cd into folder
cd '/Volumes/GoogleDrive/My Drive/research/vocalisation/Pre_registration_followu/Data/HUMLabelData/TxtFilesFromEAF'

AllEafTxtfiles = dir('*EAF.txt'); %get all relevant files

%have a folder each for adult labels and child labels
ANoutfilepath = '/Volumes/GoogleDrive/My Drive/research/vocalisation/Pre_registration_followu/Data/HUMLabelData/EafLabels/ANannot/';
CHNoutfilepath = '/Volumes/GoogleDrive/My Drive/research/vocalisation/Pre_registration_followu/Data/HUMLabelData/EafLabels/CHNannot/';

for i = 1:numel(AllEafTxtfiles) %go through files
    
    TimeIdCounter = 0; %initialise counter variables for each type of extracted info
    ChnAnnotTimeCounter = 0;
    ChnAnnotCounter = 0;
    AdultAnnotTimeCounter = 0;
    AdultUttDirecCounter = 0;
    
    fileID = fopen(AllEafTxtfiles(i).name); %get file id for each file
    
    TierID = 'NA'; %Initialise TierID as well as other cell arrays
    TimeId = {};
    TimeVal = [];
    StartTimeIdChn = {};
    EndTimeIdChn = {};
    ChnAnnot = {};
    StartTimeIdAdult = {};
    EndTimeIdAdult = {};
    AdultUttDir = {};
    ChnStartTime = [];
    ChnEndTime = [];
    AdultStartTime = [];
    AdultEndTime = [];
    
    FileNameRoot = strrep(AllEafTxtfiles(i).name,'EAF.txt',''); %get file name root
    
    %make file names for adult and child files 
    AdultFileName = strcat(FileNameRoot,'_AdultUttDirHumAnnot.csv');
    ChnFileName = strcat(FileNameRoot,'_InfVocTypeHumAnnot.csv');
    
    while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks
        
        myline = fgetl(fileID); %goes through line by line
        
        if (contains(myline,'<TIME_SLOT TIME_SLOT_ID'))...
                &&(contains(myline,'TIME_VALUE="')) %check for lines with time id and time value
            
            TimeIdCounter = TimeIdCounter + 1; %count if true
            
            %replace non-time id parts of the string with '' (strrep does
            %this)
            TimeIdStr = strrep(myline,'<TIME_SLOT TIME_SLOT_ID="','');
            TimeIdTemp = strsplit(TimeIdStr,'" TIME_VALUE'); %Splits the string where thsi substring occurs
            TimeId{TimeIdCounter,1} = strtrim(TimeIdTemp{1}); %store the first part in a cell array after removing leading and
            %trailing white space
            
            %similarly for time value
            TimeValTemp = strsplit(myline,'TIME_VALUE="');
            TimeVal(TimeIdCounter,1) = str2double(strrep(TimeValTemp{2},'"/>',''));
            
        end
        
        
        %get tier type
        if (contains(myline,'LINGUISTIC_TYPE_REF'))...
            && (contains(myline,'TIER_ID="Infant Voc Type">'))%if containes tier identifying string
            %AND Infant Voc Type
            
            TierID = 'InfVoc';
            
        elseif (contains(myline, 'LINGUISTIC_TYPE_REF'))...
                && (contains(myline, 'TIER_ID="Adult Utterance Dir')) %similat for  
            %adult utterance direction  default-lt" TIER_ID="Adult Utterance Direction"
            %This is used because some files have 'Adult Utterance Dir'
            %instead of 'Adult Utterance Direction'
            
            TierID = 'AdultUtt';
            
        elseif (contains(myline, 'LINGUISTIC_TYPE_REF'))...
                && (contains(myline, 'TIER_ID="'))...
                &&(~contains(myline,{'Infant Voc Type','Adult Utterance Dir'}))
            %This is if there is a tier block identifying line but neither
            %infant voc type or adult utterance direction. So, by defaultm
            %TierID is NA, it will change to InfVoc at the start of that
            %tier block, revert to NA at teh start of the next non-infant,
            %non-adult utterance direction tier block, and change to
            %AdultUtt at the start of adult utterance directuon block
            
            TierID = 'NA';
            
        end
        
        %Now, check for what tier we are in and go from there
        if strcmp(TierID,'InfVoc')==1 %if in infant voc tier
            
            if (contains(myline,'TIME_SLOT_REF1="')) && (contains(myline,'TIME_SLOT_REF2="'))
                %If the time id for annotation line, proceed

                ChnAnnotTimeCounter = ChnAnnotTimeCounter + 1;

                %splice line as needed and replce substrings we don't need by '', to get start time
                %id and end time id
                StartTimeTemp = strsplit(myline,'TIME_SLOT_REF1="');
                StartTimeTemp = strsplit(StartTimeTemp{2},'" TIME_SLOT_REF2="');
                StartTimeIdChn{ChnAnnotTimeCounter,1} = StartTimeTemp{1};
                EndTimeIdChn{ChnAnnotTimeCounter,1} = strrep(StartTimeTemp{2},'">','');

            elseif (contains(myline,'<ANNOTATION_VALUE'))%if contains actual annotation value
                
                ChnAnnotCounter = ChnAnnotCounter + 1;
                
                %Replace substrings we don't need
                AnnotStr = strrep(myline,'<ANNOTATION_VALUE>','');
                ChnAnnot{ChnAnnotCounter,1} = strtrim(strrep(AnnotStr,'</ANNOTATION_VALUE>',''));%Replace </ANNOTATION_VALUE> with blank and extract annotation

            end
            
        elseif strcmp(TierID,'AdultUtt')==1 %if in adult utt direc tier, proceed similarly
            
            if (contains(myline,'TIME_SLOT_REF1="')) && (contains(myline,'TIME_SLOT_REF2="'))

                AdultAnnotTimeCounter = AdultAnnotTimeCounter + 1;

                %splice line as needed and replce substrings we don't need by '', to get start time
                %id and end time id
                StartTimeTemp = strsplit(myline,'TIME_SLOT_REF1="');
                StartTimeTemp = strsplit(StartTimeTemp{2},'" TIME_SLOT_REF2="');
                StartTimeIdAdult{AdultAnnotTimeCounter,1} = StartTimeTemp{1};
                EndTimeIdAdult{AdultAnnotTimeCounter,1} = strrep(StartTimeTemp{2},'">','');
                
            elseif (contains(myline,'<ANNOTATION_VALUE'))%if contains actual annotation value
                
                AdultUttDirecCounter = AdultUttDirecCounter + 1;

                %Replace substrings we don't need
                AnnotStr = strrep(myline,'<ANNOTATION_VALUE>','');
                AdultUttDir{AdultUttDirecCounter,1} = strtrim(strrep(AnnotStr,'</ANNOTATION_VALUE>',''));
                
            end            
        end        
    end 
    
    %Nect round of clean uo: Here, we will match time id's to actual start and
    %end times, clean up adult utterance direction (some entries have actual
    %transcription, like 'love' and 'dila', instead of just the utterance
    %direction) and also (just in casE) make sure that the infant voc type is
    %cleaned up. We will then write three output files: infant voc type file with
    %start and end times, voc type, and duration; and adult utterance direction
    %file with start and end times, duration, and adult utterance
    %direction
    
    %To check if there are any weird numbers
    %[i numel(TimeId) numel(StartTimeIdChn) numel(StartTimeIdAdult)]
    %[i (numel(StartTimeIdChn)-numel(EndTimeIdChn))+(numel(StartTimeIdChn)-numel(ChnAnnot))...
        %(numel(StartTimeIdAdult)-numel(EndTimeIdAdult))+(numel(StartTimeIdAdult)-numel(AdultUttDir))]
    
    %Child file: get actual time values for start and end time ids
    for ii = 1:numel(ChnAnnot)
        for j = 1:numel(TimeId)
            if strcmp(TimeId{j},StartTimeIdChn{ii}) == 1
                ChnStartTime(ii,1) = TimeVal(j);
            end
            
            if strcmp(TimeId{j},EndTimeIdChn{ii}) == 1
                ChnEndTime(ii,1) = TimeVal(j);
            end
        end
    end
    
    %write table
    T_Chn = table(ChnStartTime,ChnEndTime,ChnAnnot);
    toDelete = ismember(T_Chn.ChnAnnot,{'R','X','L','C'}) == 0; %if there are annotations other than the 4 allowed types
    T_Chn(toDelete,:) = []; %remove those rows
    
    %Adult File
    for ii = 1:numel(AdultUttDir)
        for j = 1:numel(TimeId)
            if strcmp(TimeId{j},StartTimeIdAdult{ii}) == 1
                AdultStartTime(ii,1) = TimeVal(j);
            end
            
            if strcmp(TimeId{j},EndTimeIdAdult{ii}) == 1
                AdultEndTime(ii,1) = TimeVal(j);
            end
        end
    end
    
    %write table
    T_Ad = table(AdultStartTime,AdultEndTime,AdultUttDir);
    toDelete = ismember(T_Ad.AdultUttDir,{'T','N','U'}) == 0; %if there are annotations other than the 3 allowed types
    T_Ad(toDelete,:) = []; %remove those rows
    
    %save to file
    writetable(T_Chn,strcat(CHNoutfilepath,ChnFileName));
    writetable(T_Ad,strcat(ANoutfilepath,AdultFileName));
    
end



