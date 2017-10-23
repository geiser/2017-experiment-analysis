
#if (!'r2excel' %in% rownames(installed.packages())) {
#  devtools::install_github("kassambara/r2excel")  
#}

wants <- c('TAM', 'sirt', 'lavaan', 'ggrepel', 'parallel', 'reshape', 'ggplot2', 'dplyr', 'readr', 'readxl', 'multcomp')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])

###############################################################################
## Test Analyse Models (TAMs) for programming tasks as GPCM                  ##
###############################################################################

## remove_incorrect TAMS
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

## get TAM from a name_model using dat
get_TAM <- function(name_model, dat) {
  library(dplyr)
  #cat('\n... ', name_model,' ...\n')
  column_names <- strsplit(name_model,"[+]")[[1]]
  # select columns for data.frame
  dat_r <- dat[column_names]
  # use tam to obtain the model
  return(tryCatch(tam.mml.2pl(dat_r, irtmodel="GPCM"), error = function(e) NULL))
}

## get tams models
get_TAMs <- function(dat, column_names, tam_models = NULL, fixed = NULL, min_columns = 3, limit = 100) {
  
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
    generated_tam_models <- lapply(generated_name_models, get_TAM, dat=dat)
  } else {
    generated_tam_models <- mclapply(generated_name_models, get_TAM, dat=dat, mc.allow.recursive = FALSE)
  }
  
  for (name in names(generated_tam_models)) {
    if (nchar(name) - nchar(gsub("[+]", "", name)) < min_columns-1) next
    if (class(generated_tam_models[[name]]) != 'tam.mml') next
    tam_models[[name]] <- generated_tam_models[[name]]
  }
  
  tam_models <- remove_incorrect_TAMs(tam_models)
  return(tam_models)
}

## get mistfit information
get_misfits_information <- function(tam_models) {
  
  library(TAM)
  
  tam_names <- c()
  everything.fits <- c()
  mis.infit.param <- c()
  mis.outfit.param <- c()
  
  #resp_tam_fit <- mclapply(tam_models, FUN = function(x) {
  #  return(tryCatch(tam.fit(x), error = function(e) NULL))
  #}, mc.allow.recursive = FALSE)
  
  for (name in names(tam_models)) {
    cat('\n...',name,'...\n')
    tam_fit <- tam.fit(tam_models[[name]])
    if (is.null(tam_fit)) next
    item_fit <- tam_fit$item
    misfits_in <- as.character(item_fit$parameter[!is.na(item_fit$Infit) & item_fit$Infit > 2])
    misfits_out <- as.character(item_fit$parameter[!is.na(item_fit$Outfit) & item_fit$Outfit > 2])
    if ((!is.null(misfits_in) & length(misfits_in) > 0) |
        (!is.null(misfits_out) & length(misfits_out) > 0)) {
      num <- max(length(misfits_in), length(misfits_out))
      mis.infit.param <- c(mis.infit.param, c(misfits_in, rep(NA, num-length(misfits_in))))
      mis.outfit.param <- c(mis.outfit.param, c(misfits_out, rep(NA, num-length(misfits_out))))
      everything.fits <- c(everything.fits, rep(FALSE, num))
      tam_names <- c(tam_names, rep(name, num))
    } else {
      tam_names <- c(tam_names, name)
      everything.fits <- c(everything.fits, TRUE)
      mis.infit.param <- c(mis.infit.param, NA)
      mis.outfit.param <- c(mis.outfit.param, NA)
    }
  }
  return(data.frame(name = tam_names, everything.fits, mis.infit.param, mis.outfit.param))
}

