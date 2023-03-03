function [WR_Tab,WOR_Tab] = Get_WR_WOR_Data(InputTab, VocType, ResponseWindowStr, RespType)

%This function separates step size data into WR and WOR subsets

%First: check to make sure that ResponseWindowStr is oin expected format
%('1s', '2s', etc)
pat = digitsPattern(1); 
pat = asManyOfPattern(pat) + 's'; %makes it so that the pattern allows for as many digits at the start followed by 's' (for seconds)
if ~matches(ResponseWindowStr,pat)
    error('ResponseWindowStr not in expected format')
end

%first get step sizes
DistTab = GetStepSizeTab(InputTab, VocType);
%Var names, at minimum, include: 'DistPitch','DistAmp','DistDuration','InterVocInt','Dist2D','Dist3D','speaker';  and at least one of these: 
        %'CHNSPRespToAn_1s','CHNNSPRespToAn_1s','ChnRespToAn_1s','AnRespToCHNSP_1s','AnRespToCHNNSP_1s','AnRespToChn_1s','CHNSPRespToAn_2s','CHNNSPRespToAn_2s',
        %'ChnRespToAn_2s','AnRespToCHNSP_2s','AnRespToCHNNSP_2s','AnRespToChn_2s','CHNSPRespToAn_5s','CHNNSPRespToAn_5s','ChnRespToAn_5s','AnRespToCHNSP_5s','AnRespToCHNNSP_5s',
        % 'AnRespToChn_5s'
        
% Remove cols that contains 'Resp' in the column name from the main table
DistTabVarNames = DistTab.Properties.VariableNames;
cols_to_remove = contains(DistTabVarNames,'Resp');

%Select columns containing 'ResponseWindoStr' in their names; so if the response window is specified as '1s', this only selects those response types
%and also using RespType, which specifies if we want AnResptoChn, etc.
cols_to_select = DistTab.Properties.VariableNames(contains(DistTab.Properties.VariableNames, ResponseWindowStr) & contains(DistTab.Properties.VariableNames, RespType));
ResponseTab = [removevars(DistTab,DistTabVarNames(cols_to_remove)) DistTab(:, cols_to_select)]; %put together new table with only desired responses

%pick out WR and WOR steps based on RespType
ResponseCol = table2array(ResponseTab(:,end));
WR_Tab = ResponseTab(ResponseCol == 1,:);
WOR_Tab = ResponseTab(ResponseCol == 0,:);

%Test to make sure that our response window thing is working oproperly. Essentially, since the WOR step types are, by definition, associated with intervoc intervals >= the response 
% window, the number of rows in the WOR tab before and after filtering out intervoc intervals less than the response window show remain the same
ResponseWindow = str2num(cell2mat(regexp(ResponseWindowStr,'\d*','Match'))); %This gets the numerical value of the response window from the response window string
%This is based on the assumption that the ResponseWindowStr is of the form 1s, 2s, etc. So this picks out 1 or 2 from these example strings, respectively

Numel1 = size(WOR_Tab,1); %get number of rows before removing inter voc intervals < response window 

%remove entries associated with intervoc interval < response window
WOR_Tab(WOR_Tab.InterVocInt < ResponseWindow,:) = [];
WR_Tab(WR_Tab.InterVocInt < ResponseWindow,:) = [];

Numel2 = size(WOR_Tab,1);

if (Numel1 ~= Numel2)
    error('Error in response determination; see comments above')
end


