function [NonInterv_correlation,NonInterv_pvalue,NonInterv_YvarNames,NonInterv_XvarName,...
            NonStSize_correlation,NonStSize_pvalue,NonStSize_YvarNames,NonStSize_XvarName] =...
                                                                            GetRecordingLevelCorrelations(InputTable,ChildID,ChildAgeDays,TargetSpeaker,OtherSpeaker,DataType)

%Function to get the recording level correlations for a given data table.
%This could be a data from a daylong LENA recording, data from 5 minute
%sections labelled by human listeners, or corresponding matched LENA data.
%Note that this only gets the CHNSP and AN vocs (or correspondingly, vocs
%with annotations T, U, X, N or C for human listener labels)

%inputs: - Data table with acoustics and time series info for a given infant at a given age (InputTable)
        %- Infant ID and age in days
        %- Speaker of interest (TargetSpeaker). This is the speaker whose acoustic explorations we are looking at; string
        %- Speaker that is interacting with TargetSpeaker (OtherSpeaker); string
        %- The type of data (DataType) which specifies if the data is human labelled ('Humlabel'), matched LENA ('LENA5min'), or daylong LENA ('LENAday'); string

%outputs: - a row vector of correlations; a row vector of corresponding
                %p values for non-intervening step sizes; row cell array of corresponding Y
                %var names; name of the X variable, all for Nonintervening step sizes
         %- and similarly, the same for non-step size measures, where we
                %look at how different the acoustic feature of the SPEAKER
                %utterance is with respect to that of the last OTHER type
                %utterance, as a function of time elapsed

%get structures with X and Y vars to compute correlations
[Pitch,Amp,StartTime,EndTime,SpeakerLabels,SectionNum] = GetRelevantVars(InputTable,DataType); %first get relevant variables to pass to the function beloew
[NonInterveningStruct,~,NonStSizeStruct] = GetStepSizeVsTimeSinceEndOfLastResponse(Pitch,Amp,StartTime,EndTime,SpeakerLabels,...
                                                                         SectionNum,TargetSpeaker,OtherSpeaker,ChildID,ChildAgeDays);
%see relevant user-defined function for details

%convert to tables
NonInterveningTab = struct2table(NonInterveningStruct);
NonStSizeTab = struct2table(NonStSizeStruct);

%Nonintervening table var names: TimeSinceLastResponse, AmpStep, PitchStep, DurStep, IntVocInt, TwoDimSpaceStep, ThreeDimSpaceStep  + others
%So, Xvar has index 1; Yvars are 2:7
Yvar_NonInterv_Indices  = 2:7;
Xvar_NonInterv = table2array(NonInterveningTab(:,1));
if ~isequal(Xvar_NonInterv,Xvar_NonInterv(~isnan(Xvar_NonInterv))) %error check to make sure there are no NaN values in Xvar
    error('NaNs in X var')
end
[NonInterv_correlation,NonInterv_pvalue,NonInterv_YvarNames,NonInterv_XvarName] = GetCorrcoeffDetails(Yvar_NonInterv_Indices,Xvar_NonInterv,NonInterveningTab);

%Nonstepsize table: TimeSinceLastResponse, PitchVar, AmpVar, DurationVar, PitchStepFromLastResponse, AmpStepFromLastResponse, 
                    %DirectionalDurStepFromLastResponse, AbsDurStepFromLastResponse, TwoDimSpaceStep    ThreeDimSpaceStep
%So, Xvar has index 1; Yvars are 2:6 and 8:10
Yvar_NonStSize_Indices = [2 3 4 5 6 8 9 10];
Xvar_NonStSize = table2array(NonStSizeTab(:,1));
if ~isequal(Xvar_NonStSize,Xvar_NonStSize(~isnan(Xvar_NonStSize))) %error check to make sure there are no NaN values in Xvar
    error('NaNs in X var')
end
[NonStSize_correlation,NonStSize_pvalue,NonStSize_YvarNames,NonStSize_XvarName] = GetCorrcoeffDetails(Yvar_NonStSize_Indices,Xvar_NonStSize,NonStSizeTab);

%----nested function to get relevant variables for the tables---------------------------------------------------------------------------------------------------------
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
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

%----nested function to correlation coeff and p value as a row vector, as well as X and Y var names-----------------------------------------------------------------------
    function [XY_correlation,XY_pvalue,YvarNames,XvarName] = GetCorrcoeffDetails(Yvar_Indices,Xvar,InputTab)

        VarNames = InputTab.Properties.VariableNames; %get variable names
        XvarName = VarNames{1}; %get X var name

        for i = 1:numel(Yvar_Indices)
            YvarTemp = table2array(InputTab(:,Yvar_Indices(i))); %get current Y var
            YvarNames{1,i} = VarNames{Yvar_Indices(i)}; %get variable name for current Y var

            if numel(Xvar(~isnan(YvarTemp))) > 1 %if there are more than 1 non-NaN y var entry, proceed
                [CorrMatrix,PvalMatrix] = corrcoef(Xvar(~isnan(YvarTemp)),YvarTemp(~isnan(YvarTemp))); %compute correlation for x and y variables for the current id_age combo
                %excluding NaN values in the Y var
                XY_correlation(1,i) = CorrMatrix(1,2);
                XY_pvalue(1,i) = PvalMatrix(1,2);
            else
                XY_correlation(1,i) = NaN;
                XY_pvalue(1,i) = NaN;
            end
        end
    end
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
end