## get all possible TAMs for programming tasks
get_all_TAMs <- function(dat, column_names = NULL, tam_models = NULL, fixed = NULL) {
  
  library(TAM)
  
  p <- c()
  X2 <- c()
  SRMR <- c()
  name <- c()
  p_holm <- c()
  WLE.rel <- c()
  EAP.rel <- c()
  srmr_fit <- c()
  model_fit <- c()
  everything_fits <- c()
  rel_fit <- c()
  
  if (is.null(tam_models)) {
    tam_models <- get_TAMs(dat, column_names, fixed = fixed)
  }
  
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
    if (pholm > 0.05 && as.numeric(fit_mod$stat.MADaQ3$p) > 0.05) {
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
    
    # everything fits
    everything_fits <- c(
      everything_fits
      , all(misfits_info$everything.fits[misfits_info$name == name_model]))
    # add extra information
    p <- c(p, as.numeric(fit_mod$stat.MADaQ3$p))
    SRMR <- c(SRMR, srmr)
    p_holm <- c(p_holm, pholm)
    X2 <- c(X2, fit_mod$modelfit.test$maxX2)
    name <- c(name, name_model)
    WLE.rel <- c(WLE.rel, wle_val)
    EAP.rel <- c(EAP.rel, tam_mod$EAP.rel)
  }
  
  return(list(misfits.info = misfits_info,
              information = data.frame(name = name, model_fit = model_fit, srmr_fit = srmr_fit
                                       , everything.fits = everything_fits
                                       , X2 = X2, p_holm = p_holm, p = p, SRMR = SRMR
                                       , rel_fit = rel_fit, WLE.rel = WLE.rel, EAP.rel = EAP.rel)))
}

## evaluate the unidimensionality by DETECT
test_detect <- function(tam_mod, itemequals = NULL) {
  library(sirt)
  
  # polydetect statistic analysis
  cat('\n... ', paste0(colnames(tam_mod$resp), collapse = '+'), ' ...\n')
  
  wle_mod <- tam.wle(tam_mod)
  itemcluster <- colnames(tam_mod$resp)
  if (!is.null(itemequals)) {
    for (n_col in names(itemequals)) {
      itemcluster[itemcluster %in% itemequals[[n_col]]]  <- n_col
    }
    cat('\n... itemclusters=(', paste0(itemcluster, collapse = ','), ') ...\n')
  }
  detect_mod <- conf.detect(data = tam_mod$resp, score = wle_mod$theta, itemcluster = itemcluster) # all items are cluster for only one lattent factor
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
  
  return(list(fail = fail, detect_mod = detect_mod, detect = detect
              , detect_val = detect_val, detect_assi = detect_assi, detect_ratio = detect_ratio))
}

## evaluate the unidimensionality lav
test_lav <- function(tam_mod) {
  
  library(lavaan)
  
  cat('\n... ', paste0(colnames(tam_mod$resp), collapse = '+'),' ...\n')
  
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

## filter non-unideminsional vs unidimensional TAMs
filter_by_test_unidimensionality <- function(tam_models, step = 0.05, information = NULL, itemequals = NULL) {
  
  resp_detect_tests <- lapply(tam_models, test_detect, itemequals = itemequals)
  # detect filtering
  unidim_test <- c()
  DETECT <- c()
  DETECT_VAL <- c()
  DETECT_ASSI <- c()
  DETECT_RATIO <- c()
  for (name in names(tam_models)) {
    resp_detect_test <- resp_detect_tests[[name]]
    unidim_test <- c(unidim_test, !resp_detect_test$fail)
    DETECT <- c(DETECT, resp_detect_test$detect)
    DETECT_VAL <- c(DETECT_VAL, resp_detect_test$detect_val)
    DETECT_ASSI <- c(DETECT_ASSI, resp_detect_test$detect_assi)
    DETECT_RATIO <- c(DETECT_RATIO, resp_detect_test$detect_ratio)
  }
  
  detect.infomation <- data.frame(
    name = names(tam_models)
    , unidim_test = unidim_test
    , DETECT = DETECT, DETECT_VAL = DETECT_VAL, DETECT_ASSI = DETECT_ASSI, DETECT_RATIO)
  
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
  
  return(list(information = full.infomation
              , full.unidimensional_models = list_unidimensional_models
              , non.full.unidimensional_models = list_nonunidimensional_models))
}

## get TAMs to measure change
get_TAMs_to_measure_change <- function(dat = NULL, column_names = NULL
                                       , tam_models = NULL, fixed = NULL, itemequals = NULL) {
  if (is.null(tam_models)) {
    tam_models <- get_TAMs(dat, column_names = column_names, tam_models = tam_models, fixed = fixed)
  }
  resp_TAMs <- get_all_TAMs(tam_models = tam_models, fixed = fixed)
  resp_filter_TAMs <- filter_by_test_unidimensionality(
    tam_models = tam_models, information = resp_TAMs$information, itemequals = itemequals)
  
  return(list(all = names(tam_models)
              , detect.test = resp_filter_TAMs$detect.test
              , lav.test = resp_filter_TAMs$uni.lav.test
              , full.unidimensional = resp_filter_TAMs$full.unidimensional_models
              , non.full.unidimensional = resp_filter_TAMs$non.full.unidimensional_models
              , information = resp_filter_TAMs$information))
}

## load and save TAMs to measure change
load_and_save_TAMs_to_measure_change <- function(
  dat, column_names, prefix, url_str = NULL, min_columns = 3, itemequals = NULL) {
  
  TAMs <- NULL
  file_tams_str <- paste0(prefix, '_tams.RData')
  if (file.exists(file_tams_str)) {
    TAMs <- get(load(file_tams_str))
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
        dat, column_names = column_names, tam_models = tam_models
        , min_columns = min_columns, limit = 50)
      if (curr_length >= length(tam_models)) break
      save(tam_models, file = file_tam_models_str)
    }
    TAMs <- get_TAMs_to_measure_change(tam_models = tam_models, itemequals = itemequals)
    
    save(TAMs, file = file_tams_str)
  }
  
  return(TAMs)
}

