
wants <- c('TAM', 'sirt', 'lavaan', 'ggrepel', 'parallel', 'RColorBrewer', 'reshape', 'psych', 'ggplot2', 'dplyr', 'readr', 'readxl', 'multcomp')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

############################################################################
## Functions to pre- and post- processing data                            ##
############################################################################

## Function to get data for rating scale model
get_data_map_for_RSM <- function(sources, min_cat = 1, max_cat = 7) {
  library(readr)
  library(dplyr)
  
  data_map <- mclapply(sources, FUN = function(x) {
    dat <- read_excel(paste0(x$path, x$filename), sheet = x$sheed, col_types = "numeric")
    rdat <- dat[x$wid]
    for (endwith in x$end.withs) {
      rdat <- merge(
        rdat
        , dplyr::select(dat, starts_with(x$wid), ends_with(endwith)))
    }
    for (inv_key in x$inv.keys) {
      rdat[inv_key] <- (min_cat+max_cat)-rdat[inv_key]
    }
    return(rdat)
  }, mc.allow.recursive = FALSE)
  
  return(data_map)
}

############################################################################
## Functions to get TAM models                                            ##
############################################################################

## Remove incorrect TAMs
remove_incorrect_TAMs <- function(tam_models) {
  tmp_tam_models <- tam_models
  for(name in names(tmp_tam_models)) {
    if (name != paste0(colnames(tmp_tam_models[[name]]$resp), collapse = '+')) {
      cat('\n... removing TAM model with name: ', name, ' ...\n')
      tam_models[[name]] <- NULL
    }
  }
  return(tam_models)
}

## Function to get TAM from a name_model using dat
get_TAM <- function(name_model, dat, irtmodel="GPCM") {
  library(dplyr)
  column_names <- strsplit(name_model,"[+]")[[1]]
  dat_r <- dat[column_names] # columns for data.frame
  return(tryCatch(tam.mml(dat_r, irtmodel=irtmodel), error = function(e) NULL)) # use tam to obtain the model
}

## Function to get TAMs models
get_TAMs <- function(dat, column_names, tam_models = NULL, fixed = NULL
                     , min_columns = 3, limit = 20, irtmodel = "GPCM") {
  
  library(TAM)
  library(parallel)
  
  nro_generated_models <- 0
  if (is.null(tam_models)) tam_models <- list()
  column_names <- expand.grid(column_names)
  
  # add fixed columns
  if (!is.null(fixed) & length(fixed) > 0) {
    cnames <- colnames(column_names)
    for (cname in fixed) {
      column_names <- cbind(column_names, rep(cname, nrow(column_names))) 
    }
    colnames(column_names) <- c(cnames, fixed)
  }
  # get name_models
  name_models <- do.call(paste, c(column_names , sep="+"))
  name_models <- gsub("[+]NA", "", gsub("NA[+]","",name_models))
  # generate tam models
  nro_total_models <- 0
  for (i in 1:length(name_models)) {
    if (nchar(name_models[[i]]) < 2) next
    if (nchar(name_models[[i]]) - nchar(gsub("[+]", "", name_models[[i]])) < min_columns-1) next
    nro_total_models <- nro_total_models+1
  }
  
  generated_name_models <- list()
  for (i in 1:length(name_models)) {
    if (nchar(name_models[[i]]) < 2) next
    if (nchar(name_models[[i]]) - nchar(gsub("[+]", "", name_models[[i]])) < min_columns-1) next
    if (any(names(tam_models) == name_models[i])) next
    # use tam to obtain the model
    generated_name_models[name_models[[i]]] <- name_models[[i]]
    nro_generated_models <- nro_generated_models + 1
    if (nro_generated_models >= limit) break
  }
  cat('\n... generating ', length(generated_name_models), ' of ', nro_total_models
      , ' from ', length(tam_models), ' to ', length(tam_models)+length(generated_name_models), ' ...\n')
  
  if (nro_total_models == length(tam_models)+length(generated_name_models)) {
    generated_tam_models <- lapply(generated_name_models, get_TAM, dat=dat, irtmodel = irtmodel)
  } else {
    generated_tam_models <- mclapply(generated_name_models, get_TAM, dat=dat, irtmodel = irtmodel, mc.allow.recursive = FALSE)
  }
  
  for (name in names(generated_tam_models)) {
    if (nchar(name) - nchar(gsub("[+]", "", name)) < min_columns-1) next
    if (class(generated_tam_models[[name]]) != 'tam.mml') next
    tam_models[[name]] <- generated_tam_models[[name]]
  }
  
  tam_models <- remove_incorrect_TAMs(tam_models)
  return(tam_models)
}

