### Clean and Prepare Data for modelling
library(tidyverse)

t_stats <- read_csv("../data/adv_team_2018.csv")
t_spell <- read_csv("../data/TeamSpellings.csv")

### Top 16 Features as selected from Extra-Trees Classifier
colnames(t_stats) <- tolower(colnames(t_stats))

model_df <- t_stats %>% select(ast_to,drb,efg,ft_rate,fouls_poss,orb_pct,tov_pct,
                               opp.ast_to,opp.drb,opp.efg,opp.ft_rate,blk,opp.blk,
                               opp.fouls_poss,opp.tov_pct,opp.orb_pct,win.) %>% 
  mutate_if(is.numeric, funs(replace(., is.na(.), 0))) %>% 
  mutate(
    def.efg=opp.efg,
    def.ast_to=opp.ast_to,
    def.ft_rate=opp.ft_rate, 
    def.fouls_poss=opp.fouls_poss,
    def.orb_pct = opp.orb_pct,
    def.tov_pct = opp.tov_pct,
    opp.def.efg = efg,
    opp.def.ast_to = ast_to,
    opp.def.ft_rate = ft_rate,
    opp.def.fouls_poss = fouls_poss,
    opp.def.orb_pct = orb_pct,
    opp.def.tov_pct = tov_pct
  )


team_df <- t_stats %>%  mutate(
  def.efg=opp.efg,
  def.ast_to=opp.ast_to,
  def.ft_rate=opp.ft_rate, 
  def.fouls_poss=opp.fouls_poss,
  def.orb_pct = opp.orb_pct,
  def.tov_pct = opp.tov_pct
) %>% select(team,
             ast_to,drb,efg,blk,ft_rate,fouls_poss,orb_pct,tov_pct,
             def.ast_to,def.efg,def.ft_rate,def.fouls_poss,def.orb_pct,def.tov_pct,
             win.)

team_df <- team_df %>% inner_join(.,t_spell,
                                  by=c("team"="TeamNameSpelling")) %>% 
  mutate_if(is.numeric, funs(replace(., is.na(.), 0)))

write_csv(model_df,"../data/model_dat.csv")

write_csv(team_df,"../data/team_data_lookup.csv")
