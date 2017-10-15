
###############################################################################
## Functions to analysis motivation and learning outcomes                    ##
###############################################################################

## Definition of function wilcox_analysis
wilcox_analysis <- function(x, y, title="", alternative = "two.sided"
                            , plotting = TRUE, notch = TRUE, sub = NULL, ylab = NULL
                            , inv.col = FALSE, draw.conf.int = TRUE) {
  library(coin)
  
  x <- factor(x)
  sdata <- data.frame(x=x, y=y, r=rank(y))
  
  # wilcoxon values
  wt <- wilcox.test(y ~ x, alternative = alternative, conf.int = FALSE)
  U <- wt$statistic
  wt <- wilcox_test(y ~ x, distribution="exact", conf.int = FALSE, alternative = alternative)
  Z <- as.numeric(statistic(wt))
  pvalue <- pvalue(wt)
  r <- abs(Z/sqrt(length(x)))
  
  # drawing plotting
  if (plotting == TRUE) {
    pch1=16; pch2=17
    pcol1=10; pcol2=4
    pcol = c("white","lightgrey")
    if (inv.col == TRUE) {
      pch1=17; pch2=16
      pcol1=4; pcol2=10
      pcol = c("lightgrey","white")
    }
    
    bp <- boxplot(y ~ x, boxwex=0.2, notch=notch, col=pcol, ylab=ylab)
    title(title, sub = sub)
    
    # drawing data as points
    stripchart(sdata$y[sdata$x==levels(x)[1]], col=8, pch=pch1, add=TRUE, at=0.7, cex=.7, method="jitter", vertical=TRUE)
    stripchart(sdata$y[sdata$x==levels(x)[2]], col=8, pch=pch2, add=TRUE, at=1.7, cex=.7, method="jitter", vertical=TRUE)
    
    # drawing line wilcox conf.interval
    if (draw.conf.int==TRUE) {
      wt <- wilcox.test(sdata$y[sdata$x==levels(x)[1]], conf.int=TRUE)
      points(c(0.7,0.7,0.7), c(wt$conf.int, wt$estimate), pch="-", col=pcol1, cex=c(.9,.9,1.5))
      lines(c(0.7,0.7), wt$conf.int, col=pcol1)
      
      wt <- wilcox.test(sdata$y[sdata$x==levels(x)[2]], conf.int=TRUE)
      points(c(1.7,1.7,1.7), c(wt$conf.int, wt$estimate), pch="-", col=pcol2, cex=c(.9,.9,1.5))
      lines(c(1.7,1.7), wt$conf.int, col=pcol2)
    }
  }
  
  result <- data.frame(
    "Group" = c(levels(x)[1], levels(x)[2])
    , "N" = c(length(x[x==levels(x)[1]]), length(x[x==levels(x)[2]]))
    , "Median" = c(median(sdata$y[sdata$x == levels(x)[1]]), median(sdata$y[sdata$x == levels(x)[2]]))
    , "Mean Ranks" = c(mean(sdata$r[sdata$x == levels(x)[1]]), mean(sdata$r[sdata$x == levels(x)[2]]))
    , "Sum Ranks" = c(sum(sdata$r[sdata$x == levels(x)[1]]), sum(sdata$r[sdata$x == levels(x)[2]]))
    , "U" = c(U, U)
    , "Z" = c(Z, Z)
    , "p-value" = c(pvalue, pvalue)
    , "r" = c(r, r))
  
  return(result)
}

###############################################################################
## Functions to perform a pre-process of data                                ##
###############################################################################

library(TAM)
library(sirt)
library(psych)
library(lavaan)
library(plotly)


###############################################################################
## Anova and Ancova modules for analysis                                     ##
###############################################################################

