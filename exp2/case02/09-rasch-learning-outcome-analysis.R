library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)

participants <- as.data.frame(read_csv("data/Participant.csv"))
abilities_info <- read_excel("report/learning-outcome/MeasurementChangeModel.xlsx")

dat <- merge(participants, abilities_info[,c("UserID","pre.theta","pos.theta")])
colnames(dat) <- c(colnames(participants), c("PreTheta", "PostTheta"))
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffTheta` = dat$PostTheta-dat$PreTheta)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

set_wt_mods <- get_wilcox_mods(dat, dv = 'DiffTheta', iv = 'Type', between = c('Type', 'CLRole'))
write_wilcoxon_simple_analysis_report(
  set_wt_mods
  , ylab = "logits"
  , title = "Difference of Programming Skill - Loops"
  , filename = "report/learning-outcome/MeasurementWilcoxAnalysis.xlsx"
  , override = TRUE
  , data = dat
)
write_wilcoxon_plots(
  set_wt_mods
  , ylab = "logits"
  , title = "Difference of Programming Skill - Loops"
  , path = "report/learning-outcome/measurement-wilcox-analysis-plots/"
  , override = TRUE
)
