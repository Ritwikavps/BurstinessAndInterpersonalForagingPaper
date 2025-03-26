clear all
clc

%Ritwika VPS: code to plot the transformed CurrIVI-PrevIVI regression as well as the WR-WOR residuals in the schematic figure in main text, as well as the more detailed associated SI figs. To 
% do this, we use LENA day-long data where the infant is the vocaliser and the adult is the responder, and pick an infant age and infant ID, as well as a response window (for WR-WOR residuals)
% randomly.

%-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%CHANGE PATHS AND INPUT STRINGS ACCORDINGLY
Basepath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/';
cd(Basepath) %go to path with table
Opts = detectImportOptions('PrevStSizeResids_VarsScaleLog_RecDayLvl_IviOnly.csv'); %get table import options (this is so we can set columns to the correct data type, eg. string, double, etc)
VarNames = Opts.VariableNames; %Get the variabl names for the table
RespVarNames = VarNames(contains(VarNames,'Response_')); %get the set of response variable names (these need to be set to 'double')
Opts = setvartype(Opts,RespVarNames,'double'); %set the data type for all response columns to double (some of them get read in as strings otherwise)
Opts = setvartype(Opts,'InfantID','string'); %set infant ID data type as string
DataTab = readtable('PrevStSizeResids_VarsScaleLog_RecDayLvl_IviOnly.csv',Opts); %Read in data table with the correct options
% -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

WOR_Clr = [206 100 99]/256; WR_Clr = [126 167 45]/256; %colours to plot for WR and WOR

%first, randomly select an infant ID and age for LENA day-long data, infant speaker. This if for the main text figure.
u_Age = unique(DataTab.AgeMonths); u_ID = unique(DataTab.InfantID); %get unique ID and ages
while true %infinite while loop (just in case we pick an ID and age combo that does not have data
    RandAgeInd = randi(numel(u_Age)); RandIdInd = randi(numel(u_ID)); %pick a random ID and age
    SubTab = DataTab(strcmp(DataTab.DataType,'LENA') & contains(DataTab.InfantID,u_ID{RandIdInd}) &...
                     strcmp(DataTab.ResponseType,'ANRespToCHNSP') & DataTab.AgeMonths == u_Age(RandAgeInd),:); %subset the required table
    if ~isempty(SubTab) %check that the subsetted table does, in fact, have data
        break
    end
end

%pick random response window
RandRespInd = randi(11); %there are 11 response windows, so pick one randomly
RandRespVar = RespVarNames{RandRespInd}; %pick out the corresponding response variable name
%PLOTTING-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%I) Plot Main text schematic figure

