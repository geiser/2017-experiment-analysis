library(TAM)
library(readxl)
library(parallel)
#options(mc.cores=7)

sources = list(
  "Interest/Enjoyment" = list(
    sheed = "data", wid = "UserID", name = "Interest/Enjoyment"
    , filename = "WilcoxAnalysis.xlsx" #"AnovaAnalysis.xlsx"
    , path = "report/motivation/interest-enjoyment/"
    , start.with = c("Item"), end.withs = c("IE")
    , inv.keys = c()
    , column_names = list(Item01IE = c(NA, "Item01IE"), Item09IE = c(NA, "Item09IE")
                          , Item12IE = c(NA, "Item12IE"), Item21IE = c(NA, "Item21IE")
                          , Item22IE = c(NA, "Item22IE"), Item24IE = c(NA, "Item24IE"))
    , prefix =  "case01_interest_enjoyment", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214742&authkey=AF_FWzjlWQoVI5w"
    , itemequals = NULL
    , model = "Item01IE+Item09IE+Item12IE+Item24IE"
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID", name = "Perceived Choice"
    , filename = "WilcoxAnalysis.xlsx" #"AnovaAnalysis.xlsx"
    , path = "report/motivation/perceived-choice/"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c("Item17PC", "Item15PC", "Item08PC", "Item02PC", "Item06PC", "Item20PC")
    , column_names = list(Item02PC = c(NA, "Item02PC"), Item05PC = c(NA, "Item05PC")
                          , Item06PC = c(NA, "Item06PC"), Item08PC = c(NA, "Item08PC")
                          , Item15PC = c(NA, "Item15PC"), Item17PC = c(NA, "Item17PC")
                          , Item20PC = c(NA, "Item20PC"), Item23PC = c(NA, "Item23PC"))
    , prefix =  "case01_perceived_choice", min_columns = 5
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214745&authkey=AIk_jH6zXolQABE"
    , itemequals = NULL
    , model = "Item02PC+Item05PC+Item06PC+Item08PC+Item15PC+Item20PC+Item23PC"
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID", name = "Pressure/Tension"
    , filename = "WilcoxAnalysis.xlsx" #"AnovaAnalysis.xlsx"
    , path = "report/motivation/pressure-tension/"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys =  c("Item11PT")
    , column_names = list(Item11PT = c(NA, "Item11PT"), Item14PT = c(NA, "Item14PT")
                          , Item16PT = c(NA, "Item16PT"), Item18PT = c(NA, "Item18PT"))
    , prefix =  "case01_pressure_tension", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214766&authkey=ALiJfJPnkMpRUEA"
    , itemequals = NULL
    , model = "Item11PT+Item14PT+Item16PT+Item18PT"
  )
  , "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID", name = "Intrinsic Motivation"
    , filename = "WilcoxAnalysis.xlsx" #"AnovaAnalysis.xlsx"
    , path = "report/motivation/intrinsic-motivation/"
    , start.with = c("Item"), end.withs = c("IE", "PC", "PT")
    , inv.keys =  c("Item17PC","Item15PC","Item08PC","Item02PC","Item06PC","Item20PC","Item14PT","Item16PT","Item18PT")
    , column_names = list()
    , prefix =  "case01_intrinsic_motivation", min_columns = 2
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item01IE+Item09IE+Item12IE+Item24IE+Item02PC+Item05PC+Item06PC+Item08PC+Item15PC+Item20PC+Item23PC+Item11PT+Item14PT+Item16PT+Item18PT"
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

#View(tam_info_models_map$`Interest/Enjoyment`$information)
#View(tam_info_models_map$`Perceived Choice`$information)
#View(tam_info_models_map$`Pressure/Tension`$information)

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

dat <- merge(participants, list_abilities$`Interest/Enjoyment`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/InterestEnjoyment.csv')

dat <- merge(participants, list_abilities$`Perceived Choice`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/PerceivedChoice.csv')

dat <- merge(participants, list_abilities$`Pressure/Tension`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/PressureTension.csv')

dat <- merge(participants, list_abilities$`Intrinsic Motivation`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/IntrinsicMotivation.csv')

## write plots
lapply(sources, FUN = function(x, tam_mods) {
  mod <- tam_mods[[x$name]]
  write_measurement_model_plots(
    mod
    , paste0(x$path, "measurement-model-plots/")
    , override = TRUE)
}, tam_mods = tam_mods)

