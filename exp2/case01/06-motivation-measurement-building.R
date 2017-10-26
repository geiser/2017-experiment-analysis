library(TAM)
library(readxl)
library(parallel)
#options(mc.cores=7)

sources = list(
  "Interest/Enjoyment" = list(
    sheed = "data", wid = "UserID", name = "Interest/Enjoyment"
    , filename = "report/motivation/interest-enjoyment/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("IE")
    , inv.keys = c()
    , column_names = list(Item01IE = c(NA, "Item01IE"), Item09IE = c(NA, "Item09IE")
                          , Item12IE = c(NA, "Item12IE"), Item21IE = c(NA, "Item21IE")
                          , Item22IE = c(NA, "Item22IE"), Item24IE = c(NA, "Item24IE"))
    , prefix =  "case01_interest_enjoyment", min_columns = 3
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item01IE+Item09IE+Item12IE+Item24IE"
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID", name = "Perceived Choice"
    , filename = "report/motivation/perceived-choice/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c("Item17PC", "Item15PC", "Item08PC", "Item02PC", "Item06PC", "Item20PC")
    , column_names = list(Item02PC = c(NA, "Item02PC"), Item05PC = c(NA, "Item05PC")
                          , Item06PC = c(NA, "Item06PC"), Item08PC = c(NA, "Item08PC")
                          , Item15PC = c(NA, "Item15PC"), Item17PC = c(NA, "Item17PC")
                          , Item20PC = c(NA, "Item20PC"), Item23PC = c(NA, "Item23PC"))
    , prefix =  "case01_perceived_choice", min_columns = 5
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item02PC+Item05PC+Item08PC+Item15PC+Item17PC+Item20PC+Item23PC"
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID", name = "Pressure/Tension"
    , filename = "report/motivation/pressure-tension/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys =  c("Item11PT")
    , column_names = list(Item11PT = c(NA, "Item11PT"), Item14PT = c(NA, "Item14PT")
                          , Item16PT = c(NA, "Item16PT"), Item18PT = c(NA, "Item18PT"))
    , prefix =  "case01_pressure_tension", min_columns = 2
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item11PT+Item14PT+Item16PT+Item18PT"
  )
)

data_map <- get_data_map_from_reports(sources)

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