## function to load and save the ability instrument to measure the change
load_and_save_ability_instrument_to_measure_change <- function(
  pre_dat, pos_dat, filename, userid
  , items.pre, items.pos, same_items.pre, same_items.pos) {
  
  tam_models <- NULL
  if (file.exists(filename)) {
    instrument <- get(load(filename))
    tam_models <- list(
      pre_mod1 = instrument$info.verification$pre_mod
      , pos_mod1 = instrument$info.verification$pos_mod
      , mod2 = instrument$global.estimation$mod
      , pre_mod3 = instrument$info.stacking$pre_mod
      , pos_mod3 = instrument$info.stacking$pos_mod
      , mod4 = instrument$info.racking$mod)
  }
  instrument <- GPCM.measure_change(
    pre_dat = pre_dat, pos_dat = pos_dat, userid = userid
    , items.pre = items.pre, items.pos = items.pos
    , same_items.pre = same_items.pre, same_items.pos = same_items.pos
    , tam_models = tam_models
  )
  if (!file.exists(filename)) save(instrument, file = filename)
  
  return(instrument)
}

###############################################################################
## Stacking and Racking analysis                                             ##
###############################################################################

# P\left ( X_{i,j} = x, x>0 \right ) \approx
#    exp\left [ \sum_{k=1}^{x}\alpha_{i}\theta_{i}-\delta_{i,k} \right ]

# \alpha: discrimination parameter      -> mod$item$B.Cat1.Dim1 OR mod$B[,,"Dim01"][,"Cat1"]
# \delta: uncentralized threshold       -> mod$xsi
# uncentralized accumulated threshold   -> -1*pre_mod$AXsi


###############################################################################
## Test Analyse Models (TAMs) for programming tasks as GPCM                  ##
###############################################################################

## drawing pre vs post points generating models to measure
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

