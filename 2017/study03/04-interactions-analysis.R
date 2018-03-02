
library(readr)
library(dplyr)

participants <- read_csv('data/EffectiveParticipants.csv')

sources <- list(
  "Total of Interactions" = list(
    name = "Total of Interactions", dv = "NroTotalInteractions"
    , filename = "data/CLActivity.csv"
    , folder = "total"
    , between = c('Type', 'CLRole')
  )
  , "Necessary Interactions" = list(
    name = "Necessary Interactions", dv = "NroNecessaryInteractions"
    , filename = "data/CLActivity.csv"
    , folder = "necessary"
    , between = c('Type', 'CLRole')
  )
  , "Desired Interactions" = list(
    name = "Desired Interactions", dv = "NroDesiredInteractions"
    , extra_rmids = c(10171,10179,10231,10175,10196,10184,10230,10216)
    , filename = "data/CLActivity.csv", rm.outliers = FALSE
    , folder = "desired", only.one = TRUE
    , between = c('Type', 'CLRole')
  )
)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
nonparametric_results <- lapply(sources, FUN = function(x) {
  dat <-as.data.frame(read_csv(x$filename))
  dat <- merge(participants, dat)
  
  cat("\n .... processing: ", x$dv, " ....\n")
  path <- paste0('report/interactions/', x$folder, '/')
  filename <- paste0(path, 'NonParametricAnalysis.xlsx')
  result <- do_nonparametric_test(dat, dv = x$dv, iv = 'Type', between = c('Type', 'CLRole'))
  
  write_plots_for_nonparametric_test(
    result, ylab = "nro", title = paste("Nro. of", x$folder, "interactions")
    , path = paste0(path, 'score-nonparametric-analysis-plots/')
    , override = T, ylim = NULL
    , levels = c('w/o-gamified','ont-gamified')
  )
  write_nonparametric_test_report(
    result, ylab = "nro", title = paste("Nro. of", x$folder, "interactions")
    , filename = filename
    , override = F, ylim = NULL
    , levels = c('w/o-gamified','ont-gamified')
    , data = dat
  )
  
  return(result)
})

## translate to latex 
write_nonparam_statistics_analysis_in_latex(
  nonparametric_results, names(sources)
  , filename = "report/latex/interactions-nonparametric-statistical-analysis.tex"
  , in_title = " for the interactions in the empirical study 03"
)
