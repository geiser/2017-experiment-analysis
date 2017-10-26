
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/Participant.csv')

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('DiffScore', 'PostScore')
      , dv2=c('LevelofMotivation', 'Attention', 'Satisfaction')
    )
  , info_src = list(
    "DiffScore" = list(sheed = "data", dv = "DiffScore", wid = "UserID"
                       , filename = "report/learning-outcome/AnovaAnalysis.xlsx")
    , "PostScore" = list(sheed = "data", dv = "PostScore", wid = "UserID"
                         , filename = "report/learning-outcome/AnovaAnalysis.xlsx")
    , "LevelofMotivation" = list(sheed = "data", dv = "Level of Motivation", wid = "UserID"
                                 , filename = "report/motivation/level-of-motivation/AnovaAnalysis.xlsx")
    , "Attention" = list(sheed = "data", dv = "Attention", wid = "UserID"
                         , filename = "report/motivation/attention/AnovaAnalysis.xlsx")
    , "Satisfaction" = list(sheed = "data", dv = "Satisfaction", wid = "UserID"
                            , filename = "report/motivation/satisfaction/AnovaAnalysis.xlsx")
  )
  , include.subs = TRUE
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "DiffScore and Motivation Factors" = c(
      'DiffScore', 'Level of Motivation', 'Attention', 'Satisfaction'),
    "PostScore and Motivation Factors" = c(
      'PostScore', 'Level of Motivation', 'Attention', 'Satisfaction')
    )
  , wid = "UserID"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/SimpleCorrMatrixAnalysis.xlsx"
  , override = FALSE
)

write_corr_pair_report(
  corr_pair_mods
  , path = "report/correlation/"
  , override = FALSE
)

## Write plots
write_corr_matrix_plots(
  corr_matrix_mods
  , path = "report/correlation/simple-corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/simple-corr-chart-plots/"
  , override = TRUE
)
