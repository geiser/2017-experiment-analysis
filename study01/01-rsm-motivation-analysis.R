wants <- c('MVN', 'robustHD', 'daff', 'plyr', 'dplyr', 'readr')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(MVN)
library(daff)
library(plyr)
library(robustHD)

library(readr)
library(dplyr)
library(car)
library(afex)
library(dplyr)
library(stats)
library(ez)

participants <- read_csv('data/SignedUpParticipants.csv')

sources <- list(
  "Interest/Enjoyment" = list(
    filename = "data/InterestEnjoyment.csv", name = "Interest/Enjoyment"
    , extra_rmids = c(), folder = "interest-enjoyment"
  )
  , "Perceived Choice" = list(
    filename = "data/PerceivedChoice.csv", name = "Perceived Choice"
    , extra_rmids = c(), folder = "perceived-choice"
  )
  , "Pressure/Tension" = list(
    filename = "data/PressureTension.csv", name = "Pressure/Tension"
    , extra_rmids = c(), folder = "pressure-tension"
  )
  , "Effort/Importance" = list(
    filename = "data/EffortImportance.csv", name = "Effort/Importance"
    , extra_rmids = c(), folder = "effort-importance"
  )
  , "Intrinsic Motivation" = list(
    filename = "data/IntrinsicMotivation.csv", name = "Intrinsic Motivation"
    , extra_rmids = c(), folder = "intrinsic-motivation"
  )
)

##
sdat_map <- lapply(sources, FUN = function(src) {
  if (!is.null(src$filename)) {
    sdat <- read_csv(src$filename)
    sdat[[src$name]] <- sdat$theta
    return(sdat)
  }
})

##
dvs <- c("Interest/Enjoyment", "Perceived Choice", "Pressure/Tension", "Effort/Importance", "Intrinsic Motivation")
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
      , path = paste0("report/motivation/", sources[[dv]]$folder,"/by-",iv,"/")
      , iv = iv
    ))
  })
  
  return(list(dv=dv, name =name, info = info))
})

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
all_nonparametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  sdat <- sdat_map[[dv]]
  dir.create(paste0("report/motivation/", sources[[dv]]$folder), showWarnings = F)
  
  nonparametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'nonparametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'nonparametric-analysis-plots/')
    filename <- paste0(x$path, 'NonParametricAnalysis.xlsx')
    result <- do_nonparametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"))
    
    write_plots_for_nonparametric_test(
      result, ylab = "logits", title = x$title
      , path = path, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    write_nonparametric_test_report(
      result, ylab = "logits", title = x$title
      , filename = filename, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################
winsor_mod <- winsorize_two_by_two_design(participants, sdat_map, list_dvs, ivs_list = list(
  iv1 = list(iv = "Type", values = c("non-gamified", "ont-gamified"))
  , iv2 = list(iv = "CLRole", values = c("Master", "Apprentice"))
))

render_diff(winsor_mod$diff_dat)
(mvn_mod <- mvn(winsor_mod$wdat[,dvs], univariatePlot = "box", univariateTest = "SW"))

# print possible problems
(person_infit_outfit_problems <- lapply(list_dvs, FUN = function(dv){
  return(sdat_map[[dv]][sdat_map[[dv]]$Infit > 2 | sdat_map[[dv]]$Outfit > 2,c("UserID","theta")])
}))

skip_stop <- c("Pressure/Tension")
extra_rmids <- list(
  "Interest/Enjoyment" = c(10230,10222,10231,10200)
  )

# Validate Assumptions
lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  lapply(info, FUN = function(x) {
    sdat <- winsor_mod$wdat
    if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
      cat('\n... removing ids c(', extra_rmids[[dv]], ') from: ', dv, ' by ', x$iv, '\n')
      sdat <- sdat[!sdat$UserID %in% extra_rmids[[dv]],]
    }
    
    result <- do_parametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"), cstratify = c("CLRole"))
    cat('\n... checking assumptions for: ', dv, ' by ', x$iv, '\n')
    print(result$test.min.size$error.warning.list)
    if (result$normality.fail) cat('\n... normality fail ...\n')
    if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    if (result$assumptions.fail) {
      plot_assumptions_for_parametric_test(result, x$dv)
      if (result$normality.fail) normPlot(result$data, dv)
      stopifnot(dv %in% skip_stop)
    }
  })
})

## export reports and plots
all_parametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  
  dir.create(paste0("report/motivation/", sources[[dv]]$folder), showWarnings = F)
  
  parametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'parametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'parametric-analysis-plots/')
    filename <- paste0(x$path, 'ParametricAnalysis.xlsx')
    
    sdat <- winsor_mod$wdat
    if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
      cat('\n... removing ids c(', extra_rmids[[dv]], ') from: ', dv, ' by ', x$iv, '\n')
      sdat <- sdat[!sdat$UserID %in% extra_rmids[[dv]],]
    }
    
    result <- do_parametric_test(sdat, wid = "UserID", dv = dv, iv = x$iv, between = c(x$iv, "CLRole"), cstratify = c("CLRole"))
    write_plots_for_parametric_test(
      result, ylab = "logit", title = x$title
      , path = path, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    write_parametric_test_report(
      result, ylab = "logit", title = x$title
      , filename = filename, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

#############################################################################
## Translate latex resume                                                  ##
#############################################################################

write_winsorized_in_latex(
  winsor_mod$diff_dat
  , filename = "report/latex/wisorized-intrinsic-motivation.tex"
  , in_title = paste("for the latent trait estimates by",
                     "the RSM-based instrument for measuring"
                     ,"intrinsic motivation in the first empirical study")
)

lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  parametric_results <- all_parametric_results[[dv]]
  ##
  write_param_statistics_analysis_in_latex(
    parametric_results, ivs = names(info)
    , filename = paste0("report/latex/parametric-", sources[[dv]]$folder, "-analysis.tex")
    , in_title = paste0(" for the latent trait estimates of ", dv, " in the first empirical study")
  )
})

