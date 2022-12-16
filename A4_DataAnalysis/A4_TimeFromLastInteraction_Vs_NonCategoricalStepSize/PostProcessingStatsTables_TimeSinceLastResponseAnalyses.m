clear all
clc

%Ritwika VPS, Sep 2022
%post-analysis processing: this script goes through the stats tables
%summarusing teh stats done to look at acoustic step sizes as a function of
%time elapsed since the last OTHER speaker type utterance and catalogues
%which effects are significant and the sign match for i) LENA, 5 min LENA,
%and human labelled data; ii) match for 5 min LENA and human labelled data,
%but not daylong LENA; iii) match for 5 min LENA and daylong LENA, but not
%human labelled data; or iv) match for human labelled data nad daylong LENA
%but not 5 min LENA. This also picks out significant effects whose signs
%switch bettween the three. 

%Read in tables; explictly specify the stats results columnsn as double
%5 min LENA labels--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/TimeSinceLastResponseStats_5minLENALabel.xlsx');
opts = setvartype(opts, 3:10, 'double');
TimeSinceLastResponse_5minLENATab =...
   readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/TimeSinceLastResponseStats_5minLENALabel.xlsx',opts);

opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/TimeSinceLastResponseAndIntVocIntStats_5minLENALabel.xlsx');
opts = setvartype(opts, 3:12, 'double');
TimeSinceLastResponseAndIntVocInt_5minLENATab =...
   readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_AN_MatchedLENA5minLabels/TimeSinceLastResponseAndIntVocIntStats_5minLENALabel.xlsx',opts);

%Human label--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/TimeSinceLastResponseStats_HumLabel.xlsx');
opts = setvartype(opts, 3:10, 'double');
TimeSinceLastResponse_HumTab =...
   readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/TimeSinceLastResponseStats_HumLabel.xlsx',opts);

opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/TimeSinceLastResponseAndIntVocIntStats_HumLabel.xlsx');
opts = setvartype(opts, 3:12, 'double');
TimeSinceLastResponseAndIntVocInt_HumTab =...
   readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/HUMLabelData/A2_HUMLabelData_ToWorkWithPostCleanUp/A8_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_TUNadult_HumLabel/TimeSinceLastResponseAndIntVocIntStats_HumLabel.xlsx',opts);

%daylong LENA-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/TimeSinceLastResponseStats_LENALabel.xlsx');
opts = setvartype(opts, 3:10, 'double');
TimeSinceLastResponse_DaylongLENATab =...
   readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/TimeSinceLastResponseStats_LENALabel.xlsx',opts);

opts = detectImportOptions('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/TimeSinceLastResponseAndIntVocIntStats_LENALabel.xlsx');
opts = setvartype(opts, 3:10, 'double');
TimeSinceLastResponseAndIntVocInt_DaylongLENATab = readtable('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/LENAData/A9_TablesForStats/EffectOfTimeSinceLastResponse_CHNSP_adult_LENALabel/TimeSinceLastResponseAndIntVocIntStats_LENALabel.xlsx',opts);

%note that rows 20, 21 41, and 42 of the tables witjout intervoc step
%as an explanatory variable deal with the two and three dim space step to
%the current SPEAKER type voc from the last OTHER type voc. We will rename
%these dependent vars, just to avoid the confusion (since otherwise, there
%will be identical rows in terms of row and columns names)
for i = [20 21 41 42]
    TimeSinceLastResponse_5minLENATab.DependentVar{i} = strcat(TimeSinceLastResponse_5minLENATab.DependentVar{i},'FromLastResponse');
    TimeSinceLastResponse_DaylongLENATab.DependentVar{i} = strcat(TimeSinceLastResponse_DaylongLENATab.DependentVar{i},'FromLastResponse');
    TimeSinceLastResponse_HumTab.DependentVar{i} = strcat(TimeSinceLastResponse_HumTab.DependentVar{i},'FromLastResponse');
end

%variable names for target table: Speaker, DependentVar, Xvar, L_DayEffectwIntvocInt, 
% L_DayPwIntvocInt, L_5minEffectwIntvocInt, L_5minPwIntVocInt, H_EffectwIntVocInt,
% H_PwIntVocInt, L_DayEffect, L_DayP, L_5minEffect, L_5minP, H_Effect, H_P

Ctr = 0; %initialise counter to store new columns for the new table

