clear all
clc

%Ritwika VPS
%UCLA Comm, Nov 2022

%This script is a second attempt at comparing higher-order patterns between human-listener labelled data and corresponding matched LENA data. The goal
%of this script is to optimise the existing process I have that does this. 

%In a little more detail, the goal here is to compute correlations (r_H for human lkistener annotated data, and r_L for the corresponding matched LENA
% data) between the following measures at the recording level, for both adult and infant speakers, and to then compare how well those correlations match:
% - intervocalisation interval and steps in pitch, amplitude, duration, 2d and 3d acoustic steps
% - elapsed time since last interaction and steps in pitch, amplitude, duration, 2d and 3d acoustic space (for steps without an intervening OTHER speaker type only)
% - elapsed time since the last interaction and steps in pitch, amplitude, duration, 2d and 3d acoustic space, between the speaker 
    % utterance and the last OTHER type utterance. Note that this looks at how the acoustic features of the speaker utterance diverge from those
    % of the last OTHER type, as elapsed time increases

%Previously, I was reading out massive tables containing the step size information, picking out entries for a given infant at a given age,
%matching corresponding LENA and human-listener labelled data, computing correlations, and outputting those correlations as a table. However, thsi
%requires holding large amounts of data in memory (from reading in the saved tables). Instead, I want to read in raw acoustics for a given infant
%at a given age, do the step size and correlation computations on each of these, and output the correlations, so the used memory is much lower.

%As a bonus, we'll also compute day-long recording level correlations for LENA data that has 5 minute segments annotated by human listeners to
%compare agreement between patterns at different timescales

%Get paths for daylong LENA data, matched 5 min LENA data, and 5 min human listener data, and get all relevant files

L_path = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA/';
cd(L_path)
L_files = dir('*_ZscoredAcousticsTS_LENA.csv');

L5min_path = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData/';
cd(L5min_path)
L5min_files = dir('*_MatchedLENA_ZscoreTS.csv');

H_path = '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData/';
cd(H_path)
H_files = dir('*_ZscoredAcousticsTS_Hum.csv');

