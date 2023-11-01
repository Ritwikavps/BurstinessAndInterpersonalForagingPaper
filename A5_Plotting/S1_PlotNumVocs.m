clear all
clc

%Ritwika VPS
%June 2023

cd '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/AnalysesResults/DataTabsForStats/R1_FirstPassAnalyses'

myData = readtable('NumAnAndChnVocs.xlsx');



figure1 = figure('Color',[1 1 1]);
subplot(2,1,1); hold all

%subplot 1: num vocs of each type from each labelling method
yDat1 = [myData.NumVocsAN'; myData.NumVocsCHNNSP'; myData.NumVocsCHNSP'];
% Create multiple lines using matrix input to bar
bar1 = bar(yDat1);
% Set the remaining axes properties
xticks([1 2 3])
xticklabels({'AN','CHNSP','CHNNSP'})
ylabel('Num. vocalisations')
% Create legend
legend1 = legend({'LENA (day-long)','LENA (5 min)','Hum (5 min)'});
set(legend1,'Orientation','horizontal');

%subplot 2: frac of diff types of vocs for each labelling method
subplot2 = subplot(2,1,2,'Parent',figure1);
hold(subplot2,'on');

yDat2 = table2array(myData(:,[2 4 5])); %get num of each type of voc for each labelling ty[e
yDat2 = yDat2./sum(yDat2,2); %normalise, to show fraction
% Create multiple lines using matrix input to bar
bar2 = bar(yDat2,'Parent',subplot2,'BarLayout','stacked');
set(bar2(1),'DisplayName','AN');
set(bar2(2),'DisplayName','CHNSP');
set(bar2(3),'DisplayName','CHNNSP');

axis('tight')
axis(subplot2,'tight');
hold(subplot2,'off');
% Set the remaining axes properties
set(subplot2,'FontSize',30,'XTick',[0 1 2 3 4],'XTickLabel',...
    {'','LENA (day-long)','LENA (5 min)','Hum (5 min)',''});
ylabel('Fraction of vocalisations')
% Create legend
legend2 = legend(subplot2,'show');
set(legend2,'Orientation','horizontal');

