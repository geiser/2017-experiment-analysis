
wants <- c('coin', 'sirt', 'lavaan', 'psych', 'nloptr', 'reshape', 'dplyr'
           , 'readr', 'effsize','pwr', 'afex', 'lme4', 'ez', 'r2excel')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])
#devtools::install_github("singmann/afex@master")

library(afex)


#############################################################################
## Functions to carried out normality test                                 ##
#############################################################################

## get aov_assumption
get_aov_assumption <- function(name, dat, wid, dv, iv, between, observed = NULL
                               , within = NULL, p_limit = 0.05) {
  
  library(car)
  library(afex)
  library(dplyr)
  library(stats)
  library(ez)
  
  ## get wide data
  row_positions <- as.numeric(strsplit(name,"[+]")[[1]])
  wdat <- dat[c(row_positions),]
  columns <- base::unique(c(iv, between, observed))
  for (cname in columns) {
    if (class(wdat[[cname]]) != "numeric") {
      wdat[[cname]] <- factor(wdat[[cname]])
    }
  }
  rownames(wdat) <- wdat[[wid]]
  
  # get module of test mimimun size
  tms_mod <- test_min_size_mod(wdat, iv, between, observed, type = 'parametric')
  if (tms_mod$balanced) type <- 2 else type <- 3
  
  # validate normality
  ezAov <- aov_ez(data = wdat, id = wid, dv = dv, between = between, within = within
                  , observed = observed, type = type, print.formula = F, factorize = F)
  normality.fail <- F
  shapiro_mod <- shapiro.test(ezAov$aov$residuals) # normality
  shapiro_pvalue <- shapiro_mod$p.value
  if (shapiro_pvalue <= p_limit) {
    normality.fail <- T
  }
  
  ## get aov and formula
  formula_str <- paste(paste0('`',dv,'`'), "~", paste(c(between, within), collapse = "*"),
                       if (length(within) > 0) paste0("+Error(", wid, "/(", paste(within, collapse = "*"), "))") else NULL)
  formula_aov <- as.formula(formula_str)
  
  ## homogeneity test
  homogeneity.fail <- F
  levene_mod <- leveneTest(formula_aov, data = wdat) # homogeneity
  levene_pvalue <- levene_mod$`Pr(>F)`[[1]]
  if (levene_pvalue <= p_limit) {
    homogeneity.fail <- T
  }
  
  df.homogeneity.fail <- sapply(base::unique(c(iv, between, observed)), function(x) {
    levene_mod <- leveneTest(as.formula(paste0('`',dv,'`', " ~ ", x)), data = wdat)
    levene_pvalue <- levene_mod$`Pr(>F)`[[1]]
    return(levene_pvalue <= p_limit)
  })
  names(df.homogeneity.fail) <- paste0("homogeneity.fail.",names(df.homogeneity.fail))
  
  return (data.frame(name = name, normality.fail = normality.fail, homogeneity.fail = homogeneity.fail, as.list(df.homogeneity.fail)))
}

generate_file_aov_assumptions <- function(
  i, dat
  , wid="UserID", dv, iv, between = c()
  , path
  , pos_file_aov_assumptions_str = "aov_assumptions.RData"
  , mc.cores = 0) {
  
  if (!file.exists(paste0(path,"/","f_",i,"_",pos_file_aov_assumptions_str))) {
    
    low <- 1
    limit <- RcppAlgos::comboCount(nrow(dat), i)
    
    repeat {
      upp <- low + 1999
      if (upp > limit) { upp <- limit }
      
      #
      cat("\n", "Generating: ", i, " from ", low, " to ", upp, " until to ", limit,"\n")
      file_aov_assumptions_str <- paste0(path,"/",'f_',i,'_',low,'_',upp,'_',pos_file_aov_assumptions_str)
      if (file.exists(file_aov_assumptions_str)) {
        low <- low + 2000
        if (low >= limit) {
          df_assumptions <- do.call(
            rbind
            , lapply(Sys.glob(paste0(path,"/","f_",i,"_*_",pos_file_aov_assumptions_str))
                     , function(file_name) {
                       return(get(load(file_name)))
                     }))
          save(df_assumptions, file = paste0(path,"/","f_",i,"_",pos_file_aov_assumptions_str))
          file.remove(Sys.glob(paste0(path,"/","f_",i,"_*_",pos_file_aov_assumptions_str)))
          break;
        }
        next;
      }
      
      #
      generated_names <- list()
      tindex <- RcppAlgos::comboGeneral(nrow(dat), i, lower = low, upper = upp)
      for (j in 1:nrow(tindex)) {
        nindex <- paste0(c(tindex[j,]), collapse = "+")
        generated_names[[nindex]] <- nindex
      }
      if (!is.null(mc.cores) && mc.cores > 1) {
        library(parallel)
        options(mc.cores=mc.cores)
        result <- do.call(rbind, mclapply(generated_names, get_aov_assumption, dat=dat
                                          , wid=wid, dv=dv, iv=iv, between = between))
      } else {
        result <- do.call(rbind, lapply(generated_names, get_aov_assumption, dat=dat
                                        , wid=wid, dv=dv, iv=iv, between = between))
      }
      save(result, file = file_aov_assumptions_str)
      
      #
      if (upp >= limit) {
        df_assumptions <- do.call(
          rbind
          , lapply(Sys.glob(paste0(path,"/","f_",i,"_*_",pos_file_aov_assumptions_str))
                   , function(file_name) {
                     return(get(load(file_name)))
                   }))
        save(df_assumptions, file = paste0(path,"/","f_",i,"_",pos_file_aov_assumptions_str))
        file.remove(Sys.glob(paste0(path,"/","f_",i,"_*_",pos_file_aov_assumptions_str)))
        break;
      }
      low <- low + 2000
    }
  }
}

