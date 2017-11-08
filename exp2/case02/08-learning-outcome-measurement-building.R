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

#View(tam_info_mod$information)
#View(pre_tam_info_mod$information)

mod <- GPCM.measure_change(
  preData, posData
  , items.pre = c("Re1","Un3","Ap2a","Ap2b","An3a","An3b","Ev2")
  , items.pos = c("ReA","UnC","ApB1","ApB2","AnC1","AnC2","EvB")
  , same_items.pre = c("Ap2a","Ap2b","Ev2")
  , same_items.pos = c("ApB1","ApB2","EvB")
  , userid = "UserID", verify = T, plotting = T, remove_outlier = T, tam_models = NULL)

write_measure_change_report(
  mod, 'report/learning-outcome/', 'MeasurementChangeModel.xlsx', override = F
)

write_change_measurement_model_plots(
  mod, 'report/learning-outcome/measurement-change-model-plots/', override = T
)
