library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)

participants <- as.data.frame(read_csv("data/SignedUpParticipants.csv"))
abilities_info <- read_excel("report/learning-outcome/MeasurementChangeModel.xlsx")

dat <- merge(participants, abilities_info[,c("UserID","pre.theta","pos.theta")])
colnames(dat) <- c(colnames(participants), c("PreTheta", "PostTheta"))
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffTheta` = dat$PostTheta-dat$PreTheta)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
result <- do_nonparametric_test(dat, wid = 'UserID', dv = "DiffTheta", iv = "Type", between = c("Type", "CLRole"))

write_plots_for_nonparametric_test(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Cond. Structures"
  , path = "report/learning-outcome/signedup-participants/nonparametric-analysis-plots/"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)
write_nonparametric_test_report(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Cond. Structures"
  , filename = "report/learning-outcome/signedup-participants/NonParametricAnalysis.xlsx"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)

