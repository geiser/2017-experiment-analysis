
library(readr)
library(dplyr)

pre_dat <- as.data.frame(read_csv("data/SimplePreTest.csv"))
pos_dat <- as.data.frame(read_csv("data/SimplePosTest.csv"))

dat <- merge(pre_dat, pos_dat)
dat <- dplyr::mutate(
  dat
  , `PreScore` =  dat$Re1+dat$Re2+dat$Un1+dat$Un2+dat$Ap1+dat$Ap2+dat$Ap3+dat$An3+dat$Ev1+dat$Ev2
  , `PostScore` = dat$ReA+dat$ReB+dat$UnA+dat$UnB+dat$ApA+dat$ApB+dat$ApC+dat$AnC+dat$EvA+dat$EvB
)
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffScore` = dat$PostScore-dat$PreScore)

## performn simple parametric analysis
set_wt_mods <- get_wilcox_mods(dat, dv = 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
write_wilcoxon_simple_analysis_report(
  set_wt_mods
  , ylab = "Difference Score"
  , title = "Programming Skill - Conditional"
  , filename = "report/learning-outcome/WilcoxAnalysis.xlsx"
  , override = TRUE
)

write_wilcoxon_plots(
  set_wt_mods
  , ylab = "Difference Score"
  , title = "Programming Skill - Conditional"
  , path = "report/learning-outcome/plots/"
  , override = TRUE
)

## perform simple ANOVA analysis

