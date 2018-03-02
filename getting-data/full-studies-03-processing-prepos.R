wants <- c('readr', 'dplyr', 'readxl')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(readr)
library(dplyr)
library(readxl)

## functions to calculate greatest common divisor and least common multiple
GCD <- function(u, v) {
  if (u %% v != 0) {
    return(GCD(v, (u%%v)))
  } else {
    return(v)
  }
}
LCM <- function(u, v) {
  return(abs(u*v)/GCD(u, v))
}

## function to get simplified score test
get_simplified_score_test <- function(dat, col_names = NULL) {
  s_dat <- dat
  if (is.null(col_names)) {
    col_names <- colnames(s_dat)
  }
  n_lcm <- 1
  for (c_name in col_names) {
    n_lcm <- LCM(n_lcm, max(s_dat[c_name], na.rm = T))
  }
  
  for (c_name in col_names) {
    #s_dat[,c_name] <- s_dat[,c_name]*(n_lcm/max(s_dat[c_name], na.rm = T))
    s_dat[,c_name] <- s_dat[,c_name]/max(s_dat[c_name], na.rm = T)
  }
  return(s_dat)
}

#############################################################################

## function to get information from a programming test based on AMC
get_amc_test_info <- function(participants, source, sheet, type = 'pre', other_sheet = NULL) {
  
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


## score programming tasks
score_programming_tasks = function(dat, keys, corr_str = 'corr', nview_str = 'nview', apxt_str = 'apxt', def_non_view_score = 0) {
  
  library(dplyr)
  
  for (k in keys) {
    apxt<-paste0(apxt_str, k)
    corr<-paste0(corr_str, k)
    nview<-paste0(nview_str, k)
    
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, 1, 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s0")
    
    dat_time <- dat[[apxt]][!is.na(dat[[apxt]]) & dat[[nview]]>0 & dat[[corr]]>7.5 & dat[[apxt]]>0]
    dat_time <- dat_time[!dat_time %in% boxplot.stats(dat_time)$out]
    
    T1<-median(dat_time)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T1, 2, 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s1")
    
    T2<-quantile(dat_time, probs=.67, names=FALSE)
    T1<-quantile(dat_time, probs=.33, names=FALSE)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T2, if_else(dat[[apxt]]<T1, 3, 2), 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s2")
    
    T3<-quantile(dat_time, probs=.75, names=FALSE)
    T2<-quantile(dat_time, probs=.5, names=FALSE)
    T1<-quantile(dat_time, probs=.25, names=FALSE)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T3, if_else(dat[[apxt]]<T2, if_else(dat[[apxt]]<T1, 4, 3), 2), 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s3")
  }
  dat[dat==-1] <- NA # replace -1 values for NA
  return(dat)
}

##########################################################################
## Information from VPL                                                 ##
##########################################################################

## pre-procesing VPL data
vpl_leg <- read_excel("data/SourcePrePostData.xlsx", sheet = "legend-VPL")

vpl_dat <- read_excel("data/SourcePrePostData.xlsx", sheet = "VPLData", col_types = "numeric")
vpl_dat <- abs(vpl_dat)
vpl_dat[is.na(vpl_dat)] <- 0

vpl_dat <- score_programming_tasks(
  dat = vpl_dat
  , nview_str = 'start', apxt_str = 'exat', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4","PA","PB","PC","PD","PE","PF","PG","PH"))

if (!file.exists('data/Legend-VPL.csv')) {
  write_csv(vpl_leg, path = "data/Legend-VPL.csv")
}
if (!file.exists('data/SourceMoodle-VPL.csv')) {
  write_csv(vpl_dat, path = "data/SourceMoodle-VPL.csv")
}

##########################################################################
## PreTest and PosTest for Study01                                      ##
##########################################################################

participants <- read_csv('study01/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha1a-cond-part1"
  , type = "pre", other_sheet = "provinha1a-cond-part2")
pos_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha1b-cond-part1"
  , type = "pos", other_sheet = "provinha1b-cond-part2")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

if (!file.exists('study01/data/SourcePreTest.csv')) {
  write_csv(pre_dat, path = 'study01/data/SourcePreTest.csv')
}
if (!file.exists('study01/data/SourcePosTest.csv')) {
  write_csv(pos_dat, path = 'study01/data/SourcePosTest.csv')
}

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('study01/data/SimplifiedPreTest.csv')) {
  write_csv(simple_pre_dat, path = 'study01/data/SimplifiedPreTest.csv')
}
if (!file.exists('study01/data/SimplifiedPosTest.csv')) {
  write_csv(simple_pos_dat, path = 'study01/data/SimplifiedPosTest.csv')
}

pre_dat_with_vpl <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P1')), by='UserID')
rownames(pre_dat_with_vpl) <- pre_dat_with_vpl$UserID
pre_dat_with_vpl <- pre_dat_with_vpl[pre_dat_with_vpl$UserID %in% userids,]

pos_dat_with_vpl <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PB')), by='UserID')
rownames(pos_dat_with_vpl) <- pos_dat_with_vpl$UserID
pos_dat_with_vpl <- pos_dat_with_vpl[pos_dat_with_vpl$UserID %in% userids,]

