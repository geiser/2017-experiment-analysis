library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)
library(MVN)

dat_pre <- total_score_from_guttman(read_csv('data/PreGuttmanVPL.csv'), from_cols = c("P2s3","P3s3"), col_score = "PreScore")
dat_pos <- total_score_from_guttman(read_csv('data/PosGuttmanVPL.csv'), from_cols = c("PCs3","PDs3","PEs3"), col_score = "PosScore")
dat_prg <- merge(dat_pre, dat_pos)
dat_prg[['P2']] <- 1*dat_prg[['P2s3']]/4
dat_prg[['P3']] <- 1.25*dat_prg[['P3s3']]/4
dat_prg[['PC']] <- 1*dat_prg[['PCs3']]/4
dat_prg[['PD']] <- 1.25*dat_prg[['PDs3']]/4
dat_prg[['PE']] <- 1.5*dat_prg[['PEs3']]/4

dat_prg <- dat_prg[,c('UserID','P2','P3','PC','PD','PE')]

dat_pre <- select(read_csv('data/PreAMCscr.csv'), -starts_with('NroUSP'), -starts_with('Type'), -starts_with('CLGroup'), -starts_with('CLRole'), -starts_with('PlayerRole'))
dat_pos <- select(read_csv('data/PosAMCscr.csv'), -starts_with('NroUSP'), -starts_with('Type'), -starts_with('CLGroup'), -starts_with('CLRole'), -starts_with('PlayerRole'))
dat <- merge(dat_pre, dat_pos, by = setdiff(intersect(names(dat_pre), names(dat_pos)), 'score'), suffixes = c('.pre','.pos'))
dat <- merge(dat, dat_prg, all.x = T, by = 'UserID')
dat[is.na(dat)] <- 0
dat[['score.pre']] <- dat[['score.pre']] + dat[['P2']] + dat[['P3']] 
dat[['score.pos']] <- dat[['score.pos']] + dat[['PC']] + dat[['PD']] + dat[['PE']]
dat <- dplyr::mutate(dat, difScore = dat$score.pos - dat$score.pre)

participants <- as.data.frame(read_csv("data/EffectiveParticipants.csv"))
dat <- merge(participants, dat, by = 'UserID')

folder <- 'scr-effective-participants'
title <- "Difference in Scores (Posttest-Pretest) - Loop Structures"
dir.create(paste0("report/learning-outcomes/", folder), showWarnings = F)

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
  , dvs = list(difScore = 'difScore')
  , filename = paste0("report/latex/learning-outcomes/nonparametric-",folder,"-scr-analysis.tex")
  , in_title = paste("for Differences of Scores in the second study for students with effective participation")
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################
extra_rmids <- c()

# Validate Assumptions
sdat <- dat
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  cat('\n... removing ids c(', extra_rmids, ') from: difScore by Type \n')
  sdat <- sdat[!sdat$UserID %in% extra_rmids,]
}
(mvn_mod <- mvn(sdat[,c('score.pre','difScore')], univariatePlot = "box", univariateTest = "SW"))


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
write_param_statistics_analysis_in_latex(
  parametric_results = list("Type" = result)
  , ivs = c("Type")
  , filename = paste0("report/latex/learning-outcomes/parametric-", folder, "-analysis.tex")
  , in_title = paste("for the differences of scores in the second empirical study for students with effective participation")
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
  , in_title = "in the second study for students with effective participation"
  , mvn_mod = NULL, min_size_tests = T)
