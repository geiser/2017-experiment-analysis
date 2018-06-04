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
  , column_names = list(Re2=c(NA,"Re2"), Un2=c(NA,"Un2")
                       , Ap1=c(NA,"Ap1"), Ap3=c(NA,"Ap3")
                       , An3a=c(NA,"An3a"), An3b=c(NA,"An3b")
                       , Ev2=c(NA,"Ev2")
                       , P4=c(NA,"P4s0","P4s1","P4s2","P4s3"))
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "third_study_pre"
  , min_columns = 6, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pre_info <- pre_tam_info_models$information
#t(pre_info[pre_info$model_fit
#           & pre_info$everything.fits
#           & pre_info$unidim_lav_test
#           ,])
#pre_mdl_strs <- c("Re2+Un2+Ap1+Ap3+An3a+An3b+Ev2"
#                  , "Re2+Un2+Ap3+An3a+An3b+Ev2", "Un2+Ap1+Ap3+An3a+An3b+Ev2")

##
pos_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  pos_dat
  , column_names = list(ReB=c(NA,"ReB"), UnB=c(NA,"UnB")
                       , ApA=c(NA,"ApA"), ApC=c(NA,"ApC")
                       , AnC1=c(NA,"AnC1"), AnC2=c(NA,"AnC2")
                       , EvB=c(NA,"EvB")
                       , PF=c(NA,"PFs0","PFs1","PFs2","PFs3")
                       , PG=c(NA,"PGs0","PGs1","PGs2","PGs3")
                       , PH=c(NA,"PHs0","PHs1","PHs2","PHs3"))
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "third_study_pos"
  , min_columns = 6, fixed = NULL #c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB")
  , estimator = "MLR"
  , irtmodel = "GPCM")
pos_info <- pos_tam_info_models$information
#t(pos_info[pos_info$model_fit
#           & pos_info$everything.fits
#           & pos_info$unidim_test
#           & pos_info$rel_fit
#           & pos_info$numcols >= 4
#           ,])
#pos_mdl_strs <- c("Re2+Un2+Ap1+Ap3+An3a+An3b+Ev2"
#                  , "Re2+Un2+Ap3+An3a+An3b+Ev2", "Un2+Ap1+Ap3+An3a+An3b+Ev2")

##################################################################
## Checking Assumptions in each model                           ##
##################################################################

#pre_dat <- read_csv("data/PreGuttmanVPL.csv")[,c("UserID","P1s0","P2s0","P3s2","P4s0")]
#pos_dat <- read_csv("data/PosGuttmanVPL.csv")[,c("UserID","PAs0","PBs0","PCs0","PDs2")]

#verify_mod <- TAM.measure_change.verify(
#  pre_dat, pos_dat
#  , items.pre = c("P1s0","P2s0","P3s2","P4s0")
#  , items.pos = c("PAs0","PBs0","PCs0","PDs2")
#  , userid = "UserID", irtmodel = "GPCM"
#  , plotting = T, pairing = T
#  , folder = "report/learning-outcome/measure-change-model-plots/"
#)

# print problematic items
#(problematic_items <- do.call(
#  rbind,lapply(list(pre.mod = verify_mod$pre_mod
#                    , pos.mod= verify_mod$pos_mod), FUN = function(mod) {
#  item_fit <- tam.fit(mod, progress = F)$itemfit
#  return(item_fit[(item_fit$Outfit > 2 | item_fit$Infit > 2),])
#})))

## latex translated
#tam_mods <- list("Pre-test" = verify_mod$pre_mod, "Post-test" = verify_mod$pos_mod)
#gpcm_summaries <- get_gpcm_summaries_as_dataframe(tam_mods, estimator = "MLR")
#filename <- "report/latex/gpcm-learning-outcomes.tex"
#if (!file.exists(filename)) {
#  write_gpcm_in_latex(
#    gpcm_summaries
#    , in_title = "for measuring gains in the skills and knowledge of participants in the pilot empirical study"
#    , filename = filename
#  )
#}

##################################################################
## Stacking and Racking                                         ##
##################################################################

#mod <- TAM.measure_change(
#  pre_dat, pos_dat
#  , items.pre = c("P1s0","P2s0","P3s2","P4s0")
#  , items.pos = c("PAs0","PBs0","PCs0","PDs2")
#  , same_items.pre = c("P1s0","P2s0")
#  , same_items.pos = c("PAs0","PBs0")
#  , userid = "UserID"
#  , verify = T, plotting = T, irtmodel = "GPCM")

#write_change_measurement_model_plots(
#  mod, path = 'report/learning-outcome/measure-change-model-plots/', override = T
#)

#write_measure_change_report(
#  mod, path = 'report/learning-outcome/'
#  , filename = 'MeasurementChangeModel.xlsx', override = T
#)

#write_csv(dplyr::mutate(mod$ability, gain.theta = pos.theta-pre.theta), 'data/GainSkillsKnowledge.csv')

