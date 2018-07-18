library(TAM)
library(sirt)
library(plyr)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

participants <- read_csv('data/SignedUpParticipants.csv')
pre_dat <- merge(read_csv('data/PreAMC.csv')
                 , read_csv('data/PreGuttmanVPL.csv'), by = 'UserID', all.x = T)
pos_dat <- merge(read_csv('data/PosAMC.csv')
                 , read_csv('data/PosGuttmanVPL.csv'), by = 'UserID', all.x = T)

##################################################################
## Testing Guttman Scoring Rules                                ##
##################################################################

pre_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  pre_dat
  , column_names = list(Re1=c(NA,"Re1"), Re2=c(NA,"Re2"), Un1=c("Un1"), Un2=c("Un2")
                       , Ap1=c("Ap1"), Ap2=c("Ap2"), Ap3=c("Ap3")
                       , An3=c("An3")
                       , Ev1=c(NA,"Ev1"), Ev2=c("Ev2")
                       , P1=c(NA,"P1s0","P1s1","P1s2","P1s3")
                       )
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "first_study_pre"
  , min_columns = 7, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pre_info <- pre_tam_info_models$information
t(pre_info[pre_info$model_fit
           & pre_info$everything.fits
           & pre_info$unidim_lav_test
           & pre_info$lav_CFI > 0.9
           ,])
pre_mdl_strs <- list()
pre_mdl_strs[[1]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2","P1s2")
pre_mdl_strs[[2]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2","P1s3")
pre_mdl_strs[[3]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev2","P1s3")
pre_mdl_strs[[4]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev2","P1s2")
pre_mdl_strs[[5]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev2","P1s1")
pre_mdl_strs[[6]] <- c("Un1","Un2","Ap1","Ap2","Ap3","An3","Ev1","Ev2")
pre_mdl_strs[[7]] <- c("Re1","Un1","Un2","Ap1","Ap2","Ap3","An3","Ev2")

##
pos_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  pos_dat
  , column_names = list(ReA=c("ReA"), ReB=c("ReB"), UnA=c(NA,"UnA"), UnB=c(NA,"UnB")
                       , ApA=c(NA,"ApA"), ApB=c(NA,"ApB"), ApC=c("ApC")
                       , AnC=c("AnC")
                       , EvA=c(NA,"EvA"), EvB=c(NA,"EvB")
                       , PA=c(NA,"PAs0","PAs1","PAs2","PAs3")
                       , PB=c(NA,"PBs0","PBs1","PBs2","PBs3")
                       )
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "first_study_pos"
  , min_columns = 6, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pos_info <- pos_tam_info_models$information
t(pos_info[pos_info$model_fit
           & pos_info$everything.fits
           & pos_info$unidim_lav_test
           & pos_info$lav_CFI > 0.9
           ,])
pos_mdl_strs <- list()
pos_mdl_strs[[1]] <- c("ReB","UnB","ApA","ApB","ApC","EvB","PAs3")
pos_mdl_strs[[2]] <- c("ReB","UnB","ApB","ApC","AnC","EvA","PAs3")
pos_mdl_strs[[3]] <- c("UnA","UnB","ApB","ApC","AnC","EvA","PAs1")
pos_mdl_strs[[4]] <- c("ReB","UnA","UnB","ApA","ApB","ApC","PAs1")
pos_mdl_strs[[5]] <- c("UnA","UnB","ApB","ApC","AnC","EvA","PAs3")
pos_mdl_strs[[6]] <- c("ReA","UnA","ApB","ApC","EvA","EvB","PAs1")

##################################################################
## Checking Assumptions in each model                           ##
##################################################################

pre_dat <- merge(read_csv('data/PreAMC.csv')
                 , read_csv('data/PreGuttmanVPL.csv'), by = 'UserID', all.x = T)
pos_dat <- merge(read_csv('data/PosAMC.csv')
                 , read_csv('data/PosGuttmanVPL.csv'), by = 'UserID', all.x = T)

verify_mod <- TAM.measure_change.verify(
  pre_dat, pos_dat
  , items.pre = pre_mdl_strs[[1]]
  , items.pos = pos_mdl_strs[[2]]
  , userid = "UserID", irtmodel = "GPCM"
  , plotting = T, pairing = T
  , folder = "report/learning-outcomes/measurement-change-model-plots/"
)

# print problematic items
(problematic_items <- do.call(
  rbind,lapply(list(pre.mod = verify_mod$pre_mod
                    , pos.mod= verify_mod$pos_mod), FUN = function(mod) {
  item_fit <- tam.fit(mod, progress = F)$itemfit
  return(item_fit[(item_fit$Outfit > 2 | item_fit$Infit > 2),])
})))

## latex translated
tam_mods <- list("Pre-test" = verify_mod$pre_mod, "Post-test" = verify_mod$pos_mod)
gpcm_summaries <- get_gpcm_summaries_as_dataframe(tam_mods, estimator = "MLR")
filename <- "report/latex/gpcm-learning-outcomes.tex"
if (!file.exists(filename)) {
  write_gpcm_in_latex(
    gpcm_summaries
    , in_title = "for measuring gains in the skills and knowledge of participants in the first empirical study"
    , filename = filename
  )
}

##################################################################
## Stacking and Racking                                         ##
##################################################################

mod <- TAM.measure_change(
  pre_dat, pos_dat
  , items.pre = pre_mdl_strs[[1]]
  , items.pos = pos_mdl_strs[[2]]
  , same_items.pre = c("Ap3")
  , same_items.pos = c("ApC")
  , userid = "UserID"
  , verify = T, plotting = T, irtmodel = "GPCM")

write_change_measurement_model_plots(
  mod, path = 'report/learning-outcomes/measurement-change-model-plots/', override = T
)

write_measure_change_report(
  mod, path = 'report/learning-outcomes/'
  , filename = 'MeasurementChangeModel.xlsx', override = T
)

write_csv(dplyr::mutate(mod$ability, gain.theta = pos.theta-pre.theta), 'data/GainSkillsKnowledge.csv')