## Function to get mistfit information
get_misfits_information <- function(tam_models) {
  
  library(TAM)
  
  tam_names <- c()
  everything_fits <- c()
  mis_infit_params <- c()
  mis_outfit_params <- c()
  
  c_mis_infit_params <- c()
  c_mis_outfit_params <- c()
  
  for (name in names(tam_models)) {
    cat('\n...',name,'...\n')
    
    tam_fit <- tam.fit(tam_models[[name]])
    if (is.null(tam_fit)) next
    item_fit <- tam_fit$item
    
    misfits_in <- as.character(item_fit$parameter[!is.na(item_fit$Infit) & item_fit$Infit > 2])
    misfits_out <- as.character(item_fit$parameter[!is.na(item_fit$Outfit) & item_fit$Outfit > 2])
    
    c_misfits_in <- length(misfits_in)
    c_misfits_out <- length(misfits_out)
    
    misfits_in <- paste0(misfits_in, collapse = ',')
    misfits_out <- paste0(misfits_out, collapse = ',')
    
    tam_names <- c(tam_names, name)
    everything_fits <- c(everything_fits, (c_misfits_in == 0 && c_misfits_out == 0))
    
    mis_infit_params <- c(mis_infit_params, misfits_in)
    mis_outfit_params <- c(mis_outfit_params, misfits_out)
    
    c_mis_infit_params <- c(c_mis_infit_params, c_misfits_in)
    c_mis_outfit_params <- c(c_mis_outfit_params, c_misfits_out)
  }
  return(data.frame(
    name = tam_names, everything.fits = everything_fits
    , mis.infit.param = mis_infit_params, mis.outfit.param = mis_outfit_params
    , c.mis.infit.param = c_mis_infit_params, c.mis.outfit.param = c_mis_outfit_params
    ))
}

