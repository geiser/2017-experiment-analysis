
wants <- c('coin', 'reshape', 'dplyr', 'r2excel', 'readr')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

library(coin)
library(dplyr)
library(readr)
library(reshape)
library(r2excel)

## plot function of wilcox_analysiss
plot_wilcox.test <- function(wt, title="", sub = NULL, ylab = NULL, notch = T, inv.col = F, draw.conf.int = T) {
  
  x <- wt$data$x
  y <- wt$data$y
  
  pch1=16; pch2=17
  pcol1=10; pcol2=4
  pcol = c("white", "lightgrey")
  if (inv.col) {
    pch1 = 17; pch2 = 16
    pcol1 = 4; pcol2 = 10
    pcol = c("lightgrey", "white")
  }
  
  bp <- boxplot(y ~ x, boxwex=0.2, notch=notch, col=pcol, ylab=ylab)
  title(title, sub = sub)
  
  # drawing data as points
  stripchart(y[x==levels(x)[1]], col=8, pch=pch1, add=T, at=0.7, cex=.7, method="jitter", vertical=T)
  stripchart(y[x==levels(x)[2]], col=8, pch=pch2, add=T, at=1.7, cex=.7, method="jitter", vertical=T)
  
  # drawing line wilcox conf.interval
  if (draw.conf.int) {
    wt <- tryCatch(wilcox.test(y[x==levels(x)[1]], conf.int=T), error = function(e) NULL)
    if (!is.null(wt)) {
      points(c(0.7,0.7,0.7), c(wt$conf.int, wt$estimate), pch="-", col=pcol1, cex=c(.9,.9,1.5))
      lines(c(0.7,0.7), wt$conf.int, col=pcol1)
    }
    
    wt <- tryCatch(wilcox.test(y[x==levels(x)[2]], conf.int=T), error = function(e) NULL)
    if (!is.null(wt)) {
      points(c(1.7,1.7,1.7), c(wt$conf.int, wt$estimate), pch="-", col=pcol2, cex=c(.9,.9,1.5))
      lines(c(1.7,1.7), wt$conf.int, col=pcol2)
    }
  }
}

## Function to get wilcox_module
get_wilcox_mod <- function(x, y,  alternative = "two.sided") {
  
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
  magnitude <- 'none'
  if (r >= 0.1 && r < 0.3) magnitude <- 'small'
  if (r >= 0.3 && r < 0.5) magnitude <- 'medium'
  if (r >= 0.5) magnitude <- 'large'
  
  result <- data.frame(
    "Group" = c(levels(x)[1], levels(x)[2])
    , "N" = c(length(x[x==levels(x)[1]]), length(x[x==levels(x)[2]]))
    , "Median" = c(median(sdata$y[sdata$x == levels(x)[1]]), median(sdata$y[sdata$x == levels(x)[2]]))
    , "Mean Ranks" = c(mean(sdata$r[sdata$x == levels(x)[1]]), mean(sdata$r[sdata$x == levels(x)[2]]))
    , "Sum Ranks" = c(sum(sdata$r[sdata$x == levels(x)[1]]), sum(sdata$r[sdata$x == levels(x)[2]]))
    , "U" = c(U, U)
    , "Z" = c(Z, Z)
    , "p-value" = c(pvalue, pvalue)
    , "r" = c(r, r)
    , "magnitude" = c(magnitude, magnitude)
  )
  
  return(list(data = sdata, result = result))
}

## Function to get wilcox test modules 
get_wilcox_mods <- function(dat, dv, iv, between) {
  
  result <- list()
  columns <- unique(c(iv, between[!between %in% iv]))
  
  for (m in 1:length(columns)) {
    comb_columns <- combn(columns, m, simplify = T)
    for (i in 1:ncol(comb_columns)) {
      selected_columns  <- comb_columns[,i]
      if (selected_columns[[1]] != iv) next
      cname <- paste0(selected_columns, collapse = ':')
      factors <- factor(apply(dat[selected_columns], 1, paste, collapse='.'))
      level_pairs <- combn(levels(factors), 2)
      
      mods <- list()
      for (j in 1:ncol(level_pairs)) {
        level_pair <- level_pairs[,j]
        
        rdat <- dat[factors %in% level_pair,]
        y <- rdat[[dv]]
        x <- factors[factors %in% level_pair]
        
        wt_1 <- get_wilcox_mod(x, y, alternative = 'less')
        wt_2 <- get_wilcox_mod(x, y, alternative = 'greater')
        wt_3 <- get_wilcox_mod(x, y, alternative = 'two.sided')
        
        mods[[paste0(level_pair, collapse = ':')]] <- list(dat = rdat, less = wt_1, greater = wt_2, two.sided = wt_3)
      }
      result[[cname]] <- mods
    }
  }
  return(result)
}

