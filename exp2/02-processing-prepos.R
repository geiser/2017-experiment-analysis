library(readr)
library(dplyr)
library(readxl)

## functions to calculate greatest common divisor and least common multiple
GCD <- function(u, v) { ifelse(u %% v != 0, return(GCD(v, (u%%v))), return(v)) }
LCM <- function(u, v) { return(abs(u*v)/GCD(u, v)) }

## function to get simplified score test
get_simplified_score_test <- function(dat, col_names = NULL) {
  s_dat <- dat
  if (is.null(col_names)) col_names <- colnames(s_dat)
  n_lcm <- 1
  for (c_name in col_names) {
    n_lcm <- LCM(n_lcm, max(s_dat[c_name], na.rm = T))
  }
  for (c_name in col_names) {
    s_dat[,c_name] <- s_dat[,c_name]*(n_lcm/max(s_dat[c_name], na.rm = T))
  }
  return(s_dat)
}

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

##########################################################################
## Information from VPL                                                 ##
##########################################################################

## pre-procesing VPL data
vpl_leg <- read_excel("data/LearningData02.xlsx", sheet = "legend-VPL")

vpl_dat <- read_excel("data/LearningData02.xlsx", sheet = "VPLData", col_types = "numeric")
vpl_dat <- abs(vpl_dat)
vpl_dat[is.na(vpl_dat)] <- 0

vpl_dat <- score_programming_tasks(
  dat = vpl_dat
  , nview_str = 'start', apxt_str = 'exat', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4","PA","PB","PC","PD","PE","PF","PG","PH"))

if (!file.exists('data/Legend-VPL.csv')) write_csv(vpl_leg, path = "data/Legend-VPL.csv")
if (!file.exists('data/Moodle-VPL.csv')) write_csv(vpl_dat, path = "data/Moodle-VPL.csv")

##########################################################################
## PreTest and PosTest for Case01                                       ##
##########################################################################

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

if (!file.exists('case01/data/PreTest.csv')) write_csv(pre_dat, path = 'case01/data/PreTest.csv')
if (!file.exists('case01/data/PosTest.csv')) write_csv(pos_dat, path = 'case01/data/PosTest.csv')

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('case01/data/SimplePreTest.csv')) write_csv(simple_pre_dat, path = 'case01/data/SimplePreTest.csv')
if (!file.exists('case01/data/SimplePosTest.csv')) write_csv(simple_pos_dat, path = 'case01/data/SimplePosTest.csv')

##########################################################################
## PreTest and PosTest for Case02                                       ##
##########################################################################

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

if (!file.exists('case02/data/PreTest.csv')) write_csv(pre_dat, path = 'case02/data/PreTest.csv')
if (!file.exists('case02/data/PosTest.csv')) write_csv(pos_dat, path = 'case02/data/PosTest.csv')

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('case02/data/SimplePreTest.csv')) write_csv(simple_pre_dat, path = 'case02/data/SimplePreTest.csv')
if (!file.exists('case02/data/SimplePosTest.csv')) write_csv(simple_pos_dat, path = 'case02/data/SimplePosTest.csv')

##########################################################################
## PreTest and PosTest for Case03                                       ##
##########################################################################

participants <- read_csv('case03/data/Participant.csv')
pre_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha3a-recurs", type = "pre")
pos_dat <- get_programing_amc_test_info(
  participants, source = "data/LearningData02.xlsx", sheet = "provinha3c-recurs", type = "pos")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)

pre_dat <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P4')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

pos_dat <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PF'), starts_with('PG'), starts_with('PH')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

if (!file.exists('case03/data/PreTest.csv')) write_csv(pre_dat, path = 'case03/data/PreTest.csv')
if (!file.exists('case03/data/PosTest.csv')) write_csv(pos_dat, path = 'case03/data/PosTest.csv')

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('case03/data/SimplePreTest.csv')) write_csv(simple_pre_dat, path = 'case03/data/SimplePreTest.csv')
if (!file.exists('case03/data/SimplePosTest.csv')) write_csv(simple_pos_dat, path = 'case03/data/SimplePosTest.csv')
