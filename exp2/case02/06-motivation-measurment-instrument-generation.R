library(TAM)
library(readxl)
library(parallel)
#options(mc.cores=7)

sources = list(
  "Attention" = list(
    sheed = "data", wid = "UserID", name = "Attention"
    , filename = "report/motivation/attention/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
    , column_names = list(Item01A = c(NA, "Item01A"), Item04A = c(NA, "Item04A")
                          , Item05A = c(NA, "Item05A"), Item12A = c(NA, "Item12A")
                          , Item19A = c(NA, "Item19A"), Item20A = c(NA, "Item20A"))
    , prefix =  "case02_attention", min_columns = 3
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID", name = "Satisfaction"
    , filename = "report/motivation/satisfaction/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c()
    , column_names = list(Item09S = c(NA, "Item09S"), Item11S = c(NA, "Item11S")
                          , Item14S = c(NA, "Item14S"), Item24S = c(NA, "Item24S")
                          , Item25S = c(NA, "Item25S"))
    , prefix =  "case02_satisfaction", min_columns = 2
    , fixed = NULL
    , url_str = NULL
    , itemequals = NULL
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "report/motivation/level-of-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A", "S")
    , inv.keys = c()
    , column_names = list(Item01A = c(NA, "Item01A"), Item04A = c(NA, "Item04A")
                          , Item05A = c(NA, "Item05A"), Item12A = c(NA, "Item12A")
                          , Item19A = c(NA, "Item19A"), Item20A = c(NA, "Item20A")
                          
                          , Item09S = c(NA, "Item09S"), Item11S = c(NA, "Item11S")
                          , Item14S = c(NA, "Item14S"), Item24S = c(NA, "Item24S")
                          , Item25S = c(NA, "Item25S"))
    , prefix =  "case02_level_of_motivation", min_columns = 8
    , fixed = NULL
    , url_str = NULL
    , itemequals = list(ItemA=c('Item01A', 'Item04A', 'Item05A', 'Item12A', 'Item19A', 'Item20A')
                        , ItemS=c('Item09S','Item11S', 'Item14S', 'Item24S', 'Item25S'))
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
    , irtmodel = "RSM")
  return(tam_info_models)
}, data_map = data_map)


