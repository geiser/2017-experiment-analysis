
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "DiffTheta" = list(sheed = "data", dv = "DiffTheta", wid = "UserID"
                     , filename = "report/learning-outcome/effective-participants/ParametricAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
                                 , filename = "report/motivation/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx")
  , "LevelofMotivation" = list(sheed = "data", dv = "Level of Motivation", wid = "UserID"
                               , filename = "report/motivation/level-of-motivation/by-Type/ParametricAnalysis.xlsx")
  , "InterestEnjoyment" = list(sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
                               , filename = "report/motivation/interest-enjoyment/by-Type/ParametricAnalysis.xlsx")
  , "PerceivedChoice" = list(sheed = "data", dv = "Perceived Choice", wid = "UserID"
                             , filename = "report/motivation/perceived-choice/by-Type/ParametricAnalysis.xlsx")
  , "PressureTension" = list(sheed = "data", dv = "Pressure/Tension", wid = "UserID"
                             , filename = "report/motivation/pressure-tension/by-Type/ParametricAnalysis.xlsx")
  , "EffortImportance" = list(sheed = "data", dv = "Effort/Importance", wid = "UserID"
                              , filename = "report/motivation/effort-importance/by-Type/ParametricAnalysis.xlsx")
  , "Attention" = list(sheed = "data", dv = "Attention", wid = "UserID"
                       , filename = "report/motivation/attention/by-Type/ParametricAnalysis.xlsx")
  , "Relevance" = list(sheed = "data", dv = "Relevance", wid = "UserID"
                          , filename = "report/motivation/relevance/by-Type/ParametricAnalysis.xlsx")
  , "Satisfaction" = list(sheed = "data", dv = "Satisfaction", wid = "UserID"
                          , filename = "report/motivation/satisfaction/by-Type/ParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('DiffTheta')
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
    "DiffTheta and Motivation Factors" = c(
      'DiffTheta', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance', 'Attention', 'Satisfaction')
  )
  , wid = "UserID"
  , method = "spearman"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/effective-participants/MeasurementCorrMatrixAnalysis.xlsx"
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
  , path = "report/correlation/effective-participants/measurement-corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/effective-participants/measurement-corr-chart-plots/"
  , override = TRUE
)

