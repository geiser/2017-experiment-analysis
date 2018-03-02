
library(readr)
library(dplyr)

pre_dat <- as.data.frame(read_csv("data/SimplifiedPreTest.csv"))
pos_dat <- as.data.frame(read_csv("data/SimplifiedPosTest.csv"))

dat <- merge(pre_dat, pos_dat)
dat <- dplyr::mutate(
  dat
  , `PreScore` =  dat$Re1+dat$Re2+dat$Un1+dat$Un2+dat$Ap1+dat$Ap2+dat$Ap3+dat$An3+dat$Ev1+dat$Ev2
  , `PostScore` = dat$ReA+dat$ReB+dat$UnA+dat$UnB+dat$ApA+dat$ApB+dat$ApC+dat$AnC+dat$EvA+dat$EvB
)
rownames(dat) <- dat$UserID
dat <- dplyr::mutate(dat, `DiffScore` = dat$PostScore-dat$PreScore)

dat <- dat[complete.cases(
  select(dat, starts_with("Re"), starts_with("Un"), starts_with("Ap")
         , starts_with("An"), starts_with("Ev"))),]

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

set_wt_mods <- get_wilcox_mods(dat, dv = 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
write_wilcoxon_simple_analysis_report(
  set_wt_mods
  , ylab = "Difference of Score"
  , title = "Programming Skill - Cond. Structures"
  , filename = "report/learning-outcome/WilcoxAnalysis.xlsx"
  , override = TRUE
)
write_wilcoxon_plots(
  set_wt_mods
  , ylab = "Difference of Score"
  , title = "Programming Skill - Cond. Structures"
  , path = "report/learning-outcome/wilcox-analysis-plots/"
  , override = TRUE
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

rdat <- dat
extra_rmids <- c(10224,10238 ,10216 ,10222,10179)
## remove outliers
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  rmids <- extra_rmids
  rdat <- dat[!dat[['UserID']] %in% rmids,]
}

outlier_ids <- get_ids_outliers_for_anova(
  rdat, 'UserID', 'DiffScore', iv = 'Type', between = c('Type', 'CLRole'))
if (!is.null(outlier_ids) && length(outlier_ids) > 0) {
  rmids <- c(rmids, outlier_ids)
  rdat <- dat[!dat[['UserID']] %in% rmids,]
}
cat('\n...removing ids: ', rmids,' ...\n')


anova_result <- do_anova(rdat, wid = 'UserID', dv = 'DiffScore', iv = 'Type'
                         , between = c('Type', 'CLRole'), observed = c('CLRole'))
if (anova_result$min.sample.size.fail) {
  cat('\n... minimun sample size is not satisfied\n')
}
if (!anova_result$min.sample.size.fail && anova_result$assumptions.fail) {
  cat('\n... assumptions fail in normality or equality\n')
  print(anova_result$test.min.size$error.warning.list)
  if (anova_result$normality.fail) {
    cat('\n... normality fail ...\n')
    normPlot(rdat, dv = 'DiffScore')
  }
  if (anova_result$homogeneity.fail) {
    cat('\n... homogeneity fail ...\n')
    plot_anova_assumptions(anova_result, 'DiffScore')
  }
}

## writing report
write_anova_analysis_report(
  anova_result
  , ylab = "Difference of Score"
  , title = "Programming Skill - Cond. Structures"
  , filename = "report/learning-outcome/AnovaAnalysis.xlsx"
  , override = TRUE
)
write_anova_plots(
  anova_result
  , ylab = "Difference of Score"
  , title = "Programming Skill - Cond. Structures"
  , path = "report/learning-outcome/anova-analysis-plots/"
  , override = TRUE
)

#bx<-boxplot(rdat$DiffScore[rdat$Type=="non-gamified" & rdat$CLRole=="Master"])
#uid <- rdat$UserID[rdat$DiffScore %in% bx$out]
#rdat[rdat$UserID %in% uid,]
