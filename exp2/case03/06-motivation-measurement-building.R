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
    , inv.keys = c()
    , column_names = list(Item03PC = c(NA, "Item03PC"), Item05PC = c(NA, "Item05PC")
                          , Item13PC = c(NA, "Item13PC"), Item18PC = c(NA, "Item18PC")
                          , Item20PC = c(NA, "Item20PC"))
    , prefix =  "case03_perceived_choice", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214734&authkey=APtFDd6NxB7aoNo"
    , itemequals = NULL
    , model = "Item03PC+Item05PC+Item13PC+Item18PC+Item20PC"
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

#View(tam_info_models_map$`Interest/Enjoyment`$information)
#View(tam_info_models_map$`Perceived Choice`$information)
#View(tam_info_models_map$`Pressure/Tension`$information)
#View(tam_info_models_map$`Effort/Importance`$information)
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

dat <- merge(participants, list_abilities$`Interest/Enjoyment`[columns], by = "UserID")
write_csv(dat, 'data/InterestEnjoyment.csv')

dat <- merge(participants, list_abilities$`Perceived Choice`[columns], by = "UserID")
write_csv(dat, 'data/PerceivedChoice.csv')

dat <- merge(participants, list_abilities$`Pressure/Tension`[columns], by = "UserID")
write_csv(dat, 'data/PressureTension.csv')

dat <- merge(participants, list_abilities$`Effort/Importance`[columns], by = "UserID")
write_csv(dat, 'data/EffortImportance.csv')

dat <- merge(participants, list_abilities$Attention[columns], by = "UserID")
write_csv(dat, 'data/Attention.csv')

dat <- merge(participants, list_abilities$Satisfaction[columns], by = "UserID")
write_csv(dat, 'data/Satisfaction.csv')

dat <- participants
dat <- merge(dat, list_abilities$`Interest/Enjoyment`[columns], by = "UserID", suffixes = c("", ".IE"))
dat <- merge(dat, list_abilities$`Perceived Choice`[columns], by = "UserID", suffixes = c(".IE", ".PC"))
dat <- merge(dat, list_abilities$`Pressure/Tension`[columns], by = "UserID", suffixes = c(".PC", ".PT"))
dat <- merge(dat, list_abilities$`Effort/Importance`[columns], by = "UserID", suffixes = c(".PT", ".EI"))
dat <- dplyr::mutate(
  dat
  , PersonScores = (PersonScores.IE+PersonScores.PC-PersonScores.PT+PersonScores.EI)/4
  , theta = (theta.IE+theta.PC-theta.PT+theta.EI)/4
  , error = (error.IE+error.PC-error.PT+error.EI)/4
)
write_csv(dat, 'data/IntrinsicMotivation.csv')

dat <- participants
dat <- merge(dat, list_abilities$Attention[columns], by = "UserID", suffixes = c("", ".A"))
dat <- merge(dat, list_abilities$Satisfaction[columns], by = "UserID", suffixes = c(".A", ".S"))
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



