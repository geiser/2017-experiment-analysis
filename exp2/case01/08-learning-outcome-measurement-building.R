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

tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  sdat$resp
  , column_names = list(Re1ReA=c(NA,"Re1ReA")
                        , Re2ReB=c(NA,"Re2ReB")
                        , Un1UnA=c(NA,"Un1UnA")
                        , Un2=c(NA,"Un2"), UnB=c(NA,"UnB")
                        , Ap1ApA=c(NA,"Ap1ApA")
                        , Ap2=c(NA,"Ap2"), ApB=c(NA,"ApB")
                        , Ap3ApC=c(NA,"Ap3ApC")
                        , An3=c(NA,"An3"), AnC=c(NA,"AnC")
                        , Ev1=c(NA,"Ev1"), EvA=c(NA,"EvA")
                        , Ev2=c(NA,"Ev2"), EvB=c(NA,"EvB"))
  #, url_str = x$url_str
  , itemequals = list(Re=c("Re1ReA","Re2ReB"), Un=c("Un1UnA","Un2","UnB")
                      , Ap=c("Ap1ApA","Ap2","ApB","Ap3ApC")
                      , An=c("An3","AnC"), Ev=c("Ev1","EvA","Ev2","EvB"))
  , prefix = "case01_pre_post"
  , min_columns = 7, fixed = NULL, irtmodel = "GPCM")

#View(tam_info_mod$information)
