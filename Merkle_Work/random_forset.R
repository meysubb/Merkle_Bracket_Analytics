### Random ForestT
model_df <- read_csv("../data/game_avg.csv")

model_df <- model_df %>% mutate(
  Win. = as.factor(Win.),
  team_conf = as.factor(team_conf),
  opp.team_conf = as.factor(opp.team_conf)
)

model_df <- model_df %>% select(-c(X1,Team,Opp.Team,TeamID,OppTeamID))

set.seed(123)
library(h2o)
h2o.init(nthreads = 3, max_mem_size = "6G") 

model_df_h20 <- as.h2o(model_df)
splits <- h2o.splitFrame(data = model_df_h20, ratios = 0.75, seed = 123)  #setting a seed will guarantee reproducibility
train <- splits[[1]]
test <- splits[[2]]

y <- "Win."
x <- setdiff(names(model_df_h20), y) 

metrics_df <- expand.grid(mtries = seq(6,28,by=3),ntrees = c(300,500,750,1000,1200))
metrics_df$out_rf <- 0
metrics_df$in_rf <- 0

for(i in 1:nrow(metrics_df)){
  num_trees <- metrics_df$ntrees[i]
  var <- metrics_df$mtries[i]
  ptr_statement <- paste0("Working on ",i/nrow(metrics_df)*100, "%", sep=" ")
  print(ptr_statement)
  rf_fit1 <- h2o.randomForest(x = x,
                              y = y,
                              training_frame = train,
                              model_id = "rf_fit1",
                              seed = 1,
                              ntrees = num_trees,
                              mtries = var)
  s <- h2o.confusionMatrix(rf_fit1)
  diag <- s[2,2] + s[1,1]
  sum <- sum(s[3,1:2])
  acc <- diag/sum
  
  in_sample <- acc
  rf_perf1 <- h2o.performance(model = rf_fit1,
                              newdata = test)
  s_out <- h2o.confusionMatrix(rf_perf1)
  diag <- s_out[2,2] + s_out[1,1]
  sum <- sum(s_out[3,1:2])
  out_acc <- diag/sum
  
  out_sample <- out_acc
  
  metrics_df$in_rf[i] <- in_sample
  metrics_df$out_rf[i] <- out_sample
  
}

h2o.shutdown()

saveRDS(metrics_df,"../data/rf_metrics.RDS")

### Best model mtries = 18 ntrees  1000

library(randomForest)
rf_bball <- randomForest(Win. ~.,data=model_df,mtry=18,ntree=1000) 

saveRDS(rf_bball,"../models/rf_model.RDS")
