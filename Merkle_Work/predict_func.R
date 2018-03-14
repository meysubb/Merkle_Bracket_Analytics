### Predict Function

team_look <- read_csv("../data/TeamSpellings.csv")
team_df <- read_csv("../data/team_data_lookup.csv")

pred_ncaa_matchup <- function(model,team1,team2,its=1000,lambda=NULL){
  ### For our logistic regression it was 0.1
  t1_id <- team_look$TeamID[which(team_look$TeamNameSpelling == tolower(team1))]
  t2_id <- team_look$TeamID[which(team_look$TeamNameSpelling == tolower(team2))]
  
  res_df <- data.frame(win = c(0,0), loss=c(0,0),row.names=c(team1,team2))
  
  for(i in 1:its){
    team_t1 <- team_df %>% filter(TeamID == t1_id) %>% select(-TeamID,-team,-win.) %>% sample_frac(0.25) %>% 
      summarize_all(funs(mean))
    team_t2 <- team_df %>% filter(TeamID == t2_id) %>% select(-TeamID,-team,-win.) %>% sample_frac(0.25) %>% 
      summarize_all(funs(mean))
    colnames(team_t2) <- paste0("opp.",colnames(team_t2))
    
    final_df <- cbind(team_t1,team_t2)
    if(is.null(lambda)){
      pred_val <- predict(model,newdata=final_df)
      pred_val <- as.numeric(as.character(pred_val))
    }
    else{
      final_mat <- model.matrix(~ . + 0,final_df)
      pred_val <- predict(model,s = lambda,newx=final_mat,type="class")
      pred_val <- as.numeric(pred_val)
    }
    if(pred_val==1){
      res_df[team1,"win"] <-  res_df[team1,"win"] + 1
      res_df[team2,"loss"] <- res_df[team2,"loss"] + 1
    }else{
      res_df[team1,"loss"] <- res_df[team1,"loss"] + 1
      res_df[team2,"win"] <-  res_df[team2,"win"] + 1
    }
  }
  res_df <- res_df
  return(res_df)
}