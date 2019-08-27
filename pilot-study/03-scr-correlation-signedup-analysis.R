library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/SignedUpParticipants.csv')

info_src <- list(
  "difScore" = list(
    sheed = "data", dv = "difScore", wid = "UserID"
    , dv.name = "Diff of Scores"
    , filename = "report/learning-outcomes/scr-signedup-participants/NonParametricAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(
    sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
    , filename = "report/motivation/scr-signedup-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx")
  , "InterestEnjoyment" = list(
    sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
    , filename = "report/motivation/scr-signedup-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx")
  , "PerceivedChoice" = list(
    sheed = "data", dv = "Perceived Choice", wid = "UserID"
    , filename = "report/motivation/scr-signedup-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx")
  , "PressureTension" = list(
    sheed = "data", dv = "Pressure/Tension", wid = "UserID"
    , filename = "report/motivation/scr-signedup-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx")
  , "EffortImportance" = list(
    sheed = "data", dv = "Effort/Importance", wid = "UserID"
    , filename = "report/motivation/scr-signedup-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
    dv1=c('difScore')
    , dv2=c('IntrinsicMotivation', 'InterestEnjoyment'
            , 'PerceivedChoice', 'PressureTension', 'EffortImportance'))
  , info_src = info_src
  , include.subs = TRUE
  , method = "spearman"
)

corr_matrix_mods <- get_corr_matrix_mods(
  participants, corr_pair_mods
  , dvs = list(
    "Difference of Scores and Motivation" = c(
      'Diff of Scores', 'Intrinsic Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance')
  )
  , wid = "UserID"
  , method = "spearman"
)

## Write report
write_corr_matrix_report(
  corr_matrix_mods
  , filename = "report/correlation/scr-signedup-participants/CorrMatrixAnalysis.xlsx"
  , override = TRUE
)

write_corr_pair_report(
  corr_pair_mods
  , path = "report/correlation/scr-signedup-participants/"
  , override = TRUE
)

## Write plots
write_corr_matrix_plots(
  corr_matrix_mods
  , path = "report/correlation/scr-signedup-participants/corr-matrix-plots/"
  , override = TRUE
)

write_corr_chart_plots(
  corr_pair_mods
  , path =  "report/correlation/scr-signedup-participants/corr-chart-plots/"
  , override = TRUE
)

write_scatter_plots(
  corr_pair_mods, override = T
  , path = "report/correlation/scr-signedup-participants/corr-scatter-plots/"
)

#############################################################################
## Translate latex resume                                                  ##
#############################################################################
write_summary_corr_matrix_mods_in_latex(
  corr_matrix_mods
  , filename = "report/latex/correlation-scr-signedup-analysis.tex"
  , in_title = paste("between participants' motivation and learning outcomes"
                     ,"in the pilot empirical study")
)
