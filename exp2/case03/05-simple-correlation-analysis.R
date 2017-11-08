
library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/Participant.csv')

info_src <- list(
  "DiffScore" = list(sheed = "data", dv = "DiffScore", wid = "UserID"
                     , filename = "report/learning-outcome/AnovaAnalysis.xlsx")
  
  , "NroTotalInteractions" = list(sheed = "data", dv = "NroTotalInteractions", wid = "UserID"
                                  , filename = "report/interactions/total/WilcoxAnalysis.xlsx")
  , "NroNecessaryInteractions" = list(sheed = "data", dv = "NroNecessaryInteractions", wid = "UserID"
                                      , filename = "report/interactions/necessary/WilcoxAnalysis.xlsx")
  , "NroDesiredInteractions" = list(sheed = "data", dv = "NroDesiredInteractions", wid = "UserID"
                                    , filename = "report/interactions/desired/WilcoxAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
                                 , filename = "report/motivation/intrinsic-motivation/AnovaAnalysis.xlsx")
  , "LevelofMotivation" = list(sheed = "data", dv = "Level of Motivation", wid = "UserID"
                               , filename = "report/motivation/level-of-motivation/AnovaAnalysis.xlsx")
  , "InterestEnjoyment" = list(sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
                               , filename = "report/motivation/interest-enjoyment/AnovaAnalysis.xlsx")
  , "PerceivedChoice" = list(sheed = "data", dv = "Perceived Choice", wid = "UserID"
                             , filename = "report/motivation/perceived-choice/AnovaAnalysis.xlsx")
  , "PressureTension" = list(sheed = "data", dv = "Pressure/Tension", wid = "UserID"
                             , filename = "report/motivation/pressure-tension/AnovaAnalysis.xlsx")
  , "EffortImportance" = list(sheed = "data", dv = "Effort/Importance", wid = "UserID"
                              , filename = "report/motivation/effort-importance/AnovaAnalysis.xlsx")
  , "Attention" = list(sheed = "data", dv = "Attention", wid = "UserID"
                       , filename = "report/motivation/attention/AnovaAnalysis.xlsx")
  , "Satisfaction" = list(sheed = "data", dv = "Satisfaction", wid = "UserID"
                          , filename = "report/motivation/satisfaction/AnovaAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('DiffScore', 'NroTotalInteractions', 'NroNecessaryInteractions', 'NroDesiredInteractions')
      , dv2=c('IntrinsicMotivation', 'LevelofMotivation', 'InterestEnjoyment'
              , 'PerceivedChoice', 'PressureTension', 'EffortImportance', 'Attention', 'Satisfaction')
    )
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "DiffScore and Motivation Factors" = c(
      'DiffScore', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance', 'Attention', 'Satisfaction')
    , "Total of Interations and Motivation Factors" = c(
      'NroTotalInteractions', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance', 'Attention', 'Satisfaction')
    , "Necessary Interations and Motivation Factors" = c(
      'NroNecessaryInteractions', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance', 'Attention', 'Satisfaction')
    , "Desired Interations and Motivation Factors" = c(
      'NroDesiredInteractions', 'Intrinsic Motivation', 'Level of Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance', 'Attention', 'Satisfaction')
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
