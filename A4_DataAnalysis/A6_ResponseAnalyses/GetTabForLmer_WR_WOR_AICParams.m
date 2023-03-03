function [OpTab] = GetTabForLmer_WR_WOR_AICParams(ZscoreDir, ResponseDataPath, VocType ,ResponseWindowStr ,RespType, MetadataTab, PlotFlag)

%Ritwika VPS, UCLA Comm, Feb 2023

%This script and associated functions will analyse infant and adult step
%size distribution AIC best fit parameters, and output tables for lmer
%analyses

BestFitFlag_Tab = array2table(zeros(0,12)); %create empty table to populate with values for AIC best fits for each recording day and infant
%specify col names
BestFitFlag_Tab.Properties.VariableNames = {'WR_BestFit_DistPitch' ,'WR_BestFit_DistAmp', 'WR_BestFit_DistDuration','WR_BestFit_InterVocInt','WR_BestFit_Dist2D',...
    'WR_BestFit_Dist3D','WOR_BestFit_DistPitch','WOR_BestFit_DistAmp','WOR_BestFit_DistDuration','WOR_BestFit_InterVocInt','WOR_BestFit_Dist2D','WOR_BestFit_Dist3D'}; 


%go through list of files
for i = 1:numel(ZscoreDir)

    ZscoreFnRoot = erase(ZscoreDir(i).name, '_ZscoredAcousticsTS_LENA.csv'); % get the root of the filename
    matchingFile = fullfile(ResponseDataPath, [ZscoreFnRoot, '_AcousticsTSJoined.csv']); % construct the path to the matching file in response folder; 
    % fullfile stitches up a full fole name from pieces

    if exist(matchingFile, 'file') % check if the file exists
        ResponseTab = readtable(matchingFile,'Delimiter',','); %if yes, load both files
        ZscoreTab = readtable(ZscoreDir(i).name,'Delimiter',',');
    else
        error('No matching response file') %if not, throw error
    end

    %check if start and end times as well as speaker lables match for both
    %files
    if (~isequal(ResponseTab.start,ZscoreTab.start)) || (~isequal(ResponseTab.speaker,ZscoreTab.speaker)) || (~isequal(ResponseTab.xEnd,ZscoreTab.xEnd)) ...
            || (~isequal(ZscoreTab.wavfile,ResponseTab.wavfile)) || (~isequal(ZscoreTab.SubrecEnd,ResponseTab.SubrecEnd))
        error('Start times, end times, wav file names, subrecend info, or speaker labels from z-score table and response table do not match')
    end

    %get AIC best fit distributions (BestFitFlag_Temp) for each file based on response type, response window, speaker type, for both WR and WOR.
    %Also get AIC mle parameters for all 4 possible candidate distributions for each
    [BestFitFlag_TabTemp,WR_AICparams(i).ParamStruct,WOR_AICparams(i).ParamStruct] = GetAICBestFit_WR_WOR_Data(ZscoreTab,ResponseTab,VocType, ResponseWindowStr, RespType, PlotFlag);

    BestFitFlag_Tab = [BestFitFlag_Tab; BestFitFlag_TabTemp]; %add to best fit table

    %get infant id and age
    InfantID{i,1} = MetadataTab.InfantID(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));
    AgeDays(i,1) = MetadataTab.InfantAgeDays(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));
    AgeMonths(i,1) = MetadataTab.InfantAgeMonth(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));

end

WR_BestFitFlag_Tab = BestFitFlag_Tab(:,1:6); %separate best fit distribution info for WR and WOR
WOR_BestFitFlag_Tab = BestFitFlag_Tab(:,7:12);

%find most common best fit 
WR_BestFitMode_Tab = varfun(@mode,WR_BestFitFlag_Tab,'OutputFormat','table'); 
WOR_BestFitMode_Tab = varfun(@mode,WOR_BestFitFlag_Tab,'OutputFormat','table'); 

%Now that we have both the best fit info for each recording, and the AIC mle params for all 4 candidate distributions, we can extract the info we
%need for lmer; namely, best fit parameters per AIC if the AIC best fit for the distribution is the same as the most common AIC best fit distribution
%for that category of step sizes. 
StepType = {'pitch','amplitude','duration','int-voc-int','2d','3d'};

%go through: here i is the index for the recording -- this index also gives
%the infant id and age. j is the index for the specific step type; so j = 3
%would be the duration step
for i = 1:numel(AgeDays)
    for j = 1:numel(StepType)
        [WR_ParamsOp{i,j}, WR_BestFitMatchFlag(i,j)] = GetAICBestFitParams(WR_AICparams(i),table2array(WR_BestFitMode_Tab(1,j)),...
                                                                            table2array(WR_BestFitFlag_Tab(i,j)),StepType{j});
        [WOR_ParamsOp{i,j}, WOR_BestFitMatchFlag(i,j)] = GetAICBestFitParams(WOR_AICparams(i),table2array(WOR_BestFitMode_Tab(1,j)),...
                                                                            table2array(WOR_BestFitFlag_Tab(i,j)),StepType{j});
    end
end

WR_AICTab = OrganiseAICResults(WR_ParamsOp,WR_BestFitMatchFlag,InfantID,AgeDays,AgeMonths,WR_BestFitMode_Tab); %organise results into table
WOR_AICTab = OrganiseAICResults(WOR_ParamsOp,WOR_BestFitMatchFlag,InfantID,AgeDays,AgeMonths,WOR_BestFitMode_Tab);

WR_AICTab.ResponseVec = ones(size(WR_AICTab,1),1); %add response info
WOR_AICTab.ResponseVec = zeros(size(WR_AICTab,1),1);

%check if there are step size categories that have different corpus best
%fits for WR and WOR
VarNamesToRemove = union(setdiff(WR_AICTab.Properties.VariableNames,WOR_AICTab.Properties.VariableNames),...
                setdiff(WOR_AICTab.Properties.VariableNames,WR_AICTab.Properties.VariableNames));
if ~isempty(VarNamesToRemove)
    disp('These are the variable names corresponding to step size categories whose corpus level best fits did not match at WR and WOR level: \n')
    VarNamesToRemove
end

%plop tables together after removing vars
OpTab = [removevars(WR_AICTab,setdiff(WR_AICTab.Properties.VariableNames,WOR_AICTab.Properties.VariableNames));...
    removevars(WOR_AICTab,setdiff(WOR_AICTab.Properties.VariableNames,WR_AICTab.Properties.VariableNames))];


% switch BestFitVal
%     case
% 
% end
% 
% disp('Crikey')

% WR_Tab.InfantID = InfantID;
% WR_Tab.AgeDays = AgeDays;
% WR_Tab.AgeMonths = AgeMonths;
% 
% WOR_Tab.InfantID = InfantID;
% WOR_Tab.AgeDays = AgeDays;
% WOR_Tab.AgeMonths = AgeMonths;