## test of sample size
test_min_size <- function(data, between, type = 'parametric') {
  
  tb_size <- xtabs(as.formula(paste0('~', paste0(between, collapse = '+'))), data = data)
  n_groups <- prod(dim(tb_size))
  
  fail <- FALSE
  unbalanced <- TRUE
  codes <- c()
  descriptions <- c()
  
  minimal_size <- 5
  recomended_size <- ifelse(n_groups > 10, 20, 15)
  
  tf_size <- as.data.frame(ftable(tb_size))
  if (max(tf_size$Freq) == min(tf_size$Freq)) {
    unbalanced <- FALSE
  }
  
  for (i in 1:nrow(tf_size)) {
    csize <- tf_size$Freq[i]
    
    name_group <- apply(as.vector(within(tf_size, rm('Freq'))[i,]), 1, paste, collapse =':')
    name_group <- as.character(name_group)
    
    if (csize < minimal_size) {
      fail <- TRUE
      descriptions <- c(paste0(
        "min.size must be: ", minimal_size, " and size is: ", csize
        , " in '", name_group, "'. Min size sample for parametric test isn't satified")
        , descriptions)
      codes <- c("FAIL: min.size", codes)
    } else if (csize < recomended_size) {
      descriptions <- c(paste0(
        "size must be: ", recomended_size, " and size is: ", csize
        , " in '", name_group, "'. Size sample for parametric test isn't recomended")
        , descriptions)
      codes <- c("WARN: sample.size", codes)
      warning('\n'
              , "... Sample size doesn't looks adequate for parametric tests\n"
              , "... We recommend the use of non parametric test")
    } else {
      warning('\n'
              , "... According to your sample size, you can perform a parametric test with a non-normal distribution\n"
              , "... If you don't want to remove non-normal data, you must cite the following references:\n"
              , "... (1) Lix, L.M., J.C. Keselman, and H.J. Keselman. 1996. "
              , "Consequences of assumption violations revisited: A quantitative review"
              , " of alternatives to the one-way analysis of variance F test. Rev. Educ."
              , " Res. 66: 579-619.\n"
              , "... (2) Harwell, M.R., E.N. Rubinstein, W.S. Hayes, and C.C. Olds. 1992. "
              , "Summarizing Monte Carlo results in methodological research: the one- and two-factor "
              , "fixed effects ANOVA cases. J. Educ. Stat. 17: 315-339.")
    }
  }
  
  return(list(
    table.frequency = tf_size , fail = fail, unbalanced = unbalanced
    , fails_warnings = data.frame("code" = codes, "description" = descriptions)
    ))
}

## get formulas for test of anova ancova and anova slip-plot
get_formulas <- function(dv, wid, cv = NULL, bs = NULL, ws = NULL) {
  
  between_covariance_formula_str <- paste0(cv, collapse = '+')
  between_formula_str <- paste0(bs, collapse = '*')
  within_formula_str <- paste0(ws, collapse = '*')
  error_formula_str <- paste0('Error( ', wid, '/(',within_formula_str,') )')
  
  idata <- NULL
  idesign_str <- NULL
  lm_formula_str <- NULL
  aov_formula_str <- c(dv, ' ~ ')

  if (!is.null(cv) & length(cv) > 0) {
    aov_formula_str <- c(aov_formula_str, between_covariance_formula_str)
  }
  if (!is.null(bs) & length(bs) > 0) {
    pre.str <- ifelse(!is.null(cv) & length(cv) > 0, ' + ', ' ')
    aov_formula_str <- c(aov_formula_str, pre.str, between_formula_str)
  }
  if (!is.null(ws) & length(ws) > 0) {
    pre.str <- ifelse(!is.null(bs) & length(bs) > 0, '*', ' ')
    aov_formula_str <- c(aov_formula_str, pre.str, within_formula_str)
    aov_formula_str <- c(aov_formula_str, ' + ', error_formula_str)
    
    # Non! Comment it out! We'll just do it once for now.
    # within variables is not ready to automatic create linear models with lm
    "if (length(ws) < 4) {
      tb_factor <- list(data.frame(factor(rep(1:3, each=1, times=1))),
                        data.frame(factor(rep(1:2, each=3, times=1)),
                                   factor(rep(1:3, each=1, times=2))),
                        data.frame(factor(rep(1:2, each=9, times=1)),
                                   factor(rep(1:3, each=3, times=2)),
                                   factor(rep(1:3, each=1, times=6))))
      idata <- tb_factor[[length(ws)]]
      names(idata) <- ws
      
      idesign_str <- paste0('~', within_formula_str)
      
      for_cbind <- c()
      for (i in 1:nrow(idata)) {
        var_cbind <- c()
        for (iname in names(idata)) {
          var_cbind <- c(var_cbind, paste0(iname, idata[i, iname])) 
        }
        for_cbind <- c(for_cbind, paste0(var_cbind, collapse = ''))
      }
      post_bs <- ifelse(length(bs) > 0, between_formula_str, '1')
      lm_formula_str <- paste0('cbind(', paste0(for_cbind, collapse = ','), ') ~ ', post_bs)
    }"
  } else {
    lm_formula_str <- paste0(aov_formula_str, collapse = '')
  }
  
  aov_formula_str <- paste0(aov_formula_str, collapse = '')
  
  return(list(
    aov = as.formula(aov_formula_str), aov.str = aov_formula_str,
    lm = as.formula(lm_formula_str), lm.str = lm_formula_str, 
    idesign = as.formula(idesign_str), idesign.str = idesign_str,
    idata = idata, between.formula.str = between_formula_str
  ))
}

