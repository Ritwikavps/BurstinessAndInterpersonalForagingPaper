function [WR_Tab, WOR_Tab] = GetTabForLmer_WR_WOR_RecLvlStats(ZscoreDir, ResponseDataPath, VocType ,ResponseWindowStr ,RespType, statType,MetadataTab)

%Ritwika VPS, UCLA Comm, Feb 2023

%This script and associated functions will analyse infant and adult step
%size distribution median, mean, std dev and 90th percentile values for WR
%and WOR categories, using a 1 s response interval

WR_Tab = array2table(zeros(0,6));
WR_Tab.Properties.VariableNames = strcat(statType,{'_DistPitch','_DistAmp','_DistDuration','_InterVocInt','_Dist2D','_Dist3D'});
WOR_Tab = WR_Tab;

%go through list
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

    [WR_TabTemp,WOR_TabTemp] = Get_WR_WOR_RecLvlStatistics(ZscoreTab,ResponseTab,VocType, ResponseWindowStr, RespType, statType);

    WR_Tab = [WR_Tab; WR_TabTemp];
    WOR_Tab = [WOR_Tab; WOR_TabTemp];

    %get infant id and age
    InfantID{i,1} = MetadataTab.InfantID(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));
    AgeDays(i,1) = MetadataTab.InfantAgeDays(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));
    AgeMonths(i,1) = MetadataTab.InfantAgeMonth(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));

end

WR_Tab.InfantID = InfantID;
WR_Tab.AgeDays = AgeDays;
WR_Tab.AgeMonths = AgeMonths;

WOR_Tab.InfantID = InfantID;
WOR_Tab.AgeDays = AgeDays;
WOR_Tab.AgeMonths = AgeMonths;



