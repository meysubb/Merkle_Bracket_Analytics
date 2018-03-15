source("parallel_predict.R")

rf_bball <- readRDS("../models/rf_model.RDS")

df <- pred_ncaa_matchup(rf_bball,"Virginia","UMBC",its=1000)
### Picked UMBC

df2 <- pred_ncaa_matchup(rf_bball,"Creighton","Kansas State",its=10)

df2 <- pred_ncaa_matchup(rf_bball,"SFA","Texas Tech",its=10)

df5 <- pred_ncaa_matchup(rf_bball,"Villanova","Radford",its=1000)
### Picked Radford

df6 <- pred_ncaa_matchup(rf_bball,"Kansas","Penn",its=1000)
### Picked Kansas

df7 <- pred_ncaa_matchup(rf_bball,"Duke","Iona",its=1000)
### Picked Iona


df8 <- pred_ncaa_matchup(rf_bball,"Purdue","CS Fullerton",tis=1000)
### Picked CS Fullerton

df3 <- pred_ncaa_matchup(rf_bball,"Texas A&M","Providence",its=1000)
### Picked 

df4 <- pred_ncaa_matchup(rf_bball,"Kentucky","Davidson",its=1000)


### Seems to only pick Team 1 always
### Revisit the multi-colinearity issue
xg_bball <- readRDS("../models/xg_model.RDS")
df <- pred_ncaa_matchup(xg_bball,"UMBC","Virginia",its=500)
df2 <- pred_ncaa_matchup(xg_bball,"SFA","Texas Tech",its=500)
df4 <- pred_ncaa_matchup(xg_bball,"Davidson","Kentucky",its=500)
df5 <- pred_ncaa_matchup(xg_bball,"Villanova","Radford",its=1000)
