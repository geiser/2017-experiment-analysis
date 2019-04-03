wants <- c('MVN', 'robustHD', 'daff', 'plyr', 'dplyr', 'readr', 'lsmeans')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(MVN)
library(daff)
library(plyr)
library(robustHD)
library(lsmeans)
library(readr)
library(dplyr)
library(car)
library(afex)
library(dplyr)
library(stats)
library(ez)

participants <- read_csv('data/EffectiveParticipants.csv')

sources <- list(
  "Interest/Enjoyment" = list(name = "Interest/Enjoyment"
    , extra_rmids = c(), folder = "interest-enjoyment"
  )
  , "Perceived Choice" = list(name = "Perceived Choice"
    , extra_rmids = c(), folder = "perceived-choice"
  )
  , "Pressure/Tension" = list(name = "Pressure/Tension"
    , extra_rmids = c(), folder = "pressure-tension"
  )
  , "Effort/Importance" = list(name = "Effort/Importance"
    , extra_rmids = c(), folder = "effort-importance"
  )
  , "Intrinsic Motivation" = list(name = "Intrinsic Motivation"
    , extra_rmids = c(), folder = "intrinsic-motivation"
  )
)

##
sdat <- merge(participants, read_csv("data/IMI.csv"))

##
dvs <- c("Interest/Enjoyment", "Perceived Choice"
         , "Pressure/Tension", "Effort/Importance", "Intrinsic Motivation")
list_dvs <- as.list(dvs)
names(list_dvs) <- dvs

list_info <- lapply(list_dvs, FUN = function(dv) {
  name <- gsub('\\W', '', dv)
  ivs <- c("Type")
  list_ivs <- as.list(ivs)
  names(list_ivs) <- ivs
  info <- lapply(list_ivs, function(iv) {
    return(list(
      title = paste0(dv, " by ", iv)
      , path = paste0("report/motivation/scr-effective-participants/", sources[[dv]]$folder,"/by-",iv,"/")
      , iv = iv
    ))
  })
  
  return(list(dv=dv, name=name, info = info))
})



#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
all_nonparametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  dir.create(paste0("report/motivation/scr-effective-participants/", sources[[dv]]$folder), showWarnings = F)
  
  nonparametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'nonparametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'nonparametric-analysis-plots/')
    filename <- paste0(x$path, 'NonParametricAnalysis.xlsx')
    result <- do_nonparametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"))
    
    write_plots_for_nonparametric_test(
      result, ylab = "score", title = x$title
      , path = path, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    write_nonparametric_test_report(
      result, ylab = "score", title = x$title
      , filename = filename, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

## translate to latex
lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  nonparametric_results <- all_nonparametric_results[[dv]]
  ##
  write_nonparam_statistics_analysis_in_latex(
    nonparametric_results, dvs = names(info)
    , filename = paste0("report/latex/motivation-effective/nonparametric-"
                        , sources[[dv]]$folder, "-scr-analysis.tex")
    , in_title = paste0(" for ", dv, " score "
                        , " in the pilot study", " for students with effective participation")
  )
})


#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################
sdat_map <- lapply(list_dvs, function(x) { return(sdat) })
winsor_mod <- winsorize_two_by_two_design(
  participants, sdat_map, list_dvs, ivs_list = list(
    iv1 = list(iv = "Type", values = c("non-gamified", "ont-gamified"))
    , iv2 = list(iv = "CLRole", values = c("Master", "Apprentice"))
))

render_diff(winsor_mod$diff_dat)
(mvn_mod <- mvn(winsor_mod$wdat[,dvs], univariatePlot = "box", univariateTest = "SW"))

# Validate Assumptions
lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  lapply(info, FUN = function(x) {
    sdat <- winsor_mod$wdat
    result <- do_parametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"))
    cat('\n... checking assumptions for: ', dv, ' by ', x$iv, '\n')
    print(result$test.min.size$error.warning.list)
    if (result$normality.fail) cat('\n... normality fail ...\n')
    if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    if (result$assumptions.fail) {
      plot_assumptions_for_parametric_test(result, x$dv)
      if (result$normality.fail) normPlot(result$data, dv)
      stopifnot(F)
    }
  })
})

## export reports and plots
all_parametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  
  dir.create(paste0("report/motivation/scr-effective-participants/", sources[[dv]]$folder), showWarnings = F)
  
  parametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'parametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'parametric-analysis-plots/')
    filename <- paste0(x$path, 'ParametricAnalysis.xlsx')
    
    sdat <- winsor_mod$wdat
    result <- do_parametric_test(sdat, wid = "UserID", dv = dv, iv = x$iv, between = c(x$iv, "CLRole"))
    
    write_plots_for_parametric_test(
      result, ylab = "score", title = x$title
      , path = path, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    write_parametric_test_report(
      result, ylab = "score", title = x$title
      , filename = filename, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

## translate to latex
write_winsorized_in_latex(
  winsor_mod$diff_dat
  , filename = "report/latex/motivation-effective/wisorized-scr-intrinsic-motivation.tex"
  , in_title = paste("for intrinsic motivation score in the pilot study for students with effective participation")
)

lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  parametric_results <- all_parametric_results[[dv]]
  ##
  write_param_statistics_analysis_in_latex(
    parametric_results, ivs = names(info)
    , filename = paste0("report/latex/motivation-effective/parametric-", sources[[dv]]$folder, "-scr-analysis.tex")
    , in_title = paste0(" for ", dv, " score in the pilot study for students with effective participation")
  )
})

#############################################################################
## Global summary                                                          ##
#############################################################################
write_param_and_nonparam_statistics_analysis_in_latex(
  all_parametric_results, all_nonparametric_results, list_info
  , filename = "report/latex/motivation-effective/summary-scr-analysis.tex"
  , in_title = "in the pilot study for students with effective participation"
  , mvn_mod = mvn_mod, min_size_tests = T)

