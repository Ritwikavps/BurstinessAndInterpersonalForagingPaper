#Ritwika VPS, Nov 2022
#This function takes two input tables and returns lmer coefficients and p values testing correlations between
#recording level correlations. The input tables have vectors storing recording level correlations for different measures, 
#eg. correlation between time elapsed since last interaction and step size in amplitude for infant vocs (see input tables and related scripts
#as well as documentation for the same). This function runs an lmer on each measure with infant age as a fixed effect and 
#infant ID as a random effect, and returns descriptors of the results (beta and p values). So, for the 
#example of the correlation between time elapsed since last interaction and step size in amplitude for infant vocs, if the input tables are 
#the recording level correlations for human listener data and matched LENA data, this function pops out the beta value estimating how this correlation
#measure compares between human listener labelled data and the matched LENA data, the associated p value, as well as the beta value for the age effect and 
#its p value

GetLmerCoefs_RecLvlCorrelations <- function(InputTabName1,InputTabName2){
  
  #initialise output vectors
  Ymeasure = c()
  Spkr = c()
  AgeEffect = c()
  AgePvalue = c()
  RecLvlCorrelationBeta = c()
  RecLvlCorrelationPvalue = c()
  
  #read tables
  Tab1 = read.csv(InputTabName1, header = TRUE)
  Tab2 = read.csv(InputTabName2, header = TRUE)
  
  #check to make sure that id and age vectors are the same #If statement to check
  if ((!identical(Tab1$InfantID,Tab2$InfantID)) || (!identical(Tab1$InfantAgeDays,Tab2$InfantAgeDays))){ 
    stop('Age or ID vectors not equal')
  }
  
  #get ID and age
  AgeVar = Tab2$InfantAgeDays
  IDVar = as.factor(Tab2$InfantID)
  
  #The first 28 columns are the ones we want to do tests on
  for (i in 1:28){ #go through relevant cols
    
    #first get colname
    ColName1 = strsplit(colnames(Tab1)[i],'_')
    ColName2 = strsplit(colnames(Tab2)[i],'_')
    
    if (strcmp(ColName1[[1]][2],'NonStSize')){ #if the second split string is NonStSize, then we combine the first two splits
      Ymeasure1 = strcat(c(ColName1[[1]][1],'_',ColName1[[1]][2]))
      Ymeasure2 = strcat(c(ColName2[[1]][1],'_',ColName2[[1]][2]))
      
      if (!identical(Ymeasure1,Ymeasure2)){ #if portions of the colnames describing the acoustic measure whose rec level correlation we are testing don't match
        stop('Y measure between tables do not match')
      }
      
      Ymeasure[i] = Ymeasure1 #get string to store as Ymeasure
      
      #get speaker string from both tables; remove TUN string from speaker type; only applicable to human labelled data table (AnTUN)
      Spkr1 = gsub('TUN','',ColName1[[1]][3],ignore.case = FALSE)
      Spkr2 = gsub('TUN','',ColName2[[1]][3],ignore.case = FALSE)
      
    } else {
      
      if (!identical(ColName1[[1]][1],ColName2[[1]][1])){ #if portions of the colnames describing the acoustic measure whose rec level correlation we are testing don't match
        stop('Y measure between tables do not match')
      }
      
      Ymeasure[i] = ColName1[[1]][1]
      
      #get speaker string from both tables
      Spkr1 = gsub('TUN','',ColName1[[1]][2],ignore.case = FALSE)
      Spkr2 = gsub('TUN','',ColName2[[1]][2],ignore.case = FALSE)
    }
    
    if (!identical(tolower(Spkr1),tolower(Spkr2))){
      print(Spkr1)
      print(Spkr2)
      stop('Spkr names between tables do not match')
    }
    
    Spkr[i] = Spkr1 #assign speaker
    
    #do lmer
    Var1 = Tab1[,i]
    Var2 = Tab2[,i]
    
    LmerModelFormula = lmer(scale(Var1) ~ (1|IDVar) + scale(Var2))# + scale(AgeVar)) 
    StatsSummary = summary(LmerModelFormula) #get summary
    
    RecLvlCorrelationBeta[i] = StatsSummary$coefficients[2,1]
    RecLvlCorrelationPvalue[i] = StatsSummary$coefficients[2,5]
    #AgeEffect[i] = StatsSummary$coefficients[3,1]
    #AgePvalue[i] = StatsSummary$coefficients[3,5]

  }
  
  #Results_df = data.frame(Ymeasure,Spkr,AgeEffect,AgePvalue,RecLvlCorrelationBeta,RecLvlCorrelationPvalue)
  Results_df = data.frame(Ymeasure,Spkr,RecLvlCorrelationBeta,RecLvlCorrelationPvalue)
  
  return(Results_df)
}