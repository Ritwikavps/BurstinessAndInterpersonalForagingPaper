function [OutputStruct] = ComputeInterVocIntervalAndAcousticSpaceSteps(SectionNum,Pitch,Amplitude,Duration,StartTime,EndTime,Id,AgeDays,AgeMonths)

%Ritwika VPS, Sep 2022
%function to compute acoustic space steps (2d and 3d) and intervocalisation interval, given pitch, amplitude, duration, start and end times of vocs as
%well as information about section number (for 5 minute segments, this would just be the section number, while for daylong LENA data, all vocs
%from the start to end of a subrecording would belong to the same section)

%inputs: - start and end times of vocs; pitch, amplitude, and duration of vocs; and the section number for each voc
%outputs: structure with vectors of 2d (space = pitch and amp) and 3d (additional duration dimension) acoustic space steps, and intervocalisation interval,
    %accounting for the fact that steps between subrecordings or sections should not be counted (%Note that we aren't removing NaN values from step sizes at this time)

%[Note that diff does (i+1)-i.I always forget this and always need to check this!!!]

UniqSectionNum = unique(SectionNum); %get unqiue section numbers

Steps2D_vec = [];  Steps3D_vec = []; InterVocInterval_vec = []; %iniitialsie outputs (column vector)

for i = 1:numel(UniqSectionNum) %go through unique section numbers
    PitchSteps = diff(Pitch(SectionNum == UniqSectionNum(i))); %get pitch steps for ith section number
    AmpSteps = diff(Amplitude(SectionNum == UniqSectionNum(i))); %amp steps
    DurationSteps = diff(Duration(SectionNum == UniqSectionNum(i))); %duration steps

    Steps2D_vec = [Steps2D_vec; sqrt(PitchSteps.^2 + AmpSteps.^2)]; %get 2d steps -- append
    Steps3D_vec = [Steps3D_vec; sqrt(PitchSteps.^2 + AmpSteps.^2 + DurationSteps.^2)]; %get 3d steps -- append

    StartTimeTemp = StartTime(SectionNum == UniqSectionNum(i)); EndTimeTemp = EndTime(SectionNum == UniqSectionNum(i));
    InterVocInterval_vec = [InterVocInterval_vec;  StartTimeTemp(2:end) - EndTimeTemp(1:end-1)];
end

%recast empty matrices as []; this is because sometimes Steps2D_vec is cast ac 1x0 but intervoc interval is cast as 0x0 (or vice-versa) and this creates
%a problem for cell2mat-ing them
if isempty(Steps3D_vec)
    Steps3D_vec = [];
end
if isempty(Steps2D_vec)
    Steps2D_vec = [];
end
if isempty(InterVocInterval_vec)
    InterVocInterval_vec = [];
end

%chekc for negative inter-voc interval
if ~isempty(InterVocInterval_vec(InterVocInterval_vec < 0)) 
    disp('what is going on')
end

%check if size of all step sizes is the same
if ~isequal(size(Steps3D_vec),size(Steps2D_vec)) || ~isequal(size(Steps3D_vec),size(InterVocInterval_vec))
    error('Size of vectors of step sizes and/or intervoc interval do not match')
end

%put o/p into struicture
OutputStruct.Steps2D = Steps2D_vec; OutputStruct.Steps3D = Steps3D_vec; OutputStruct.InterVocInterval = InterVocInterval_vec;

%get age and id
OutputStruct.ChildAgeMonth = AgeMonths*ones(size(InterVocInterval_vec));
OutputStruct.ChildAgeDays = AgeDays*ones(size(InterVocInterval_vec));
ChildId_vec = cell(size(InterVocInterval_vec));
[ChildId_vec{:}] = deal(Id);
OutputStruct.ChildId = ChildId_vec;