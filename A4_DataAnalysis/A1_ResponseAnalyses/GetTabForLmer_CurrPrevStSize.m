function CurrPrevStepSizeTab_Agg = GetTabForLmer_CurrPrevStSize(ZscoreDir, ResponseWindow_s, SpkrType, OtherType, NAType, StringToRemoveFromFname, MetadataTab)

%Ritwika VPS, UCLA Comm, Sep 2023

%This script and associated functions will analyse infant and adult step sizes and get current and prev step size info + WR/WOR info, age, infant
%ID, and put it into a single table for further statistical analyses.

%Inputs: - ZscoreDir: structure that has list of all relevant files (output of dir() on the relevant directory)
        %- ResponseWindow_s: the response window time (in seconds) 
        %- SpkrType: the target speaker (eg. CHNSP)
        %- OtherType: the responder (eg. if we are looking at the effect of adult response on infant vocs, then this would be AN)
        %- NAType: the speaker label that triggers an NA response (see ComputeResponseVector.m for details)
        %- StringToRemoveFromFname: the substring to remove from the filename to get the filename root (eg. If the filename is '0009_000302_ZscoredAcousticsTS_LENA.csv'
            % , then the string to remove would be '_ZscoredAcousticsTS_LENA.csv', so we get the filename root '0009_000302'
        %- MetadataTab: the table containing metadata info

%Output: CurrPrevStepSizeTab_Agg: table with all Current and previous step size details for each infant at each age, aggregated across the whole corpus,
        %along with infant ID and infant age info.

CurrPrevStepSizeTab_Agg = array2table(zeros(0,16));
FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','Response',...
    'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D','InfantID','AgeDays','AgeMonths'};
CurrPrevStepSizeTab_Agg.Properties.VariableNames = FinalVarNames;

for i = 1:numel(ZscoreDir) %go through list of files

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