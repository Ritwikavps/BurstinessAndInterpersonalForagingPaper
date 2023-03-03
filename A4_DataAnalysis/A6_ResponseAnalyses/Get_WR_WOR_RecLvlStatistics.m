function [WR_Op,WOR_Op] = Get_WR_WOR_RecLvlStatistics(ZscoreTab,ResponseTab,VocType, ResponseWindowStr, RespType, statType)

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
CombinedTab = join(removevars(ZscoreTab,{'wavfile','speaker','duration','SubrecEnd','FileNameUnMerged'}),... %remove unnecessary vars for this table
                   removevars(ResponseTab,{'wavfile','FileNameUnMerged','meanf0','dB'}),... %remove unnecessary vars for this table
                   'Keys',{'start','xEnd'}); %specify common var names to join tables using

[WR_Tab,WOR_Tab] = Get_WR_WOR_Data(CombinedTab, VocType, ResponseWindowStr, RespType); %get WR and WOR step size data
 
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