%get cell array of file roots of file names of LENA daylong, LENA 5 min matched, and human labelled data
H_fnroots = erase({H_files.name}','_ZscoredAcousticsTS_Hum.csv'); %the {H_files.name} makes a cell array with names from the dir output, and the ' does a transpose
L_fnroots = erase({L_files.name}','_ZscoredAcousticsTS_LENA.csv');
L5min_fnroots = erase({L5min_files.name}','_MatchedLENA_ZscoreTS.csv');

L_indices = 1:numel(L_files);
L5min_indices = 1:numel(L5min_files);

%now get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%go through humman listener label file roots, find matching daylong and matched 5 min LENA data
for i = 1:numel(H_files)

    %i

    %get indices corresponding to matching files
    L_IndexMatch = L_indices(contains(L_fnroots,H_fnroots{i}));
    L5min_IndexMatch = L5min_indices(contains(L5min_fnroots,H_fnroots{i}));

    % %--------------------------------------------------------------------------------------------------------------------------------------------------------
    % %DEBUGGING TO MAKe SURE THAT THEre ARE MATCHeS; Uncomment to check
    % if ~strcmp(H_fnroots{i},L_fnroots{L_IndexMatch}) || ~strcmp(H_fnroots{i},L5min_fnroots{L5min_IndexMatch})
    %     %note that in case there isn't an index match in the above lines
    %     %for either the daylong or the 5 min matched lena data, the if
    %     %statement will throw an error, because L_fnroots{L_IndexMatch}
    %     %and/or L5min_fnroots{L5min_IndexMatch} will be unassigned
    % 
    %     display('Houston we have a problem')
    % 
    % end
    %
    % %once again confirm that the names match: here, we pick out the actual file names based on the matched index and check. 
    % if ~contains(L_files(L_IndexMatch).name,strcat(H_fnroots{i},'_')) || ~contains(L5min_files(L5min_IndexMatch).name,strcat(H_fnroots{i},'_'))
    %     display('Houston we have a problem. AGAIN')
    % end
    % %--------------------------------------------------------------------------------------------------------------------------------------------------------

    H_tab = readtable(H_files(i).name,'Delimiter',',');
    L_tab = readtable(L_files(L_IndexMatch).name,'Delimiter',',');
    L5min_tab = readtable(L5min_files(L5min_IndexMatch).name,'Delimiter',',');

    %get child id and age in days
    ChildID{i,1} = DataDetails.InfantID{contains(DataDetails.FileNameRoot,H_fnroots{i})};
    ChildAgeDays(i,1) = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,H_fnroots{i}));

    %get correlations for adult and infant vocs
    %1. Human listener labels
    [NonInterv_R_CHNSPspkr_H(i,:),NonInterv_P_CHNSPspkr_H(i,:),NonInterv_Yvars_CHNSPspkr_H{i,1},NonInterv_Xvar_CHNSPspkr_H{i,1},...
     NonStSize_R_CHNSPspkr_H(i,:),NonStSize_P_CHNSPspkr_H(i,:),NonStSize_Yvars_CHNSPspkr_H{i,1},NonStSize_Xvar_CHNSPspkr_H{i,1}] =...
               GetRecordingLevelCorrelations(H_tab,ChildID(i,1),ChildAgeDays(i,1),'CHN','AN','Humlabel');

    [NonInterv_R_AnTUNspkr_H(i,:),NonInterv_P_AnTUNspkr_H(i,:),NonInterv_Yvars_AnTUNspkr_H{i,1},NonInterv_Xvar_AnTUNspkr_H{i,1},...
     NonStSize_R_AnTUNspkr_H(i,:),NonStSize_P_AnTUNspkr_H(i,:),NonStSize_Yvars_AnTUNspkr_H{i,1},NonStSize_Xvar_AnTUNspkr_H{i,1}] =...
               GetRecordingLevelCorrelations(H_tab,ChildID(i,1),ChildAgeDays(i,1),'AN','CHN','Humlabel');

    %2. Lena daylong
    [NonInterv_R_CHNSPspkr_L(i,:),NonInterv_P_CHNSPspkr_L(i,:),NonInterv_Yvars_CHNSPspkr_L{i,1},NonInterv_Xvar_CHNSPspkr_L{i,1},...
     NonStSize_R_CHNSPspkr_L(i,:),NonStSize_P_CHNSPspkr_L(i,:),NonStSize_Yvars_CHNSPspkr_L{i,1},NonStSize_Xvar_CHNSPspkr_L{i,1}] =...
               GetRecordingLevelCorrelations(L_tab,ChildID(i,1),ChildAgeDays(i,1),'CHN','AN','LENAday');

    [NonInterv_R_ANspkr_L(i,:),NonInterv_P_ANspkr_L(i,:),NonInterv_Yvars_ANspkr_L{i,1},NonInterv_Xvar_ANspkr_L{i,1},...
     NonStSize_R_ANspkr_L(i,:),NonStSize_P_ANspkr_L(i,:),NonStSize_Yvars_ANspkr_L{i,1},NonStSize_Xvar_ANspkr_L{i,1}] =...
               GetRecordingLevelCorrelations(L_tab,ChildID(i,1),ChildAgeDays(i,1),'AN','CHN','LENAday');

    %3. Lena 5min
    [NonInterv_R_CHNSPspkr_L5min(i,:),NonInterv_P_CHNSPspkr_L5min(i,:),NonInterv_Yvars_CHNSPspkr_L5min{i,1},NonInterv_Xvar_CHNSPspkr_L5min{i,1},...
     NonStSize_R_CHNSPspkr_L5min(i,:),NonStSize_P_CHNSPspkr_L5min(i,:),NonStSize_Yvars_CHNSPspkr_L5min{i,1},NonStSize_Xvar_CHNSPspkr_L5min{i,1}] =...
               GetRecordingLevelCorrelations(L5min_tab,ChildID(i,1),ChildAgeDays(i,1),'CHN','AN','LENA5min');

    [NonInterv_R_ANspkr_L5min(i,:),NonInterv_P_ANspkr_L5min(i,:),NonInterv_Yvars_ANspkr_L5min{i,1},NonInterv_Xvar_ANspkr_L5min{i,1},...
     NonStSize_R_ANspkr_L5min(i,:),NonStSize_P_ANspkr_L5min(i,:),NonStSize_Yvars_ANspkr_L5min{i,1},NonStSize_Xvar_ANspkr_L5min{i,1}] =...
               GetRecordingLevelCorrelations(L5min_tab,ChildID(i,1),ChildAgeDays(i,1),'AN','CHN','LENA5min');

end

%put tables together: first get variable names
%1. Human listener labels
Htab_VarNames = [strcat(NonInterv_Yvars_CHNSPspkr_H{1},'_Chnsp_R_H'), strcat(NonStSize_Yvars_CHNSPspkr_H{1},'_NonStSize_Chnsp_R_H'),...
            strcat(NonInterv_Yvars_AnTUNspkr_H{1},'_AnTUN_R_H'), strcat(NonStSize_Yvars_AnTUNspkr_H{1},'_NonStSize_AnTUN_R_H'),...
            strcat(NonInterv_Yvars_CHNSPspkr_H{1},'_Chnsp_P_H'), strcat(NonStSize_Yvars_CHNSPspkr_H{1},'_NonStSize_Chnsp_P_H'),...
            strcat(NonInterv_Yvars_AnTUNspkr_H{1},'_AnTUN_P_H'), strcat(NonStSize_Yvars_AnTUNspkr_H{1},'_NonStSize_AnTUN_P_H')];
Htab_op = array2table([NonInterv_R_CHNSPspkr_H NonStSize_R_CHNSPspkr_H NonInterv_R_AnTUNspkr_H NonStSize_R_AnTUNspkr_H ...
                NonInterv_P_CHNSPspkr_H NonStSize_P_CHNSPspkr_H NonInterv_P_AnTUNspkr_H NonStSize_P_AnTUNspkr_H]);
Htab_op.Properties.VariableNames = Htab_VarNames;
Htab_op.InfantID = ChildID;
Htab_op.InfantAgeDays = ChildAgeDays;

%2. Lena daylong
Ltab_VarNames = [strcat(NonInterv_Yvars_CHNSPspkr_L{1},'_Chnsp_R_L'), strcat(NonStSize_Yvars_CHNSPspkr_L{1},'_NonStSize_Chnsp_R_L'),...
            strcat(NonInterv_Yvars_ANspkr_L{1},'_AN_R_L'), strcat(NonStSize_Yvars_ANspkr_L{1},'_NonStSize_AN_R_L'),...
            strcat(NonInterv_Yvars_CHNSPspkr_L{1},'_Chnsp_P_L'), strcat(NonStSize_Yvars_CHNSPspkr_L{1},'_NonStSize_Chnsp_P_L'),...
            strcat(NonInterv_Yvars_ANspkr_L{1},'_AN_P_L'), strcat(NonStSize_Yvars_ANspkr_L{1},'_NonStSize_AN_P_L')];
Ltab_op = array2table([NonInterv_R_CHNSPspkr_L NonStSize_R_CHNSPspkr_L NonInterv_R_ANspkr_L NonStSize_R_ANspkr_L ...
                NonInterv_P_CHNSPspkr_L NonStSize_P_CHNSPspkr_L NonInterv_P_ANspkr_L NonStSize_P_ANspkr_L]);
Ltab_op.Properties.VariableNames = Ltab_VarNames;
Ltab_op.InfantID = ChildID;
Ltab_op.InfantAgeDays = ChildAgeDays;

%3. Lena 5min
L5mintab_VarNames = [strcat(NonInterv_Yvars_CHNSPspkr_L5min{1},'_Chnsp_R_L5min'), strcat(NonStSize_Yvars_CHNSPspkr_L5min{1},'_NonStSize_Chnsp_R_L5min'),...
            strcat(NonInterv_Yvars_ANspkr_L5min{1},'_AN_R_L5min'), strcat(NonStSize_Yvars_ANspkr_L5min{1},'_NonStSize_AN_R_L5min'),...
            strcat(NonInterv_Yvars_CHNSPspkr_L5min{1},'_Chnsp_P_L5min'), strcat(NonStSize_Yvars_CHNSPspkr_L5min{1},'_NonStSize_Chnsp_P_L5min'),...
            strcat(NonInterv_Yvars_ANspkr_L5min{1},'_AN_P_L5min'), strcat(NonStSize_Yvars_ANspkr_L5min{1},'_NonStSize_AN_P_L5min')];
L5mintab_op = array2table([NonInterv_R_CHNSPspkr_L5min NonStSize_R_CHNSPspkr_L5min NonInterv_R_ANspkr_L5min NonStSize_R_ANspkr_L5min ...
                NonInterv_P_CHNSPspkr_L5min NonStSize_P_CHNSPspkr_L5min NonInterv_P_ANspkr_L5min NonStSize_P_ANspkr_L5min]);
L5mintab_op.Properties.VariableNames = L5mintab_VarNames;
L5mintab_op.InfantID = ChildID;
L5mintab_op.InfantAgeDays = ChildAgeDays;

%save tables
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/')
writetable(Htab_op,'RecLevelCorr_TimeSinceLastInteractionVsY_Hlabel.csv')
writetable(L5mintab_op,'RecLevelCorr_TimeSinceLastInteractionVsY_L5min.csv')

cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/')
writetable(Ltab_op,'RecLevelCorr_TimeSinceLastInteractionVsY_LENAday.csv')






