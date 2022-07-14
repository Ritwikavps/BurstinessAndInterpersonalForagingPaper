function TierInfoTable = ParseEafFiles(EafFileName,FilesFromR_dir)

%Ritwika VPS, June 2022
%code to get table after parsing eaf file 
%contains local functions

%inputs: eaf file name and structure with list of files (and details) from
        %R code
%output: table with Start and end time slot refs, line numbers, and time
        %values; annotation id and line num; annotation and line number;
        %tier id and eaf file name

%first get the time refs and time values 
[TimeSlotRef,TimeVal] = GetEafTimeRefTimeValue(EafFileName);

%get details of annotations from .eaf files
TierInfoTable = GetAnnotationDetails(EafFileName);

%                     size(TierInfoTable) %for debugging

%match time slot refs to actual tiem values
[StartTime,EndTime] = MatchAnnotTimeRefToTime(TierInfoTable.StartTimeRef,TierInfoTable.EndTimeRef,TimeSlotRef,TimeVal);

%append to table
TierInfoTable.StartTimeVal = StartTime;
TierInfoTable.EndTimeVal = EndTime;
%                     size(TierInfoTable) %for debugging

%name for the new table
FnEafRemoved = strrep(EafFileName,'EAF.txt','_fromMATLAB.csv'); %the addition of _fromMATLAB.csv is a relic from when I was saving these files. I then
%realised I don't need to

for rr = 1:numel(FilesFromR_dir) %go through structure with info about files from R code
    FnString_R = strrep(FilesFromR_dir(rr).name,'.csv',''); %get file name root string from R .csv file
    if contains(FnEafRemoved,FnString_R) == 1 %check if file name roots match
        R_table = readtable(FilesFromR_dir(rr).name,'Delimiter',','); %get R table
        if ~isequal(TierInfoTable,R_table) %check if thety are equal
            fprintf('Tables from R code %s and Matlab code %s are not the same \n',FilesFromR_dir(rr).name,FnEafRemoved)       
        else
            %fprintf('Tables from R code %s and Matlab code %s match \n',FilesFromR_dir(rr).name,FnEafRemoved)
        end
    end
end

%I have verified that R and MATLAB output the same files with the same info

%finally, add a column with the filename
Fname = cell(size(TierInfoTable.StartTimeRef));
[Fname{1:end}] = deal(strrep(EafFileName,'EAF.txt',''));
TierInfoTable.EafFname = Fname;   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local function 1: gets time ref and time value from the block before the
        %annotations block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [TimeSlotRef,TimeVal] = GetEafTimeRefTimeValue(EafFileName)

%gets time slot refs and time slot values from .eaf file, given EafFileName

%inputs: Eaf file name
%outputs: vectors of time slot refs and corresponding time values

TSref_ctr = 0; %initialise counter

fileID = fopen(EafFileName); %get file id for each file

while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks
    
    myline = strtrim(fgetl(fileID)); %goes through line by line

    if contains(myline,'<TIME_SLOT TIME_SLOT_ID="') %id if target string is in line

        %get time slot ref
        TSref_ctr = TSref_ctr + 1;

        %first, sub <TIME_SLOT TIME_SLOT_ID=" with empty, then ssplit the string at " TIME_VALUE="
        %, get the first part, and finally.
        TimeSlotRefTemp = strrep(myline,'<TIME_SLOT TIME_SLOT_ID="','');
        TimeSlotRefTempSplit = strsplit(TimeSlotRefTemp,'" TIME_VALUE="');
        TimeSlotRef{TSref_ctr,1} = strtrim(TimeSlotRefTempSplit{1});
      
        %get corresponding time
        %remove everything up to .*" TIME_VALUE=", then remove "/>', and convert to numeric
        TimeValTemp = strsplit(myline,'" TIME_VALUE="');
        TimeVal(TSref_ctr,1) = str2double(strtrim(strrep(TimeValTemp{2},'"/>','')));

    end
end

fclose('all'); %explicitly close opened file and any other open connections

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local function 2: gets annotation details from the annotations block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [AnnotDetailsTable] = GetAnnotationDetails(EafFileName)

%Ritwika VPS, June 2022
%gets annotation details from .eaf file, given EafFileName

%list of key tiers
KeyTierList = {'Infant Voc Type','Adult Utterance Dir','Adult Ortho'}; %Key tiers are : 'Infant Voc Type', 'Adult Utterance Dir' 
% (because some files only have this much of the string),
% 'Adult Ortho' (for the orthograohic transcription tier; some files only have 'Adult Orthographic' in this tier label)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%we do this in three blocks: first, we identify all the tiers in the file, then we identify the line numbers associated with the
%start and end of each annotation tier, and then, we parse out annotation details in each tier
%first, establish a connection (which is an interface to the file) to the desires .eaf file

