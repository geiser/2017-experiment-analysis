
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "GainScore" = list(sheed = "data", dv = "Gain Score", wid = "UserID"
                     , filename = "report/learning-outcome/ScoreParametricAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
                                 , filename = "report/motivation/intrinsic-motivation/ScoreParametricAnalysis.xlsx")
  , "LevelofMotivation" = list(sheed = "data", dv = "Level of Motivation", wid = "UserID"
                               , filename = "report/motivation/level-of-motivation/ScoreParametricAnalysis.xlsx")
  , "InterestEnjoyment" = list(sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
                               , filename = "report/motivation/interest-enjoyment/ScoreParametricAnalysis.xlsx")
  , "PerceivedChoice" = list(sheed = "data", dv = "Perceived Choice", wid = "UserID"
                             , filename = "report/motivation/perceived-choice/ScoreParametricAnalysis.xlsx")
  , "PressureTension" = list(sheed = "data", dv = "Pressure/Tension", wid = "UserID"
                             , filename = "report/motivation/pressure-tension/ScoreParametricAnalysis.xlsx")
  , "EffortImportance" = list(sheed = "data", dv = "Effort/Importance", wid = "UserID"
                              , filename = "report/motivation/effort-importance/ScoreParametricAnalysis.xlsx")
  , "Attention" = list(sheed = "data", dv = "Attention", wid = "UserID"
                       , filename = "report/motivation/attention/ScoreParametricAnalysis.xlsx")
  , "Relevance" = list(sheed = "data", dv = "Relevance", wid = "UserID"
                       , filename = "report/motivation/relevance/ScoreParametricAnalysis.xlsx")
  , "Satisfaction" = list(sheed = "data", dv = "Satisfaction", wid = "UserID"
                          , filename = "report/motivation/satisfaction/ScoreParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('GainScore')
      , dv2=c('IntrinsicMotivation', 'LevelofMotivation', 'InterestEnjoyment'
              , 'PerceivedChoice', 'PressureTension', 'EffortImportance', 'Attention', 'Relevance', 'Satisfaction')
    )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "Gain Score and Motivation Factors" = c(
      'Gain Score', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension'
      , 'Effort/Importance', 'Attention', 'Relevance', 'Satisfaction')
  )
  , wid = "UserID"
  , method = "spearman"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/SimpleCorrMatrixAnalysis.xlsx"
  , override = TRUE
)

write_corr_pair_report(
  corr_pair_mods
  , path = "report/correlation/"
  , override = TRUE
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
