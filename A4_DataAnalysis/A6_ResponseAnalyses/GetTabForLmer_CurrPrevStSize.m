function CurrPrevStepSizeTab_Agg = GetTabForLmer_CurrPrevStSize(ZscoreDir, ResponseWindow_s, SpkrType, OtherType, NAType, StringToRemoveFromFname, MetadataTab)

%Ritwika VPS, UCLA Comm, Sep 2023

%This script and associated functions will analyse infant and adult step
%sizes and get current and prev step size info + WR/WOR info, age, infant
%ID, and put it into a single table for further statistical analyses

CurrPrevStepSizeTab_Agg = array2table(zeros(0,17));
FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','FileNameUnMerged','Response',...
    'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D','InfantID','AgeDays','AgeMonths'};
CurrPrevStepSizeTab_Agg.Properties.VariableNames = FinalVarNames;

%go through list
for i = 1:numel(ZscoreDir)

    ZscoreFnRoot = erase(ZscoreDir(i).name, StringToRemoveFromFname); % get the root of the filename
    ZscoreTab = readtable(ZscoreDir(i).name,'Delimiter',',');
    
    [CurrPrevStepSizeTab] = Get_CurrPrevStepSizeTab(ZscoreTab,SpkrType, OtherType, NAType, ResponseWindow_s);

    %get infant id and age
    InfantID = cell(numel(CurrPrevStepSizeTab.CurrDistAmp),1);
    [InfantID{:}] = deal(MetadataTab.InfantID(contains(MetadataTab.FileNameRoot,ZscoreFnRoot)));
    AgeDays = MetadataTab.InfantAgeDays(contains(MetadataTab.FileNameRoot,ZscoreFnRoot))*ones(numel(CurrPrevStepSizeTab.CurrDistAmp),1);
    AgeMonths = MetadataTab.InfantAgeMonth(contains(MetadataTab.FileNameRoot,ZscoreFnRoot))*ones(numel(CurrPrevStepSizeTab.CurrDistAmp),1);

    CurrPrevStepSizeTab.InfantID = InfantID;
    CurrPrevStepSizeTab.AgeDays = AgeDays;
    CurrPrevStepSizeTab.AgeMonths = AgeMonths;

    CurrPrevStepSizeTab_Agg = [CurrPrevStepSizeTab_Agg; CurrPrevStepSizeTab]; 
end