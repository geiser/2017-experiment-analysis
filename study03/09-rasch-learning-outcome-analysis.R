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
## Parametric Statistic Analysis                                           ##
#############################################################################

## remove outliers
extra_rmids <- c(10203)
rmids <- get_ids_outliers_for_anova(dat, "UserID", "DiffTheta", "Type", between = c("Type", "CLRole"))
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  rmids <- unique(c(rmids, extra_rmids))
}

cat('\n...removing ids: ', rmids,' ...\n')
rdat <- as.data.frame(dat[!dat[['UserID']] %in% rmids,])
rownames(rdat) <- rdat[['UserID']]

##
anova_result <- do_anova(
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
  plot_anova_assumptions(anova_result, 'Skill')
}

## writing report
write_anova_analysis_report(
  anova_result
  , ylab = "logits"
  , title = "Difference of Programming Skill - Recursion"
  , filename = "report/learning-outcome/MeasurementAnovaAnalysis.xlsx"
  , override = TRUE
)
write_anova_plots(
  anova_result
  , ylab = "logits"
  , title = "Difference of Programming Skill - Recursion"
  , path = "report/learning-outcome/measurement-anova-analysis-plots/"
  , override = TRUE
)
