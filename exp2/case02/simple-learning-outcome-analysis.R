
library(readr)
library(dplyr)

pre_dat <- as.data.frame(read_csv("data/SimplePreTest.csv"))
pos_dat <- as.data.frame(read_csv("data/SimplePosTest.csv"))

dat <- merge(pre_dat, pos_dat)
dat <- dplyr::mutate(
  dat
  , `PreScore`  = dat$Re1+dat$Un3+dat$Ap2a+dat$Ap2b+dat$An3a+dat$An3b+dat$Ev2
  , `PostScore` = dat$ReA+dat$UnC+dat$ApB1+dat$ApB2+dat$AnC1+dat$AnC2+dat$EvB
)
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffScore` = dat$PostScore-dat$PreScore)

## performn simple parametric analysis
set_wt_mods <- get_wilcox_mods(dat, dv = 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
write_wilcoxon_simple_analysis_report(
  set_wt_mods
  , ylab = "Difference Score"
  , title = "Programming Skill - Loops"
  , filename = "report/learning-outcome/WilcoxAnalysis.xlsx"
  , override = TRUE
)

write_wilcoxon_plots(
  set_wt_mods
  , ylab = "Difference Score"
  , title = "Programming Skill - Loops"
  , path = "report/learning-outcome/plots/"
  , override = TRUE
)

## perform simple ANOVA analysis

