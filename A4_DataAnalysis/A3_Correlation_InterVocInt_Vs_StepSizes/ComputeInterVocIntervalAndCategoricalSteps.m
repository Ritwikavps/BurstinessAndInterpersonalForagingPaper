function [OutputStruct] = ComputeInterVocIntervalAndCategoricalSteps(StartTime,EndTime,AnnotationLabel,SpeakerLabels,SectionNum,Type1,ChildID,ChildAgeDays,ChildAgeMonths)

%Ritwika VPS, Sep 2022
%function to compute categorical steps (eg. between X and C, or CHNSP and CHNNSP) and intervocalisation
%interval. We can optionally repeat this for LENA labelled data for CHNSP vs CHNNSP. This is, however, not 
%equivalent to X and C types. Rather, the equivalent types would be (X,C) and (R,L), respectively.  

%For the purposes of this function, we will assign a avlue of 1 to C type vocs (for LENA labels, CHNSP type vocs would be assigned a value of 1
%and correspondingly, for the human labelled data, the [X,C] class of vocs would be assigned a value of 1 if we were to test for transitions between
%speech related and non-speech related vocs), and 0 for X type vocs (or for CHNNSP vocs foe LENA labels or for [R,L] class of vocs for human labelled
%data, to test for transitions between speech and non-speech related vocs. Thus, X -> C transitions would be +1, C -> X would be -1, and X -> X and
%C -> C would be 0. Note that this can only be done for the infant as the target speaker and the adult speaker type as the Other speaker

%The inputs are: Start and End times; speaker labels for the recording (or subrecording or 5 minute section), where CHN
    %and AN vocs are presented as a single vector; the annotation labels (T, U, N, C, etc) for human labelled data (this can be empty for LENA labels),
    %and the vector of section numbers; as well as the string identifying the voc type assigned 1 (Type1, eg. C). The voc type assigned type 0 gets 0 assigned
    % by default (see below); and finally infant id, age in days, and age in months

%output: structure with vectors of categorical steps and corresponding intervocalisation intervals,accounting for the fact that steps between subrecordings or sections
    %should not be counted; as well as vectors of child age in months and
    %days, and a cell array with the child id. These last three all have
    %the same number of elements as the vectors of categorical steps and
    %ibntervoc interval

%Note that diff does (i+1)-i.I always forget this and always need to check this!!! 

%sort all the vectors by start time (this should have already been done,
%but this is to make sure this is the case)
[StartTime,SortI] = sort(StartTime);
EndTime = EndTime(SortI);
SectionNum = SectionNum(SortI);

%recast AnnotationLabel vector as a vector of 1's and 0's
if ~isempty(AnnotationLabel) %if there is a non-empty AnnotationLabel, this is human listener data
    AnnotationLabel = AnnotationLabel(SortI);
    NumericVocType = zeros(size(AnnotationLabel));
    NumericVocType(contains(AnnotationLabel,Type1)) = 1;
else %if not, thsi is LENA data
    NumericVocType = zeros(size(SpeakerLabels));
    NumericVocType(contains(SpeakerLabels,Type1)) = 1;
end

UniqSectionNum = unique(SectionNum); %get unqiue section numbers

CategoricalStep_vec = []; %iniitialsie outputs (column vector)
InterVocInterval_vec = [];

for i = 1:numel(UniqSectionNum) %go through unique section numbers
    
    StartTimeTemp = StartTime(SectionNum == UniqSectionNum(i));
    EndTimeTemp = EndTime(SectionNum == UniqSectionNum(i));

    CategoricalStep_vec = [CategoricalStep_vec; abs(diff(NumericVocType(SectionNum == UniqSectionNum(i))))]; %get categorical steps for ith section number
    InterVocInterval_vec = [InterVocInterval_vec;  StartTimeTemp(2:end) - EndTimeTemp(1:end-1)];

end

%recast empty matrices as []; this is because sometimes Steps2D_vec is cast ac
%1x0 but intervoc interval is cast as 0x0 (or vice-versa) and this creates
%a problem for cell2mat-ing them
if isempty(CategoricalStep_vec)
    CategoricalStep_vec  = [];
end
if isempty(InterVocInterval_vec)
    InterVocInterval_vec = [];
end

%check if there are negative intervoc interval values
if ~isempty(InterVocInterval_vec(InterVocInterval_vec < 0))
    disp('what is going on')
end

%check if size of all step sizes is the same
if ~isequal(size(CategoricalStep_vec),size(InterVocInterval_vec)) 
    error('Size of vectors of step sizes and/or intervoc interval do not match')
end

%put o/p into struicture
OutputStruct.CategoricalSteps = CategoricalStep_vec;
OutputStruct.InterVocInterval = InterVocInterval_vec;

%get age and id
OutputStruct.ChildAgeMonth = ChildAgeMonths*ones(size(InterVocInterval_vec));
OutputStruct.ChildAgeDays = ChildAgeDays*ones(size(InterVocInterval_vec));
ChildId_vec = cell(size(InterVocInterval_vec));
[ChildId_vec{:}] = deal(ChildID);
OutputStruct.ChildId = ChildId_vec;

%Note that we aren't removing NaN values