get_dataframe_assumptions <- function(dat, dv, iv, between, path, from=nrow(dat)-5, to = nrow(dat), wid="UserID", generate = T, mc.cores = 0) {
  pos_file_aov_assumptions_str = "aov_assumptions.RData"
  
  dir.create(path, showWarnings = F)
  
  ilist <- as.list(c(to:from))
  names(ilist) <- c(from:from)
  
  if (generate) {
    if (!is.null(mc.cores) && mc.cores > 1) {
      library(parallel)
      options(mc.cores=mc.cores)
      mclapply(ilist, generate_file_aov_assumptions, dat
               , wid=wid, dv=dv, iv=iv, between = between, path = path
               , pos_file_aov_assumptions_str = pos_file_aov_assumptions_str)
    } else {
      lapply(ilist, generate_file_aov_assumptions, dat
             , wid=wid, dv=dv, iv=iv, between = between, path = path
             , pos_file_aov_assumptions_str = pos_file_aov_assumptions_str)
    }  
  }
  
  file_list <- c()
  for (k in names(ilist)) {
    file_list <- c(file_list,Sys.glob(paste0(path,"/","f_",k,"_",pos_file_aov_assumptions_str)))
    file_list <- c(file_list,Sys.glob(paste0(path,"/","f_",k,"_*_",pos_file_aov_assumptions_str)))
  }
  df_assumptions <- do.call(
    rbind
    , lapply(file_list, function(file_name) { return(get(load(file_name))) }))
  return(df_assumptions)
}

#############################################################################
## Functions to performs ANOVA and t-test                                  ##
#############################################################################

## Function to get ids for anova
get_winsorized_values <- function(
  dat, wid, dv, iv, between, observed = NULL, only.first.level = T) {
  
  ## wide data and factorize
  wdat <- dat
  columns <- base::unique(c(iv, between, observed))
  for (cname in columns) {
    if (class(wdat[[cname]]) != "numeric") {
      wdat[[cname]] <- factor(wdat[[cname]])
    }
  }
  rownames(wdat) <- wdat[[wid]]
  
  columns <- unique(c(iv, columns[!columns %in% iv]))
  for (m in 1:length(columns)) {
    comb_columns <- combn(columns, m, simplify = T)
    
    for (i in 1:ncol(comb_columns)) {
      selected_columns  <- comb_columns[,i]
      if (selected_columns[[1]] != iv) next
      
      cname <- paste0(selected_columns, collapse = ':')
      factors <- factor(apply(wdat[selected_columns], 1, paste, collapse='.'))
      level_pairs <- combn(levels(factors), 2)
      
      for (j in 1:ncol(level_pairs)) {
        level_pair <- level_pairs[,j]
        rdat2 <- wdat[factors %in% level_pair,]
        
        repeat {
          y <- rdat2[[dv]]
          x <- factors[factors %in% level_pair]
          
          out_x1 <- x[x == level_pair[[1]]]
          out_x2 <- x[x == level_pair[[2]]]
          
          if (length(out_x1) < 3 || length(out_x2) < 3) break
          
          out_yA <- y[x == level_pair[[1]]]
          out_yB <- y[x == level_pair[[2]]]
          
          out_y1 <- robustHD::winsorize(y[x == level_pair[[1]]])
          out_y2 <- robustHD::winsorize(y[x == level_pair[[2]]])
          
          if (any(is.na(out_y1)) || any(is.na(out_y2))) break
          
          idx1 <- round(out_yA,3) != round(out_y1,3)
          idx2 <- round(out_yB,3) != round(out_y2,3)
          
          #
          wids1 <- attributes(out_x1[idx1])$names
          wids2 <- attributes(out_x2[idx2])$names
          if (length(wids1) > 0) {
            for (k in 1:length(wids1)) {
              wid1 <- wids1[[k]]
              wdat[wid1,dv] <- out_y1[idx1][[k]]
            }
          }
          if (length(wids2) > 0) {
            for (k in 1:length(wids2)) {
              wid2 <- wids2[[k]]
              wdat[wid2,dv] <- out_y2[idx2][[k]]
            }
          }
          
          if (only.first.level) break
        }
      }
    }
  }
  
  return(wdat)
}


## Function to get ids for anova
get_ids_outliers <- function(
  dat, wid, dv, iv, between, observed = NULL, only.first.level = T) {
  
  ## wide data and factorize
  wdat <- dat
  columns <- base::unique(c(iv, between, observed))
  for (cname in columns) {
    if (class(wdat[[cname]]) != "numeric") {
      wdat[[cname]] <- factor(wdat[[cname]])
    }
  }
  rownames(wdat) <- wdat[[wid]]
  
  set_rm_ids <- c()
  columns <- unique(c(iv, columns[!columns %in% iv]))
  for (m in 1:length(columns)) {
    comb_columns <- combn(columns, m, simplify = T)
    
    for (i in 1:ncol(comb_columns)) {
      selected_columns  <- comb_columns[,i]
      if (selected_columns[[1]] != iv) next
      
      cname <- paste0(selected_columns, collapse = ':')
      factors <- factor(apply(wdat[selected_columns], 1, paste, collapse='.'))
      level_pairs <- combn(levels(factors), 2)
      
      for (j in 1:ncol(level_pairs)) {
        rm_ids <- c()
        level_pair <- level_pairs[,j]
        rdat2 <- wdat[factors %in% level_pair,]
        
        repeat {
          y <- rdat2[[dv]][!rdat2[[wid]] %in% rm_ids]
          x <- factors[factors %in% level_pair][!rdat2[[wid]] %in% rm_ids]
          
          out_y1 <- boxplot(y[x == level_pair[[1]]], plot = F)$out
          out_y2 <- boxplot(y[x == level_pair[[2]]], plot = F)$out
          out_y <- unique(c(out_y1, out_y2))
          if (length(out_y) == 0) break
          
          rm_ids <- unique(c(rm_ids, rdat2[[wid]][rdat2[[dv]] %in% c(out_y)]))
          
          if (only.first.level) break
        }
        
        set_rm_ids <- c(set_rm_ids, rm_ids)
      }
    }
  }
  
  return(unique(set_rm_ids))
}

