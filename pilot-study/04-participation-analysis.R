wants <- c('car', 'afex', 'stats', 'dplyr', 'readr', 'r2excel', 'Hmisc')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

library(car)
library(afex)
library(stats)
library(dplyr)
library(readr)
library(Hmisc)
library(r2excel)

############################################################################
## Getting Percentages of Participation Analysis                          ##
############################################################################

activity <- read_csv("data/CLActivity.csv")

sdat <- merge(cast(activity, Group ~ Type), cast(activity, Group ~ ParticipationLevel))
sdat <- dplyr::mutate(sdat, Type = if_else(`non-gamified` > 0, 'non-gamified', 'ont-gamified'))
sdat <- dplyr::mutate(sdat, `N` = `non-gamified`+`ont-gamified`)
sdat <- dplyr::mutate(sdat, `PctComplete` = complete/N)
sdat <- dplyr::mutate(sdat, `PctSemiComplete` = semicomplete/N)
sdat <- dplyr::mutate(sdat, `PctIncomplete` = incomplete/N)
sdat <- dplyr::mutate(sdat, `PctNone` = none/N)


having_participation_dat <- data.frame(
  "id" = 1:(3*length(sdat$Group)), "Group" = rep(sdat$Group, 3)
  , "Type" = rep(sdat$Type, 3)
  , "LevelParticipation" = rep(c("complete", "semicomplete", "incomplete"), c(rep(length(sdat$Group),3)))
  , "PctHavingParticipation" = c(sdat$PctComplete, sdat$PctSemiComplete, sdat$PctIncomplete))
having_participation_dat <- having_participation_dat[
  which(having_participation_dat$PctHavingParticipation != 0),]

adequate_participation_dat <- data.frame(
  "id" = 1:(2*length(sdat$Group)), "Group" = rep(sdat$Group, 2)
  , "Type" = rep(sdat$Type, 2)
  , "LevelParticipation" = rep(c("complete", "semicomplete"), c(rep(length(sdat$Group),2)))
  , "PctAdequateParticipation" = c(sdat$PctComplete, sdat$PctSemiComplete))
adequate_participation_dat <- adequate_participation_dat[
  which(adequate_participation_dat$PctAdequateParticipation != 0),]

incomplete_participation_dat <- data.frame(
  "id" = 1:(2*length(sdat$Group)), "Group" = rep(sdat$Group, 2)
  , "Type" = rep(sdat$Type, 2)
  , "LevelParticipation" = rep(c("incomplete", "none"), c(rep(length(sdat$Group),2)))
  , "PctIncompleteParticipation" = c(sdat$PctIncomplete, sdat$PctNone))
incomplete_participation_dat <- incomplete_participation_dat[
  which(incomplete_participation_dat$PctIncompleteParticipation != 0),]

without_participation_dat <- data.frame(
  "id" = 1:length(sdat$Group), "Group" = sdat$Group
  , "Type" = sdat$Type
  , "LevelParticipation" = rep(c("none"), length(sdat$Group))
  , "PctWithoutParticipation" = sdat$PctNone)
without_participation_dat <- without_participation_dat[
  which(without_participation_dat$PctWithoutParticipation != 0),]

##
sources <- list(
  "PctHavingParticipation" = list(
    dv = "PctHavingParticipation"
    , dat = having_participation_dat
    , title = "Pct Having Participation"
    , folder = "having-participation"
  )
  , "PctAdequateParticipation" = list(
    dv = "PctAdequateParticipation"
    , dat = adequate_participation_dat
    , title = "Pct Having Adequate Participation"
    , folder = "adequate-participation"
  )
  , "PctIncompleteParticipation" = list(
    dv = "PctIncompleteParticipation"
    , dat = incomplete_participation_dat
    , title = "Pct Having Incomplete Participation"
    , folder = "incomplete-participation"
  )
  , "PctWithoutParticipation" = list(
    dv = "PctWithoutParticipation"
    , dat = without_participation_dat
    , title = "Pct Without Participation"
    , folder = "without-participation"
  )
)


#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
nonparametric_results <- lapply(sources, FUN = function(x) {
  cat("\n .... processing: ", x$title, " ....\n")
  
  dir.create(paste0("report/participation/",x$folder), showWarnings = F)
  path <- paste0('report/participation/',x$folder,'/nonparametric-analysis-plots/')
  dir.create(path, showWarnings = F)
  
  filename <- paste0('report/participation/',x$folder,'/NonParametricAnalysis.xlsx')
  result <- do_nonparametric_test(dat = x$dat, dv = x$dv, wid = "id", iv = 'Type', between = c('Type'))
  
  write_plots_for_nonparametric_test(
    result, ylab = "Pct", title = x$title, path = path
    , override = T, ylim = NULL, levels = c('non-gamified','ont-gamified')
  )
  write_nonparametric_test_report(
    result, ylab = "Pct", title = x$title, filename = filename
    , override = T, ylim = NULL, levels = c('non-gamified','ont-gamified')
  )
  return(result)
})

## latex transaltion
list_dvs <- as.list(names(sources))
names(list_dvs) <- names(sources)
write_nonparam_statistics_analysis_in_latex(
  filename = paste0("report/latex/nonparametric-participation.tex")
  , nonparametric_results
  , dvs = list_dvs
)

