library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)

dat_pre <- total_score_from_guttman(read_csv('data/PreGuttmanVPL.csv'), from_cols = c("P1s3","P2s3","P3s3","P4s3"), col_score = "PreScore")
dat_pos <- total_score_from_guttman(read_csv('data/PosGuttmanVPL.csv'), from_cols = c("PAs3","PBs3","PCs3","PDs3"), col_score = "PosScore")

participants <- as.data.frame(read_csv("data/SignedUpParticipants.csv"))

dat <- merge(dat_pre, dat_pos)
dat <- merge(participants, dat)
dat <- dplyr::mutate(dat, difScore = dat$PosScore - dat$PreScore)

folder <- 'scr-signedup-participants'
title <- "Difference in Scores - Loop Structures"
dir.create(paste0("report/learning-outcomes/", folder), showWarnings = F)

list_dvs <- as.list(c("difScore"))
names(list_dvs) <- c("difScore")
sdat_map = list("difScore" = dat)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

nonparam_result <- do_nonparametric_test(dat, wid = 'UserID', dv = "difScore"
                                , iv = "Type", between = c("Type", "CLRole"))
write_plots_for_nonparametric_test(
  nonparam_result, ylab = "score", title = title
  , path = paste0("report/learning-outcomes/",folder,'/nonparametric-analysis-plots/')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

write_nonparametric_test_report(
  nonparam_result, ylab = "score", title = title
  , filename = paste0("report/learning-outcomes/",folder,"/NonParametricAnalysis.xlsx")
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

## translate to latex
write_nonparam_statistics_analysis_in_latex(
  nonparametric_results = list("difScore" = nonparam_result)
  , dvs = list_dvs
  , filename = paste0("report/latex/learning-outcomes/nonparametric-",folder,"-scr-analysis.tex")
  , in_title = paste("for Differences of Scores in the pilot study for signed-up students")
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

winsor_mod <- winsorize_two_by_two_design(
  participants, sdat_map = sdat_map, wid = "UserID", list_dvs = list_dvs
  , ivs_list = list(
    iv1 = list(iv = "Type", values = c("non-gamified", "ont-gamified"))
    , iv2 = list(iv = "CLRole", values = c("Master", "Apprentice"))
))

render_diff(winsor_mod$diff_dat)
extra_rmids <- c()#10141,10148,10143,10127)#

# Validate Assumptions
sdat <- winsor_mod$wdat
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  cat('\n... removing ids c(', extra_rmids, ') from: difScore by Type \n')
  sdat <- sdat[!sdat$UserID %in% extra_rmids,]
}
(mvn_mod <- mvn(sdat[,list_dvs$difScore], univariatePlot = "box", univariateTest = "SW"))

result <- do_parametric_test(sdat, wid = 'UserID', dv = 'difScore', iv = 'Type'
                             , between = c('Type', "CLRole"), cstratify = c("CLRole"))
cat('\n... checking assumptions for: difScore by Type\n')
print(result$test.min.size$error.warning.list)
if (result$normality.fail) cat('\n... normality fail ...\n')
if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
if (result$assumptions.fail) {
  plot_assumptions_for_parametric_test(result, 'difScore')
  if (result$normality.fail) normPlot(result$data, 'difScore')
}

## export reports and plots
filename <- paste0('report/learning-outcomes/',folder,'/ParametricAnalysis.xlsx')
sdat <- winsor_mod$wdat
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  cat('\n... removing ids c(', extra_rmids, ') from: difScore by Type\n')
  sdat <- sdat[!sdat$UserID %in% extra_rmids,]
}

result <- do_parametric_test(sdat, wid = "UserID", dv = 'difScore', iv = 'Type'
                             , between = c("Type", "CLRole"), cstratify = c("CLRole"))
write_plots_for_parametric_test(
  result, ylab = "score", title = title
  , path = paste0('report/learning-outcomes/',folder,'/parametric-analysis-plots/')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

write_parametric_test_report(
  result, ylab = "score", title =title
  , filename = paste0('report/learning-outcomes/',folder,'/ParametricAnalysis.xlsx')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

## translate to latex
write_winsorized_in_latex(
  winsor_mod$diff_dat
  , filename = paste0("report/latex/learning-outcomes/wisorized-",folder,".tex")
  , in_title = paste("for the differences of scores in the pilot empirical study")
)

write_param_statistics_analysis_in_latex(
  parametric_results = list("Type" = result)
  , ivs = c("Type")
  , filename = paste0("report/latex/learning-outcomes/parametric-", folder, "-analysis.tex")
  , in_title = paste("for the differences of scores in the pilot empirical study")
)

#############################################################################
## Global summary                                                          ##
#############################################################################
write_param_and_nonparam_statistics_analysis_in_latex(
  all_parametric_results = list("difScore" = list("Type" = result))
  , all_nonparametric_results = list("difScore" = list("Type" = nonparam_result))
  , list_info = list("difScore"=list("ivs"="Type", "dv"="difScore"
                                       , "info" = list("Type"="Type")))
  , filename = paste0("report/latex/learning-outcomes/",folder,"-summary-analysis.tex")
  , in_title = "in the pilot study for signed-up students"
  , mvn_mod = mvn_mod, min_size_tests = T)



