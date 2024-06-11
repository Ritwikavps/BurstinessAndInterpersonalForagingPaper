function [] = GetRespBetasAsFnOfAgeFig(PathTotabs,DataTypePrefix,QtyToPlot,LineClrs)

%this function produces a 4-panel figure with infant and adult response betas with and without the step size control, for different ages and response windows. You can generate these plots 
% for LENA day0long data, LENA 5 min data, and human-labelled 5 min data, by specifiying the input string (see below for details on function inputs).

AgeMnth = [3 6 9 18]; %infant ages vector

cd(PathTotabs) %go to path
CHNSP_wCtrl = readtable(strcat(DataTypePrefix,'_ANRespToCHNSP_RespEff_W_PrevStSizCtrl_VarsScaleLog_CorpusLvl_IviOnly.csv')); %read in tables
CHNSP_woCtrl = readtable(strcat(DataTypePrefix,'_ANRespToCHNSP_RespEff_NoPrevStSizCtrl_VarsScaleLog_CorpusLvl_IviOnly.csv'));
AN_wCtrl = readtable(strcat(DataTypePrefix,'_CHNSPRespToAN_RespEff_W_PrevStSizCtrl_VarsScaleLog_CorpusLvl_IviOnly.csv'));                    
AN_woCtrl = readtable(strcat(DataTypePrefix,'_CHNSPRespToAN_RespEff_NoPrevStSizCtrl_VarsScaleLog_CorpusLvl_IviOnly.csv'));

%plotting
figure1 = figure('PaperType','<custom>','PaperSize',[18 11.5],'Color',[1 1 1]); % Create figure

axes1 = axes('Position',[0.124705882352941 0.54656862745098 0.394509803921569 0.386029411764706]); % Create axes
hold(axes1,'on');
ylabel(['Response \beta: AN ';'response to CHNSP  '],'FontName','Helvetica Neue'); % Create ylabel
title('A','FontName','Helvetica Neue'); % Create title
for k = 1:numel(AgeMnth) %get legend
    LegendCell{k} = strcat(num2str(AgeMnth(k)),' months'); %get the legend strings; 
    plot(NaN*[1 2 3 4],[1 2 3 4],'Color',LineClrs(k,:),'LineWidth',2) %plot NaN lines first according to the order of items in the legend, so the legend appears correctly
end 
GetRespEffPlotsFnOfRespWin(CHNSP_wCtrl,QtyToPlot,LineClrs,DataTypePrefix,'boundedline') %custom function (nested within this main function) to plot subplots
GetRespEffPlotsFnOfRespWin(CHNSP_wCtrl,QtyToPlot,LineClrs,DataTypePrefix,'siglvls')
axis(axes1,'tight'); hold(axes1,'off'); set(axes1,'FontSize',24,'XTick',zeros(1,0)); % Set the remaining axes properties
legend1 = legend(LegendCell); % Create legend
set(legend1,'Position',[0.392156862745097 0.792892156862745 0.121568627450981 0.134110965149716]);


axes2 = axes('Position',[0.589998129643362 0.545343137254902 0.395884223297815 0.387254901960785]); % Create axes
hold(axes2,'on');
title('B','FontName','Helvetica Neue'); % Create title
GetRespEffPlotsFnOfRespWin(CHNSP_woCtrl,QtyToPlot,LineClrs,DataTypePrefix,'boundedline')
GetRespEffPlotsFnOfRespWin(CHNSP_woCtrl,QtyToPlot,LineClrs,DataTypePrefix,'siglvls')
axis(axes2,'tight'); hold(axes2,'off'); set(axes2,'FontSize',24,'XTick',zeros(1,0)); % Set the remaining axes properties


axes3 = axes('Position',[0.124705882352941 0.111091523565948 0.395294117647059 0.390133966630131]); % Create axes
hold(axes3,'on');
ylabel(['Response \beta: CHNSP ';'response to AN        '],'FontName','Helvetica Neue'); % Create ylabel
xlabel('Response window (s)','FontName','Helvetica Neue'); % Create xlabel
title('C','FontName','Helvetica Neue'); % Create title
GetRespEffPlotsFnOfRespWin(AN_wCtrl,QtyToPlot,LineClrs,DataTypePrefix,'boundedline')
GetRespEffPlotsFnOfRespWin(AN_wCtrl,QtyToPlot,LineClrs,DataTypePrefix,'siglvls')
axis(axes3,'tight');
hold(axes3,'off');
set(axes3,'FontSize',24); % Set the remaining axes properties


axes4 = axes('Position',[0.589998129643362 0.111091523565948 0.396668537023305 0.388908476434052]); % Create axes
hold(axes4,'on');
title('D','FontName','Helvetica Neue'); % Create title
GetRespEffPlotsFnOfRespWin(AN_woCtrl,QtyToPlot,LineClrs,DataTypePrefix,'boundedline')
GetRespEffPlotsFnOfRespWin(AN_woCtrl,QtyToPlot,LineClrs,DataTypePrefix,'siglvls')
axis(axes4,'tight'); hold(axes4,'off'); set(axes4,'FontSize',24); % Set the remaining axes properties

