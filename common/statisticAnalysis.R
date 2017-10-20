
wants <- c('coin', 'sirt', 'lavaan', 'psych', 'reshape', 'dplyr', 'readr')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])


## Function to get aov mods for pre and post-test
get_aov_mods_for_pre_pos <- function(dat, wid, pre, pos, between, type = 3
                                     , diff_cname = 'Diff', outcome_cname = 'Score', times = NULL) {
  library(car) 
  library(afex)
  library(stats)
  
  if (is.null(times)) times <- c('pre-test', 'post-test')
  
  # pre-processing data
  wdat <- data.frame(factor(dat[[wid]]), dat[[pre]], dat[[pos]])
  wdat[,diff_cname] <- dat[[pos]] - dat[[pre]]
  colnames(wdat) <- c(wid, pre, pos, diff_cname)
  for (cname in c(between)) wdat[,cname] <- factor(dat[[cname]])
  rownames(wdat) <- wdat[[wid]]
  
  af <- as.formula(paste0(diff_cname, " ~ ", paste0(between, collapse = " * ")))
  mod <- aov(formula = af, data = wdat) 
  
  ##
  ldat <- data.frame(factor(rep(wdat[,wid], 2)), c(wdat[[pre]], wdat[[pos]]),
                     factor(rep(times, each=nrow(wdat))))
  colnames(ldat) <- c(wid, outcome_cname, 'Phase')
  rownames(ldat) <- within(expand.grid('A'=wdat[[wid]], 'B'=c('1','2')), C <- paste(A, B, sep='.'))[['C']]
  for (cname in between) ldat[,cname] <- factor(rep(wdat[[cname]], 2))
  
  ## get modules
  ezAov1 <- aov_ez(data = wdat, id = wid, dv = diff_cname, between = between
                   , observed = between[-1], type = type, print.formula = T, factorize = F)
  ezAov2 <- aov_ez(data = wdat, id = wid, dv = pos, between = between, covariate = pre
                   , observed = c(between[-1], pre), type = type, print.formula = T, factorize = F)
  ezAov3 <- aov_ez(data = ldat, id = wid, dv = outcome_cname, between = between
                   , within = 'Phase', observed = between[-1], type = type, print.formula = T)
  
  return(list(mod = mod, aov = ezAov1, aocv = ezAov2, sp = ezAov3, wdat = wdat, ldat = ldat))
}

## main function for performing an statistical analysis
do_statistical_analysis_for_pre_post_test <- function(data, wid, pre.test, post.test, between, type.test = 'parametric'
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

