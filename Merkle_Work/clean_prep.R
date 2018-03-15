### Clean and Prepare Data for modelling
library(tidyverse)

t_stats <- read_csv("../data/adv_team_2018.csv")
t_spell <- read_csv("../data/TeamSpellings.csv")
conf_dat <- read_csv("../data/conf_team.csv") %>% mutate(
  team_name = trimws(tolower(team_name))
) %>% inner_join(.,t_spell,by=c("team_name"="TeamNameSpelling"))

colnames(t_stats) <- tolower(colnames(t_stats))

t <- t_stats %>% inner_join(.,t_spell,by=c("team"="TeamNameSpelling")) %>% 
  inner_join(.,t_spell,by=c("opp.team"="TeamNameSpelling")) %>% inner_join(.,conf_dat,by=c("TeamID.x"="TeamID")) %>% 
                                                                             inner_join(.,conf_dat,by=c("TeamID.y"="TeamID")) %>% 
  select(-c(TeamID.x,TeamID.y,team_name.x,team_name.y)) %>% rename(team_conf=Conf.x,opp.team_conf=Conf.y)

p_6 <- c("ACC","Big 12","Big Ten","Pac-12","SEC","Big East")
t_dummy <- t %>% 
  mutate(team_conf = as.factor(ifelse(team_conf %in% p_6,1,0)),
         opp.team_conf = as.factor(ifelse(opp.team_conf %in% p_6,1,0)))

model_df <- t_dummy %>% select(ast_to,drb,efg,ft_rate,fouls_poss,orb_pct,tov_pct,
                               opp.ast_to,opp.drb,opp.efg,opp.ft_rate,blk,opp.blk,
                               opp.fouls_poss,opp.tov_pct,opp.orb_pct,win.,team_conf,opp.team_conf) %>% 
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


team_df <- t_dummy %>%  mutate(
  def.efg=opp.efg,
  def.ast_to=opp.ast_to,
  def.ft_rate=opp.ft_rate, 
  def.fouls_poss=opp.fouls_poss,
  def.orb_pct = opp.orb_pct,
  def.tov_pct = opp.tov_pct
) %>% select(team,
             ast_to,drb,efg,blk,ft_rate,fouls_poss,orb_pct,tov_pct,
             def.ast_to,def.efg,def.ft_rate,def.fouls_poss,def.orb_pct,def.tov_pct,
             win.,team_conf)

team_df <- team_df %>% inner_join(.,t_spell,
                                  by=c("team"="TeamNameSpelling")) %>% 
  mutate_if(is.numeric, funs(replace(., is.na(.), 0))) %>% 
  mutate(team_conf = as.factor(team_conf))

write_csv(model_df,"../data/model_dat.csv")

write_csv(team_df,"../data/team_data_lookup.csv")
