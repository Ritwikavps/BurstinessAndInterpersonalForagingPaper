function [NonInterveningStruct,InterveningStruct,NonStSizeStruct] = ...
    GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amplitude,StartTime,EndTime,SpeakerLabels,SectionNum,TargetSpeaker,OtherSpeaker,...
    ChildID,ChildAgeDays,ChildAgeMonths)

%Ritwika VPS
%This function computes the vector of non-directional step sizes (pitch, duration, and amplitude steps,
%as well inter vocalisation internval), 2d and 3d acoustic space step sizes,  and acoustic measures (pitch, duration, amplitude) 
%as a function of time since last response. We also get the difference in
%pitch, amplitude, and duration (directional and non-directions; teh former tells us whether explorayion is diffused or focused
% while the latter tells us how duration changes wrt the last 'response')
% between the last response and the currenyt Speaker type voc as a function 
% of the time since the last response. We start at the first instance of the
%'Other' vocalisation, since we can't be sure about when the last 'Other'
%type voc was prior to this. 

%Also note that we will have two seperate classes of outputs: a set fo step
%sizes as a fucntion of time since last response, and anOther set of step
%sizes for vocs with an intervening response, as a function of time to
%response from the first voc and time from the respone to the next voc

%We set this up such that time from last response is computed from the end
%of the last Other voc type to the start of the ith Speaker voc in
%computing step sizes (i.e., from ith to i+1th voc)

%The output is 3 structures containing:
    %- For step sizes without an intervening Other voc type:
        %TimeSinceLastResponse, directional (not abs. value) steps in pitch, amplitude and duration
        %(identifiable as PitchStepNonIntervening, etc.), and the
        %intervocalisation interval (IntVocIntNonIntervening)
    %- for step sizes WITH an intervening Other voc type: similar step size
        %and intervoc interval vectors (identifiable as PitchStepIntervening,
        %etc.) and the time from the end of the first Speaker voc to teh
        %start of the intervening Other voc (TimeToResponse) and time from
        %the end of the intervening Other voc to the start of the second
        %Speaker voc (TimeFromResponse)
    %- for non-step size acoustic variables as well as steps wrt the last response: time since last Other type voc
        %(TimeSinceLastResponseForAcousticVars) and the acoustics variables
        %pitch, amplitude, and duration (PitchVar, etc.), as well as
        %directional steps in pitch, amplitude and duration wrt to the last
        %response

%The inputs are: Pitch, Amplitude, Start and End times, speaker
%labels for the recording (or subrecording or 5 minute section), where CHN
%and AN vocs are presented as a single vector, and the vector of section numbers; as well as the string
%identifying the speaker (TargetSpeaker, eg. 'CHN') and the other speaker
%(OtherSpeaker, eg. 'AN'); and finally infant id, age in days, and age in
%months, the last being optional

%initialise results
NonInterveningStruct.TimeSinceLastResponse = [];
NonInterveningStruct.AmpStep = [];
NonInterveningStruct.PitchStep = [];
NonInterveningStruct.DurStep = [];
NonInterveningStruct.IntVocInt = [];


InterveningStruct.TimeToResponse = [];
InterveningStruct.TimeFromResponse = [];
InterveningStruct.PitchStep = [];
InterveningStruct.AmpStep = [];
InterveningStruct.DurStep = [];
InterveningStruct.IntVocInt = [];


NonStSizeStruct.TimeSinceLastResponse = [];
NonStSizeStruct.PitchVar = [];
NonStSizeStruct.AmpVar = [];
NonStSizeStruct.DurationVar = [];
NonStSizeStruct.PitchStepFromLastResponse = []; %these step sizes are about step sizes with respect to the acoustic dimensions of the
%Response, that is, it is current speaker type - last OTHER type response
NonStSizeStruct.AmpStepFromLastResponse = [];
NonStSizeStruct.DirectionalDurStepFromLastResponse = [];