## get anova and ancovas mods
get_aov_mods_for_pre_post_test <- function(data, wid, pre.test, post.test, between, type = 3) {
  
  #devtools::install_github("singmann/afex@master")
  
  library(car)
  library(afex)
  
  # pre-processing data into rdat
  rdat <- data.frame(factor(data[[wid]]), data[[pre.test]], data[[post.test]])
  rdat[,'Diff'] <- data[[post.test]] - data[[pre.test]]
  colnames(rdat) <- c(wid, pre.test, post.test, 'Diff')
  for (cname in c(between)) {
    rdat[,cname] <- factor(data[[cname]])
  }
  rownames(rdat) <- data[[wid]]
  
  # pre-processing data into ldat
  ldat <- data.frame(factor(rep(rdat[,wid], 2)),
                     c(rdat[[pre.test]], rdat[[post.test]]),
                     factor(rep(c(pre.test, post.test), each=nrow(rdat))))
  colnames(ldat) <- c(wid, 'Score', 'Time')
  rownames(ldat) <- within(expand.grid('A'=rdat[[wid]], 'B'=c('1','2'))
                           , C <- paste(A, B, sep='.'))[['C']]
  
  for (cname in between) {
    ldat[,cname] <- factor(rep(rdat[[cname]], 2))
  }
  
  # get models using traditional methods
  aov_formulas <- get_formulas(dv = 'Diff', wid = wid, bs = between)
  aocv_formulas <- get_formulas(dv = post.test, wid = wid, cv = pre.test, bs = between)
  aspv_formulas <- get_formulas(dv = 'Score', wid = wid, bs = between, ws = 'Time') # split_plot
  aspv_formulas$lm.str <- paste0('cbind(',pre.test,', ',post.test,') ~ ' , paste0(between, collapse = '*'))
  aspv_formulas$lm <- as.formula(aspv_formulas$lm.str)
  
  mod_aov <- aov(aov_formulas$aov, data = rdat)
  mod_aocv <- aov(aocv_formulas$aov, data = rdat)
  mod_aspv <- aov(aspv_formulas$aov, data = ldat)
  
  lm_aov <- lm(formula = aov_formulas$lm, data = rdat)
  lm_aocv <- lm(formula = aocv_formulas$lm, data = rdat)
  lm_aspv <- lm(formula = aspv_formulas$lm, data = rdat)
  
  mod_AOV <- NULL
  mod_AOCV <- NULL
  mod_ASPV <- NULL
  if (type != 1 & type != 'I') {
    mod_AOV <- Anova(mod = lm_aov, type = type)
    mod_AOCV <- Anova(mod = lm_aocv, type = type)
    mod_ASPV <- Anova(mod = lm_aspv, idata = data.frame(Time=gl(2,1)), idesign = ~Time, type = type)
  }
  
  ## get model fits using afex 
  
  ezAov <- aov_ez(id = wid, dv = 'Diff', data = rdat, between = between, print.formula = T)
  ezAov_aocv <- aov_ez(id = wid, dv = post.test, data = rdat, between = between, covariate = pre.test, print.formula = T)
  ezAov_sp <- aov_ez(id = wid, dv = 'Score', between = between, within = 'Time', data = ldat, print.formula = T)
  
  return(list(
    data = rdat, data.sp = ldat, type = type, wid = wid, pre.test = pre.test, post.test = post.test, between = between,
    lm = lm_aov, lm.aocv = lm_aocv, lm.sp = lm_aspv,
    aov = mod_aov, aov.aocv = mod_aocv, aov.sp = mod_aspv,
    Anova = mod_AOV, Anova.aocv = mod_AOCV, Anova.sp = mod_ASPV,
    ezAov = ezAov, ezAov.aocv = ezAov_aocv, ezAov.sp = ezAov_sp,
    formula = aov_formulas, formula.aocv = aocv_formulas, formula.sp = aspv_formulas
  ))
}

