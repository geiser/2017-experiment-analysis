
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)

dat <- as.data.frame(read_csv('data/IMMS.csv'))
dat <- dplyr::mutate(
  dat
  , `Attention` = (dat$Item01A+dat$Item04A+dat$Item05A+dat$Item12A+dat$Item19A+dat$Item20A)/6
  , `Satisfaction` = (dat$Item09S+dat$Item11S+dat$Item14S+dat$Item24S+dat$Item25S)/5
)
dat <- dplyr::mutate(
  dat
  ,`Level of Motivation` = (dat$Attention*6+dat$Satisfaction*5)/11
)
rownames(dat) <- dat$UserID

dvs <- c('Attention', 'Satisfaction', 'Level of Motivation')
folders <- c('attention', 'satisfaction', 'level-of-motivation')

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  path <- paste0('report/motivation/', folders[[i]], '/wilcox-analysis-plots/')
  filename <- paste0('report/motivation/', folders[[i]], '/WilcoxAnalysis.xlsx')
  
  set_wt_mods <- get_wilcox_mods(dat, dv = dv, iv = 'Type', between = c('Type', 'CLRole'))
  write_wilcoxon_simple_analysis_report(
    set_wt_mods
    , ylab = "Score"
    , title = dv
    , filename = filename
    , override = FALSE
  )
  write_wilcoxon_plots(
    set_wt_mods
    , ylab = "Score"
    , title = dv
    , path = path
    , override = FALSE
  )
}

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

rmids <- list()
rdats <- list()
extra_rmids <- list('Attention'=c(10198,10204,10209,10223,10242,10231,10189
                                  ,10220,10175,10184,10169,10190,10240,10227,10224))
## remove outliers
for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  rmids[[dv]] <- get_ids_outliers_for_anova(
    dat, 'UserID', dv, iv = 'Type', between = c('Type', 'CLRole'))
  if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
    rmids[[dv]] <- unique(c(rmids[[dv]], extra_rmids[[dv]]))
  }
  cat('\n...removing ids: ', rmids[[dv]],' from: ', dv, ' ...\n')
  rdats[[dv]] <- dat[!dat[['UserID']] %in% rmids[[dv]],]
}

for (dv in dvs) {
  anova_result <- do_anova(
    rdats[[dv]], wid = 'UserID', dv = dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  if (anova_result$min.sample.size.fail) {
    cat('\n... minimun sample size is not satisfied for the group: ', dv, '\n')
  }
  if (!anova_result$min.sample.size.fail && anova_result$assumptions.fail) {
    cat('\n... assumptions fail in normality or equality for the group: ', dv, '\n')
    print(anova_result$test.min.size$error.warning.list)
    if (anova_result$normality.fail) cat('\n... normality fail ...\n')
    if (anova_result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    plot_anova_assumptions(anova_result, dv)
  }
}

## writing report
for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  path <- paste0('report/motivation/', folders[[i]], '/anova-analysis-plots/')
  filename <- paste0('report/motivation/', folders[[i]], '/AnovaAnalysis.xlsx')
  
  anova_result <- do_anova(
    dat = rdats[[dv]], wid = 'UserID', dv = dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  
  ##
  write_anova_analysis_report(
    anova_result
    , ylab = "Score"
    , title = dv
    , filename = filename
    , override = FALSE
  )
  write_anova_plots(
    anova_result
    , ylab = "Score"
    , title = dv
    , path = path
    , override = FALSE
  )
}