## function to write wilcoxon test in sheet
write_wts_in_wb <- function(wt_mods, wb, iv, i, title = "", ylab = "Score") {
  library(r2excel) 
  
  wt_mod <- wt_mods[[i]]
  sheet <- xlsx::createSheet(wb, sheetName = paste0(sub(':', '_', iv),"_", i))
  xlsx.addHeader(wb, sheet, paste0("Wilcoxon Analysis for ", title, " in ", iv, " between ", names(wt_mods)[[i]], collapse = ''), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Wilcoxon test results", level = 2, startCol = 1)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: less", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, wt_mod$less$result, startCol = 1, row.names = F)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: greater", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, wt_mod$greater$result, startCol = 1, row.names = F)
  xlsx.addHeader(wb, sheet, "Alternative hypothesis: two.sided", level = 3, startCol = 1)
  xlsx.addTable(wb, sheet, wt_mod$two.sided$result, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Box plots for wilcoxon tests", level = 2, startCol = 1)
  plotWT <- function() {
    plot_wilcox.test(wt_mod$two.sided, title = title, ylab = ylab)
  }
  xlsx.addPlot(wb, sheet, plotWT, width = 640, height = 640, startCol = 1)
  plotWT <- function() {
    plot_wilcox.test(wt_mod$two.sided, title = title, ylab = ylab, inv.col = T)
  }
  xlsx.addPlot(wb, sheet, plotWT, width = 640, height = 640, startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Wilcoxon data", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, wt_mod$dat, startCol = 1, row.names = F)
}

## Function to write summary of set wt mods
write_wts_summary_in_wb <- function(set_wt_mods, wb, title = "") {
  
  library(r2excel) 
  
  sheet <- xlsx::createSheet(wb, sheetName = "Summary")
  xlsx.addHeader(wb, sheet, paste0("Summary of Wilcoxon Analysis for ", title, collapse = ''), startCol = 1)
  
  for (iv in names(set_wt_mods)) {
    wt_mods <- set_wt_mods[[iv]]
    for (i in 1:length(wt_mods)) {
      wt_mod <- wt_mods[[i]]
      
      if (max(wt_mod$less$result$p.value) <= 0.05) {
        xlsx.addLineBreak(sheet, 2)
        xlsx.addHeader(wb, sheet, paste0("Wilcoxon test results for ", iv, " - Alternative hypothesis: less"), level = 2, startCol = 1)
        xlsx.addTable(wb, sheet, wt_mod$less$result, startCol = 1, row.names = F)
      }
      if (max(wt_mod$greater$result$p.value) <= 0.05) {
        xlsx.addLineBreak(sheet, 2)
        xlsx.addHeader(wb, sheet, paste0("Wilcoxon test results for ", iv, " - Alternative hypothesis: greater"), level = 2, startCol = 1)
        xlsx.addTable(wb, sheet, wt_mod$greater$result, startCol = 1, row.names = F)
      }
    }
  }
}

## Function to write wilcoxon analysis
write_wilcoxon_simple_analysis_report <- function(set_wt_mods, filename, title = "", ylab = "Difference Score", override = T, data = NULL) {
  
  library(r2excel)
  
  if (!file.exists(filename) || override) {
    wb <- createWorkbook(type="xlsx")
    write_wts_summary_in_wb(set_wt_mods, wb, title = title)
    for (iv in names(set_wt_mods)) {
      wt_mods <- set_wt_mods[[iv]]
      for (i in 1:length(wt_mods)) {
        write_wts_in_wb(wt_mods, wb, iv, i, title = title, ylab = ylab)
      }
    }
    if (!is.null(data)) {
      sheet <- xlsx::createSheet(wb, sheetName = "data")
      xlsx.addTable(wb, sheet, data, startCol = 1, row.names = F)
    }
    saveWorkbook(wb, filename)
  }
}

## Function to write plots of wilcoxon test
write_wilcoxon_plots <- function(set_wt_mods, ylab, title, path, override = T) {
  for (iv in names(set_wt_mods)) {
    wt_mods <- set_wt_mods[[iv]]
    for (i in 1:length(wt_mods)) {
      wt_mod <- wt_mods[[i]]
      
      filename <- paste0(iv, '_', names(wt_mods)[[i]], ".png")
      filename <- gsub(':', '.', gsub('/', '', filename))
      filename <- paste0(path, filename)
      
      filename_inv <- paste0(iv, '_', names(wt_mods)[[i]], "_inv.png")
      filename_inv <- gsub(':', '.', gsub('/', '', filename_inv))
      filename_inv <- paste0(path, filename_inv)
      
      if (!file.exists(filename) || override) {
        png(filename = filename, width = 640, height = 640)
        plot_wilcox.test(wt_mod$two.sided, title = title, ylab = ylab)
        dev.off()
        png(filename = filename_inv, width = 640, height = 640)
        plot_wilcox.test(wt_mod$two.sided, title = title, ylab = ylab, inv.col = T)
        dev.off()
      }
    }
  }
}
