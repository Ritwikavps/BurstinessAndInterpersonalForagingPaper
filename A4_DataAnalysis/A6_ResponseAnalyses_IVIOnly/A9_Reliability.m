clear all
clc

%Ritwika VPS, June 2024, UCLA Comm
%reliability code: this script estimates reliability measures between human-listener labelled 5 minute sections and corresponding LENA sections, by computing the following metrics:
% false alarm rate, miss rate, confusion rate, identification error rate, precision, and recall, per Cristia et al, 2021. Note that we use 1 ms frames as opposed to Cristia et al's 
% 10 ms frames, because the human listener labels are determined to 0.001 seconds.

%"These are calculated with the following formulas at the level of each clip, where:
    %- FA (false alarm) is the number of frames during which there is no talk according to the human annotator but during which LENA® found some talk; 
    %- M (miss) is the number of frames during which there is talk according to the human annotator but during which LENA® found no talk; 
    %- C (confusion) is the number of frames correctly classified by LENA® as containing talk, but whose voice type has not been correctly identified (when the LENA® model 
        % recognizes female adult speech where there is male adult speech for instance)
    %- T is the total number of frames that contain talk according to the human annotation
%Then, False alarm rate = FA/T; miss rate = M/T; confusion rate = C/T; Id error rate = (FA + M + C)/T


%THINGS WE CAN DO:
%-age trends in error rates and confusion/precision/recall matrices?



%CHNSP vs CHNSP; CHNNSP vs CHNNSP; CHN vs CHN; AN vs AN; AN vs T AN only
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATHS AND INPUT STRINGS ACCORDINGLY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/'; %set base path
UnannotatedFiles = readtable(strcat(BasePath,'A2_HUMLabelData_PostCleanUp/','FilesWithUnannotatedSections.csv')); %read in file with info about unannotated sections
CodingSheet = readtable(strcat(BasePath,'A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/FNSTETSimplified.csv')); %read in coding spreadsheet

HumFilesPath = strcat(BasePath,'A2_HUMLabelData_PostCleanUp/A9_NoAcoustics_0IviMerged_Hum/'); %get path to human listener labelled files
cd(HumFilesPath); StrForDir_H = '*_NoAcoustics_0IviMerged_Hum.csv';

HumFilesPath = strcat(BasePath,'A2_HUMLabelData_PostCleanUp/A11_NoAcoustics_0IviMerged_Hum_ChildDirANOnly/'); %get path to human listener labelled files
cd(HumFilesPath); StrForDir_H = '*_NoAcoustics_0IviMerged_ChildDirANOnly_Hum.csv'; %read in files
HumFiles = dir(StrForDir_H); %read in files

LENAFilesPath = strcat(BasePath,'A2_HUMLabelData_PostCleanUp/A10_NoAcoustics_0IviMerged_L5min/');%get path to corresponding LENA labelled files
cd(LENAFilesPath); LENAFiles = dir('*_NoAcoustics_0IviMerged_LENA5min.csv'); %read in files
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

%first check if both lena and human files have the same number of files.
if numel(HumFiles) ~= numel(LENAFiles)
    disp('Number of human-labelled files and corresponding LENA files is not equal')
end

H_StrToRemove = erase(StrForDir_H,'*');
for i = 1:numel(HumFiles) %go through list of human-labelled files

    if ~strcmp(erase(HumFiles(i).name,H_StrToRemove),erase(LENAFiles(i).name,'_NoAcoustics_0IviMerged_LENA5min.csv'))
        disp('Human-labelled file root and LENA file-root of the ith files in respective directories do not match')
    else
        FnameRoot = erase(HumFiles(i).name,H_StrToRemove); %get file name root
        CodingSubsheet = CodingSheet(contains(CodingSheet.FileName,FnameRoot),:); %get coding spreadsheet start and end times
        Hfile = readtable(HumFiles(i).name); Lfile = readtable(LENAFiles(i).name); %read human-listener labelled files
        [Hfile, NumAnnotSecs_H] = Get1msVocChunks(Hfile,CodingSubsheet); [Lfile, NumAnnotSecs_L] = Get1msVocChunks(Lfile,CodingSubsheet); %get 1 ms frames

        %DO: unannotated file check

        [Num_FA(i,1),Num_Miss(i,1),Num_Confusion_CHN(i,1),Num_Confusion(i,1)] = GetErrorNums(Hfile,Lfile);
        TotFrames(i,1) = numel(Hfile.speaker);
    end