## internal homogeneity function
test_homogeneity_mod <- function(mods, mod_sufix_code, mod_name, plotting = T, p_limit = 0.05) {
  
  levene_mod <- NULL
  
  fail <- FALSE
  codes <- c()
  descriptions <- c()
  
  ##
  aov_mod <- mods[[paste0('aov', mod_sufix_code)]]
  aov_formula <- mods[[paste0('formula', mod_sufix_code)]]$aov
  aov_formula_str <- mods[[paste0('formula', mod_sufix_code)]]$aov.str
  
  lm_mod <- mods[[paste0('lm', mod_sufix_code)]]
  lm_formula <- mods[[paste0('formula', mod_sufix_code)]]$lm
  lm_formula_str <- mods[[paste0('formula', mod_sufix_code)]]$lm.str
  
  ##
  levene_mod <- NULL
  levene_mod <- tryCatch(
    leveneTest(aov_formula, data = mods$data)
    , error = function(e) list('Pr(>F)'= c(Inf)))
  
  levene_pvalue <- levene_mod$`Pr(>F)`[[1]]
  if (levene_pvalue < p_limit) {
    fail <- TRUE
    descriptions <- c("Null hypothesis of Levene's Test rejected - H0: sample has equal variance", descriptions)
    codes <- c("FAIL: Levene's Test", codes)
  }
  
  ##
  tryCatch(if (plotting) {
    
    plot(aov_mod, 1, sub = aov_formula_str, main = paste0('Homogeneity test for ', mod_name))
    plot(aov_mod, 3, sub = aov_formula_str, main = paste0('Homogeneity test for ', mod_name))
    plot(aov_mod, 5, sub = aov_formula_str, main = paste0('Homogeneity test for ', mod_name))
    
    plot(aov_mod, 4, sub = paste0(aov_formula_str, ' ', '(most influential data points)'), main = paste0('Homogeneity test for ', mod_name))
    plot(aov_mod, 6, sub = paste0(aov_formula_str, ' ', '(most influential data points)'), main = paste0('Homogeneity test for ', mod_name))
  }, error = function(e) NULL)
  
  return(list(
    fail = fail
    , levene_mod = levene_mod, levene_pvalue = levene_pvalue
    , fails_warnings = data.frame("code" = codes, "description" = descriptions)
  ))
}

## function to evaluate the homogeneity
test_homogeneity <- function(data, wid, pre.test, post.test, between,
                             mods = NULL, plotting = T, p_limit = 0.05, information = NULL) {
  
  if (is.null(mods)) {
    mods <- get_aov_mods_for_pre_post_test(data, wid, pre.test, post.test, between)
  }
  
  mod_sufix_codes <- c('', '.aocv', '.sp')
  mod_names <- c('ANOVA', 'ANCOVA', 'Analysis of Split-Plot')
  if (is.null(information)) information <- data.frame(name = mod_names)
  
  homogeneity <- c()
  levene_pvalue <- c()
  levene_mods <- list()
  homogeneity_fails_warnings <- list()
  
  for (i in 1:length(mod_names)) {
    mod_name <- mod_names[[i]]
    mod_sufix_code <- mod_sufix_codes[[i]]
    
    resp_test <- NULL
    resp_test <- tryCatch(test_homogeneity_mod(
      mods, mod_sufix_code, mod_name, plotting = plotting, p_limit = p_limit)
      , error = function(e) NULL)
    
    if (!is.null(resp_test)) {
      homogeneity <- c(homogeneity, !resp_test$fail)
      levene_pvalue <- c(levene_pvalue, resp_test$levene_pvalue)
      
      levene_mods[[mod_name]] <- resp_test$levene_mod
      homogeneity_fails_warnings[[mod_name]] <- resp_test$fails_warnings
    } else {
      homogeneity <- c(homogeneity, NA)
      levene_pvalue <- c(levene_pvalue, NA)
      
      levene_mods[[mod_name]] <- NULL
      homogeneity_fails_warnings[[mod_name]] <- NULL
    }
  }
  
  return(list(
    levene.mods = levene_mods
    , fails.warnings = homogeneity_fails_warnings
    , information = cbind(information
                          , homogeneity = homogeneity
                          , levene.pvalue = levene_pvalue)
  ))
}

## internal normality function
test_normality_mod <- function(mods, mod_sufix_code, mod_name, plotting = T, p_limit = 0.05) {
  
  shapiro_mod <- NULL
  
  fail <- FALSE
  codes <- c()
  descriptions <- c()

  ##
  aov_mod <- mods[[paste0('aov', mod_sufix_code)]]
  aov_formula <- mods[[paste0('formula', mod_sufix_code)]]$aov
  aov_formula_str <- mods[[paste0('formula', mod_sufix_code)]]$aov.str
  
  lm_mod <- mods[[paste0('lm', mod_sufix_code)]]
  lm_formula_str <- mods[[paste0('formula', mod_sufix_code)]]$lm.str
  
  ##
  shapiro_mod <- NULL
  shapiro_mod <- tryCatch(shapiro.test(aov_mod$residuals)
                          , error = function(e) shapiro.test(lm_mod$residuals))
    
  shapiro_pvalue <- shapiro_mod$p.value
  if (shapiro_pvalue < p_limit) {
    fail <- TRUE
    descriptions <- c('Null hypothesis of Shapiro test rejected - H0: sample has normality distributed', descriptions)
    codes <- c("FAIL: Shapiro test", codes)
  }
  
  ##
  if (plotting) {
    tryCatch(
      plot(aov_mod, 2, sub = aov_formula_str, main = paste0('Normality test for ', mod_name))
      , error = function(e)
        qqnorm(lm_mod$residuals
               , sub = paste0(lm_formula_str, ' (Aprox. linear model)')
               , main = paste0('Normality test for ', mod_name)
               )
    )
    tryCatch(
      hist(aov_mod$residuals, sub = aov_formula_str, main = paste0('Histogram of residuals for ', mod_name), xlab = "residuals")
      , error = function(e)
        hist(lm_mod$residuals, sub = paste0(lm_formula_str, ' (Aprox. linear model)'), main = paste0('Histogram of residuals for ', mod_name), xlab = "residuals")
    )
  }
  
  return(list(
    fail = fail
    , shapiro_mod = shapiro_mod, shapiro_pvalue = shapiro_pvalue
    , fails_warnings = data.frame("code" = codes, "description" = descriptions)
    ))
}

