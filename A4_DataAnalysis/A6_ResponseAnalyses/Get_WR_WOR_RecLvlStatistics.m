function [WR_Tab,WOR_Tab] = Get_WR_WOR_RecLvlStatistics(ZscoreTab,SpkrType, OtherType, NAType, ResponseWindow_s)

% This function computes the median, mean, standard deviation, or 90th
% percentile value of step size InputTabs based on a string input
%
% Inputs:
%   - Input table: the input table with acoustics and response data
%   - statType: a string specifying the type of statistic to compute (either 'median', 'mean', 'std', or 'percentile').
%
% Output:
%   - 

%Join the tables
[WR_Tab,WOR_Tab] = Get_WR_WOR_Data(ZscoreTab, ResponseWindow_s, SpkrType, OtherType, NAType); %get WR and WOR step size data

TabVarNames = strcat(statType,{'_DistPitch','_DistAmp','_DistDuration','_InterVocInt','_Dist2D','_Dist3D'});

if (isempty(WR_Tab)) || (isempty(WOR_Tab))
    WR_Op = array2table(NaN*ones(1,6));
    WOR_Op = array2table(NaN*ones(1,6));
    WR_Op.Properties.VariableNames = TabVarNames;
    WOR_Op.Properties.VariableNames = TabVarNames;
    return
end
 
switch statType
    case 'median'
        WR_Op = varfun(@(x)median(x,'omitnan'), WR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        WOR_Op = varfun(@(x)median(x,'omitnan'), WOR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
    case 'mean'
        WR_Op = varfun(@(x)mean(x,'omitnan'), WR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        WOR_Op = varfun(@(x)mean(x,'omitnan'), WOR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
    case 'std'
        WR_Op = varfun(@(x)std(x,'omitnan'), WR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        WOR_Op = varfun(@(x)std(x,'omitnan'), WOR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
    case 'percentile'
        WR_Op = varfun(@(x)prctile(x,90), WR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        WOR_Op = varfun(@(x)prctile(x,90), WOR_Tab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
    otherwise
        error('Invalid statistic type.');
end

WOR_Op.Properties.VariableNames = strcat(statType,erase(WOR_Op.Properties.VariableNames,'Fun')); %rename variables
WR_Op.Properties.VariableNames = strcat(statType,erase(WR_Op.Properties.VariableNames,'Fun'));