for i = 1:numel(TimeSinceLastResponse_5minLENATab(:,1)) %go through each row - for this, use the table with more rows (the tables without intervocint as an X var)

    IntVocIntTestIndexMatch = NaN; %this is the variable to store the row index in the tables with intervocinteral as an explanatory variable
    %that match the corresponding row in the tables without intervocinterval as an explanatory variable. We set this to NaN
    %because not all dependent variables have both tests

    %Now, match table entries for table with intervoc int as an explanatory variable and find IntVocIntTestIndexMatch, if applicable. 
    for j = 1:numel(TimeSinceLastResponseAndIntVocInt_DaylongLENATab(:,1)) %go through rows of table with intervocinterval as an X var
        %check if speaker and dependent var match  (fiurst two conditions) as well as whether it is
        %for intervening or non intervening voc (last condition; here, we
        %check to make sure that the result of isnan for both entries are
        %the same)
        if (strcmp(TimeSinceLastResponseAndIntVocInt_DaylongLENATab.Speaker{j},TimeSinceLastResponse_DaylongLENATab.Speaker{i})) && ...
                (strcmp(TimeSinceLastResponseAndIntVocInt_DaylongLENATab.DependentVar{j},TimeSinceLastResponse_DaylongLENATab.DependentVar{i})) && ...
                (isnan(TimeSinceLastResponseAndIntVocInt_DaylongLENATab.TimeSinceLastResponseEffect(j)) == ...  
                    isnan(TimeSinceLastResponse_DaylongLENATab.TimeSinceLastResponseEffect(i))) 

            IntVocIntTestIndexMatch = j; %if none of these conditions are satisfied, this will remain NaN

        end
    end

    %[i IntVocIntTestIndexMatch]

    %start populating columns for new table
    %fill in age effect----------------------------------------------------------------------------------------------------------------------------------------
    Ctr = Ctr + 1; 

    Speaker{Ctr,1} = TimeSinceLastResponse_5minLENATab.Speaker{i};
    DependentVar{Ctr,1} = TimeSinceLastResponse_5minLENATab.DependentVar{i};
    Xvar{Ctr,1} = 'LogAge';

    %table results without intervocalisation interval as an X var
    [L_5minEffect(Ctr,1),L_5minP(Ctr,1),L_DayEffect(Ctr,1),L_DayP(Ctr,1),H_Effect(Ctr,1),H_P(Ctr,1)] = ColsWoIntVocIntervalAsXvar(i,4,3,TimeSinceLastResponse_5minLENATab,...
                                                                                                TimeSinceLastResponse_DaylongLENATab,TimeSinceLastResponse_HumTab);

    %table results with intervocalisation interval as an X var
    [L_DayEffectwIntvocInt(Ctr,1),L_DayPwIntvocInt(Ctr,1),L_5minEffectwIntvocInt(Ctr,1),L_5minPwIntVocInt(Ctr,1),...
        H_EffectwIntVocInt(Ctr,1),H_PwIntVocInt(Ctr,1)] = ColsWithIntVocIntervalAsXvar(IntVocIntTestIndexMatch,...
                                                          TimeSinceLastResponseAndIntVocInt_DaylongLENATab,TimeSinceLastResponseAndIntVocInt_5minLENATab,...
                                                          TimeSinceLastResponseAndIntVocInt_HumTab,3,4);
    
    if ~isnan(TimeSinceLastResponse_5minLENATab.TimeSinceLastResponseEffect(i)) 
        %if time since last response effect exists, fill in------------------------------------------------------------------------------------------------------
    
        Ctr = Ctr + 1;

        Speaker{Ctr,1} = {};
        DependentVar{Ctr,1} = {};
        Xvar{Ctr,1} = 'TimeSinceLastResponse';
    
        %table results without intervocalisation interval as an X var
        [L_5minEffect(Ctr,1),L_5minP(Ctr,1),L_DayEffect(Ctr,1),L_DayP(Ctr,1),H_Effect(Ctr,1),H_P(Ctr,1)] =...
                                                                                        ColsWoIntVocIntervalAsXvar(i,6,5,TimeSinceLastResponse_5minLENATab,...
                                                                                        TimeSinceLastResponse_DaylongLENATab,TimeSinceLastResponse_HumTab);

    
        %table results with intervocalisation interval as an X var
        [L_DayEffectwIntvocInt(Ctr,1),L_DayPwIntvocInt(Ctr,1),L_5minEffectwIntvocInt(Ctr,1),L_5minPwIntVocInt(Ctr,1),...
            H_EffectwIntVocInt(Ctr,1),H_PwIntVocInt(Ctr,1)] = ColsWithIntVocIntervalAsXvar(IntVocIntTestIndexMatch,...
                                                          TimeSinceLastResponseAndIntVocInt_DaylongLENATab,TimeSinceLastResponseAndIntVocInt_5minLENATab,...
                                                          TimeSinceLastResponseAndIntVocInt_HumTab,5,6);

    elseif ~isnan(TimeSinceLastResponse_5minLENATab.TimeToLastResponseEffect(i))

        %time to last response effect-------------------------------------------------------------------------------------------------------------------------------
        Ctr = Ctr + 1;

        Speaker{Ctr,1} = {};
        DependentVar{Ctr,1} = {};
        Xvar{Ctr,1} = 'TimeToLastResponse';
    
        %table results without intervocalisation interval as an X var
        [L_5minEffect(Ctr,1),L_5minP(Ctr,1),L_DayEffect(Ctr,1),L_DayP(Ctr,1),H_Effect(Ctr,1),H_P(Ctr,1)] =...
                                                                                        ColsWoIntVocIntervalAsXvar(i,8,7,TimeSinceLastResponse_5minLENATab,...
                                                                                        TimeSinceLastResponse_DaylongLENATab,TimeSinceLastResponse_HumTab);
        %table results with intervocalisation interval as an X var
        [L_DayEffectwIntvocInt(Ctr,1),L_DayPwIntvocInt(Ctr,1),L_5minEffectwIntvocInt(Ctr,1),L_5minPwIntVocInt(Ctr,1),...
            H_EffectwIntVocInt(Ctr,1),H_PwIntVocInt(Ctr,1)] = ColsWithIntVocIntervalAsXvar(IntVocIntTestIndexMatch,...
                                                          TimeSinceLastResponseAndIntVocInt_DaylongLENATab,TimeSinceLastResponseAndIntVocInt_5minLENATab,...
                                                          TimeSinceLastResponseAndIntVocInt_HumTab,7,8);
        %time From last response effect------------------------------------------------------------------------------------------------------------------------------
        Ctr = Ctr + 1;

        Speaker{Ctr,1} = {};
        DependentVar{Ctr,1} = {};
        Xvar{Ctr,1} = 'TimeFromLastResponse';
    
        %table results without intervocalisation interval as an X var
        [L_5minEffect(Ctr,1),L_5minP(Ctr,1),L_DayEffect(Ctr,1),L_DayP(Ctr,1),H_Effect(Ctr,1),H_P(Ctr,1)] =...
                                                                                        ColsWoIntVocIntervalAsXvar(i,10,9,TimeSinceLastResponse_5minLENATab,...
                                                                                        TimeSinceLastResponse_DaylongLENATab,TimeSinceLastResponse_HumTab);
        %table results with intervocalisation interval as an X var
        [L_DayEffectwIntvocInt(Ctr,1),L_DayPwIntvocInt(Ctr,1),L_5minEffectwIntvocInt(Ctr,1),L_5minPwIntVocInt(Ctr,1),...
            H_EffectwIntVocInt(Ctr,1),H_PwIntVocInt(Ctr,1)] = ColsWithIntVocIntervalAsXvar(IntVocIntTestIndexMatch,...
                                                          TimeSinceLastResponseAndIntVocInt_DaylongLENATab,TimeSinceLastResponseAndIntVocInt_5minLENATab,...
                                                          TimeSinceLastResponseAndIntVocInt_HumTab,9,10);
    end

    %fill in intervoc int effect-----------------------------------------------------------------------------------------------------------------------------
    if ~isnan(IntVocIntTestIndexMatch) %if there is an intervoc interval effect

        Ctr = Ctr + 1;
    
        Speaker{Ctr,1} = {};
        DependentVar{Ctr,1} = {};
        Xvar{Ctr,1} = 'InterVocInt';
    
        %table results without intervocalisation interval as an X var
        L_5minEffect(Ctr,1) = NaN;
        L_5minP(Ctr,1) = NaN;
        L_DayEffect(Ctr,1) = NaN;
        L_DayP(Ctr,1) = NaN;
        H_Effect(Ctr,1) = NaN;
        H_P(Ctr,1) = NaN;
    
        %table results with intervocalisation interval as an X var
        L_DayEffectwIntvocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_DaylongLENATab.InterVocIntEffect(IntVocIntTestIndexMatch);
        L_DayPwIntvocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_DaylongLENATab.InterVocIntPvalue(IntVocIntTestIndexMatch);
        L_5minEffectwIntvocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_5minLENATab.InterVocIntEffect(IntVocIntTestIndexMatch);
        L_5minPwIntVocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_5minLENATab.InterVocIntPvalue(IntVocIntTestIndexMatch);
        H_EffectwIntVocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_HumTab.InterVocIntEffect(IntVocIntTestIndexMatch);
        H_PwIntVocInt(Ctr,1) = TimeSinceLastResponseAndIntVocInt_HumTab.InterVocIntPvalue(IntVocIntTestIndexMatch);
    end
     
