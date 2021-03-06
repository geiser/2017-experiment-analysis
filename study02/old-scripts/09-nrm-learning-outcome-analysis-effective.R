library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)

participants <- as.data.frame(read_csv("data/EffectiveParticipants.csv"))
abilities_info <- read_excel("report/learning-outcome/MeasurementChangeModel.xlsx")

dat <- merge(participants, abilities_info[,c("UserID","pre.theta","pos.theta")])
colnames(dat) <- c(colnames(participants), c("PreTheta", "PostTheta"))
dat <- dplyr::mutate(dat, `DiffTheta` = dat$PostTheta-dat$PreTheta)
rownames(dat) <- dat$UserID


#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
result <- do_nonparametric_test(dat, wid = 'UserID', dv = "DiffTheta", iv = "Type", between = c("Type", "CLRole"))

write_plots_for_nonparametric_test(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , path = "report/learning-outcome/effective-participants/nonparametric-analysis-plots/"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)
write_nonparametric_test_report(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , filename = "report/learning-outcome/effective-participants/NonParametricAnalysis.xlsx"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################
