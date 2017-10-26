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
    , column_names = list(Item08IE = c(NA, "Item08IE"), Item09IE = c(NA, "Item09IE")
                          , Item11IE = c(NA, "Item11IE"), Item12IE = c(NA, "Item12IE")
                          , Item21IE = c(NA, "Item21IE"), Item24IE = c(NA, "Item24IE"))
    , prefix =  "case03_interest_enjoyment", min_columns = 4
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214730&authkey=ACNtHGzE3m8-6zk"
    , itemequals = NULL
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID", name = "Perceived Choice"
    , filename = "report/motivation/perceived-choice/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c()
    , column_names = list(Item03PC = c(NA, "Item03PC"), Item05PC = c(NA, "Item05PC")
                          , Item13PC = c(NA, "Item13PC"), Item18PC = c(NA, "Item18PC")
                          , Item20PC = c(NA, "Item20PC"))
    , prefix =  "case03_perceived_choice", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214734&authkey=APtFDd6NxB7aoNo"
    , itemequals = NULL
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID", name = "Pressure/Tension"
    , filename = "report/motivation/pressure-tension/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys = c("Item23PT")
    , column_names = list(Item02PT = c(NA, "Item02PT"), Item04PT = c(NA, "Item04PT")
                          , Item06PT = c(NA, "Item06PT"), Item23PT = c(NA, "Item23PT"))
    , prefix =  "case03_pressure_tension", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214736&authkey=ABZ1YPbVwbZPfno"
    , itemequals = NULL
  )
  , "Effort/Importance" = list(
    sheed = "data", wid = "UserID", name = "Effort/Importance"
    , filename = "report/motivation/effort-importance/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("EI")
    , inv.keys = c("Item01EI", "Item19EI")
    , column_names = list(Item01EI = c(NA, "Item01EI"), Item14EI = c(NA, "Item14EI")
                          , Item19EI = c(NA, "Item19EI"), Item22EI = c(NA, "Item22EI"))
    , prefix =  "case03_effort_importance", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214727&authkey=ANqLsKIjd44RKdM"
    , itemequals = NULL
  )
  , "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID", name = "Intrinsic Motivation"
    , filename = "report/motivation/intrinsic-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("IE","PC","PT","EI")
    , inv.keys = c("Item05PC", "Item20PC", "Item18PC", "Item13PC", "Item03PC"
                   , "Item02PT",  "Item06PT", "Item04PT", "Item01EI",  "Item19EI")
    , column_names = list(Item08IE = c(NA, "Item08IE"), Item09IE = c(NA, "Item09IE")
                          , Item11IE = c(NA, "Item11IE"), Item12IE = c(NA, "Item12IE")
                          , Item21IE = c(NA, "Item21IE"), Item24IE = c(NA, "Item24IE")
                          
                          , Item03PC = c(NA, "Item03PC"), Item05PC = c(NA, "Item05PC")
                          , Item13PC = c(NA, "Item13PC"), Item18PC = c(NA, "Item18PC")
                          , Item20PC = c(NA, "Item20PC")
                          
                          , Item02PT = c(NA, "Item02PT"), Item04PT = c(NA, "Item04PT")
                          , Item06PT = c(NA, "Item06PT"), Item23PT = c(NA, "Item23PT")
                          
                          , Item01EI = c(NA, "Item01EI"), Item14EI = c(NA, "Item14EI")
                          , Item19EI = c(NA, "Item19EI"), Item22EI = c(NA, "Item22EI"))
    , prefix =  "case03_intrinsic_motivation", min_columns = 16
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214739&authkey=AM34xYZHQV7K3DU"
    , itemequals = list(ItemIE=c('Item08IE', 'Item09IE', 'Item11IE', 'Item12IE', 'Item21IE', 'Item24IE')
                        , ItemPC=c('Item03PC','Item05PC', 'Item13PC', 'Item18PC', 'Item20PC')
                        , ItemPT=c('Item02PT', 'Item04PT', 'Item06PT', 'Item23PT')
                        , ItemEI=c('Item01EI', 'Item14EI', 'Item19EI', 'Item22EI'))
  )
  , "Attention" = list(
    sheed = "data", wid = "UserID", name = "Attention"
    , filename = "report/motivation/attention/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
    , column_names = list(Item18A = c(NA, "Item18A"), Item20A = c(NA, "Item20A")
                          , Item25A = c(NA, "Item25A"), Item07A = c(NA, "Item07A")
                          , Item13A = c(NA, "Item13A"))
    , prefix =  "case03_attention", min_columns = 3
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214725&authkey=AP57z7OeXAyjJAg"
    , itemequals = NULL
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID", name = "Satisfaction"
    , filename = "report/motivation/satisfaction/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c("Item21S")
    , column_names = list(Item01S = c(NA, "Item01S"), Item02S = c(NA, "Item02S")
                          , Item05S = c(NA, "Item05S"), Item21S = c(NA, "Item21S"))
    , prefix =  "case03_satisfaction", min_columns = 2
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214738&authkey=AHgozRlQl_KiCmE"
    , itemequals = NULL
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID", name = "Level of Motivation"
    , filename = "report/motivation/level-of-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A", "S")
    , inv.keys = c("Item21S")
    , column_names = list(Item18A = c(NA, "Item18A"), Item20A = c(NA, "Item20A")
                          , Item25A = c(NA, "Item25A"), Item07A = c(NA, "Item07A")
                          , Item13A = c(NA, "Item13A")
                          
                          , Item01S = c(NA, "Item01S"), Item02S = c(NA, "Item02S")
                          , Item05S = c(NA, "Item05S"), Item21S = c(NA, "Item21S"))
    , prefix =  "case03_level_of_motivation", min_columns = 7
    , fixed = NULL
    , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214732&authkey=ALNcF69gQAxS2rc"
    , itemequals = list(ItemA=c('Item18A', 'Item20A', 'Item25A', 'Item07A', 'Item13A')
                        , ItemS=c('Item01S','Item02S', 'Item05S', 'Item21S'))
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

tam_mod <- load_tam_mod(
  "Item08IE+Item09IE+Item12IE+Item21IE+Item24IE"
  , url_str = sources$`Interest/Enjoyment`$url_str
  , prefix =  "case03_interest_enjoyment")

View(tam_info_models_map$`Intrinsic Motivation`$information)


View(tam_info_models_map$`Interest/Enjoyment`$information)
