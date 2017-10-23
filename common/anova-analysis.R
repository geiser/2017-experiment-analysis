
wants <- c('coin', 'sirt', 'lavaan', 'psych', 'reshape', 'dplyr', 'readr', 'effsize')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

#############################################################################
## Functions to performs ANOVA and t-test                                  ##
#############################################################################

## Function to get ids for anova
get_ids_outliers_for_anova <- function(dat, wid, dv, iv, between, observed = NULL) {
  
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
  
  effectsize_mod <- cohen.d(sdata$y[sdata$x == levels(x)[1]], sdata$y[sdata$x == levels(x)[2]], hedges.correction = T)
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
        "current.size is = ", csize, " and min.size must be = ", minimal_size
        , " for the group: '", name_group, "'. Min size sample for parametric test isn't satified"))
      codes <- c(codes, "FAIL: min.size")
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', "
        , "we recommend non perform statistic test."))
    } else if (csize < recomended_size) {
      descriptions <- c(descriptions, paste0(
        "current.size is = ", csize, " and recommended.size must be = ", recomended_size
        , " for the group: '", name_group, "'. Size sample for parametric test isn't recomended"))
      codes <- c(codes, "WARN: sample.size")
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', "
        , "we recommend the use of non parametric test."))
    } else {
      error_warning_list <- c(error_warning_list, paste0(
        "For the group: '", name_group, "', "
        , "you can perform a parametric test with a non-normal distribution"))
    }
  }
  
  return(list(
    table.frequency = tf_size , fail = fail, balanced = balanced
    , fails.warnings = data.frame("code" = codes, "description" = descriptions)
    , error.warning.list = error_warning_list))
}

