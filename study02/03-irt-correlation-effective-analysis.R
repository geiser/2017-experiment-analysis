library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

source('../common/misc.R')
source('../common/correlation-analysis.R')
source('../common/latex-translator.R')

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "gain.theta" = list(
    sheed = "data", dv = "gain.theta", wid = "UserID"
    , dv.name = "Gains in Skill/Knowledge"
    , filename = "report/learning-outcomes/effective-participants/ParametricAnalysis.xlsx")
  
  , "LevelofMotivation" = list(
    sheed = "data", dv = "Level of Motivation", wid = "UserID"
    , filename = "report/motivation/effective-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx")
  , "Attention" = list(
    sheed = "data", dv = "Attention", wid = "UserID"
    , filename = "report/motivation/effective-participants/attention/by-Type/ParametricAnalysis.xlsx")
  , "Relevance" = list(
    sheed = "data", dv = "Relevance", wid = "UserID"
    , filename = "report/motivation/effective-participants/relevance/by-Type/ParametricAnalysis.xlsx")
  , "Satisfaction" = list(
    sheed = "data", dv = "Satisfaction", wid = "UserID"
    , filename = "report/motivation/effective-participants/satisfaction/by-Type/ParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
    dv1=c('gain.theta')
    , dv2=c('LevelofMotivation', 'Attention', 'Relevance', 'Satisfaction')
  )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "Gains in Skill/Knowledge and Motivation" = c(
      'Gains in Skill/Knowledge'
      , 'Level of Motivation'
      , 'Attention', 'Relevance', 'Satisfaction')
  )
  , wid = "UserID"
  , method = "spearman"
)


## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/effective-participants/CorrMatrixAnalysis.xlsx"
  , override = TRUE
)

write_corr_pair_report(
  corr_pair_mods
  , path = "report/correlation/effective-participants/"
  , override = TRUE
)

## Write plots
write_corr_matrix_plots(
  corr_matrix_mods
  , path = "report/correlation/effective-participants/corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/effective-participants/corr-pairs-plots/"
  , override = TRUE
)

write_scatter_plots(
  corr_pair_mods
  , path =  "report/correlation/effective-participants/corr-scatter-plots/"
  , override = TRUE
)

#############################################################################
## Translate latex resume                                                  ##
#############################################################################
write_summary_corr_matrix_mods_in_latex(
  corr_matrix_mods
  , filename = paste0("report/latex/correlation-effective-analysis.tex")
  , in_title = paste0("between motivation factors and in the second empirical study")
)

