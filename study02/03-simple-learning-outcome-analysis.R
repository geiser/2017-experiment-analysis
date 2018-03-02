library(readr)
library(dplyr)

pre_dat <- as.data.frame(read_csv("data/SimplifiedPreTest.csv"))
pos_dat <- as.data.frame(read_csv("data/SimplifiedPosTest.csv"))

dat <- merge(pre_dat, pos_dat)
dat <- dplyr::mutate(
  dat
  , `PreScore`  = dat$Re1+dat$Un3+dat$Ap2a+dat$Ap2b+dat$An3a+dat$An3b+dat$Ev2
  , `PostScore` = dat$ReA+dat$UnC+dat$ApB1+dat$ApB2+dat$AnC1+dat$AnC2+dat$EvB
)
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffScore` = dat$PostScore-dat$PreScore)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

set_wt_mods <- get_wilcox_mods(dat, dv = 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
write_wilcoxon_simple_analysis_report(
  set_wt_mods
  , ylab = "Difference of Score"
  , title = "Programming Skill - Loops"
  , filename = "report/learning-outcome/WilcoxAnalysis.xlsx"
  , override = FALSE
)
write_wilcoxon_plots(
  set_wt_mods
  , ylab = "Difference of Score"
  , title = "Programming Skill - Loops"
  , path = "report/learning-outcome/wilcox-analysis-plots/"
  , override = TRUE
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

rdat <- dat
extra_rmids <- c()
## remove outliers
rmids <- get_ids_outliers_for_anova(
  dat, 'UserID', 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  rmids <- unique(c(rmids, extra_rmids))
}
cat('\n...removing ids: ', rmids,' ...\n')
rdat <- dat[!dat[['UserID']] %in% rmids,]

anova_result <- do_anova(rdat, wid = 'UserID', dv = 'DiffScore', iv = 'Type'
                         , between = c('Type', 'CLRole'), observed = c('CLRole'))
if (anova_result$min.sample.size.fail) {
  cat('\n... minimun sample size is not satisfied\n')
}
if (!anova_result$min.sample.size.fail && anova_result$assumptions.fail) {
  cat('\n... assumptions fail in normality or equality\n')
  print(anova_result$test.min.size$error.warning.list)
  if (anova_result$normality.fail) cat('\n... normality fail ...\n')
  if (anova_result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
  plot_anova_assumptions(anova_result, 'DiffScore')
}

## writing report
write_anova_analysis_report(
  anova_result
  , ylab = "Difference of Score"
  , title = "Programming Skill - Loops"
  , filename = "report/learning-outcome/AnovaAnalysis.xlsx"
  , override = FALSE
)
write_anova_plots(
  anova_result
  , ylab = "Difference of Score"
  , title = "Programming Skill - Loops"
  , path = "report/learning-outcome/anova-analysis-plots/"
  , override = TRUE
)

