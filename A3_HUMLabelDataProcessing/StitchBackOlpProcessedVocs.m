function [OpLine] = StitchBackOlpProcessedVocs(SubTab)

%function to stitch back vocs that have been chopped up into non-overlapping chunks. This function takes the subsetted table (SubTab) for vocs with a common Voc Index as input, and outputs
% a single-rowed table with details about the re-constituted vocalisation from the chopped up subvocalisations.

%The pertinent details are as follows: SubTab has all the chopped up sub-vocs for an original vocalisation that has at least some overlap with another vocalisation. Notably, all 
% these sub-vocs have the same Voc Index, to identify that they are sub-vocs from the same un-chopped up voc. Given this, we have 2 possibilities:
    %- If all the sub-vocs are overlap, then all annotation and speaker labels in SubTab will be OLP. In this case, we can simply check that all sub-vocs add up to the original voc
        % (which we can verify by checking that the duration of the original voc--which we can estimate from the min start time and max end time in SubTab--and the sum of the durations of
        % the sub-vocs are the same). Once this check is done, we assign an empty table as the output for this case, since we won't be processing vocs that are all OLP in our data analyses.
    %- If there is at least one sub-voc that is non-OLP, then we check that the sub-vocs sum up to the original voc, that all the annotation/speaker labels that are not OLP are the same,
        % and then we reconstitute the voc by using a weighted average of the non-pverlapping acoustics. If any of the acoutic values for any of the sub-vocs is NA, then the whole voc is
        % assigned NA for acoustics. 

%first check that there are only chopped up vocs corresponding to one pre-chopping voc, and that the chopped up vocs and the original voc match 
if numel(unique(SubTab.VocIndex)) ~= 1
    error('More than one unique VocIndex')
end

u_Annot = unique(SubTab.Annotation); %get list of unique annotations
u_Spkr = unique(SubTab.speaker); %and the list of unique speaker labels

OpLine = SubTab(1,:); %initialise output line
OpLine.Properties.VariableNames = SubTab.Properties.VariableNames;

if (numel(u_Annot) == 1) && (numel(u_Spkr) == 1) %if there is only one unique annotation AND one unique speaker label
    if (strcmpi(u_Annot{1},'OLP') == 1) && (strcmpi(u_Spkr{1},'OLP') == 1) %check if that annotation/speaker label is OLP
        if (max(SubTab.xEnd)-min(SubTab.start)) ~= sum(SubTab.xEnd-SubTab.start) %if yes, check that the durations of the sub-vocs sum to the duration of the unchopped voc;
            %This works because we are looking at the mutually exclusive, buyt exhaustive chopped-up sub-vocs of one vocalisation.
            SubTab
            error('Sub-voc durations do not sum to duration of unchopped voc')
        end
        OpLine.start = min(SubTab.start); %set start time, etc of the re-constituted voc; This is just so that we can check to make sure that ALL vocs have been chopped up, processed,
        % and re-constituted correctly in the main script, before removing vocs that are fully OLP and saving the new data table. 
        OpLine.xEnd = max(SubTab.xEnd);
        OpLine.duration = OpLine.xEnd - OpLine.start;
    else
        error('There is only one unique annotation/speaker label but that is not OLP') %Because, by necessity, there has to be at least one OLP sub-voc, and it follows that if there is
        % only one unique annotation/speaker tag for all sub-vocs, it has to be OLP.
    end
else %now, if there is more than one unique annotation/speaker type, check to make sure that they are the same
    if (numel(setdiff(u_Annot,'OLP')) == 1) && (numel(setdiff(u_Spkr,'OLP')) == 1) %make sure that the set of unique annotations/speaker labels EXCEPT 'OLP' consists of only one element
        % (because this should be the case, since it is one voc being chopped up into overlapping and non-overlapping sub-vocs). 
        if (max(SubTab.xEnd)-min(SubTab.start)) ~= sum(SubTab.xEnd-SubTab.start) %if yes, check that the durations of the sub-vocs sum to the duration of the unchopped voc
            SubTab
            error('Sub-voc durations do not sum to duration of unchopped voc')
        else 
            OpLine.start = min(SubTab.start); %set start time, etc of the re-constituted voc
            OpLine.xEnd = max(SubTab.xEnd);
            OpLine.duration = OpLine.xEnd - OpLine.start;
            if OpLine.duration < 0 %sanity check error check
                error('start time < end time')
            end
            OpLine.Annotation = setdiff(u_Annot,'OLP');
            OpLine.speaker = setdiff(u_Spkr,'OLP');

            NotOlpFlag = ~contains(SubTab.speaker,'OLP');

            SubVocDuration_WtFrac = (SubTab.xEnd - SubTab.start)/sum(NotOlpFlag.*(SubTab.xEnd - SubTab.start)); %get fraction of the duration of sub-vocs wrt total duration that is not OLP                    

            OpLine.meanf0 = sum((SubTab.meanf0).*(SubVocDuration_WtFrac).*NotOlpFlag); %weighted average, excluding OLP. If there is an NA value for acoustics, the whole thing will sum to NaN
            OpLine.dB = sum((SubTab.dB).*(SubVocDuration_WtFrac).*NotOlpFlag);
        end
    else
        SubTab
        error('There are more than one non-OLP speaker or annotation label in SubTab.')
    end  
end
