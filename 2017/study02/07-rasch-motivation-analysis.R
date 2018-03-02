
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)

sources <- list(
  "Attention" = list(
    filename = "data/Attention.csv", name = "Attention"
    , rm.out = TRUE
    , extra_rmids = c(), folder = "attention"
  )
  , "Satisfaction" = list(
    filename = "data/Satisfaction.csv", name = "Satisfaction"
    , rm.out = TRUE
    , extra_rmids = c(10209, 10175,10216), folder = "satisfaction" # ,10211,10193,10223
  )
  , "Level of Motivation" = list(
    filename = "data/LevelMotivation.csv", name = "Level of Motivation"
    , rm.out = TRUE
    , extra_rmids = c(10209, 10175), folder = "level-of-motivation" # 10209,10175
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
  colnames(dat)[7] <- x$name
  
  rdat <- dat
  rmids <- c()
  if (!is.null(x$extra_rmids) && length(x$extra_rmids) > 0) {
    rmids <- x$extra_rmids
    rdat <- rdat[!rdat[['UserID']] %in% rmids,]
  }
  
  if (x$rm.out) {
    outlier_ids <- get_ids_outliers_for_anova(rdat, "UserID", x$name, "Type", between = c("Type", "CLRole"))
    if (!is.null(outlier_ids) && length(outlier_ids) > 0) {
      rmids <- unique(c(rmids, outlier_ids))
      rdat <- rdat[!rdat[['UserID']] %in% rmids,]
    }
  }
  
  cat('\n...removing ids: ', rmids,' from: ', x$name , ' ...\n')
  return(list(data = rdat, name = x$name))
})


anova_result_mods <- lapply(dat_map, FUN = function(x) {
  
  anova_result <- do_anova(
    x$data, wid = 'UserID', dv = x$name, iv = 'Type'
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
  
  path <- paste0('report/motivation/', sources[[aov_name]]$folder, '/anova-analysis-plots/')
  filename <- paste0('report/motivation/', sources[[aov_name]]$folder, '/MeasurementAnovaAnalysis.xlsx')
  
  ##
  write_anova_analysis_report(
    anova_result
    , ylab = "logits"
    , title = sources[[aov_name]]$name
    , filename = filename
    , override = TRUE
  )
  write_anova_plots(
    anova_result
    , ylab = "logits"
    , title = sources[[aov_name]]$name
    , path = path
    , override = TRUE
  )
}
