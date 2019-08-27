
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(Hmisc)

datIMMS <- read_csv("data/IMMS.csv")
participants <- read_csv('data/EffectiveParticipants.csv')

dat <- merge(participants, datIMMS)
dat <- dplyr::mutate(
  dat
  , `Attention` = (dat$Item12A+dat$Item20A+dat$Item01A+dat$Item04A)/4
  , `Satisfaction` = (dat$Item24S+dat$Item14S+dat$Item02S+dat$Item26S+8-dat$Item15S)/5
)
dat <- dplyr::mutate(
  dat
  , `Level of Motivation` = ((4*dat$Attention)+(5*dat$Satisfaction))/9
)
rownames(dat) <- dat$UserID

info <- list(
  "Attention" = list(
    path = "report/motivation/attention/"
    , dv = "Attention", extra_rmids = c(10209)
  )
  , "Satisfaction" = list(
    path = "report/motivation/satisfaction/"
    , dv = "Satisfaction", extra_rmids = c()
  )
  , "Level of Motivation" = list(
    path = "report/motivation/level-of-motivation/"
    , dv = "Level of Motivation", extra_rmids = c(10191,10230, 10209)
  )
)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
nonparametric_results <- lapply(info, FUN = function(x) {
  cat("\n .... processing: ", x$dv, " ....\n")
  path <- paste0(x$path, 'score-nonparametric-analysis-plots/')
  filename <- paste0(x$path, 'ScoreNonParametricAnalysis.xlsx')
  result <- do_nonparametric_test(dat, dv = x$dv, iv = 'Type', between = c('Type', 'CLRole'))
  
  write_plots_for_nonparametric_test(
    result, ylab = "Score", title = paste(x$dv, "Score"), path = path
    , override = T, ylim = c(1,7), levels = c('non-gamified','ont-gamified')
  )
  write_nonparametric_test_report(
    result, ylab = "Score", title = paste(x$dv, "Score"), filename = filename
    , override = F, ylim = c(1,7), levels = c('non-gamified','ont-gamified')
  )
  return(result)
})

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

# remove outliers
dat_map <- lapply(info, FUN = function(x) {
  rmids <- get_ids_outliers(
    dat, 'UserID', x$dv, iv = 'Type', between = c('Type', 'CLRole'))
  if (!is.null(x$extra_rmids) && length(x$extra_rmids) > 0) {
    rmids <- unique(c(rmids, x$extra_rmids))
  }
  cat('\n...removing ids: ', rmids,' from: ', x$dv, ' ...\n')
  
  return(dat[!dat[['UserID']] %in% rmids,])
})

# tdat <- dat_map[[x$dv]]
# tdat <- tdat[tdat$Type == 'ont-gamified' & tdat$CLRole=='Apprentice',]
# tdat$UserID[tdat[[x$dv]] %in% c(boxplot(tdat[[x$dv]])$out)]

# validate assumptions
lapply(info, FUN = function(x) {
  
  result <- do_parametric_test(
    dat = dat_map[[x$dv]], wid = 'UserID', dv = x$dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  
  if (result$min.sample.size.fail) {
    cat('\n... minimun sample size is not satisfied for the group: ', x$dv, '\n')
  }
  if (result$assumptions.fail) {
    cat('\n... assumptions fail in normality or equality for the group: ', x$dv, '\n')
    print(result$test.min.size$error.warning.list)
    if (result$normality.fail) cat('\n... normality fail ...\n')
    if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    plot_assumptions_for_parametric_test(result, x$dv)
  }
})

# writing plots and reports
parametric_results <- lapply(info, FUN = function(x) {
  cat("\n .... processing: ", x$dv, " ....\n")
  path <- paste0(x$path, 'score-parametric-analysis-plots/')
  filename <- paste0(x$path, 'ScoreParametricAnalysis.xlsx')
  
  result <- do_parametric_test(
    dat = dat_map[[x$dv]], wid = 'UserID', dv = x$dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  
  write_plots_for_parametric_test(
    result, ylab = "Score", title = paste(x$dv, "Score"), path = path
    , override = T, ylim = c(1,7), levels = c('non-gamified','ont-gamified')
  )
  write_parametric_test_report(
    result, ylab = "Score", title = paste(x$dv, "Score"), filename = filename
    , override = F, ylim = c(1,7), levels = c('non-gamified','ont-gamified')
  )
  return(result)
})

## translate to latex 
write_param_and_nonparam_statistics_analysis_in_latex(
  parametric_results, nonparametric_results, names(info)
  , filename = "report/latex/score-LM-statistical-analysis.tex"
  , in_title = " for the scores of Level of Motivation obtained in the study 02")


