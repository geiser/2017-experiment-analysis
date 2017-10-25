library(TAM)
library(readr)
library(readxl)
library(dplyr)
library(parallel)
#options(mc.cores=7)

datIMI <- read_csv("data/IMI.csv")

sources = list(
  "Intrinsic Motivation" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/intrinsic-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("IE","PC","PT","EI")
    , inv.keys = c("Item05PC", "Item20PC", "Item18PC", "Item13PC", "Item03PC"
                   , "Item02PT",  "Item06PT", "Item04PT", "Item01EI",  "Item19EI")
  )
  , "Interest/Enjoyment" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/interest-enjoyment/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("IE")
    , inv.keys = c()
  )
  , "Perceived Choice" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/perceived-choice/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PC")
    , inv.keys = c()
  )
  , "Pressure/Tension" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/pressure-tension/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("PT")
    , inv.keys = c("Item23PT")
  )
  , "Effort/Importance" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/effort-importance/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("EI")
    , inv.keys = c("Item01EI", "Item19EI")
  )
  , "Level of Motivation" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/level-of-motivation/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A", "S")
    , inv.keys = c("Item21S")
  )
  , "Attention" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/attention/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("A")
    , inv.keys = c()
  )
  , "Satisfaction" = list(
    sheed = "data", wid = "UserID"
    , filename = "report/motivation/satisfaction/AnovaAnalysis.xlsx"
    , start.with = c("Item"), end.withs = c("S")
    , inv.keys = c("Item21S")
  )
)

x <- list_vars$`Intrinsic Motivation`

generated_tam_mods <- mclapply(sources, FUN = function(x, irtmodel) {
  cat('\n... ', x$filename, ' ... \n')
  dat <- read_excel(x$filename, sheet = x$sheed, col_types = "numeric")
  rdat <- dat[x$wid]
  for (endwith in x$end.withs) {
    rdat <- merge(
      rdat
      , dplyr::select(dat, starts_with(x$wid), ends_with(endwith)))
  }
  for (inv_key in x$inv.keys) {
    rdat[inv_key] <- 8-rdat[inv_key]
  }
  mod <- tam.mml(dplyr::select(rdat, starts_with(x$start.with)), irtmodel=irtmodel)
  
  return(list(mod = mod, data = rdat))
}, irtmodel="RSM"
, mc.allow.recursive = FALSE
)

save(generated_tam_mods, file="generated_tam_mods.RData")

View(tam.fit(mod)$itemfit)