## Function to add information for TAM models
add_info_for_TAM_models <- function(tam_models) {
  
  library(TAM)
  
  p <- c()
  X2 <- c()
  SRMR <- c()
  name <- c()
  p_holm <- c()
  WLE.rel <- c()
  EAP.rel <- c()
  srmr_fit <- c()
  
  rel_fit <- c()
  numcols <- c()
  
  model_fit <- c()
  everything_fits <- c()
  max_item_non_fits <- c()
  
  misfits_info <- get_misfits_information(tam_models)
  
  for (name_model in names(tam_models)) {
    tam_mod <- tam_models[[name_model]]
    if (is.null(tam_mod)) next;
    
    # model fit
    fit_mod <- tam.modelfit(tam_mod)
    srmr <- as.numeric(fit_mod$statlist$SRMR)
    pholm <- as.numeric(fit_mod$modelfit.test$p.holm)
    wle_val <- mean(tam.wle(tam_mod)$WLE.rel, na.rm = TRUE)
    
    # p indicates significative error of approximation (MADaQ3)
    # p-holm indicates significative error of approximation (Maximum Chi square)
    model_fit_v <- FALSE
    if (pholm > 0.05 || as.numeric(fit_mod$stat.MADaQ3$p) > 0.05) {
      model_fit_v <- TRUE
    }
    model_fit <- c(model_fit, model_fit_v)
    
    # SRMR less than 0.08 is good
    srmr_v <- 'not good'
    if (srmr < 0.08) {
      srmr_v <- 'good'
    }
    if (srmr >= 0.08 && srmr < 0.1) {
      srmr_v <- 'normal'
    }
    srmr_fit <- c(srmr_fit, srmr_v)
    
    # relability adequacy
    rel_v <- FALSE
    if (!is.null(wle_val) && !is.na(wle_val) &&
        !is.null(tam_mod$EAP.rel) && !is.na(tam_mod$EAP.rel) &&
        wle_val > 0.5 && tam_mod$EAP.rel > 0.5) {
      rel_v <- TRUE
    }
    rel_fit <- c(rel_fit, rel_v)
    
    # model fits
    everything_fits <- c(
      everything_fits
      , misfits_info$everything.fits[misfits_info$name == name_model])
    max_item_non_fits <- c(max_item_non_fits, max(
      misfits_info$c.mis.infit.param[misfits_info$name == name_model],
      misfits_info$c.mis.outfit.param[misfits_info$name == name_model]))
    
    # add extra information
    p <- c(p, as.numeric(fit_mod$stat.MADaQ3$p))
    SRMR <- c(SRMR, srmr)
    p_holm <- c(p_holm, pholm)
    X2 <- c(X2, fit_mod$modelfit.test$maxX2)
    name <- c(name, name_model)
    WLE.rel <- c(WLE.rel, wle_val)
    EAP.rel <- c(EAP.rel, tam_mod$EAP.rel)
    
    numcols <- c(numcols, length(strsplit(name_model, "[+]")[[1]]))
  }
  
  return(list(
    misfits.info = misfits_info,
    information = data.frame(
      name = name, numcols = numcols, model_fit = model_fit, srmr_fit = srmr_fit
      , everything.fits = everything_fits, max.item.non.fits  = max_item_non_fits
      , X2 = X2, p_holm = p_holm, p = p, SRMR = SRMR, rel_fit = rel_fit, WLE.rel = WLE.rel, EAP.rel = EAP.rel)))
}


## Function to evaluate the unidimensionality lavaan
test_lav <- function(tam_mod) {
  
  library(lavaan)
  
  cat('\n... test by lavaan: ', paste0(colnames(tam_mod$resp), collapse = '+'),' ...\n')
  
  # linear CFA with lavaan
  lavmodel <- paste0("\n Ability =~ ", paste(colnames(tam_mod$resp), collapse = "+"), "\n Ability ~~ 1*Ability \n")
  lav_mod <- tryCatch(lavaan::sem(lavmodel , data = tam_mod$resp , missing="fiml", std.lv=TRUE), error = function(e) NULL)
  
  fail <- TRUE
  lav_cfi_val <- NA
  lav_tli_val <- NA
  lav_rmsea_pvalue_val <- NA
  
  if (!is.null(lav_mod) && !is.null(tryCatch(fitMeasures(lav_mod), error = function(e) NULL))) {
    fail <- FALSE
    lav_cfi_val <- as.numeric(fitMeasures(lav_mod, "cfi"))
    lav_tli_val <- as.numeric(fitMeasures(lav_mod, "tli"))
    lav_rmsea_pvalue_val <- as.numeric(fitMeasures(lav_mod, "rmsea.pvalue"))
    if (!is.na(lav_rmsea_pvalue_val) && lav_rmsea_pvalue_val < 0.05) {
      fail <- TRUE
    }
  }
  
  return(list(fail = fail, lav_mod = lav_mod
              , lav_cfi_val = lav_cfi_val, lav_tli_val = lav_tli_val
              , lav_rmsea_pvalue_val = lav_rmsea_pvalue_val))
}

