
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


