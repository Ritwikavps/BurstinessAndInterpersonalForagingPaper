function [BestFitFlag_Op,WR_AICparamsStruct,WOR_AICparamsStruct] = GetAICBestFit_WR_WOR_Data(ZscoreTab,ResponseTab,VocType, ResponseWindowStr, RespType, PlotFlag)

    % This function computes the best fit distribution for WR and WOR data (and
    % optionally for data not split by responses), and based on the most common
    % fit type, gets the fit parameters for each day level data. 
    %
    % Inputs:
    %   - Input table: the input table with acoustics and response data
    %   
    % Output:
    %   - 
    
    %Join the tables
    CombinedTab = join(removevars(ZscoreTab,{'wavfile','speaker','duration','SubrecEnd','FileNameUnMerged'}),... %remove unnecessary vars for this table
                       removevars(ResponseTab,{'wavfile','FileNameUnMerged','meanf0','dB'}),... %remove unnecessary vars for this table
                       'Keys',{'start','xEnd'}); %specify common var names to join tables using

    [WR_Tab,WOR_Tab] = Get_WR_WOR_Data(CombinedTab, VocType, ResponseWindowStr, RespType); %get WR and WOR step size data

    %Get required ops for WR and WOR
    [WR_BestFitFlagTab,WR_AICparamsStruct] = GetReqOpForAICBestFitFn(WR_Tab,PlotFlag);
    [WOR_BestFitFlagTab,WOR_AICparamsStruct] = GetReqOpForAICBestFitFn(WOR_Tab,PlotFlag);

    WR_BestFitFlagTab.Properties.VariableNames = strcat('WR_',WR_BestFitFlagTab.Properties.VariableNames); %change var names
    WOR_BestFitFlagTab.Properties.VariableNames = strcat('WOR_',WOR_BestFitFlagTab.Properties.VariableNames);
    
    BestFitFlag_Op = [WR_BestFitFlagTab WOR_BestFitFlagTab]; %combine tabs

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %nested functions used
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function [BestFitFlagTab,AICparamsStruct] = GetReqOpForAICBestFitFn(StepSizeTab,PlotFlag)
        %This function gets the best fit flag table and the params struct 

        %Get best fit flags with WR as an example -- basically information about which candidate distribution is determined best fit by AIC for each step
        %size distribution (eg. pitch, amp, etc.). The output is a table
        BestFitFlagTab = varfun(@(x)GetAIC_BestFit(x,PlotFlag), StepSizeTab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        
        %rename table cols
        BestFitFlagTab.Properties.VariableNames = strcat('BestFit',erase(BestFitFlagTab .Properties.VariableNames,'Fun')); %rename variables
        
        %similarly, get AIC best fit parameters for each candidate distribution; output is a table where each table element is a struct
        AICparamsTab = varfun(@(x)GetAIC_MleStruct(x,PlotFlag), StepSizeTab(:,{'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D'}), 'OutputFormat', 'table');
        
        %change table colnames
        AICparamsTab.Properties.VariableNames = strcat('AICresults',erase(AICparamsTab.Properties.VariableNames,'Fun'));
        
        %convert table to a struct
        AICparamsStruct = table2struct(AICparamsTab);
    end
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function MleStruct = GetAIC_MleStruct(StepsizeVec,PlotFlag) %get struct with AIC best fit params for each candidate dist
        [MleStruct,~,~] = aicnew(StepsizeVec,PlotFlag,0);
    end
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    function BestFitFlag= GetAIC_BestFit(StepSizeVec,PlotFlag) %get a flag for which candidate dist is best fit; double
        [~,BestFitFlag,~] = aicnew(StepSizeVec,PlotFlag,0);
    end
end




    %switch RespType
   % case 'NA' %in case we are looking at non-response data

   % otherwise

   %end