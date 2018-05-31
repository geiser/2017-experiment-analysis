
wants <- c('TAM', 'sirt', 'lavaan', 'ggrepel', 'parallel', 'RColorBrewer', 'reshape', 'psych', 'ggplot2', 'dplyr', 'readr', 'readxl', 'multcomp', 'WrightMap')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

############################################################################
## Functions to processing data for building measurment intrument         ##
############################################################################

## Function to get stacking data
get_stacking_data <- function(pre_dat, pos_dat, wid, items.pre, items.pos, same.items) {
  same_items_pre <- same.items[['pre']]
  same_items_pos <- same.items[['pos']]
  rdat <- merge(pre_dat, pos_dat, by = wid)
  
  pre_data <- rdat[unique(c(wid, items.pre))]
  rownames(pre_data) <- rdat[[wid]]
  pos_data <- rdat[unique(c(wid, items.pos))]
  rownames(pos_data) <- rdat[[wid]]
  
  res_dat <- data.frame(idx=c(1:(nrow(rdat)*2)))
  for (i in 1:length(same_items_pre)) {
    pre_cname <- same_items_pre[[i]]
    pos_cname <- same_items_pos[[i]]
    cname <- paste0(pre_cname, pos_cname)
    res_dat[[cname]] <- c(rdat[[pre_cname]], rdat[[pos_cname]])
  }
  for (cname in items.pre[!items.pre %in% same_items_pre]) {
    res_dat[[cname]] <- c(rdat[[cname]], rep(NA,nrow(rdat)))
  }
  for (cname in items.pos[!items.pos %in% same_items_pos]) {
    res_dat[[cname]] <- c(rep(NA,nrow(rdat)), rdat[[cname]])
  }
  res_dat <- res_dat[,-1]
  
  return(list(resp = res_dat, pre.data = pre_data, pos.data = pos_data))
}