## Function to get t.test module
get_t.test_mod <- function(x, y, alternative = "two.sided") {
  
  library(stats)
  library(effsize)
  
  x <- factor(x)
  sdata <- data.frame(x=x, y=y)
  
  # t.test values
  t_mod <- t.test(y ~ x, alternative = alternative, data = sdata)
  df <- as.numeric(t_mod$parameter)
  t_value <- as.numeric(t_mod$statistic)
  pvalue <- t_mod$p.value
  
  numbers <- c(length(x[x==levels(x)[1]]), length(x[x==levels(x)[2]]))
  means <- c(mean(sdata$y[sdata$x == levels(x)[1]]), mean(sdata$y[sdata$x == levels(x)[2]]))
  means_diff <- c(means[1]-means[2], means[2]-means[1])
  std_deviation <- c(sd(sdata$y[sdata$x == levels(x)[1]]), sd(sdata$y[sdata$x == levels(x)[2]]))
  sems <- std_deviation/sqrt(numbers)
  
  effectsize_mod <- effsize::cohen.d(sdata$y[sdata$x == levels(x)[1]], sdata$y[sdata$x == levels(x)[2]], hedges.correction = T)
  magnitudes <- c(as.character(effectsize_mod$magnitude), as.character(effectsize_mod$magnitude))
  
  result <- data.frame(
    "Group" = c(levels(x)[1], levels(x)[2])
    , "N" = numbers
    , "Mean" = means
    , "Mean Difference" = means_diff
    , "Std.deviation" = std_deviation
    , "Std.error" = sems
    , "CI.lower" = c(means-2*sems)
    , "CI.upper" = c(means+2*sems)
    , "df" = c(df, df)
    , "t-value" = c(t_value, t_value)
    , "p-value" = c(pvalue, pvalue)
    , "g" = c(effectsize_mod$estimate, effectsize_mod$estimate)
    , "magnitude" = magnitudes
  )
  
  return(list(data = sdata, result = result))
}

## Funtion to perform test of sample size
test_min_size_mod <- function(data, iv, between, observed, type = 'parametric') {
  
  library(dplyr)
  library(stats)
  
  columns <- base::unique(c(iv, between, observed))
  if (length(columns) <= 1) return(NULL)
  
  tb_size <- xtabs(as.formula(paste0('~', paste0(columns, collapse = '+'))), data = data)
  n_groups <- prod(dim(tb_size))
  
  fail <- FALSE
  balanced <- FALSE
  codes <- c()
  descriptions <- c()
  error_warning_list <- c()
  
  minimal_size <- 5
  recomended_size <- ifelse(n_groups > 10, 20, 15)
  
  tf_size <- as.data.frame(ftable(tb_size))
  if (max(tf_size$Freq) == min(tf_size$Freq)) {
    balanced <- TRUE
  }
  
  for (i in 1:nrow(tf_size)) {
    csize <- tf_size$Freq[i]
    
    name_group <- apply(as.vector(within(tf_size, rm('Freq'))[i,]), 1, paste, collapse =':')
    name_group <- as.character(name_group)
    
    if (csize < minimal_size) {
      fail <- TRUE
      descriptions <- c(descriptions, paste0(
        "current size is ", csize, " but the minimal recomended size is ", minimal_size
        , " for the group: '", name_group, "'."))
      codes <- c(codes, "FAIL: min.size")
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', ", "we recommend the use of non-parametric test."))
    } else if (csize < recomended_size) {
      descriptions <- c(descriptions, paste0(
        "current size is ", csize, " and recommended size is ", recomended_size
        , " for the group: '", name_group, "'."))
      codes <- c(codes, "WARN: sample.size")
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', "
        , "we recommend the use of non-parametric test."))
    } else {
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', "
        , "you can perform a parametric test without having a normal distribution"))
    }
  }
  
  return(list(
    table.frequency = tf_size , fail = fail, balanced = balanced
    , fails.warnings = data.frame("code" = codes, "description" = descriptions)
    , error.warning.list = error_warning_list))
}

