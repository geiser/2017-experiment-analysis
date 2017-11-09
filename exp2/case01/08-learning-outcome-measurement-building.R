library(TAM)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

preData <- read_csv("data/SourcePreTest.csv")
posData <- read_csv("data/SourcePosTest.csv")

sdat <- get_stacking_data(
  preData, posData, wid = "UserID",
  items.pre = c("Re1","Re2","Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2"),
  items.pos = c("ReA","ReB","UnA","UnB","ApA","ApB","ApC","AnC","EvA","EvB"),
  same.items = list(pre=c("Re1","Re2","Un1","Ap1","Ap3"),
                    pos=c("ReA","ReB","UnA","ApA","ApC")))

## get pre and post tams

pre_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  preData[c("Re1","Re2","Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2")]
  , column_names = list(Re1=c(NA,"Re1"), Re2=c(NA,"Re2")
                        , Un1=c(NA,"Un1"), Un2=c(NA,"Un2")
                        , Ap1=c(NA,"Ap1"), Ap2=c(NA,"Ap2"), Ap3=c(NA,"Ap3")
                        , An3=c(NA,"An3")
                        , Ev1=c(NA,"Ev1"), Ev2=c(NA,"Ev2"))
  #, url_str = url_str
  , itemequals = list(Re=c("Re1","Re2"), Un=c("Un1","Un2")
                      , Ap=c("Ap1","Ap2","Ap3"), An=c("An3")
                      , Ev=c("Ev1","Ev2"))
  , prefix = "case01_pre"
  , fixed = NULL
  , min_columns = 8, irtmodel = "2PL")
View(pre_tam_info_mod$information)

pos_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  posData[c("ReA","ReB","UnA","UnB","ApA","ApB","ApC","AnC","EvA","EvB")]
  , column_names = list(ReA=c(NA,"ReA"), ReB=c(NA,"ReB")
                        , UnA=c(NA,"UnA"), UnB=c(NA,"UnB")
                        , ApA=c(NA,"ApA"), ApB=c(NA,"ApB"), ApC=c(NA,"ApC")
                        , AnC=c(NA,"AnC")
                        , EvA=c(NA,"EvA"), EvB=c(NA,"EvB"))
  #, url_str = x$url_str
  , itemequals = list(Re=c("ReA","ReB"), Un=c("UnA","UnB")
                      , Ap=c("ApA","ApB","ApC"), An=c("AnC")
                      , Ev=c("EvA","EvB"))
  , prefix = "case01_pos"
  , fixed = NULL
  , min_columns = 8, irtmodel = "2PL")
View(pos_tam_info_mod$information)

#View(tam_info_mod$information)
#View(pre_tam_info_mod$information)

if (file.exists('case01_prepos_mod.RData')) {
  mod <- get(load('case01_prepos_mod.RData'))
} else {
  mod <- TAM.measure_change(
    preData, posData
    , items.pre = c("Re1","Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1")
    , items.pos = c("ReB","UnA","UnB","ApA","ApB","ApC","AnC","EvA")
    , same_items.pre = c("Un1","Ap1","Ap3")
    , same_items.pos = c("UnA","ApA","ApC")
    , userid = "UserID", verify = T, plotting = F, remove_outlier = T, irtmodel = "2PL")
  save(mod, file = 'case01_prepos_mod.RData')
}

write_measure_change_report(
  mod, 'report/learning-outcome/', 'MeasurementChangeModel.xlsx', override = T
)

write_change_measurement_model_plots(
  mod, 'report/learning-outcome/measurement-change-model-plots/', override = T
)