if (!file.exists('study01/data/SourcePreTestWithVPL.csv')) {
  write_csv(pre_dat_with_vpl, path = 'study01/data/SourcePreTestWithVPL.csv')
} 
if (!file.exists('study01/data/SourcePosTestWithVPL.csv')) {
  write_csv(pos_dat_with_vpl, path = 'study01/data/SourcePosTestWithVPL.csv')
}

##########################################################################
## PreTest and PosTest for Study02                                      ##
##########################################################################

participants <- read_csv('study02/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha2a-loops"
  , type = "pre")
pos_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha2b-loops"
  , type = "pos")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

if (!file.exists('study02/data/SourcePreTest.csv')) {
  write_csv(pre_dat, path = 'study02/data/SourcePreTest.csv')
}
if (!file.exists('study02/data/SourcePosTest.csv')) {
  write_csv(pos_dat, path = 'study02/data/SourcePosTest.csv')
}

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('study02/data/SimplifiedPreTest.csv')) {
  write_csv(simple_pre_dat, path = 'study02/data/SimplifiedPreTest.csv')
}
if (!file.exists('study02/data/SimplifiedPosTest.csv')) {
  write_csv(simple_pos_dat, path = 'study02/data/SimplifiedPosTest.csv')
}

pre_dat_with_vpl <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P2'), starts_with('P3')), by='UserID')
rownames(pre_dat_with_vpl) <- pre_dat_with_vpl$UserID
pre_dat_with_vpl <- pre_dat_with_vpl[pre_dat_with_vpl$UserID %in% userids,]

pos_dat_with_vpl <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PC'), starts_with('PD')), by='UserID')
rownames(pos_dat_with_vpl) <- pos_dat_with_vpl$UserID
pos_dat_with_vpl <- pos_dat_with_vpl[pos_dat_with_vpl$UserID %in% userids,]

if (!file.exists('study02/data/SourcePreTestWithVPL.csv')) {
  write_csv(pre_dat_with_vpl, path = 'study02/data/SourcePreTestWithVPL.csv')
}
if (!file.exists('study02/data/SourcePosTestWithVPL.csv')) {
  write_csv(pos_dat_with_vpl, path = 'study02/data/SourcePosTestWithVPL.csv')
}

##########################################################################
## PreTest and PosTest for Study03                                      ##
##########################################################################

participants <- read_csv('study03/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha3a-recurs"
  , type = "pre")
pos_dat <- get_amc_test_info(
  participants, source = "data/SourcePrePostData.xlsx", sheet = "provinha3c-recurs"
  , type = "pos")
userids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

if (!file.exists('study03/data/SourcePreTest.csv')) {
  write_csv(pre_dat, path = 'study03/data/SourcePreTest.csv')
}
if (!file.exists('study03/data/SourcePosTest.csv')) {
  write_csv(pos_dat, path = 'study03/data/SourcePosTest.csv')
}

## simplified data to have the same scores
col_names_pre <- c('UserID', colnames(pre_dat)[!colnames(pre_dat) %in% colnames(participants)])
col_names_pos <- c('UserID', colnames(pos_dat)[!colnames(pos_dat) %in% colnames(participants)])
simple_dat <- merge(pre_dat[col_names_pre], pos_dat[col_names_pos], by = 'UserID')

col_names <- union(col_names_pre, col_names_pos)
col_names <- col_names[!col_names %in% c('UserID')]
simple_dat <- get_simplified_score_test(simple_dat, col_names)

simple_pre_dat <- merge(participants, simple_dat[col_names_pre], by = 'UserID')
simple_pos_dat <- merge(participants, simple_dat[col_names_pos], by = 'UserID')

if (!file.exists('study03/data/SimplifiedPreTest.csv')) {
  write_csv(simple_pre_dat, path = 'study03/data/SimplifiedPreTest.csv')
}
if (!file.exists('study03/data/SimplifiedPosTest.csv')) {
  write_csv(simple_pos_dat, path = 'study03/data/SimplifiedPosTest.csv')
}

pre_dat_with_vpl <- merge(pre_dat, select(vpl_dat, starts_with('UserID'), starts_with('P4')), by='UserID')
rownames(pre_dat_with_vpl) <- pre_dat_with_vpl$UserID
pre_dat_with_vpl <- pre_dat_with_vpl[pre_dat_with_vpl$UserID %in% userids,]

pos_dat_with_vpl <- merge(pos_dat, select(vpl_dat, starts_with('UserID'), starts_with('PF')), by='UserID')
rownames(pos_dat_with_vpl) <- pos_dat_with_vpl$UserID
pos_dat_with_vpl <- pos_dat_with_vpl[pos_dat_with_vpl$UserID %in% userids,]

if (!file.exists('study03/data/SourcePreTestWithVPL.csv')) {
  write_csv(pre_dat_with_vpl, path = 'study03/data/SourcePreTestWithVPL.csv')
}
if (!file.exists('study03/data/SourcePosTestWithVPL.csv')) {
  write_csv(pos_dat_with_vpl, path = 'study03/data/SourcePosTestWithVPL.csv')
}