%sort all the vectors by start time (this should have already been done,
%but this is to make sure this is the case)
[StartTime,SortI] = sort(StartTime);
Pitch = Pitch(SortI);
Amplitude = Amplitude(SortI);
EndTime = EndTime(SortI);
SpeakerLabels = SpeakerLabels(SortI);
Duration = EndTime-StartTime;
SectionNum = SectionNum(SortI);

IndVec = 1:numel(Pitch); %Index vector
OtherInd = IndVec(contains(SpeakerLabels,OtherSpeaker)); %pick out indices for Other speakeer
if ~isempty(OtherInd) %if only there are OTHER type vocs
    
    CurrOtherEnd = EndTime(OtherInd(1)); %get end time and section number for the first Other voc
    CurrOtherSectionNum = SectionNum(OtherInd(1));
    CurrOtherEnd_Copy = EndTime(OtherInd(1)); %Make copies for the second for loop below
    CurrOtherSectionNum_Copy = SectionNum(OtherInd(1));
    
    NonIntervening_Ctr = 0;
    Intervening_Ctr = 0;
    
    for i = OtherInd+1:numel(Pitch)-1 %OtherInd is the indes corresponding to the Other voc type in question, so we only need check from the
        %next index for the Speaker type
    
        %if the next voc and the voc after that is Speaker type, then there is
        %a step size, as long as the first Speaker type voc starts at or after
        %the end of the current Other type; also make sure that everything is
        %in the same section
        if (contains(SpeakerLabels{i},TargetSpeaker)) && (contains(SpeakerLabels{i+1},TargetSpeaker))...
                && (StartTime(i) >= CurrOtherEnd) && (SectionNum(i+1) == SectionNum(i)) && (SectionNum(i+1) == CurrOtherSectionNum)
    
            NonIntervening_Ctr = NonIntervening_Ctr + 1;
    
            NonInterveningStruct.TimeSinceLastResponse(NonIntervening_Ctr,1) = StartTime(i)-CurrOtherEnd;
            NonInterveningStruct.AmpStep(NonIntervening_Ctr,1) = abs(Amplitude(i+1) - Amplitude(i));
            NonInterveningStruct.PitchStep(NonIntervening_Ctr,1) = abs(Pitch(i+1) - Pitch(i));
            NonInterveningStruct.DurStep(NonIntervening_Ctr,1) = abs(Duration(i+1)-Duration(i));
            NonInterveningStruct.IntVocInt(NonIntervening_Ctr,1) = StartTime(i+1)-EndTime(i);
            
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
                InterveningStruct.PitchStep(Intervening_Ctr,1) = abs(Pitch(i-1) - Pitch(i+1));
                InterveningStruct.AmpStep(Intervening_Ctr,1) = abs(Amplitude(i+1) - Amplitude(i-1));
                InterveningStruct.DurStep(Intervening_Ctr,1) = abs(Duration(i+1)-Duration(i-1)); 
                InterveningStruct.IntVocInt(Intervening_Ctr,1) = StartTime(i+1)-EndTime(i-1);
    
            end   
        end
    end
    
    %Now, repeat for non-step size variables (pitch, amplitude, and duration
    NonStep_Ctr = 0;
    CurrPitch = Pitch(OtherInd(1));
    CurrAmp = Amplitude(OtherInd(1));
    CurrDur = Duration(OtherInd(1));
    
    for i = OtherInd+1:numel(Pitch) %OtherInd is the indes corresponding to the Other voc type in question, so we only need check from the
        %next index for the Speaker type
    
        %if the next voc is Speaker type, and the Speaker type voc starts at or after
        %the end of the current Other type
        if (contains(SpeakerLabels{i},TargetSpeaker)) && (StartTime(i) >= CurrOtherEnd_Copy) && (SectionNum(i) == CurrOtherSectionNum_Copy)
    
            NonStep_Ctr = NonStep_Ctr + 1;
            NonStSizeStruct.TimeSinceLastResponse(NonStep_Ctr,1) = StartTime(i)-CurrOtherEnd_Copy;
            NonStSizeStruct.PitchVar(NonStep_Ctr,1) = Pitch(i);
            NonStSizeStruct.AmpVar(NonStep_Ctr,1) = Amplitude(i);
            NonStSizeStruct.DurationVar(NonStep_Ctr,1) = Duration(i);
    
            NonStSizeStruct.PitchStepFromLastResponse(NonStep_Ctr,1) = abs(Pitch(i) - CurrPitch);
            NonStSizeStruct.AmpStepFromLastResponse(NonStep_Ctr,1) = abs(Amplitude(i) - CurrAmp);
            NonStSizeStruct.DirectionalDurStepFromLastResponse(NonStep_Ctr,1) = Duration(i) - CurrDur;
    
        elseif contains(SpeakerLabels{i},OtherSpeaker) %if the voc is Other type, reset the CurrOtherEnd variable
    
            CurrOtherEnd_Copy = EndTime(i);
            CurrOtherSectionNum_Copy = SectionNum(i);
            CurrPitch = Pitch(i);
            CurrAmp = Amplitude(i);
            CurrDur = Duration(i);
            
        end
    end
    
    %add additional vars
    NonInterveningStruct.TwoDimSpaceStep = sqrt(NonInterveningStruct.PitchStep.^2 + NonInterveningStruct.AmpStep.^2);
    NonInterveningStruct.ThreeDimSpaceStep = sqrt(NonInterveningStruct.PitchStep.^2 + NonInterveningStruct.AmpStep.^2 +...
        NonInterveningStruct.DurStep.^2);
    
    InterveningStruct.TwoDimSpaceStep = sqrt(InterveningStruct.PitchStep.^2 + InterveningStruct.AmpStep.^2);
    InterveningStruct.ThreeDimSpaceStep = sqrt(InterveningStruct.PitchStep.^2 + InterveningStruct.AmpStep.^2 +...
        InterveningStruct.DurStep.^2);
    
    NonStSizeStruct.AbsDurStepFromLastResponse = abs(NonStSizeStruct.DirectionalDurStepFromLastResponse);
    NonStSizeStruct.TwoDimSpaceStep = sqrt(NonStSizeStruct.PitchStepFromLastResponse.^2 + NonStSizeStruct.AmpStepFromLastResponse.^2);
    NonStSizeStruct.ThreeDimSpaceStep = sqrt(NonStSizeStruct.PitchStepFromLastResponse.^2 + NonStSizeStruct.AmpStepFromLastResponse.^2 +...
        NonStSizeStruct.DirectionalDurStepFromLastResponse.^2);


    %add child id and age to all structres
    NonInterveningStruct.ChildID = cell(size(NonInterveningStruct.TimeSinceLastResponse));
    [NonInterveningStruct.ChildID{:}] = deal(cell2mat(ChildID));
    NonInterveningStruct.ChildAgeDays = ChildAgeDays*ones(size(NonInterveningStruct.TimeSinceLastResponse));
    
    InterveningStruct.ChildID = cell(size(InterveningStruct.TimeToResponse));
    [InterveningStruct.ChildID{:}] = deal(cell2mat(ChildID));
    InterveningStruct.ChildAgeDays = ChildAgeDays*ones(size(InterveningStruct.TimeToResponse));
    
    NonStSizeStruct.ChildID = cell(size(NonStSizeStruct.PitchVar));
    [NonStSizeStruct.ChildID{:}] = deal(cell2mat(ChildID));
    NonStSizeStruct.ChildAgeDays = ChildAgeDays*ones(size(NonStSizeStruct.PitchVar));

    if nargin == 11 %if there is a childagemonth input, add months to the output
        NonInterveningStruct.ChildAgeMonths = ChildAgeMonths*ones(size(NonInterveningStruct.TimeSinceLastResponse));
        InterveningStruct.ChildAgeMonths = ChildAgeMonths*ones(size(InterveningStruct.TimeToResponse));
        NonStSizeStruct.ChildAgeMonths = ChildAgeMonths*ones(size(NonStSizeStruct.PitchVar));
    end
end