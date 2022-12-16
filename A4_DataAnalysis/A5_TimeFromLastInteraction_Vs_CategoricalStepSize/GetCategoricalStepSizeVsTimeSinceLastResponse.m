function [NonInterveningStruct,InterveningStruct] = GetCategoricalStepSizeVsTimeSinceLastResponse(StartTime,EndTime,SpeakerLabels,AnnotationLabel,...
                                            SectionNum,Type1,ChildID,ChildAgeDays,ChildAgeMonths)

%Ritwika VPS
%This function computes the vector of what I call 'categorical' step sizes for now (ie, whether infant vocs go from X to C, C to X, or remains the same type)
% as a function of time since the last interaction from the adult speaker type. We can optionally repeat this for LENA labelled data
% for CHNSP vs CHNNSP. This is, however, not equivalent to X and C types. Rather, the equivalent types would be (X,C) and (R,L), respectively. 

%For the purposes of this function, we will assign a avlue of 1 to C type vocs (for LENA labels, CHNSP type vocs would be assigned a value of 1
%and correspondingly, for the human labelled data, the [X,C] class of vocs would be assigned a value of 1 if we were to test for transitions between
%speech related and non-speech related vocs), and 0 for X type vocs (or for CHNNSP vocs foe LENA labels or for [R,L] class of vocs for human labelled
%data, to test for transitions between speech and non-speech related vocs. Thus, X -> C transitions would be +1, C -> X would be -1, and X -> X and
% C -> C would be 0. Note that this can only be done for the infant as the target speaker and the adult speaker type as the Other speaker

%Also note that we will have two seperate classes of outputs: a set fo step sizes as a fucntion of time since last response, and anOther set of step
%sizes for vocs with an intervening response, as a function of time to response from the first voc and time from the respone to the next voc

%We set this up such that time from last response is computed from the end
%of the last Other voc type to the start of the ith Speaker voc in
%computing step sizes (i.e., from ith to i+1th voc)

%The output is 2 structures containing:
    %- For step sizes without an intervening Other voc type:
        %TimeSinceLastResponse, and corresponding categorical step as well as corresponding intervicalisation intervals + child
        %id and age
    %- for step sizes WITH an intervening Other voc type: similar
        %categorical step sizes, corresponding intervocalisation intervals, 
        %and the time from the end of the first Speaker voc to teh
        %start of the intervening Other voc (TimeToResponse) and time from
        %the end of the intervening Other voc to the start of the second
        %Speaker voc (TimeFromResponse) +  child id and age

%The inputs are: Start and End times; speaker labels for the recording (or subrecording or 5 minute section), where CHN
%and AN vocs are presented as a single vector; the annotation labels (T, U, N, C, etc) for human labelled data (this can be empty for LENA labels),
%and the vector of section numbers; as well as the string identifying the voc type assigned 1 (Type1, eg. C). The voc type assigned type 0 gets 0 assigned
% by default (see below); and finally infant id, age in days, and age in months, the last being optional

TargetSpeaker = 'CHN'; %define target speaker type and Other speaker type
OtherSpeaker ='AN';

%initialise results
NonInterveningStruct.TimeSinceLastResponse = [];
NonInterveningStruct.CategoricalStep = [];
NonInterveningStruct.IntervocInt = [];

InterveningStruct.TimeToResponse = [];
InterveningStruct.TimeFromResponse = [];
InterveningStruct.CategoricalStep = [];
InterveningStruct.IntervocInt = [];

%sort all the vectors by start time (this should have already been done,
%but this is to make sure this is the case)
[StartTime,SortI] = sort(StartTime);
EndTime = EndTime(SortI);
SpeakerLabels = SpeakerLabels(SortI);
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

IndVec = 1:numel(StartTime); %Index vector
OtherInd = IndVec(contains(SpeakerLabels,OtherSpeaker)); %pick out indices for Other speakeer
if ~isempty(OtherInd) %if only there are OTHER type vocs
    
    CurrOtherEnd = EndTime(OtherInd(1)); %get end time and section number for the first Other voc
    CurrOtherSectionNum = SectionNum(OtherInd(1));
    
    NonIntervening_Ctr = 0;
    Intervening_Ctr = 0;
    
    for i = OtherInd+1:numel(StartTime)-1 %OtherInd is the indes corresponding to the Other voc type in question, so we only need check from the
        %next index for the Speaker type
    
        %if the next voc and the voc after that is Speaker type, then there is
        %a step size, as long as the first Speaker type voc starts at or after
        %the end of the current Other type; also make sure that everything is
        %in the same section
        if (contains(SpeakerLabels{i},TargetSpeaker)) && (contains(SpeakerLabels{i+1},TargetSpeaker))...
                && (StartTime(i) >= CurrOtherEnd) && (SectionNum(i+1) == SectionNum(i)) && (SectionNum(i+1) == CurrOtherSectionNum)
    
            NonIntervening_Ctr = NonIntervening_Ctr + 1;
    
            NonInterveningStruct.TimeSinceLastResponse(NonIntervening_Ctr,1) = StartTime(i)-CurrOtherEnd;
            NonInterveningStruct.CategoricalStep(NonIntervening_Ctr,1) =  NumericVocType(i+1) - NumericVocType(i);
            NonInterveningStruct.IntervocInt(NonIntervening_Ctr,1) =  StartTime(i+1) - EndTime(i);
            
        elseif contains(SpeakerLabels{i},OtherSpeaker) %if the voc is Other type, reset the CurrOtherEnd variable
    
            CurrOtherEnd = EndTime(i);
            CurrOtherSectionNum = SectionNum(i);
    
            %now check if the Other voc is straddles by two Speaker vocs. We
            %only allow this as an intervening Other type vocalisation IF the
            %the imediately preceding and immediately following vocs are
            %Speaker types AND IF the preceding voc ends at or before the start
            %of the current Other type and the following voc starts at or after
            %the end of the current Other type; also make sure that everything
            %is in the same section
            if (contains(SpeakerLabels{i-1},TargetSpeaker)) && (contains(SpeakerLabels{i+1},TargetSpeaker))...
                    && (EndTime(i-1) <= StartTime(i)) && (StartTime(i+1) >= EndTime(i))...
                    && (SectionNum(i+1) == SectionNum(i)) && (SectionNum(i-1) == SectionNum(i))
                
                Intervening_Ctr = Intervening_Ctr + 1;
    
                InterveningStruct.TimeToResponse(Intervening_Ctr,1) = StartTime(i)-EndTime(i-1);
                InterveningStruct.TimeFromResponse(Intervening_Ctr,1) = StartTime(i+1)-EndTime(i);
                InterveningStruct.CategoricalStep(Intervening_Ctr,1) =  NumericVocType(i+1) - NumericVocType(i-1);
                InterveningStruct.IntervocInt(Intervening_Ctr,1) = StartTime(i+1)-EndTime(i-1);
    
            end   
        end
    end

    %add child id and age to all structres
    NonInterveningStruct.ChildID = cell(size(NonInterveningStruct.TimeSinceLastResponse));
    [NonInterveningStruct.ChildID{:}] = deal(cell2mat(ChildID));
    NonInterveningStruct.ChildAgeDays = ChildAgeDays*ones(size(NonInterveningStruct.TimeSinceLastResponse));
    
    InterveningStruct.ChildID = cell(size(InterveningStruct.TimeToResponse));
    [InterveningStruct.ChildID{:}] = deal(cell2mat(ChildID));
    InterveningStruct.ChildAgeDays = ChildAgeDays*ones(size(InterveningStruct.TimeToResponse));
    
    if nargin == 9 %if there is a childagemonth input, add months to the output
        NonInterveningStruct.ChildAgeMonths = ChildAgeMonths*ones(size(NonInterveningStruct.TimeSinceLastResponse));
        InterveningStruct.ChildAgeMonths = ChildAgeMonths*ones(size(InterveningStruct.TimeToResponse));
    end
end

