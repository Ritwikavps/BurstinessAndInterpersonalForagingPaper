function DistTab = GetStepSizeTab(InputTab,VocType)

%This function computes step size vectors and intervocalisation interval
%vector based on input table. It also removes step size entries associated
%with the end of a subrecording

%The input is a table that contains (at the very least) columns
%('logf0_z','dB_z','duration','start','xEnd','SubrecEnd')

SectionNumVec = GetSectionNumVec(InputTab); %get section number information

InputTab.SectionNum = SectionNumVec; %add section number information to InputTab
InputTab = InputTab(contains(InputTab.speaker,VocType),:);

U_SectionNumVec = unique(SectionNumVec);

%create empty table to store distances
DistTab = array2table(zeros(0,3)); 
DistTab.Properties.VariableNames = {'DistPitch','DistAmp','DistDuration'};
InterVocIntVec = []; %empty vector to store intervoc intervals

%create empty table to store the rest of the info needed, after removing redundant or unnecessary cols: usually this would be response info
DuplicateTab = removevars(InputTab(1:10,:),{'dB_z','logf0_z','start','duration','xEnd','SubrecEnd'}); %thsi is just to get teh number of columns as well as variable names,
NumCols = size(DuplicateTab,2);
RestOfTab = array2table(zeros(0,NumCols)); 
RestOfTab.Properties.VariableNames = DuplicateTab.Properties.VariableNames;

for i = 1:numel(unique(U_SectionNumVec)) %go through each unique section and get step sizes. This way, we don't add step sizes between subrecs

    Section_SubTab = InputTab(InputTab.SectionNum == U_SectionNumVec(i),:); %pick out rows with the same section number

    TempTab = varfun(@diff, Section_SubTab(:,{'logf0_z','dB_z','duration'}), 'OutputFormat', 'table'); %compute distances for each section
    TempTab = varfun(@abs, TempTab, 'OutputFormat', 'table'); %get abs value
    TempTab.Properties.VariableNames = {'DistPitch','DistAmp','DistDuration'};
    DistTab = [DistTab; TempTab];

    %inter voc interval
    InterVocIntVec  = [InterVocIntVec ; Section_SubTab.start(2:end) - Section_SubTab.xEnd(1:end-1)];

    %get rest of the table to add to DistTab, after the end of the loop. Note that the last entry in each 
    %column has to be removed, since this isn't going to be associated with a step size
    Section_SubTab = removevars(Section_SubTab,{'dB_z','logf0_z','start','duration','xEnd','SubrecEnd'});
    RestOfTab = [RestOfTab; Section_SubTab(1:end-1,:)];

end

%add additional step size columns
DistTab.InterVocInt = InterVocIntVec; %add inter voc interval
DistTab.Dist2D = sqrt((DistTab.DistPitch).^2 + (DistTab.DistAmp).^2); %add 2d and 3d step sizes
DistTab.Dist3D = sqrt((DistTab.DistPitch).^2 + (DistTab.DistAmp).^2 + (DistTab.DistDuration).^2);

DistTab = [DistTab RestOfTab]; %plop tables together

