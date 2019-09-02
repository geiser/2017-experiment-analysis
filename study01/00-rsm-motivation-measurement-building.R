library(TAM)
library(sirt)
library(plyr)
library(readxl)
library(parallel)
#options(mc.cores=7)

source('../common/misc.R')
source('../common/measurement-building.R')
source('../common/latex-translator.R')

sources = list(
  "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID", name = "Intrinsic Motivation"
    , filename = "data/IMI.csv"
    , path = "report/motivation/intrinsic-motivation/"
    , start.with = c("Item"), end.withs = c("IE","PC","PT","EI")
    , inv.keys = c("Item17PC", "Item15PC", "Item06PC", "Item02PC", "Item08PC"
                   , "Item16PT", "Item14PT", "Item18PT"
                   , "Item13EI", "Item07EI")
    , column_names = list(
      # Interest/Enjoyment
      Item22IE = c("Item22IE"), Item09IE = c("Item09IE")
      , Item12IE = c("Item12IE"), Item24IE = c("Item24IE")
      , Item21IE = c("Item21IE"), Item01IE = c("Item01IE")
      # Perceived Competence
      , Item17PC = c("Item17PC"), Item15PC = c("Item15PC")
      , Item06PC = c("Item06PC"), Item02PC = c("Item02PC")
      , Item08PC = c("Item08PC")
      # Pressure/Tension
      , Item16PT = c("Item16PT"), Item14PT = c("Item14PT")
      , Item18PT = c("Item18PT")#, Item11PT = c("Item11PT")
      # Effort/Importance
      , Item13EI = c("Item13EI"), Item03EI = c("Item03EI")
      , Item07EI = c("Item07EI"))
    , prefix =  "pilot_intrinsic_motivation", min_columns = 17
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item22IE+Item09IE+Item12IE+Item24IE+Item21IE+Item01IE+Item17PC+Item15PC+Item06PC+Item02PC+Item08PC+Item16PT+Item14PT+Item18PT+Item13EI+Item03EI+Item07EI"
  )
  , "Interest/Enjoyment" = list(
    sheed = "data", wid = "UserID", name = "Interest/Enjoyment"
    , filename = "data/IMI.csv"
    , path = "report/motivation/interest-enjoyment/"
    , start.with = c("Item"), end.withs = c("IE")
    , inv.keys = c()
    , column_names = list(Item22IE = c("Item22IE"), Item09IE = c("Item09IE")
                          , Item12IE = c("Item12IE"), Item24IE = c("Item24IE")
                          , Item21IE = c("Item21IE"), Item01IE = c("Item01IE"))
    , prefix =  "pilot_interest_enjoyment", min_columns = 6
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item22IE+Item09IE+Item12IE+Item24IE+Item21IE+Item01IE"
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID", name = "Perceived Choice"
    , filename = "data/IMI.csv"
    , path = "report/motivation/perceived-choice/"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c("Item17PC", "Item15PC", "Item06PC", "Item02PC", "Item08PC")
    , column_names = list(Item17PC = c("Item17PC"), Item15PC = c("Item15PC")
                          , Item06PC = c("Item06PC"), Item02PC = c("Item02PC")
                          , Item08PC = c("Item08PC"))
    , prefix =  "pilot_perceived_choice", min_columns = 5
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item17PC+Item15PC+Item06PC+Item02PC+Item08PC"
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID", name = "Pressure/Tension"
    , filename = "data/IMI.csv"
    , path = "report/motivation/pressure-tension/"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys = c("Item11PT")
    , column_names = list(Item16PT = c("Item16PT"), Item14PT = c("Item14PT")
                          , Item18PT = c("Item18PT"), Item11PT = c("Item11PT"))
    , prefix =  "pilot_pressure_tension", min_columns = 4
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item16PT+Item14PT+Item18PT+Item11PT"
  )
  , "Effort/Importance" = list(
    sheed = "data", wid = "UserID", name = "Effort/Importance"
    , filename = "data/IMI.csv"
    , path = "report/motivation/effort-importance/"
    , start.with = c("Item"), end.withs = c("EI")
    , inv.keys = c("Item13EI", "Item07EI")
    , column_names = list(Item13EI = c("Item13EI"), Item03EI = c("Item03EI")
                          , Item07EI = c("Item07EI"))
    , prefix =  "pilot_effort_importance", min_columns = 2
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item13EI+Item03EI+Item07EI"
  )
)

data_map <- get_data_map_for_RSM(sources, min_cat = 1, max_cat = 7)

#
tam_mods <- lapply(sources, FUN = function(x) {
  return(get_TAM(
    x$model
    , data_map[[x$name]]
    , irtmodel = "RSM"
    , wid = x$wid))
})

# print problematic items
(problematic_items <- do.call(rbind, lapply(tam_mods, FUN = function(mod) {
  item_fit <- tam.fit(mod, progress = F)$itemfit
  item_fit <- as.data.frame(item_fit[item_fit$parameter %in% colnames(mod$resp),])
  return(item_fit[(item_fit$Outfit > 2 | item_fit$Infit > 2),])
})))

##################################################################
## Getting TAM Reports                                          ##
##################################################################

abilities <- get_abilities(sources, tam_mods)
abilities$`Intrinsic Motivation`$theta <- (
  abilities$`Interest/Enjoyment`$theta
  + abilities$`Perceived Choice`$theta
  - abilities$`Pressure/Tension`$theta
  + abilities$`Effort/Importance`$theta)/4

## write report
lapply(sources, FUN = function(x) {
  library(TAM)
  mod <- tam_mods[[x$name]]
  write_tam_report(mod, x$path, "MeasurementModel.xlsx", TRUE)
})

## write csv
participants <- read_csv('data/SignedUpParticipants.csv')
lapply(sources, FUN = function(x) {
  ability_df <- abilities[[x$name]]
  ability_df[["UserID"]] <- rownames(ability_df)
  dat <- merge(participants, ability_df, by = "UserID")
  write_csv(dat, paste0('data/', gsub("/", "", gsub(" ", "", x$name)),'.csv'))
})

## write plots
lapply(sources, FUN = function(x, tam_mods) {
  mod <- tam_mods[[x$name]]
  write_measurement_model_plots(
    mod
    , paste0(x$path, "measurement-model-plots/")
    , override = TRUE)
}, tam_mods = tam_mods)


## latex translated
rsm_summaries <- get_rsm_summaries_as_dataframe(
  sources, tam_mods, estimator = "WLSMVS", scores = list(
    "Intrinsic Motivation" = abilities$`Intrinsic Motivation`$theta))
filename <- "report/latex/rsm-motivation.tex"
if (!file.exists(filename)) {
  write_rsm_in_latex(
    rsm_summaries
    , in_title = "for measuring the intrinsic motivation of participants in the first empirical study"
    , filename = filename
  )
}