## test unidimensionality by residual pca
test_uni_by_pca <- function(tam_mod) {
  library(TAM)
  library(psych)
  
  res <- IRT.residuals(tam_mod)$residuals
  
  pca_mod <- pca(res, nfactors = ncol(res))
  fail = !all(colSums(abs(as.data.frame(unclass(pca_mod$loadings))) > 0.4) == 1)
  
  return(list(fail = fail))
}

## Function to filter non-unidimensional vs unidimensional TAMs
add_unidimensionality_test_info_for_TAM_models <- function(tam_models, information = NULL, itemequals = NULL) {
  
  resp_detect_tests <- lapply(tam_models, test_detect, itemequals = itemequals)
  resp_test_uni_by_pca <- lapply(tam_models, test_uni_by_pca)
  # detect filtering
  unidim_test <- c()
  DETECT <- c()
  DETECT_VAL <- c()
  DETECT_ASSI <- c()
  DETECT_RATIO <- c()
  test_uni_by_res_pca <- c()
  for (name in names(tam_models)) {
    resp_detect_test <- resp_detect_tests[[name]]
    unidim_test <- c(unidim_test, !resp_detect_test$fail)
    DETECT <- c(DETECT, resp_detect_test$detect)
    DETECT_VAL <- c(DETECT_VAL, resp_detect_test$detect_val)
    DETECT_ASSI <- c(DETECT_ASSI, resp_detect_test$detect_assi)
    DETECT_RATIO <- c(DETECT_RATIO, resp_detect_test$detect_ratio)
    test_uni_by_res_pca <- c(test_uni_by_res_pca, !resp_test_uni_by_pca[[name]]$fail)
  }
  
  detect.infomation <- data.frame(
    name = names(tam_models)
    , unidim_test = unidim_test
    , DETECT = DETECT, DETECT_VAL = DETECT_VAL, DETECT_ASSI = DETECT_ASSI, DETECT_RATIO
    , uni.by.pca = test_uni_by_res_pca)
  
  if (!is.null(information)) {
    detect.infomation <- merge(information, detect.infomation, by = 'name', all.x = TRUE)
  }
  
  resp_lav_tests <- lapply(tam_models, test_lav)
  
  # lavaan filtering
  unidim_lav_test <- c()
  lav_CFI <- c()
  lav_TLI <- c()
  lav_rmsea_pvalue <-c()
  for (name in names(tam_models)) {
    resp_lav_test <- resp_lav_tests[[name]]
    if (!is.null(resp_lav_test)) {
      unidim_lav_test <- c(unidim_lav_test, !resp_lav_test$fail)
      lav_CFI <- c(lav_CFI, resp_lav_test$lav_cfi_val)
      lav_TLI <- c(lav_TLI, resp_lav_test$lav_tli_val)
      lav_rmsea_pvalue <- c(lav_rmsea_pvalue, resp_lav_test$lav_rmsea_pvalue_val)
    } else {
      unidim_lav_test <- c(unidim_lav_test, FALSE)
      lav_CFI <- c(lav_CFI, NA)
      lav_TLI <- c(lav_TLI, NA)
      lav_rmsea_pvalue <- c(lav_rmsea_pvalue, NA)
    }
  }
  
  lav.infomation <- data.frame(
    name = names(tam_models)
    , unidim_lav_test = unidim_lav_test
    , lav_CFI = lav_CFI, lav_TLI = lav_TLI, lav_rmsea_pvalue = lav_rmsea_pvalue)
  
  full.infomation <- merge(detect.infomation, lav.infomation, by = 'name', all.x = TRUE)
  
  ###
  list_nonunidimensional_models <- c()
  list_unidimensional_models <- c()
  for (name in names(tam_models)) {
    if (resp_detect_tests[[name]]$fail || resp_lav_tests[[name]]$fail) {
      list_nonunidimensional_models <- c(list_nonunidimensional_models, name)
    } else {
      list_unidimensional_models <- c(list_unidimensional_models, name)
    }
  }
  
  return(list(
    information = full.infomation
    , full.unidimensional_models = list_unidimensional_models
    , non.full.unidimensional_models = list_nonunidimensional_models
  )
  )
}

