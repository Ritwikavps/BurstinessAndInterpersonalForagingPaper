clear all
clc

%plots main fig plots

MainFigStepTypes = {'InterVocInt','Dist2D','Dist3D'};
MainFigStepTypeTitle = {'IVI','2D steps','3D steps'};
SIFigStepTypes = {'DistPitch','DistAmp','DistDuration','AbsDistDuration'};
SIFigStepTypeTitle = {'Pitch steps','Amp. steps','Dur. steps (directional)','Dur. steps (non-directional)'};

BasePath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/DataTabsForStats/R6_DataTablesForResponseAnalyses/CurrPrevStSi/';

FileName_CHNSP = strcat(BasePath,'CurrPrevStSizResp_Hum_ANRespToCHNSP_DurLogZ_RespAnalysesOnResid_VarsScaleLog_Oct182023.xlsx');
FileName_AN = strcat(BasePath,'CurrPrevStSizResp_Hum_CHNSPRespToAN_DurLogZ_RespAnalysesOnResid_VarsScaleLog_Oct182023.xlsx');
Xvar = 'AgeMnth'; %AgeMnth'
LineTypeVar = 'RespWindow'; %'RespWindow';
Yvar = 'ResponseEff'; %PrevStEff, ResponseEff
Ypval = 'ResponseP';
YLowerCI = 'ResponseCI_2_5';
YUpperCI = 'ResponseCI_97_5';

figure;
set(gcf,'Color','white');
getMainPlot('CHNSP',FileName_CHNSP,MainFigStepTypes,MainFigStepTypeTitle,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI)
getMainPlot('AN',FileName_AN,MainFigStepTypes,MainFigStepTypeTitle,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI)
plottools

figure;
set(gcf,'Color','white');
getMainPlot('CHNSP',FileName_CHNSP,SIFigStepTypes,SIFigStepTypeTitle,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI)
getMainPlot('AN',FileName_AN,SIFigStepTypes,SIFigStepTypeTitle,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI)
plottools

function [] = getMainPlot(Spkr,FileName,StepTypes,StepTypeTitle,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI)

%Xvar can be responsewindow (RespWindow) or age (AgeMnth); in which case,
%the different lines (specified by LineTypeVar) would be the other.

    aa = readtable(FileName); %read file

    LineTypeVals = unique(aa.(LineTypeVar)); %get unique line type values. So, if we are plotting effect of response as a function of responsewindow, then we'd have
    %age mnth = 3, 6, 9, and 18 as the different lines

    StartClr = [0.4 1 0.7]; %blue
    EndClr = [0 0 0]; %orange-ish

    LineClrs = [linspace(StartClr(1),EndClr(1),numel(LineTypeVals))', linspace(StartClr(2),EndClr(2),numel(LineTypeVals))', linspace(StartClr(3),EndClr(3),numel(LineTypeVals))'];

    switch Spkr
        case 'CHNSP'
            SubplotNums = 1:numel(StepTypes);
            RowId = 'Top';
        case 'AN'
            SubplotNums = numel(StepTypes)+(1:numel(StepTypes));
            RowId = 'Bottom';
        otherwise
            error('Unknown speaker type')
    end

    GetSubPlot(Spkr,aa,StepTypes,StepTypeTitle,SubplotNums,LineTypeVals,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI,LineClrs,RowId) 
end

function [] = GetSubPlot(Spkr,aa,StepTypes,StepTypeTitle,SubplotNums,LineTypeVals,LineTypeVar,Xvar,Yvar,Ypval,YLowerCI,YUpperCI,LineClrs,RowId)

    if numel(LineTypeVals) == 4
        LegendStrSuffix = ' months';
    else
        LegendStrSuffix = ' s';
    end

    subplot(2,numel(StepTypes),2*numel(StepTypes))
    hold all

    for k = 1:numel(LineTypeVals)
        LegendCell{k} = strcat(num2str(LineTypeVals(k)),LegendStrSuffix);

        plot(NaN*[1 2 3 4],[1 2 3 4],'Color',LineClrs(k,:),'LineWidth',2)
    end

    for i = 1:numel(StepTypes)
        subplot(2,numel(StepTypes),SubplotNums(i))
        if (strcmp(RowId,'Top')) 
            title(StepTypeTitle{i})
            if i == 1
                ylabel('Infant speech-related (CHNSP)');
            end
        elseif (strcmp(RowId,'Bottom')) && (i == 1)
            ylabel('Adult (AN)')
        end
    
        hold all
    
        SubTab = aa(strcmp(aa.StepVar,StepTypes{i}),:);
    
        for j = 1:numel(LineTypeVals)

            tabToPlot = SubTab(SubTab.(LineTypeVar) == LineTypeVals(j),:); %get effect size as function of X var, for each line type value
            tabToPlot = sortrows(tabToPlot,Xvar);
            boundedline(tabToPlot.(Xvar),tabToPlot.(Yvar),[abs(tabToPlot.(Yvar) - tabToPlot.(YLowerCI))...
                    abs(tabToPlot.(Yvar) - tabToPlot.(YUpperCI))],'Color',LineClrs(j,:),'LineWidth',2);
            alphaVal = 0.8 - (j/15);
            alpha (alphaVal)
    
            SigTab = tabToPlot(tabToPlot.(Ypval) < 0.05,:);
            plot(SigTab.(Xvar),SigTab.(Yvar),'.','MarkerSize',10,'Color',LineClrs(j,:))
            SigTab = tabToPlot(tabToPlot.(Ypval) < 0.01,:);
            plot(SigTab.(Xvar),SigTab.(Yvar),'.','MarkerSize',20,'Color',LineClrs(j,:))
            SigTab = tabToPlot(tabToPlot.(Ypval) < 0.001,:);
            plot(SigTab.(Xvar),SigTab.(Yvar),'.','MarkerSize',35,'Color',LineClrs(j,:))
        end

        if strcmp(RowId,'Top')
            xticks([])
        elseif strcmp(RowId,'Bottom')
            if numel(tabToPlot.(Xvar)) == 4
                xticks([3 6 9 18]);
            else
                xticks([2 4 6 8 10]);
            end
        end

        axis tight
    end

    if strcmp(Spkr,'AN')
        subplot(2,numel(StepTypes),2*numel(StepTypes))
        legend(LegendCell,'Orientation','horizontal')
    end
end