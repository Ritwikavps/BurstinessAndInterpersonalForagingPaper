clear all
clc

%This script plots a figure with infant and adult prev. step size betas for different ages using the custom function GetPrevStSizeBetaFig_LENA.m and GetPrevStSizeBetaFig_SI.m.
% his script does this for LENA day0long data, LENA 5 min data, and human-labelled 5 min data, by specifiying the input string and path

LineClrs = [0 0.4470 0.7410; 0 0 0]; %first colour is for CHNSP, the second is for AN
QtyToPlot = 'InterVocInt'; %{'InterVocInt','DistPitch','DistAmp','DistDuration'}; %{'InterVocInt','Dist2D','Dist3D'}

%paths
Basepath = '/Users/ritwikavps/Desktop/GoogleDriveFiles/research/IVFCRAndOtherWorkWithAnne/Pre_registration_followu/Data/ResultsTabs/ResponseAnalyses/';
LENApath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_LENA/');
LENA5minpath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_LENA5min/');
Humpath = strcat(Basepath,'ResponseEffect_w_CurrPrevStSizeControl_H/');

GetPrevStSizeBetaFig_LENA(LENApath,QtyToPlot,LineClrs) %plot main text figure

PathTotabs = {LENA5minpath, Humpath}; %put the paths into a cell (for SI plot function)
GetPrevStSizeBetaFig_SI(PathTotabs,QtyToPlot,LineClrs) %plot SI fig