## Function to perform the parametric test
do_parametric_test <- function(dat, wid, dv, iv, between, observed = NULL
                               , within = NULL, p_limit = 0.05, completed = F
                               , cstratify = NULL) {
  library(car)
  library(afex)
  library(dplyr)
  library(stats)
  library(ez)
  
  codes <- c()
  descriptions <- c()
  error_warning_list <- c()
  
  ## get wide data
  wdat <- dat
  columns <- base::unique(c(iv, between, observed))
  for (cname in columns) {
    if (class(wdat[[cname]]) != "numeric") {
      wdat[[cname]] <- factor(wdat[[cname]])
    }
  }
  rownames(wdat) <- wdat[[wid]]
  
  # get module of test mimimun size
  tms_mod <- test_min_size_mod(wdat, iv, between, observed, type = 'parametric')
  if (tms_mod$balanced) type <- 2 else type <- 3
  
  ## get aov and formula
  formula_str <- paste(paste0('`',dv,'`'), "~", paste(c(between, within), collapse = "*"),
                       if (length(within) > 0) paste0("+Error(", wid, "/(", paste(within, collapse = "*"), "))") else NULL)
  formula_aov <- as.formula(formula_str)
  plotAov <- aov(formula_aov, data = wdat)
  
  ## get aov and ezAov modules
  ezAov <- aov_ez(data = wdat, id = wid, dv = dv, between = between, within = within
                  , observed = observed, type = type, print.formula = T, factorize = F)
  
  ## get assumptions modules
  normality.fail <- FALSE
  shapiro_mod <- shapiro.test(ezAov$aov$residuals) # normality
  shapiro_pvalue <- shapiro_mod$p.value
  if (shapiro_pvalue <= p_limit) {
    normality.fail <- TRUE
    descriptions <- c(descriptions, 'Null hypothesis of Shapiro test rejected')
    error_warning_list <- c(error_warning_list, 'The null hypothesis "H0: sample is normality distributed" has been rejected - The sample is not normal')
    codes <- c(codes, "FAIL: Shapiro")
    
    ## stratify not necessary if we are using residuals
    # if (!is.null(cstratify) && length(cstratify) > 0) {
    #  normality.fail <- FALSE
    #  normality.fail <- any(sapply(cstratify, FUN = function(sname) {
    #    norm.fails <- sapply(levels(wdat[[sname]]), FUN = function(svalue) {
    #      tdat <- wdat[wdat[[sname]] == svalue,]
    #      tezAov <- aov_ez(data = tdat, id = wid, dv = dv
    #                       , between = between[!between %in% sname]
    #                       , within = within[!within %in% sname]
    #                       , observed = observed[!observed %in% sname]
    #                       , type = type, print.formula = T, factorize = F)
    #      return(shapiro.test(tezAov$aov$residuals)$p.value <= p_limit)
    #    })
    #    return(any(norm.fails))
    #  }))
    #  if (normality.fail) {
    #    descriptions <- c(descriptions, '(Stratify) Null hypothesis of Shapiro test rejected')
    #    error_warning_list <- c(error_warning_list, '(Stratify) The null hypothesis "H0: sample is normality distributed" has been rejected - The sample is not normal')
    #    codes <- c(codes, "(Stratify) FAIL: Shapiro")
    #  }
    #}
  }
  
  homogeneity.fail <- FALSE
  levene_mod <- leveneTest(formula_aov, data = wdat) # homogeneity
  levene_pvalue <- levene_mod$`Pr(>F)`[[1]]
  if (levene_pvalue <= p_limit) {
    homogeneity.fail <- TRUE
    descriptions <- c(descriptions, "Null hypothesis of Levene's Test rejected")
    error_warning_list <- c(error_warning_list, 'The null hypothesis "H0: homogeneity of variance" has been rejected - There is a difference between the variances of sample')
    codes <- c(codes, "FAIL: Levene's")
    
    ## stratify
    #if (!is.null(cstratify) && length(cstratify) > 0) {
    #  homogeneity.fail <- FALSE
    #  homogeneity.fail <- any(sapply(cstratify, FUN = function(sname) {
    #    homo.fails <- sapply(levels(wdat[[sname]]), FUN = function(svalue) {
    #      tdat <- wdat[wdat[[sname]] == svalue,]
    #      tformula_aov <- as.formula(
    #        paste(paste0('`',dv,'`'), "~", paste(c(between[!between %in% sname], within[!within %in% sname]), collapse = "*"),
    #              if (length(within) > 0) paste0("+Error(", wid, "/(", paste(within[!within %in% sname], collapse = "*"), "))") else NULL))
    #      return(leveneTest(tformula_aov, data = tdat)$`Pr(>F)`[[1]] <= p_limit)
    #    })
    #    return(any(homo.fails))
    #  }))
    #  if (homogeneity.fail) {
    #    descriptions <- c(descriptions, "(Stratify) Null hypothesis of Levene's Test rejected")
    #    error_warning_list <- c(error_warning_list, '(Stratify) The null hypothesis "H0: homogeneity of variance" has been rejected - There is a difference between the variances of sample')
    #    codes <- c(codes, "(Stratify) FAIL: Levene's")
    #  }
    #}
  }
  
  ## post-hoc test
  tukey_mod <- TukeyHSD(ezAov$aov, ordered = T)
  
  df_lsmeans <- list()
  df_contrasts <- list()
  
  for (k in 1:length(columns)) {
    str_m1 <- paste0(columns[1:k], collapse = ':')
    str_m2 <- paste0(columns[1:k], collapse = '|')
    
    means_mod <- lsmeans::lsmeans(ezAov$aov, as.formula(paste0('~', str_m2)))
    contrast_mod <- lsmeans::contrast(means_mod, method = 'pairwise')
    df_lsmean = as.data.frame(summary(means_mod))
    df_lsmean["Pairs"] = factor(apply(df_lsmean[columns[1:k]], 1, paste, collapse='.'))
    df_contrast = as.data.frame(summary(contrast_mod))
    
    df_lsmeans[[str_m1]] <- df_lsmean
    df_contrasts[[str_m1]] <- df_contrast
  }
  
  ## pair using t-test
  t.test_pairs <- list()
  columns <- unique(c(iv, columns[!columns %in% iv]))
  
  for (m in 1:length(columns)) {
    comb_columns <- combn(columns, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      selected_columns  <- comb_columns[,i]
      if (!completed && selected_columns[[1]] != iv) next
      cname <- paste0(selected_columns, collapse = ':')
      factors <- factor(apply(wdat[selected_columns], 1, paste, collapse='.'))
      level_pairs <- combn(levels(factors), 2)
      
      mods <- list()
      for (j in 1:ncol(level_pairs)) {
        level_pair <- level_pairs[,j]
        
        rdat2 <- wdat[factors %in% level_pair,]
        y <- rdat2[[dv]]
        x <- factors[factors %in% level_pair]
        
        tt_1 <- get_t.test_mod(x, y, alternative = 'less')
        tt_2 <- get_t.test_mod(x, y, alternative = 'greater')
        tt_3 <- get_t.test_mod(x, y, alternative = 'two.sided')
        
        mods[[paste0(level_pair, collapse = ':')]] <- list(dat = rdat2, less = tt_1, greater = tt_2, two.sided = tt_3)
      }
      t.test_pairs[[cname]] <- mods
    }
  }
  
  return(list(
    fails.warnings = data.frame("code" = codes, "description" = descriptions)
    , data = wdat , min.sample.size.fail = tms_mod$fail, anova.type = type
    , post.hoc = list(tukey = tukey_mod, lsmeans = df_lsmeans, contrasts = df_contrasts)
    , t.test.pairs = t.test_pairs
    , assumptions.fail = (homogeneity.fail || normality.fail)
    , homogeneity.fail = homogeneity.fail, normality.fail = normality.fail
    , test.min.size = tms_mod, plotAov = plotAov, formula.str = formula_str
    , ezAov = ezAov, shapiro = shapiro_mod, levene = levene_mod
    , error.warning.list = error_warning_list))
}

