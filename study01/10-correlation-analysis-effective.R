
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "DiffTheta" = list(sheed = "data", dv = "DiffTheta", wid = "UserID"
                     , filename = "report/learning-outcome/effective-participants/NonParametricAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
                                 , filename = "report/motivation/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx")
  , "InterestEnjoyment" = list(sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
                               , filename = "report/motivation/interest-enjoyment/by-Type/ParametricAnalysis.xlsx")
  , "PerceivedChoice" = list(sheed = "data", dv = "Perceived Choice", wid = "UserID"
                             , filename = "report/motivation/perceived-choice/by-Type/ParametricAnalysis.xlsx")
  , "PressureTension" = list(sheed = "data", dv = "Pressure/Tension", wid = "UserID"
                             , filename = "report/motivation/pressure-tension/by-Type/ParametricAnalysis.xlsx")
  , "EffortImportance" = list(sheed = "data", dv = "Effort/Importance", wid = "UserID"
                              , filename = "report/motivation/effort-importance/by-Type/ParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('DiffTheta')
      , dv2=c('IntrinsicMotivation', 'InterestEnjoyment'
              , 'PerceivedChoice', 'PressureTension', 'EffortImportance')
    )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "DiffTheta and Motivation Factors" = c(
      'DiffTheta', 'Intrinsic Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance')
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

