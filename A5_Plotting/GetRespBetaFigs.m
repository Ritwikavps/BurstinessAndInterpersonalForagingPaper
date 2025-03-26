function [] = GetRespBetaFigs(InputTab,LENAClrs,ValDataTypeList,ValDataClrs,ValDataLegend,WithOrWoCtrlTxt,MainOrSI)

%This function plots response betas as a function of the response window, for the LENA day-long data (for each age block), and validation data (not separated into age blocks), both for the
% case of with and without previous strep size control.

%Inputs:
    %- InputTab: table with response betas, CIs, etc
    %- LENAClrs: array specifying colours for each age block for the LENA day-long data
    %- ValDataTypeList: list of strings specifying the different validation data sets
    %- ValDataClrs: array specifying colours for each validation data set
    %- ValDataLegend: legend string array for the validation data sets
    %- WithOrWoCtrlTxt: string specifying whether the results being plotted is for with or without control tests
    %- MainOrSI: string specifying whether the plot is for main text or SI.

u_RespToSpkr = {'ANRespToCHNSP','CHNSPRespToAN'}; %get list of response_to_spekar strings (ANRespToCHNSP, CHNSPRespToAN)
YlabelTxt = {'ChSp response to Ad','Ad response to ChSp'}; %text for Y axis label corresponding to thd speaker and response type

%check that the unique speaker list from the table is the same as the one we manually input
u_RespToSpkrFrmTab = sort(unique(InputTab.ResponseType));
if numel(u_RespToSpkrFrmTab) == numel(u_RespToSpkr) %check if they both have the same number of elements 
    if height(u_RespToSpkrFrmTab) ~= height(u_RespToSpkr) %If one of them is a column vector and the other is a row vector, do a transpose
        u_RespToSpkrFrmTab = u_RespToSpkrFrmTab';
    end
    if ~isequal(u_RespToSpkrFrmTab,sort(u_RespToSpkr))
        error('The response-to-speaker list from the table is not as expected')
    end
else
    error('The number of entries in the response-to-speaker list from the table is not equal to the number expected')
end

InfAge = [3 6 9 18]; 
Xlims = [3 102]; %this is based on the X axis (response windows) scaled by a factor of 5
Ylims = [min(InputTab.ResponseCI_Lwr)-0.01  max(max(InputTab.ResponseCI_Upper)+0.01,0.4)]; %set up Y axis limits that are the same all the subplots
YTix = [-0.4 -0.2 0 0.2 0.4]; %This is based on the Ylims; CHANGE AS NEEDED

%Pick out LENA day-long data and validation data subsets separately. Note that the validation data results are not separated by age, so there is only one response effect 
% per validation dataset for each response window, while LENA day-long data has prev step size effects for each age block.
LENATab = InputTab(strcmp(InputTab.DataType,'LENA'),:); 
ValTab = InputTab(~strcmp(InputTab.DataType,'LENA'),:); 

%Plotting: create figure
figure1 = figure('PaperType','<custom>','PaperSize',[27 14],'WindowState','maximized','Color',[1 1 1]);

%A: LENA daylong, infant speaker
axes1 = axes('Parent',figure1,'Position',[0.0779541666666667 0.543812314725528 0.440208333333333 0.41850934044987]); hold(axes1,'on'); % Create axes 
for k = 1:numel(InfAge) %get legend for each age
    LegendCell{k} = strcat(num2str(InfAge(k)),' months'); %get the legend strings; 
    plot(NaN*[1 2 3 4],[1 2 3 4],'Color',LENAClrs(k,:),'LineWidth',2) 
end
[RespWin_X] = GetRespEffPlotsFnOfRespWin_LENAday(LENATab,LENAClrs,u_RespToSpkr{1},MainOrSI,InfAge);
title('A'); ylabel({'Response effect (\beta): ',YlabelTxt{1}}); 
ylim(axes1,Ylims); xlim(axes1,Xlims); hold(axes1,'off');
set(axes1,'FontSize',24,'XLimitMethod','tight','XMinorTick','off','XTick',RespWin_X,'XTickLabel',repmat({''},size(RespWin_X)),'XGrid','on',...
    'YLimitMethod','tight','YMinorTick','on','YTick',YTix,'YGrid','on','YMinorGrid','on',...
    'GridAlpha',0.25,'GridLineStyle',':','GridLineWidth',0.75,'MinorGridAlpha',0.1,'MinorGridLineWidth',0.75); % Set the remaining axes properties
