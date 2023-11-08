clear all
clc

%Ritwika VPS
%Dec 2021
%Code to 
    %-run getIndividualAudioSegments.m on each .wav file in the LENAExports folder's subfolders; 
    %-to run getAcousticsTS for human labelled data
    %-to delete all the small wave files from getIndividualAudioSegments.m
        %after each iteration so memory isn't cluttered
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/';

%First, read .csv file with info about which .eaf file belongs to which infant ID
%The infant ID column is read in as double instead of string, so we have to
%force it to be read as string
opts = detectImportOptions(strcat(BasePath,'Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv'));
opts = setvartype(opts, 'InfantID', 'string');
EAFdetails = readtable(strcat(BasePath,'Data/HUMLabelData/A1_HUMLabelData_CleanupPipeline/SummaryCsvAndTxtFiles/EAFFileDetailsWithOldFN.csv'),opts);
%get filename and infant id
EAFfilename = EAFdetails.EafFileNameNew;
EAFinfantID = EAFdetails.InfantID;

%Go through parsed .eaf file info, match the files to .wav files, run
%IndividualAudioSegments and getAcousticsTS
%This is going to be based on identifying teh fileroot. For example, for
%'e2973927_217387_126836_section1.eaf', the fileroot is
%e2973927_217387_126836_section1, while for 'e3273797_3681623_3686.eaf',
%it is e3273797_3681623_3686

%get .wav file folder paths
WAVfolderpath = '/Users/ritwikavps/Library/CloudStorage/Box-Box/IVFCR Study/LENAExports_Renamed';%path for folders with .wav files
cd(WAVfolderpath)
WAVdir = dir('*'); %get all files and folders
N = setdiff({WAVdir([WAVdir.isdir]).name},{'.','..'}); %get all folders ONLY except the . and .. folders

%specifuy paths for AN and CH files
AnnotFilepath = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A2_EafLabelsOlpsProcessed');

cd(AnnotFilepath)

%get all relevant files
S = dir('*_OlpProcessed.csv');

for i = 1:numel(S) %go through files
    
    i
    
    fileroot = strrep(S(i).name,'_OlpProcessed.csv',''); %get fileroot by replacing '_AdultUttDirHumAnnot.csv' by blank
    
    %first, figure out which infant id each file corresponds to 
    for j = 1:numel(EAFfilename)
        if strcmp(fileroot,strrep(EAFfilename{j},'.eaf','')) == 1 %if there is a match
            InfantID = strcat('0',erase(EAFinfantID{j},'-')); %adding the 0 because the LENA_Exports Renamed folder has subfolder names with an extra 0
        end
    end   
    
    %go through the .wav file folders to see which one matches
    for j = 1:numel(N)
        FolderNameRoot = N{j};
        if contains(FolderNameRoot,InfantID) == 1
            WAVfilepath = strcat(WAVfolderpath,'/',N{j}); %get the path to the wav files
        end
    end
    
    %Once folder is identified, check if corresponding .wav file exists in
    %the folder
    cd(WAVfilepath)
    
    WAVfilename = strcat(fileroot,'.wav');
    TSfile = strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A3_TimeSeries/',fileroot,'_TS.csv');
    if (isfile(WAVfilename) == 1) && (isfile(TSfile) == 0) %if wave file exists and if TSfile does not exist in final folder, continue
        bigWavFile = strcat(WAVfilepath,'/',WAVfilename); %get wave file name with path
        OutFileBase = strcat('/Users/ritwikavps/Downloads/TempWavFiles/',fileroot);
        buffer = 0; %0 is the buffer value we want
        speakers = {'CHN','AN'}; %These are the speaker types we want (basically, speaker types are not filtered here 
        %cuz human listeners only idenytify CHN and AN speakers
        AnnotFile = strcat(AnnotFilepath,'/',fileroot,'_OlpProcessed.csv');
        getIndividualAudioSegmentsHUMlabel(AnnotFile,bigWavFile,OutFileBase,buffer,speakers)   
        
        %Get acoustics and timeseries for adult and CHN
        %Inputs:
            %SegmentsFile = The name of the Segments .csv file; same as
                %above
            %wavFileDir: The directory where the small audio segments live
            %wavfilebase: The name base for the .wav file segments
            %outFile: The path and name of the output file where you want the time series to be written
        wavFileDir = '/Users/ritwikavps/Downloads/TempWavFiles/';
        wavfilebase = fileroot;
        outFile =...
            strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/TempTS/',fileroot,'_TS.csv');
        getacousticsTS_HUMlabel(AnnotFile,wavFileDir,wavfilebase,outFile,speakers)

        %once complete, move file to TimeSeries folder (final destination)
        movefile(outFile,strcat(BasePath,'Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A3_TimeSeries/'));

        %delete all the small wavefiles created
        which_dir = '/Users/ritwikavps/Downloads/TempWavFiles/';
        filestr = strcat(which_dir,'/',fileroot,'*.wav');
        dinfo = dir(filestr); %get all contents for the specific file name root
        dinfo([dinfo.isdir]) = [];   %skip directories
        filenames = fullfile(which_dir, {dinfo.name}); %get filenames
        delete( filenames{:} ) %delete all
    end     
end

%A note: A couple files that are parts of day long recordings (with the
%suffix a, b, etc) don't find a wave file match, because the wave files
%aren't necessarily split up into a, b, etc. Make sure to check for this
%and do those manually if necessary

%TS, so might
%have to do this by hand. A couple others, where 
%ere 
