
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)

sources <- list(
  "Interest/Enjoyment" = list(
    filename = "data/InterestEnjoyment.csv", name = "Interest/Enjoyment"
    , extra_rmids = c(10200)
    , rm.out = T, folder = "interest-enjoyment"
  )
  , "Perceived Choice" = list(
    filename = "data/PerceivedChoice.csv", name = "Perceived Choice"
    , extra_rmids = c() #c(10198,10199)
    , rm.out = T, folder = "perceived-choice"
  )
  , "Pressure/Tension" = list(
    filename = "data/PressureTension.csv", name = "Pressure/Tension"
    , extra_rmids = c(#10231,10240,10174,10193
                      10210,10170,10172
                      ,10175,10181,10192,10238
                      ,10195,10196,10197,10198,10204
                      ,10240
                      ,10227,10237,10231
                      ,10221,10220
                      ,10222,10200
                      )
    , rm.out = T, folder = "pressure-tension"
  )
  , "Intrinsic Motivation" = list(
    filename = "data/IntrinsicMotivation.csv", name = "Intrinsic Motivation"
    , extra_rmids = c(10175,10204, 10204,  10222,10202,10220,10210 ,10171, 10197,10209,10208,10187 ,10192,10200,10230)
    # , ,10175,10204  ,10240  , 10222,10202,10220,10210) #, 10222, , ,,10171)
    , rm.out = T, folder = "intrinsic-motivation"
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
  }
  if (anova_result$normality.fail) {
    cat('\n... normality fail ...\n')
    normPlot(x$data, dv = x$name)
  }
  if (anova_result$homogeneity.fail) {
    cat('\n... homogeneity fail ...\n')
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

#ddat <- dat_map$`Intrinsic Motivation`$data
#bx <- boxplot(ddat$`Intrinsic Motivation`[ddat$Type=='ont-gamified'])
#ddat$UserID[ddat$`Intrinsic Motivation` %in% bx$out]
