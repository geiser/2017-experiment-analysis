library(TAM)
library(sirt)
library(plyr)
library(readxl)
library(parallel)
#options(mc.cores=7)

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
      , Item18PT = c("Item18PT"), Item11PT = c("Item11PT")
      # Effort/Importance
      , Item13EI = c("Item13EI"), Item03EI = c("Item03EI")
      , Item07EI = c("Item07EI"))
    , prefix =  "study03_intrinsic_motivation", min_columns = 17
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item22IE+Item09IE+Item12IE+Item24IE+Item21IE+Item01IE+Item17PC+Item15PC+Item06PC+Item02PC+Item08PC+Item16PT+Item14PT+Item18PT+Item11PT+Item13EI+Item03EI+Item07EI"
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
    , prefix =  "study03_interest_enjoyment", min_columns = 6
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
    , prefix =  "study03_perceived_choice", min_columns = 5
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
    , prefix =  "study03_pressure_tension", min_columns = 4
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
    , prefix =  "study03_effort_importance", min_columns = 2
    , fixed = NULL
    , url_str = NULL
    , itemclusters = NULL
    , model = "Item13EI+Item03EI+Item07EI"
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "data/IMMS.csv"
    , path = "report/motivation/level-of-motivation/"
    , start.with = c("Item"), end.withs = c("A", "R", "S")
    , inv.keys = c(#"Item15R",
                   "Item21R", "Item10R", "Item08R") # item 15 cause non-monotonocity
    , column_names = list(Item12A = c("Item12A"), Item19A = c("Item19A")
                          , Item04A = c("Item04A"), Item20A = c("Item20A")
                          , Item16A = c("Item16A"), Item01A = c("Item01A")
                          #, Item15R = c("Item15R")
                          , Item21R = c("Item21R")
                          , Item10R = c("Item10R"), Item08R = c("Item08R")
                          , Item13S = c("Item13S"), Item14S = c("Item14S")
                          , Item17S = c("Item17S"))
    , prefix =  "study03_level_motivation", min_columns = 12
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item12A+Item19A+Item04A+Item20A+Item16A+Item01A+Item21R+Item10R+Item08R+Item13S+Item14S+Item17S"
  )
  , "Attention" = list(
    sheed = "data", wid = "UserID", name = "Attention"
    , filename = "data/IMMS.csv"
    , path = "report/motivation/attention/"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
    , column_names = list(Item12A = c("Item12A"), Item19A = c("Item19A")
                          , Item04A = c("Item04A"), Item20A = c("Item20A")
                          , Item16A = c("Item16A"), Item01A = c("Item01A"))
    , prefix =  "study03_attention", min_columns = 6
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item12A+Item19A+Item04A+Item20A+Item16A+Item01A"
  )
  , "Relevance" = list(
    sheed = "data", wid = "UserID", name = "Relevance"
    , filename = "data/IMMS.csv"
    , path = "report/motivation/relevance/"
    , start.with = c("Item"), end.withs = c("R")
    , inv.keys = c("Item15R", "Item21R", "Item10R", "Item08R")
    , column_names = list(Item15R = c("Item15R"), Item21R = c("Item21R")
                          , Item10R = c("Item10R"), Item08R = c("Item08R"))
    , prefix =  "study03_relevance", min_columns = 4
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item15R+Item21R+Item10R+Item08R"
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID", name = "Satisfaction"
    , filename = "data/IMMS.csv"
    , path = "report/motivation/satisfaction/"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c()
    , column_names = list(Item13S = c("Item13S"), Item14S = c("Item14S")
                          , Item17S = c("Item17S"))
    , prefix =  "study03_satisfaction", min_columns = 3
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item13S+Item14S+Item17S"
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
sources_im <- sources[c("Intrinsic Motivation", "Interest/Enjoyment", "Perceived Choice", "Pressure/Tension", "Effort/Importance")]
tam_mods_im <- tam_mods[c("Intrinsic Motivation", "Interest/Enjoyment", "Perceived Choice", "Pressure/Tension", "Effort/Importance")]
rsm_summaries <- get_rsm_summaries_as_dataframe(
  sources_im, tam_mods_im, estimator = "WLSMVS", scores = list(
    "Intrinsic Motivation" = abilities$`Intrinsic Motivation`$theta))
filename <- "report/latex/rsm-intrinsic-motivation.tex"
if (!file.exists(filename)) {
  write_rsm_in_latex(
    rsm_summaries
    , in_title = "for measuring the intrinsic motivation of participants in the third empirical study"
    , filename = filename
  )
}

sources_lm <- sources[c("Level of Motivation", "Attention", "Relevance", "Satisfaction")]
tam_mods_lm <- tam_mods[c("Level of Motivation", "Attention", "Relevance", "Satisfaction")]
rsm_summaries <- get_rsm_summaries_as_dataframe(
  sources_lm, tam_mods_lm, estimator = "WLSMVS")
filename <- "report/latex/rsm-level-of-motivation.tex"
if (!file.exists(filename)) {
  write_rsm_in_latex(
    rsm_summaries
    , in_title = "for measuring the level of motivation of participants in the third empirical study"
    , filename = filename
  )
}
