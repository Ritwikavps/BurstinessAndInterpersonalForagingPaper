clear all
clc

%Ritwika VPS, UCLA Comm, Nov 2022

%this script computes the recording level summary measures (mean, median,
%std dev, 90 prctile) for CHNSP and AN pitch, amplitude, duration, intervoc
%int; and steps in pitch, amplitude, duration, 2d and 3d acoustic space,
%for human listener data, matched LENA data, and LENA daylong data

%get age and child id details
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv'); %make sure to read in infant code as string
opts = setvartype(opts, 'InfantID', 'string');
DataDetails = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/MergedTSAcousticsMetadata.csv',opts);
%var names: {'FileNameRoot'}    {'InfantAgeDays'}  {'InfantAgeMonth'}  {'InfantID'}

%-----1.LENA daylong data--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A8_ZscoredTSAcousticsLENA'
L_files = dir('*_ZscoredAcousticsTS_LENA.csv');

for i = 1:numel(L_files)
    
    %get child id and age in days
    L_ChildID{i,1} = DataDetails.InfantID{contains(DataDetails.FileNameRoot,erase(L_files(i).name,'_ZscoredAcousticsTS_LENA.csv'))};
    L_ChildAgeDays(i,1) = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(L_files(i).name,'_ZscoredAcousticsTS_LENA.csv')));
   
    %chnsp measures
    L_MeanChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','CHNSP','mean',L_files(i).name);  %input format: %GetRecLvlSummaryMeasures(DataType,SpeakerType,MeasureType,InputFname)
    L_MedianChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','CHNSP','median',L_files(i).name);
    L_StddevChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','CHNSP','stddev',L_files(i).name);
    L_90prcChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','CHNSP','90prc',L_files(i).name);

    %An measures
    L_MeanAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','AN','mean',L_files(i).name);
    L_MedianAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','AN','median',L_files(i).name);
    L_StddevAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','AN','stddev',L_files(i).name);
    L_90prcAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENAday','AN','90prc',L_files(i).name);

    %OpVals order: {Pitch Amp Duration PitchStep AmpStep DurationStep TwoDimStep ThreeDimStep IntVocInt}
end

%-----2. Lena 5 min data--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A7_MatchedLenaData'
L5min_files = dir('*_MatchedLENA_ZscoreTS.csv');

for i = 1:numel(L5min_files)
    
    %get child id and age in days
    L5min_ChildID{i,1} = DataDetails.InfantID{contains(DataDetails.FileNameRoot,erase(L5min_files(i).name,'_MatchedLENA_ZscoreTS.csv'))};
    L5min_ChildAgeDays(i,1) = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(L5min_files(i).name,'_MatchedLENA_ZscoreTS.csv')));

    %chnsp measures
    L5min_MeanChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','CHNSP','mean',L5min_files(i).name);
    L5min_MedianChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','CHNSP','median',L5min_files(i).name);
    L5min_StddevChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','CHNSP','stddev',L5min_files(i).name);
    L5min_90prcChnspOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','CHNSP','90prc',L5min_files(i).name);

    %An measures
    L5min_MeanAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','AN','mean',L5min_files(i).name);
    L5min_MedianAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','AN','median',L5min_files(i).name);
    L5min_StddevAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','AN','stddev',L5min_files(i).name);
    L5min_90prcAnOpVals(i,:) = GetRecLvlSummaryMeasures('LENA5min','AN','90prc',L5min_files(i).name);
end

%-----3. Hum-listener data--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A6_ZscoredHumLabelData'
H_files = dir('*_ZscoredAcousticsTS_Hum.csv');

for i = 1:numel(H_files)
    
    %get child id and age in days
    H_ChildID{i,1} = DataDetails.InfantID{contains(DataDetails.FileNameRoot,erase(H_files(i).name,'_ZscoredAcousticsTS_Hum.csv'))};
    H_ChildAgeDays(i,1) = DataDetails.InfantAgeDays(contains(DataDetails.FileNameRoot,erase(H_files(i).name,'_ZscoredAcousticsTS_Hum.csv')));

    %chnsp measures
    H_MeanChnspOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','CHN','mean',H_files(i).name);
    H_MedianChnspOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','CHN','median',H_files(i).name);
    H_StddevChnspOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','CHN','stddev',H_files(i).name);
    H_90prcChnspOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','CHN','90prc',H_files(i).name);

    %An measures
    H_MeanAnTUNOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','AN','mean',H_files(i).name);
    H_MedianAnTUNOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','AN','median',H_files(i).name);
    H_StddevAnTUNOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','AN','stddev',H_files(i).name);
    H_90prcAnTUNOpVals(i,:) = GetRecLvlSummaryMeasures('Humlabel','AN','90prc',H_files(i).name);
end

%consolidate tables
%first get variable names for table
RootVarNames = {'Pitch' 'Amp' 'Duration' 'PitchStep' 'AmpStep' 'DurationStep' 'TwoDimStep' 'ThreeDimStep' 'IntVocInt'};
Expanded_VarNames = [strcat('Chnsp_',RootVarNames,'_Mean') strcat('Chnsp_',RootVarNames,'_Median') strcat('Chnsp_',RootVarNames,'_Stddev') strcat('Chnsp_',RootVarNames,'_90prc') ...
    strcat('An_',RootVarNames,'_Mean') strcat('An_',RootVarNames,'_Median') strcat('An_',RootVarNames,'_Stddev') strcat('An_',RootVarNames,'_90prc')];

%1. Lena 5 min matched
L5min_tab = array2table([L5min_MeanChnspOpVals L5min_MedianChnspOpVals L5min_StddevChnspOpVals L5min_90prcChnspOpVals ...
    L5min_MeanAnOpVals L5min_MedianAnOpVals L5min_StddevAnOpVals L5min_90prcAnOpVals]);
L5min_tab.Properties.VariableNames = Expanded_VarNames;
L5min_tab.InfantID = L5min_ChildID;
L5min_tab.InfantAgeDays = L5min_ChildAgeDays;

%2. Daylong LENA
L_tab = array2table([L_MeanChnspOpVals L_MedianChnspOpVals L_StddevChnspOpVals L_90prcChnspOpVals ...
    L_MeanAnOpVals L_MedianAnOpVals L_StddevAnOpVals L_90prcAnOpVals]);
L_tab.Properties.VariableNames = Expanded_VarNames;
L_tab.InfantID = L_ChildID;
L_tab.InfantAgeDays = L_ChildAgeDays;

%3. Human listener labelled data
H_tab = array2table([H_MeanChnspOpVals H_MedianChnspOpVals H_StddevChnspOpVals H_90prcChnspOpVals ...
    H_MeanAnTUNOpVals H_MedianAnTUNOpVals H_StddevAnTUNOpVals H_90prcAnTUNOpVals]);
H_tab.Properties.VariableNames = Expanded_VarNames;
H_tab.InfantID = H_ChildID;
H_tab.InfantAgeDays = H_ChildAgeDays;

%save tables
cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats'
writetable(H_tab,'MeanStddevAndOtherSummaryMeasures_Hlabel.csv')
writetable(L5min_tab,'MeanStddevAndOtherSummaryMeasures_L5min.csv')

cd '/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats'
writetable(L_tab,'MeanStddevAndOtherSummaryMeasures_LENAday.csv')