%compute pieces that go into first subplot: linear fit
LinFit = fitlm(SubTab.PrevIVI_Trans,SubTab.CurrIVI_Trans); %linear fit for curr vs prev IVI; note that the first coeff is the intercept, and the second coeff is the slope
X_Fit = min(SubTab.PrevIVI_Trans):(range(SubTab.PrevIVI_Trans)/200):max(SubTab.PrevIVI_Trans); %Get x values for fit (min_prevIVI to max_PrevIVI, with an increment such that there are a total 
% of 201 x points to plot
Fit_Intercept = LinFit.Coefficients.Estimate(1); Fit_Slope = LinFit.Coefficients.Estimate(2); %get slope and intercept from fit
Fit_Slope_pval = LinFit.Coefficients.pValue(2); %get p value for the intercept

%compute pieces that go into second subplot: histogram bin centers and frequencies
[WR_Resid_y,WR_Resid_x] = GetHistBinCentersAndVals(SubTab.ResidVar(SubTab.(RandRespVar) == 1)); %get histogram bin centres and frequencies for WR, for randomly chosen response window
[WOR_Resid_y,WOR_Resid_x] = GetHistBinCentersAndVals(SubTab.ResidVar(SubTab.(RandRespVar) == 0)); %similarly for WOR

%Initialise figure
figure1 = figure('PaperType','<custom>','PaperSize',[18.5 9],'Color',[1 1 1]);

%subplot 1: transformed CurrIVI vs PrevIVI
axes1 = axes('Parent',figure1,'Position',[0.101733232856066 0.17156862745098 0.362925858053025 0.774673202614379]); hold(axes1,'on'); %get axes
scatter(SubTab.PrevIVI_Trans,SubTab.CurrIVI_Trans,30,'filled','Marker','square','MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
    'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'LineWidth',1,'MarkerFaceAlpha',0.5); %scatter plot (data)
plot(X_Fit, X_Fit*Fit_Slope + Fit_Intercept, '--','LineWidth',1.5,'Color',[0.603921592235565 0.596078455448151 0.596078455448151]); %line: fit
axis tight; hold(axes1,'off'); set(axes1,'FontSize',24); %set remaining axes properties
xlabel('$f_z  (\mathrm{log}_{10} \: \mathrm{IEI}_{i-1})$','interpreter','latex'); ylabel('$f_z (\mathrm{log}_{10} \mathrm{IEI}_{i})$','Interpreter','latex');
title('C')


%subplot 2: WR and WOR residuals
axes2 = axes('Parent',figure1,'Position',[0.581644601630472 0.172058823529412 0.362925858053025 0.774673202614379]); hold(axes2,'on');
scatter(WR_Resid_x,WR_Resid_y,60,'filled','MarkerEdgeColor',WR_Clr,'LineWidth',1,'MarkerFaceAlpha',0.5,'MarkerFaceColor',WR_Clr,'Marker','o'); %plot
scatter(WOR_Resid_x,WOR_Resid_y,60,'filled','MarkerEdgeColor',WOR_Clr,'LineWidth',1,'MarkerFaceAlpha',0.5,'MarkerFaceColor',WOR_Clr,'Marker','o');
%plot(WR_Resid_x,WR_Resid_y,'LineWidth',1.5,'Color',[WR_Clr 0.2]);
%plot(WOR_Resid_x,WOR_Resid_y,'LineWidth',1.5,'Color',[WOR_Clr 0.2]);
axis tight; hold(axes2,'off'); set(axes2,'FontSize',24);
legend('Resp','NoResp'); xlabel('Residual IEIs (   )'); ylabel('Frequency (normalized)'); title('D');

% Create textbox
annotation(figure1,'textbox',[0.832289491997218 0.0394074706124531 0.0410427247474155 0.0699490658900936],'String',{'$R_i$'},'Interpreter','latex',...
    'FontSize',26,'FontName','Helvetica Neue','EdgeColor','none');


%-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%II) Plot extra SI fig

%compute pieces that go into subplots 3 and 4: WR and WOR distributions for raw IVI and transformed IVI
[WR_IVI_y,WR_IVI_x] = GetHistBinCentersAndVals(SubTab.CurrIVI(SubTab.(RandRespVar) == 1)); %Raw IVI
[WOR_IVI_y,WOR_IVI_x] = GetHistBinCentersAndVals(SubTab.CurrIVI(SubTab.(RandRespVar) == 0));

[WR_IVItrans_y,WR_IVItrans_x] = GetHistBinCentersAndVals(SubTab.CurrIVI_Trans(SubTab.(RandRespVar) == 1)); %Transformed IVI
[WOR_IVItrans_y,WOR_IVItrans_x] = GetHistBinCentersAndVals(SubTab.CurrIVI_Trans(SubTab.(RandRespVar) == 0)); 


%Initialise figure
figure2 = figure('PaperType','<custom>','PaperSize',[20.75 14],'Color',[1 1 1]);

%subplot 1: raw Curr vs prev. IVI
axes1 = axes('Parent',figure2,'Position',[0.0957933042212521 0.6062605947654 0.382902058678403 0.367039815014343]); hold(axes1,'on');
scatter(SubTab.PrevIVI,SubTab.CurrIVI,30,'filled','Marker','square','MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
    'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'LineWidth',1,'MarkerFaceAlpha',0.5); %scatter plot (data)
ylabel('(raw; s)'); xlabel(' (raw; s)'); title('A');
axis tight; hold(axes1,'off'); set(axes1,'FontSize',24);

% Create textbox for axis label
annotation(figure2,'textbox',[0.226851851851851 0.497523384763743 0.0363756613756614 0.0496323529411766],'String',{'${\rm IEI}_{i-1}$'},...
    'LineStyle','none','Interpreter','latex','FontSize',24,'FitBoxToText','off');

%Dummy sub-plot for the latex Y label
axes1_1 = axes('Parent',figure2,'Position',[0.201719576719577 0.78688524590164 0.094576719576719 0.111680327868852]);
ylabel('${\rm IEI}_i$','Interpreter','latex');
axis(axes1_1,'tight'); set(axes1_1,'FontSize',24,'XColor',[0 0 0],'XTick',zeros(1,0),'YColor',[0 0 0],'YTick',zeros(1,0),'ZColor',[0 0 0]);


%subplot 2: transformed CurrIVI vs PrevIVI
axes2 = axes('Parent',figure2,'Position',[0.58806404657933 0.604508196721312 0.382902058678403 0.36703981501434]); hold(axes2,'on');
scatter(SubTab.PrevIVI_Trans,SubTab.CurrIVI_Trans,30,'filled','Marker','square','MarkerEdgeColor',[0 0.447058826684952 0.74117648601532],...
    'MarkerFaceColor',[0 0.447058826684952 0.74117648601532],'LineWidth',1,'MarkerFaceAlpha',0.5); %scatter plot (data)
plot(X_Fit, X_Fit*Fit_Slope + Fit_Intercept, '--','LineWidth',1.5,'Color',[0.603921592235565 0.596078455448151 0.596078455448151]); %line: fit
ylabel('$f_z ({\rm log}_{10} {\rm IEI}_{i})$','Interpreter','latex'); xlabel('$f_z ({\rm log}_{10} {\rm IEI}_{i-1})$','Interpreter','latex'); title('B');
axis tight; hold(axes2,'off'); set(axes2,'FontSize',24);


%subplot 3: WR and WOR distributions of raw IVI
axes3 = axes('Parent',figure2,'Position',[0.0957933042212521 0.101059973526117 0.382902058678403 0.367039815014341]); hold(axes3,'on');
% scatter(WR_IVI_x,WR_IVI_y,30,'filled','MarkerEdgeColor',WR_Clr,'LineWidth',1,'MarkerFaceAlpha',0.5,'MarkerFaceColor',WR_Clr,'Marker','o'); %plot
% scatter(WOR_IVI_x,WOR_IVI_y,30,'filled','MarkerEdgeColor',WOR_Clr,'LineWidth',1,'MarkerFaceAlpha',0.5,'MarkerFaceColor',WOR_Clr,'Marker','o');
plot(WR_IVI_x,WR_IVI_y,'Marker','.','LineWidth',1.5,'Color',[WR_Clr 0.2],'MarkerSize',20);
plot(WOR_IVI_x,WOR_IVI_y,'Marker','.','LineWidth',1.5,'Color',[WOR_Clr 0.2],'MarkerSize',20);
ylabel('Frequency (normalized)'); xlabel('IEI (raw; s)'); title('C');
legend('Resp','NoResp')
axis tight; hold(axes3,'off'); set(axes3,'FontSize',24); 


%subplot 4: WR and WOR distributions of transformed IVI and residuals
axes4 = axes('Parent',figure2,'Position',[0.589240738460345 0.101059973526117 0.382902058678403 0.367039815014341]); hold(axes4,'on');
plot(WR_IVItrans_x,WR_IVItrans_y,'Marker','.','LineWidth',1.5,'Color',[WR_Clr 0.2],'MarkerFaceColor',WR_Clr,'MarkerSize',20);
plot(WOR_IVItrans_x,WOR_IVItrans_y,'Marker','.','LineWidth',1.5,'Color',[WOR_Clr 0.2],'MarkerFaceColor',WOR_Clr,'MarkerSize',20);
plot(WR_Resid_x,WR_Resid_y,'Marker','square','LineWidth',1.5,'Color',[WR_Clr 0.2],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',WR_Clr,'MarkerSize',8);
plot(WOR_Resid_x,WOR_Resid_y,'Marker','square','LineWidth',1.5,'Color',[WOR_Clr 0.2],'MarkerFaceColor',[1 1 1],'MarkerEdgeColor',WOR_Clr,'MarkerSize',8);
legend('WR: IEI (transformed)','WOR: IEI (transformed)','WR: Residual IEI','WOR: Residual IEI') 
ylabel('Frequency (normalized)'); xlabel('$f_z ({\rm log}_{10} {\rm IEI}) $ ','Interpreter','latex'); title('D');
axis(axes4,'tight'); hold(axes4,'off'); set(axes4,'FontSize',24);

% Create textboxes for axis labels
annotation(figure2,'textbox',[0.879629629629612 0.00723794599807188 0.225529100529109 0.049632352941176],'String','$R_{i}$','LineStyle','none',...
    'Interpreter','latex','FontSize',26);
annotation(figure2,'textbox',[0.767195767195756 0.006081726133076 0.144841269841281 0.0496323529411764],'String','or Residual IEI (    )',...
    'LineStyle','none','FontSize',26);

% Create lines to align text boxes
annotation(figure2,'line',[0.0410052910052875 0.0410052910052875],[0.970311475409845 0.161885245901648]);
annotation(figure2,'line',[0.10648148148148 0.930555555555551],[0.0164180327868898 0.0164180327868898]);


%FINALLY, print outputs to console
fprintf('Data used: LENA day-long, CHNSP vocaliser, infant ID = %s, infant age = %i months, response window = %0.1f s \n',u_ID{RandIdInd},u_Age(RandAgeInd),...
                                                                                                            str2double(regexprep(RespVarNames{RandRespInd},'.*_',''))) %details of recording
fprintf('The linear fit for log-d, z-scored CurrIEI vs. PrevIEI is %0.4f x + %0.4e, and the p-value associated with the slope is %0.4e \n',...
                                            Fit_Slope,Fit_Intercept,Fit_Slope_pval) %linear fit values and p value of slope


%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%This function computes the histogram bin centres and frequencies of the input variable (WR and WOR resiuals/IVIs, as applicable).
function [BinFreq,BinCenterVals] = GetHistBinCentersAndVals(TargetVar)
    [BinFreq,BinEdges] = histcounts(TargetVar,12,'Normalization','probability'); %get histogram bin edges and frequencies
    BinCenterVals = 0.5*(BinEdges(1:end-1)+BinEdges(2:end)); %get bin centers
end






% %-------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% %III) A thought for a set of IS plots is this: an 8 panel figure with C and D from the SI fig associated with Fig 1 in main text, repeated 4 times for each data type (LENA day-long, LENA 
% 5 min, human listener labelled 5 min with all adult vocs, and human listener labelled 5 min with only infant directed adult vocs). One figure would have this for CHNSP utterances, and 
% a second figure would have this for adult utterances. Because we are demo-ing WR and WOR, we'd have to pick a response window. While these figure would look nice, they don't add any more 
% info than the analyses, and the analyses show the (possible) conclusions from these figures in more statistically grounded and elegant ways. Below, some preliminary code for these proposed 
% figures are provided (commented out).
% figure;
% 
% %CHNSP utterances: LENA day long
% %Get distributions for CHNSP utterances, 2 s response window, LENA daylong data
% ReqTab = DataTab(strcmp(DataTab.DataType,'LENA') & strcmp(DataTab.ResponseType,'ANRespToCHNSP'),:); %subset the required table
% 
% %Raw IVI distributions
% [WR_IVI_y,WR_IVI_x] = GetHistBinCentersAndVals(ReqTab.CurrIVI(ReqTab.Response_2 == 1)); %Raw IVI
% [WOR_IVI_y,WOR_IVI_x] = GetHistBinCentersAndVals(ReqTab.CurrIVI(ReqTab.Response_2 == 0));
% 
% %Transformed IVI distributions
% [WR_IVItrans_y,WR_IVItrans_x] = GetHistBinCentersAndVals(ReqTab.CurrIVI_Trans(ReqTab.Response_2 == 1)); %Transformed IVI
% [WOR_IVItrans_y,WOR_IVItrans_x] = GetHistBinCentersAndVals(ReqTab.CurrIVI_Trans(ReqTab.Response_2 == 0)); 
% 
% %Residual distributions
% [WR_Resid_y,WR_Resid_x] = GetHistBinCentersAndVals(ReqTab.ResidVar(ReqTab.Response_2 == 1)); %get histogram bin centres and frequencies for WR, for randomly chosen response window
% [WOR_Resid_y,WOR_Resid_x] = GetHistBinCentersAndVals(ReqTab.ResidVar(ReqTab.Response_2 == 0)); %similarly for WOR
% 
% 
% subplot(4,2,1);
% hold all
% plot(WR_IVI_x,WR_IVI_y,'LineWidth',1,'Color',WR_Clr,'.');
% plot(WOR_IVI_x,WOR_IVI_y,'LineWidth',1,'Color',WOR_Clr,'.');
% 
% subplot(4,2,2);
% hold all
% plot(WR_IVItrans,WR_IVItrans_y,'LineWidth',1,'Color',WR_Clr,'.');
% plot(WOR_IVItrans_x,WOR_IVItrans_y,'LineWidth',1,'Color',WOR_Clr,'.');
% plot(WR_Resid,WR_Resid_y,'LineWidth',1,'Color',WR_Clr,'+');
% plot(WOR_Resid_x,WOR_Resid_y,'LineWidth',1,'Color',WOR_Clr,'+');
% 
% 
% %CHNSP utterances: LENA 5 min
% 
% %CHNSP utterances: H 5 min, all adult
% 
% %CHNSP utterances: H 5 min, chnsp-directed  adult



