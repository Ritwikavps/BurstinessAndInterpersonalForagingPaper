function T_AnnotInOrthoTierButNotAdultUttDirTier_out = GetAnnotInOrthoButNotInUttDir(TierInfoTable,EafFilename,T_AnnotInOrthoTierButNotAdultUttDirTier)

%Ritwika VPS, JUne 2022

%function to check whether any annotations that are in the adult
%orthographic transcription tier are missing from the utternace direction
%tier
%In addition, this function also identifies annotations that are in the
%music and background overlap tiers but missing from the utterance
%direction tier or vice versa. Thsi was added after the function was
%originally written, so I haven't bothered changing the function name

%inputs: TierInfoTable: Table with info parsed from eaf file (col nameS: %Clumn names: StartTimeRef, StartTimeLineNum, 
                        %EndTimeRef, EndTimeLineNum, AnnotId, AnnotIdLineNum, Annotation, AnnotationLineNum
                        %TierTypeVec, StartTimeVal, EndTimeVal, EafFnam)
        %T_AnnotInOrthoTierButNotAdultUttDirTier: initialised table with mismatched or incorrect tiers 
                        %that we continue to populate
        %Eaf file name
%output: T_AnnotInOrthoTierButNotAdultUttDirTier_out populated with mismatched or
        %otherwise incorrect annotations from this run of the function

%first get subtables contaiing only orthographic annotations, adult
%utterance dir annotation, music, and background overlap tiers
T_AdultOrthoTranscrip = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Adult Ortho','IgnoreCase',true),:);
T_AdultUttDirAnnot = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Adult Utterance Dir','IgnoreCase',true),:);
T_Music = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Music','IgnoreCase',true),:);
T_BgOlp = TierInfoTable(contains(TierInfoTable.TierTypeVec,'Background Overlap','IgnoreCase',true),:); 

%check if there are repeats in the start and end times for both tables 
UniqCheck = [abs(numel(T_AdultUttDirAnnot.StartTimeVal)-numel(unique(T_AdultUttDirAnnot.StartTimeVal))) 
    abs(numel(T_AdultUttDirAnnot.EndTimeVal)-numel(unique(T_AdultUttDirAnnot.EndTimeVal)))
    abs(numel(T_AdultOrthoTranscrip.StartTimeVal)-numel(unique(T_AdultOrthoTranscrip.StartTimeVal)))
    abs(numel(T_AdultOrthoTranscrip.EndTimeVal)-numel(unique(T_AdultOrthoTranscrip.EndTimeVal)))
    abs(numel(T_Music.StartTimeVal)-numel(unique(T_Music.StartTimeVal))) 
    abs(numel(T_Music.EndTimeVal)-numel(unique(T_Music.EndTimeVal)))
    abs(numel(T_BgOlp.StartTimeVal)-numel(unique(T_BgOlp.StartTimeVal)))
    abs(numel(T_BgOlp.EndTimeVal)-numel(unique(T_BgOlp.EndTimeVal)))];

if sum(UniqCheck) > 0
    fprintf('There are duplicate time values in %s \n',EafFilename) %verified that there are no duplicate time entries
end
 
if ~isempty(T_AdultUttDirAnnot) %only proceed if utt dir table not empty

    if ~isempty(T_AdultOrthoTranscrip)
        %now go through the orthographic table start and end times and compare to adult utterance direction start and end time
        for j = 1:numel(T_AdultOrthoTranscrip.StartTimeRef)
            if (~ismember(T_AdultOrthoTranscrip.StartTimeVal(j),T_AdultUttDirAnnot.StartTimeVal)) ...
                    || (~ismember(T_AdultOrthoTranscrip.EndTimeVal(j),T_AdultUttDirAnnot.EndTimeVal)) %if either start or end time of any orthographic annotation
                %is missing in the utterance direction tier, add to the table
                %keeping track of this
                T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_AdultOrthoTranscrip(j,:)];
            end 
        end
    end
    
    %------------------------------------------------------------------------------------------------------------------------------------------------------------
    if ~isempty(T_Music)
        %go through music tier and check if there are music tier annotationns that
        %are not present in the adult utterance direction tier
        for j = 1:numel(T_Music.StartTimeRef)
            if (~ismember(T_Music.StartTimeVal(j),T_AdultUttDirAnnot.StartTimeVal)) ...
                    || (~ismember(T_Music.EndTimeVal(j),T_AdultUttDirAnnot.EndTimeVal)) %if either start or end time of any music annotation
                %is missing in the utterance direction tier, add to the table
                %keeping track of this
                T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_Music(j,:)];
            end 
        end
        
        %go through utterance direction tier and check if there are utterance direction tier annotationns that
        %are not present in the music tier
        for j = 1:numel(T_AdultUttDirAnnot.StartTimeRef)
            if (~ismember(T_AdultUttDirAnnot.StartTimeVal(j),T_Music.StartTimeVal)) ...
                    || (~ismember(T_AdultUttDirAnnot.EndTimeVal(j),T_Music.EndTimeVal)) %if either start or end time of any utterance dir annotation
                %is missing in the music tier, add to the table
                %keeping track of this
                T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_AdultUttDirAnnot(j,:)];
            end 
        end
    end
    
    %------------------------------------------------------------------------------------------------------------------------------------------------------------
    if ~isempty(T_BgOlp)
        %Do simiarlly for background overlap tier and utterance direction tier
        %go through background olp tier and check if there are background olp tier annotationns that
        %are not present in the adult utterance direction tier
        for j = 1:numel(T_BgOlp.StartTimeRef)
            if (~ismember(T_BgOlp.StartTimeVal(j),T_AdultUttDirAnnot.StartTimeVal)) ...
                    || (~ismember(T_BgOlp.EndTimeVal(j),T_AdultUttDirAnnot.EndTimeVal)) %if either start or end time of any background olp annotation
                %is missing in the utterance direction tier, add to the table
                %keeping track of this
                T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_BgOlp(j,:)];
            end 
        end
    
        %go through utterance direction tier and check if there are utterance direction tier annotationns that
        %are not present in the backgroiund olp tier
        for j = 1:numel(T_AdultUttDirAnnot.StartTimeRef)
            if (~ismember(T_AdultUttDirAnnot.StartTimeVal(j),T_BgOlp.StartTimeVal)) ...
                    || (~ismember(T_AdultUttDirAnnot.EndTimeVal(j),T_BgOlp.EndTimeVal)) %if either start or end time of any utterance dir annotation
                %is missing in the background olp tier, add to the table
                %keeping track of this
                T_AnnotInOrthoTierButNotAdultUttDirTier = [T_AnnotInOrthoTierButNotAdultUttDirTier; T_AdultUttDirAnnot(j,:)];
            end 
        end
    end
end

T_AnnotInOrthoTierButNotAdultUttDirTier_out = T_AnnotInOrthoTierButNotAdultUttDirTier;