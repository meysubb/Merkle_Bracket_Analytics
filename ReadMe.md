Note to those who want to use this, feel free. 

We ran into something weird. The Monte Carlo Simulation picked higher seeds when only 10 iterations were run, but when you ran more than that they overwhelmingly lost (regardless of who they played)

## Overview

We predicted the outcomes of the 2018 March Madness Bracket by combining a random forest trained on head to head team data and a monte carlo simulation using boostraped samples of a team's games throughout the season.

## Advanced Statistics Creation

As can be seen near the end of this chunk, the statistics we used were effective field goal %, points per possesion, number of possesions, offensive rebound %, turnover %, free throw rate, three point rate, and assist to turnover ratio. These were made for both home and away teams. Later in the data cleaning step, we use one team's statistics to make the defensive statistics for the other team.

```
source("feature_engr_metric.R")
```

## Data Cleaning

The data cleaning step involves joining the data with a dataframe of common spellings of teams, converting opponent field goal percentage into a team's defensive field goal percentage and other similar metrics. As well as putting it into a form that can be used with the monte carlo method later on and averaging the statistics for each team for the random forest model

```
source(clean_prep_2.R)
```

## Random Forest

We took the csv created in the data cleaning step, made some of the variables factors, and then ran the random forest classifier to predict wins given two teams season average statistics. A grid search method was used to determine the best number of trees and variables to use and was implemented seperately in h2o. 

`
model_df <- read_csv("../data/game_avg.csv")
`

`model_df <- model_df %>% mutate(`

`Win. = as.factor(Win.),`
  
`team_conf = as.factor(team_conf),`
  
`opp.team_conf = as.factor(opp.team_conf)`
`)`

`model_df <- model_df %>% select(`

`-c(X1,Team,Opp.Team,TeamID,OppTeamID))`

`### Best model mtries = 18 ntrees  1000`

`library(randomForest)`
`rf_bball <- randomForest(`
`Win. ~.,data=model_df,mtry=18,ntree=1000)` 

`saveRDS(rf_bball,"../models/rf_model.RDS")`


## Monte Carlo Prediction

In order to offset the fact that averages get rid of a lot of the variability that you would expect from a team's performance from night to night, and gets rid of any information about the distribution of a team's performance, we ran a simulation for each match up where we would randomly sample without replacement one third of both teams' games, take their average, and then use our random forest model to predict who the winner is. We did this 200 times for each matchup. The team that won the majority of the time was predicted to be the winner. The code for this is a little long and hard to simplify, but can be found in parallel_predict.R

For any overrides that we personally had, we ran the simulation again for 20 times. 

```
source("parallel_predict.R")
```

## Bracket Predictions

We created a way to simulate the bracket by predicting each matchup in the round of 64, following the winners to the round of 32 and predicting their matchups and so on until we had oursevles a winner.

```
source("2018_bracket.R")
```

## Issues and Areas for Improvement

The biggest issue with this model is that it does not take into account the strength of schedule of a team. We had to override this model's common prediction that a 16-seed would upset a 1-seed. Since this has never happened before in the history of college basketball, we figured we would be pretty confident that would not happen. We believe the reason for this type of prediction is that many of these 16-seeded teams are coming from smaller conferences where they are "top dog" and beating up on weak teams. This would make their statistics look better in comparison to other teams. 