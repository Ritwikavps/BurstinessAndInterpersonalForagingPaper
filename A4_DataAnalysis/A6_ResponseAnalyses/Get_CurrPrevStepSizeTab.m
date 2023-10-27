function [CurrPrevStepSizeTab] = Get_CurrPrevStepSizeTab(ZscoreTab,SpkrType, OtherType, NAType, ResponseWindow_s)

% This function computes the median, mean, standard deviation, or 90th
% percentile value of step size InputTabs based on a string input
%
% Inputs:
%   - Input table: the input table with acoustics and response data
%   - statType: a string specifying the type of statistic to compute (either 'median', 'mean', 'std', or 'percentile').
%
% Output:
%   - 

%get step size tab
DistTab = GetStepSizeTab(ZscoreTab,SpkrType,OtherType,NAType,ResponseWindow_s); 

%Get CurrStepSize + WR/WOR info and section num info 
CurrPrevStepSizeTab = array2table(zeros(0,14)); %initialise output tab
FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','FileNameUnMerged','Response',...
    'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D'};
CurrPrevStepSizeTab.Properties.VariableNames = FinalVarNames;

%get var names for the current and prev step size parts of the final table
TabVarNames_Curr = strcat('Curr',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
TabVarNames_Curr  = [TabVarNames_Curr, 'FileNameUnMerged','Response'];
TabVarNames_Prev = strcat('Prev',{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'});
u_SecNum = unique(DistTab.SectionNum);
for i = 1:numel(u_SecNum) %go through each section number
    TempTab = DistTab(DistTab.SectionNum == u_SecNum(i),:);
    Curr_TempTab = TempTab(2:end,:);
    Curr_TempTab = removevars(Curr_TempTab,{'speaker','SectionNum'});
    Prev_TempTab = TempTab(1:end-1,:);
    Prev_TempTab = removevars(Prev_TempTab,{'speaker','FileNameUnMerged','SectionNum','Response'});

    

    %recast var names
    Curr_TempTab.Properties.VariableNames = TabVarNames_Curr;
    Prev_TempTab.Properties.VariableNames = TabVarNames_Prev;

    ProcessedTab = [Curr_TempTab Prev_TempTab]; %putb both togther
    ProcessedTab = ProcessedTab(~isnan(ProcessedTab.Response),:);%remove NA responses

    CurrPrevStepSizeTab = [CurrPrevStepSizeTab; ProcessedTab]; %stack
end