end

%write output table
T_out = table(Speaker, DependentVar, Xvar, L_DayEffectwIntvocInt, L_DayPwIntvocInt, L_5minEffectwIntvocInt, ...
L_5minPwIntVocInt, H_EffectwIntVocInt,H_PwIntVocInt, L_DayEffect, L_DayP, L_5minEffect, L_5minP, H_Effect, H_P);
cd('/Volumes/GoogleDrive/My Drive/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/GeneralTablesForStatsFromHumanAndLENAlabels')
writetable(T_out,'TimeSinceLastResponseStatsCollated.csv')

%--------------------------------------------------------------------------------------------------------------------------------------------------------------
%functions
%--------------------------------------------------------------------------------------------------------------------------------------------------------------
%this function is to avoid repeating the block where we pick out the effect size %and pvalue for a 
%given explanatory variable for the tables withoit intervoc interval as an X var
function [L_5minEffect,L_5minP,L_DayEffect,L_DayP,H_Effect,H_P] =...
                        ColsWoIntVocIntervalAsXvar(RowIndex,PvalueIndex,EffectIndex,TimeSinceLastResponse_5minLENATab,...
                        TimeSinceLastResponse_DaylongLENATab,TimeSinceLastResponse_HumTab)

    L_5minEffect = table2array(TimeSinceLastResponse_5minLENATab(RowIndex,EffectIndex));
    L_5minP = table2array(TimeSinceLastResponse_5minLENATab(RowIndex,PvalueIndex));
    L_DayEffect = table2array(TimeSinceLastResponse_DaylongLENATab(RowIndex,EffectIndex));
    L_DayP = table2array(TimeSinceLastResponse_DaylongLENATab(RowIndex,PvalueIndex));
    H_Effect = table2array(TimeSinceLastResponse_HumTab(RowIndex,EffectIndex));
    H_P = table2array(TimeSinceLastResponse_HumTab(RowIndex,PvalueIndex));

