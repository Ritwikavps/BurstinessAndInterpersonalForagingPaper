function [Duration] = GetUttDurations(FilePath,StringForDir,SpkrType)

%This function reads in time series files and gets utterance durations from time series data. This function does this for LENA day-long, LENA 5 min, and human-listener labelled data, 
% and for combos of CHNSP and AN spekers.
%Inputs: - FilePath: path to the files to read in
       % - StringForDir: the string used as input to dir().
       % - SpkrType: the target speaker

cd(FilePath) %go to file path
aa = dir(StringForDir); %get list of desired files

%check to make sure that SpkrType is acceptable string
if sum(strcmpi(SpkrType,{'CHNSP','CHNNSP','CHN','AN'})) == 0
    error('Incorrect SpkrType string')
end

Duration = []; %initialise empty vector to store duration in 

for i = 1:numel(aa) %go through list of files
    DataTab = readtable(aa(i).name); %read table
    
    if size(DataTab,1) ~= 0  %mandatory checks ; if table is empty, then this whole exercise is pointless.    
        DataTab = DataTab(contains(DataTab.speaker,SpkrType),:); %filter by target speaker type

        Dur_Temp = DataTab.xEnd - DataTab.start; %compute duration
        Duration = [Duration; Dur_Temp]; %append temp table to output table
    end
end
