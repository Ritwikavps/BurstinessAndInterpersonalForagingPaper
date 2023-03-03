function [ParamsOp, BestFitMatchFlag] = GetAICBestFitParams(AIC_MleInput,BestFitMode,BestFitFlag,StepType)

%This function outputs the parameters associated with the most common best AIC fit (input BestFitMode) for a given step size category for a given recording day. For
%eg. for a step size category whose most common best fit is exponential, this parameter output would be the lambda value. For a step size category
%whose most common best fit is lognormal, this parameter output would be [mu sigma]. This function also outputs a flag (0 or 1) that summarises
%whether the AIC best fit for the input step size data is the same as the most common AIC best fit for that step size category.

%To illustrate, consider the e. of WR infant speech related pitch steps where the adult response is computed based on a 1s response window. This function
%only deals with the WR infant speech related pitch step vector from a single recording day. The AIC_MleInput is a structure that contains the
%AIC parameters for all 4 candidate distributions (exponential, lognormal, normal, and pareto) for all step size types (amplitude, pitch, 2d and 3d
%step, duration, and intervocalisation interval) for the WR category for that infant for that recording day. Indexing by the BestFitMode
%(which is the most common best fit type for the WR infant speech related pitch steps acorss all recording days) gets the parameter values
%corresponding to the BestFitMode (where Mode stands for the most frequent value). 

%In addition, this also outputs a flag, which specifies whether the AIC best fit for the WR infant speech related pitch steps for this infant on
%this recording day matches the most common AIC best fit for the WR infant speech related pitch steps for the entire corpus.

%Inputs: - AIC_MleInput: Nested structure that has AIC best fit parameters for all step size categories for a given speaker on a given recording day
            %(for that specific type; eg. speech related WR steps)
        %- BestFitFlag: AIC best fit type for the specific distribution (eg. infant speech related WR pitch steps) for that infant for that recording day; double
        %- BestFitMode: The most common AIC best fit type for that distribution category eg. infant speech related WR pitch steps); double
        %- StepType: The step size category (to use in the switch block); string

%Outputs: - ParamsOp: an array that contains AIC best fit parameyters for the diustribution type for the speaker for the recording day
         %- BestFitMatchFlag: Flag that summarises whether the best fit for the specific speaker on the specific recording day for the
            %distribution category matches the most common AIC best fit for that category across the corpus; double

switch StepType %gets info based on the query StepType
    case 'amplitude'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_DistAmp(BestFitMode).mle.params;
    case 'pitch'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_DistPitch(BestFitMode).mle.params;
    case 'duration'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_DistDuration(BestFitMode).mle.params;
    case 'int-voc-int'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_InterVocInt(BestFitMode).mle.params;
    case '2d'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_Dist2D(BestFitMode).mle.params;
    case '3d'
        ParamsOp = AIC_MleInput.ParamStruct.AICresults_Dist3D(BestFitMode).mle.params;
    otherwise
        error('Unrecognised StepType string')
end

if BestFitMode == BestFitFlag %checks Best fit match
    BestFitMatchFlag = 1;
else
    BestFitMatchFlag = 0;
end



%WR_AICparams(1).ParamStruct.AICresults_Dist2D(1).mle.params
