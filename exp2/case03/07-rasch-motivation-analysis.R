
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)

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
  , "Attention" = list(
    filename = "data/Attention.csv", name = "Attention"
    , extra_rmids = c(), folder = "attention"
  )
  , "Satisfaction" = list(
    filename = "data/Satisfaction.csv", name = "Satisfaction"
    , extra_rmids = c(), folder = "satisfaction"
  )
  , "Level of Motivation" = list(
    filename = "data/LevelMotivation.csv", name = "Level of Motivation"
    , extra_rmids = c(), folder = "level-of-motivation"
  )
)

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

## remove outliers
dat_map <- lapply(sources, FUN = function(x) {
  library(readr)
  
  dat <- as.data.frame(read_csv(x$filename))
  rownames(dat) <- dat$UserID
  
  rmids <- get_ids_outliers_for_anova(dat, "UserID", "theta", "Type", between = c("Type", "CLRole"))
  if (!is.null(x$extra_rmids) && length(x$extra_rmids) > 0) {
    rmids <- unique(c(rmids, x$extra_rmids))
  }
  
  cat('\n...removing ids: ', rmids,' from: ', x$name , ' ...\n')
  rdat <- dat[!dat[['UserID']] %in% rmids,]
  
  return(list(data = rdat, name = x$name))
})


anova_result_mods <- lapply(dat_map, FUN = function(x) {
  
  anova_result <- do_anova(
    x$data, wid = 'UserID', dv = 'theta', iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  if (anova_result$min.sample.size.fail) {
    cat('\n... minimun sample size is not satisfied for the group: ', x$name, '\n')
  }
  if (anova_result$assumptions.fail) {
    cat('\n... assumptions fail in normality or equality for the group: ', x$name, '\n')
    print(anova_result$test.min.size$error.warning.list)
    if (anova_result$normality.fail) cat('\n... normality fail ...\n')
    if (anova_result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    plot_anova_assumptions(anova_result, x$name)
  }
  
  return(anova_result)
})

## writing report
for (aov_name in names(anova_result_mods)) {
  anova_result <- anova_result_mods[[aov_name]]
  
  path <- paste0('report/motivation/', sources[[aov_name]]$folder, '/measurement-anova-analysis-plots/')
  filename <- paste0('report/motivation/', sources[[aov_name]]$folder, '/MeasurementAnovaAnalysis.xlsx')
  
  ##
  write_anova_analysis_report(
    anova_result
    , ylab = "logits"
    , title = sources[[aov_name]]$name
    , filename = filename
    , override = FALSE
  )
  write_anova_plots(
    anova_result
    , ylab = "logits"
    , title = sources[[aov_name]]$name
    , path = path
    , override = TRUE
  )
}
  