%id all tier IDs
TierIdIndexNum = 0; %initialise index variable for vector to store tier IDs
TierIdVec = {}; %cell array to store available tier ids

fileID = fopen(EafFileName); %get file id for each file

while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks

    myLine = strtrim(fgetl(fileID)); %goes through line by line
    
    %time slot ref and time matching block
    if (contains(myLine,'LINGUISTIC_TYPE_REF="')) && (contains(myLine,'TIER_ID="'))
    
        %get tier id for the tier
        TierIdCurrent = regexprep(regexprep(myLine,'.*TIER_ID="',''),'">',''); %replace everything berore TIER_ED=" and in the
        %remaining string, ">, with blank
        
        %check if the tier id has already been stored (and that it is not the default id)
        if (sum(contains(TierIdVec,TierIdCurrent)) == 0) && (~(contains(TierIdCurrent,'default','IgnoreCase',true)))%checks if the current tier id is already in the vector of tier ids present in the file
            %TierIdCurrent %in% TierIdVec checks this. We only proceed if it isn't present, that is, if this condition is FALSE. 
            %Or, alternatively, if the negatve of this condition is true
            %we also don't want to include the defauilt tier, so that is the second condition (only proceed if current tier id does not conatin 'default')
    
            %update vector and counter variable
            TierIdIndexNum = TierIdIndexNum + 1;
            TierIdVec{TierIdIndexNum} = regexprep(regexprep(myLine,'.*TIER_ID="',''),'".*','');

        end
    end
end

fclose(fileID); %explicitly close opened file


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Now we loop over the tiers, get start and end line num for the tier, and
%get annotation details for each tier based on that

%assign empty vectors in case the tier doesn't exist so there is still an
%o/p (also initialise counter variables)
StartTimeRef = [];
StartTimeLineNum = [];
StartTime_ctr = 0;
EndTimeRef = [];
EndTimeLineNum = [];
EndTime_ctr = 0;
AnnotId = [];
AnnotIdLineNum = [];
AnnotId_ctr = 0;
Annotation = [];
AnnotationLineNum = [];
Annotation_ctr = 0;
TierTypeVec = []; %vector with the tier type string repeated

for ii = 1:numel(TierIdVec)

    TierIdQuery = TierIdVec{ii};

    %initialise line number
    LineNum = 0;
    ExistTierStartLineNum = 0; %flag for if start of tier line number variable exists
    ExistTierEndLineNum = 0;

    fileID = fopen(EafFileName); %get file id for each file
    
    while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks
        
        myLine = strtrim(fgetl(fileID)); %goes through line by line
    
        LineNum = LineNum + 1; %update line number
    
        %time slot ref and time matching block
        if contains(myLine,TierIdQuery)
    
            TierStartLineNum = LineNum; %get line number at which desired tier starts 
            ExistTierStartLineNum = 1; %turn flag on
    
        elseif (ExistTierStartLineNum == 1) && (contains(myLine,TierIdQuery) == 0) && (contains(myLine,'LINGUISTIC_TYPE_REF="'))
          
          %These conditions make it so that this block is only executed if there is a value 
          %asisgned to TierStartLineNum, AND if the line is the start of a new Tier ID
          %('<TIER LINGUISTIC_TYPE_REF="' check), AND if said new Tier is not the desired Tier.
          %This makes it so that this will only be triggered at the tier after the start of the 
          %desired tier
          %we make sure that we don't go past this next tier by terminating the repeat loop after this
          %elseif condition is satisfied
          %we use 'LINGUISTIC_TYPE_REF="' as a check because some .eaf files
          %have only this substring 
    
          TierEndLineNum = LineNum;
          ExistTierEndLineNum = 1;
    
          break
    
        end
    end
    
    %if TierEndLineNum doesn't exist, that's because the tier correpsonding to
    %Tier Id inquiry is the last tier. In that case, assign TierEndLineNum to
    %the last line in the file
    if ExistTierEndLineNum == 0
        TierEndLineNum = LineNum;
    end
    
    fclose(fileID); %explicitly close opened file
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Now that we have the start and end line numbers of the desired tier, we can work on 
    %getting the annotation details
    
    %This may not be the most efficient way to do this, but this is how I wrote the R code,
    %and I want to stay as close to it as possible to check if it is working correctly
    
    LineNum = 0;
    
    fileID = fopen(EafFileName); %get file id for each file
    
    while ~feof(fileID) %while loop terminated at end of file, so this goes on till the end of file or otherwise breaks
        
        myLine = strtrim(fgetl(fileID)); %goes through line by line
        LineNum = LineNum + 1; %update line number

        if LineNum >= TierStartLineNum %we will check for each type of info (time slot refs, annotation id, annotation) independelty
            %annotation ID
            %Note that if a specific condition is not satisfied in detecting each of these items,
            %the vector to store the item will be populated by NA or 0 as applicable, by default
            %This is another reason why we want to check for each item separately

            if contains(myLine,'ALIGNABLE_ANNOTATION ANNOTATION_ID="')

                AnnotId_ctr = AnnotId_ctr  + 1;
                AnnotId{AnnotId_ctr,1} = regexprep(regexprep(myLine,'" TIME_SLOT_REF1=".*',''),'.*<ALIGNABLE_ANNOTATION ANNOTATION_ID="','');
                AnnotIdLineNum(AnnotId_ctr,1) = LineNum;

            end
    
            %time slot ref1
            if contains(myLine,'TIME_SLOT_REF1="' )
            
                StartTime_ctr = StartTime_ctr + 1;
                StartTimeRef{StartTime_ctr,1} = regexprep(regexprep(myLine,'.*TIME_SLOT_REF1="',''),'" TIME_SLOT_REF2=".*','');
                StartTimeLineNum(StartTime_ctr,1) = LineNum;

            end

            %time slot ref2
            if contains(myLine,'TIME_SLOT_REF2="' )
            
                EndTime_ctr = EndTime_ctr + 1;
                EndTimeRef{EndTime_ctr,1} = regexprep(regexprep(myLine,'.*TIME_SLOT_REF2="',''),'">.*','');
                EndTimeLineNum(EndTime_ctr,1) = LineNum;
                
            end
    
            %Annotation
            if contains(myLine,'<ANNOTATION_VALUE') %we ue this stribg because some files have <ANNOTATION_VALUE/>
                %instead of <ANNOTATION_VALUE>X</ANNOTATION_VALUE> where X is a sample annotation
                
                Annotation_ctr = Annotation_ctr + 1;
                Annotation{Annotation_ctr,1} = strrep(strrep(strrep(myLine,'<ANNOTATION_VALUE',''),'</ANNOTATION_VALUE>',''),'>','');
                AnnotationLineNum(Annotation_ctr,1) = LineNum;
                TierTypeVec{Annotation_ctr,1} = TierIdQuery;

            end
    
        end
    
        if (LineNum >= TierEndLineNum) %finally if we get past the line number for the tier, break
            break
        end
    end
