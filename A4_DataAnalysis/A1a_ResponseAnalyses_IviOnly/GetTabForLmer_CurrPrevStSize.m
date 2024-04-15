function [CurrPrevStepSizeTab_Agg, ZeroIviMergeDetails] = GetTabForLmer_CurrPrevStSize(ZscoreDir, ResponseWindow_s, SpkrType, OtherType, NAType, StringToRemoveFromFname, MetadataTab, IviOnly)

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
        %- IviOnly: toggle 1 or 0 depending on whether we are only looking at Ivi (1) or both Ivi and acoustics (0).  

%Output: CurrPrevStepSizeTab_Agg: table with all Current and previous step size details for each infant at each age, aggregated across the whole corpus,
            %along with infant ID and infant age info.
      %- ZeroIviMergeDetails: table w the total number of voc merges that have been performed, for each recording, plus relevant infant age and ID details. 

if IviOnly == 0       
    CurrPrevStepSizeTab_Agg = array2table(zeros(0,16));
    FinalVarNames = {'CurrDistPitch','CurrDistAmp','CurrDistDuration','CurrInterVocInt','CurrDist2D','CurrDist3D','Response',...
                              'PrevDistPitch','PrevDistAmp','PrevDistDuration','PrevInterVocInt','PrevDist2D','PrevDist3D','InfantID','AgeDays','AgeMonths'};
elseif IviOnly == 1
    CurrPrevStepSizeTab_Agg = array2table(zeros(0,6)); 
    FinalVarNames = {'Response','CurrInterVocInt','PrevInterVocInt','InfantID','AgeDays','AgeMonths'};
end

CurrPrevStepSizeTab_Agg.Properties.VariableNames = FinalVarNames; %set variable names for output table

for i = 1:numel(ZscoreDir) %go through list of files

    ZscoreFnRoot = erase(ZscoreDir(i).name, StringToRemoveFromFname); % get the root of the filename
    ZscoreTab = readtable(ZscoreDir(i).name,'Delimiter',',');
    
    [CurrPrevStepSizeTab, TotalMergeCt(i,1)] = Get_CurrPrevStepSizeTab(ZscoreTab,SpkrType, OtherType, NAType, ResponseWindow_s, IviOnly);

    %get infant id and age
    InfantID = cell(numel(CurrPrevStepSizeTab.CurrInterVocInt),1);
    [InfantID{:}] = deal(MetadataTab.InfantID(contains(MetadataTab.FileNameRoot,ZscoreFnRoot)));
    AgeDays = MetadataTab.InfantAgeDays(contains(MetadataTab.FileNameRoot,ZscoreFnRoot))*ones(numel(CurrPrevStepSizeTab.CurrInterVocInt),1);
    AgeMonths = MetadataTab.InfantAgeMonth(contains(MetadataTab.FileNameRoot,ZscoreFnRoot))*ones(numel(CurrPrevStepSizeTab.CurrInterVocInt),1);

    CurrPrevStepSizeTab.InfantID = InfantID;
    CurrPrevStepSizeTab.AgeDays = AgeDays;
    CurrPrevStepSizeTab.AgeMonths = AgeMonths;

    InfantIDvec{i,1} = InfantID{1};
    InfanAgeMonthVec(i,1) = AgeMonths(1);

    CurrPrevStepSizeTab_Agg = [CurrPrevStepSizeTab_Agg; CurrPrevStepSizeTab]; 
end

ZeroIviMergeDetails = table(TotalMergeCt,InfantIDvec,InfanAgeMonthVec);