legend(LegendCell,'Position',[0.434765624999999 0.830276642017183 0.075 0.119672131147541])



%B: Val data, infant
axes2 = axes('Parent',figure1,'Position',[0.554537835249043 0.543992642594381 0.440208333333333 0.41850934044987]); hold(axes2,'on');
for k = 1:numel(ValDataTypeList)
    plot(NaN*[1 2 3 4],[1 2 3 4],'Color',ValDataClrs(k,:),'LineWidth',2) 
end
GetRespEffPlotsFnOfRespWin_ValData(ValTab,ValDataClrs,u_RespToSpkr{1},MainOrSI,ValDataTypeList);
title('B')
ylim(axes2,Ylims); xlim(axes2,Xlims); hold(axes2,'off');
set(axes2,'FontSize',24,'XLimitMethod','tight','XMinorTick','off','XTick',RespWin_X,'XTickLabel',repmat({''},size(RespWin_X)),'XGrid','on',...
    'YLimitMethod','tight','YMinorTick','on','YTick',YTix,'YTickLabel',repmat({''},size(YTix)),'YGrid','on','YMinorGrid','on',...
    'GridAlpha',0.25,'GridLineStyle',':','GridLineWidth',0.75,'MinorGridAlpha',0.1,'MinorGridLineWidth',0.75); % Set the remaining axes properties
legend(ValDataLegend,'Position',[0.839062499999999 0.852971314542075 0.1390625 0.0850409836065574]);



%C: LENA daylong, adult
axes3 = axes('Parent',figure1,'Position',[0.0779166666666667 0.0867076502732242 0.440208333333333 0.41850934044987]); hold(axes3,'on');
GetRespEffPlotsFnOfRespWin_LENAday(LENATab,LENAClrs,u_RespToSpkr{2},MainOrSI,InfAge);
title('C'); ylabel({'Response effect (\beta): ',YlabelTxt{2}}); xlabel('Response window,        (s)');
ylim(axes3,Ylims); xlim(axes3,Xlims); hold(axes3,'off');
set(axes3,'FontSize',24,'XLimitMethod','tight','XMinorTick','off','XTick',RespWin_X,'XTickLabel',{'0.5','1','2','3','4','5','6','7','8','9','10'},'XGrid','on',...
    'YLimitMethod','tight','YMinorTick','on','YTick',YTix,'YGrid','on','YMinorGrid','on',...
    'GridAlpha',0.25,'GridLineStyle',':','GridLineWidth',0.75,'MinorGridAlpha',0.1,'MinorGridLineWidth',0.75); % Set the remaining axes properties



%D: Val data, adult
axes4 = axes('Parent',figure1,'Position',[0.554566244339952 0.0856830601092899 0.440208333333333 0.41850934044987]); hold(axes4,'on');
GetRespEffPlotsFnOfRespWin_ValData(ValTab,ValDataClrs,u_RespToSpkr{2},MainOrSI,ValDataTypeList);
title('D'); xlabel('Response window,        (s)');
ylim(axes4,Ylims); xlim(axes4,Xlims); hold(axes4,'off');
set(axes4,'FontSize',24,'XLimitMethod','tight','XMinorTick','off','XTick',RespWin_X,'XTickLabel',{'0.5','1','2','3','4','5','6','7','8','9','10'},'XGrid','on',...
    'YLimitMethod','tight','YMinorTick','on','YTick',YTix,'YTickLabel',repmat({''},size(YTix)),'YGrid','on','YMinorGrid','on',...
    'GridAlpha',0.25,'GridLineStyle',':','GridLineWidth',0.75,'MinorGridAlpha',0.1,'MinorGridLineWidth',0.75); % Set the remaining axes properties



%Annotations and textboxes
annotation(figure1,'textbox',[0.717113665389528 0.970252321511483 0.121807151979566 0.0394467213114754],'String',{'Validation data'},'FontSize',24,...
    'FitBoxToText','off','EdgeColor','none');