## Function to get anova mods for parametric test
do_anova <- function(dat, wid, dv, iv, between, observed = NULL, within = NULL, p_limit = 0.05) {
  library(car)
  library(afex)
  library(dplyr)
  library(stats)
  
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
  }
  
  homogeneity.fail <- FALSE
  levene_mod <- leveneTest(formula_aov, data = wdat) # homogeneity
  levene_pvalue <- levene_mod$`Pr(>F)`[[1]]
  if (levene_pvalue <= p_limit) {
    homogeneity.fail <- TRUE
    descriptions <- c(descriptions, "Null hypothesis of Levene's Test rejected")
    error_warning_list <- c(error_warning_list, 'The null hypothesis "H0: homogeneity of variance" has been rejected - There is a difference between the variances of sample')
    codes <- c(codes, "FAIL: Levene's")
  }
  
  ## post-hoc test
  tukey_mod <- TukeyHSD(ezAov$aov)
  
  means_mod <- lsmeans(ezAov, as.formula(paste0('~', paste0(columns, collapse = '|'))))
  contrast_mod <- contrast(means_mod, method = 'pairwise')
  df_lsmeans = as.data.frame(summary(means_mod))
  df_contrasts = as.data.frame(summary(contrast_mod))
  
  ## pair using t-test
  t.test_pairs <- list()
  columns <- unique(c(iv, columns[!columns %in% iv]))
  
  for (m in 1:length(columns)) {
    comb_columns <- combn(columns, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      selected_columns  <- comb_columns[,i] 
      if (selected_columns[[1]] != iv) next
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
## Functions to draw anova plots                                           ##
#############################################################################

## Function to plot assumptions based on the result of anova
plot_anova_assumptions <- function(result, dv) {
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
plot_t.test <- function(tt, title="", sub = NULL, ylab = NULL, notch = F, inv.col = F, draw.conf.int = T) {
  
  pch <- c(16,17)
  pcol <- c("white","lightgrey")
  vcols <- c('blue', 'red')
  if (inv.col) {
    pch <- c(17,16)
    pcol <- c("lightgrey","white")
    vcols <- c('red', 'blue')
  }
  
  bx <- boxplot(y ~ x, data=tt$data, boxwex=0.2, col=pcol, notch = notch, ylab=ylab)
  title(title, sub = sub)
  stripchart(y ~ x, data=tt$data, cex=0.75, pch=pch, col=8, add=T, at = seq(from=0.7, by=1, length.out = length(bx$names)), method = 'jitter', vertical=T)
  
  if (draw.conf.int) {
    j <- 1
    for (bx_name in bx$names) {
      ci_lower <- tt$result$CI.lower[tt$result$Group == bx_name]
      ci_upper <- tt$result$CI.upper[tt$result$Group == bx_name]
      points(c(j-0.3, j-0.3, j-0.3), c(ci_lower, (ci_lower+ci_upper)/2, ci_upper), pch="-", col=vcols[[j%%2 + 1]], cex=c(.9,.9,1.5))
      lines(c(j-0.3, j-0.3), c(ci_lower, ci_upper), col=vcols[j%%2 + 1])
      j <- j + 1
    }
  }
}

## Function to write plots of t-test
write_anova_plots <- function(anova_result, ylab, title, path, override = T) {
  
  mod <- anova_result$plotAov
  sub <- anova_result$formula.str
  
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
  
  ## box plots for the pairs
  set_tt_mods <- anova_result$t.test.pairs
  for (iv in names(set_tt_mods)) {
    tt_mods <- set_tt_mods[[iv]]
    for (i in 1:length(tt_mods)) {
      tt_mod <- tt_mods[[i]]
      
      filename <- paste0(iv, '_', names(tt_mods)[[i]], ".png")
      filename <- gsub(':', '.', gsub('/', '', filename))
      filename <- paste0(path, filename)
      
      filename_inv <- paste0(iv, '_', names(tt_mods)[[i]], "_inv.png")
      filename_inv <- gsub(':', '.', gsub('/', '', filename_inv))
      filename_inv <- paste0(path, filename_inv)
      
      if (!file.exists(filename) || override) {
        png(filename = filename, width = 640, height = 640)
        plot_t.test(tt_mod$two.sided, title = title, ylab = ylab)
        dev.off()
        png(filename = filename_inv, width = 640, height = 640)
        plot_t.test(tt_mod$two.sided, title = title, ylab = ylab, inv.col = T)
        dev.off()
      }
    }
  }
}

#############################################################################
## Functions to write report of anova                                      ##
#############################################################################

## Function to write anova summary
write_anova_summary_in_wb <- function(anova_result, wb, title = "") {
  
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Summary")
  xlsx.addHeader(wb, sheet, paste0("Summary of ANOVA for ", title), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Anova Table (Type ", anova_result$anova.type, " tests) for ", anova_result$formula.str), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(anova_result$ezAov$anova_table), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Anova Table (Type ", anova_result$anova.type, " tests) for ", anova_result$formula.str), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(anova_result$ezAov$Anova), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Fail and warnings in Anova for ", title), level = 2, startCol = 1)
  if (nrow(anova_result$fails.warnings) > 0) {
    xlsx.addTable(wb, sheet, anova_result$fails.warnings, startCol = 1, row.names = T)
  }
  if (length(anova_result$error.warning.list) > 0) {
    xlsx.addParagraph(wb, sheet, paste0(anova_result$error.warning.list, collapse = "\n"), startCol = 1)
  }
}

## Function to write anova assumptions
write_anova_assumptions_in_wb <- function(anova_result, wb, title = "") {
  
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Assumptions")
  xlsx.addHeader(wb, sheet, paste0("ANOVA assumptions for ", title), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0(anova_result$shapiro$method," for ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, data.frame(W = anova_result$shapiro$statistic, p.value = anova_result$shapiro$p.value), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots for normality test", level = 2, startCol = 1)
  plotNormality <- function() {
    plot(anova_result$plotAov, 2, sub = anova_result$formula.str, main = paste0('Normality for ', title))
  }
  xlsx.addPlot(wb, sheet, plotNormality, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Levene's Test for Homogeneity of Variance in ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(anova_result$levene), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots for homogeneity of variance", level = 2, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(anova_result$plotAov, 1, sub = anova_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(anova_result$plotAov, 3, sub = anova_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(anova_result$plotAov, 5, sub = anova_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(anova_result$plotAov, 4, sub = anova_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  plotHomogeneity <- function() {
    plot(anova_result$plotAov, 6, sub = anova_result$formula.str, main = paste0('Homogeneity for ', title))
  }
  xlsx.addPlot(wb, sheet, plotHomogeneity, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Minimum Sample Size Test for ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, anova_result$test.min.size$table.frequency, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Errors and Warnings in Sample Size Test for ANOVA in ", title), level = 2, startCol = 1)
  if (nrow(anova_result$test.min.size$fails.warnings) > 0) {
    xlsx.addTable(wb, sheet, anova_result$test.min.size$fails.warnings, startCol = 1, row.names = F)
  }
  if (length(anova_result$test.min.size$error.warning.list) > 0) {
    xlsx.addLineBreak(sheet, 1)
    xlsx.addParagraph(wb, sheet, paste0(anova_result$test.min.size$error.warning.list, collapse = "\n"), startCol = 1)
  }
  
  if (!anova_result$test.min.size$fail) {
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
write_post_hoc_in_wb <- function(anova_result, wb, title = "") {
  library(r2excel)
  
  sheet <- xlsx::createSheet(wb, sheetName = "Post-hoc")
  xlsx.addHeader(wb, sheet, paste0("Post-hoc Tukey Honestly Significant Difference (HSD) Test for ", title), startCol = 1)
  
  for (name in names(anova_result$post.hoc$tukey)) {
    dframe <- anova_result$post.hoc$tukey[[name]]
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Comparisons of means for ", name), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, as.data.frame(dframe), startCol = 1, row.names = T)
  }
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, paste0("Contrast Matrices for ", title), level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, anova_result$post.hoc$contrasts, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Least Squares Means and Confidence Intervals", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, anova_result$post.hoc$lsmeans, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Plots", level = 2, startCol = 1)
  plotTukey <- function() {
    plot(anova_result$post.hoc$tukey, sub = anova_result$formula.str, cex.axis = 0.5, cex.lab = 0.5, cex.main=0.5)
  }
  xlsx.addPlot(wb, sheet, plotTukey, width = 1024, height = 1024, startCol = 1)
  plotMeans <- function() {
    plot.design(as.formula(anova_result$formula.str), ask = F, fun=mean,
                sub = anova_result$formula.str, data = anova_result$ezAov$aov$model, main = paste0('Group means for ', title))
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
write_tts_in_wb <- function(tt_mods, wb, iv, i, title = "", ylab = "Score") {
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
    plot_t.test(tt_mod$two.sided, title = title, ylab = ylab)
  }
  xlsx.addPlot(wb, sheet, plotTT, width = 640, height = 640, startCol = 1)
  plotTT <- function() {
    plot_t.test(tt_mod$two.sided, title = title, ylab = ylab, inv.col = T)
  }
  xlsx.addPlot(wb, sheet, plotTT, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Student's t-Test data", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, tt_mod$dat, startCol = 1, row.names = F)
}


## Function to write anova analysis report
write_anova_analysis_report <- function(anova_result, filename, title = "", ylab = "Score", override = T) {
  library(r2excel)
  if (!file.exists(filename) || override) {
    wb <- createWorkbook(type="xlsx")
    
    write_anova_summary_in_wb(anova_result, wb, title)
    write_anova_assumptions_in_wb(anova_result, wb, title)
    write_post_hoc_in_wb(anova_result, wb, title)
    
    set_tt_mods <- anova_result$t.test.pairs
    write_anova_pair_ttest_summary_in_wb(set_tt_mods, wb, title)
    for (iv in names(set_tt_mods)) {
      tt_mods <- set_tt_mods[[iv]]
      for (i in 1:length(tt_mods)) {
        write_tts_in_wb(tt_mods, wb, iv, i, title = title, ylab = ylab)
      }
    }  
    
    sheet <- xlsx::createSheet(wb, sheetName = "data")
    xlsx.addTable(wb, sheet, anova_result$data, startCol = 1, row.names = F)
    
    ##
    saveWorkbook(wb, filename)
  }
}

