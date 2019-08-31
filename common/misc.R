## total score from guttman table
total_score_from_guttman <- function(dat, col_id="UserID", col_score = "score", from_cols = NULL) {
  if (is.null(from_cols)) {
    from_cols <- colnames(dat)[!colnames(dat) %in% c(col_id)]
  }
  dat <- dat[, c(col_id, from_cols)]
  result <- dat[!complete.cases(dat),]
  to_add <- c()
  if (length(from_cols) > 1){
    for (i in 1:nrow(result)) {
      for (j in 1:ncol(result)) {
        if (is.na(result[[i,j]]) && !is.na(result[[i,j-1]])) {
          if (all(is.na(result[i,j:ncol(result)]))) {
            to_add <- c(to_add, i)
          }
          break;
        }
      }
    }
  }
  result <- rbind(dat[complete.cases(dat),], result[to_add,])
  result[is.na(result)] <- 0
  result[[col_score]] <- rowSums(result[,c(-1)])
  return(result)
}


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

## function to round only numeric values in dataframe
round_df <- function(df, digits) {
  nums <- vapply(df, is.numeric, FUN.VALUE = logical(1))
  
  df[,nums] <- round(df[,nums], digits = digits)
  
  (df)
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
score_programming_tasks = function(dat, keys, corr_str = 'corr', nview_str = 'nview', apxt_str = 'apxt', def_non_view_score = -1) {
  
  library(dplyr)
  
  for (k in keys) {
    apxt<-paste0(apxt_str, k)
    corr<-paste0(corr_str, k)
    nview<-paste0(nview_str, k)
    
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, 1, 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s0")
    
    dat_time <- dat[[apxt]][!is.na(dat[[apxt]]) & dat[[nview]]>0 & dat[[corr]]>7.5 & dat[[apxt]]>0]
    dat_time <- dat_time[!dat_time %in% boxplot.stats(dat_time)$out]
    
    T1<-median(dat_time, na.rm = T)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T1, 2, 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s1")
    
    T2<-quantile(dat_time, probs=.67, names=FALSE, na.rm = T)
    T1<-quantile(dat_time, probs=.33, names=FALSE, na.rm = T)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T2, if_else(dat[[apxt]]<T1, 3, 2), 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s2")
    
    T3<-quantile(dat_time, probs=.75, names=FALSE, na.rm = T)
    T2<-quantile(dat_time, probs=.5, names=FALSE, na.rm = T)
    T1<-quantile(dat_time, probs=.25, names=FALSE, na.rm = T)
    dat<-mutate(dat, score=if_else(dat[[nview]]>0, if_else(dat[[corr]]>7.5, if_else(dat[[apxt]]<T3, if_else(dat[[apxt]]<T2, if_else(dat[[apxt]]<T1, 4, 3), 2), 1), 0), def_non_view_score))
    colnames(dat)[which(names(dat) == "score")]<-paste0(k, "s3")
  }
  dat[dat==-1] <- NA # replace -1 values for NA
  return(dat)
}

## function to get information from a programming test based on AMC
get_amc_test_info <- function(participants, source, sheet, type = 'pre', other_sheet = NULL, extra_fields = c()) {
  
  acm_test <- read_excel(source, sheet = sheet, col_types = "numeric")
  acm_test <- acm_test[!is.na(acm_test[['NUSP']]) & !is.na(acm_test[['score']]) & !is.na(acm_test[['max']]),]
  
  if (is.null(other_sheet)) {
    acm_test <- merge(select(
      acm_test, starts_with('NUSP')
      , starts_with('remember'), starts_with('understand')
      , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
      , acm_test[,c('NUSP',extra_fields)])
  } else {
    acm_test <- merge(select(
      acm_test, starts_with('NUSP')
      , starts_with('remember'), starts_with('understand')
      , starts_with('apply'), starts_with('evaluate'))
      , acm_test[,c('NUSP',extra_fields)])
  }
  
  if (!is.null(other_sheet)) {
    rsheet <- read_excel(source, sheet = other_sheet, col_types = "numeric")
    rsheet <- merge(select(rsheet, starts_with('NUSP'), starts_with('analyse'))
                    , rsheet[,c('NUSP', extra_fields)])
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
  
  to_return <- select(
    acm_test, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
    , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
  if (!is.null(other_sheet)) {
    for (cname in extra_fields) {
      x <- acm_test[[paste0(cname,'.x')]]
      y <- acm_test[[paste0(cname,'.y')]]
      x[is.na(x)] <- 0; y[is.na(y)] <- 0
      to_return[[cname]] <- x+y
    }
  } else {
    if (length(extra_fields)>0) to_return <- merge(to_return, acm_test[,c('NUSP', extra_fields)])
  }
  
  to_return <- merge(participants, to_return, by.x = 'NroUSP', by.y = 'NUSP')
  
  rownames(to_return) <- to_return$UserID
  
  return(to_return)
}

