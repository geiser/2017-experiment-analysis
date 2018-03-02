library(TAM)
library(readxl)
library(parallel)
#options(mc.cores=7)

sources = list(
  "Attention" = list(
    sheed = "data", wid = "UserID", name = "Attention"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/attention/"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
    , column_names = list(Item01A = c(NA, "Item01A"), Item04A = c(NA, "Item04A")
                          , Item05A = c(NA, "Item05A"), Item12A = c(NA, "Item12A")
                          , Item19A = c(NA, "Item19A"), Item20A = c(NA, "Item20A"))
    , prefix =  "case02_attention", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214748&authkey=ANcCqM1ILXtB4vQ"
    , itemequals = NULL
    , model = "Item05A+Item12A+Item19A+Item20A"
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID", name = "Satisfaction"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/satisfaction/"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c()
    , column_names = list(Item09S = c(NA, "Item09S"), Item11S = c(NA, "Item11S")
                          , Item14S = c(NA, "Item14S"), Item24S = c(NA, "Item24S")
                          , Item25S = c(NA, "Item25S"))
    , prefix =  "case02_satisfaction", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214752&authkey=AErkrjFTDtNIH30"
    , itemequals = NULL
    , model = "Item11S+Item24S+Item25S"
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/level-of-motivation/"
    , start.with = c("Item"), end.withs = c("A", "S")
    , inv.keys = c()
    , column_names = list()
    , prefix =  "case02_level_motivation", min_columns = 7
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item05A+Item12A+Item19A+Item20A+Item11S+Item24S+Item25S"
  )
)

data_map <- get_data_map_for_RSM(sources)

tam_info_models_map <- lapply(sources, FUN = function(x, data_map) {
  if (is.null(x$column_names) || length(x$column_names) < 3) return(NULL)
  tam_info_models <- load_and_save_TAMs_to_measure_skill(
    data_map[[x$name]]
    , column_names = x$column_names
    , url_str = x$url_str
    , itemequals = x$itemequals
    , prefix = x$prefix, min_columns = x$min_columns
    , fixed = x$fixed
    , irtmodel = "RSM")
  return(tam_info_models)
}, data_map = data_map)

#View(tam_info_models_map$Attention$information)
#View(tam_info_models_map$Satisfaction$information)

tam_mods <- lapply(sources, FUN = function(x) {
  return(get_TAM(
    x$model
    , data_map[[x$name]]
    , irtmodel = "RSM"
    , wid = x$wid))
})

## write report
list_abilities <- lapply(sources, FUN = function(x, tam_mods, data_map) {
  library(TAM)
  
  mod <- tam_mods[[x$name]]
  write_tam_report(mod, x$path, "MeasurementModel.xlsx", TRUE)
  
  wmod <- tam.wle(mod)
  return(as.data.frame(unclass(wmod))[c('pid', 'theta', 'error', 'WLE.rel')])
}, tam_mods = tam_mods, data_map = data_map)

## write csv
columns <- c('UserID','PersonScores','theta','error')
participants <- read_csv('data/Participant.csv')

dat <- merge(participants, list_abilities$Attention, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/Attention.csv')

dat <- merge(participants, list_abilities$Satisfaction, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/Satisfaction.csv')

dat <- merge(participants, list_abilities$`Level of Motivation`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/LevelMotivation.csv')

## write plots
lapply(sources, FUN = function(x, tam_mods) {
  mod <- tam_mods[[x$name]]
  write_measurement_model_plots(
    mod
    , paste0(x$path, "measurement-model-plots/")
    , override = TRUE)
}, tam_mods = tam_mods)
