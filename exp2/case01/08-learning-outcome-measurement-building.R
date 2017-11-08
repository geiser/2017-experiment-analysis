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

#View(tam_info_mod$information)
#View(pre_tam_info_mod$information)

mod <- GPCM.measure_change(
  preData, posData
  , items.pre = c("Re1","Re2","Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2")
  , items.pos = c("ReA","ReB","UnA","UnB","ApA","ApB","ApC","AnC","EvA","EvB")
  , same_items.pre = c("Re1","Re2","Un1","Ap1","Ap3")
  , same_items.pos = c("ReA","ReB","UnA","ApA","ApC")
  , userid = "UserID", verify = T, plotting = T, remove_outlier = T, tam_models = NULL)

write_measure_change_report(
  mod, 'report/learning-outcome/', 'MeasurementChangeModel.xlsx', override = T
)

write_change_measurement_model_plots(
  mod, 'report/learning-outcome/measurement-change-model-plots/', override = T
)
