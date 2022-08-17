clear all
clc

%Ritwika VPS
%April 2021
%Code to 
    %-run getIndividualAudioSegments.m on each .wav file in the LENAExports folder's subfolders; 
    %-to run getAcousticsTS for all speakers, CHNSP only, and adult only
        %for the speciifc dataset (and store them in a TS folder)
    %-to delete all the small wave files from getIndividualAudioSegments.m
        %after each iteration so memory isn't cluttered        
        
%first, we need to go into each folder in LENAExports and then run each
%wave file
cd /Users/ritwikavps/Library/CloudStorage/Box-Box/'IVFCR Study'/LENAExports_Renamed/ %Insert your path

S = dir('*'); %get all files and folders
N = setdiff({S([S.isdir]).name},{'.','..'}); %get all folders ONLY except the . and .. folders

%numfiles = 0;

parfor i = 1:numel(N) %go through each subfolder; parallelising for faster processing
    
    desiredpath = strcat('/Users/ritwikavps/Library/CloudStorage/Box-Box/IVFCR Study/LENAExports_Renamed/',N{i});
    cd(desiredpath)
    
    newdir = dir('*.wav');
    
    for j = 1:numel(newdir) %go through each wavefile
        
        %numfiles = numfiles + 1
        
        %get the root of the filename - this is the bit that all associated
        %files will have in common
        %eg: e20170321_104125_010587.wav will have
        %e20170321_104125_010587.its, e20170321_104125_010587_Segments.csv,
        %etc
        NameRoot = strrep(newdir(j).name,'.wav','');  %replace .wav with blank so we can find same root file
        
        %Inputs for this:
            %SegmentsFile: the name of the segments csv file corresponding
                %to the wave file (with path)
            %bigWavFile: the wave files in the newdir structure: eg: e20170321_104125_010587.wav
            %OutFileBase: Where audio segments will be written + the beginning part of each segment filename
            %Buffer: Should be in seconds and will add some time to the beginning and ending of each audio segment before extracting it 
                % e.g., 0 or .3
            %speakers: An array holding the speaker types whose segments you would like to output. E.g. {'CHNSP','FAN','MAN'} for child speech-related, female adult, and male adult, "near" (loud) segments only. 
     
        SegmentsFile = strcat('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A2_Segments/',NameRoot,'_Segments.csv'); %to use in downstream function
        TSfile = strcat('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A4_TimeSeries/',NameRoot,'_TS.csv'); %to check if TS file exists

        if (isfile(SegmentsFile) == 1) && (isfile(TSfile) == 0)%continue ONLY if the corresponding segments file exists
           
            [i j] 

            %AND if the TSfile does not existm because we don't want to
            %repeat compiutations
            bigWavFile = strcat(desiredpath,'/',newdir(j).name);
            OutFileBase = strcat('/Users/ritwikavps/Downloads/TempWavFiles/',NameRoot);
            buffer = 0; %0 is the buffer value we want
            speakers = {'CHNSP','CHNNSP','FAN','MAN'}; %These are the speaker types we want
            getIndividualAudioSegments(SegmentsFile,bigWavFile,OutFileBase,buffer,speakers);

            %Get acoustics and timeseries for adult and CHNSP
            %Inputs:
                %SegmentsFile = The name of the Segments .csv file; same as
                    %above
                %wavFileDir: The directory where the small audio segments live
                %wavfilebase: The name base for the .wav file segments
                %outFile: The path and name of the output file where you want the time series to be written
            wavFileDir = '/Users/ritwikavps/Downloads/TempWavFiles/';
            wavfilebase = NameRoot;
            outFile = strcat('/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/TempTS/',NameRoot,'_TS.csv');
            speakers = {'CHNSP','CHNNSP','FAN','MAN'};
            getAcousticsTS(SegmentsFile,wavFileDir,wavfilebase,outFile,speakers);

            movefile(outFile,'/Volumes/GoogleDrive-104060580022184327356/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A4_TimeSeries');

            %delete all the small wavefiles created
            which_dir = '/Users/ritwikavps/Downloads/TempWavFiles';
            filestr = strcat(which_dir,'/',NameRoot,'*.wav');
            dinfo = dir(filestr); %get all contents for the specific file name root
            dinfo([dinfo.isdir]) = [];   %skip directories
            filenames = fullfile(which_dir, {dinfo.name}); %get filenames
            delete( filenames{:} ) %delete all
        end
        
    end 
end