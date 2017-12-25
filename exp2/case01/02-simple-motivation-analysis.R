
library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)

dat <- as.data.frame(read_csv('data/IMI.csv'))
dat <- dplyr::mutate(
  dat
  , `Interest/Enjoyment` = (dat$Item12IE+dat$Item24IE+dat$Item01IE
                            +dat$Item09IE+dat$Item22IE+dat$Item21IE)/6
  , `Perceived Choice` = (48+dat$Item23PC+dat$Item05PC
                          -(dat$Item17PC+dat$Item15PC+dat$Item08PC
                            +dat$Item02PC+dat$Item06PC+dat$Item20PC))/8
  , `Pressure/Tension` = (8+dat$Item16PT+dat$Item14PT+dat$Item18PT-dat$Item11PT)/4
)
dat <- dplyr::mutate(
  dat
  , `Intrinsic Motivation` = (6*dat$`Interest/Enjoyment`
                              +8*dat$`Perceived Choice`
                              +32-4*dat$`Pressure/Tension`)/18
)
rownames(dat) <- dat$UserID

dvs <- c('Interest/Enjoyment','Perceived Choice','Pressure/Tension','Intrinsic Motivation')
folders <- c('interest-enjoyment','perceived-choice','pressure-tension','intrinsic-motivation')

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  path <- paste0('report/motivation/', folders[[i]], '/wilcox-analysis-plots/')
  filename <- paste0('report/motivation/', folders[[i]], '/WilcoxAnalysis.xlsx')
  
  set_wt_mods <- get_wilcox_mods(dat, dv = dv, iv = 'Type', between = c('Type', 'CLRole'))
  write_wilcoxon_simple_analysis_report(
    set_wt_mods
    , ylab = "Score"
    , title = dv
    , filename = filename
    , override = TRUE
    , data = dat
  )
  write_wilcoxon_plots(
    set_wt_mods
    , ylab = "Score"
    , title = dv
    , path = path
    , override = TRUE
  )
}

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

rmids <- list()
rdats <- list()
extra_rmids <- list(
  "Pressure/Tension"=c(10170,10181,10195,10172,10175,10192,10196,10197,10200
                       ,10198,10204,10209,10213,10215,10217,10219,10220
                       ,10221,10231,10237,10240,10171 ,10174,10191,10193
                       ,10203 ,10202))

## remove outliers
for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  rmids[[dv]] <- c()
  
  rdat <- dat
  if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
    rmids[[dv]] <- extra_rmids[[dv]]
    rdat <- rdat[!rdat[['UserID']] %in% rmids[[dv]],]
  }
  
  outlier_ids <- get_ids_outliers_for_anova(rdat, 'UserID', dv, iv = 'Type', between = c('Type', 'CLRole'))
  if (!is.null(outlier_ids) && length(outlier_ids) > 0) {
    rmids[[dv]] <- unique(c(rmids[[dv]], outlier_ids))
    rdat <- rdat[!rdat[['UserID']] %in% rmids[[dv]],]
  }
  
  rdats[[dv]] <- rdat
  cat('\n...removing ids: ', rmids[[dv]],' from: ', dv, ' ...\n')
}

for (dv in dvs) {
  anova_result <- do_anova(
    rdats[[dv]], wid = 'UserID', dv = dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  if (anova_result$min.sample.size.fail) {
    cat('\n... minimun sample size is not satisfied for the group: ', dv, '\n')
  }
  if (anova_result$assumptions.fail) {
    cat('\n... assumptions fail in normality or equality for the group: ', dv, '\n')
    print(anova_result$test.min.size$error.warning.list)
    if (anova_result$normality.fail) {
      cat('\n... normality fail ...\n')
      normPlot(rdats[[dv]], dv)
    }
    if (anova_result$homogeneity.fail) {
      cat('\n... homogeneity fail ...\n')
      plot_anova_assumptions(anova_result, dv)
    }
  }
}

## writing report
for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  path <- paste0('report/motivation/', folders[[i]], '/anova-analysis-plots/')
  filename <- paste0('report/motivation/', folders[[i]], '/AnovaAnalysis.xlsx')
  
  anova_result <- do_anova(
    dat = rdats[[dv]], wid = 'UserID', dv = dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  
  ##
  write_anova_analysis_report(
    anova_result
    , ylab = "Score"
    , title = dv
    , filename = filename
    , override = TRUE
  )
  write_anova_plots(
    anova_result
    , ylab = "Score"
    , title = dv
    , path = path
    , override = TRUE
  )
}

#bx<-boxplot(rdats$`Pressure/Tension`$`Pressure/Tension`[rdats$`Pressure/Tension`$Type=="non-gamified" & rdats$`Pressure/Tension`$CLRole=="Master"])
#(uid <- rdats$`Pressure/Tension`$UserID[rdats$`Pressure/Tension`$`Pressure/Tension` %in% bx$out])
#rdats$`Pressure/Tension`[rdats$`Pressure/Tension`$UserID %in% uid,]

