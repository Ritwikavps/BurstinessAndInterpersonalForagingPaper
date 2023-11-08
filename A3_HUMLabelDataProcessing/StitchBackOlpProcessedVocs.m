function [StartTimeOut,EndTimeOut,PitchOut,dBOut] = StitchBackOlpProcessedVocs(WholeVocLine,TSlines)

%function to stitch back vocs that have been chopped up into
%non-overlapping chunks. This function does the following:
%-set start and end times to that of non-olp processed voc
%-compute pitch and amplitude of the non-chopped up voc by doing a weighted
%average of the chopped up vocs (NA if one or more of the
%pitch/amplitude of the chopped up voc is NA)

%WholeVocLine is the row of the eaf labels table for the target voc
%TSlines are the rows of the time series table corresponding to the target voc with overlaps processed

%first check that there are only chopped up vocs corresponding to one pre-chopping voc,
% and that the chopped up vocs and the original voc match (as a
%sanity check)
if numel(unique(TSlines.VocIndex)) ~= 1
    error('More than one unique VocIndex')
end

if unique(TSlines.VocIndex) ~= WholeVocLine.VocIndex
    error('VocIndex(s) of Chopped up vocs and pre-chopped up voc do not match')
end

StartTimeOut = WholeVocLine.StartTimeVal/1000; %assign start and end times
EndTimeOut = WholeVocLine.EndTimeVal/1000;

MainDuration = (WholeVocLine.EndTimeVal - WholeVocLine.StartTimeVal)/1000; %get duration of unchopped voc
if MainDuration < 0 %sanity check error check
    error('start time < end time')
end

%to get amplitude and pitch values, first determine how many constituent
%vocs there are
NumSmallVocs = numel(TSlines.VocIndex);

%get how much each chopped-up voc contributes to the main voc
for i = 1:NumSmallVocs

    DurationSubVoc = TSlines.xEnd(i) - TSlines.start(i); %get duration of each voc
    if DurationSubVoc < 0 %sanity check error check
        error('start time < end time')
    end

    %set duratiaon fraction to NaN if pitch or amplitude values is NaN, else compute
    %fraction of duration
    if ~isnan(TSlines.meanf0(i)) %if pitch is NaN
        DurFracPitch(i,1) = DurationSubVoc/MainDuration;
    else
        DurFracPitch(i,1) = NaN;
    end

    %simiarly for amplitude
    if ~isnan(TSlines.dB(i)) 
        DurFracdB(i,1) = DurationSubVoc/MainDuration;
    else
        DurFracdB(i,1) = NaN;
    end

end

%rebalance durationb fractions so the vector sums to 1 (excluding NaN)
DurFracPitch = DurFracPitch/sum(DurFracPitch(~isnan(DurFracPitch)));
DurFracdB = DurFracdB/sum(DurFracdB(~isnan(DurFracdB)));

%get weighted sum of pitch and amplitude for the stitched back up voc
PitchOut = DurFracPitch.*TSlines.meanf0; %elemenet by element multiplication
if ~isempty(PitchOut(~isnan(PitchOut)))  %if there is at least one non-NaN value
    PitchOut = sum(PitchOut(~isnan(PitchOut))); %mean excluding nan
else
    PitchOut = NaN;
end

%similarly for dB
dBOut = DurFracdB.*TSlines.dB;
if ~isempty(dBOut(~isnan(dBOut))) 
    dBOut = sum(dBOut(~isnan(dBOut))); %mean excluding nan
else
    dBOut = NaN;
end



