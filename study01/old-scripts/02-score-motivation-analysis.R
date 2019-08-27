
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(Hmisc)

datIMI <- read_csv('data/IMI.csv')
participants <- read_csv('data/EffectiveParticipants.csv')

dat <- merge(participants, datIMI)
dat <- dplyr::mutate(
  dat
  , `Interest/Enjoyment` = (dat$Item12IE+dat$Item24IE+dat$Item09IE+dat$Item22IE
                            +dat$Item21IE+dat$Item01IE)/6
  , `Perceived Choice` = (40-(dat$Item17PC+dat$Item15PC+dat$Item08PC
                              +dat$Item02PC+dat$Item06PC))/5
  , `Pressure/Tension` = (dat$Item16PT+dat$Item14PT+dat$Item18PT+8-dat$Item11PT)/4
)

dat <- dplyr::mutate(
  dat
  , `Intrinsic Motivation` = ((6*dat$`Interest/Enjoyment`)+(5*dat$`Perceived Choice`)
                              +(32-(4*dat$`Pressure/Tension`)))/15
)
rownames(dat) <- dat$UserID

info_im <- list(
  "Interest/Enjoyment" = list(
    path = "report/motivation/interest-enjoyment/"
    , dv = "Interest/Enjoyment", extra_rmids =c()
  )
  , "Perceived Choice" = list(
    path = "report/motivation/perceived-choice/"
    , dv = "Perceived Choice", extra_rmids = c()
  )
  , "Pressure/Tension" = list(
    path = "report/motivation/pressure-tension/"
    , dv = "Pressure/Tension", extra_rmids = c(10170,10175,10192,10195,10196,10197,10198,10200,10204
                                               ,10210,10238
                                               ,10213,10218,10209,10217
                                               ,10219,10220,10206,10187
                                               ,10230)
  )
  , "Intrinsic Motivation" = list(
    path = "report/motivation/intrinsic-motivation/"
    , dv = "Intrinsic Motivation", extra_rmids = c(10240)
  )
)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
nonparametric_results <- lapply(info_im, FUN = function(x) {
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
dat_map <- lapply(info_im, FUN = function(x) {
  rmids <- get_ids_outliers(
    dat, 'UserID', x$dv, iv = 'Type', between = c('Type', 'CLRole'))
  if (!is.null(x$extra_rmids) && length(x$extra_rmids) > 0) {
    rmids <- unique(c(rmids, x$extra_rmids))
  }
  cat('\n...removing ids: ', rmids,' from: ', x$dv, ' ...\n')
  
  return(dat[!dat[['UserID']] %in% rmids,])
})

# tdat <- dat_map[[x$dv]]
# tdat <- tdat[tdat$Type == 'ont-gamified',]
# tdat$UserID[tdat[[x$dv]] %in% c(boxplot(tdat[[x$dv]])$out)]

# validate assumptions
lapply(info_im, FUN = function(x) {
  
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
    #normPlot(result$data, x$dv)
  }
})

# writing plots and reports
parametric_results <- lapply(info_im, FUN = function(x) {
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
  parametric_results, nonparametric_results, names(info_im)
  , filename = "report/latex/score-IM-statistical-analysis.tex"
  , in_title = " for the scores of Intrinsic Motivation obtained in the study 01"
)

