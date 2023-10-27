function [OpTab] = OutputTableForCategoricalStepsVsIntervocInt(DirStruct,DataDetailsTab,FileExtToErase,DataSource,AnnotOrSpeakerList,Type1)

%Ritwika VPS< Sep 2022

%inputs: -structure with info from doing dir on relevant folder: DirStruct
        %-table with metadata details: DataDetailsTab (NOTE: this is a specific table, and the variable names are explictly used in the fn)
        %-standard string at the end of files in the dir'd folder to erase to get fileroot ofb the file: FileExtToErase
        %-Identifier for whether data is human labelled or matched LENA: DataSource
        %-specific annotations or speakerlabels to pick out cepending (ONLY FOR human labelled data): AnnotOrSpeakerList
            %for example, if we are trying to find the relationship between
            %the intervoc interval and categorical steps between X and C,
            %then we need to filter the inputs, so that only these
            %annotation labels are inputted. 
        %-annotation or speaker label type(s) that are designated type 1 (eg. annotation type 'C' or speaker type CHNSP): Type1

%initialise tables
OpTab = array2table(zeros(0,7));
OpTab.Properties.VariableNames = {'CategoricalSteps','InterVocInterval','SpaceSteps2d','SpaceSteps3d','ChildAgeMonth','ChildAgeDays','ChildId'};

for i = 1:numel(DirStruct) %go through DirStruct

    %i

    %get child id, age (month and days): fill in if needed for st
    ChildID = DataDetailsTab.InfantID(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));
    ChildAgeDays = DataDetailsTab.InfantAgeDays(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));
    ChildAgeMonths = DataDetailsTab.InfantAgeMonth(contains(DataDetailsTab.FileNameRoot,erase(DirStruct(i).name,FileExtToErase)));

    %read table
    TableRead = readtable(DirStruct(i).name,'Delimiter',',');

    if strcmp(DataSource,'HumanLabels')
        %pick out CHN (either all CHN or X and C only) vocs ONLY
        StartTime = TableRead.start(contains(TableRead.Annotation,AnnotOrSpeakerList),:);
        EndTime = TableRead.xEnd(contains(TableRead.Annotation,AnnotOrSpeakerList),:);
        Pitch = TableRead.logf0_z(contains(TableRead.Annotation,AnnotOrSpeakerList),:);
        Amplitude = TableRead.dB_z(contains(TableRead.Annotation,AnnotOrSpeakerList),:);

        AnnotationLabel = TableRead.Annotation(contains(TableRead.Annotation,AnnotOrSpeakerList),:);
        SpeakerLabels = [];
        SectionNumVec = TableRead.SectionNum(contains(TableRead.Annotation,AnnotOrSpeakerList),:);
    elseif strcmp(DataSource,'LENAmatch') %if matched LENA 5 minute labels, we pick out CHN vocs + read the section number vec
        StartTime = TableRead.start(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        EndTime = TableRead.xEnd(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        Pitch = TableRead.logf0_z(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        Amplitude = TableRead.dB_z(contains(TableRead.speaker,AnnotOrSpeakerList),:);

        AnnotationLabel = [];
        SpeakerLabels = TableRead.speaker(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        SectionNumVec = TableRead.SectionNum(contains(TableRead.speaker,AnnotOrSpeakerList),:);
    elseif strcmp(DataSource,'LENAdaylong') %here, we need to also generate a section number vector
        StartTime = TableRead.start(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        EndTime = TableRead.xEnd(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        Pitch = TableRead.logf0_z(contains(TableRead.speaker,AnnotOrSpeakerList),:);
        Amplitude = TableRead.dB_z(contains(TableRead.speaker,AnnotOrSpeakerList),:);

        AnnotationLabel = [];
        SpeakerLabels = TableRead.speaker(contains(TableRead.speaker,AnnotOrSpeakerList),:); 
        
        SubrecEnd = TableRead.SubrecEnd;

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

        SectionNumVec = SectionNumVec(contains(TableRead.speaker,AnnotOrSpeakerList),:);
    else
        error('DataSource string not recognised')
    end

    %get acoustic space step sizes and intervoc intervals for CHN and AN:
    %because we have already picked out only child C and X vocs, all CHN
    %vocs are now CHNSP
    ChildVocStruct = ComputeInterVocIntervalAndCategoricalSteps(StartTime,EndTime,AnnotationLabel,SpeakerLabels,SectionNumVec,Type1,ChildID,ChildAgeDays,ChildAgeMonths,Pitch,Amplitude);

    OpTab = [OpTab; struct2table(ChildVocStruct)];

end