end

%by recording
FAR = Num_FA./TotFrames; MissRate = Num_Miss./TotFrames; 
ConfRate_CHN = Num_Confusion_CHN./TotFrames; ConfRate = Num_Confusion./TotFrames;
IdErrRate_ConfCHN = FAR + MissRate + ConfRate_CHN;
IdErrRate_ConfReg = FAR + MissRate + ConfRate;

%totals
TotFAR = sum(Num_FA)/sum(TotFrames)
TotMR = sum(Num_Miss)/sum(TotFrames)
TotConfCHN = sum(Num_Confusion_CHN)/sum(TotFrames);
TotConfReg = sum(Num_Confusion)/sum(TotFrames)



%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%thsi function takes in the input table (with human or LENA speaker labels and onsets/offsets, vocs of the same type and in the case of human labels, .
%make everything in 1 ms increments +  adds 1 ms frames of NA speaker labels in between (for unlabelled portions in the case of human listener labels, and all other label
% types which we are not considering in our study, in the case of LENA labels. For the latter case, this includes labels such as SIL, OLN, MAF, CXN, etc.).
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [OpTab,NumAnnotSecs] = Get1msVocChunks(InputTab,CodingSubsheet)
   
%WRITE ABOUT INPUTS AND OUTPUTS
    InpVarNames = InputTab.Properties.VariableNames; %get variable names for input table

    if ~isempty(InpVarNames(contains(InpVarNames,'FileNameUnMerged'))) %rename variable names if applicable
        InputTab = renamevars(InputTab,'FileNameUnMerged','FnameUnmerged');
    end
    if ~isempty(InpVarNames(contains(InpVarNames,'wavfile'))) %remove obsolete columns
        InputTab = removevars(InputTab,'wavfile');
    end
    if ~isempty(InpVarNames(contains(InpVarNames,'Annotation')))
        InputTab = removevars(InputTab,'Annotation');
    end
    if ~isempty(InpVarNames(contains(InpVarNames,'SubrecEnd')))
        InputTab = removevars(InputTab,'SubrecEnd');
    end

    NumAnnotSecs = 0; %initialise number of annotated sections
    OpTab = array2table(zeros(0,width(InputTab))); OpTab.Properties.VariableNames = InputTab.Properties.VariableNames;%initialise output table and set variable names
    u_Secnum = unique(InputTab.SectionNum); %get unique section number

    for i = 1:height(CodingSubsheet) %go through 5 minute section per coding subsheet

        CodingSheetStart = CodingSubsheet.StartTimeSS(i); CodingSheetEnd = CodingSubsheet.EndTimeSS(i); %get start and end times of section from coding spreadsheet
        %subset input table using start and end times in coding spreadsheet for the labelled section. Note that we are allowing all vocs that end after coding spreadsheet start time
        % and start before coding spreadsheet end time.
        SubTab = InputTab(InputTab.xEnd >= CodingSheetStart & InputTab.start <= CodingSheetEnd & contains(InputTab.FnameUnmerged,CodingSubsheet.FileName{i}),:);
        CorrespSecNum = unique(SubTab.SectionNum); %get section number
        if numel(CorrespSecNum) > 1 %check if one section in coding spreadsheet has only one section number in the inpout table
            error('One start-end time pair from coding spreadsheet corresponds to more than one section in the data table.')
        end
        
        InputTab = setdiff(InputTab,SubTab); %remove subsetted rows from the input table (so we can test if after all sections--per coding spreadsheet--have been id'd, the inoput table
        %is empty); 
        u_Secnum = setdiff(u_Secnum,CorrespSecNum); %remove the current section number from the list of unique section numbers

        if ~isempty(SubTab) %if the section has been annotated, the subsetted table will have rows
            NumAnnotSecs = NumAnnotSecs + 1; %increment
            Times = (CodingSheetStart:0.001:CodingSheetEnd)'; %get 1 ms frames for the 5 minute section in question (per coding sheet)
            StartTimes = Times(1:end-1); EndTimes = Times(2:end); %get vectors of start and end times for this 1 ms breakdown
            SecNumVec = CorrespSecNum*ones(size(StartTimes)); %get section number vector for this
            FnameUnmergedTemp = cell(size(EndTimes)); FnameUnmergedTemp(1:end) = SubTab.FnameUnmerged(1); %get cell array populated with unmerged filename
            SpeakerTemp = cell(size(EndTimes)); SpeakerTemp(1:end) = {'NA-NotLab'}; %initialise Speaker label cell array to populate; here, 'NA-NotLab' indicates all frames that don't have a label
            %as far as our analyses are concerned
            IndVec = 1:numel(StartTimes); %get vector of indices to assign relevnt speaker labels
            for j = 1:numel(SubTab.speaker) %go through speaker labels in input subsetted table
                TempInd = IndVec(StartTimes >= SubTab.start(j) & EndTimes <= SubTab.xEnd(j)); %pick out all frames that constituite a given utterance
                SpeakerTemp(TempInd) = SubTab.speaker(j); %assign that speaker label to all those frames. The rest will simply have the NA-NotLab label
            end
    
            T_Temp = table(SpeakerTemp,StartTimes,EndTimes,FnameUnmergedTemp,SecNumVec); %make table for the section
            T_Temp.Properties.VariableNames = OpTab.Properties.VariableNames; %assign variable names
            OpTab = [OpTab; T_Temp]; %add to final output table
        end
    end

    %Checks: Check if input table is now empty after having all sections removed. Also check if there are unannotated sections.
    if ~isempty(InputTab)
        fprintf('Input table not fully empty after going through all coding sheet sections for file %s\n',InputTab.FnameUnmerged{1})
        InputTab
    end

%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    % %Note that these checks add more time to this analyses, so I would recommend uncommenting these once to do these checks and to comment them back every other time this file is executed.
    % % Also note that there is a total of 12 instances where the unique speaker label (Uq_Spkr) for speaker labels for 1 ms frames spanning an utterance or speaker lables for 1 ms frames
    % % spanning the time between utterances is empty. This is because of the fine-grainness of the human-label annotation onsets and offsets, and can be circumvented by using an even smaller
    % % frame length (eg. 0.5 ms). However, this would add even more time to the computation and 12 total instances of this happening does not (in my opinion) warrant doing this.
    % 
    % %checks: check that: 
    %     % 1) all 1 ms frames constituting a labelled utterance only has the label for that utterance.
    %     % 2) all 1 ms frames constituing times between utterances are labelled 'NA-NotLab'.
    % for i = 1:numel(u_Secnum) %go through each section
    %     OpSubTab = OpTab(OpTab.SectionNum == u_Secnum(i),:); %subset the output and input tables for the section number (the output table has the 1 ms frames and the input table has the orginal
    %     %utternace onsets and offsets)
    %     IpSubTab = InputTab(InputTab.SectionNum == u_Secnum(i),:);
    % 
    %     %Check 1
    %     for j = 1:height(IpSubTab)
    %         if IpSubTab.xEnd(j)-IpSubTab.start(j) > 0 %if the utterance has a duration
    %             Uq_Spkr = unique(OpSubTab(OpSubTab.start >= IpSubTab.start(j) & OpSubTab.xEnd <= IpSubTab.xEnd(j),:).speaker); %pick out all 1 ms frames that span the onset and offset
    %             %of a given utterance (per the input table), then get unique speaker labels
    %             if numel(Uq_Spkr) > 1  %if there is more than one unique speaker label, throw error 
    %                 error('More than one unique speaker label for 1 ms frames from utterance in question')
    %             elseif (~isempty(Uq_Spkr)) && (~strcmp(Uq_Spkr,IpSubTab.speaker(j)))%if the unique speaker label is different than the speaker label for the original utterance, throw error
    %                 error('Utterance speaker label (per input table) does not match unique speaker label from 1 ms frames')
    %             end
    % 
    %             if isempty(Uq_Spkr)
    %                 InputSubTab.FnameUnmerged(j)
    %             end
    %         end
    %     end
    % 
    %     %Check 2
    %     for j = 1:height(IpSubTab)-1 %here, we look for the time between utterances, so ith end to (i+1)th start, ergo the indexing in the for loop.
    %         if IpSubTab.start(j+1)-IpSubTab.xEnd(j) > 0 %if there is time between subsequent utterances
    %             Uq_Spkr = unique(OpSubTab(OpSubTab.start >= IpSubTab.xEnd(j) & OpSubTab.xEnd <= IpSubTab.start(j+1),:).speaker); %pick out all 1 ms frames that span the time between the 
    %             % offset of ith utterance and onset of the next utterance, then get unique speaker labels
    %             if numel(Uq_Spkr) > 1 %if there is more than one unique speaker label, throw error 
    %                 error('More than one unique speaker label for 1 ms frames between subsequent utterances')
    %             elseif (~isempty(Uq_Spkr)) && (~strcmp(Uq_Spkr,'NA-NotLab')) %if the unique speaker label is NOT NA-NotLab, throw error; the ~isempty condition is for cases when 
    %                 %the between-utterances is just one frame (eg. i=13 for file list, section number 1, utterance indices 149-150).
    %                 error('Unique speaker label for 1 ms frames between subsequent utterances is NOT NA-NotLab')
    %             end
    % 
    %             if isempty(Uq_Spkr)
    %                 InputSubTab.FnameUnmerged(j)
    %             end
    %         end
    %     end
    % end
