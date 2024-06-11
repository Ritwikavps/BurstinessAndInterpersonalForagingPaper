clear all
clc

%This script plots a 4-panel figure with infant and adult response betas with and without the step size control, for different ages and response windows using the custom function
% GetRespBetasAsFnOfAgeFig.m. This script does this for LENA day0long data, LENA 5 min data, and human-labelled 5 min data, by specifiying the input string and path

LineClrs_LENA = [0 0 0 ; 126 3 168;    204 71 120;  248  149 64]/256;
LineClrs_SI = [0 0 0; 126 3 168;    204 71 120]/256;
QtyToPlot = 'InterVocInt'; %{'InterVocInt','DistPitch','DistAmp','DistDuration'}; %{'InterVocInt','Dist2D','Dist3D'}

%paths
Basepath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/';
LENApath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_LENA/');
LENA5minpath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_LENA5min/');
Humpath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_H/');
HumChildDirANOnlyPath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_H_ChildDirANOnly/');

PathTotabs = {LENA5minpath, Humpath,HumChildDirANOnlyPath}; %put the paths into a cell
DataTypePrefix = {'LENA5min','Hum','HumChildDirANOnly'}; %prefixes to specify data type

GetRespBetasAsFnOfAgeFig(LENApath,'LENA',QtyToPlot,LineClrs_LENA)
GetRespBetNoAge_ValData_Fig(PathTotabs,DataTypePrefix,QtyToPlot,LineClrs_SI)

%Sub-optimal line colour options
%LineClrs = [0 0 0;     0 0.4470 0.7410;    0.8500 0.3250 0.0980;     0.4940 0.1840 0.5560]; %the different line colours for diff infant ages
%LineClrs = ([252 197 192;    247 104 161;    174 1 126;    73 0 106])/256;
%LineClrs = [ 0 0 0;     189 0 38;       253 141 60;      255 237 160]/256;
%StartClr = [65 255 255]/256;%[65 182 255]/256;%
% EndClr = [255 27 255]/256; %[197 27 125]/256; %
% LineClrs = [(linspace(StartClr(1),EndClr(1),4))' ...
% (linspace(StartClr(2),EndClr(2),4))' ...
% (linspace(StartClr(3),EndClr(3),4))'];