## measuring change using GPCM by stacking and racking data
GPCM.measure_change <- function(
  pre_dat, pos_dat, items.pre, items.pos, same_items.pre, same_items.pos
  , userid = "UserID", verify = T, plotting = T, remove_outlier = T, tam_models = NULL) {
  
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
    if (!is.null(tam_models) && !is.null(tam_models$pos_mod1)) {
      pos_mod1 <- tam_models$pos_mod1
    } else {
      pos_mod1 <- tam.mml.2pl(dat[,items$pos], irtmodel = "GPCM")
    }
    pos_wle1 <- tam.wle(pos_mod1)
    
    if (!is.null(tam_models) && !is.null(tam_models$pre_mod1)) {
      pre_mod1 <- tam_models$pre_mod1
    } else {
      pre_mod1 <- tam.mml.2pl(dat[,items$pre], irtmodel = "GPCM")
    }
    pre_wle1 <- tam.wle(pre_mod1)
    
    pos_tt <- as.data.frame(tam.threshold(pos_mod1))
    pre_tt <- as.data.frame(tam.threshold(pre_mod1))
    tt <- plyr::rbind.fill(pos_tt,pre_tt)
    tt[,"Item"] <- c(IRT.threshold(pos_mod1, type="item"), IRT.threshold(pre_mod1, type="item"))
    rownames(tt) <- c(rownames(pos_tt), rownames(pre_tt))
    
    info.verification <- list(tt = data.frame(tt)
                              , pos_mod = pos_mod1, pre_mod = pre_mod1
                              , pos_wle = pos_wle1, pre_wle = pre_wle1)
    if (plotting) {
      dotchart(t(tt), pch = 16, main = "Verification: Thurstonian Thresholds", cex=0.5)
      plot_pre_vs_post(pre_wle1$theta, pos_wle1$theta, dat[[userid]]
                       , "Verification: Pre-test vs. Post-test")
    }
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
    mod2 <- tam.mml.2pl(resp, irtmodel='GPCM')
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
    pos_mod3 <- tam.mml.2pl(pos_resp, irtmodel="GPCM", B.fixed = pos_B2.fixed)
  }
  pos_wle3 <- tam.wle(pos_mod3)
  
  if (!is.null(tam_models) && !is.null(tam_models$pre_mod3)) {
    pre_mod3 <- tam_models$pre_mod3
  } else {
    pre_mod3 <- tam.mml.2pl(pre_resp, irtmodel="GPCM", B.fixed = pre_B2.fixed)
    xsi.names <- intersect(row.names(pos_mod3$xsi.fixed.estimated)
                           , row.names(pre_mod3$xsi.fixed.estimated))
    pos_xsi3.fixed <- pos_mod3$xsi.fixed.estimated[xsi.names,]
    pre_mod3 <- tam.mml.2pl(pre_resp, irtmodel="GPCM", B.fixed = pre_B2.fixed
                            , xsi.fixed = pos_xsi3.fixed)
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
    mod4 <- tam.mml.2pl(pre_resp, irtmodel = "GPCM", B.fixed = pre_B2.fixed)
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
  
  r_id <- c(dat[[userid]][dat$pos.sd.error == Inf],
            dat[[userid]][dat$pre.sd.error == Inf])
  dat_non <- dat[!(dat[[userid]] %in% unique(r_id)),]
  if (plotting) {
    plot_pre_vs_post(dat_non$pre.theta, dat_non$pos.theta, dat_non[[userid]]
                     , "Pre-test vs. Post-test")
  }
  
  if (remove_outlier) {
    r_id <- c(dat_non[[userid]][dat_non$pos.theta %in% boxplot.stats(dat_non$pos.theta)$out],
              dat_non[[userid]][dat_non$pre.theta %in% boxplot.stats(dat_non$pre.theta)$out])
    dat_wo <- dat_non[!(dat_non[[userid]] %in% unique(r_id)),]
    if (plotting) {
      plot_pre_vs_post(dat_wo$pre.theta, dat_wo$pos.theta, dat_wo[[userid]]
                       , "Pre-test vs. Post-test (Without Outliers)")
    }
  }
  
  return(list(
    ability.without = dat_wo, info.verification = info.verification
    , xsi = info.stacking$xsi, tt = info.stacking$tt, B = data.frame(mod2$B[,,])
    , global.estimation = list(mod = mod2, B = data.frame(mod2$B[,,]))
    , info.stacking = info.stacking, info.racking = info.racking
    , ability = dat_non, ability.all = dat))
}