#############################################################################
## Functions to draw plots                                                 ##
#############################################################################

pnormPlot <- function(presult){
  adat = data.frame("ID" = names(presult$plotAov$residuals)
                    , "res" = as.vector(presult$plotAov$residuals))
  normPlot(adat, "res", "ID")
}

## plot normality points
normPlot <- function(rdat, dv, wid="UserID") {
  library(ggplot2)
  library(ggrepel)
  
  df <- data.frame(name = factor(rdat[[wid]]), x = rdat[[dv]])
  
  y <- quantile(rdat[[dv]], c(0.25,0.75))
  x <- qnorm(c(0.25,0.75))
  name <- rdat[[wid]]
  
  slope <- diff(y)/diff(x)
  int <- y[1] - slope*x[1]
  
  g<-ggplot(df, aes(sample = x)) + stat_qq()
  df.new<-ggplot_build(g)$data[[1]]
  df.new$name<-df$name[order(df$x)]
  
  print(ggplot(df.new,aes(theoretical,sample,label=name))+geom_point(color = 'black')+#geom_text()+ 
          geom_abline(intercept=int, slope=slope,linetype = "dotted") + theme_bw() +
          geom_text_repel(aes(label = name)
                          , segment.color = '#888888'
                          , segment.size = 0.25
                          , arrow = arrow(length = unit(0.005, 'npc'))
                          , point.padding = unit(0.4, 'lines') # extra padding
                          , box.padding = unit(0.15, 'lines')
                          , force = 1 # Strength of the repulsion force.
                          , size = 3))
}

## Function to plot assumptions based on the result of anova
plot_assumptions_for_parametric_test <- function(result, dv) {
  mod <- result$plotAov
  sub <- result$formula.str
  plot(mod, 2, sub = sub, main = paste0('Normality for ', dv))
  
  plot(mod, 1, sub = sub, main = paste0('Homogeneity for ', dv))
  plot(mod, 3, sub = sub, main = paste0('Homogeneity for ', dv))
  plot(mod, 5, sub = sub, main = paste0('Homogeneity for ', dv))
  
  plot(mod, 4, sub = sub, main = paste0('Homogeneity for ', dv))
  plot(mod, 6, sub = sub, main = paste0('Homogeneity for ', dv))
}

## Plot function of t.test
plot_t.test <- function(
  tt, title="", sub = NULL, ylab = NULL, notch = F, inv.col = F
  , draw.conf.int = T, lsmean = NULL, ylim = NULL, levels = NULL) {
  
  pch <- c(16,17)
  pcol <- c("white","lightgrey")
  vcols <- c('blue', 'red')
  if (inv.col) {
    pch <- c(17,16)
    pcol <- c("lightgrey","white")
    vcols <- c('red', 'blue')
  }
  if (is.null(levels)) {
    tt$data$x <- factor(tt$data$x)
  } else tt$data$x <- factor(tt$data$x, levels = levels)

  par(cex.main=2, cex.lab=1.25, cex.sub=1.75, cex.axis=1.75)
  bx <- boxplot(y ~ x, data=tt$data, boxwex=0.2, col=pcol, notch = notch, ylab=ylab, ylim = ylim)
  
  title(title, sub = sub)
  stripchart(y ~ x, data=tt$data, cex=0.75, pch=pch, col=8, add=T, at = seq(from=0.7, by=1, length.out = length(bx$names)), method = 'jitter', vertical=T)
  
  if (draw.conf.int) {
    j <- 1
    for (bx_name in bx$names) {
      ci_lower <- tt$result$CI.lower[tt$result$Group == bx_name]
      ci_upper <- tt$result$CI.upper[tt$result$Group == bx_name]
      if (!is.null(lsmean)) {
        ci_lower <- lsmean$lower.CL[lsmean$Pairs == bx_name]
        ci_upper <- lsmean$upper.CL[lsmean$Pairs == bx_name]
      }
      
      points(c(j-0.3, j-0.3, j-0.3), c(ci_lower, (ci_lower+ci_upper)/2, ci_upper), pch="-", col=vcols[[j%%2 + 1]], cex=c(.9,.9,1.5))
      lines(c(j-0.3, j-0.3), c(ci_lower, ci_upper), col=vcols[j%%2 + 1])
      j <- j + 1
    }
  }
}

