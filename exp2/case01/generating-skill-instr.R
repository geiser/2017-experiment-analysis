library(readr)
library(dplyr)
library(readxl)
library(parallel)
#options(mc.cores=6)

pre_dat <- as.data.frame(read_csv("data/PreTest.csv"))
rownames(pre_dat) <- pre_dat$UserID
pos_dat <- as.data.frame(read_csv("data/PosTest.csv"))
rownames(pos_dat) <- pos_dat$UserID

pre_dat_unify <- as.data.frame(read_csv("data/PreTestUnify.csv"))
rownames(pre_dat_unify) <- pre_dat_unify$UserID
pos_dat_unify <- as.data.frame(read_csv("data/PosTestUnify.csv"))
rownames(pos_dat_unify) <- pos_dat_unify$UserID

## Get TAMs for Basic Analysis
preTAMs <- load_and_save_TAMs_to_measure_change(
  pre_dat, column_names = list(P1=c(NA, 'P1s3', 'P1s2', 'P1s1', 'P1s0')
                               , Re1=c(NA, 'Re1'), Re2=c(NA, 'Re2')
                               , Un1=c(NA, 'Un1'), Un2=c(NA, 'Un2')
                               , Ap1=c(NA, 'Ap1'), Ap2=c(NA, 'Ap2'), Ap3=c(NA, 'Ap3')
                               , An3=c(NA, 'An3')
                               , Ev1=c(NA, 'Ev1'), Ev2=c(NA, 'Ev2'))
  , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214720&authkey=ABwrjZPet-L6vo0"
  , prefix =  "pre", min_columns = 9)
View(preTAMs$information)

posTAMs <- load_and_save_TAMs_to_measure_change(
  pos_dat, column_names = list(PA=c(NA, 'PAs3', 'PAs2', 'PAs1', 'PAs0')
                               , PB=c(NA, 'PBs3', 'PBs2', 'PBs1', 'PBs0')
                               , ReA=c(NA, 'ReA'), ReB=c(NA, 'ReB')
                               , UnA=c(NA, 'UnA'), UnB=c(NA, 'UnB')
                               , ApA=c(NA, 'ApA'), ApB=c(NA, 'ApB'), ApC=c(NA, 'ApC')
                               , AnC=c(NA, 'AnC')
                               , EvA=c(NA, 'EvA'), EvB=c(NA, 'EvB'))
  , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214721&authkey=AONbAbVs_VXG3hs"
  , prefix =  "pos", min_columns = 9)
View(posTAMs$information)

## get meassure changes using GPCMs
# +Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1         +P1s0
#     +UnA+UnB+ApA+   +ApC+AnC+EvA+EvB+PAs1+PBs2

skill_instr <- load_and_save_ability_instrument_to_measure_change(
  pre_dat = pre_dat, pos_dat = pos_dat
  , filename = 'skill_instr.RData', userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Ap1', 'Ap3')
  , same_items.pos = c('UnA', 'ApA', 'ApC')
)
filename <- 'report/skill_instr.xlsx'
if (!file.exists(filename)) {
  GPCM.measure_change.saveFile(skill_instr, filename = filename)
}

skill_instr_unify <- load_and_save_ability_instrument_to_measure_change(
  pre_dat = pre_dat_unify, pos_dat = pos_dat_unify
  , filename = 'skill_instr_unify.RData', userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Un2', 'Ap1', 'Ap3', 'An3', 'Ev1')
  , same_items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA')
)
filename <- 'report/skill_instr_unify.xlsx'
if (!file.exists(filename)) {
  GPCM.measure_change.saveFile(skill_instr_unify, filename = filename)
}

## extra quick analysis using wilcoxon
rdat <- merge(
  pre_dat[,c('UserID', 'Type', 'Group', 'CLRole', 'PlayerRole')]
  , skill_instr$ability.without[,c('UserID', 'pre.theta', 'pos.theta')]
  , by = 'UserID')
rownames(rdat) <- rdat$UserID
colnames(rdat) <- c('UserID', 'Type', 'CLGroup', 'CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')

rdat4test <- rdat[rdat$CLRole == 'Master',]
print(wilcox_analysis(
  rdat4test$Type
  , rdat4test$PostSkill-rdat4test$PreSkill
  , title = 'Programming Performance Skill (Master)'
  , sub = 'Quick Analysis Using Wilcox'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

rdat4test <- rdat[rdat$CLRole == 'Apprentice',]
print(wilcox_analysis(
  rdat4test$Type
  , rdat4test$PostSkill-rdat4test$PreSkill
  , title = 'Programming Performance Skill (Apprentice)'
  , sub = 'Quick Analysis Using Wilcox'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

rdat_unify <- merge(
  pre_dat_unify[,c('UserID', 'Type', 'Group', 'CLRole', 'PlayerRole')]
  , skill_instr_unify$ability.without[,c('UserID', 'pre.theta', 'pos.theta')]
  , by = 'UserID')
rownames(rdat_unify) <- rdat_unify$UserID
colnames(rdat_unify) <- c('UserID', 'Type', 'CLGroup', 'CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')

rdat4test_unify <- rdat_unify[rdat_unify$CLRole == 'Master',]
print(wilcox_analysis(
  rdat4test_unify$Type
  , rdat4test_unify$PostSkill-rdat4test_unify$PreSkill
  , title = 'Programming Performance Skill (Master)'
  , sub = 'Quick Analysis Using Wilcox and Unified Data'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

rdat4test_unify <- rdat_unify[rdat_unify$CLRole == 'Apprentice',]
print(wilcox_analysis(
  rdat4test_unify$Type
  , rdat4test_unify$PostSkill-rdat4test_unify$PreSkill
  , title = 'Programming Performance Skill (Apprentice)'
  , sub = 'Quick Analysis Using Wilcox and Unified Data'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

## saving better information
write_csv(rdat_unify, 'data/SkillChange.csv')