end

%check whether the numel of starttimeref, endtimeref, annotId and annotation are the same
CtrNumCheck = abs(StartTime_ctr-EndTime_ctr) + abs(EndTime_ctr-AnnotId_ctr) + abs(AnnotId_ctr-Annotation_ctr);
if (CtrNumCheck ~= 0) %if these counter numbers are the same, implying that the number of instances
%of start times, end times, annotation ids and annotations are the same, create output dfr if else
    fprintf('mismatch in number of start time ref, end time ref, annotation id, and/or annotation in eaf file %s \n',EafFileName)
end

%check if file has key tiers
for j = 1:numel(KeyTierList)
    if isempty(cell2mat(regexp(TierIdVec,KeyTierList{j})))%if there isn't a block for desired tier, print error message
      
      fprintf('No %s tier in file %s \n',KeyTierList{j},EafFileName)

    end
end

fclose('all'); %explicitly close opened file and any other open connections

AnnotDetailsTable = table(StartTimeRef,StartTimeLineNum,EndTimeRef,EndTimeLineNum,AnnotId,AnnotIdLineNum,Annotation,AnnotationLineNum,TierTypeVec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%local function 3: Matches time refs to time values in the annotation table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [StartTimeVal,EndTimeVal] = MatchAnnotTimeRefToTime(StartTimeRef,EndTimeRef,TimeRefVec,TimeValVec)

%Ritwika VPS, June 2022
%function to metch start and end time slot refs in Tierinfodf to actual times from TimeRefTimeVal_df

%inputs: Vectors with time slot ref (TimeRefVec) and corresponding time
        %values (TimeValVec); and vectors with start time slot and end tiem slot
        %refs
%outputs: Vectors of start and end time values

StartTimeVal = zeros(size(StartTimeRef));
EndTimeVal = zeros(size(EndTimeRef));

%go through start time ref and time value vectors and match
for i = 1:numel(StartTimeRef)
    for j = 1:numel(TimeRefVec)

        %check if string matched and match; we can do this for start and end time refs in the same for loop block
        %because both have the same number of elements. But, to be extra paranoid, I am doing this in two blocks
        if strcmp(StartTimeRef{i},TimeRefVec{j})==1
            StartTimeVal(i,1) = TimeValVec(j);
        end

    end
end

%go through end time ref and time value vectors and match
for i = 1:numel(StartTimeRef)
    for j = 1:numel(TimeRefVec)

        %check if string matched and match; 
        if strcmp(EndTimeRef{i},TimeRefVec{j})==1
            EndTimeVal(i,1) = TimeValVec(j);
        end
    end
end






