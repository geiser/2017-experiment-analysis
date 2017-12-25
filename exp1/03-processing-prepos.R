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
## PreTest and PosTest for Case01                                       ##
##########################################################################

participants <- read_csv('case01/data/Participant.csv')

pre_dat <- read_excel("data/SourceMoodle-VPL.xlsx", sheet = "PretestData", col_types = "numeric")
pre_dat <- abs(pre_dat)
pre_dat[is.na(pre_dat)] <- 0
pre_dat <- pre_dat[,!colnames(pre_dat) %in% c('Type','CLGroup','CLRole','PlayerRole')]

pre_dat <- score_programming_tasks(
  dat = pre_dat
  , nview_str = 'nview', apxt_str = 'apxt', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4"))
pre_dat <- merge(participants, pre_dat, by = 'UserID')
pre_dat <- pre_dat[which(pre_dat$nviewP1>0),]

pos_dat <- read_excel("data/SourceMoodle-VPL.xlsx", sheet = "PostestData", col_types = "numeric")
pos_dat <- abs(pos_dat)
pos_dat[is.na(pos_dat)] <- 0
pos_dat <- pos_dat[,!colnames(pos_dat) %in% c('Type','CLGroup','CLRole','PlayerRole')]

pos_dat <- score_programming_tasks(
  dat = pos_dat
  , nview_str = 'nview', apxt_str = 'apxt', def_non_view_score = -1
  , keys = c("PA","PB","PC","PD"))
pos_dat <- merge(participants, pos_dat, by = 'UserID')
pos_dat <- pos_dat[which(pos_dat$nviewPA>0),]

userids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

if (!file.exists('case01/data/SourcePreTestVPL.csv')) write_csv(pre_dat, path = 'case01/data/SourcePreTestVPL.csv')
if (!file.exists('case01/data/SourcePosTestVPL.csv')) write_csv(pos_dat, path = 'case01/data/SourcePosTestVPL.csv')

