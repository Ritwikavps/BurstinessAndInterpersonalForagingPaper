function [OverLapFlag] = DetectOverlap(SortedTable)

%Ritwika VPS, July 2022, UCLA

%Function to get a flag vector flagging overlapping voc (OverLapFlag)
%Input: SortedTable - table with inf voc type and adult utt dir vocs, sorted by start time

%Get index vector, and initialise overlap flag vector as well as vector to store start
%times to be updated by removing the i-1th starttime
IndVec = 1:numel(SortedTable.StartTimeVal);
OverLapFlag = zeros(numel(SortedTable.StartTimeVal),1);
TempStartTime = SortedTable.StartTimeVal;

%go through vocs to see which ones overlap
for j = 1:numel(SortedTable.StartTimeVal)

    TempStartTime(j) = Inf; %set the current start time to infinity. This way, as we get to the next voc, the start time of
    %the prevous voc won't be flagged as pverlapping. And similarly,
    %the start time of the current voc will also not be flagged as
    %overlapping

    OverLapIndex = IndVec(TempStartTime < SortedTable.EndTimeVal(j)); %check if there are any start times 9of
    %subsequent vocs) that fall before the end of current voc
    if ~isempty(OverLapIndex) %if overlapindex is not empty
        OverLapFlag(j) = 1; %flag cureent voc as having overlap
        OverLapFlag(OverLapIndex) = 1; %flag overlappoing vocs as well  
    end
end

