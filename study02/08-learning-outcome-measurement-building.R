library(TAM)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

preData <- read_csv("data/SourcePreTest.csv")
posData <- read_csv("data/SourcePosTest.csv")

sdat <- get_stacking_data(
  preData, posData, wid = "UserID",
  items.pre = c("Re1","Un3","Ap2a","Ap2b","An3a","An3b","Ev2"),
  items.pos = c("ReA","UnC","ApB1","ApB2","AnC1","AnC2","EvB"),
  same.items = list(pre=c("Ap2a","Ap2b","Ev2"),
                    pos=c("ApB1","ApB2","EvB")))

## get pre and post tams

pre_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  preData[c("Re1","Un3","Ap2a","Ap2b","An3a","An3b","Ev2")]
  , column_names = list(Re1=c(NA,"Re1"), Un3=c(NA,"Un3")
                        , Ap2a=c(NA,"Ap2a"), Ap2b=c(NA,"Ap2b")
                        , An3a=c(NA,"An3a"), An3b=c(NA,"An3b")
                        , Ev2=c(NA,"Ev2"))
  #, url_str = url_str
  , itemequals = list(Re=c("Re1"), Un=c("Un3"), Ap=c("Ap2a","Ap2b")
                      , An=c("An3a", "An3b"), Ev=c("Ev2"))
  , prefix = "case02_pre"
  , fixed = NULL
  , min_columns = 4, irtmodel = "2PL")
View(pre_tam_info_mod$information)

pos_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  posData[c("ReA","UnC","ApB1","ApB2","AnC1","AnC2","EvB")]
  , column_names = list(ReA=c(NA,"ReA"), UnC=c(NA,"UnC")
                        , ApB1=c(NA,"ApB1"), ApB2=c(NA,"ApB2")
                        , AnC1=c(NA,"AnC1"), AnC2=c(NA,"AnC2")
                        , EvB=c(NA,"EvB"))
  #, url_str = x$url_str
  , itemequals = list(Re=c("ReA"), Un=c("UnC"), Ap=c("ApB1","ApB2")
                      , An=c("AnC1", "AnC2"), Ev=c("EvB"))
  , prefix = "case02_pos"
  , fixed = NULL
  , min_columns = 4, irtmodel = "2PL")
View(pos_tam_info_mod$information)

#View(tam_info_mod$information)
#View(pre_tam_info_mod$information)

if (file.exists('case02_prepos_mod.RData')) {
  mod <- get(load('case02_prepos_mod.RData'))
} else {
  mod <- TAM.measure_change(
    preData, posData
    , items.pre = c("Un3","Ap2a","Ap2b","An3a","An3b")
    , items.pos = c("UnC","ApB1","ApB2","AnC1","AnC2")
    , same_items.pre = c("Ap2a","Ap2b")
    , same_items.pos = c("ApB1","ApB2")
    , userid = "UserID", verify = T, plotting = F, remove_outlier = T, irtmodel = "2PL")
  save(mod, file = 'case02_prepos_mod.RData')
}

write_measure_change_report(
  mod, 'report/learning-outcome/', 'MeasurementChangeModel.xlsx', override = T
)

write_change_measurement_model_plots(
  mod, 'report/learning-outcome/measurement-change-model-plots/', override = T
)