## Function to write plots of parametric test
write_plots_for_parametric_test <- function(
  p_result, ylab, title, path, override = T, ylim = NULL, levels = NULL, inv.col = F) {
  
  mod <- p_result$plotAov
  sub <- p_result$formula.str
  
  ## plot assumptions for anova
  filename <- paste0(path, '00-normality1.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 2, sub = sub, main = paste0('Normality for ', title))
    dev.off()
  }
  
  filename <- paste0(path, '00-homogeneity1.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 1, sub = sub, main = paste0('Homogeneity for ', title))
    dev.off()
  }
  
  filename <- paste0(path, '00-homogeneity2.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 3, sub = sub, main = paste0('Homogeneity for ', title))
    dev.off()
  }
  
  filename <- paste0(path, '00-homogeneity3.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 5, sub = sub, main = paste0('Homogeneity for ', title))
    dev.off()
  }
  
  filename <- paste0(path, '00-homogeneity4.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 4, sub = sub, main = paste0('Homogeneity for ', title))
    dev.off()
  }
  
  filename <- paste0(path, '00-homogeneity5.png')
  if (!file.exists(filename) || override) { 
    png(filename = filename, width = 640, height = 640)
    plot(mod, 6, sub = sub, main = paste0('Homogeneity for ', title))
    dev.off()
  }
  
  ## box plots for the pairs using lsmeans
  set_tt_mods <- p_result$t.test.pairs
  
  for (iv in names(set_tt_mods)) {
    tt_mods <- set_tt_mods[[iv]]
    for (i in 1:length(tt_mods)) {
      tt_mod <- tt_mods[[i]]
      
      ##
      pair_names <- strsplit(names(tt_mods)[[i]], ':')[[1]]
      lsmean <- p_result$post.hoc$lsmeans[[iv]][
        p_result$post.hoc$lsmeans[[iv]]$Pairs %in% pair_names,]
      
      ##
      filename <- paste0(iv, '_', names(tt_mods)[[i]], ".png")
      filename <- gsub(':', '.', gsub('/', '', filename))
      filename <- paste0(path, filename)
      
      ## sorting levels
      pair_levels <- NULL
      if (!is.null(levels)) {
        pair_levels <- c()
        for (lvl in levels) {
          pair_levels <- c(pair_levels, pair_names[grepl(lvl, pair_names)])
        }
      }
      
      if (!file.exists(filename) || override) {
        png(filename = filename, width = 640, height = 640)
        plot_t.test(tt_mod$two.sided, title = title, ylab = ylab, lsmean = lsmean
                    , ylim = ylim, levels = pair_levels, inv.col = inv.col)
        dev.off()
      }
      
    }
  }
}

#############################################################################
## Functions to write reports                                              ##
#############################################################################

## Function to write anova summary
write_anova_summary_in_wb <- function(p_result, wb, title = "") {
  
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Summary")
  xlsx.addHeader(wb, sheet, paste0("Summary of ANOVA for ", title), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Anova Table (Type ", p_result$anova.type, " tests) for ", p_result$formula.str), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(p_result$ezAov$anova_table), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Anova Table (Type ", p_result$anova.type, " tests) for ", p_result$formula.str), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(p_result$ezAov$Anova), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Fail and warnings in Anova for ", title), level = 2, startCol = 1)
  if (nrow(p_result$fails.warnings) > 0) {
    xlsx.addTable(wb, sheet, p_result$fails.warnings, startCol = 1, row.names = T)
  }
  if (length(p_result$error.warning.list) > 0) {
    xlsx.addParagraph(wb, sheet, paste0(p_result$error.warning.list, collapse = "\n"), startCol = 1)
  }
}

