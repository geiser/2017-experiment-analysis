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
## Parametric Statistic Analysis                                           ##
#############################################################################

## remove outliers
extra_rmids <- c()
rmids <- get_ids_outliers(dat, "UserID", "DiffTheta", "Type", between = c("Type", "CLRole"))
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  rmids <- unique(c(rmids, extra_rmids))
}

cat('\n...removing ids: ', rmids,' ...\n')
rdat <- as.data.frame(dat[!dat[['UserID']] %in% rmids,])
rownames(rdat) <- rdat[['UserID']]

##
anova_result <- do_parametric_test(
  rdat, wid = 'UserID', dv = 'DiffTheta', iv = 'Type'
  , between = c('Type', 'CLRole'), observed = c('CLRole'))
if (anova_result$min.sample.size.fail) {
  cat('\n... minimun sample size is not satisfied\n')
}
if (anova_result$assumptions.fail) {
  cat('\n... assumptions fail in normality or equality\n')
  print(anova_result$test.min.size$error.warning.list)
  if (anova_result$normality.fail) cat('\n... normality fail ...\n')
  if (anova_result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
  plot_assumptions_for_parametric_test(anova_result, 'Skill')
}

## writing report
write_parametric_test_report(
  anova_result
  , ylab = "logits"
  , title = "Gain in Skills and Knowledge - Recursion"
  , filename = "report/learning-outcome/signedup-participants/ParametricAnalysis.xlsx"
  , ylim = NULL, levels = c('w/o-gamified','ont-gamified')
  , override = TRUE
)
write_plots_for_parametric_test(
  anova_result
  , ylab = "logits"
  , title = "Gain in Skills and Knowledge - Recursion"
  , path = "report/learning-outcome/signedup-participants/parametric-analysis-plots/"
  , ylim = NULL, levels = c('w/o-gamified','ont-gamified')
  , override = TRUE
)