end


%this function is to avoid repeating the block where we pick out the effect size %and pvalue for a 
%given explanatory variable for the tables WITH intervoc interval as an X var
function [L_DayEffectwIntvocInt,L_DayPwIntvocInt,L_5minEffectwIntvocInt,L_5minPwIntVocInt,H_EffectwIntVocInt,H_PwIntVocInt] = ...
             ColsWithIntVocIntervalAsXvar(IntVocIntTestIndexMatch,TimeSinceLastResponseAndIntVocInt_DaylongLENATab,TimeSinceLastResponseAndIntVocInt_5minLENATab,...
             TimeSinceLastResponseAndIntVocInt_HumTab,EffectIndex,PvalueIndex)  
    
    if ~isnan(IntVocIntTestIndexMatch)
        
        %table results with intervocalisation interval as an X var
        L_DayEffectwIntvocInt = table2array(TimeSinceLastResponseAndIntVocInt_DaylongLENATab(IntVocIntTestIndexMatch,EffectIndex));
        L_DayPwIntvocInt = table2array(TimeSinceLastResponseAndIntVocInt_DaylongLENATab(IntVocIntTestIndexMatch,PvalueIndex));
        L_5minEffectwIntvocInt = table2array(TimeSinceLastResponseAndIntVocInt_5minLENATab(IntVocIntTestIndexMatch,EffectIndex));
        L_5minPwIntVocInt = table2array(TimeSinceLastResponseAndIntVocInt_5minLENATab(IntVocIntTestIndexMatch,PvalueIndex));
        H_EffectwIntVocInt = table2array(TimeSinceLastResponseAndIntVocInt_HumTab(IntVocIntTestIndexMatch,EffectIndex));
        H_PwIntVocInt = table2array(TimeSinceLastResponseAndIntVocInt_HumTab(IntVocIntTestIndexMatch,PvalueIndex));
    else
        L_DayEffectwIntvocInt = NaN;
        L_DayPwIntvocInt = NaN;
        L_5minEffectwIntvocInt = NaN;
        L_5minPwIntVocInt = NaN;
        H_EffectwIntVocInt = NaN;
        H_PwIntVocInt = NaN;
    end
end
