clear all
clc

%This script goes through all 3 sets of daat (LENA day-long, human label 5 min, and corresponding LENA 5 min) and merges vocs of a given speaker type separated by 0 IVI (or in the human label case, less
% than 600 ms IVI, which is the IVI cut-off for LENA). Note that we treat CHNSP, CHNNSP, and AN (both FAN and MAN together) speaker types differently.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%PLEASE CHANGE PATHS AND STRINGS IN FUNCTION CALL APPROPRIATELY
BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/';%This is the base path to the google drive folder that may undergo change
%read in table with .its file details
cd(strcat(BasePath,'MetadataFiles/'));
opts = detectImportOptions('MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
MetadataTab = readtable('MergedTSAcousticsMetadata.csv',opts);

%LENA (day-long) specific inputs; 
LENA_ZscoreDataPath = strcat(BasePath,'LENAData/A7_ZscoredTSAcousticsLENA/');
LENA_DestinationPath = strcat(BasePath,'LENAData/A8_NoAcoustics_0IviMerged_LENA/');
LENA_StringToRemoveFromFname = '_ZscoredAcousticsTS_LENA.csv';
LENA_StringToAddToFname = '_NoAcoustics_0IviMerged_LENA.csv';

%human listener labelled data specific inputs
H_ZscoreDataPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A7_HlabelTS_Zscored/');
H_DestinationPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A9_NoAcoustics_0IviMerged_Hum/');
H_StringToRemoveFromFname = '_ZscoredAcousticsTS_Hum.csv';
H_StringToAddToFname = '_NoAcoustics_0IviMerged_Hum.csv';

%match ed 5 min LENA data specific inputs
LENA_5min_ZscoreDataPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A8_MatchedLENAZscoreSections/');
LENA_5min_DestinationPath = strcat(BasePath,'/HUMLabelData/A2_HUMLabelData_PostCleanUp/A10_NoAcoustics_0IviMerged_L5min/');
LENA_5min_StringToRemoveFromFname = '_MatchedLENA_ZscoreTS.csv';
LENA_5min_StringToAddToFname = '_NoAcoustics_0IviMerged_LENA5min.csv';
%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%do for all three labelling methoids
Save0IviMerged_NoAcousticsTabs(LENA_ZscoreDataPath,LENA_DestinationPath,LENA_StringToRemoveFromFname,LENA_StringToAddToFname,MetadataTab) %LENA day long
Save0IviMerged_NoAcousticsTabs(LENA_5min_ZscoreDataPath,LENA_5min_DestinationPath,LENA_5min_StringToRemoveFromFname,LENA_5min_StringToAddToFname,MetadataTab) %LENA 5 min
Save0IviMerged_NoAcousticsTabs(H_ZscoreDataPath,H_DestinationPath,H_StringToRemoveFromFname,H_StringToAddToFname,MetadataTab) %hum label

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [] = Save0IviMerged_NoAcousticsTabs(ZscorePath,DestinationPath,StringToRemoveFromFname,StringToAddToFname,MetadataTab)

    %this function reads in all files from the given directory (ZscoreDir), removes acoustics (pitch, amplitude, and duration), and merges all vocs of a given speaker type that are separated by 0 IVI (or in the
    % case of human listener labelled data, separated by 600 ms, since this is the LENA ivi tolerance, and we want to match the LENA process as closely as possible). Then, these new tables as well a table 
    % with details of how many voc merges were performed for each speaker type (FAN and MAN treated as a single AN type) are saved.

    %Get Zscored data
    cd(ZscorePath); ZscoreDir = dir(strcat('*',StringToRemoveFromFname));

    for i = 1:numel(ZscoreDir) %go through list of files
    
        ZscoreFnRoot = erase(ZscoreDir(i).name, StringToRemoveFromFname); % get the root of the filename
        ZscoreTab = readtable(ZscoreDir(i).name,'Delimiter',',');
        
        [MergedTab, TotalMergeCt_AN(i,1),TotalMergeCt_CHNSP(i,1),TotalMergeCt_CHNNSP(i,1)] = MergeZeroIviVocsAndGetTSOnlyTab(ZscoreTab);
    
        if isempty(MergedTab) %if table is empty
            TotalMergeCt_AN(i,1) = NaN;
            TotalMergeCt_CHNSP(i,1) = NaN;
            TotalMergeCt_CHNNSP(i,1) = NaN;
        end
    
        %get infant id and age
        InfantID{i,1} = MetadataTab.InfantID(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));
        InfantAgeMonth(i,1) = MetadataTab.InfantAgeMonth(contains(MetadataTab.FileNameRoot,ZscoreFnRoot));

        if size(MergedTab,1) ~= 0 %if the Ivi merged tab isn't empty, save
            FileNameToSave_StepSiTab = strcat(DestinationPath,ZscoreFnRoot,StringToAddToFname);
            writetable(MergedTab,FileNameToSave_StepSiTab)
        end
    end

    MergeDetailsTab = table(InfantID,InfantAgeMonth,TotalMergeCt_CHNNSP,TotalMergeCt_CHNSP,TotalMergeCt_AN); %put together table with merge details
    if contains(StringToAddToFname,'5min') %get label method info
        LabelMethod = '5min';
    elseif contains(StringToAddToFname,'Hum')
        LabelMethod = 'Hum';
    elseif contains(StringToAddToFname,'LENA') && ~contains(StringToAddToFname,'5min')
        LabelMethod = 'LENA';
    end
    writetable(MergeDetailsTab,strcat(DestinationPath,'ZeroIviMergeDetailsTab_',LabelMethod,'.csv')) %save table
    %----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %I like to move this table to the folder MetaDataFiles (but I do that manually. PLEASE MAKE SURE to do this after running this script (or change paths in any future scripts accordingly).
    %----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end