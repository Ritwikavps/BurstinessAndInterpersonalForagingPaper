function [OpTab] = Get_WR_WOR_RecLvlStatsTab_Residuals(MyData,statType)

u_ID = unique(MyData.InfantID);
OpTab = array2table(zeros(0,9));
OpTab.Properties.VariableNames = [strcat(statType,{'_DistPitchRes','_DistAmpRes','_DistDurRes','_IviRes','_Dist2DRes','_Dist3DRes'}),'InfantID','AgeDays','ResponseVec'];

for i = 1:numel(u_ID)

    SubTab = MyData(contains(MyData.InfantID,u_ID(i)),:);

    WR_Tab = SubTab(SubTab.Response == 1,:);
    WOR_Tab = SubTab(SubTab.Response == 0,:);

    switch statType
        case 'median'
            WR_Op = varfun(@(x)median(x,'omitnan'), WR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
            WOR_Op = varfun(@(x)median(x,'omitnan'), WOR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
        case 'mean'
            WR_Op = varfun(@(x)mean(x,'omitnan'), WR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
            WOR_Op = varfun(@(x)mean(x,'omitnan'), WOR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
        case 'std'
            WR_Op = varfun(@(x)std(x,'omitnan'), WR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
            WOR_Op = varfun(@(x)std(x,'omitnan'), WOR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
        case 'percentile'
            WR_Op = varfun(@(x)prctile(x,90), WR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
            WOR_Op = varfun(@(x)prctile(x,90), WOR_Tab(:,{'DistPitchRes','DistAmpRes','DistDurRes','IviRes','Dist2DRes','Dist3DRes'}), 'OutputFormat', 'table');
        otherwise
            error('Invalid statistic type.');
    end

    WOR_Op.Properties.VariableNames = strcat(statType,erase(WOR_Op.Properties.VariableNames,'Fun')); %rename variables
    WR_Op.Properties.VariableNames = strcat(statType,erase(WR_Op.Properties.VariableNames,'Fun'));

    WR_Op.InfantID = u_ID(i);
    WOR_Op.InfantID = u_ID(i);

    WR_Op.AgeDays = WR_Tab.AgeDays(1);
    WOR_Op.AgeDays =  WR_Tab.AgeDays(1);

    WR_Op.ResponseVec = 1;
    WOR_Op.ResponseVec = 0;

    OpTab = [OpTab; WR_Op; WOR_Op];
end

