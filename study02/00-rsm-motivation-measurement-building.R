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
  "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "data/IMMS.csv"
    , path = "report/motivation/level-of-motivation/"
    , start.with = c("Item"), end.withs = c("A", "R", "S")
    , inv.keys = c("Item15R","Item21R", "Item10R"#, "Item08R"
                   ) # Item08 degrade the system
    , column_names = list(Item12A = c("Item12A"), Item19A = c("Item19A")
                          , Item04A = c("Item04A"), Item20A = c("Item20A")
                          , Item16A = c("Item16A"), Item01A = c("Item01A")
                          , Item15R = c("Item15R")
                          , Item21R = c("Item21R")
                          , Item10R = c("Item10R")#, Item08R = c("Item08R")
                          , Item13S = c("Item13S"), Item14S = c("Item14S")
                          , Item17S = c("Item17S"))
    , prefix =  "study02_level_motivation", min_columns = 12
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
    , model = "Item12A+Item19A+Item04A+Item20A+Item16A+Item01A+Item15R+Item21R+Item10R+Item13S+Item14S+Item17S"
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
    , prefix =  "study02_attention", min_columns = 6
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
    , prefix =  "study02_relevance", min_columns = 4
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
    , prefix =  "study02_satisfaction", min_columns = 3
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
  sources, tam_mods, estimator = "WLSMVS")
filename <- "report/latex/rsm-level-of-motivation.tex"
if (!file.exists(filename)) {
  write_rsm_in_latex(
    rsm_summaries
    , in_title = "for measuring the level of motivation of participants in the second empirical study"
    , filename = filename
  )
}

