library(TAM)
library(sirt)
library(plyr)
library(readr)
library(readxl)
library(parallel)
#options(mc.cores=7)

source('../common/misc.R')
source('../common/measurement-building.R')
source('../common/latex-translator.R')


##################################################################
## Testing Guttman Scoring Rules                                ##
##################################################################

##
pre_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  read_csv("data/PreGuttmanVPL.csv")
  , column_names =list(P1 = c(NA,"P1s0","P1s1","P1s2","P1s3")
                       , P2 = c(NA,"P2s0","P2s1","P2s2","P2s3")
                       , P3 = c(NA,"P3s0","P3s1","P3s2","P3s3")
                       , P4 = c(NA,"P4s0","P4s1","P4s2","P4s3"))
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "pilot_study_pre"
  , min_columns = 3, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pre_info <- pre_tam_info_models$information
t(pre_info[pre_info$model_fit
           & pre_info$everything.fits
           & pre_info$unidim_lav_test
           & pre_info$lav_CFI > 0.9
           ,])
pre_mdl_strs <- list()
pre_mdl_strs[[1]] <- c("P1s0","P2s0","P3s2","P4s0")
pre_mdl_strs[[2]] <- c("P1s0","P2s0","P3s3","P4s0")
pre_mdl_strs[[3]] <- c("P1s0","P2s1","P3s3","P4s0")
pre_mdl_strs[[4]] <- c("P1s0","P2s0","P3s2","P4s2")
pre_mdl_strs[[5]] <- c("P1s0","P2s0","P3s3","P4s2")

##
pos_tam_info_models <- load_and_save_TAMs_to_measure_skill(
  read_csv("data/PosGuttmanVPL.csv")
  , column_names =list(PA = c(NA,"PAs0","PAs1","PAs2","PAs3")
                       , PB = c(NA,"PBs0","PBs1","PBs2","PBs3")
                       , PC = c(NA,"PCs0","PCs1","PCs2","PCs3")
                       , PD = c(NA,"PDs0","PDs1","PDs2","PDs3"))
  , url_str = NULL
  , itemclusters = NULL
  , prefix = "pilot_study_pos"
  , min_columns = 3, fixed = NULL
  , estimator = "MLR"
  , irtmodel = "GPCM")
pos_info <- pos_tam_info_models$information
t(pos_info[pos_info$model_fit
           & pos_info$everything.fits
           & pos_info$unidim_lav_test
           & pos_info$lav_CFI > 0.9
           ,])
pos_mdl_strs <- list()
pos_mdl_strs[[1]] <- c("PAs2","PBs3","PCs0","PDs0")
pos_mdl_strs[[2]] <- c("PAs2","PBs2","PCs0","PDs0")
pos_mdl_strs[[3]] <- c("PAs3","PBs2","PCs0","PDs0")
pos_mdl_strs[[4]] <- c("PAs3","PBs3","PCs0","PDs2")

##################################################################
## Checking Assumptions in each model                           ##
##################################################################

pre_dat <- read_csv("data/PreGuttmanVPL.csv")
pos_dat <- read_csv("data/PosGuttmanVPL.csv")

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
    , in_title = "for measuring gains in the skill/knowledge of participants in the pilot empirical study"
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
  , same_items.pre = c("P3s2","P4s0")
  , same_items.pos = c("PAs2","PCs0")
  , userid = "UserID"
  , verify = T, plotting = T, irtmodel = "GPCM")

write_change_measurement_model_plots(
  mod, path = 'report/learning-outcomes/measure-change-model-plots/', override = T
)

write_measure_change_report(
  mod, path = 'report/learning-outcomes/'
  , filename = 'MeasurementChangeModel.xlsx', override = T
)

write_csv(dplyr::mutate(mod$ability, gain.theta = pos.theta-pre.theta), 'data/GainSkillsKnowledge.csv')

