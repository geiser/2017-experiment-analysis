library(TAM)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

preData <- read_csv("data/SourcePreTest.csv")
posData <- read_csv("data/SourcePosTest.csv")

sdat <- get_stacking_data(
  preData, posData, wid = "UserID",
  items.pre = c("Re2","Un2","Ap1","Ap3","An3a","An3b","Ev2"),
  items.pos = c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB"),
  same.items = list(pre=c("Re2","An3a","An3b","Ev2"),
                    pos=c("ReB","AnC1","AnC2","EvB")))

tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  sdat$resp
  , column_names = list(Re2ReB=c(NA,"Re2ReB")
                        , Un2=c(NA,"Un2"), UnB=c(NA,"UnB")
                        , Ap1=c(NA,"Ap1"), ApA=c(NA,"ApA")
                        , Ap3=c(NA,"Ap3"), ApC=c(NA,"ApC")
                        , An3aAnC1=c(NA,"An3aAnC1"), An3bAnC2=c(NA,"An3bAnC2")
                        , Ev2EvB=c(NA,"Ev2EvB"))
  #, url_str = x$url_str
  , itemequals = list(Re=c("Re2ReB"), Un=c("Un2","UnB"), Ap=c("Ap1","ApA","Ap3","ApC")
                      , An=c("An3aAnC1", "An3bAnC2"), Ev=c("Ev2EvB"))
  , prefix = "case03_pre_post"
  , min_columns = 7, fixed = NULL, irtmodel = "GPCM")

#View(tam_info_mod$information)
