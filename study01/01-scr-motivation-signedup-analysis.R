wants <- c('RcppAlgos', 'MVN', 'robustHD', 'daff', 'plyr', 'dplyr', 'readr')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(MVN)
library(daff)
library(plyr)
library(robustHD)

library(readr)
library(dplyr)
library(car)
library(afex)
library(dplyr)
library(stats)
library(ez)

participants <- read_csv('data/SignedUpParticipants.csv')

sources <- list(
  "Interest/Enjoyment" = list(
    filename = "data/IMI.csv", name = "Interest/Enjoyment"
    , extra_rmids = c(), folder = "interest-enjoyment"
  )
  , "Perceived Choice" = list(
    filename = "data/IMI.csv", name = "Perceived Choice"
    , extra_rmids = c(), folder = "perceived-choice"
  )
  , "Pressure/Tension" = list(
    filename = "data/IMI.csv", name = "Pressure/Tension"
    , extra_rmids = c(), folder = "pressure-tension"
  )
  , "Effort/Importance" = list(
    filename = "data/IMI.csv", name = "Effort/Importance"
    , extra_rmids = c(), folder = "effort-importance"
  )
  , "Intrinsic Motivation" = list(
    filename = "data/IMI.csv", name = "Intrinsic Motivation"
    , extra_rmids = c(), folder = "intrinsic-motivation"
  )
)

##
sdat_map <- lapply(sources, FUN = function(src) {
  if (!is.null(src$filename)) {
    sdat <- read_csv(src$filename)
    #sdat[[src$name]] <- sdat[[src$name]]
    return(sdat)
  }
})

##
dvs <- c("Interest/Enjoyment", "Perceived Choice"
         , "Pressure/Tension", "Effort/Importance", "Intrinsic Motivation")
list_dvs <- as.list(dvs)
names(list_dvs) <- dvs

list_info <- lapply(list_dvs, FUN = function(dv) {
  name <- gsub('\\W', '', dv)
  ivs <- c("Type")
  list_ivs <- as.list(ivs)
  names(list_ivs) <- ivs
  info <- lapply(list_ivs, function(iv) {
    return(list(
      title = paste0(dv, " by ", iv)
      , path = paste0("report/motivation/scr-signedup-participants/", sources[[dv]]$folder,"/by-",iv,"/")
      , iv = iv
    ))
  })
  
  return(list(dv=dv, name =name, info = info))
})

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
all_nonparametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  sdat <- merge(participants, sdat_map[[dv]])
  dir.create(paste0("report/motivation/scr-signedup-participants/", sources[[dv]]$folder), showWarnings = F)
  
  nonparametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'nonparametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'nonparametric-analysis-plots/')
    filename <- paste0(x$path, 'NonParametricAnalysis.xlsx')
    result <- do_nonparametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"))
    
    write_plots_for_nonparametric_test(
      result, ylab = "score", title = x$title
      , path = path, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    write_nonparametric_test_report(
      result, ylab = "score", title = x$title
      , filename = filename, override = T
      , ylim = c(1,7), levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

## translate to latex
lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  nonparametric_results <- all_nonparametric_results[[dv]]
  ##
  write_nonparam_statistics_analysis_in_latex(
    nonparametric_results, dvs = names(info)
    , filename = paste0("report/latex/motivation-signedup/nonparametric-"
                        , sources[[dv]]$folder, "-scr-analysis.tex")
    , in_title = paste0(" for the scores of ", dv
                        , " in the first study for signed up students")
  )
})


#############################################################################
## Parametric Statistic Analysis                                           ##
#############################################################################
winsor_mod <- winsorize_two_by_two_design(participants, sdat_map, list_dvs, ivs_list = list(
  iv1 = list(iv = "Type", values = c("non-gamified", "ont-gamified"))
  , iv2 = list(iv = "CLRole", values = c("Master", "Apprentice"))
))

render_diff(winsor_mod$diff_dat)
(mvn_mod <- mvn(winsor_mod$wdat[,dvs], univariatePlot = "box", univariateTest = "SW"))


dat = winsor_mod$wdat





generated_names <- list()

min=30

