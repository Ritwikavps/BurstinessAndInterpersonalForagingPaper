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
DistTab.Response(DistTab.InterVocInt <= ResponseWindow) = NaN; %set responses associated with IVI less than ResponseWindow as NaN. Note that for AN
%response to CHNSP, some NaNs are going to be associated with a CHNNSP onset within the response window threshold after the offset of a CHNSP sound, 
%while other NaNs are going to be associated with CHNSP-to-CHNSP IVI being less than the responsewindow.

DistTabVarNames = DistTab.Properties.VariableNames;
if ~isempty(DistTabVarNames(contains(DistTabVarNames,'SubrecEnd'))) %if there is a column named SubrecEnd
    DistTab = removevars(DistTab,{'SubrecEnd'}); 
end

if ~isempty(DistTabVarNames(contains(DistTabVarNames,'wavfile'))) %if there is a column named wavfile
    DistTab = removevars(DistTab,{'wavfile'}); 
end

%initialise output table
CurrPrevStepSizeTab = array2table(zeros(0,14)); %initialise output tab
FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','FileNameUnMerged','Response',...
    'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D'};
CurrPrevStepSizeTab.Properties.VariableNames = FinalVarNames;

%get var names for the current and prev step size parts of the final table
TabVarNames_Curr = strcat('Curr',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
TabVarNames_Curr  = [TabVarNames_Curr, 'FileNameUnMerged','Response'];
TabVarNames_Prev = strcat('Prev',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
u_SecNum = unique(DistTab.SectionNum); %get unique section numbers
for i = 1:numel(u_SecNum) %go through each section number
    TempTab = DistTab(DistTab.SectionNum == u_SecNum(i),:);
    Curr_TempTab = TempTab(2:end,:);
    Curr_TempTab = removevars(Curr_TempTab,{'SectionNum'});
    Prev_TempTab = TempTab(1:end-1,:);
    Prev_TempTab = removevars(Prev_TempTab,{'FileNameUnMerged','SectionNum','Response'});

    %recast var names
    Curr_TempTab.Properties.VariableNames = TabVarNames_Curr;
    Prev_TempTab.Properties.VariableNames = TabVarNames_Prev;

    ProcessedTab = [Curr_TempTab Prev_TempTab]; %putb both togther
    %ProcessedTab = ProcessedTab(~isnan(ProcessedTab.Response),:);%remove NA responses

    CurrPrevStepSizeTab = [CurrPrevStepSizeTab; ProcessedTab]; %stack
end
