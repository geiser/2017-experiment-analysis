
library(car) 
library(afex)
library(stats)
library(dplyr)
library(readr)

datIMI <- read_csv('data/IMI.csv')
datIMMS <- read_csv("data/IMMS.csv")

dat <- merge(datIMI, datIMMS)
dat <- dplyr::mutate(
  dat
  , `Interest/Enjoyment` = (dat$Item08IE+dat$Item09IE+dat$Item11IE
                            +dat$Item12IE+dat$Item21IE+dat$Item24IE)/6
  , `Perceived Choice` = (40-(dat$Item03PC+dat$Item05PC+dat$Item13PC
                              +dat$Item18PC+dat$Item20PC))/5
  , `Pressure/Tension` = (dat$Item02PT+dat$Item04PT+dat$Item06PT+8-dat$Item23PT)/4
  , `Effort/Importance` = (dat$Item14EI+dat$Item22EI+16-(dat$Item01EI+dat$Item19EI))/4
  , `Attention` = (dat$Item18A+dat$Item25A+dat$Item20A+dat$Item07A+dat$Item13A)/5
  , `Satisfaction` = (dat$Item01S+dat$Item02S+dat$Item05S+8-dat$Item21S)/4
)
dat <- dplyr::mutate(
  dat
  , `Intrinsic Motivation` = (6*dat$`Interest/Enjoyment`
                              +5*dat$`Perceived Choice`
                              +4*dat$`Effort/Importance`
                              +32-4*dat$`Pressure/Tension`)/19
  , `Level of Motivation` = (dat$Attention*5+dat$Satisfaction*4)/9
)
rownames(dat) <- dat$UserID

dvs <- c('Interest/Enjoyment', 'Perceived Choice', 'Pressure/Tension'
         , 'Effort/Importance', 'Attention', 'Satisfaction', 'Intrinsic Motivation', 'Level of Motivation')
folders <- c('interest-enjoyment', 'perceived-choice', 'pressure-tension'
             , 'effort-importance', 'attention', 'satisfaction', 'intrinsic-motivation', 'level-of-motivation')

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
    , override = FALSE
  )
  write_wilcoxon_plots(
    set_wt_mods
    , ylab = "Score"
    , title = dv
    , path = path
    , override = FALSE
  )
}

#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################

rmids <- list()
rdats <- list()
extra_rmids <- list('Interest/Enjoyment'=c(10234,10219,10204))
## remove outliers
for (i in 1:length(dvs)) {
  dv <- dvs[[i]]
  rmids[[dv]] <- get_ids_outliers_for_anova(
    dat, 'UserID', dv, iv = 'Type', between = c('Type', 'CLRole'))
  if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
    rmids[[dv]] <- unique(c(rmids[[dv]], extra_rmids[[dv]]))
  }
  cat('\n...removing ids: ', rmids[[dv]],' from: ', dv, ' ...\n')
  rdats[[dv]] <- dat[!dat[['UserID']] %in% rmids[[dv]],]
}

for (dv in dvs) {
  anova_result <- do_anova(
    rdats[[dv]], wid = 'UserID', dv = dv, iv = 'Type'
    , between = c('Type', 'CLRole'), observed = c('CLRole'))
  if (anova_result$min.sample.size.fail) {
    cat('\n... minimun sample size is not satisfied for the group: ', dv, '\n')
  }
  if (!anova_result$min.sample.size.fail && anova_result$assumptions.fail) {
    cat('\n... assumptions fail in normality or equality for the group: ', dv, '\n')
    print(anova_result$test.min.size$error.warning.list)
    if (anova_result$normality.fail) cat('\n... normality fail ...\n')
    if (anova_result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    plot_anova_assumptions(anova_result, dv)
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