## function to evaluate the normality
test_normality <- function(data, wid, pre.test, post.test, between,
                           mods = NULL, plotting = T, p_limit = 0.05, information = NULL) {
  
  if (is.null(mods)) {
    mods <- get_aov_mods_for_pre_post_test(data, wid, pre.test, post.test, between)
  }
  
  mod_sufix_codes <- c('', '.aocv', '.sp')
  mod_names <- c('ANOVA', 'ANCOVA', 'Analysis of Split-Plot')
  if (is.null(information)) information <- data.frame(name = mod_names)
  
  normality <- c()
  shapiro_pvalue <- c()
  shapiro_mods <- list()
  normality_fails_warnings <- list()
  
  for (i in 1:length(mod_names)) {
    mod_name <- mod_names[[i]]
    mod_sufix_code <- mod_sufix_codes[[i]]
    
    resp_test <- NULL
    resp_test <- tryCatch(test_normality_mod(
      mods, mod_sufix_code, mod_name, plotting = plotting, p_limit = p_limit)
      , error = function(e) NULL)
    
    if (!is.null(resp_test)) {
      normality <- c(normality, !resp_test$fail)
      shapiro_pvalue <- c(shapiro_pvalue, resp_test$shapiro_pvalue)
    
      shapiro_mods[[mod_name]] <- resp_test$shapiro_mod
      normality_fails_warnings[[mod_name]] <- resp_test$fails_warnings
    } else {
      normality <- c(normality, NA)
      shapiro_pvalue <- c(shapiro_pvalue, NA)
      
      shapiro_mods[[mod_name]] <- NULL
      normality_fails_warnings[[mod_name]] <- NULL
    }
  }
  
  return(list(
    shapiro.mods = shapiro_mods
    , fails.warnings = normality_fails_warnings
    , information = cbind(information
                          , normality = normality
                          , shapiro.pvalue = shapiro_pvalue)
    ))
}

## test assumptions
test_parametric_assumptions <- function(
  data, wid, pre.test, post.test, between, mods = NULL, plotting = T, p_limit = 0.05) {
  
  if (is.null(mods)) {
    mods <- get_aov_mods_for_pre_post_test(data, wid, pre.test, post.test, between)
  }
  
  test_n <- test_normality(mods = mods)
  test_h <- test_homogeneity(mods = mods, information = test_n$information)
  
  information <- test_h$information
  fail <- !all(c(information$normality, information$homogeneity), na.rm = TRUE)
  
  return(list(
    fail = fail, test.normality = test_n, test.homogeneity = test_h, information = information
    ))
}

## 
test_post_hoc_mod <- function(mods, mod_sufix_code, mod_name, plotting = T, p_limit = 0.05) {
  
  aov_mod <- mods[[paste0('aov', mod_sufix_code)]]
  aov_formula <- mods[[paste0('formula', mod_sufix_code)]]$aov
  aov_formula_str <- mods[[paste0('formula', mod_sufix_code)]]$aov.str
  
  ez_mod <- mods[[paste0('ezAov', mod_sufix_code)]]
  
  ## tukey comparison and others
  tukey_mod <- NULL 
  tukey_mod <- tryCatch(TukeyHSD(aov_mod), error = function(e) NULL)
  
  ## easy comparison
  means_mod <- lsmeans(ez_mod,as.formula(paste0('~', paste0(mods$between, collapse = '|'))))
  contrast_mod <- contrast(means_mod, method = 'pairwise')
  
  ##
  if (plotting) { 
    tryCatch(plot.design(aov_formula, ask = F, fun=mean, sub = aov_formula_str, data = aov_mod$model, main = paste0('Group means for ', mod_name))
             , error = function(e) NULL)
    if (!is.null(tukey_mod)) {
      plot(tukey_mod, sub = paste0(aov_formula_str, ' (',mod_name,')'), cex.axis = 0.5, cex.lab = 0.5, cex.main=0.5)
    }
  }
  
  return(list(
    tukey.mod = tukey_mod, pair.wise.
    , means.mod = means_mod, means.df = data.frame(summary(means_mod))
    , contrast.mod = contrast_mod, contrast.mod.df = data.frame(summary(contrast_mod))
  ))
}

