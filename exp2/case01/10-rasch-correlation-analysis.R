
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/Participant.csv')

info_src <- list(
  "DiffTheta" = list(sheed = "data", dv = "DiffTheta", wid = "UserID"
                     , filename = "report/learning-outcome/MeasurementAnovaAnalysis.xlsx")
  
  , "NroTotalInteractions" = list(sheed = "data", dv = "NroTotalInteractions", wid = "UserID"
                                  , filename = "report/interactions/total/WilcoxAnalysis.xlsx")
  , "NroNecessaryInteractions" = list(sheed = "data", dv = "NroNecessaryInteractions", wid = "UserID"
                                      , filename = "report/interactions/necessary/WilcoxAnalysis.xlsx")
  , "NroDesiredInteractions" = list(sheed = "data", dv = "NroDesiredInteractions", wid = "UserID"
                                    , filename = "report/interactions/desired/WilcoxAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
                                 , filename = "report/motivation/intrinsic-motivation/MeasurementAnovaAnalysis.xlsx")
  , "InterestEnjoyment" = list(sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
                               , filename = "report/motivation/interest-enjoyment/MeasurementAnovaAnalysis.xlsx")
  , "PerceivedChoice" = list(sheed = "data", dv = "Perceived Choice", wid = "UserID"
                             , filename = "report/motivation/perceived-choice/MeasurementAnovaAnalysis.xlsx")
  , "PressureTension" = list(sheed = "data", dv = "Pressure/Tension", wid = "UserID"
                             , filename = "report/motivation/pressure-tension/MeasurementAnovaAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
    dv1=c('DiffTheta', 'NroTotalInteractions', 'NroNecessaryInteractions', 'NroDesiredInteractions')
    , dv2=c('IntrinsicMotivation', 'InterestEnjoyment', 'PerceivedChoice', 'PressureTension')
  )
  , info_src = info_src
  , include.subs = TRUE
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "DiffTheta and Motivation Factors" = c(
      'DiffTheta', 'Intrinsic Motivation', 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension')
    , "Total of Interations and Motivation Factors" = c(
      'NroTotalInteractions', 'Intrinsic Motivation', 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension')
    , "Necessary Interations and Motivation Factors" = c(
      'NroNecessaryInteractions', 'Intrinsic Motivation', 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension')
    , "Desired Interations and Motivation Factors" = c(
      'NroDesiredInteractions', 'Intrinsic Motivation', 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension')
  )
  , wid = "UserID"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/MeasurementCorrMatrixAnalysis.xlsx"
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
  , path = "report/correlation/measurement-corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/measurement-corr-chart-plots/"
  , override = TRUE
)
