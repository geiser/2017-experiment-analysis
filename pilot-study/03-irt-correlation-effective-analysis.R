library(psych)
library(readr)
library(dplyr)
library(readxl)
library(PerformanceAnalytics)

participants <- read_csv('data/EffectiveParticipants.csv')

info_src <- list(
  "gain.theta" = list(
    sheed = "data", dv = "gain.theta", wid = "UserID"
    , dv.name = "Gains in Skill/Knowledge"
    , filename = "report/learning-outcomes/effective-participants/ParametricAnalysis.xlsx")
  
  , "IntrinsicMotivation" = list(
    sheed = "data", dv = "Intrinsic Motivation", wid = "UserID"
    , filename = "report/motivation/effective-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx")
  , "InterestEnjoyment" = list(
    sheed = "data", dv = "Interest/Enjoyment", wid = "UserID"
    , filename = "report/motivation/effective-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx")
  , "PerceivedChoice" = list(
    sheed = "data", dv = "Perceived Choice", wid = "UserID"
    , filename = "report/motivation/effective-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx")
  , "PressureTension" = list(
    sheed = "data", dv = "Pressure/Tension", wid = "UserID"
    , filename = "report/motivation/effective-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx")
  , "EffortImportance" = list(
    sheed = "data", dv = "Effort/Importance", wid = "UserID"
    , filename = "report/motivation/effective-participants/effort-importance/by-Type/ParametricAnalysis.xlsx")
)

corr_pair_mods <- get_corr_pair_mods(
  participants, iv = "Type", wid = "UserID", between = c('Type', 'CLRole')
  , corr_var = list(
      dv1=c('gain.theta')
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
    "Gains in Skill/Knowledge and Motivation" = c(
      'Gains in Skill/Knowledge', 'Intrinsic Motivation'
      , 'Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension', 'Effort/Importance')
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
  corr_pair_mods, override = T
  , path = "report/correlation/effective-participants/corr-scatter-plots/"
)

#############################################################################
## Translate latex resume                                                  ##
#############################################################################
write_summary_corr_matrix_mods_in_latex(
  corr_matrix_mods
  , filename = paste0("report/latex/correlation-effective-analysis.tex")
  , in_title = paste("between participants' motivation and learning outcomes"
                     ,"in the pilot empirical study")
)


