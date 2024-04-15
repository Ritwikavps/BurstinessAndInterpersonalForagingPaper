function [DistTab, TotalMergeCt] = GetStepSizeTab(InputTab,SpkrType,OtherType,NAType,ResponseWindow,IviOnly)

%This function computes step size vectors and intervocalisation interval vector based on input table. It also removes step size entries associated
%with the end of a subrecording. It also outputs the total number of voc merges (when applicable) for the input table, when merging vocs of the same speaker type with 0 Ivis .

%Inputs: - InputTab: a table that contains (at the very least) columns ('logf0_z','dB_z','logDur_z','start','xEnd', 'speaker', and either 'SubrecEnd' or 'SectionNum').
        %- SpkrType, OtherType, NAType: speaker labels that correspond to the target speaker, the other speaker (responder), and the speaker type that
            % triggers an NA response. For eg, if we are looking at AN response to CHNSP, thiese would be CHNSP, AN, and CHN, respectively
        %- ResponseWIndow: the response window time (ResponseWindow) in seconds
        %- IviOnly: toggle 1 or 0 depending on whether we are only looking at Ivi (1) or both Ivi and acoustics (0).  

TotalMergeCt = NaN; %initialise as Nan; this will get updaed if we are doing the voc merge. As of now (April 14, 2024), voc merges only happen when IviOnly = 1 (because we haven't added the 
%code to process acoustics accordingly for voc merges)

%check to make sure that SpkrType, OtherType, and NAType inputs are acceptable strings
if sum(strcmpi(SpkrType,{'CHNSP','CHNNSP','CHN','AN'})) == 0
    error('Incorrect SpkrType string')
end

if sum(strcmpi(OtherType,{'CHNSP','CHNNSP','CHN','AN'})) == 0
    error('Incorrect OtherType string')
end

if sum(strcmpi(NAType,{'CHNSP','CHNNSP','CHN','AN'})) == 0
    error('Incorrect NAType string')
end

if IviOnly == 0 %set number of columns for output table
    OpNumCols = 8; %if looking at acoustics AND Ivi (extra cols: pitch, amp, duration, 2d, and 3d steps)
else
    OpNumCols = 3; %if only looking at Ivi
end   

if size(InputTab,1) <= 1  %mandatory checks ; if there is only one row, then this whole exercise is pointless.
        DistTab = array2table(zeros(0,OpNumCols)); 
    return
end

%get section number info if applicable
InputTabVarNames = InputTab.Properties.VariableNames;
if isempty(InputTabVarNames(contains(InputTabVarNames,'SectionNum'))) %if there is NO column with section num info
    InputTab.SectionNum = GetSectionNumVec(InputTab); %get section number information, and add section number information to InputTab
end

if IviOnly == 1
    [InputTab, TotalMergeCt] = MergeZeroIviVocsAndGetTSOnlyTab(InputTab); %remove acoustics (duration, pitch, amplitude), and do Ivi Processing and merging--basically, 
    %merge any vocs of the same speaker type separated by 0 IVI
end

InputTab.Response = ComputeResponseVector(InputTab.start,InputTab.xEnd,InputTab.speaker,SpkrType,OtherType,NAType,ResponseWindow); %compute response
InputTab = InputTab(contains(InputTab.speaker,SpkrType),:); %filter by speaker type

if size(InputTab,1) <= 1 %check again if the filtered inputtab is empty
    DistTab = array2table(zeros(0,OpNumCols));
    return
end
                                                    
InterVocIntVec = []; %empty vector to store intervoc intervals

%create empty table to store the rest of the info needed, after removing redundant or unnecessary cols
RestOfTab = array2table(zeros(0,2)); 
RestOfTab.Properties.VariableNames = {'SectionNum','Response'};

U_SectionNumVec = unique(InputTab.SectionNum); %get unique section numbers

if IviOnly == 0 %if looking at Ivis AND acoustics
    DistTab = array2table(zeros(0,3)); %create empty table to store distances
    DistTab.Properties.VariableNames = {'DistPitch','DistAmp','DistDuration'};
end

for i = 1:numel(unique(U_SectionNumVec)) %go through each unique section and get step sizes. This way, we don't add step sizes between subrecs

    Section_SubTab = InputTab(InputTab.SectionNum == U_SectionNumVec(i),:); %pick out rows with the same section number

    %now, if a section only has one row of elements, then we cannot compute a step size
    if size(Section_SubTab,1) >= 3 %if there are at least three rows (because, we need at least two utterance events to get a step size, and two step sizes to get one
        %set of current and previous step size)

        if IviOnly == 0 %if looking at Ivis AND acoustics
            TempTab = varfun(@diff, Section_SubTab(:,{'logf0_z','dB_z','logDur_z'}), 'OutputFormat', 'table'); %compute distances for each section
            TempTab = varfun(@abs, TempTab, 'OutputFormat', 'table'); %get absolute value
            TempTab.Properties.VariableNames = {'DistPitch','DistAmp','DistDuration'}; %    TempTab = varfun(@abs, TempTab, 'OutputFormat', 'table'); %get abs value
            DistTab = [DistTab; TempTab];
        end
    
        InterVocIntVec  = [InterVocIntVec ; Section_SubTab.start(2:end) - Section_SubTab.xEnd(1:end-1)]; %inter voc interval
    
        %get rest of the table to add to DistTab, after the end of the loop. Note that the last entry in each  column has to be removed, since this isn't going 
        %to be associated with a step size
        Section_SubTab = Section_SubTab(:,{'SectionNum','Response'});
        RestOfTab = [RestOfTab; Section_SubTab(1:end-1,:)];
    end
end

%add additional step size columns
if IviOnly == 0 %if looking at Ivis AND acoustics
    DistTab.InterVocInt = InterVocIntVec; %add inter voc interval
    DistTab.Dist2D = sqrt((DistTab.DistPitch).^2 + (DistTab.DistAmp).^2); %add 2d and 3d step sizes
    DistTab.Dist3D = sqrt((DistTab.DistPitch).^2 + (DistTab.DistAmp).^2 + (DistTab.DistDuration).^2);
    DistTab = [DistTab RestOfTab]; %plop tables together
elseif IviOnly == 1
    RestOfTab.InterVocInt = InterVocIntVec; %add inter voc interval
    DistTab = RestOfTab;
end
                                    