## Function to evaluate the unidimensionality by DETECT
test_detect <- function(tam_mod, itemequals = NULL) {
  library(sirt)
  
  # polydetect statistic analysis
  cat('\n... test by detect: ', paste0(colnames(tam_mod$resp), collapse = '+'), ' ...\n')
  
  wle_mod <- tam.wle(tam_mod)
  itemcluster <- colnames(tam_mod$resp)
  if (!is.null(itemequals)) {
    for (n_col in names(itemequals)) {
      itemcluster[itemcluster %in% itemequals[[n_col]]]  <- n_col
    }
  }
  
  # all items are cluster for only one lattent factor
  detect_mod <- conf.detect(data = tam_mod$resp, score = wle_mod$theta, itemcluster = itemcluster)
  
  # evaluate detect value
  detect <- NA
  detect_val <- max(abs(detect_mod$detect.summary['DETECT',]), na.rm = T)
  detect_assi <- max(abs(detect_mod$detect.summary['ASSI',]), na.rm = T)
  detect_ratio <- max(abs(detect_mod$detect.summary['RATIO',]), na.rm = T)
  
  fail <- FALSE
  if (!is.na(detect_val) && detect_val >= 1) {
    fail <- TRUE
    detect <- "Strong multi"
  }
  if (!is.na(detect_val) && detect_val >= 0.4 && detect_val < 1) {
    detect <- "Moderate multi"
  }
  if (!is.na(detect_val) && detect_val >= 0.2 && detect_val < 0.4) {
    detect <- "Weak multi"
  }
  if (!is.na(detect_val) && detect_val < 0.2) {
    detect <- "Unidimensional"
    if (!is.na(detect_assi) && !is.na(detect_ratio) && detect_assi < 0.25 && detect_ratio < 0.36) {
      detect <- "Essential Unidimensional"
    }
  }
  
  return(list(
    fail = fail, detect_mod = detect_mod, detect = detect, detect_val = detect_val
    , detect_assi = detect_assi, detect_ratio = detect_ratio))
}


## load TAM model
load_tam_mod <- function(name_model, prefix, url_str = NULL) {
  
  
  tam_models <- list()
  file_tam_models_str <- paste0(prefix, '_tam_models.RData')
  if (file.exists(file_tam_models_str)) {
    tam_models <- get(load(file_tam_models_str))
  } else if (!is.null(url_str)) {
    url_con <- url(url_str)
    tam_models <- tryCatch(get(load(url_con)), error = function(e) list())
    close(url_con)
  }
  
  return(tam_models[[name_model]])
}

## load and save TAMs to measure change
load_and_save_TAMs_to_measure_skill <- function(dat, column_names, prefix, fixed = NULL, url_str = NULL, min_columns = 3, itemequals = NULL, irtmodel = "GPCM") {
  
  info_tam_models <- NULL
  file_tam_info_str <- paste0(prefix, '_info_tam_models.RData')
  if (file.exists(file_tam_info_str)) {
    info_tam_models <- get(load(file_tam_info_str))
  } else {
    
    # get tam_models
    tam_models <- list()
    file_tam_models_str <- paste0(prefix, '_tam_models.RData')
    if (file.exists(file_tam_models_str)) {
      tam_models <- get(load(file_tam_models_str))
    } else if (!is.null(url_str)) {
      url_con <- url(url_str)
      tam_models <- tryCatch(get(load(url_con)), error = function(e) list())
      close(url_con)
    }
    tam_models <- remove_incorrect_TAMs(tam_models)
    
    # get TAMs information
    repeat {
      curr_length <- length(tam_models)
      tam_models <- get_TAMs(
        dat, column_names = column_names, tam_models = tam_models, fixed = fixed
        , min_columns = min_columns, limit = 20, irtmodel = irtmodel)
      if (curr_length >= length(tam_models)) break
      save(tam_models, file = file_tam_models_str)
    }
    info_tam_models <- add_info_for_TAM_models(tam_models)
    info_tam_models <- add_unidimensionality_test_info_for_TAM_models(
      tam_models, information = info_tam_models$information, itemequals = itemequals)
    save(info_tam_models, file = file_tam_info_str)
  }
  
  return(info_tam_models)
}

