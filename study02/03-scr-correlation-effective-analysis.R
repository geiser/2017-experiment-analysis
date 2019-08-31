library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "difScore" = list(
    sheed = "data", dv = "difScore", wid = "UserID"
    , dv.name = "Diference in Scores"
    , filename = "report/learning-outcomes/scr-effective-participants/ParametricAnalysis.xlsx")
  
  , "LevelMotivation" = list(
    sheed = "data", dv = "Level of Motivation", wid = "UserID"
    , filename = "report/motivation/scr-effective-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx")
  , "Attention" = list(
    sheed = "data", dv = "Attention", wid = "UserID"
    , filename = "report/motivation/scr-effective-participants/attention/by-Type/ParametricAnalysis.xlsx")
  , "Relevance" = list(
    sheed = "data", dv = "Relevance", wid = "UserID"
    , filename = "report/motivation/scr-effective-participants/relevance/by-Type/ParametricAnalysis.xlsx")
  , "Satisfaction" = list(
    sheed = "data", dv = "Satisfaction", wid = "UserID"
    , filename = "report/motivation/scr-effective-participants/satisfaction/by-Type/ParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
    dv1=c('difScore')
    , dv2=c('LevelMotivation', 'Attention', 'Relevance', 'Satisfaction')
  )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "Diference in Scores and Motivation" = c(
      'Diference in Scores', 'Level of Motivation', 'Attention', 'Relevance', 'Satisfaction')
  )
  , wid = "UserID"
  , method = "spearman"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/scr-effective-participants/CorrMatrixAnalysis.xlsx"
  , override = TRUE
)

write_corr_pair_report(
  corr_pair_mods
  , path = "report/correlation/scr-effective-participants/"
  , override = TRUE
)

## Write plots
write_corr_matrix_plots(
  corr_matrix_mods
  , path = "report/correlation/scr-effective-participants/corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/scr-effective-participants/corr-chart-plots/"
  , override = TRUE
)

write_scatter_plots(
  corr_pair_mods, override = T
  , path = "report/correlation/scr-effective-participants/corr-scatter-plots/"
)

#############################################################################
## Translate latex resume                                                  ##
#############################################################################
write_summary_corr_matrix_mods_in_latex(
  corr_matrix_mods
  , filename = "report/latex/correlation-scr-effective-analysis.tex"
  , in_title = paste("between participants' motivation and learning outcomes"
                     ,"in the second empirical study")
)