## Function to get data for rating scale model
get_data_map_for_RSM <- function(sources, min_cat = 1, max_cat = 7, is.excel.src = F) {
  library(readr)
  library(readxl)
  library(dplyr)
  library(xlsx)
  
  data_map <- lapply(sources, FUN = function(x) {
    if (is.excel.src) {
      dat <- readxl::read_excel(x$filename, sheet = x$sheed, col_types = "numeric")
    } else {
      dat <- readr::read_csv(x$filename)
    }
    rdat <- dat[x$wid]
    for (endwith in x$end.withs) {
      rdat <- merge(rdat, dplyr::select(dat, starts_with(x$wid), ends_with(endwith)))
    }
    
    for (inv_key in x$inv.keys) {
      rdat[inv_key] <- (min_cat+max_cat)-rdat[inv_key]
    }
    
    #
    for (cname in colnames(rdat)) {
      if (x$wid != cname) {
        rdat[cname] <- rdat[cname] - min_cat
      }
    }
    
    return(rdat)
  })
  
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
get_TAM <- function(name_model, dat, irtmodel="GPCM", wid = "UserID") {
  library(dplyr)
  column_names <- strsplit(name_model,"[+]")[[1]]
  dat_r <- dat[column_names] # columns for data.frame
  pid = dat[[wid]]
  return(tryCatch(tam.mml(dat_r, irtmodel=irtmodel, pid = pid), error = function(e) NULL)) # use tam to obtain the model
}

## Function to get TAMs models
get_TAMs <- function(dat, column_names, tam_models = NULL, fixed = NULL
                     , fixed_sets = NULL
                     , min_columns = 3, limit = 50, irtmodel = "GPCM") {
  
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
    
    if (!is.null(fixed_sets)) {
      there_is_one <- FALSE
      some_pair_match <- FALSE
      for (name_fix in names(fixed_sets)) {
        fixed_set <- fixed_sets[[name_fix]]
        contain_set <- lapply(fixed_set, grep, name_models[[i]])
        if (any(contain_set > 0, na.rm = T)) there_is_one <- TRUE
        if (all(contain_set > 0, na.rm = T)) some_pair_match <- TRUE
      }
      if (!some_pair_match && there_is_one) next
    }
    
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
test_lav <- function(tam_mod = NULL, estimator = "ML", resp = NULL) {
  
  library(lavaan)
  if (!is.null(tam_mod)) { resp <- tam_mod$resp }
  
  cat('\n... test by lavaan: ', paste0(colnames(resp), collapse = '+'),' ...\n')
  
  # linear CFA with lavaan
  lavmodel <- paste0("\n Ability =~ ", paste(colnames(resp), collapse = "+"), "\n Ability ~~ 1*Ability \n")
  lav_mod <- tryCatch(lavaan::sem(lavmodel , data = resp, std.lv=TRUE, estimator = estimator), error = function(e) NULL)
  
  fail <- TRUE
  lav_df_val <- NA
  lav_chisq_val <- NA
  lav_agfi_val <- NA
  lav_tli_val <- NA
  lav_cfi_val <- NA
  lav_rmsea_val <- NA
  lav_rmsea_lwr_val <- NA
  lav_rmsea_upr_val <- NA
  lav_rmsea_pvalue_val <- NA
  
  if (!is.null(lav_mod) && !is.null(tryCatch(fitMeasures(lav_mod), error = function(e) NULL))) {
    fail <- FALSE
    lav_df_val <- as.numeric(fitMeasures(lav_mod, "df"))
    lav_chisq_val <- as.numeric(fitMeasures(lav_mod, "chisq"))
    
    lav_agfi_val <- as.numeric(fitMeasures(lav_mod, "agfi"))
    lav_tli_val <- as.numeric(fitMeasures(lav_mod, "tli"))
    lav_cfi_val <- as.numeric(fitMeasures(lav_mod, "cfi"))
    
    lav_rmsea_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea")), error = function(e) NA)
    lav_rmsea_lwr_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.ci.lower")), error = function(e) NA)
    lav_rmsea_upr_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.ci.upper")), error = function(e) NA)
    lav_rmsea_pvalue_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.pvalue")), error = function(e) NA)
    
    if (estimator %in% c("ULS", "DWLS", "ULSM", "ULSMV", "WLSMVS")) {
      lav_df_val <- as.numeric(fitMeasures(lav_mod, "df.scaled"))
      lav_chisq_val <- as.numeric(fitMeasures(lav_mod, "chisq.scaled"))
      
      lav_tli_val <- as.numeric(fitMeasures(lav_mod, "tli.scaled"))
      lav_cfi_val <- as.numeric(fitMeasures(lav_mod, "cfi.scaled"))
      
      lav_rmsea_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.scaled")), error = function(e) NA)
      lav_rmsea_lwr_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.ci.lower.scaled")), error = function(e) NA)
      lav_rmsea_upr_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.ci.upper.scaled")), error = function(e) NA)
      lav_rmsea_pvalue_val <- tryCatch(as.numeric(fitMeasures(lav_mod, "rmsea.pvalue.scaled")), error = function(e) NA)
    }
    
    if (!is.na(lav_rmsea_pvalue_val) && lav_rmsea_pvalue_val < 0.05) {
      fail <- TRUE
    }
  }
  
  return(list(fail = fail, lav_mod = lav_mod
              , lav_df_val = lav_df_val, lav_chisq_val = lav_chisq_val
              , lav_agfi_val = lav_agfi_val, lav_tli_val = lav_tli_val, lav_cfi_val = lav_cfi_val
              , lav_rmsea_val = lav_rmsea_val, lav_rmsea_lwr_val = lav_rmsea_lwr_val, lav_rmsea_upr_val = lav_rmsea_upr_val
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
add_unidimensionality_test_info_for_TAM_models <- function(tam_models, information = NULL, itemclusters = NULL, estimator = "ML") {
  
  resp_detect_tests <- lapply(tam_models, test_detect, itemclusters = itemclusters)
  resp_test_uni_by_pca <- lapply(
    tam_models, 
    FUN = function(x) {
      return(tryCatch(test_uni_by_pca(x)
                      , error = function(e) list(fail = TRUE)))
    }
  )
  
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
  
  resp_lav_tests <- lapply(tam_models, test_lav, estimator = estimator)
  
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

## Function to get the itemcluser for DETECT analysis
get_detect_itemcluster <- function(data, score) {
  
  min_detect_value <- Inf
  # using expl.detect to identify itemclusters
  try(dev.off())
  expl_detect_mod <- tryCatch(
    expl.detect(data
                , score = score
                , nclusters = ncol(data)
                , N.est = nrow(data))
    , error =  function(e) 
      expl.detect(data
                  , score = score
                  , nclusters = ncol(data)-1
                  , N.est = nrow(data))
  )
  # iterate in all clusters
  for (j in 2:ncol(expl_detect_mod$itemcluster)) {
    i_cluster <- c(paste0("I", expl_detect_mod$itemcluster[,j]))
    detect_mod <- conf.detect(data = data, score = score, itemcluster = i_cluster)
    detect_val <- min(abs(detect_mod$detect.summary['DETECT',]), na.rm = T)
    if (detect_val < min_detect_value) {
      itemcluster <- i_cluster
      min_detect_value <- detect_val
    }
  }
  return(itemcluster)
}

## Function to evaluate the unidimensionality by DETECT
test_detect <- function(tam_mod, itemclusters = NULL, score = NULL) {
  library(sirt)
  
  # polydetect statistic analysis
  cat('\n... test by detect: ', paste0(colnames(tam_mod$resp), collapse = '+'), ' ...\n')
  
  if (is.null(score)) { score <- tam.wle(tam_mod)$theta }
  itemcluster <- colnames(tam_mod$resp)
  if (!is.null(itemclusters)) {
    for (n_col in names(itemclusters)) {
      itemcluster[itemcluster %in% itemclusters[[n_col]]]  <- n_col
    }
  } else {
    cat("\n ...", "Using expl.detect analysis to estimate itemcluster", "... \n")
    itemcluster <- get_detect_itemcluster(tam_mod$resp, score = score)
  }
  
  # all items are cluster for only one lattent factor
  detect_mod <- conf.detect(data = tam_mod$resp, score = score, itemcluster = itemcluster)
  
  # evaluate detect value
  detect <- NA
  detect_val <- min(abs(detect_mod$detect.summary['DETECT',]), na.rm = T)
  detect_assi <- min(abs(detect_mod$detect.summary['ASSI',]), na.rm = T)
  detect_ratio <- min(abs(detect_mod$detect.summary['RATIO',]), na.rm = T)
  
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
load_and_save_TAMs_to_measure_skill <- function(
  dat, column_names, prefix, fixed = NULL, fixed_sets = NULL
  , url_str = NULL, min_columns = 3, itemclusters = NULL, irtmodel = "GPCM", estimator = "ML"
  , tam_mods = NULL) {
  
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
    } else if (!is.null(tam_mods)) {
      tam_models <- tam_mods
    }
    tam_models <- remove_incorrect_TAMs(tam_models)
    
    # get TAMs information
    repeat {
      curr_length <- length(tam_models)
      tam_models <- get_TAMs(
        dat, column_names = column_names, tam_models = tam_models, fixed = fixed
        , fixed_sets = fixed_sets
        , min_columns = min_columns, limit = 20, irtmodel = irtmodel)
      if (curr_length >= length(tam_models)) break
      save(tam_models, file = file_tam_models_str)
    }
    info_tam_models <- add_info_for_TAM_models(tam_models)
    info_tam_models <- add_unidimensionality_test_info_for_TAM_models(
      tam_models, information = info_tam_models$information, itemclusters = itemclusters, estimator = estimator)
    save(info_tam_models, file = file_tam_info_str)
  }
  
  return(info_tam_models)
}

############################################################################
## Functions to measure change of skills                                  ##
############################################################################

## Drawing pre vs post points generating models to measure
plot_pre_vs_post <- function(x, y, plabels, title = "Pre-test vs. Post-test") {
  
  library(ggplot2)
  library(ggrepel)
  
  idx <- !is.na(x & y)
  x <- x[idx]
  y <- y[idx]
  plabels <- plabels[idx]
  
  gg1 <- data.frame(pre=x, pos=y)
  rownames(gg1) <- plabels
  print(ggplot(gg1, aes(pre, pos)) +
          coord_fixed(xlim = c(min(x,y), max(x,y)), ylim = c(min(x,y), max(x,y))) +
          scale_x_continuous(breaks = scales::pretty_breaks(n = 10)) +
          scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
          geom_point(color = 'black') +
          geom_text_repel(aes(label = rownames(gg1))
                          , segment.color = '#888888'
                          , segment.size = 0.25
                          , arrow = arrow(length = unit(0.005, 'npc'))
                          , point.padding = unit(0.4, 'lines') # extra padding
                          , box.padding = unit(0.15, 'lines')
                          , force = 1 # Strength of the repulsion force.
                          , size = 3) +
          theme_light(base_size = 12) +
          geom_abline(intercept = 0, slope = 1, color='blue', size=0.15) +
          xlab('pre-test') +
          ylab('post-test') +
          ggtitle(title))
}

## measuring change using TAM by stacking and racking data
TAM.measure_change.verify <- function(pre_dat, pos_dat
                                      , items.pre, items.pos
                                      , tam_models = NULL
                                      , userid = "UserID", irtmodel = "GPCM"
                                      , plotting = T, pairing = F, folder = NULL) {
  library(TAM)
  library(reshape)
  library(dplyr)
  
  items = list(pre=items.pre, pos=items.pos)
  
  userids <- intersect(pre_dat[[userid]], pos_dat[[userid]])
  n <- length(userids)
  pre_i <- pre_dat[[userid]] %in% userids
  pos_i <- pos_dat[[userid]] %in% userids
  
  dat <- merge(pre_dat[pre_i,][,c(userid, items$pre)],
               pos_dat[pos_i,][,c(userid, items$pos)], by = userid)
  
  if (!is.null(tam_models) && !is.null(tam_models$pos_mod1)) {
    pos_mod1 <- tam_models$pos_mod1
  } else {
    pos_mod1 <- tam.mml(dat[,items$pos], irtmodel = irtmodel, pid = dat[[userid]])
  }
  pos_wle1 <- tam.wle(pos_mod1)
  
  if (!is.null(tam_models) && !is.null(tam_models$pre_mod1)) {
    pre_mod1 <- tam_models$pre_mod1
  } else {
    pre_mod1 <- tam.mml(dat[,items$pre], irtmodel = irtmodel, pid = dat[[userid]])
  }
  pre_wle1 <- tam.wle(pre_mod1)
  
  pos_tt <- as.data.frame(tam.threshold(pos_mod1))
  pre_tt <- as.data.frame(tam.threshold(pre_mod1))
  tt <- plyr::rbind.fill(pos_tt,pre_tt)
  tt[,"Item"] <- c(IRT.threshold(pos_mod1, type="item"), IRT.threshold(pre_mod1, type="item"))
  rownames(tt) <- c(rownames(pos_tt), rownames(pre_tt))
  
  
  if (plotting) {
    filename <- "verification-thurstonian-thresholds.png"
    if (!is.null(folder)) png(filename = paste0(folder, filename), width = 640, height = 640)
    dotchart(t(tt), pch = 16, main = "Verification: Thurstonian Thresholds", cex=0.5)
    dev.off()
    
    filename <- "verification-ability-pre-vs-post.png"
    if (!is.null(folder)) png(filename = paste0(folder, filename), width = 640, height = 640)
    plot_pre_vs_post(pre_wle1$theta, pos_wle1$theta, dat[[userid]]
                     , "Verification: Pre-test vs. Post-test")
    if (!is.null(folder)) dev.off()
  }
  
  ## plotting pairing
  if (pairing) {
    for (i in 1:length(items.pre)) {
      for (j in 1:length(items.pos)) {
        pre_tt_val <- tt[items.pre[[i]],"Item"]
        pos_tt_val <- tt[items.pos[[j]],"Item"]
        abs_tt_val <- abs(pos_tt_val - pre_tt_val)
        
        align_tt <- rbind(tt[items.pos,] - abs_tt_val, tt[items.pre,])
        if (pos_tt_val < pre_tt_val) {
          align_tt <- rbind(tt[items.pos,], tt[items.pre,] - abs_tt_val)
        }
        
        
        pre_c <- c()
        pos_c <- c()
        exp_grid <- expand.grid(pre = items.pre[!items.pre %in% items.pre[[i]]]
                                , pos = items.pos[!items.pos %in% items.pos[[j]]])
        exp_grid <- rbind(exp_grid, data.frame(pre = items.pre[[i]], pos = items.pos[[j]]))
        exp_grid <- dplyr::mutate(exp_grid, label = paste0("(", pre,",", pos, ")"))
        for (k in 1:nrow(exp_grid)) {
          pre_c <- c(pre_c, align_tt[as.character(exp_grid[["pre"]][k]),][["Item"]])
          pos_c <- c(pos_c, align_tt[as.character(exp_grid[["pos"]][k]),][["Item"]])
        }
        exp_grid <- cbind(exp_grid, "pre.v" = pre_c)
        exp_grid <- cbind(exp_grid, "pos.v" = pos_c)
        
        filename <- paste0("verification-items-pre-vs-post", items.pre[[i]], "-", items.pos[[j]],".png")
        if (!is.null(folder)) png(filename = paste0(folder, filename), width = 640, height = 640)
        plot_pre_vs_post(exp_grid$pre.v, exp_grid$pos.v, exp_grid$label
                         , paste0("Verification: Pre-test vs. Post-test - base pair: (",items.pre[[i]],",",items.pos[[j]],")"))
        if (!is.null(folder)) dev.off()
      }
    }
  }
  
  return(list(tt = data.frame(tt)
         , pos_mod = pos_mod1, pre_mod = pre_mod1
         , pos_wle = pos_wle1, pre_wle = pre_wle1))
}

## measuring change using TAM by stacking and racking data
TAM.measure_change <- function(
  pre_dat, pos_dat, items.pre, items.pos, same_items.pre, same_items.pos
  , userid = "UserID", verify = T, plotting = F, tam_models = NULL, irtmodel = "GPCM") {
  
  library(TAM)
  library(reshape)
  library(dplyr)
  
  #  -> (TODO): changing prefix "pos" for "post"
  
  items = list(pre=items.pre, pos=items.pos)
  same_items = list(pre=same_items.pre, pos= same_items.pos)
  
  userids <- intersect(pre_dat[[userid]], pos_dat[[userid]])
  n <- length(userids)
  pre_i <- pre_dat[[userid]] %in% userids
  pos_i <- pos_dat[[userid]] %in% userids
  
  dat <- merge(pre_dat[pre_i,][,c(userid, items$pre)],
               pos_dat[pos_i,][,c(userid, items$pos)], by = userid)
  
  # Stage I: Data Verification
  info_verification <- NULL
  if (verify) {
    info_verification <- TAM.measure_change.verify(
      pre_dat, pos_dat, items.pre, items.pos, tam_models = NULL
      , userid = userid, irtmodel = irtmodel
      , plotting = plotting, pairing = F)
  }
  
  # Stage II: Item splitting & steps
  j_labels <- c()
  resp <- data.frame(idx=c(1:(n*2)))
  for (i in 1:length(same_items$pre)) {
    pre_cname <- same_items$pre[[i]]
    pos_cname <- same_items$pos[[i]]
    cname <- paste(pre_cname, pos_cname, sep = "")
    j_labels <- c(j_labels, cname)
    resp[[cname]] <- c(dat[[pre_cname]], dat[[pos_cname]])
  }
  for (cname in items$pre[!(items$pre %in% same_items$pre)]) {
    resp[[cname]] <- c(dat[[cname]], rep(NA, n))
  }
  for (cname in items$pos[!(items$pos %in% same_items$pos)]) {
    resp[[cname]] <- c(rep(NA, n), dat[[cname]])
  }
  resp <- resp[,-1]
  
  # get pre- and post-test responses
  pos_resp <- subset(resp, select = j_labels)[(n+1):(n*2),]
  for (cname in items$pos[!(items$pos %in% same_items$pos)]) {
    pos_resp[[cname]] <- resp[[cname]][(n+1):(n*2)]
  }
  
  pre_resp <- subset(resp, select = j_labels)[1:n,]
  for (cname in items$pre[!(items$pre %in% same_items$pre)]) {
    pre_resp[[cname]] <- resp[[cname]][1:n]
  }
  
  # get fixing steps (B): loading matrix
  if (!is.null(tam_models) && !is.null(tam_models$mod2)) {
    mod2 <- tam_models$mod2
  } else {
    mod2 <- tam.mml(resp, irtmodel = irtmodel, pid = dat[[userid]])
  }
  
  pos_B2 <- mod2$B[,,][colnames(pos_resp),]
  pos_B2 <- pos_B2[,colnames(pos_B2) == "Cat0" | 
                     (!is.na(colSums(pos_B2)) & colSums(abs(pos_B2)) > 0)]
  pos_B2 <- array(pos_B2, dim = c(dim(pos_B2), 1), dimnames = dimnames(pos_B2))
  dimnames(pos_B2)[[3]] <- dimnames(mod2$B)[[3]]
  
  pos_B2.fixed <- matrix(nrow = nrow(pos_B2)*ncol(pos_B2), ncol = 4)
  pos_B2.fixed[,4] <- c(t(pos_B2[,,1]))
  pos_B2.fixed[,3] <- 1
  pos_B2.fixed[,2] <- rep(1:ncol(pos_B2),nrow(pos_B2))
  pos_B2.fixed[,1] <- rep(1:nrow(pos_B2), each = ncol(pos_B2))
  
  pre_B2 <- mod2$B[,,][colnames(pre_resp),]
  pre_B2 <- pre_B2[,colnames(pre_B2) == "Cat0" | 
                     (!is.na(colSums(pre_B2)) & colSums(abs(pre_B2)) > 0)]
  pre_B2 <- array(pre_B2, dim = c(dim(pre_B2), 1), dimnames = dimnames(pre_B2))
  dimnames(pre_B2)[[3]] <- dimnames(mod2$B)[[3]]
  
  pre_B2.fixed <- matrix(nrow = nrow(pre_B2)*ncol(pre_B2), ncol = 4)
  pre_B2.fixed[,4] <- c(t(pre_B2[,,1]))
  pre_B2.fixed[,3] <- 1
  pre_B2.fixed[,2] <- rep(1:ncol(pre_B2),nrow(pre_B2))
  pre_B2.fixed[,1] <- rep(1:nrow(pre_B2), each = ncol(pre_B2))
  
  # Stage III: Measure person ability changes
  if (!is.null(tam_models) && !is.null(tam_models$pos_mod3)) {
    pos_mod3 <- tam_models$pos_mod3
  } else {
    pos_mod3 <- tam.mml(pos_resp, irtmodel = irtmodel, B.fixed = pos_B2.fixed, pid = dat[[userid]])
  }
  pos_wle3 <- tam.wle(pos_mod3)
  
  if (!is.null(tam_models) && !is.null(tam_models$pre_mod3)) {
    pre_mod3 <- tam_models$pre_mod3
  } else {
    pre_mod3 <- tam.mml(pre_resp, irtmodel = irtmodel, B.fixed = pre_B2.fixed, pid = dat[[userid]])
    xsi.names <- intersect(row.names(pos_mod3$xsi.fixed.estimated)
                           , row.names(pre_mod3$xsi.fixed.estimated))
    pos_xsi3.fixed <- pos_mod3$xsi.fixed.estimated[xsi.names,]
    pre_mod3 <- tam.mml(pre_resp, irtmodel = irtmodel, B.fixed = pre_B2.fixed
                        , xsi.fixed = pos_xsi3.fixed, pid = dat[[userid]])
  }
  pre_wle3 <- tam.wle(pre_mod3)
  
  pre_tt3 <- as.data.frame(tam.threshold(pre_mod3))
  pre_tt3[,"atem"] <- c(IRT.threshold(pre_mod3, type="item"))
  pre_tt3 <- pre_tt3[!(rownames(pre_tt3) %in% j_labels),]
  pos_tt3 <- as.data.frame(tam.threshold(pos_mod3))
  pos_tt3[,"atem"] <- c(IRT.threshold(pos_mod3, type="item"))
  
  tt3 <- plyr::rbind.fill(pos_tt3, pre_tt3)
  tt3 <- dplyr::select(dplyr::mutate(tt3, Item = atem), -starts_with("atem"))
  rownames(tt3) <- c(rownames(pos_tt3), rownames(pre_tt3))
  
  info.stacking <- list(tt = tt3
                        , xsi = data.frame(rbind(pos_mod3$xsi, pre_mod3$xsi[!(rownames(pre_mod3$xsi) %in% intersect(rownames(pos_mod3$xsi), rownames(pre_mod3$xsi))),]))
                        , pos_mod = pos_mod3, pre_mod = pre_mod3
                        , pos_wle = pos_wle3, pre_wle = pre_wle3)
  
  if (plotting) {
    dotchart(t(tt3), pch = 16, main = "Stacking: Thurstonian Thresholds", cex = 0.5)
    plot_pre_vs_post(pre_wle3$theta, pos_wle3$theta, dat[[userid]]
                     , "Stacking: Pre-test vs. Post-test")
  }
  
  dat[["pre.PersonScores"]] <- pre_wle3$PersonScores
  dat[["pos.PersonScores"]] <- pos_wle3$PersonScores
  dat[["pre.theta"]] <- pre_wle3$theta
  dat[["pos.theta"]] <- pos_wle3$theta
  dat[["pre.sd.error"]] <- pre_wle3$error
  dat[["pos.sd.error"]] <- pos_wle3$error
  
  # Stage IV: Measure item difficulty changes
  # -> anchored abilities is non-necessary in MML estimation
  # -> MML assumpts an uniform distribution for the ability
  if (!is.null(tam_models) && !is.null(tam_models$mod4)) {
    mod4 <- tam_models$mod4
  } else {
    mod4 <- tam.mml(pre_resp, irtmodel = irtmodel, B.fixed = pre_B2.fixed, pid = dat[[userid]])
  }
  
  tt4 <- as.data.frame(tam.threshold(mod4))
  tt4[,"Item"] <- c(IRT.threshold(mod4, type = "item"))
  
  tt4 <- plyr::rbind.fill(tt4[j_labels,], tt3[j_labels,])
  rownames(tt4) <- c(paste("pre", j_labels, sep = "."), paste("pos", j_labels, sep = "."))
  
  tt_pre <- c(); tt_pos <- c(); tt_item <- c()
  for (rname in j_labels) {
    for (cname in colnames(tt4)) {
      tt_pre <- c(tt_pre, tt4[paste("pre", rname, sep = "."), cname])
      tt_pos <- c(tt_pos, tt4[paste("pos", rname, sep = "."), cname])
      tt_item <- c(tt_item, paste(rname, cname, sep = "_"))
    }
  }
  tt4.changed = data.frame(item=tt_item, pre=tt_pre, pos=tt_pos)
  
  info.racking <- list(tt = data.frame(tt4), mod = mod4, tt.changed = tt4.changed)
  
  if (plotting) {
    dotchart(t(tt4), pch = 16, main = "Racking: Thurstonian Thresholds", cex = 0.5)
    tt4.plot <- na.omit(tt4.changed)
    plot_pre_vs_post(tt4.plot$pre, tt4.plot$pos, tt4.plot$item
                     , "Racking: Pre-test vs. Post-test Thurstonian Thresholds")
  }
  
  ## Treatment of outliers: Stage V
  r_id <- c(dat[[userid]][dat$pos.theta %in% boxplot.stats(dat$pos.theta)$out],
            dat[[userid]][dat$pre.theta %in% boxplot.stats(dat$pre.theta)$out])
  dat_wo <- dat[!(dat[[userid]] %in% unique(r_id)),]
  
  library(robustHD)
  dat_wisor <- dat
  dat_wisor$pre.theta <- robustHD::winsorize(dat$pre.theta)
  dat_wisor$pos.theta <- robustHD::winsorize(dat$pos.theta)
  
  if (plotting) {
    plot_pre_vs_post(dat$pre.theta, dat$pos.theta, dat[[userid]]
                     , "Pre-test vs. Post-test: Latent Trait Estimates")
    plot_pre_vs_post(dat_wo$pre.theta, dat_wo$pos.theta, dat_wo[[userid]]
                     , "Pre-test vs. Post-test: Latent Trait Estimates (Without Outliers)")
    plot_pre_vs_post(dat_wisor$pre.theta, dat_wisor$pos.theta, dat_wisor[[userid]]
                     , "Pre-test vs. Post-test: Latent Trait Estimates (Winsorized)")
  }
  
  return(list(
    ability.without.outliers = list("rm.outlieres" = dat_wo, "winsor.outliers" = dat_wisor)
    , info.verification = info_verification
    , xsi = info.stacking$xsi, tt = info.stacking$tt, B = data.frame(mod2$B[,,])
    , global.estimation = list(mod = mod2, B = data.frame(mod2$B[,,]))
    , info.stacking = info.stacking, info.racking = info.racking
    , ability = dat
    ))
}

############################################################################
## Functions to write report TAM models                                   ##
############################################################################


## Function to write plots of measurement model
write_change_measurement_model_plots <- function(mod, path, override = T) {
  library(r2excel)
  library(RColorBrewer)
  
  ## ability pre-vs-post
  filename <- paste0(path, '00-ability-pre-vs-post.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(mod$ability$pre.theta
                     , mod$ability$pos.theta
                     , mod$ability$UserID
                     , "Pre-test vs. Post-test")
    dev.off()
  }
  
  filename <- paste0(path, '00-ability-without-outliers-pre-vs-post.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(mod$ability.without.outliers$rm.outlieres$pre.theta
                     , mod$ability.without.outliers$rm.outlieres$pos.theta
                     , mod$ability.without.outliers$rm.outlieres$UserID
                     , "Pre-test vs. Post-test: Latent Trait Estimates (Without Outliers)")
    dev.off()
  }
  
  filename <- paste0(path, '00-ability-winsorized-pre-vs-post.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(mod$ability.without.outliers$winsor.outliers$pre.theta
                     , mod$ability.without.outliers$winsor.outliers$pos.theta
                     , mod$ability.without.outliers$winsor.outliers$UserID, "Pre-test vs. Post-test: Latent Trait Estimates (Winsorized)")
    dev.off()
  }
  
  ## verification thurstonian
  filename <- paste0(path, '01-verification-tt.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    dotchart(t(mod$info.verification$tt), pch = 16, main = "Verification: Thurstonian Thresholds", cex=0.5)
    dev.off()
  }
  
  ## verification pre_vs_post
  filename <- paste0(path, '01-verification-pre-vs-post-data.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(mod$info.verification$pre_wle$theta
                     , mod$info.verification$pos_wle$theta
                     , mod$info.verification$pre_wle$pid
                     , "Verification: Pre-test vs. Post-test")
    dev.off()
  }
  
  ## stacking thurstonian
  filename <- paste0(path, '02-stacking-tt.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    dotchart(t(mod$info.stacking$tt), pch = 16, main = "Stacking: Thurstonian Thresholds", cex = 0.5)
    dev.off()
  }
  
  ## stacking pre_vs_post
  filename <- paste0(path, '02-stacking-pre-vs-post-data.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(mod$info.stacking$pre_wle$theta
                     , mod$info.stacking$pos_wle$theta
                     , mod$info.stacking$pre_wle$pid
                     , "Stacking: Pre-test vs. Post-test")
    dev.off()
  }
  
  ## racking thurstonian
  filename <- paste0(path, '03-racking-tt.png')
  if (!file.exists(filename) || override) {
    png(filename = filename, width = 640, height = 640)
    dotchart(t(mod$info.racking$tt), pch = 16, main = "Racking: Thurstonian Thresholds", cex = 0.5)
    dev.off()
  }
  
  ## racking pre_vs_post
  filename <- paste0(path, '03-racking-pre-vs-post-data.png')
  if (!file.exists(filename) || override) {
    tt4.plot <- na.omit(mod$info.racking$tt.changed)
    
    png(filename = filename, width = 640, height = 640)
    plot_pre_vs_post(tt4.plot$pre, tt4.plot$pos, tt4.plot$item
                     , "Racking: Pre-test vs. Post-test Thurstonian Thresholds")
    dev.off()
  }
  
  
}

