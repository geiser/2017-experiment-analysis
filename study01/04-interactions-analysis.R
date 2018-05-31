## TODO
library(readr)
library(dplyr)

sources <- list(
  "Total of Interactions" = list(
    name = "Total of Interactions", dv = "NroTotalInteractions"
    , extra_rmids = c()
    , filename = "data/CLActivity.csv", rm.outliers = TRUE
    , folder = "total", only.one = FALSE
    , between = c('Type', 'CLRole')
  )
  , "Necessary Interactions" = list(
    name = "Necessary Interactions", dv = "NroNecessaryInteractions"
    , extra_rmids = c()
    , filename = "data/CLActivity.csv", rm.outliers = TRUE
    , folder = "necessary", only.one = FALSE
    , between = c('Type', 'CLRole')
  )
  , "Desired Interactions" = list(
    name = "Desired Interactions", dv = "NroDesiredInteractions"
    , extra_rmids = c()
    , filename = "data/CLActivity.csv", rm.outliers = FALSE
    , folder = "desired", only.one = TRUE
    , between = c('Type', 'CLRole')
  )
)

#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################

lapply(sources, FUN = function(x) {
  dat <-as.data.frame(read_csv(x$filename))
  set_wt_mods <- get_wilcox_mods(dat, dv = x$dv, iv = 'Type', between = c('Type', 'CLRole'))
  write_wilcoxon_simple_analysis_report(
    set_wt_mods
    , ylab = "nro"
    , title = paste0(x$name, " - Cond. Structures")
    , filename = paste0("report/interactions/", x$folder,"/WilcoxAnalysis.xlsx")
    , override = TRUE
    , data = dat
  )
  write_wilcoxon_plots(
    set_wt_mods
    , ylab = "nro"
    , title = paste0(x$name, " - Cond. Structures")
    , path = paste0("report/interactions/", x$folder,"/wilcox-analysis-plots/")
    , override = TRUE
  )
})