## post-hoc test 
test_post_hoc <- function(data, wid, pre.test, post.test, between,
                           mods = NULL, plotting = T, p_limit = 0.05, information = NULL) {
  
  if (is.null(mods)) {
    mods <- get_aov_mods_for_pre_post_test(data, wid, pre.test, post.test, between)
  }
  
  mod_sufix_codes <- c('', '.aocv', '.sp')
  mod_names <- c('ANOVA', 'ANCOVA', 'Analysis of Split-Plot')

  post_hoc_mods <- list()
  
  for (i in 1:length(mod_names)) {
    mod_name <- mod_names[[i]]
    mod_sufix_code <- mod_sufix_codes[[i]]
    
    resp_test <- NULL
    resp_test <- tryCatch(test_post_hoc_mod(
      mods, mod_sufix_code, mod_name, plotting = plotting, p_limit = p_limit)
      , error = function(e) NULL)
    
    if (!is.null(resp_test)) {
      post_hoc_mods[[mod_name]] <- resp_test
    } else {
      post_hoc_mods[[mod_name]] <- NULL
    }
  }
  
  # pairwise using t.test
  pairwise_list <- list()
  for (cname in mods$between) {
    pairwise_list[[cname]] <- list(
      'two.sided' = pairwise.t.test(mods$data[['Diff']], mods$data[[cname]], p.adjust.method = "bonferroni", alternative = "two.sided"),
      'less' = pairwise.t.test(mods$data[['Diff']], mods$data[[cname]], p.adjust.method = "bonferroni", alternative = "less"),
      'greater' = pairwise.t.test(mods$data[['Diff']], mods$data[[cname]], p.adjust.method = "bonferroni", alternative = "greater")
      )
  }
  
  post_hoc_mods[['pairwise.t.test']] <- pairwise_list
  return(post_hoc_mods)
}

## function to draw interaction_plot
draw_interaction_plots <- function(mods, inv.col = FALSE) {
  
  col4interactions <- c()
  data4interaction <- mods$data.sp
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      columns  <- comb_columns[,i]
      cname <- paste0(columns, collapse = ':')
      col4interactions <- c(col4interactions, cname)
      data4interaction[,cname] <- factor(apply(mods$data.sp[columns], 1, paste, collapse='.'))
    }
  }
  
  for (cname in col4interactions) {
    interaction.plot(
      factor(data4interaction$Time, levels =  c(mods$pre.test, mods$post.test))
      , data4interaction[[cname]], data4interaction$Score
      , xpd = TRUE, cex.axis=1, cex.names=1, type = 'b'
      , col = c('red', 'blue', 'forestgreen', 'black'), cex=1
      , lwd=1, pch=c(18,24), legend = T
      , xlab = 'Time', ylab = 'mean of ability'
      , trace.label = cname, main = 'Interaction plot'
    )
    #legend('bottom', col = 1:4, cex = 0.35, legend=levels(data4interaction[[cname]]), xpd = TRUE, horiz = TRUE, inset = c(0, 0), bty = "n") #, leg.bty = 'o', leg.bg = 'beige'
  }
}

## function to draw interaction_plot
draw_boxplot <- function (x, y, title.ops = NULL, inv.col=F, notch=F) {
  pch1=16; pch2=17
  pcol1=10; pcol2=4
  pcol = c("white","lightgrey")
  
  if (inv.col == TRUE) {
    pch1=17; pch2=16
    pcol1=4; pcol2=10
    pcol = c("lightgrey","white")
  }
  
  bp <- boxplot(y ~ x, boxwex=0.2, notch=notch, col=pcol)
  if (!is.null(title.ops)) title(title.ops)
}

