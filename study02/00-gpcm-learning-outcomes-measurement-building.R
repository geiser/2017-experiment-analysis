library(TAM)
library(sirt)
library(plyr)
library(readr)
library(readxl)
library(parallel)
options(mc.cores=7)

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
  , column_names = list(#Re1=c("Re1"), 
                        Un3=c(NA,"Un3")
                       , Ap2a=c(NA,"Ap2a"), Ap2b=c(NA,"Ap2b")
                       , An3a=c(NA,"An3a"), An3b=c(NA,"An3b")
                       , Ev2=c(NA,"Ev2")
                       , P2=c(NA,"P2s0","P2s1","P2s2","P2s3")
                       , P3=c(NA,"P3s0","P3s1","P3s2","P3s3")
                       )
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "second_study_pre"
  , min_columns = 5, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pre_info <- pre_tam_info_models$information
t(pre_info[pre_info$model_fit
           & pre_info$everything.fits
           & pre_info$unidim_lav_test
           & pre_info$lav_CFI > 0.9
           ,])
pre_mdl_strs <- list()
pre_mdl_strs[[1]] <- c("Un3","Ap2a","Ap2b","An3a","An3b","P2s3")
pre_mdl_strs[[2]] <- c("Un3","Ap2a","Ap2b","An3a","An3b","P2s2")
pre_mdl_strs[[3]] <- c("Un3","Ap2a","Ap2b","An3b","P2s2","P3s1")
pre_mdl_strs[[4]] <- c("Un3","Ap2a","Ap2b","An3b","P2s2","P3s3")
pre_mdl_strs[[5]] <- c("Un3","Ap2a","Ap2b","An3b","P2s2","P3s2")

##
pos_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  pos_dat
  , column_names = list(#ReA=c(NA,"ReA"),
                        UnC=c(NA,"UnC")
                       , ApB1=c("ApB1"), ApB2=c("ApB2")
                       , AnC1=c(NA,"AnC1"), AnC2=c(NA,"AnC2")
                       , EvB=c(NA,"EvB")
                       , PC=c(NA,"PCs0","PCs1","PCs2","PCs3")
                       , PD=c(NA,"PDs0","PDs1","PDs2","PDs3")
                       , PE=c(NA,"PEs0","PEs1","PEs2","PEs3")
                       )
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "second_study_pos"
  , min_columns = 4, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pos_info <- pos_tam_info_models$information
t(pos_info[pos_info$model_fit
           & pos_info$everything.fits
           & pos_info$unidim_lav_test
           & pos_info$lav_CFI > 0.9
           ,])
pos_mdl_strs <- list()
pos_mdl_strs[[1]] <- c("ApB1","ApB2","AnC2","EvB","PCs2","PDs1")
pos_mdl_strs[[2]] <- c("UnC","ApB1","ApB2","AnC2","PCs3","PDs1")
pos_mdl_strs[[3]] <- c("ApB1","ApB2","AnC2","EvB","PCs3","PDs2")
pos_mdl_strs[[4]] <- c("ApB1","ApB2","AnC2","EvB","PCs1","PDs3")
pos_mdl_strs[[5]] <- c("UnC","ApB1","ApB2","AnC2","PCs2","PDs1")
pos_mdl_strs[[6]] <- c("UnC","ApB1","ApB2","AnC1","AnC2")
pos_mdl_strs[[7]] <- c("ApB1","ApB2","AnC2","EvB","PDs2")


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
  , items.pos = pos_mdl_strs[[1]]
  , userid = "UserID", irtmodel = "GPCM"
  , plotting = T, pairing = T
  , folder = "report/learning-outcomes/measure-change-model-plots/"
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
    , in_title = "for measuring gains in the skills and knowledge of participants in the second empirical study"
    , filename = filename
  )
}

##################################################################
## Stacking and Racking                                         ##
##################################################################

mod <- TAM.measure_change(
  pre_dat, pos_dat
  , items.pre = pre_mdl_strs[[1]]
  , items.pos = pos_mdl_strs[[1]]
  , same_items.pre = c("Ap2a","ApB1")
  , same_items.pos = c("Ap2b","ApB2")
  , userid = "UserID"
  , verify = T, plotting = T, irtmodel = "GPCM")

write_change_measurement_model_plots(
  mod, path = 'report/learning-outcomes/measure-change-model-plots/', override = T
)

write_measure_change_report(
  mod, path = 'report/learning-outcomes/'
  , filename = 'MeasurementChangeModel.xlsx', override = T
)

#write_csv(dplyr::mutate(mod$ability, gain.theta = pos.theta-pre.theta), 'data/GainSkillsKnowledge.csv')

