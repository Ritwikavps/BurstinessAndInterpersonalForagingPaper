GetLmerCoefs_MeanAndOtherSummaryMeasures <- function(InputTabName){
  
  #initialise output vectors
  SummaryMeasure = c()
  Spkr = c()
  Age1Effect = c()
  Age1Pvalue = c()
  Age2Effect = c()
  Age2Pvalue = c()
  
  #read tables
  mydata = read.csv(InputTabName, header = TRUE)
  
  #get ID and age
  AgeVar = mydata$InfantAgeDays
  IDVar = as.factor(mydata$InfantID)
  
  for (i in 1:72){
    
    #get column name and do string split
    ColName = strsplit(colnames(mydata)[i],'_')
    
    Spkr[i] = ColName[[1]][1]
    SummaryMeasure[i] = strcat(ColName[[1]][2],ColName[[1]][3])
    
    Yvar = mydata[,i]
    
    LmerModelFormula = lmer(scale(Yvar) ~ (1|IDVar) + poly(AgeVar,2)) 
    StatsSummary = summary(LmerModelFormula) #get summary
    
    Age1Effect[i] = StatsSummary$coefficients[2,1]
    Age1Pvalue[i] = StatsSummary$coefficients[2,5]
    Age2Effect[i] = StatsSummary$coefficients[3,1]
    Age2Pvalue[i] = StatsSummary$coefficients[3,5]
  }
  
  Results_df = data.frame(SummaryMeasure,Spkr,Age1Effect,Age1Pvalue,Age2Effect,Age2Pvalue)
}