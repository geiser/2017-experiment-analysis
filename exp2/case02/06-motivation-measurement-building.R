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
    , model = "Item04A+Item05A+Item12A+Item19A+Item20A"
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
    , model = "Item09S+Item11S+Item14S"
  )
)

data_map <- get_data_map_for_RSM(sources)

tam_info_models_map <- lapply(sources, FUN = function(x, data_map) {
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
  return(load_tam_mod(
    x$model
    , url_str = x$url_str
    , prefix = x$prefix
  ))
})

## write report
list_abilities <- lapply(sources, FUN = function(x, tam_mods, data_map) {
  library(TAM)
  
  mod <- tam_mods[[x$name]]
  userids <- data_map[[x$name]][[x$wid]]
  write_tam_report(mod, x$path, "MeasurementModel.xlsx", FALSE, userids)
  
  wmod <- tam.wle(mod)
  rdat <- cbind(data.frame(UserID=userids), as.data.frame(unclass(wmod)))
  
  return(rdat)
}, tam_mods = tam_mods, data_map = data_map)

## write csv
columns <- c('UserID','PersonScores','theta','error')
participants <- read_csv('data/Participant.csv')

dat <- merge(participants, list_abilities$Attention[columns], by = "UserID")
write_csv(dat, 'data/Attention.csv')

dat <- merge(participants, list_abilities$Satisfaction[columns], by = "UserID")
write_csv(dat, 'data/PerceivedChoice.csv')


dat <- merge(participants, list_abilities$Attention[columns], by = "UserID")
dat <- merge(dat, list_abilities$Satisfaction[columns], by = "UserID")
colnames(dat) <- c(colnames(participants), c("PersonScores.A", "theta.A", "error.A"), c("PersonScores.S", "theta.S", "error.S"))
dat <- dplyr::mutate(
  dat
  , PersonScores = (PersonScores.A+PersonScores.S)/2
  , theta = (theta.A+theta.S)/2
  , error = (error.A+error.S)/2
)
write_csv(dat, 'data/LevelMotivation.csv')

## write plots
lapply(sources, FUN = function(x, tam_mods) {
  mod <- tam_mods[[x$name]]
  write_measurement_model_plots(
    mod
    , paste0(x$path, "measurement-model-plots/")
    , override = TRUE)
}, tam_mods = tam_mods)