annotation(figure1,'textbox',[0.00281727289456071 0.951885452964771 0.05806781755687 0.0509316770186341],'String',strcat(DataTypePrefix),'FontName','Helvetica Neue',...
    'FitBoxToText','off','EdgeColor','none'); %small text box with data type string (can delete before saving plot)
annotation(figure1,'textbox',[0.21391942178331 0.95043274458644 0.237845284099043 0.0509316770186335],'String',{'w/ prev. step size control'},...
    'FontSize',26,'FontName','Helvetica Neue','EdgeColor','none'); % Create textbox
annotation(figure1,'textbox',[0.663047087448115 0.95043274458644 0.251462716473452 0.0509316770186335],'String',{'w/o prev. step size control'},...
    'FontSize',26,'FontName','Helvetica Neue','EdgeColor','none'); % Create textbox

%COMENTED OUT BECAUSE the p value threshold legend is added in manually using pPT.
% if ~strcmpi(DataTypePrefix,'LENA')
%     annotation(figure1,'ellipse',[0.340145019889521 0.918187905516175 0.00292067354113634 0.00382983940151427],'FaceColor',[0 0 0]); % Create ellipse
%     annotation(figure1,'textbox',[0.348583594021549 0.897804016326711 0.10926094890511 0.0478260869565217],'String',{'p < 0.05'},'FontSize',24,...
%         'FontName','Helvetica Neue','EdgeColor','none'); % Create textbox
%     annotation(figure1,'ellipse',[0.469644305410684 0.915709590770202 0.0057206580929654 0.00764731152047382],'FaceColor',[0 0 0]); % Create ellipse
%     annotation(figure1,'textbox',[0.479154597767735 0.897804016326711 0.10926094890511 0.0478260869565217],'String',{'p < 0.01'},'FontSize',24,...
%         'FontName','Helvetica Neue','EdgeColor','none'); % Create textbox
%     annotation(figure1,'ellipse',[0.597067740315889 0.914470433397216 0.00785926698338091 0.0118271636825417],'FaceColor',[0 0 0]); % Create ellipse
%     annotation(figure1,'textbox',[0.608972502220672 0.89780401632671 0.121578467153285 0.0478260869565217],'String',{'p < 0.001'},'FontSize',24,...
%         'FontName','Helvetica Neue','EdgeColor','none'); % Create textbox
% end

annotation(figure1,'arrow',[0.447302848146556 0.96828824960641],[0.0213290884157126 0.0210899310427262]); % Create arrow

%----------------------------------------------------------------------------------------------------------------------
    %function to plot the subplots: given the input table (InputTab) and the type of step variable (StepType) whose response betas need to be plotted, this function plots
    % the response betas for that step type as a function of the response window, for each infant age block. The colors for each age is speacified by the LineClrs array. 
    %Finally, WhatToPlot determines if we plot the bounded line (with the CIs) or the line with markers indicating significance levels.
    function [] = GetRespEffPlotsFnOfRespWin(InputTab,StepType,LineClrs,DataTypePrefix,WhatToPlot)
    
        SubTab = InputTab(strcmp(InputTab.StepVar,StepType),:); %susbet for the given step type
        InfAge = [3 6 9 18];
        
        for i = 1:numel(InfAge) %loop thriough infant age
            tabToPlot = SubTab(SubTab.AgeMnth == InfAge(i),:); %subset for infant age
            tabToPlot = sortrows(tabToPlot,'RespWindow'); %sort the table by response window
            switch WhatToPlot %depending on whether we want to plot the bounded line (CIs) or the significance level lines
                case 'boundedline'
                    boundedline(tabToPlot.RespWindow,tabToPlot.ResponseEff,[abs(tabToPlot.ResponseEff - tabToPlot.ResponseCI_2_5)...
                            abs(tabToPlot.ResponseEff - tabToPlot.ResponseCI_97_5)],'Color',LineClrs(i,:),'LineWidth',2); %plots the bounded line (Conf. intervlas determine the bounds)
                %------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                %REQUIRES the bounded line package found here: https://www.mathworks.com/matlabcentral/fileexchange/27485-boundedline-m
                %------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                    alphaVal = 1 - (i/8); %set the transparency value for the bounded line
                    alpha (alphaVal)
                case 'siglvls'
                    if ~strcmpi('LENA',DataTypePrefix) %only plot these two sig levels if the data type is not lena day-long
                        SigTab = tabToPlot(tabToPlot.ResponseP < 0.05,:); %subset for specified significance level
                        plot(SigTab.RespWindow,SigTab.ResponseEff,'.','MarkerSize',10,'Color',LineClrs(i,:));
                        SigTab = tabToPlot(tabToPlot.ResponseP < 0.01,:); %subset for sig level 0.01
                        plot(SigTab.RespWindow,SigTab.ResponseEff,'.','MarkerSize',20,'Color',LineClrs(i,:));%,'MarkerEdgeColor', 'b')
                    end
                    SigTab = tabToPlot(tabToPlot.ResponseP < 0.001,:); %subset for sig level 0.001
                    plot(SigTab.RespWindow,SigTab.ResponseEff,'.','MarkerSize',35,'Color',LineClrs(i,:));%,'MarkerEdgeColor', 'b')
                    plot(tabToPlot.RespWindow,tabToPlot.ResponseEff,'LineWidth',2,'Color',LineClrs(i,:));
            end
        end
    end
end