library(TAM)
library(readxl)
library(parallel)
#options(mc.cores=7)

sources = list(
  "Interest/Enjoyment" = list(
    sheed = "data", wid = "UserID", name = "Interest/Enjoyment"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/interest-enjoyment/"
    , start.with = c("Item"), end.withs = c("IE")
    , inv.keys = c()
    , column_names = list(Item08IE = c(NA, "Item08IE"), Item09IE = c(NA, "Item09IE")
                          , Item11IE = c(NA, "Item11IE"), Item12IE = c(NA, "Item12IE")
                          , Item21IE = c(NA, "Item21IE"), Item24IE = c(NA, "Item24IE"))
    , prefix =  "case03_interest_enjoyment", min_columns = 4
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214730&authkey=ACNtHGzE3m8-6zk"
    , itemequals = NULL
    , model = "Item08IE+Item09IE+Item12IE+Item21IE+Item24IE"
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID", name = "Perceived Choice"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/perceived-choice/"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c("Item03PC", "Item05PC", "Item13PC", "Item18PC", "Item20PC")
    , column_names = list(Item03PC = c(NA, "Item03PC"), Item05PC = c(NA, "Item05PC")
                          , Item13PC = c(NA, "Item13PC"), Item18PC = c(NA, "Item18PC")
                          , Item20PC = c(NA, "Item20PC"))
    , prefix =  "case03_perceived_choice", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214734&authkey=APtFDd6NxB7aoNo"
    , itemequals = NULL
    , model = "Item03PC+Item05PC+Item18PC"
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID", name = "Pressure/Tension"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/pressure-tension/"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys = c("Item23PT")
    , column_names = list(Item02PT = c(NA, "Item02PT"), Item04PT = c(NA, "Item04PT")
                          , Item06PT = c(NA, "Item06PT"), Item23PT = c(NA, "Item23PT"))
    , prefix =  "case03_pressure_tension", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214736&authkey=ABZ1YPbVwbZPfno"
    , itemequals = NULL
    , model = "Item02PT+Item04PT+Item06PT"
  )
  , "Effort/Importance" = list(
    sheed = "data", wid = "UserID", name = "Effort/Importance"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/effort-importance/"
    , start.with = c("Item"), end.withs = c("EI")
    , inv.keys = c("Item01EI", "Item19EI")
    , column_names = list(Item01EI = c(NA, "Item01EI"), Item14EI = c(NA, "Item14EI")
                          , Item19EI = c(NA, "Item19EI"), Item22EI = c(NA, "Item22EI"))
    , prefix =  "case03_effort_importance", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214727&authkey=ANqLsKIjd44RKdM"
    , itemequals = NULL
    , model = "Item01EI+Item14EI+Item19EI"
  )
  , "Attention" = list(
    sheed = "data", wid = "UserID", name = "Attention"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/attention/"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
    , column_names = list(Item18A = c(NA, "Item18A"), Item20A = c(NA, "Item20A")
                          , Item25A = c(NA, "Item25A"), Item07A = c(NA, "Item07A")
                          , Item13A = c(NA, "Item13A"))
    , prefix =  "case03_attention", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214725&authkey=AP57z7OeXAyjJAg"
    , itemequals = NULL
    , model = "Item18A+Item20A+Item25A+Item07A+Item13A"
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID", name = "Satisfaction"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/satisfaction/"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c("Item21S")
    , column_names = list(Item01S = c(NA, "Item01S"), Item02S = c(NA, "Item02S")
                          , Item05S = c(NA, "Item05S"), Item21S = c(NA, "Item21S"))
    , prefix =  "case03_satisfaction", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214738&authkey=AHgozRlQl_KiCmE"
    , itemequals = NULL
    , model = "Item01S+Item02S+Item05S"
  )
  , "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID", name = "Intrinsic Motivation"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/intrinsic-motivation/"
    , start.with = c("Item"), end.withs = c("IE", "PC", "PT", "EI")
    , inv.keys = c("Item05PC", "Item20PC", "Item18PC", "Item13PC", "Item03PC"
                   , "Item02PT",  "Item06PT", "Item04PT", "Item01EI",  "Item19EI")
    , column_names = list()
    , prefix =  "case03_intrinsic_motivation", min_columns = 18
    , fixed = c("Item01EI","Item02PT","Item03PC","Item04PT","Item05PC","Item06PT","Item08IE","Item09IE","Item12IE","Item14EI","Item18PC","Item19EI","Item21IE","Item24IE")
    , url_str = NULL
    , itemequals = NULL
    , model = "Item01EI+Item02PT+Item03PC+Item04PT+Item05PC+Item06PT+Item08IE+Item09IE+Item12IE+Item14EI+Item18PC+Item19EI+Item21IE+Item24IE"
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "AnovaAnalysis.xlsx"
    , path = "report/motivation/level-of-motivation/"
    , start.with = c("Item"), end.withs = c("A", "S")
    , inv.keys = c("Item21S")
    , column_names = list()
    , prefix =  "case03_level_motivation", min_columns = 8
    , fixed = c("Item07A","Item13A","Item18A","Item20A","Item25A","Item01S","Item02S","Item05S")
    , url_str = NULL
    , itemequals = NULL
    , model = "Item07A+Item13A+Item18A+Item20A+Item25A+Item01S+Item02S+Item05S"
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
#View(tam_info_models_map$`Effort/Importance`$information)
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
  write_tam_report(mod, x$path, "MeasurementModel.xlsx", FALSE)
  
  wmod <- tam.wle(mod)
  return(as.data.frame(unclass(wmod))[c('pid', 'theta', 'error', 'WLE.rel')])
}, tam_mods = tam_mods, data_map = data_map)

## write csv
participants <- read_csv('data/Participant.csv')

dat <- merge(participants, list_abilities$`Interest/Enjoyment`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/InterestEnjoyment.csv')

dat <- merge(participants, list_abilities$`Perceived Choice`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/PerceivedChoice.csv')

dat <- merge(participants, list_abilities$`Pressure/Tension`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/PressureTension.csv')

dat <- merge(participants, list_abilities$`Effort/Importance`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/EffortImportance.csv')

dat <- merge(participants, list_abilities$Attention, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/Attention.csv')

dat <- merge(participants, list_abilities$Satisfaction, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/Satisfaction.csv')

dat <- merge(participants, list_abilities$`Intrinsic Motivation`, by.x = "UserID", by.y = "pid")
write_csv(dat, 'data/IntrinsicMotivation.csv')

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

