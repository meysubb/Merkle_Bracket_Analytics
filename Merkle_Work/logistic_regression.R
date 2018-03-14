### LOGIT Model 
model_df <- read_csv("../data/model_dat.csv")


set.seed(123)
n <- floor(0.75 * nrow(model_df))
train <- sample_frac(model_df, 0.75) 
test <- model_df[-as.numeric(rownames(train)),]

train <- train %>% mutate(win=as.factor(win.)) %>% select(-win.)
y_test <- as.factor(test$win.)
test <- test %>% select(-win.)


### Problem of Perfect Separation
model <- glm (win ~. + 0, data = train, family=binomial(link='logit'))


### Lasso Logistic Regression to avoid issues from 
### perfect linear separation
library(glmnet)
test <- model_df[-as.numeric(rownames(train)),]

mat_train <- model.matrix(win ~. + 0 , train)
mat_test <- model.matrix(win. ~. + 0 , test)
grid <- 10^seq(10,-2,length = 100)
lasso_model <- glmnet(mat_train,train$win,
                      alpha=1,lambda=grid,thresh = 1e-12,family = "binomial",
                      intercept=FALSE)

cv_model_lasso <- cv.glmnet(mat_train,train$win, alpha=1,lambda=grid,thresh = 1e-12,
                            family="binomial",type.measure = "class",
                            intercept=FALSE)

r_lambda_min <- cv_model_lasso$lambda.min

lasso_pred <- predict(lasso_model, s = r_lambda_min,newx=mat_test,type="class")

y_pred <- as.factor(lasso_pred)
lasso_conf_mat <- table(y_test,y_pred)
acc <- sum(diag(lasso_conf_mat))/sum(lasso_conf_mat)


### Final Logistic Regression, use to predict on future data. 
final_df <- model.matrix(win. ~ . + 0,model_df)
final_lasso_model <- glmnet(final_df,model_df$win.,
                           alpha=1,lambda=r_lambda_min,thresh = 1e-12,family = "binomial",
                           intercept=FALSE)
saveRDS(final_lasso_model,"../models/lasso_logistic.RDS")
saveRDS(r_lambda_min,"../models/lasso_lambda.RDS")