#nrow(dat)
dat=winsor_mod$wdat



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
  , wid="UserID", dv="Pressure/Tension", iv="Type", between = c("Type","CLRole")
  , path = "data/pressure-tension"
  , pos_file_aov_assumptions_str = "aov_assumptions.RData") {
  
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
      result <- do.call(rbind, lapply(generated_names, get_aov_assumption, dat=dat
                                      , wid=wid, dv=dv, iv=iv, between = between))
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


ilist <- as.list(c(nrow(dat):30))
names(ilist) <- c(nrow(dat):30)
lapply(ilist, generate_file_aov_assumptions, dat
       , wid="UserID", dv="Pressure/Tension", iv="Type", between = c("Type","CLRole")
       , path = "data/pressure-tension"
       , pos_file_aov_assumptions_str = "aov_assumptions.RData")




for (i in nrow(dat):min) {
  
}

k <- 55

df_assumptions <- do.call(
  rbind
  , lapply(Sys.glob(paste0("f_",k,"_*_",pre_file_aov_assumptions_str))
           , function(file_name) {
             return(get(load(file_name)))
           }))

View()







repeat {
  curr_length <- length(tam_models)
  tam_models <- get_TAMs(
    dat, column_names = column_names, tam_models = tam_models, fixed = fixed
    , fixed_sets = fixed_sets
    , min_columns = min_columns, limit = 20, irtmodel = irtmodel)
  if (curr_length >= length(tam_models)) break
  save(tam_models, file = file_tam_models_str)
}


#
skip_stop <- c()#"Pressure/Tension")
extra_rmids <- list(
  "Pressure/Tension" = c(
    10230,10292
    ,10192,10222,10212
    ,10186,10183
    ,10220,10203
    ,10178
    ,10233
    ,10176
    ,10171
    ,10190
    ,10224
    ,10208
    ,10175
                         )
)

# Validate Assumptions
lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  lapply(info, FUN = function(x) {
    sdat <- winsor_mod$wdat
    if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
      cat('\n... removing ids c(', extra_rmids[[dv]], ') from: ', dv, ' by ', x$iv, '\n')
      sdat <- sdat[!sdat$UserID %in% extra_rmids[[dv]],]
    }
    
    result <- do_parametric_test(sdat, wid = 'UserID', dv = dv, iv = x$iv, between = c(x$iv, "CLRole"), cstratify = c("CLRole"))
    cat('\n... checking assumptions for: ', dv, ' by ', x$iv, '\n')
    print(result$test.min.size$error.warning.list)
    if (result$normality.fail) cat('\n... normality fail ...\n')
    if (result$homogeneity.fail) cat('\n... homogeneity fail ...\n')
    if (result$assumptions.fail) {
      plot_assumptions_for_parametric_test(result, x$dv)
      if (result$normality.fail) pnormPlot(result)
      stopifnot(dv %in% skip_stop)
    }
  })
})

## export reports and plots
all_parametric_results <- lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  
  dir.create(paste0("report/motivation/signedup-participants/", sources[[dv]]$folder), showWarnings = F)
  
  parametric_results <- lapply(info, FUN = function(x) {
    cat("\n .... processing: ", x$title, " ....\n")
    dir.create(file.path(x$path), showWarnings = F)
    dir.create(file.path(x$path, 'parametric-analysis-plots'), showWarnings = F)
    
    path <- paste0(x$path, 'parametric-analysis-plots/')
    filename <- paste0(x$path, 'ParametricAnalysis.xlsx')
    
    sdat <- winsor_mod$wdat
    if (!is.null(extra_rmids[[dv]]) && length(extra_rmids[[dv]]) > 0) {
      cat('\n... removing ids c(', extra_rmids[[dv]], ') from: ', dv, ' by ', x$iv, '\n')
      sdat <- sdat[!sdat$UserID %in% extra_rmids[[dv]],]
    }
    
    result <- do_parametric_test(sdat, wid = "UserID", dv = dv, iv = x$iv, between = c(x$iv, "CLRole"), cstratify = c("CLRole"))
    write_plots_for_parametric_test(
      result, ylab = "logit", title = x$title
      , path = path, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    write_parametric_test_report(
      result, ylab = "logit", title = x$title
      , filename = filename, override = T
      , ylim = NULL, levels = c('non-gamified','ont-gamified')
    )
    return(result)
  })
})

## translate to latex
write_winsorized_in_latex(
  winsor_mod$diff_dat
  , filename = "report/latex/motivation-signedup/wisorized-intrinsic-motivation.tex"
  , in_title = paste("for the latent trait estimates by",
                     "the RSM-based instrument for measuring"
                     ,"intrinsic motivation in the first study", "for signed up students")
)

lapply(list_dvs, function(dv) {
  info <- list_info[[dv]]$info
  parametric_results <- all_parametric_results[[dv]]
  ##
  write_param_statistics_analysis_in_latex(
    parametric_results, ivs = names(info)
    , filename = paste0("report/latex/motivation-signedup/parametric-", sources[[dv]]$folder, "-analysis.tex")
    , in_title = paste0(" for the latent trait estimates of ", dv, " in the first study "
                        , "for signed up students")
  )
})

#############################################################################
## Global summary                                                          ##
#############################################################################
write_param_and_nonparam_statistics_analysis_in_latex(
  all_parametric_results, all_nonparametric_results, list_info
  , filename = "report/latex/motivation-signedup/summary-analysis.tex"
  , in_title = "in the first study for signed up students")

