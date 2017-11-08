library(TAM)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

preData <- read_csv("data/SourcePreTest.csv")
posData <- read_csv("data/SourcePosTest.csv")

## get pre and post tams

sdat <- get_stacking_data(
  preData, posData, wid = "UserID",
  items.pre = c("Re2","Un2","Ap1","Ap3","An3a","An3b","Ev2"),
  items.pos = c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB"),
  same.items = list(pre=c("Re2","An3a","An3b","Ev2"),
                    pos=c("ReB","AnC1","AnC2","EvB")))

tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  sdat$resp
  , column_names = list(Re2ReB=c(NA,"Re2ReB"),
                        Un2=c(NA,"Un2"), UnB=c(NA,"UnB"),
                        Ap1=c(NA,"Ap1"), ApA=c(NA,"ApA"),
                        Ap3=c(NA,"Ap3"), ApC=c(NA,"ApC")
                        , An3aAnC1=c(NA,"An3aAnC1")
                        , An3bAnC2=c(NA,"An3bAnC2")
                        , Ev2EvB=c(NA,"Ev2EvB")
                        )
  #, url_str = x$url_str
  , itemequals = list(Re=c("Re2ReB"), Un=c("Un2","UnB"), Ap=c("Ap1","ApA","Ap3","ApC")
                      , An=c("An3aAnC1", "An3bAnC2"), Ev=c("Ev2EvB"))
  , prefix = "case03_prepos"
  , fixed = NULL #c("Re2ReB","An3aAnC1","An3bAnC2","Ev2EvB")
  , fixed_sets = list(s1=c("Un2","UnB"), s2=c("Ap1","ApA"), s3=c("Ap3","ApC"))
  , min_columns = 4, irtmodel = "2PL")
View(tam_info_mod$information)

pre_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  preData[c("Re2","Un2","Ap1","Ap3","An3a","An3b","Ev2")]
  , column_names = list(Re2=c(NA,"Re2"), Un2=c(NA,"Un2")
                        , Ap1=c(NA,"Ap1"), Ap3=c(NA,"Ap3")
                        , An3a=c(NA,"An3a"), An3b=c(NA,"An3b")
                        , Ev2=c(NA,"Ev2"))
  #, url_str = url_str
  , itemequals = list(Re=c("Re2"), Un=c("Un2"), Ap=c("Ap1","Ap3")
                      , An=c("An3a", "An3b"), Ev=c("Ev2"))
  , prefix = "case03_pre"
  , fixed = NULL #c("Re2ReB","An3aAnC1","An3bAnC2","Ev2EvB")
  , min_columns = 4, irtmodel = "2PL")
View(pre_tam_info_mod$information)

pos_tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  posData[c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB")]
  , column_names = list(ReB=c(NA,"ReB"), UnB=c(NA,"UnB")
                        , ApA=c(NA,"ApA"), ApC=c(NA,"ApC")
                        , AnC1=c(NA,"AnC1"), AnC2=c(NA,"AnC2")
                        , EvB=c(NA,"EvB")
  )
  #, url_str = x$url_str
  , itemequals = list(Re=c("ReB"), Un=c("UnB"), Ap=c("ApA","ApC")
                      , An=c("AnC1", "AnC2"), Ev=c("EvB"))
  , prefix = "case03_pos"
  , fixed = NULL #c("Re2ReB","An3aAnC1","An3bAnC2","Ev2EvB")
  , min_columns = 4, irtmodel = "2PL")
View(pos_tam_info_mod$information)


#View(tam_info_mod$information)
#View(pre_tam_info_mod$information)

mod <- TAM.measure_change(
    preData, posData
    , items.pre = c("Re2","Un2","Ap1","Ap3","An3a","An3b","Ev2")
    , items.pos = c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB")
    , same_items.pre = c("Re2","An3a","An3b","Ev2")
    , same_items.pos = c("ReB","AnC1","AnC2","EvB")
    , userid = "UserID", verify = T, plotting = F, remove_outlier = T, irtmodel = "2PL")

write_measure_change_report(
  mod, 'report/learning-outcome/', 'MeasurementChangeModel.xlsx', override = T
)

write_change_measurement_model_plots(
  mod, 'report/learning-outcome/measurement-change-model-plots/', override = T
)
plot(mod$info.stacking$pre_mod)