annotation(figure1,'textbox',[0.233195641762453 0.969162996892748 0.157886334610473 0.0394467213114755],'String',{'LENA day-long data'},'FontSize',24,...
    'FitBoxToText','off','EdgeColor','none');
annotation(figure1,'textbox',[0.333854166666666 0.00487431713531613 0.0420144478480021 0.0422131145586733],'String',{'$T_{\rm resp}$'},...
    'Interpreter','latex','FontWeight','bold','FontSize',26,'EdgeColor','none');
annotation(figure1,'textbox',[0.8109375 0.00487431713531605 0.0420144478480021 0.0422131145586733],'String',{'$T_{\rm resp}$'},'Interpreter','latex',...
    'FontWeight','bold','FontSize',26,'EdgeColor','none');
annotation(figure1,'textbox',[0.000185584291187742 0.973897540983611 0.0408684546615581 0.0230532786885246],'String',WithOrWoCtrlTxt,'FitBoxToText','off'); 
annotation(figure1,'line',[0.2015625 0.927083333333],[0.612729508196723 0.612729508196723]);

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %function to plot the subplots: given the input table (InputTab) and the speaker type (RespToSpkr) whose response betas need to be plotted, this function plots
    % the response betas as a function of the response window, for each infant age block (InfAge). The colors for each age is speacified by the LineClrs array. 
    %Finally, MainOrSI indicates whether the figure goes in the main text or the SI. If the former, we only plot sig levels of 0.001. Otherwise, we plot differet sig levels.
    function [RespWin_X] = GetRespEffPlotsFnOfRespWin_LENAday(InputTab,LineClrs,RespToSpkr,MainOrSI,InfAge)

        %For easier visualisation, we stagger the different ages around the response window values. This is so that the CIs and the variation in effect sizes as a function of 
        % response window and age are easily visible. To do this, we first have the response window values scaled by a factor (this factor is 5, as of now), and we add a modifier 
        % for each age (as specified by AddModif below). So for InfAge = 3 months (which is the first age), the x axis point to plot the response beta for response window = 1 s would
        % actually be ((1*5) - 0.5). Here, 5 is the factor by which we scale the response window vector, and -0.5 is the additive modifier we are using to stagger for age = 3 months. 
        %In addition, to guide the eye, we also connect the error bar-d points with a patch (so we can control the transparency).
    
        SigLvlVec = 0.001; SigLvlMkrSz = 10; %default significance level value and correponding marker size (for main text)
        SubTab = InputTab(strcmp(InputTab.ResponseType,RespToSpkr),:); %susbet for the given responder and speaker type
        RespWinVals_UnMod = sort(unique(SubTab.RespWin_Seconds)); %get response window values 

        RespWin_X = RespWinVals_UnMod; RespWinScaleVal = 10; RespWin_X = RespWin_X*RespWinScaleVal; %get the scaled X axis values 
        AddModif = [-1.5 -0.5 0.5 1.5]; %specifiy the vector of additive modifiers to stagger, for each age, as a vector

        plot([RespWin_X(1)-10 RespWin_X(end)+10],zeros(1,2),'LineWidth',0.75,'Color',[1 1 1]); %first, plot a white line to mask the zero grid line, and then plot the zero line
        %plot([RespWin_X(1)-10 RespWin_X(end)+10],zeros(1,2),'LineWidth',1,'Color',[0.8008 0.8008 0.8008],'LineStyle','--'); 
        plot(RespWin_X(1)-10:0.35:RespWin_X(end)+10,zeros(size(RespWin_X(1)-10:0.35:RespWin_X(end)+10)),'.','Color',[0.54 0.54 0.54],'LineStyle','none','MarkerSize',5); 
        
        %Plot the patch first (so that they are behind all the other stuff).
        Patch_X = [RespWin_X; flip(RespWin_X)]; %get patch X coords
        for i = 1:numel(InfAge) %go through Infant age
            TabToPlot = SubTab(SubTab.InfAge_Months == InfAge(i),:); TabToPlot = sortrows(TabToPlot,'RespWin_Seconds'); %subset table for relevant age and sort 
            %error check: make sure that the response window values match the unmodified values we picked out earlier.
            if ~isequal(TabToPlot.RespWin_Seconds,RespWinVals_UnMod)
                error('Response window values do not match')
            end
            %Plot patch: add the required X axis value modifier, use the line colour for the given age, etc.
            patch(Patch_X+AddModif(i),[TabToPlot.Response_Beta-0.0001; flip(TabToPlot.Response_Beta)+0.0001],LineClrs(i,:),'FaceColor','none',...
                'EdgeColor',LineClrs(i,:),'EdgeAlpha',0.15,'LineWidth',3)
        end
        
        %Now, we plot the error bars and significance level points with different sizes, etc.
        for i = 1:numel(InfAge)
            TabToPlot = SubTab(SubTab.InfAge_Months == InfAge(i),:); TabToPlot = sortrows(TabToPlot,'RespWin_Seconds');
            %plot the error bars (without any markers)
            errorbar(RespWin_X+AddModif(i),TabToPlot.Response_Beta,abs(TabToPlot.Response_Beta-TabToPlot.ResponseCI_Lwr),abs(TabToPlot.Response_Beta-TabToPlot.ResponseCI_Upper),...
                'Color',LineClrs(i,:),'LineWidth',1.5,'LineStyle','none'  )
            
            %significance level plotting
            if ~strcmpi('MainTxt',MainOrSI) %check if this is for main text or SI
                SigLvlVec = [0.05 0.01 SigLvlVec]; %add extra sig lvl values if this is for SI
                SigLvlMkrSz = [8 7 SigLvlMkrSz]; %add marker sizes
            end

            BetaUpdate_SigLvl = TabToPlot.Response_Beta; %get the beta values (we will then modify this for diff sig levls)
            for j = 1:numel(SigLvlVec) %go through teh significance leevl vector
                BetaUpdate_SigLvl(TabToPlot.ResponseP >= SigLvlVec(j)) = NaN; %any beta values with p values above the sig lvl is set to NaN so they don't get plotted
                if SigLvlVec(j) == 0.05 %if siglvl 0.05, open circle
                    plot(RespWin_X+AddModif(i),BetaUpdate_SigLvl,'o','MarkerSize',SigLvlMkrSz(j),'MarkerEdgeColor',LineClrs(i,:),'MarkerFaceColor',[1 1 1],...
                        'LineStyle','none','LineWidth',1.25);%,'MarkerEdgeColor', 'b')
                else
                    plot(RespWin_X+AddModif(i),BetaUpdate_SigLvl,'o','MarkerSize',SigLvlMkrSz(j),'MarkerEdgeColor',LineClrs(i,:),'MarkerFaceColor',LineClrs(i,:),...
                        'LineStyle','none','LineWidth',1.5);%,'MarkerEdgeColor', 'b')
                end
            end
        end
    end


