library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(readxl)

participants <- as.data.frame(read_csv("data/SignedUpParticipants.csv"))
dat <- read_csv('data/GainSkillsKnowledge.csv')
dat <- merge(participants, dat[,c("UserID","pre.theta","pos.theta","gain.theta")])

folder <- 'signedup-participants'
title <- "Gains in Skill/Knowledge - Loop Structures"
dir.create(paste0("report/learning-outcomes/", folder), showWarnings = F)

list_dvs <- as.list(c("gain.theta"))
names(list_dvs) <- c("gain.theta")
sdat_map = list("gain.theta" = dat)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

nonparam_result <- do_nonparametric_test(dat, wid = 'UserID', dv = "gain.theta"
                                , iv = "Type", between = c("Type", "CLRole"))
write_plots_for_nonparametric_test(
  nonparam_result, ylab = "logits", title = title
  , path = paste0("report/learning-outcomes/",folder,'/nonparametric-analysis-plots/')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

write_nonparametric_test_report(
  nonparam_result, ylab = "logits", title = title
  , filename = paste0("report/learning-outcomes/",folder,"/NonParametricAnalysis.xlsx")
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
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
  cat('\n... removing ids c(', extra_rmids, ') from: gain.theta by Type \n')
  sdat <- sdat[!sdat$UserID %in% extra_rmids,]
}

result <- do_parametric_test(sdat, wid = 'UserID', dv = 'gain.theta', iv = 'Type'
                             , between = c('Type', "CLRole"), cstratify = c("CLRole"))
cat('\n... checking assumptions for: gain.theta by Type\n')
print(result$test.min.size$error.warning.list)
if (result$normality.fail) cat('\n... normality fail ...\n')
if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
if (result$assumptions.fail) {
  plot_assumptions_for_parametric_test(result, 'gain.theta')
  if (result$normality.fail) normPlot(result$data, 'gain.theta')
}

## export reports and plots
filename <- paste0('report/learning-outcomes/',folder,'/ParametricAnalysis.xlsx')
sdat <- winsor_mod$wdat
if (!is.null(extra_rmids) && length(extra_rmids) > 0) {
  cat('\n... removing ids c(', extra_rmids, ') from: gain.theta by Type\n')
  sdat <- sdat[!sdat$UserID %in% extra_rmids,]
}

result <- do_parametric_test(sdat, wid = "UserID", dv = 'gain.theta', iv = 'Type'
                             , between = c("Type", "CLRole"), cstratify = c("CLRole"))
write_plots_for_parametric_test(
  result, ylab = "logit", title = title
  , path = paste0('report/learning-outcomes/',folder,'/parametric-analysis-plots/')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

write_parametric_test_report(
  result, ylab = "logit", title =title
  , filename = paste0('report/learning-outcomes/',folder,'/ParametricAnalysis.xlsx')
  , override = T, ylim = NULL
  , levels = c('non-gamified','ont-gamified')
)

#############################################################################
## Translate latex resume                                                  ##
#############################################################################
write_nonparam_statistics_analysis_in_latex(
  filename = paste0("report/latex/nonparametric-learning-outcomes-",folder,"-analysis.tex")
  , nonparametric_results = list("gain.theta" = nonparam_result)
  , dvs = list_dvs
)

write_winsorized_in_latex(
  winsor_mod$diff_dat
  , filename = paste0("report/latex/wisorized-learning-outcomes",folder,".tex")
  , in_title = paste("for estimating gains in skill/knowledge based on"
                     ,"the stacking of pre-test and post-test data with GPCM"
                     ,"in the pilot empirical study")
)

write_param_statistics_analysis_in_latex(
  parametric_results = list("Type" = result)
  , ivs = c("Type")
  , filename = paste0("report/latex/parametric-learning-outcomes-", folder, "-analysis.tex")
  , in_title = paste("for the gains in skill/knowledge estimates in the pilot empirical study")
)

