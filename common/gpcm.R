
#if (!'r2excel' %in% rownames(installed.packages())) {
#  devtools::install_github("kassambara/r2excel")  
#}

wants <- c('TAM', 'sirt', 'lavaan', 'ggrepel', 'parallel', 'reshape', 'ggplot2', 'dplyr', 'readr', 'readxl', 'multcomp')
has   <- wants %in% rownames(installed.packages())
if(any(!has)) install.packages(wants[!has])


###############################################################################
## Test Analyse Models (TAMs) for programming tasks as GPCM                  ##
###############################################################################







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

