### parrallel predict

library(parallel)
library(doSNOW)
nocores <- detectCores() - 1
cl <- makeCluster(nocores)
registerDoSNOW(cl)

team_look <- read_csv("../data/TeamSpellings.csv")
team_df <- read_csv("../data/team_data_lookup.csv")


pred_ncaa_matchup <- function(model,team1,team2,its=1000){
  t1_id <- team_look$TeamID[which(team_look$TeamNameSpelling == tolower(team1))]
  t2_id <- team_look$TeamID[which(team_look$TeamNameSpelling == tolower(team2))]
  
  ### Progress Bar
  iterations <- its
  pb <- txtProgressBar(max = iterations, style = 3)
  progress <- function(n) setTxtProgressBar(pb, n)
  opts <- list(progress = progress)
  
 
  pred_vals <- foreach(i=1:its,.combine=c, .packages = c("dplyr","stats","randomForest","xgboost"),
                       .export = c("team_look","team_df","t1_id","t2_id"),
                       .options.snow = opts) %dopar% {
    team_t1 <- team_df %>% filter(TeamID == t1_id) %>% select(-TeamID,-team,-win.) %>% sample_frac(0.33) %>% 
      summarize_all(funs(mean))
    team_t2 <- team_df %>% filter(TeamID == t2_id) %>% select(-TeamID,-team,-win.) %>% sample_frac(0.33) %>% 
      summarize_all(funs(mean))
    colnames(team_t2) <- paste0("opp.",colnames(team_t2))
    
    final_df <- cbind(team_t1,team_t2)
    if(class(model)=="xgb.Booster"){
      final_mat <- as.matrix(final_df)
      pred_val <- predict(model,newdata=final_mat)
    }
    else{
      pred_val <- predict(model,newdata=final_df)
      pred_val <- as.numeric(as.character(pred_val))
    }
  }
  if(class(model)=="xgb.Booster"){
    pred_vals <- round(pred_vals)
  }
  conf <- table(pred_vals)
  df <- as.data.frame(conf)
  df$team2 <- its - df$Freq
  colnames(df) <- c("result",team1,team2)
  if(length(df)==2){
    df$result <- c("Win","Loss")
    df[,2:3] <- df[,2:3]/its
  }else{
    df$result <- c("Win")
    df[2,] <- c("Loss",its-df[1,2],its-df[1,3])
  }
  return(df) 
}



