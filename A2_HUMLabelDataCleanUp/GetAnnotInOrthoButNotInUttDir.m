function T_AnnotInOrthoTierButNotAdultUttDirTier_out = GetAnnotInOrthoButNotInUttDir(TierInfoTable,EafFilename,T_AnnotInOrthoTierButNotAdultUttDirTier)

%Ritwika VPS, JUne 2022

%function to check whether any annotations that are in the adult
%orthographic transcription tier are missing from the utternace direction
%tier

%inputs: TierInfoTable: Table with info parsed from eaf file (col nameS: %Clumn names: StartTimeRef, StartTimeLineNum, 
                        %EndTimeRef, EndTimeLineNum, AnnotId, AnnotIdLineNum, Annotation, AnnotationLineNum
                        %TierTypeVec, StartTimeVal, EndTimeVal, EafFnam)
        %T_AnnotInOrthoTierButNotAdultUttDirTier: initialised table with mismatched or incorrect tiers 
                        %that we continue to populate
        %Eaf file name
%output: T_AnnotInOrthoTierButNotAdultUttDirTier_out populated with mismatched or
        %otherwise incorrect annotations from this run of the function

%first get subtables contaiing only orthographic annotations, and adult utterance dir annotation 
T_AdultOrthoTranscrip = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Adult Ortho'),:);
T_AdultUttDirAnnot = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Adult Utterance Dir'),:);

%check if there are repeats in the start and end times for both tables 
UniqCheck = [abs(numel(T_AdultUttDirAnnot.StartTimeVal)-numel(unique(T_AdultUttDirAnnot.StartTimeVal))) 
    abs(numel(T_AdultUttDirAnnot.EndTimeVal)-numel(unique(T_AdultUttDirAnnot.EndTimeVal)))
    abs(numel(T_AdultOrthoTranscrip.StartTimeVal)-numel(unique(T_AdultOrthoTranscrip.StartTimeVal)))
    abs(numel(T_AdultOrthoTranscrip.EndTimeVal)-numel(unique(T_AdultOrthoTranscrip.EndTimeVal)))];
if sum(UniqCheck) > 0
    fprintf('There are duplicate time values in %s \n',EafFilename) %verified that there are no duplicate time entries
end

%now go through the orthographic table start and end times and compare to adult utterance direction start and end time
for j = 1:numel(T_AdultOrthoTranscrip.StartTimeRef)
    if (~ismember(T_AdultOrthoTranscrip.StartTimeVal(j),T_AdultUttDirAnnot.StartTimeVal)) ...
            || (~ismember(T_AdultOrthoTranscrip.EndTimeVal(j),T_AdultUttDirAnnot.EndTimeVal)) %if either start or end time of any orthographic annotation
        %is missing in the utterance direction tier, add to the table
        %keeping track of this
        T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_AdultOrthoTranscrip(j,:)];
    end 
end

T_AnnotInOrthoTierButNotAdultUttDirTier_out = T_AnnotInOrthoTierButNotAdultUttDirTier;