%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
end

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
%This function computes number of false alarms, misses, and confusion
function [Num_FA,Num_Miss,Num_Confusion_CHN,Num_Confusion] = GetErrorNums(Hfile,Lfile)

%- FA (false alarm) is the number of frames during which there is no talk according to the human annotator but during which LENA® found some talk; 
%- M (miss) is the number of frames during which there is talk according to the human annotator but during which LENA® found no talk; 
%- C (confusion) is the number of frames correctly classified by LENA® as containing talk, but whose voice type has not been correctly identified (when the LENA® model 
    % recognizes female adult speech where there is male adult speech for instance)

    H_spkr = Hfile.speaker; L_spkr = Lfile.speaker;
    if numel(H_spkr) ~= numel(L_spkr)
        error('Human and LENA speaker labels have different lengths')
    end
    IndVec = 1:numel(H_spkr);

    %get logical for when human listener and LENA says no speech and when something is labelled as speech
    H_nospeech_Ind = IndVec(contains(H_spkr,'NA-NotLab')); H_speech_Ind =  IndVec(~contains(H_spkr,'NA-NotLab'));
    L_nospeech_Ind = IndVec(contains(L_spkr,'NA-NotLab')); L_speech_Ind = IndVec(~contains(L_spkr,'NA-NotLab')); 

    Num_FA = numel(intersect(H_nospeech_Ind,L_speech_Ind)); 
    Num_Miss = numel(intersect(H_speech_Ind,L_nospeech_Ind)); 

    %compute number of confusions
    LandH_speechInd = intersect(L_speech_Ind,H_speech_Ind); %when both agree is speech
    L_speech_spkr = L_spkr(LandH_speechInd); %get speech labels ONLY
    H_speech_spkr = H_spkr(LandH_speechInd);
    if sum(contains(unique(L_speech_spkr),'NA-NotLab')) + sum(contains(unique(H_speech_spkr),'NA-NotLab')) ~= 0
        error('Vector with ONLY speech labels contains NA-NotLab label')
    end
    
    Num_Confusion = GetNumConfusion({'AN','CHNNSP','CHNSP'},L_speech_spkr,H_speech_spkr);
    Num_Confusion_CHN = GetNumConfusion({'AN','CHN'},L_speech_spkr,H_speech_spkr);
    
end

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 
%This function computes the number of instances of confusion for different sets of speaker labels.
function Num_Confusion = GetNumConfusion(VocLabels,L_speech_spkr,H_speech_spkr)

    L_spkrcodes = zeros(size(L_speech_spkr)); H_spkrcodes = zeros(size(H_speech_spkr));
    for i = 1:numel(VocLabels)
        L_spkrcodes(contains(L_speech_spkr,VocLabels{i})) = i;
        H_spkrcodes(contains(H_speech_spkr,VocLabels{i})) = i;
    end
    Num_Confusion = numel(L_spkrcodes ~= H_spkrcodes);
end




