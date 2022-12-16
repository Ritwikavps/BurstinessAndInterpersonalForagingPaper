function [ChnTab,AnTab] = OutputTableForSpaceStepsVsIntervocInt(DirStruct,DataDetailsTab,FileExtToErase,DataSource,AnnotList,ChildVocString,AdultVocString)

%Ritwika VPS< Sep 2022

%inputs: -structure with info from doing dir on relevant folder: DirStruct
        %-table with metadata details: DataDetailsTab (NOTE: this is a specific table, and the variable names are explictly used in the fn)
        %-standard string at the end of files in the dir'd folder to erase to get fileroot ofb the file: FileExtToErase
        %-Identifier for whether data is human labelled or matched LENA: DataSource
        %-specific annotations pick out cepending (ONLY FOR human labelled data): AnnotList
        %-strings to pick out relevant adult and child vocs (eg. CHNSP vs CHNNSP, AN, etc): ChildVocString, AdultVocString

%NOTE: for human labelled data: CHN and AN as relevant Voc strings works; for both kinds of LENA data, you need to specify CHNSP or CHNNSP


%initialise tables
ChnTab = array2table(zeros(0,6));
ChnTab.Properties.VariableNames = {'Steps2D','Steps3D','InterVocInterval','ChildAgeMonth','ChildAgeDays','ChildId'};
AnTab = array2table(zeros(0,6));
AnTab.Properties.VariableNames = {'Steps2D','Steps3D','InterVocInterval','ChildAgeMonth','ChildAgeDays','ChildId'};

for i = 1:numel(DirStruct)

    i

    %get child id, age (month and days): fill in if needed for st
    ChildID = DataDetailsTab.InfantID(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));
    ChildAgeDays = DataDetailsTab.InfantAgeDays(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));
    ChildAgeMonth = DataDetailsTab.InfantAgeMonth(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));

    %read table
    TableRead = readtable(DirStruct(i).name,'Delimiter',',');

    if strcmp(DataSource,'HumanLabels')
        %pick out CHNSP and AN vocs ONLY
        Pitch = TableRead.logf0_z(contains(TableRead.Annotation,AnnotList),:);
        Amplitude = TableRead.dB_z(contains(TableRead.Annotation,AnnotList),:);
        StartTime = TableRead.start(contains(TableRead.Annotation,AnnotList),:);
        EndTime = TableRead.xEnd(contains(TableRead.Annotation,AnnotList),:);
        SpeakerLabels = TableRead.speaker(contains(TableRead.Annotation,AnnotList),:);
        SectionNumVec = TableRead.SectionNum(contains(TableRead.Annotation,AnnotList),:);
    elseif strcmp(DataSource,'LENAmatch') %if matched LENA 5 minute labels; NOTE THAT we dont need to use AnnotList for any kind of data except human labelled
        Pitch = TableRead.logf0_z; Amplitude = TableRead.dB_z; StartTime = TableRead.start;
        EndTime = TableRead.xEnd; SpeakerLabels = TableRead.speaker; SectionNumVec = TableRead.SectionNum;
    elseif strcmp(DataSource,'LENAdaylong') %here, we need to also generate a section number vector
        Pitch = TableRead.logf0_z; Amplitude = TableRead.dB_z; StartTime = TableRead.start;
        EndTime = TableRead.xEnd; SpeakerLabels = TableRead.speaker; SubrecEnd = TableRead.SubrecEnd;

        %based on subrecend, generate SectionNumVec: basically, a vector identifying the section number the voc belongs to, if there are
        %subrecs in the recording
        SectionNumValue = 1; %default
        SectionNumVec = zeros(size(SubrecEnd)); %initialise
        for j = 1:numel(SubrecEnd)
            SectionNumVec(j) = SectionNumValue;
            if SubrecEnd(j) == 1
                SectionNumValue = SectionNumValue + 1; %if current voc is end of a subrec, increment section number value
            end
        end
    else
        error('DataSource string not recognised')
    end

    %get acoustic space step sizes and intervoc intervals for CHN and AN:
    %because we have already picked out only child C and X vocs, all CHN
    %vocs are now CHNSP
    ChildVocStruct = ComputeInterVocIntervalAndAcousticSpaceSteps(SectionNumVec(contains(SpeakerLabels,ChildVocString)),Pitch(contains(SpeakerLabels,ChildVocString)),...
                     Amplitude(contains(SpeakerLabels,ChildVocString)),StartTime(contains(SpeakerLabels,ChildVocString)),EndTime(contains(SpeakerLabels,ChildVocString)),...
                     ChildID,ChildAgeDays,ChildAgeMonth);

    AdultVocStruct = ComputeInterVocIntervalAndAcousticSpaceSteps(SectionNumVec(contains(SpeakerLabels,AdultVocString)),Pitch(contains(SpeakerLabels,AdultVocString)),...
                     Amplitude(contains(SpeakerLabels,AdultVocString)),StartTime(contains(SpeakerLabels,AdultVocString)),EndTime(contains(SpeakerLabels,AdultVocString)),...
                     ChildID,ChildAgeDays,ChildAgeMonth);

    ChnTab = [ChnTab; struct2table(ChildVocStruct)];
    AnTab = [AnTab; struct2table(AdultVocStruct)];

end
