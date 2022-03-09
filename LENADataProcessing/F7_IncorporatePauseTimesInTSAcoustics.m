clear all
clc

%Ritwika VPS; Feb 2022
%UCLA, Dpmt of Comm

%Code to account for recorder pause times in acoustics time series (LENA
%data)

%get path for acoustics time series and pause times
TSpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/TimeSeries';
PausePath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/PauseTimes';

%go to time series folder and dir; and same for pause times folder
cd(TSpath)
TSdir = dir('*TS.csv');

cd(PausePath)
Pausedir = dir('*PauseTimes.txt');

%get destination path
destinationpath = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/TimeSeriesWPauses/';

%The idea is to label the last adult/infant event in a subrecording with a
%1, and all other events with 0. So, thsi would look something like this:
% AN  - start time - end time - ----- lastevent = 0
% CHN - start time - end time - ----- lastevent = 0
% CHN  - start time - end time - ----- lastevent = 0
% CHN - start time - end time - ----- lastevent = 0
% AN  - start time - end time - ----- lastevent = 1
% CHN - start time - end time - ----- lastevent = 0

%Then, if the ith event is indexed with 1 for lastevent, the step (i+1)-i
%won't be counted
for i = 1:numel(TSdir) %go throigh TS files, read each and read in corresponding pause times file
    
    TStab = readtable(TSdir(i).name,'Delimiter',','); %read TS file; delimiter here ensures that all files are read in correctly
    TSfileroot = strrep(TSdir(i).name,'_TS.csv',''); %get file root
    SubrecEnd = zeros(size(TStab.xEnd)); %initialise vector of zeros to store end of subrecording index
    FoundMatch = 0; %flag to see if there is a missing pausetime svariable

    NewFileName = strcat(destinationpath,TSfileroot,'_TSwPauses.csv');

    if isfile(NewFileName) == 0 %proceed only if file doesnt already exist

        for j = 1:numel(Pausedir) %find matching pause times file and read
            
            if strcmp(TSfileroot,strrep(Pausedir(j).name,'_PauseTimes.txt','')) == 1
                
                FoundMatch = FoundMatch + 1;
                Pausetab = readtable(Pausedir(j).name);
    
                %procedd only if there ARE pauses: note that readtable only
                %reads as not-empty if there is more than one row in the pause
                %time info. If there is only one row, taht means there were no
                %pauses, so this is perfectly fine
                if isempty(Pausetab) == 0
                    i
                    TerminateInd = zeros(size(Pausetab.Var2)); %initialise vector to store indices for last end times in subrec
        
                    %index the last end time in each subrecording with 1, for the SubrecEnd
                    %variable and append it to thje TS table
                    for k = 1:numel(Pausetab.Var1)
                        EndIndex = 1:numel(TStab.xEnd); %temporary vector with indices for End times
                        TempEnd = EndIndex(TStab.xEnd <= Pausetab.Var2(k)); %pick out all end times less than or equal to each pause time; 
                        %Var2 is the one storing the end time of each subrec
                        if isempty(TempEnd) == 0 %if there ARE end time indices before pause
                            TerminateInd(k) = TempEnd(end); %get index of the last entry in this subset
                        end
                    end
        
                    TerminateInd = TerminateInd(TerminateInd ~= 0); %remove zeros from terminateind
                    SubrecEnd(TerminateInd) = 1; %if an end time is the last in a subrecording, index it with one
                end
            end
        end
    
        TStab.SubrecEnd = SubrecEnd; %append vector to TStab
        
        %warnings
        if FoundMatch == 0
            disp('This TS file does not have a matching Pause Times file')
            TSfileroot
        elseif FoundMatch > 1
            disp('This TS file has multiple matching Pause times files')
        end
    
        %write TS with pause info to file
        writetable(TStab,NewFileName)    
    end
end





