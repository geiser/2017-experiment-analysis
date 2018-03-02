
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/Participant.csv')

info_src <- list(
  "DiffTheta" = list(sheed = "data", dv = "DiffTheta", wid = "UserID"
                     , filename = "report/learning-outcome/MeasurementWilcoxAnalysis.xlsx")
  
  , "NroTotalInteractions" = list(sheed = "data", dv = "NroTotalInteractions", wid = "UserID"
                                  , filename = "report/interactions/total/WilcoxAnalysis.xlsx")
  , "NroNecessaryInteractions" = list(sheed = "data", dv = "NroNecessaryInteractions", wid = "UserID"
                                      , filename = "report/interactions/necessary/WilcoxAnalysis.xlsx")
  , "NroDesiredInteractions" = list(sheed = "data", dv = "NroDesiredInteractions", wid = "UserID"
                                    , filename = "report/interactions/desired/WilcoxAnalysis.xlsx")
  
  , "LevelofMotivation" = list(sheed = "data", dv = "Level of Motivation", wid = "UserID"
                               , filename = "report/motivation/level-of-motivation/MeasurementAnovaAnalysis.xlsx")
  , "Attention" = list(sheed = "data", dv = "Attention", wid = "UserID"
                       , filename = "report/motivation/attention/MeasurementAnovaAnalysis.xlsx")
  , "Satisfaction" = list(sheed = "data", dv = "Satisfaction", wid = "UserID"
                          , filename = "report/motivation/satisfaction/MeasurementAnovaAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
    dv1=c('DiffTheta', 'NroTotalInteractions', 'NroNecessaryInteractions', 'NroDesiredInteractions')
    , dv2=c('LevelofMotivation', 'Attention', 'Satisfaction')
  )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "DiffTheta and Motivation Factors" = c(
      'DiffTheta', 'Level of Motivation', 'Attention', 'Satisfaction')
    , "Total of Interations and Motivation Factors" = c(
      'NroTotalInteractions', 'Level of Motivation', 'Attention', 'Satisfaction')
    , "Necessary Interations and Motivation Factors" = c(
      'NroNecessaryInteractions', 'Level of Motivation','Attention', 'Satisfaction')
    , "Desired Interations and Motivation Factors" = c(
      'NroDesiredInteractions', 'Level of Motivation', 'Attention', 'Satisfaction')
  )
  , wid = "UserID"
  , method = "spearman"
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