## Save changes in file
GPCM.measure_change.saveFile <- function(result, filename = 'GPCM.measure_change.xlsx') {
  library(sirt)
  library(r2excel)
  
  wb <- createWorkbook(type='xlsx')
  
  ## write ability estimates (with outliers)
  ability_estimates_wo <- result$ability
  ability_estimates_all <- result$ability.all
  
  personfit_df <- sirt::pcm.fit(b = result$info.stacking$pre_mod$AXsi_[, -1]
                                , theta = result$info.stacking$pre_wle$theta
                                , dat = result$info.stacking$pre_mod$resp)$personfit
  personfit_df <- personfit_df[, -which(names(personfit_df) %in% 'person')]
  colnames(personfit_df) <- c('pre.outfit','pre.outfit.t','pre.infit','pre.infit.t')
  ability_estimates_all <- cbind(ability_estimates_all, personfit_df)
  
  personfit_df <- sirt::pcm.fit(b = result$info.stacking$pos_mod$AXsi_[, -1]
                                , theta = result$info.stacking$pos_wle$theta
                                , dat = result$info.stacking$pos_mod$resp)$personfit
  personfit_df <- personfit_df[, -which(names(personfit_df) %in% 'person')]
  colnames(personfit_df) <- c('pos.outfit','pos.outfit.t','pos.infit','pos.infit.t')
  ability_estimates_all <- cbind(ability_estimates_all, personfit_df)
  
  rownames(ability_estimates_all) <- ability_estimates_all$UserID
  
  ## write ability estimates (without inf)
  ability_estimates <- ability_estimates_all[which(ability_estimates_all$UserID %in% result$ability$UserID),]
  
  sheet0 <- createSheet(wb, sheetName = 'Ability Estimates')
  xlsx.addTable(wb, sheet0, ability_estimates, startCol = 1, row.names = F, columnWidth = 16)
  
  ## write ability estimates (all)
  sheet1 <- createSheet(wb, sheetName = 'Ability Estimates (all)')
  xlsx.addTable(wb, sheet1, ability_estimates_all, startCol = 1, row.names = F, columnWidth = 16)
  
  ## write ability estimates (with-out outliers)
  ability_estimates <- ability_estimates_all[which(ability_estimates_all$UserID %in% result$ability.without$UserID),]
  
  sheet2 <- createSheet(wb, sheetName = 'Ability Estimates (wo outliers)')
  xlsx.addTable(wb, sheet2, ability_estimates, startCol = 1, row.names = F, columnWidth = 16)
  
  ## write ability estimates statistics
  sheet3 <- createSheet(wb, sheetName = 'Ability Estimates (statistics)')
  pre_wle_info_df <- data.frame(unclass(summary(result$info.stacking$pre_wle))
                                , check.names = F, stringsAsFactors = F)
  pre_wle_info_df <- data.frame(
    'pre PersonScores' = pre_wle_info_df$` PersonScores`
    , 'pre theta' = pre_wle_info_df$`    theta`
    , 'pre error' = pre_wle_info_df$`    error`
    , 'pre N.items' = result$info.stacking$pre_wle$N.items[[1]]
    , 'pre ScoreMax' = result$info.stacking$pre_wle$PersonMax[[1]]
    , 'pre WLE.rel'= result$info.stacking$pre_wle$WLE.rel[[1]])
  xlsx.addTable(wb, sheet3, pre_wle_info_df, startCol = 1, row.names = F, columnWidth = 16)
  
  xlsx.addLineBreak(sheet3, 2)
  pos_wle_info_df <- data.frame(unclass(summary(result$info.stacking$pos_wle))
                                , check.names = F, stringsAsFactors = F)
  pos_wle_info_df <- data.frame(
    'pos PersonScores' = pos_wle_info_df$` PersonScores`
    , 'pos theta' = pos_wle_info_df$`    theta`
    , 'pos error' = pos_wle_info_df$`    error`
    , 'pos N.items' = result$info.stacking$pos_wle$N.items[[1]]
    , 'pos ScoreMax' = result$info.stacking$pos_wle$PersonMax[[1]]
    , 'pos WLE.rel' = result$info.stacking$pos_wle$WLE.rel[[1]])
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
  saveWorkbook(wb, filename)
}

