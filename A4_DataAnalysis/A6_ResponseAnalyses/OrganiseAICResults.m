function OpTab = OrganiseAICResults(ParamsOp,BestFitMatchFlag,InfantID,AgeDays,AgeMonths,BestFitMode_Tab)

%organises the AIC outputs for the whole corpus

%- ParamsOp is the cell array that contains the AIC best fit params for the best fit distribtion at the corpus level for that category
    %Indexed as (i,j) where i is the infant age/ID index and j is the step
    %type catrgory index, in the order {'pitch','amplitude','duration','int-voc-int','2d','3d'};
%- BestFitMatchFlag is the array of flags that tell if the best fit distribution type for the specific category, say CHNSP pitch step WR for
    %the specific recording is the same as the corpus-level best fit for the category. We will only admit this to stats if they match
%-BestFitMode_Tab is the table (one row) taht has the corpus-level best fit for each distribution type, in the order {'pitch','amplitude','duration','int-voc-int','2d','3d'};

%So what we want is to go through the infant ID/age index, and for each of that, go through the BestFitMode (or step size category index) and sort 
%out the fit params and sort them into a table

StepTypeCategory = {'PitchStep','AmpStep','DurationStep','IntVocInt','Step2d','Step3d'}; %to generate variable names for output table
VarNames = {}; %initialise

BestFitModeArray = table2array(BestFitMode_Tab); %convert to array

for i = 1:numel(BestFitModeArray) %go through step size type, in the order {'pitch','amplitude','duration','int-voc-int','2d','3d'};

    CorpusBestFit = BestFitModeArray(i); %get the corpus best fit for each step type category
        
    switch CorpusBestFit
        case 1 %Normal; mu, sigma
            VarNames = [VarNames strcat(StepTypeCategory{i},'NormalMu')]; %add var name strings accordingly
            VarNames = [VarNames strcat(StepTypeCategory{i},'NormalSigma')]; 
        case 2 %LogNormal; mu, sigma
            VarNames = [VarNames strcat(StepTypeCategory{i},'LognMu')];
            VarNames = [VarNames strcat(StepTypeCategory{i},'LognSigma')];    
        case 3 %Exp; lambda
            VarNames = [VarNames strcat(StepTypeCategory{i},'ExpLambda')];
        case 4 %pareto: xmin, mu
            VarNames = [VarNames strcat(StepTypeCategory{i},'ParetoXmin')];
            VarNames = [VarNames strcat(StepTypeCategory{i},'ParetoSigma')];
        otherwise
            error('Unrecognisd Corpus best fit ID')
    end
end


%This is not the best way to do this, but I have a giant eye stye and I am
%tired of trying to vectorise this bit. This isn't going to take that long
%so, idk, this is future Ritwika's problem
for i = 1:numel(BestFitMatchFlag)
    if BestFitMatchFlag(i) == 0
        ParamsOp{i} = NaN*ParamsOp{i}; %anything whose best fit doesnt match teh corpus level best fit gets turned to NaN
    end
end

%convert the whole thing to a table and add VarNames
OpTab = array2table(cell2mat(ParamsOp));
OpTab.Properties.VariableNames = VarNames;
OpTab.InfantID = InfantID;
OpTab.AgeDays = AgeDays;
OpTab.AgeMonths = AgeMonths;