function [OpVals] = GetRecLvlSummaryMeasures(DataType,SpeakerType,MeasureType,InputFname)

%This function takes an input file name (daylong LENA or 5 min human labelled sections or matched LENA sections at the recording level), 
% reads in the table, gets relevant acoustic vairables from the tables, filters by specified speaker type, and gets the specified summary measure
% for pitch, amplpitude, duration, pitch steps, amp steps, duration steps, 2d and 3d space steps, and intervoc int, while accounting for vocs from
% different subrecs or sections

%note that for now, we are only looking at CHNSP and AN speaker types. If
%you want to look at CHNNSP types, you'll have to edit the nested function GetRelevantVars

%inputs: - File name of the table to read (InputFname)
        %- Summary measure to compute (MeasureType); string
        %- Speaker tyepe we are interested in (SpeakerType); string
        %- The type of data (DataType) which specifies if the data is human labelled ('Humlabel'), matched LENA ('LENA5min'), or daylong LENA ('LENAday'); string

%outputs: - OpVals: a row vector of summary measures, in this order (Pitch Amp Duration PitchStep AmpStep DurationStep TwoDimStep ThreeDimStep IntVocInt)

InputTab = readtable(InputFname,'Delimiter',','); %read table

[Pitch,Amp,StartTime,EndTime,SpeakerLabel,SectionNum] = GetRelevantVars(InputTab,DataType); %get relevant acoustic measures from table

%get speaker specific acoustic variables
Pitch = Pitch(contains(SpeakerLabel,SpeakerType));
Amp = Amp(contains(SpeakerLabel,SpeakerType));
StartTime = StartTime(contains(SpeakerLabel,SpeakerType));
EndTime = EndTime(contains(SpeakerLabel,SpeakerType));
SectionNum = SectionNum(contains(SpeakerLabel,SpeakerType));
Duration = EndTime-StartTime;

if numel(Duration) ~= numel(Duration(Duration >= 0)) %error check
    error('Negative duration values')
end

%get step sizes by accounting for vocs from different sections or subrecs
PitchStep = [];
AmpStep = [];
IntVocInt = [];
DurationStep = [];

U_SectionNum = unique(SectionNum); %pick out unique section numbers

for i = 1:numel(U_SectionNum) %get step sizes excluding steps between different sections or subrecs
    %acoustic dim step sizes
    PitchStep = [PitchStep; abs(diff(Pitch(SectionNum == U_SectionNum(i))))]; 
    AmpStep = [AmpStep; abs(diff(Amp(SectionNum == U_SectionNum(i))))]; 
    DurationStep = [DurationStep; abs(diff(Duration(SectionNum == U_SectionNum(i))))]; 

    %inter voc int
    StartTimeTemp = StartTime(SectionNum == U_SectionNum(i));
    EndTimeTemp = EndTime(SectionNum == U_SectionNum(i));

    IntVocInt = [IntVocInt;  StartTimeTemp(2:end) - EndTimeTemp(1:end-1)];
end

%acoustic space steps
TwoDimStep = sqrt(PitchStep.^2 + AmpStep.^2);
ThreeDimStep = sqrt(PitchStep.^2 + AmpStep.^2 + DurationStep.^2);

%put all vectors into a cell array to streamline computing summary measure
%using cellfun
CellArrayToCompute = {Pitch Amp Duration PitchStep AmpStep DurationStep TwoDimStep ThreeDimStep IntVocInt};

%compute summary measure
if strcmpi(MeasureType,'mean')
    OpVals = cellfun(@(x) mean(x, 'omitnan'), CellArrayToCompute);
elseif strcmpi(MeasureType,'median')
    OpVals = cellfun(@(x) median(x, 'omitnan'), CellArrayToCompute);
elseif strcmpi(MeasureType,'stddev')
    OpVals = cellfun(@(x) std(x, 'omitnan'), CellArrayToCompute);
elseif strcmpi(MeasureType,'90prc')
    OpVals = cellfun(@(x) prctile(x, 90), CellArrayToCompute); %prctile automatically omits NaN
else
    error('Invalid summary measure')
end

%----nested function to get relevant variables for the tables---------------------------------------------------------------------------------------------------------
%I actually repeat this nested function in more than one function and one can argue that that means I should make it its own function, but like, I
%don't want to at this point because then I'll have to edit other things and it really is a metter of copy-and-pasting this block wherever I need
%it. I will probably fix this when I do a sweeping code clean-up before putting it up on Github, but then again, I might not. I just want to
%acknowledge that this isn't the best practice, but I also don't want to fix it now. So, essentially, if you read this, I want you to know that I
%might be a little stupid and a lot lazy, but I am definitely not that stupid. 
    function [PitchVec,AmpVec,StartTimeVec,EndTimeVec,SpeakerLabelVec,SectionNumVec] = GetRelevantVars(TabName,TabType)

        %note that the lena daylong tables have information about the ending of the subrecording; the human listener data tables have infomration about
        %section numbers for each of the annotated 5 min sections; while the matched 5 min lena data has both section number and subrecend info. 
        %We need to process this so that we are not considering step sizes between vocs that are part of different subrecordings or different sections

        if strcmpi(TabType,'LENAday') %for daylong lena data, we need to convert info from the subrecend column into section numbers, i.e., a 
            %section number associated with each utterance such that utterances from different subrecs have different section numbers
            SubrecEnd = TabName.SubrecEnd;
            SectionNumValue = 1; %default
            SectionNumVec = zeros(size(SubrecEnd)); %initialise
            for j = 1:numel(SubrecEnd)
                SectionNumVec(j) = SectionNumValue;
                if SubrecEnd(j) == 1
                    SectionNumValue = SectionNumValue + 1; %if current voc is end of a subrec, increment section number value
                end
            end
        else %if not LENA daylong data, the section num info already exists
            SectionNumVec = TabName.SectionNum;
        end

        %pick out CHNSP and AN sounds
        if strcmpi(TabType,'Humlabel')  %pick out AN (T, U, N annotations) and CHNSP (X, C annotations)

            PitchVec = TabName.logf0_z(contains(TabName.Annotation,{'T','U','N','X','C'}),:);
            AmpVec = TabName.dB_z(contains(TabName.Annotation,{'T','U','N','X','C'}),:);
            StartTimeVec = TabName.start(contains(TabName.Annotation,{'T','U','N','X','C'}),:);
            EndTimeVec = TabName.xEnd(contains(TabName.Annotation,{'T','U','N','X','C'}),:);
            SpeakerLabelVec = TabName.speaker(contains(TabName.Annotation,{'T','U','N','X','C'}),:);
            SectionNumVec = SectionNumVec(contains(TabName.Annotation,{'T','U','N','X','C'}),:);

        else %if LENA data, this has CHNSP, CHNNSP, and AN; pick out CHNSP and AN

            PitchVec = TabName.logf0_z(contains(TabName.speaker,{'CHNSP','AN'}),:);
            AmpVec = TabName.dB_z(contains(TabName.speaker,{'CHNSP','AN'}),:);
            StartTimeVec = TabName.start(contains(TabName.speaker,{'CHNSP','AN'}),:);
            EndTimeVec = TabName.xEnd(contains(TabName.speaker,{'CHNSP','AN'}),:);
            SpeakerLabelVec = TabName.speaker(contains(TabName.speaker,{'CHNSP','AN'}),:);
            SectionNumVec = SectionNumVec(contains(TabName.speaker,{'CHNSP','AN'}),:);

        end
    end
end