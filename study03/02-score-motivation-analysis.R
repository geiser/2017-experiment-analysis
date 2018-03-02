
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(Hmisc)

datIMI <- read_csv('data/IMI.csv')
datIMMS <- read_csv("data/IMMS.csv")
participants <- read_csv('data/EffectiveParticipants.csv')

dat <- merge(participants, merge(datIMI, datIMMS))
dat <- dplyr::mutate(
  dat
  , `Interest/Enjoyment` = (dat$Item09IE+dat$Item21IE+dat$Item08IE+dat$Item11IE
                            +dat$Item24IE+dat$Item12IE)/6
  , `Perceived Choice` = (40-(dat$Item05PC+dat$Item18PC+dat$Item20PC
                              +dat$Item13PC+dat$Item03PC))/5
  , `Pressure/Tension` = (dat$Item06PT+dat$Item02PT+dat$Item04PT)/3
  , `Effort/Importance` = (dat$Item22EI+16-(dat$Item01EI+dat$Item19EI))/3
  , `Attention` = (dat$Item20A+dat$Item25A+dat$Item18A+dat$Item07A+dat$Item04A)/5
  , `Relevance` = (dat$Item12R+16-(dat$Item09R+dat$Item06R))/3
  , `Satisfaction` = (dat$Item01S+dat$Item02S)/2
)
dat <- dplyr::mutate(
  dat
  , `Intrinsic Motivation` = ((6*dat$`Interest/Enjoyment`)+(5*dat$`Perceived Choice`)
                              +(3*dat$`Effort/Importance`)+(24-(3*dat$`Pressure/Tension`)))/17
  , `Level of Motivation` = ((5*dat$Attention)+(2*dat$Satisfaction)+(3*dat$Relevance))/10
)
rownames(dat) <- dat$UserID

info_im <- list(
  "Interest/Enjoyment" = list(
    path = "report/motivation/interest-enjoyment/"
    , dv = "Interest/Enjoyment", extra_rmids =c(10191)
  )
  , "Perceived Choice" = list(
    path = "report/motivation/perceived-choice/"
    , dv = "Perceived Choice", extra_rmids = c(10193)
  )
  , "Pressure/Tension" = list(
    path = "report/motivation/pressure-tension/"
    , dv = "Pressure/Tension", extra_rmids = c(10176)
  )
  , "Effort/Importance" = list(
    path = "report/motivation/effort-importance/"
    , dv = "Effort/Importance", extra_rmids = c(10232)
  )
  , "Intrinsic Motivation" = list(
    path = "report/motivation/intrinsic-motivation/"
    , dv = "Intrinsic Motivation", extra_rmids = c(10214,10175)
  )
)

info_lm <- list(
  "Attention" = list(
    path = "report/motivation/attention/"
    , dv = "Attention", extra_rmids = c()
  )
  , "Relevance" = list(
    path = "report/motivation/relevance/"
    , dv = "Relevance", extra_rmids = c(10232,10208,10176)
  )
  , "Satisfaction" = list(
    path = "report/motivation/satisfaction/"
    , dv = "Satisfaction", extra_rmids = c(10193)
  )
  , "Level of Motivation" = list(
    path = "report/motivation/level-of-motivation/"
    , dv = "Level of Motivation", extra_rmids = c()
  )
)

info <- c(info_im, info_lm)

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
    , override = T, ylim = c(1,7), levels = c('w/o-gamified','ont-gamified')
  )
  write_nonparametric_test_report(
    result, ylab = "Score", title = paste(x$dv, "Score"), filename = filename
    , override = F, ylim = c(1,7), levels = c('w/o-gamified','ont-gamified')
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
# tdat <- tdat[tdat$Type == 'ont-gamified',]
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
    , override = T, ylim = c(1,7), levels = c('w/o-gamified','ont-gamified')
  )
  write_parametric_test_report(
    result, ylab = "Score", title = paste(x$dv, "Score"), filename = filename
    , override = F, ylim = c(1,7), levels = c('w/o-gamified','ont-gamified')
  )
  return(result)
})

## translate to latex 
write_param_and_nonparam_statistics_analysis_in_latex(
  parametric_results, nonparametric_results, names(info_im)
  , filename = "report/latex/score-IM-statistical-analysis.tex"
  , in_title = " for the scores of Intrinsic Motivation obtained in the study 03"
)

write_param_and_nonparam_statistics_analysis_in_latex(
  parametric_results, nonparametric_results, names(info_lm)
  , filename = "report/latex/score-LM-statistical-analysis.tex"
  , in_title = " for the scores of Level of Motivation obtained in the study 03")

