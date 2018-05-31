wants <- c('reshape', 'ggplot2', 'dplyr', 'readr', 'readxl', 'psych', 'corrplot', 'PerformanceAnalytics')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

###############################################################################
## Functions to get modules                                                  ##
###############################################################################

## Function to get correlation magnitude
get_corr_magnitude <- function(mod) {
  r1 <- mod$r
  diag(r1) <- NA
  r_val <- max(abs(r1), na.rm=T)
  
  mag1 <- 'non-linear'
  if (r_val > 0.3 & r_val <= 0.5) mag1 <- 'weak'
  if (r_val > 0.5 & r_val <= 0.7) mag1 <- 'moderate'
  if (r_val > 0.7 & r_val <= 1.0) mag1 <- 'strong'
  return(mag1)
}

## Function computing the p-value of correlations
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  return(p.mat)
}

## Function to get global data
get_data_for_gobal_corr <- function(corr_mods, participants, wid) {
  
  result <- list()
  
  for (name_pair in names(corr_mods)) {
    mods <- corr_mods[[name_pair]]
    for (sub_name in names(mods)) {
      dat <- result[[sub_name]]
      if (is.null(dat)) {
        dat <- participants[c(wid)]
      }
      rdat <- mods[[sub_name]]$data.full
      result[[sub_name]] <- merge(dat, rdat)
    }
  }
  
  return(result)
}

## Function to get correlation modules
get_corr_pair_mods <- function(participants, iv, wid, between, observed = NULL
                               , corr_var, info_src, include.subs = F, method = "pearson") {
  library(psych)
  
  grid_models <- expand.grid(corr_var)
  name_models <- do.call(paste, c(grid_models , sep="_"))
  name_models <- gsub("[_]NA", "", gsub("NA[_]","", name_models))
  
  factor_columns <- base::unique(c(iv, between, observed))
  factor_columns <- unique(c(iv, factor_columns[!factor_columns %in% iv]))
  
  corr_result <- list()
  # iterates in correlations
  for (i in 1:length(name_models)) {
    
    sub_corr_mods <- list()
    
    dat <- NULL
    columns <- c()
    name_mod <- name_models[[i]]
    for (j in 1:length(grid_models[i,])) {
      
      info <- info_src[[as.character(grid_models[[j]][[i]])]]
      rdat <- read_excel(info$filename, sheet = info$sheed)
      dv <- info$dv
      
      if (!is.null(info$dv.name) && (length(info$dv.name) > 0)) {
        rdat[[info$dv.name]] <- rdat[[info$dv]]
        dv <- info$dv.name
      }
      
      if (is.null(dat)) {
        dat <- rdat[c(info$wid, dv)]
      } else {
        dat <- merge(dat, rdat[c(info$wid, dv)], by.x = by_x, by.y = info$wid)
      }
      columns <- c(columns, dv)
      by_x = info$wid
    }
    
    sub_corr_mods[['main']] <- list(
      data = dat[columns], data.full = dat, mod = corr.test(dat[columns], method = method))
    
    ## sub - modules
    if (include.subs) {
      wdat <- merge(participants, dat, by.x = wid, by.y = by_x)
      for (m in 1:length(factor_columns)) {
        comb_factor_columns <- combn(factor_columns, m, simplify = T)
        
        for (i2 in 1:ncol(comb_factor_columns)) {
          selected_factor_columns  <- comb_factor_columns[,i2]
          
          cname <- paste0(selected_factor_columns, collapse = ':')
          factors <- factor(apply(wdat[selected_factor_columns], 1, paste, collapse='.'))
          for (nlevel in levels(factors)) {
            sub_corr_mods[[nlevel]] <- list(
              data = wdat[factors == nlevel,][columns], data.full = wdat[factors == nlevel,]
              , mod = corr.test(wdat[factors == nlevel,][columns], method = method), method = method)
          }
        }
      }
    }
    
    corr_result[[name_mod]] <- sub_corr_mods
  }
  
  return(corr_result)
}


## Function get matrix mods
get_corr_matrix_mods <- function(participants, corr_pair_mods, dvs, wid = 'UserID', method = "pearson") {
  library(psych)
  
  corr_dat <- get_data_for_gobal_corr(corr_pair_mods, participants, wid)
  
  i <- 1
  result <- list()
  for (part_of_title in names(dvs)) {
    
    j <- 1
    columns <- dvs[[part_of_title]]
    for (sub_name in names(corr_dat)) {
      sub_main <- ''
      if (sub_name != 'main') {
        sub_main <- paste0(' for the group ', sub_name)
      }
      cdat <- corr_dat[[sub_name]]
      
      part_filename <- gsub(
        ':', '', gsub('/', '', gsub(' ', '', paste0(part_of_title, sub_main))))
      filename <- paste0(part_filename, i, '.png')
      
      result[[paste0('corr_',i,'_',j)]] <- list(
        filename = filename
        , title = paste0("Correlation of ", part_of_title, sub_main)
        , mod = corr.test(cdat[columns], method = method)
        , data = cdat[columns]
        , data.full = cdat
        , method = method
      )
      
      j <- j+1
    }
    
    i <- i+1 
  }
  
  return(result)
}

###############################################################################
## Functions to plots correlations results                                   ##
###############################################################################

