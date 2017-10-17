library(readr)
library(dplyr)
library(readxl)

## function to get information from a programming test based on AMC
get_programing_amc_test_info <- function(participants, source, sheet, type = 'pre', other_sheet = NULL) {
  
  acm_test <- read_excel(source, sheet = sheet, col_types = "numeric")
  if (is.null(other_sheet)) {
    acm_test <- select(
      acm_test, starts_with('NUSP')
      , starts_with('remember'), starts_with('understand')
      , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
  } else {
    acm_test <- select(
      acm_test, starts_with('NUSP')
      , starts_with('remember'), starts_with('understand')
      , starts_with('apply'), starts_with('evaluate'))
  }
  acm_test <- acm_test[complete.cases(acm_test),]
  
  if (!is.null(other_sheet)) {
    rsheet <- read_excel(source, sheet = other_sheet, col_types = "numeric")
    rsheet <- select(rsheet, starts_with('NUSP'), starts_with('analyse'))
    acm_test <- merge(acm_test, rsheet, by='NUSP')
  }
  
  colnames(acm_test) <- sub('remember', 'Re', colnames(acm_test))
  colnames(acm_test) <- sub('understand', 'Un', colnames(acm_test))
  colnames(acm_test) <- sub('apply', 'Ap', colnames(acm_test))
  colnames(acm_test) <- sub('analyse', 'An', colnames(acm_test))
  colnames(acm_test) <- sub('evaluate', 'Ev', colnames(acm_test))
  
  if (type == 'pre') {
    colnames(acm_test) <- sub('-unistructural', '1', colnames(acm_test))
    colnames(acm_test) <- sub('-multistructural', '2', colnames(acm_test))
    colnames(acm_test) <- sub('-relational', '3', colnames(acm_test))
    colnames(acm_test) <- sub('-1', 'a', colnames(acm_test))
    colnames(acm_test) <- sub('-2', 'b', colnames(acm_test))
    colnames(acm_test) <- sub('-3', 'c', colnames(acm_test))
  } else {
    colnames(acm_test) <- sub('-unistructural', 'A', colnames(acm_test))
    colnames(acm_test) <- sub('-multistructural', 'B', colnames(acm_test))
    colnames(acm_test) <- sub('-relational', 'C', colnames(acm_test))
    colnames(acm_test) <- sub('-1', '1', colnames(acm_test))
    colnames(acm_test) <- sub('-2', '2', colnames(acm_test))
    colnames(acm_test) <- sub('-3', '3', colnames(acm_test))
  }
  
  acm_test <- select(
    acm_test, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
    , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
  acm_test <- merge(participants, acm_test, by.x = 'NroUSP', by.y = 'NUSP')
  
  rownames(acm_test) <- acm_test$UserID
  
  return(acm_test)
}

###########################################################################

## pre-procesing VPL data
vpl_leg <- read_excel("data/LearningData02.xlsx", sheet = "legend-VPL")

vpl_dat <- read_excel("data/LearningData02.xlsx", sheet = "VPLData", col_types = "numeric")
vpl_dat <- abs(vpl_dat)
vpl_dat[is.na(vpl_dat)] <- 0

vpl_dat <- score_programming_tasks(
  dat = vpl_dat
  , nview_str = 'start', apxt_str = 'exat', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4","PA","PB","PC","PD","PE","PF","PG","PH"))

write_csv(vpl_leg, path = "data/Legend-VPL.csv")
write_csv(vpl_dat, path = "data/Moodle-VPL.csv")

###########################################################################

## CaseStudy01 - geting pre- and post- data for 
participants <- read_csv('case01/data/Participant.csv')
pre_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha1a-cond-part1"
  , type = "pre", other_sheet = "provinha1a-cond-part2")
pos_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha1b-cond-part1"
  , type = "pos", other_sheet = "provinha1b-cond-part2")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)

pre_dat <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P1')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

pos_dat <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PA'), starts_with('PB')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

pre_dat[,'Cr2'] <- pre_dat[,'P1s0']
pos_dat[,'CrA'] <- pos_dat[,'PAs1']
pos_dat[,'CrB'] <- pos_dat[,'PBs2']

write_csv(pre_dat, path = "case01/data/PreTest.csv")
write_csv(pos_dat, path = "case01/data/PosTest.csv")

pre_dat_unify <- pre_dat
pos_dat_unify <- pos_dat

pre_dat_unify[,'Ap2'] <- pre_dat[,'Ap2']*12
pos_dat_unify[,'ApB'] <- pos_dat[,'ApB']*1

pre_dat_unify[,'Ev2'] <- pre_dat[,'Ev2']*6
pos_dat_unify[,'EvB'] <- pos_dat[,'EvB']*5

pre_dat_unify[,'Ev1'] <- pre_dat[,'Ev1']*1
pos_dat_unify[,'EvA'] <- pos_dat[,'EvA']*2

pre_dat_unify[,'Un2'] <- pre_dat[,'Un2']*2
pos_dat_unify[,'UnB'] <- pos_dat[,'UnB']*3

pre_dat_unify[,'An3'] <- pre_dat[,'An3']*7
pos_dat_unify[,'AnC'] <- pos_dat[,'AnC']*8

write_csv(pre_dat_unify, path = "case01/data/PreTestUnify.csv")
write_csv(pos_dat_unify, path = "case01/data/PosTestUnify.csv")

## CaseStudy02 - geting pre- and post- data for 
participants <- read_csv('case02/data/Participant.csv')
pre_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha2a-loops", type = "pre")
pos_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha2b-loops", type = "pos")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)

pre_dat <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P2'), starts_with('P3')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

pos_dat <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PC'), starts_with('PD'), starts_with('PE')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

write_csv(pre_dat, path = "case02/data/PreTest.csv")
write_csv(pos_dat, path = "case02/data/PosTest.csv")

## CaseStudy03 - geting pre- and post- data for 
participants <- read_csv('case03/data/Participant.csv')
pre_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha3c-recurs", type = "pre")
pos_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha3c-recurs", type = "pos")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)

pre_dat <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P4')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

pos_dat <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PF'), starts_with('PG'), starts_with('PH')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

write_csv(pre_dat, path = "case03/data/PreTest.csv")
write_csv(pos_dat, path = "case03/data/PosTest.csv")

###########################################################################