## draw_means boxplots
draw_mean_boxplots <- function(mods, inv.col = FALSE) {
  library('mosaic')
  
  pcol = c("white","lightgrey")
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      columns  <- comb_columns[,i]
      formula_bx_str <- paste0('Diff ~ ', paste0(columns, collapse = '*'))
      formula_bx <- as.formula(paste0('mods$data$Diff~mods$data$',
                                      paste0(columns, collapse = '+ mods$data$')))
      bx <- boxplot(formula_bx, data=mods$data, boxwex=0.2, col=pcol, sub = formula_bx_str
                    , main = paste0('Gain in ability for ',
                                    paste0(columns, collapse = ':')))
      stripchart(formula_bx,data=mods$data, cex=0.75,pch=c(16,17), col=8, add=T, at = seq(from=0.7, by=1, length.out = length(bx$names)), method = 'jitter', vertical=T)
      sd_result <- mosaic::sd(formula_bx, data = mods$data)
      means_result <- mosaic::mean(formula_bx, data = mods$data)
      j <- 1
      vcols <- c('blue', 'red')
      for (bx_name in bx$names) {
        y_pos1 <- c(means_result[[bx_name]] - sd_result[[bx_name]], means_result[[bx_name]], means_result[[bx_name]] + sd_result[[bx_name]])
        y_pos2 <- c(means_result[[bx_name]] - sd_result[[bx_name]], means_result[[bx_name]] + sd_result[[bx_name]])
        points(c(j-0.3, j-0.3, j-0.3), y_pos1, pch="-", col=vcols[[j%%2 + 1]], cex=c(.9,.9,1.5))
        lines(c(j-0.3, j-0.3), y_pos2, col=vcols[j%%2 + 1])
        j <- j + 1
      }
    }
  }
}

## function to draw bars for lsmeans
drawing_bars_for_lsmeans <- function(lsmeans_mod) {
  library(ggplot2)
  
  for (lsname in names(lsmeans_mod)) {
    lsmeans_grid <- lsmeans_mod[[lsname]]$df
    fill_gg <- NULL
    if (length(lsmeans_mod[[lsname]]$columns) > 1) {
      fill_gg <- lsmeans_mod[[lsname]]$columns[-1]
    }
    print(
      ggplot(
        lsmeans_grid, aes_string(x=lsmeans_mod[[lsname]]$columns[[1]]
                                 , y='lsmean', fill = fill_gg)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
        geom_bar(position=position_dodge(.9), colour="black", stat="identity") +
        geom_errorbar(position=position_dodge(.9), width=.25
                      , aes(ymin=lower.CL, ymax=upper.CL)) +
        scale_fill_manual(values=c("#CCCCCC","#FFFFFF")) +
        theme_bw()
    )
  }
   
}

## function to calculate least-squares means
get_least_squares_means <- function(mods) {
  library(lsmeans)
  
  aov_lsmeans <- list()
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      columns  <- comb_columns[,i]
      lsname <- paste0(columns, collapse = ':')
      llsmod <- lsmeans::lsmeans(mods$ezAov, specs = columns)
      aov_lsmeans[[lsname]] <- list(columns = columns, mod = llsmod, df = as.data.frame(summary(llsmod)))
    }
  }
  
  aocv_lsmeans <- list()
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      columns  <- comb_columns[,i]
      lsname <- paste0(columns, collapse = ':')
      llsmod <- lsmeans::lsmeans(mods$aov.aocv, specs = columns)
      aocv_lsmeans[[lsname]] <- list(columns = columns, mod = llsmod, df = as.data.frame(summary(llsmod)))
    }
  }
  
  aov_sp_lsmeans <- list()
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      columns  <- c('Time', comb_columns[,i])
      lsname <- paste0(columns, collapse = ':')
      llsmod <- lsmeans::lsmeans(mods$ezAov.sp, specs = columns)
      aov_sp_lsmeans[[lsname]] <- list(columns = columns, mod = llsmod, df = as.data.frame(summary(llsmod)))
    }
  }
  
  return(list(aov = aov_lsmeans, aocv  = aocv_lsmeans, aov.sp = aov_sp_lsmeans))
}

## drawing interaction plotrs for lsmenas
drawing_interaction_plots_for_lsmeans <- function(lsmeans_mod, levels = NULL) {
  library(ggplot2)
  
  for (lsname in names(lsmeans_mod)) {
    lsmeans_grid <- lsmeans_mod[[lsname]]$df
    
    if (!is.null(levels)) {
      lsmeans_grid[,'Time'] <- factor(lsmeans_grid$Time, levels = levels)
    }
    
    lscolumns <- lsmeans_mod[[lsname]]$columns[lsmeans_mod[[lsname]]$columns != 'Time'] 
    lscolumns_name <- paste0(lscolumns, collapse = ':')
    if (!(lscolumns_name %in% colnames(lsmeans_grid))) {
      lsmeans_grid[,lscolumns_name] <- factor(
        apply(lsmeans_grid[lscolumns], 1, paste0, collapse=':'))
    }
    print(
      ggplot(lsmeans_grid, aes_string(x='Time', y='lsmean', group=lscolumns_name, color=lscolumns_name)) +
        geom_line() +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
        geom_errorbar(width=.1, aes(ymin=lsmean-SE, ymax=lsmean+SE), colour='black') +
        geom_point(shape=21, size=3, fill='white') +
        theme_bw()
    )
  }
}