## Function to write plots of pair charts
write_corr_chart_plots <- function(corr_mods, path, override = T) {
  
  library(psych)
  library(PerformanceAnalytics)
  
  for (model_name in names(corr_mods)) {
    mods <- corr_mods[[model_name]]
    
    for (sub_name in names(mods)) {
      corr_mod <- mods[[sub_name]]
      
      file_name <- gsub(':', '.', gsub('/', '', sub_name))
      sub_title <- sub_name; if (sub_name == 'main') sub_title <- ''
      
      filename <- paste0(path, model_name, file_name, '.png')
      if (!file.exists(filename) || override) { 
        png(filename = filename, width = 640, height = 640)
        try(chart.Correlation(corr_mod$data, method = corr_mod$method, histogram = T, pch=16
                          , main=paste0('Correlation ', sub_title,' for '
                                        , paste0(colnames(corr_mod$data), collapse = ' - '))), silent = T)
        dev.off()
      }
    }
    
  }
}

## Function to plots 
write_corr_matrix_plots <- function(corr_matrix_mods, path, override = T) {
  library(corrplot)
  library(RColorBrewer)
  
  lapply(corr_matrix_mods, FUN = function(mod) {
    ##
    col <- colorRampPalette(c("#BB4444", "#EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
    
    M <- cor(mod$data, method = mod$method)
    p_mat <- cor.mtest(mod$data, method = mod$method)
    
    filename = paste0(path, mod$filename)
    if (!file.exists(filename) || override) { 
      png(filename = filename, width = 640, height = 640)
      corrplot(
        M, method="circle", col=col(200),
        type="upper", order="original",
        addCoef.col="black", # Add coefficient of correlation
        tl.col="black", tl.srt=45, #Text label color and rotation
        # Combine with significance
        p.mat = p_mat, sig.level = 0.05, insig = "blank",
        # hide correlation coefficient on the principal diagonal
        main = mod$title, # rect.col = black, outline = TRUE,
        tl.cex=0.75, number.cex = 0.75, cl.cex = 0.65,
        diag=FALSE 
      )
      dev.off()
    }
    
  })
  
}

###############################################################################
## Functions to write correlations reports                                   ##
###############################################################################

write_corr_matrix_report <- function(corr_matrix_mods, filename, override = T) {
  library(r2excel)
  
  if (!file.exists(filename) || override) {
    wb <- createWorkbook(type="xlsx")
    
    for (sheetName in names(corr_matrix_mods)) {
      corr_info <- corr_matrix_mods[[sheetName]]
      
      write_corr_in_wb(
        corr_info$mod, wb, title=corr_info$title, method = corr_info$method
        , data = corr_info$data, data.full = corr_info$data.full
        , sheetName = paste0(sheetName, '_', corr_info$method))
    }
    saveWorkbook(wb, filename)
  }
}

write_corr_in_wb <- function(mod, wb, title="", magnitude = 'non-linear', i = 0
                             , method = "pearson", data = NULL, data.full = NULL, sheetName = NULL) {
  library(r2excel)
  
  if (is.null(sheetName)) {
    sheetName <- paste0(magnitude, '_', method, '_', i)
  }
  
  sheet <- xlsx::createSheet(wb, sheetName = sheetName)
  xlsx.addHeader(wb, sheet, paste0("Correlation information for ", title, " using the method: ", method), startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Correlation matrix", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(mod$r), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Matrix of t-test value", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(mod$t), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Probability of values (p-values)", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(mod$p), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, "Confidence intervals", level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(mod$ci), startCol = 1, row.names = T)
  
  if (!is.null(data) && nrow(data) > 0) {
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Data source for ", title), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, data, startCol = 1, row.names = F)
  }
  if (!is.null(data.full) && nrow(data.full) > 0) {  
    xlsx.addLineBreak(sheet, 2)
    xlsx.addHeader(wb, sheet, paste0("Data full source for ", title), level = 2, startCol = 1)
    xlsx.addTable(wb, sheet, data.full, startCol = 1, row.names = F)
  }
}

write_corr_mods_in_wb <- function(corr_mods, wb, magnitude = 'non-linear') {
  
  i <- 1
  for (pair_factor_name in names(corr_mods)) {
    mods <- corr_mods[[pair_factor_name]]
    for (sub_set_name in names(mods)) {
      
      cat('\n ... processing ', pair_factor_name, ' in ', sub_set_name, ' for ', magnitude, '\n')
      
      corr_mod <- mods[[sub_set_name]]
      mtitle <- paste0(paste0(colnames(corr_mod$data), collapse = " - "), " in ", sub_set_name)
      
      mag <- get_corr_magnitude(corr_mod$mod)
      if (mag == magnitude) {
        write_corr_in_wb(corr_mod$mod, wb, mtitle, magnitude, i, corr_mod$method
                         , data = corr_mod$data, data.full = corr_mod$data.full)
      }
      
      i <- i+1
    }
  }
  
}

## Function to write anova analysis report
write_corr_pair_report <- function(corr_mods, path, override = T, magnitudes = c('strong', 'moderate', 'weak')) {
  
  library(r2excel)
  
  for (magnitude in magnitudes) {
    filename = paste0(path, "SimpleCorrPairAnalysis-", magnitude,".xlsx")
    
    if (!file.exists(filename) || override) {
      wb <- createWorkbook(type="xlsx")
      write_corr_mods_in_wb(corr_mods, wb, magnitude)
      saveWorkbook(wb, filename)
    }
  }
  
}


