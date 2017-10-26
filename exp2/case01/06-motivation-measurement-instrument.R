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
  )
  , "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID", name = "Intrinsic Motivation"
    , filename = "report/motivation/intrinsic-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("IE","PC","PT")
    , inv.keys =  c("Item17PC", "Item15PC", "Item08PC", "Item02PC", "Item06PC", "Item20PC", "Item16PT",  "Item14PT",  "Item18PT")
    , column_names = list(Item01IE = c(NA, "Item01IE"), Item09IE = c(NA, "Item09IE")
                          , Item12IE = c(NA, "Item12IE"), Item21IE = c(NA, "Item21IE")
                          , Item22IE = c(NA, "Item22IE"), Item24IE = c(NA, "Item24IE")
                          
                          , Item02PC = c(NA, "Item02PC"), Item05PC = c(NA, "Item05PC")
                          , Item06PC = c(NA, "Item06PC"), Item08PC = c(NA, "Item08PC")
                          , Item15PC = c(NA, "Item15PC"), Item17PC = c(NA, "Item17PC")
                          , Item20PC = c(NA, "Item20PC"), Item23PC = c(NA, "Item23PC")
                          
                          , Item11PT = c(NA, "Item11PT"), Item14PT = c(NA, "Item14PT")
                          , Item16PT = c(NA, "Item16PT"), Item18PT = c(NA, "Item18PT"))
    , prefix =  "case01_intrinsic_motivation", min_columns = 14
    , fixed = NULL
    , url_str = NULL
    , itemequals = list(ItemIE=c('Item01IE', 'Item09IE', 'Item12IE', 'Item21IE', 'Item22IE', 'Item24IE')
                        , ItemPC=c('Item02PC','Item05PC', 'Item06PC', 'Item08PC', 'Item15PC', 'Item17PC', 'Item20PC', 'Item23PC')
                        , ItemPT=c('Item11PT', 'Item14PT', 'Item16PT', 'Item18PT'))
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