## Function to write anova assumptions
write_assumptions_for_parametric_test_in_wb <- function(p_result, wb, title = "") {
  
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Assumptions")
  xlsx.addHeader(wb, sheet, paste0("ANOVA assumptions for ", title), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0(p_result$shapiro$method," for ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, data.frame(W = p_result$shapiro$statistic, p.value = p_result$shapiro$p.value), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots for normality test", level = 2, startCol = 1)
  plotNormality <- function() {
    plot(p_result$plotAov, 2, sub = p_result$formula.str, main = paste0('Normality for ', title))
  }
  xlsx.addPlot(wb, sheet, plotNormality, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Levene's Test for Homogeneity of Variance in ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(p_result$levene), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots for homogeneity of variance", level = 2, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(p_result$plotAov, 1, sub = p_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(p_result$plotAov, 3, sub = p_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(p_result$plotAov, 5, sub = p_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(p_result$plotAov, 4, sub = p_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(p_result$plotAov, 6, sub = p_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Minimum Sample Size Test for ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, p_result$test.min.size$table.frequency, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Errors and Warnings in Sample Size Test for ANOVA in ", title), level = 2, startCol = 1)
  if (nrow(p_result$test.min.size$fails.warnings) > 0) {
    xlsx.addTable(wb, sheet, p_result$test.min.size$fails.warnings, startCol = 1, row.names = F)
  }
  if (length(p_result$test.min.size$error.warning.list) > 0) {
    xlsx.addLineBreak(sheet, 1)
    xlsx.addParagraph(wb, sheet, paste0(p_result$test.min.size$error.warning.list, collapse = "\n"), startCol = 1)
  }
  
  if (!p_result$test.min.size$fail) {
    xlsx.addLineBreak(sheet, 1)
    xlsx.addParagraph(wb, sheet, paste0(
      c("If you don't want to remove non-normal data, you must cite the following references:\n"
        , "... (1) Lix, L.M., J.C. Keselman, and H.J. Keselman. 1996. "
        , "Consequences of assumption violations revisited: A quantitative review"
        , " of alternatives to the one-way analysis of variance F test. Rev. Educ."
        , " Res. 66: 579-619.\n"
        , "... (2) Harwell, M.R., E.N. Rubinstein, W.S. Hayes, and C.C. Olds. 1992. "
        , "Summarizing Monte Carlo results in methodological research: the one- and two-factor "
        , "fixed effects ANOVA cases. J. Educ. Stat. 17: 315-339."), collapse = ""), startCol = 1)
  }
}

## Function to write post_hoc information
write_post_hoc_in_wb <- function(p_result, wb, title = "") {
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Post-hoc")
  xlsx.addHeader(wb, sheet, paste0("Post-hoc Tukey Honestly Significant Difference (HSD) Test for ", title), startCol = 1)
  
  for (name in names(p_result$post.hoc$tukey)) {
    dframe <- p_result$post.hoc$tukey[[name]]
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Comparisons of means for ", name), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, as.data.frame(dframe), startCol = 1, row.names = T)
  }
  
  for (iv in names(p_result$post.hoc$contrasts)) {
    df_contrast <- p_result$post.hoc$contrasts[[iv]]
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Contrast Matrices for ", title, ' - ', iv), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, df_contrast, startCol = 1, row.names = F)
  }
  
  for (iv in names(p_result$post.hoc$lsmeans)) {
    lsmean <- p_result$post.hoc$lsmeans[[iv]]
    
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Least Squares Means and Confidence Intervals for ", iv), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, lsmean, startCol = 1, row.names = F)
  }
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots", level = 2, startCol = 1)
  plotTukey <- function() {
    plot(p_result$post.hoc$tukey, sub = p_result$formula.str, cex.axis = 0.5, cex.lab = 0.5, cex.main=0.5)
  }
  xlsx.addPlot(wb, sheet, plotTukey, width = 1024, height = 1024, startCol = 1)
  plotMeans <- function() {
    plot.design(as.formula(p_result$formula.str), ask = F, fun=mean,
                sub = p_result$formula.str, data = p_result$ezAov$aov$model, main = paste0('Group means for ', title))
  }
  xlsx.addPlot(wb, sheet, plotMeans, width = 640, height = 640, startCol = 1)
}

## Function to write summary of set wt mods
write_anova_pair_ttest_summary_in_wb <- function(set_tt_mods, wb, title = "") {
  
  library(r2excel) 
  
  sheet <- xlsx::createSheet(wb, sheetName = "Summary t-Test")
  xlsx.addHeader(wb, sheet, paste0("Summary of Student's t-Test for ", title), startCol = 1)
  
  for (iv in names(set_tt_mods)) {
    tt_mods <- set_tt_mods[[iv]]
    for (i in 1:length(tt_mods)) {
      tt_mod <- tt_mods[[i]]
      
      if (max(tt_mod$less$result$p.value) <= 0.05) {
        xlsx.addLineBreak(sheet, 2)
        xlsx.addHeader(wb, sheet, paste0("Student's t-Test results for ", iv, " - Alternative hypothesis: less"), level = 2, startCol = 1)
        xlsx.addTable(wb, sheet, tt_mod$less$result, startCol = 1, row.names = F)
      }
      if (max(tt_mod$greater$result$p.value) <= 0.05) {
        xlsx.addLineBreak(sheet, 2)
        xlsx.addHeader(wb, sheet, paste0("Student's t-Test results for ", iv, " - Alternative hypothesis: greater"), level = 2, startCol = 1)
        xlsx.addTable(wb, sheet, tt_mod$greater$result, startCol = 1, row.names = F)
      }
    }
  }
}

## Function to write t-test in sheet
write_tts_in_wb <- function(
  tt_mods, wb, iv, i, title = "", ylab = "Score", ylim = NULL, levels = NULL) {
  
  library(r2excel) 
  
  tt_mod <- tt_mods[[i]]
  sheet <- xlsx::createSheet(wb, sheetName = paste0(sub(':', '_', iv),"_", i))
  xlsx.addHeader(wb, sheet, paste0("Student's t-Test for ", title, " in ", iv, " between ", names(tt_mods)[[i]]), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Student's t-Test results", level = 2, startCol = 1)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: less", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, tt_mod$less$result, startCol = 1, row.names = F)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: greater", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, tt_mod$greater$result, startCol = 1, row.names = F)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: two.sided", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, tt_mod$two.sided$result, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Box plots for Student's t-Test", level = 2, startCol = 1)
  plotTT <- function() {
    plot_t.test(tt_mod$two.sided, title = title, ylab = ylab, ylim = ylim, levels = levels)
  }
  xlsx.addPlot(wb, sheet, plotTT, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Student's t-Test data", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, tt_mod$dat, startCol = 1, row.names = F)
}

## Function to write parametric analysis report
write_parametric_test_report <- function(
  p_result, filename, title = "", ylab = "Score", override = T, ylim = NULL, levels = NULL) {
  
  library(r2excel)
  
  if (!file.exists(filename) || override) {
    wb <- createWorkbook(type="xlsx")
    
    write_anova_summary_in_wb(p_result, wb, title)
    write_assumptions_for_parametric_test_in_wb(p_result, wb, title)
    write_post_hoc_in_wb(p_result, wb, title)
    
    set_tt_mods <- p_result$t.test.pairs
    write_anova_pair_ttest_summary_in_wb(set_tt_mods, wb, title)
    
    for (iv in names(set_tt_mods)) {
      tt_mods <- set_tt_mods[[iv]]
      for (i in 1:length(tt_mods)) {
        
        ##
        pair_names <- strsplit(names(tt_mods)[[i]], ':')[[1]]
        lsmean <- p_result$post.hoc$lsmeans[[iv]][
          p_result$post.hoc$lsmeans[[iv]]$Pairs %in% pair_names,]
        
        ## sorting levels
        pair_levels <- NULL
        if (!is.null(levels)) {
          pair_levels <- c()
          for (lvl in levels) {
            pair_levels <- c(pair_levels, pair_names[grepl(lvl, pair_names)])
          }
        }
        
        write_tts_in_wb(tt_mods, wb, iv, i, title = title
                        , ylab = ylab, ylim = ylim, levels = pair_levels)
      }
    }  
    
    sheet <- xlsx::createSheet(wb, sheetName = "data")
    xlsx.addTable(wb, sheet, p_result$data, startCol = 1, row.names = F)
    
    ##
    saveWorkbook(wb, filename)
  }
}

##
winsorize_two_by_two_design <- function(
  participants, sdat_map, list_dvs, wid = "UserID", ivs_list = list(
    iv1 = list(iv = "Type", values = c("non-gamified", "ont-gamified"))
    , iv2 = list(iv = "CLRole", values = c("Master", "Apprentice")))) {
  library(MVN)
  library(daff)
  library(robustHD)
  
  library(readr)
  library(dplyr)
  
  
  wdat_map <- lapply(list_dvs, FUN = function(dv) {
    wdat <- sdat_map[[dv]]
    winsorize_dv <- robustHD::winsorize(wdat[[dv]])
    if (all(!is.na(winsorize_dv))) {
      wdat[[dv]] <- winsorize_dv
    }
    wdat$theta <- wdat[[dv]]
    return(wdat)
  })
  
  wdat_map <- lapply(list_dvs, FUN = function(dv) {
    return(do.call(rbind, lapply(
      list(
        "iv1_1" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[1]])),
        "iv1_2" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[2]]))
      )
      , FUN = function(params) {
        wdat <- wdat_map[[dv]]
        idx <- (wdat[[params$p1$iv]] == params$p1$value)
        wdat <- wdat[idx,]
        winsorize_dv <- robustHD::winsorize(wdat[[dv]])
        if (all(!is.na(winsorize_dv))) {
          wdat[[dv]] <- winsorize_dv
        }
        wdat$theta <- wdat[[dv]]
        return(wdat)
      }
    )))
  })
  
  wdat_map <- lapply(list_dvs, FUN = function(dv) {
    return(do.call(rbind, lapply(
      list(
        "iv1_1_iv2_1" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[1]]),
          p2 = list(iv = ivs_list$iv2$iv, value = ivs_list$iv2$values[[1]])),
        "iv1_1_iv2_2" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[1]]),
          p2 = list(iv = ivs_list$iv2$iv, value = ivs_list$iv2$values[[2]])),
        "iv1_2_iv2_1" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[2]]),
          p2 = list(iv = ivs_list$iv2$iv, value = ivs_list$iv2$values[[1]])),
        "iv2_2_iv2_2" = list(
          p1 = list(iv = ivs_list$iv1$iv, value = ivs_list$iv1$values[[2]]),
          p2 = list(iv = ivs_list$iv2$iv, value = ivs_list$iv2$values[[2]]))
      )
      , FUN = function(params) {
        wdat <- wdat_map[[dv]]
        idx <- (wdat[[params$p1$iv]] == params$p1$value
                & wdat[[params$p2$iv]] == params$p2$value)
        wdat <- wdat[idx,]
        winsorize_dv <- robustHD::winsorize(wdat[[dv]])
        if (all(!is.na(winsorize_dv))) {
          wdat[[dv]] <- winsorize_dv
        }
        wdat$theta <- wdat[[dv]]
        return(wdat)
      }
    )))
  })
  
  ##
  sdat <- participants
  wdat <- participants
  for (dv in names(list_dvs)) {
    sdat <- merge(sdat, sdat_map[[dv]][,c(wid, dv)], by = wid)
    wdat <- merge(wdat, wdat_map[[dv]][,c(wid, dv)], by = wid)
  }
  rownames(sdat) <- sdat[[wid]]
  rownames(wdat) <- wdat[[wid]]
  
  return(list(sdat = sdat, wdat = wdat, diff_dat = diff_data(sdat, wdat)))
}