%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    %Function to plot the subplots: given the input table (InputTab) and the speaker type (RespToSpkr) whose response betas need to be plotted, this function plots the response betas as 
    % a function of the response window, for each labelling type for the validation effort (ValDataTypeList). The colors for each validation type is speacified by the LineClrs array. 
    %Finally, MainOrSI indicates whether the figure goes in the main text or the SI. If the former, we only plot sig levels of 0.001. Otherwise, we plot differet sig levels.
    function [RespWin_X] = GetRespEffPlotsFnOfRespWin_ValData(InputTab,LineClrs,RespToSpkr,MainOrSI,ValDataTypeList)
    
        %For easier visualisation, we stagger the different ages around the response window values. This is so that the CIs and the variation in effect sizes as a function of 
        % response window and validation labelling type are easily visible. To do this, we first have the response window values scaled by a factor (this factor is 5, as of now), and 
        % we add a modifier for each labelling method (as specified by AddModif below).  
        %In addition, to guide the eye, we also connect the error bar-d points with a patch (so we can control the transparency).

        SigLvlVec = 0.001; SigLvlMkrSz = 10; %default significance level value and correponding marker size (for main text)
        SubTab = InputTab(strcmp(InputTab.ResponseType,RespToSpkr),:); %susbet for the given responder and speaker type
        RespWinVals_UnMod = sort(unique(SubTab.RespWin_Seconds)); %get response window values 

        RespWin_X = RespWinVals_UnMod; RespWinScaleVal = 10; RespWin_X = RespWin_X*RespWinScaleVal; %get the scaled X axis values 
        AddModif = [-1.5 -0.5 0.5 1.5]; %specifiy the vector of additive modifiers to stagger, for each age, as a vector

        plot([RespWin_X(1)-10 RespWin_X(end)+10],zeros(1,2),'LineWidth',0.75,'Color',[1 1 1]); %first, plot a white line to mask the zero grid line, and then plot the zero line
        plot(RespWin_X(1)-10:0.35:RespWin_X(end)+10,zeros(size(RespWin_X(1)-10:0.35:RespWin_X(end)+10)),'.','Color',[0.54 0.54 0.54],'LineStyle','none','MarkerSize',5); 
        
        %Plot the patch first (so that they are behind all the other stuff).
        Patch_X = [RespWin_X; flip(RespWin_X)]; %get patch X coords
        for i = 1:numel(ValDataTypeList) %go through validation labelling type
            TabToPlot = SubTab(contains(SubTab.DataType, ValDataTypeList{i}),:); TabToPlot = sortrows(TabToPlot,'RespWin_Seconds'); %subset table for relevant labelling method and sort 
            %error check: make sure that the response window values match the unmodified values we picked out earlier.
            if ~isequal(TabToPlot.RespWin_Seconds,RespWinVals_UnMod)
                error('Response window values do not match')
            end
            %Plot patch: add the required X axis value modifier, use the line colour for the given age, etc.
            patch(Patch_X+AddModif(i),[TabToPlot.Response_Beta-0.0001; flip(TabToPlot.Response_Beta)+0.0001],LineClrs(i,:),'FaceColor','none',...
                'EdgeColor',LineClrs(i,:),'EdgeAlpha',0.15,'LineWidth',3)
        end

        %Now, we plot the error bars and significance level points with different sizes, etc.
        for i = 1:numel(ValDataTypeList)
            TabToPlot = SubTab(contains(SubTab.DataType, ValDataTypeList{i}),:); TabToPlot = sortrows(TabToPlot,'RespWin_Seconds');
            %plot the error bars (without any markers)
            errorbar(RespWin_X+AddModif(i),TabToPlot.Response_Beta,abs(TabToPlot.Response_Beta-TabToPlot.ResponseCI_Lwr),abs(TabToPlot.Response_Beta-TabToPlot.ResponseCI_Upper),...
                'Color',LineClrs(i,:),'LineWidth',1.5,'LineStyle','none')
            
            %significance level plotting
            if ~strcmpi('MainTxt',MainOrSI) %check if this is for main text or SI
                SigLvlVec = [0.05 0.01 SigLvlVec]; %add extra sig lvl values if this is for SI
                SigLvlMkrSz = [8 7 SigLvlMkrSz]; %add marker sizes
            end

            BetaUpdate_SigLvl = TabToPlot.Response_Beta; %get the beta values (we will then modify this for diff sig levls)
            for j = 1:numel(SigLvlVec) %go through teh significance leevl vector
                BetaUpdate_SigLvl(TabToPlot.ResponseP >= SigLvlVec(j)) = NaN; %any beta values with p values above the sig lvl is set to NaN so they don't get plotted
                if SigLvlVec(j) == 0.05 %if siglvl 0.05, open circle
                    plot(RespWin_X+AddModif(i),BetaUpdate_SigLvl,'o','MarkerSize',SigLvlMkrSz(j),'MarkerEdgeColor',LineClrs(i,:),'MarkerFaceColor',[1 1 1],...
                        'LineStyle','none','LineWidth',1.25);%,'MarkerEdgeColor', 'b')
                else
                    plot(RespWin_X+AddModif(i),BetaUpdate_SigLvl,'o','MarkerSize',SigLvlMkrSz(j),'MarkerEdgeColor',LineClrs(i,:),'MarkerFaceColor',LineClrs(i,:),...
                        'LineStyle','none','LineWidth',1.5);%,'MarkerEdgeColor', 'b')
                end
            end
        end
    end

%----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
end