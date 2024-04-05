function [CurrPrevStepSizeTab] = Get_CurrPrevStepSizeTab(ZscoreTab,SpkrType, OtherType, NAType, ResponseWindow)

% This function takes the table with step size info, and outputs a table with current and previous step size info, after marking steps associated with IVIs
% less than the ResponseWindow as NA response (note that this NA is functionally different from the NA response when there is a target speaker onset within 
% the response window threshold after the last target speaker offset, without an intervening responder (OtherType) onset. The purpose of this NA tag is to 
% filter out IVIs that are less than the ResponseWindow for steps associated with a response, since steps associated without a response are, by definition 
% going to have IVIs greater than the ResponseWindow).

% Note that we DO not remove rows associated with NaN responses in this output table. We will do this in the R stats code AFTER we estimate residuals of the
% current step size ~ previous step size linear fit.
%
% Inputs: - ZscoreTab: the input table with acoustics, speaker labels, etc.
         %- SpkrType, OtherType, NAType: speaker labels that correspond to the target speaker, the other speaker (responder), and the speaker type that
            % triggers an NA response. For eg, if we are looking at AN response to CHNSP, thiese would be CHNSP, AN, and CHN, respectively
         %- ResponseWIndow: the response window time (ResponseWindow) in seconds
% Output: CurrPrevStepSizeTab: table with current and previous step size info as well as response info.

%get step size tab
DistTab = GetStepSizeTab(ZscoreTab,SpkrType,OtherType,NAType,ResponseWindow); 

if size(DistTab,1) <= 1 %if there are less than 2 step sizes
    CurrPrevStepSizeTab = array2table(zeros(0,13)); %initialise output tab
    FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','Response',...
        'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D'};
    CurrPrevStepSizeTab.Properties.VariableNames = FinalVarNames;
    return
end

DistTab.Response(DistTab.InterVocInt <= ResponseWindow) = NaN; %set responses associated with IVI less than ResponseWindow as NaN. Note that for AN
%response to CHNSP, some NaNs are going to be associated with a CHNNSP onset within the response window threshold after the offset of a CHNSP sound, 
%while other NaNs are going to be associated with CHNSP-to-CHNSP IVI being less than the responsewindow.

DistTabVarNames = DistTab.Properties.VariableNames;

%initialise output table
CurrPrevStepSizeTab = array2table(zeros(0,13)); %initialise output tab
FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','Response',...
    'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D'};
CurrPrevStepSizeTab.Properties.VariableNames = FinalVarNames;

%get var names for the current and prev step size parts of the final table
TabVarNames_Curr = strcat('Curr',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
TabVarNames_Curr  = [TabVarNames_Curr,'Response'];
TabVarNames_Prev = strcat('Prev',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
u_SecNum = unique(DistTab.SectionNum); %get unique section numbers
for i = 1:numel(u_SecNum) %go through each section number
    TempTab = DistTab(DistTab.SectionNum == u_SecNum(i),:);

    if size(TempTab,1) >= 2 %we need at least 2 steps in a section to get a set of current and prev step size for rthat section 
        Curr_TempTab = TempTab(2:end,:);
        Curr_TempTab = removevars(Curr_TempTab,{'SectionNum'});
        Prev_TempTab = TempTab(1:end-1,:);
        Prev_TempTab = removevars(Prev_TempTab,{'SectionNum','Response'});
    
        %recast var names
        Curr_TempTab.Properties.VariableNames = TabVarNames_Curr;
        Prev_TempTab.Properties.VariableNames = TabVarNames_Prev;
    
        ProcessedTab = [Curr_TempTab Prev_TempTab]; %putb both togther
        %ProcessedTab = ProcessedTab(~isnan(ProcessedTab.Response),:);%remove NA responses
    
        CurrPrevStepSizeTab = [CurrPrevStepSizeTab; ProcessedTab]; %stack
    end
end

%checks: we are going to do the following checks, just to make sure that everything works as intended.
%1. 2d and 3d steps can be reproduced from individual acoustic steps (excluding NaN values)
Curr_2DStep_FromAcousticSteps = sqrt(CurrPrevStepSizeTab.CurrDistPitch.^2 + CurrPrevStepSizeTab.CurrDistAmp.^2); %get 2d step sizes from individual acoustic steps
Curr_3DStep_FromAcousticSteps = sqrt(CurrPrevStepSizeTab.CurrDistPitch.^2 + CurrPrevStepSizeTab.CurrDistAmp.^2 + CurrPrevStepSizeTab.CurrDistDuration.^2); %similarly for 3d
if ~isequal(Curr_2DStep_FromAcousticSteps(~isnan(Curr_2DStep_FromAcousticSteps)),... %do checks
        CurrPrevStepSizeTab.CurrDist2D(~isnan(CurrPrevStepSizeTab.CurrDist2D))) 
    error('2d step sizes in the table not equal to 2d steps computed from individual acoustic steps')
elseif ~isequal(Curr_3DStep_FromAcousticSteps(~isnan(Curr_3DStep_FromAcousticSteps)),...
        CurrPrevStepSizeTab.CurrDist3D(~isnan(CurrPrevStepSizeTab.CurrDist3D)))
    error('3d step sizes in the table not equal to 3d steps computed from individual acoustic steps')
end

%2. now, let's check to make sure that NaN response steps ARE included
if numel(CurrPrevStepSizeTab.Response) == numel(CurrPrevStepSizeTab.Response(~isnan(CurrPrevStepSizeTab.Response))) %if NaN responses and associated steps have been excludeed, then
    %the number of elements in Response vector before and after removing NaN responses will be the same. So, if this condition is satisfied, we know that NaN responses have already been 
    %excluded.
    DistTab
    %disp('NaN responses and associated steps have already been removed from the table. OR this is a human')
end

%3. Finally, let's make sure that all IVIs less than or equal to response window are associated with NaN responses.
ResponseForShortIvis = CurrPrevStepSizeTab.Response(CurrPrevStepSizeTab.CurrInterVocInt <= ResponseWindow); %get Response values for Ivis <= response window
if ~isempty(ResponseForShortIvis(~isnan(ResponseForShortIvis)))
    error('IVIs less than or equal to response window have not been flagged as associated with NaN response')
end
