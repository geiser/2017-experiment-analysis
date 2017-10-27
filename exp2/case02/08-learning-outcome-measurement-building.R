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

tam_info_mod <- load_and_save_TAMs_to_measure_skill(
  sdat$resp
  , column_names = list(Re1=c(NA,"Re1"), ReA=c(NA,"ReA")
                        , Un3=c(NA,"Un3"), UnC=c(NA,"UnC")
                        , An3a=c(NA,"An3a"), An3b=c(NA,"An3b"), AnC1=c(NA,"AnC1"), AnC2=c(NA,"AnC2")
                        , Ap2aApB1=c(NA,"Ap2aApB1"), Ap2bApB2=c(NA,"Ap2bApB2")
                        , Ev2EvB=c(NA,"Ev2EvB"))
  #, url_str = x$url_str
  , itemequals = list(Re=c("Re1","ReA"), Un=c("Un3","UnC"), Ap=c("Ap2aApB1","Ap2bApB2")
                      , An=c("An3a","An3b","AnC1","AnC2"), Ev=c("Ev2EvB"))
  , prefix = "case02_pre_post"
  , min_columns = 8, fixed = NULL, irtmodel = "GPCM")

#View(tam_info_mod$information)
