function SectionNumVec = GetSectionNumVec(InputTab)

%This function generates a section number vector, that contains information about he section an utterance belongs to. So, all vocs upto the end of the
%first subrec will be tagged 1, all vocs from the start to end of the second subrec will be tagged 2, etc. This is so that the information from
%the Subrecend column of the input table (all data tables should have one) is copied into a more, shall we say, robust SectionNumVec vector, so that
%even if we filter by speaker type, we have information about whether 2 utterances are part of the same subrec or not. 

%<I really should have made this a function a while ago, but *shrugs*>

%based on subrecend, generate SectionNumVec: basically, a vector identifying the section number the voc belongs to, if there are
%subrecs in the recording
SectionNumValue = 1; %default
SectionNumVec = zeros(size(InputTab.SubrecEnd)); %initialise
for j = 1:numel(InputTab.SubrecEnd)
    SectionNumVec(j) = SectionNumValue;
    if InputTab.SubrecEnd(j) == 1
        SectionNumValue = SectionNumValue + 1; %if current voc is end of a subrec, increment section number value
    end
end