############################################################################
## Functions to write report TAM models                                   ##
############################################################################

## Function to write global information
write_tam_global_info_in_wb <- function(mod, wb) {
  library(r2excel)
  library(RColorBrewer)
  
  sheet <- createSheet(wb, sheetName = 'Global-info')
  xlsx.addHeader(wb, sheet, "Global information for a measurement model", startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Information', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, data.frame('Number of items' = mod$nitems
                                      , 'Deviance' = mod$deviance
                                      , 'Log Likelihood' = as.numeric(logLik(mod))
                                      , 'Number of persons' = mod$nstud
                                      , 'EAP.rel' = mod$EAP.rel
                                      , 'n theta nodes' = mod$nnodes
                                      , 'irt.model' = mod$irtmodel), startCol = 1, row.names = F)
  
  fit <- tam.modelfit(mod)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Global fit statistic MADaQ3 and test fit', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(fit$stat.MADaQ3), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Test statistic of global fit based on Chi square', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(fit$modelfit.test), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Model fit statistics', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, t(as.data.frame(fit$fitstat)), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Chi square tests for every item pairs', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(fit$chi2.stat), startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Item residuals', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(fit$residuals), startCol = 1, row.names = F)
  
  width <- 640
  if (ncol(mod$resp) > 3) width <- width + 20*(ncol(mod$resp)-3)
  plotWrightMap <- function () {
    ncat <- mod$maxK        # number of category parameters
    I <- ncol(mod$resp)    # number of items
    itemlevelcolors <- matrix(rep(RColorBrewer::brewer.pal(ncat, "Set2"), I), byrow = TRUE, ncol = ncat)
    # Wright map
    IRT.WrightMap(mod, dim.color = brewer.pal(5, "Set1")
                  , prob.lvl=.625 , thr.sym.col.fg = itemlevelcolors,
                  thr.sym.col.bg = itemlevelcolors , label.items = colnames( mod$resp) )
  }
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Wright Map for Item Response Models', level = 2, startCol = 1)
  xlsx.addPlot(wb, sheet, plotWrightMap, startCol = 1, width = width, height = 640) 
  
}

## Function to write estimate items
write_tam_item_info_in_wb <- function(mod, wb) {
  library(TAM)
  
  sheet <- createSheet(wb, sheetName = 'Estimate-Items')
  xlsx.addHeader(wb, sheet, "Estimate items information for the measurement model", startCol = 1)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Full Item Information', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, mod$item, startCol = 1, row.names = F)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Thurstonian Thresholds (category-wise)', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(tam.threshold(mod)), startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Thurstonian Thresholds (item-wise)', level = 2, startCol = 1)
  tt_item <- as.data.frame(unclass(IRT.threshold(mod, type = "item"))); colnames(tt_item) <- "Threshold"
  xlsx.addTable(wb, sheet, tt_item, startCol = 1, row.names = T)
  
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Item Infit/Outfit Statistic', level = 2, startCol = 1)
  xlsx.addTable(wb, sheet, as.data.frame(tam.fit(mod)$itemfit), startCol = 1, row.names = F)
 
  xlsx.addLineBreak(sheet, 2)
  xlsx.addHeader(wb, sheet, 'Box plot of expected curves', level = 2, startCol = 1)
  for (i in 1:ncol(mod$resp)) {
    plotItem1 <- function() {
      plot(mod, items = i, export = F)
    }
    xlsx.addPlot(wb, sheet, plotItem1, startCol = 1, width = 640, height = 640) 
    plotItem2 <- function() {
      plot(mod, items = i, type = "items", export = F)
    }
    xlsx.addPlot(wb, sheet, plotItem2, startCol = 1, width = 640, height = 640) 
  }
}