## drawing pre vs post
drawing_pre_post_plots_for_lsmeans <- function (lsmeans_mod) {
  
  library(ggplot2)
  
  for (lsname in names(lsmeans_mod)) {
    lsmeans_grid <- lsmeans_mod[[lsname]]$df
    lscolumns <- lsmeans_mod[[lsname]]$columns
    
    gg1 <- mods$data
    gg1[,'pre'] <- mods$data[[mods$pre.test]]
    gg1[,'pos'] <- mods$data[[mods$post.test]]
    if (!(lsname %in% colnames(lsmeans_grid))) {
      gg1[,lsname] <- factor(apply(lsmeans_grid[lscolumns], 1, paste0, collapse=':'))
    }
    
    print(
      ggplot(gg1, aes_string(x='pre', y='pos', colour = lsname, shape = lsname)) +
        #coord_fixed(xlim = c(min(x,y), max(x,y)), ylim = c(min(x,y), max(x,y))) +
        scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
        scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
        scale_colour_manual(values=c('red', 'blue', 'darkgreen', '#E69F00')) +
        geom_smooth(method = lm, se = F, size = 0.45) +
        geom_point(size=1.5) +
        geom_text_repel(aes(label = rownames(gg1))
                        , segment.color = '#888888'
                        , segment.size = 0.25
                        , arrow = arrow(length = unit(0.005, 'npc'))
                        , point.padding = unit(0.4, 'lines') # extra padding
                        , box.padding = unit(0.15, 'lines')
                        , force = 1 # Strength of the repulsion force.
                        , size = 2) +
        theme_light(base_size = 12) +
        xlab('pre-test') +
        ylab('post-test') +
        ggtitle(paste0('Pre-test vs. Post-test for ', lsname))
    )
  }
}

## drawing scatter plots
drawing_scatter_plots <- function(mods) {
  library(car)
  
  for (m in 1:length(mods$between)) {
    comb_columns <- combn(mods$between, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      sdata <- mods$data
      columns  <- comb_columns[,i]
      ncolumn <- paste0(columns, collapse = '.')
      if (!(ncolumn %in% colnames(sdata))) {
        sdata[,ncolumn] <- factor(apply(sdata[columns], 1, paste0, collapse='.'))
      }
      
      scatterplot(as.formula(paste(post.test, '~', pre.test, '|', ncolumn))
                  , data = sdata#, legend.coords = 'bottom'
                  #, main = paste0('Enhanced scatter plot for ', ncolumn)
      )
    }
  }
}

## main function for performing an statistical analysis
do_statistical_analysis_for_pre_post_test <- function(
  data, wid, pre.test, post.test, between, type.test = 'parametric'
  , plotting = TRUE) {
  
  test_size <- test_min_size(data = data, between = between)
  anova_type <- ifelse(test_size$unbalanced, 3, 2)
  
  mods <- get_aov_mods_for_pre_post_test(data, wid, pre.test, post.test, between, type = anova_type)
  test_p <- test_parametric_assumptions(mods = mods)
  
  ##
  if (!test_p$fail) {
    
    test_ph <- test_post_hoc(mods=mods)
    lsmeans_mods <- get_least_squares_means(mods = mods)
    
    if (plotting) {
      drawing_bars_for_lsmeans(lsmeans_mods$aov)
      #drawing_interaction_plots_for_lsmeans(lsmeans_mods$aov.sp, c(mods$pre.test, mods$post.test))
      #drawing_pre_post_plots_for_lsmeans(lsmeans_mods$aocv)
      #drawing_scatter_plots(mods)
      #draw_interaction_plots(mods=mods)
      #draw_mean_boxplots(mods=mods)
    }
  }
  
  return(list(
    anova.type = anova_type
    , lsmeans = lsmeans_mods, test.post.hoc = test_ph
    , test.assumptions = test_p, test.size = test_size, mods = mods
  ))
}

###############################################################################


## 
do_kruskal <- function(dat) {
  #test_dispersion(dat)
}


###
##Parametric: Pearson Product Moment Correlation Coefficient Analysis

#1) Y data for each X must be randomly selected from a normal distribution of Y values
#2) X data for each Y must be randomly selected from a normal distribution of X values

#Non Parametric: Spearman Rank Correlation Coefficient Analysis
##