## Write report to measure change in file
write_measure_change_report <- function(result, path, filename, override = F) {
  
  library(sirt)
  library(r2excel)
  
  if (!file.exists(paste0(path, filename)) || override) {
    
    wb <- createWorkbook(type='xlsx')
    
    ## write ability estimates (with outliers)
    ability_estimates <- result$ability
    ability_estimates_rm_ouliers <- result$ability.without.outliers$rm.outlieres
    ability_estimates_winsorized <- result$ability.without.outliers$winsor.outliers
    
    personfit_df <- sirt::pcm.fit(b = result$info.stacking$pre_mod$AXsi_[, -1]
                                  , theta = result$info.stacking$pre_wle$theta
                                  , dat = result$info.stacking$pre_mod$resp)$personfit
    personfit_df <- personfit_df[, -which(names(personfit_df) %in% 'person')]
    colnames(personfit_df) <- c('pre.outfit','pre.outfit.t','pre.infit','pre.infit.t')
    personfit_df[["UserID"]] <- ability_estimates$UserID
    
    
    ability_estimates <- merge(ability_estimates, personfit_df)
    rownames(ability_estimates) <- ability_estimates$UserID
    
    ability_estimates_rm_ouliers <- merge(ability_estimates_rm_ouliers, personfit_df)
    rownames(ability_estimates_rm_ouliers) <- ability_estimates_rm_ouliers$UserID
    
    ability_estimates_winsorized <- merge(ability_estimates_winsorized, personfit_df)
    rownames(ability_estimates_winsorized) <- ability_estimates_winsorized$UserID
    
    ## write ability estimates
    sheet1 <- createSheet(wb, sheetName = 'Ability Estimates')
    xlsx.addTable(wb, sheet1, ability_estimates, startCol = 1, row.names = F, columnWidth = 16)
    
    ## write ability estimates (without outliers)
    sheet1 <- createSheet(wb, sheetName = 'Ability Estimates (without outliers)')
    xlsx.addTable(wb, sheet1, ability_estimates_rm_ouliers, startCol = 1, row.names = F, columnWidth = 16)
    
    ## write ability estimates (winsorized outliers)
    sheet2 <- createSheet(wb, sheetName = 'Ability Estimates (winsorized)')
    xlsx.addTable(wb, sheet2, ability_estimates_winsorized, startCol = 1, row.names = F, columnWidth = 16)
    
    ## write ability estimates statistics
    sheet3 <- createSheet(wb, sheetName = 'Ability Estimates (statistics)')
    pre_wle_info_df <- data.frame(
      'pre.pid' = result$info.stacking$pre_wle$pid
      , 'pre.theta' = result$info.stacking$pre_wle$theta
      , 'pre.error' = result$info.stacking$pre_wle$error
      , 'pre.N.items' = result$info.stacking$pre_wle$N.items
      , 'pre.Score' = result$info.stacking$pre_wle$PersonScores
      , 'pre.WLE.rel'= result$info.stacking$pre_wle$WLE.rel)
    xlsx.addTable(wb, sheet3, pre_wle_info_df, startCol = 1, row.names = F, columnWidth = 16)
    
    xlsx.addLineBreak(sheet3, 2)
    pos_wle_info_df <- data.frame(
      'pos.pid' = result$info.stacking$pos_wle$pid
      , 'pos.theta' = result$info.stacking$pos_wle$theta
      , 'pos.error' = result$info.stacking$pos_wle$error
      , 'pos.N.items' = result$info.stacking$pos_wle$N.items
      , 'pos.Score' = result$info.stacking$pos_wle$PersonScores
      , 'pos.WLE.rel'= result$info.stacking$pos_wle$WLE.rel)
    xlsx.addTable(wb, sheet3, pos_wle_info_df, startCol = 1, row.names = F, columnWidth = 16)
    
    ## write item estimates
    sheet4 <- createSheet(wb, sheetName = 'Item Estimates')
    
    xlsx.addHeader(wb, sheet4, 'Full Item Information (pre-test)', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet4, result$info.stacking$pre_mod$item, startCol = 1, row.names = F)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Full Item Information (post-test)', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet4, result$info.stacking$pos_mod$item, startCol = 1, row.names = F)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Discrimination parameters', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet4, result$B, startCol = 1, row.names = T)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Thurstonian Thresholds', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet4, result$tt, startCol = 1, row.names = T)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Item Infit/Outfit Statistic (pre-test)', level = 2, startCol = 1)
    pre_item_fit_df <- tam.fit(result$info.stacking$pre_mod)$itemfit
    xlsx.addTable(wb, sheet4, pre_item_fit_df, startCol = 1, row.names = F)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Item Infit/Outfit Statistic (post-test)', level = 2, startCol = 1)
    pos_item_fit_df <- tam.fit(result$info.stacking$pos_mod)$itemfit
    xlsx.addTable(wb, sheet4, pos_item_fit_df, startCol = 1, row.names = F)
    
    xlsx.addLineBreak(sheet4, 2)
    xlsx.addHeader(wb, sheet4, 'Extra information', level = 2, startCol = 1)
    ext_df <- data.frame(
      'model' = rep(c('pre.test','post.test'), each=5)
      , 'parameter' = rep(c('Number of items', 'Deviance', 'Log Likelihood'
                            , 'Number of persons', 'EAP.rel'), times=2)
      , 'value' = c(result$info.stacking$pre_mod$nitems
                    , result$info.stacking$pre_mod$deviance
                    , as.numeric(logLik(result$info.stacking$pre_mod))
                    , result$info.stacking$pre_mod$nstud
                    , result$info.stacking$pre_mod$EAP.rel
                    , result$info.stacking$pos_mod$nitems
                    , result$info.stacking$pos_mod$deviance
                    , as.numeric(logLik(result$info.stacking$pos_mod))
                    , result$info.stacking$pos_mod$nstud
                    , result$info.stacking$pos_mod$EAP.rel))
    xlsx.addTable(wb, sheet4, ext_df, startCol = 1, row.names = F)
    
    ## write racking item estimates
    sheet5 <- createSheet(wb, sheetName = 'Item Estimates for Racking')
    
    xlsx.addHeader(wb, sheet5, 'Change for Thurstonian Thresholds', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet5, result$info.racking$tt, startCol = 1, row.names = T)
    
    xlsx.addLineBreak(sheet5, 2)
    xlsx.addHeader(wb, sheet5, 'Thurstonian Thresholds', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet5, result$info.racking$tt.changed, startCol = 1, row.names = F)
    
    xlsx.addLineBreak(sheet5, 2)
    xlsx.addHeader(wb, sheet5, 'Full Item Information', level = 2, startCol = 1)
    xlsx.addTable(wb, sheet5, result$info.racking$mod$item, startCol = 1, row.names = F)
    
    ##
    
    write_tam_item_info_in_wb(result$global.estimation$mod, wb, prefix = 'global-')
    write_tam_item_info_in_wb(result$info.stacking$pre_mod, wb, prefix = 'stacking-pre-')
    write_tam_item_info_in_wb(result$info.stacking$pos_mod, wb, prefix = 'stacking-pos-')
    write_tam_item_info_in_wb(result$info.racking$mod, wb, prefix = 'racking-')
    
    ##
    saveWorkbook(wb, paste0(path, filename))
  }
}

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
write_tam_item_info_in_wb <- function(mod, wb, prefix = NULL) {
  library(TAM)
  library(r2excel)
  
  sheetName <- 'Estimate-Items'
  if (!is.null(prefix)) sheetName <- paste0(prefix, sheetName)
  
  sheet <- createSheet(wb, sheetName = sheetName)
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
write_tam_abilities_in_wb <- function(mod, wb) {
  library(TAM)
  library(r2excel)
  
  wmod <- tam.wle(mod)
  rdat <- cbind(cbind(data.frame(UserID=mod$pid), mod$resp), 
                as.data.frame(unclass(wmod)))
  
  sheet <- createSheet(wb, sheetName = 'Abilities')
  xlsx.addTable(wb, sheet, rdat, startCol = 1, row.names = F, columnWidth = 25)
}

# Function to write person fit
write_tam_personfit_in_wb <- function(mod, wb) {
  library(r2excel)
  library(TAM)
  library(sirt)
  
  wmod <- tam.wle(mod)
  
  personfit_df <- sirt::pcm.fit(b = mod$AXsi_[, -1], theta = wmod$theta, dat = mod$resp)$personfit
  rdat <- cbind(cbind(data.frame(UserID=mod$pid), mod$resp), personfit_df)
  
  sheet <- createSheet(wb, sheetName = 'Person-fit')
  xlsx.addTable(wb, sheet, rdat, startCol = 1, row.names = F)
}

## Function to write TAM reports 
write_tam_report <- function(mod, path, filename, override = F) {
  library(r2excel)
  
  if (!file.exists(paste0(path, filename)) || override) {
    wb <- createWorkbook(type="xlsx")
    
    write_tam_global_info_in_wb(mod, wb)
    write_tam_item_info_in_wb(mod, wb)
    write_tam_personfit_in_wb(mod, wb)
    write_tam_abilities_in_wb(mod, wb)
    
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

### Function to obtain summary
get_rsm_summaries_as_dataframe <- function(sources, tam_mods, estimator = "ML", scores = list()) {
  library(mokken)
  
  test_unidimensionality_df <- do.call(rbind, lapply(sources, FUN = function(src){
    mod <- tam_mods[[src$name]]
    lavaan_fit <- test_lav(mod, estimator = estimator)
    detect_fit <- test_detect(mod, score = scores[[src$name]])
    
    return(data.frame(
      "df" = tryCatch(lavaan_fit$lav_df_val, error = function(e) NA)
      , "chisq" = tryCatch(lavaan_fit$lav_chisq_val, error = function(e) NA)
      , "AGFI" = tryCatch(lavaan_fit$lav_agfi_val, error = function(e) NA)
      , "TLI" = tryCatch(lavaan_fit$lav_tli_val, error = function(e) NA)
      , "CFI" = tryCatch(lavaan_fit$lav_cfi_val, error = function(e) NA)
      #, "p_RMSEA" = tryCatch(lavaan_fit$lav_rmsea_pvalue_val, error = function(e) NA)
      , "DETECT" = tryCatch(detect_fit$detect_val, error = function(e) NA)
      , "ASSI" = tryCatch(detect_fit$detect_assi, error = function(e) NA)
      , "RATIO" = tryCatch(detect_fit$detect_ratio, error = function(e) NA)
    ))
  }))
  
  test_local_independence_df <- do.call(rbind, lapply(sources, FUN = function(src){
    mod <- tam_mods[[src$name]]
    fit <- tam.modelfit(mod)
    return(data.frame(
      "max.chisq" = fit$modelfit.test$maxX2
      , "maxaQ3" = fit$stat.MADaQ3$maxaQ3
      , "MADaQ3" = fit$stat.MADaQ3$MADaQ3
      , "SRMSR" = as.list(fit$fitstat)$SRMSR
      , "p.value" = fit$stat.MADaQ3$p
    ))
  }))
  
  test_monotonicity_df <- do.call(rbind, lapply(sources, FUN = function(src){
    mod <- tam_mods[[src$name]]
    monotonicity_mod <- NULL
    resp <- mod$resp[complete.cases(mod$resp),]
    monotonicity_mod <- tryCatch(
      check.monotonicity(resp)
      , error = function(e) check.monotonicity(resp, minsize = nrow(resp)/2)
    )
    return(as.data.frame(summary(monotonicity_mod)))
  }))
  
  estimated_params_list <- lapply(sources, FUN = function(src){
    mod <- tam_mods[[src$name]]
    
    outfit_infit_df <- tam.fit(mod, progress = F)$itemfit
    if (mod$irtmodel == "RSM") {
      outfit_infit_df <- as.data.frame(
        outfit_infit_df[outfit_infit_df$parameter %in% colnames(mod$resp),])
    } else if (mod$irtmodel == "GPCM") {
      item_names <- outfit_infit_df$parameter
      for (k in 1:(mod$maxK-1)) {
        item_names <- gsub(paste0("_Cat",k), "", item_names)
      }
      
      cparameter <- c()
      cmaxoutfit <- c()
      cmaxinfit <- c()
      for (citem in colnames(mod$resp)) {
        cparameter <- c(cparameter, citem)
        cmaxinfit <- c(cmaxinfit, max(outfit_infit_df$Infit[item_names %in% citem], na.rm = T))
        cmaxoutfit <- c(cmaxoutfit, max(outfit_infit_df$Outfit[item_names %in% citem], na.rm = T))
      }
      
      outfit_infit_df <- data.frame(
        parameter = cparameter, max.Outfit = cmaxoutfit, max.Infit = cmaxinfit
      )
    }
    outfit_infit_df <- dplyr::select(
      outfit_infit_df, starts_with("parameter"), ends_with("fit"))
    
    item_df <- as.data.frame(mod$AXsi)
    colnames(item_df) <- paste0("AXsi.Cat", seq(0, ncol(mod$AXsi)-1))
    
    item_b_df <- as.data.frame(mod$B)
    colnames(item_b_df) <- paste0("B.", colnames(item_b_df))
    
    item_df <- cbind(item_b_df, item_df)
    item_df <- cbind(dplyr::select(
      as.data.frame(mod$item)
      , starts_with("item")
      , starts_with("xsi.item")), item_df)
    colnames(item_df) <- gsub(".Dim01", "", colnames(item_df))
    
    item_df <- merge(item_df, outfit_infit_df, by.x = "item", by.y = "parameter")
    rownames(item_df) <- item_df$item
    item_df <- dplyr::select(item_df, -starts_with("item"))
    return(t(item_df))
  })
  
  person_ability_df <- do.call(cbind, get_abilities(
    sources, tam_mods, columns = c("theta", "error","Outfit", "Infit")))
  
  return(list(
    test_unidimensionality = test_unidimensionality_df
    , test_local_independence = test_local_independence_df
    , test_monotonicity = test_monotonicity_df
    , estimated_params = estimated_params_list
    , person_ability = person_ability_df
    ))
}

### Function to obtain summary as gpcm
get_gpcm_summaries_as_dataframe <- function(tam_mods, estimator = "ML") {
  sources <- lapply(names(tam_mods), FUN = function(x) return(list(name = x)))
  names(sources) <- names(tam_mods)
  return(get_rsm_summaries_as_dataframe(sources, tam_mods, estimator = estimator))
}

## function to get abilities
get_abilities <- function(sources, tam_mods, columns = NULL) {
  return(lapply(sources, FUN = function(src){
    mod <- tam_mods[[src$name]]
    
    wmod <- tam.wle(mod)
    personfit_df <- sirt::pcm.fit(b = mod$AXsi_[, -1], theta = wmod$theta, dat = mod$resp)$personfit
    
    result_df <- as.data.frame(wmod)[,c("pid","PersonScores","theta","error")]
    result_df <- cbind(result_df, personfit_df[,c("outfit","infit")])
    colnames(result_df) <- c("UserID", "Score", "theta", "error", "Outfit", "Infit")
    rownames(result_df) <- result_df$UserID
    
    if (!is.null(columns)) {
      result_df <- result_df[,columns]
    }
    
    return(dplyr::select(result_df, -starts_with("UserID")))
  }))
}