## Function to write abilities
write_tam_abilities_in_wb <- function(mod, wb, userids = NULL) {
  library(TAM)
  
  wmod <- tam.mml.wle(mod)
  if (is.null(userids)) userids <- mod$pid
  rdat <- cbind(cbind(data.frame(UserID=userids), mod$resp), 
                as.data.frame(unclass(wmod)))
  
  sheet <- createSheet(wb, sheetName = 'Abilities')
  xlsx.addTable(wb, sheet, rdat, startCol = 1, row.names = F, columnWidth = 25)
}

# Function to write person fit
write_tam_personfit_in_wb <- function(mod, wb, userids = NULL) {
  library(TAM)
  library(sirt)
  
  wmod <- tam.mml.wle(mod)
  
  personfit_df <- sirt::pcm.fit(b = mod$AXsi_[, -1], theta = wmod$theta, dat = mod$resp)$personfit
  
  if (is.null(userids)) userids <- mod$pid
  rdat <- cbind(cbind(data.frame(UserID=userids), mod$resp), personfit_df)
  
  sheet <- createSheet(wb, sheetName = 'Person-fit')
  xlsx.addTable(wb, sheet, rdat, startCol = 1, row.names = F)
}

## Function to write TAM reports 
write_tam_report <- function(mod, path, filename, override = F, userids = NULL) {
  if (!file.exists(paste0(path, filename)) || override) {
    wb <- createWorkbook(type="xlsx")
    
    write_tam_global_info_in_wb(mod, wb)
    write_tam_item_info_in_wb(mod, wb)
    write_tam_personfit_in_wb(mod, wb, userids)
    write_tam_abilities_in_wb(mod, wb, userids)
    
    saveWorkbook(wb, paste0(path, filename))
  }
}

## Function to write plots of measurement model
write_measurement_model_plots <- function(mod, path, override = T) {
  library(r2excel)
  library(RColorBrewer)
  
  # Wright map
  filename <- paste0(path, '00-wrightmap.png')
  if (!file.exists(filename) || override) {
    width <- 640; if (ncol(mod$resp) > 3) width <- width + 20*(ncol(mod$resp)-3)
    
    ncat <- mod$maxK        # number of category parameters
    I <- ncol(mod$resp)    # number of items
    itemlevelcolors <- matrix(rep(RColorBrewer::brewer.pal(ncat, "Set2"), I), byrow = TRUE, ncol = ncat)
    
    png(filename = filename, width = width, height = 640)
    IRT.WrightMap(mod, dim.color = brewer.pal(5, "Set1")
                  , prob.lvl=.625 , thr.sym.col.fg = itemlevelcolors,
                  thr.sym.col.bg = itemlevelcolors , label.items = colnames( mod$resp) )
    dev.off()
  }
  
  # Item response curves
  for (i in 1:ncol(mod$resp)) {
    filename <- paste0(path, '0', i, '-expected-resp-curve.png')
    if (!file.exists(filename) || override) {
      png(filename = filename, width = 640, height = 640)
      plot(mod, items = i, export = F)
      dev.off()
    }
    
    filename <- paste0(path, '0', i, '-resp-curves-all-items.png')
    if (!file.exists(filename) || override) {
      png(filename = filename, width = 640, height = 640)
      plot(mod, items = i, type = "items", export = F)
      dev.off()
    }
  }
  
  # Write thurstonian thresholds
  filename <- paste0(path, '00-thurstonian-thresholds.png')
  if (!file.exists(filename) || override) {
    tt <- as.data.frame(tam.threshold(mod))
    png(filename = filename, width = 640, height = 640)
    dotchart(t(tt), pch = 16, main = "Thurstonian Thresholds", cex = 0.5)
    dev.off()
  }
}
