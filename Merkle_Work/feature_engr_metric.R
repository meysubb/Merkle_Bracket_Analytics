library(tidyverse)
options(stringsAsFactors = FALSE)
team_stats <- read_csv("../data/2018TeamStats Final.csv") %>% select(-X1)

colnames(team_stats) <- make.names(colnames(team_stats))

## Check Class balance, should be perfect 50 vs 50.
table(team_stats$Win.)

### Add Opponnent name just in case
team_stats$Opp.Team <- "empty"
for(i in 1:nrow(team_stats)){
  names <- team_stats$Team[which(team_stats$gameid == team_stats$gameid[i])]
  rev_names <- rev(names)
  team_stats$Opp.Team[which(team_stats$gameid == team_stats$gameid[i])] <- rev_names
}

### Advanced stats to study
### Possessions, EFG, PPP  - Pace of Play
### ORB, TOV, FTR, 3PTR - Four Factors
### What else?
team_stats_adv <- team_stats  %>% mutate(
  possessions = FGA + 0.475 * FTA - ORB + TOV,
  Opp.possessions = Opp.FGA + 0.475 * Opp.FTA - Opp.ORB + Opp.TOV,
  efg = (FG + (0.5 * X3P)) / FGA,
  Opp.efg = (Opp.FG + (0.5 * Opp.3P)) / Opp.FGA,
  ppp = PTS/(FGA + 0.475 * FTA) * (FGA + 0.475 * FTA)/possessions,
  Opp.ppp = Opp.PTS/(Opp.FGA+ 0.475 * Opp.FTA) * (Opp.FGA + 0.475 * Opp.FTA)/Opp.possessions,
  ORB_pct = ORB / (ORB + Opp.DRB),
  OPP.ORB_pct = Opp.ORB / (Opp.ORB + DRB),
  TOV_pct = TOV / (FGA + 0.44 * FTA + TOV),
  OPP.TOV_pct = Opp.TOV / (Opp.FGA + 0.44 * Opp.FTA + Opp.TOV),
  FT_rate = FT/FGA,
  OPP.FT_rate = Opp.FT/Opp.FGA,
  X3PAR = X3PA/FGA,
  Opp.3PAR = Opp.3PA/Opp.FGA,
  ast_to = AST/TOV,
  Opp.ast_to = Opp.AST/Opp.TOV,
  fouls_poss = PF/possessions,
  Opp.fouls_poss = Opp.PF/Opp.possessions
)



write_csv(team_stats_adv,"../data/adv_team_2018.csv")


