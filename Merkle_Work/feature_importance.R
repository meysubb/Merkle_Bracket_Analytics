### Decision Trees for Feature Importance 
adv_metrics <- read_csv("../data/adv_team_2018.csv") %>% select(-Team,-Opp.Team)

#### Sample Data
set.seed(123)
n <- floor(0.75 * nrow(adv_metrics))
train <- sample_frac(adv_metrics, 0.75) 
test <- adv_metrics[-as.numeric(rownames(train)),]

train_y <- as.factor(train$Win.)
test_y <- as.factor(test$Win.)

train <- train %>% select(-Win.)
test <- test %>% select(-Win.)
### Use Extra-Trees classifier 
library(extraTrees)

et_mod <- extraTrees(train,train_y,
                     ntree=1000,
                     nodesize = 5,
                     na.action='zero')
pred_y <- predict(et_mod,newdata=test)

conf_mat <- table(test_y,pred_y)

acc <- sum(diag(conf_mat))/sum(conf_mat)
