library(readr)
library(dplyr)
library(readxl)
library(parallel)
#options(mc.cores=6)

aov_dat <- read_excel("report/learning-outcome/AnovaAnalysis.xlsx", sheet = "data", col_types = "numeric")
userids <- aov_dat$UserID

pre_dat <- as.data.frame(read_csv("data/SourcePreTestWithVPL.csv"))
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- as.data.frame(read_csv("data/SourcePosTestWithVPL.csv"))
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

sdat <- get_stacking_data(
  pre_dat, pos_dat, 'UserID'
  , items.pre = c("Re2","Un2","Ap1","Ap3","An3a","An3b","Ev2","P4s0","P4s1","P4s2","P4s3")
  , items.pos = c("ReB","UnB","ApA","ApC","AnC1","AnC2","EvB","PFs0","PFs1","PFs2","PFs3")
  , same.items = list(pre = c("Re2","An3a","An3b","Ev2","P4s0","P4s1","P4s2","P4s3"),
                      pos = c("ReB","AnC1","AnC2","EvB","PFs0","PFs1","PFs2","PFs3"))
)

## Get TAMs for analysis of pre- and post-test
resTAMs <- load_and_save_TAMs_to_measure_change(
  sdat, column_names = list(
    Re2ReB=c(NA,'Re2ReB')
    , Un2=c('Un2'), UnB=c('UnB')
    , Ap1=c('Ap1'), ApA=c('ApA')
    , Ap3=c('Ap3'), ApC=c('ApC')
    , An3aAnC1=c(NA,'An3aAnC1'), An3bAnC2=c(NA,'An3bAnC2')
    , Ev2EvB=c(NA,'Ev2EvB')
    , P4PF=c(NA, 'P4s0PFs0', 'P4s1PFs1', 'P4s2PFs2', 'P4s3PFs3'))
  #, url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214720&authkey=ABwrjZPet-L6vo0"
  , itemequals = list(An3=c('An3aAnC1', 'An3bAnC2'))
  , prefix =  "case03", min_columns = 7)
View(preTAMs$information)

### ????

## Get TAMs for Basic Analysis
preTAMs <- load_and_save_TAMs_to_measure_change(
  pre_dat, column_names = list(Re2=c(NA, 'Re2')
                               , Un2=c(NA, 'Un2')
                               , Ap1=c('Ap1'), Ap3=c('Ap3')
                               , An3a=c('An3a'), An3b=c('An3b')
                               , Ev2=c('Ev2')
                               , P4=c(NA, 'P4s3', 'P4s2', 'P4s1', 'P4s0'))
  #, url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214720&authkey=ABwrjZPet-L6vo0"
  , itemequals = list(An3=c('An3a', 'An3b'))
  , prefix =  "pre", min_columns = 5)
View(preTAMs$information)

###3 ??

library(readr)
library(dplyr)
library(readxl)
library(parallel)
#options(mc.cores=6)

## get vpl data
vpl_leg <- read_excel("LearningData02.xlsx", sheet = "legend-VPL")
vpl_dat <- read_excel("LearningData02.xlsx", sheet = "VPLData", col_types = "numeric")
vpl_dat <- abs(vpl_dat)
vpl_dat[is.na(vpl_dat)] <- 0

vpl_dat <- score_programming_tasks(dat = vpl_dat
  , nview_str = 'start', apxt_str = 'exat', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4","PA","PB","PC","PD","PE","PF","PG","PH"))

## get participants cvs
participants <- read_csv('Participant04.csv')

## get p3a and p3c information (provinha3a and provinha3c)
p3a <- read_excel(
  "LearningData02.xlsx", sheet = "provinha3a-recurs", col_types = "numeric")
p3a <- select(
  p3a, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
p3a <- p3a[complete.cases(p3a),]

p3c <- read_excel(
  "LearningData02.xlsx", sheet = "provinha3c-recurs", col_types = "numeric")
p3c <- select(
  p3c, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
p3c <- p3c[complete.cases(p3c),]

colnames(p3a) <- sub('remember', 'Re', colnames(p3a))
colnames(p3a) <- sub('understand', 'Un', colnames(p3a))
colnames(p3a) <- sub('apply', 'Ap', colnames(p3a))
colnames(p3a) <- sub('analyse', 'An', colnames(p3a))
colnames(p3a) <- sub('evaluate', 'Ev', colnames(p3a))
colnames(p3a) <- sub('-unistructural', '1', colnames(p3a))
colnames(p3a) <- sub('-multistructural', '2', colnames(p3a))
colnames(p3a) <- sub('-relational', '3', colnames(p3a))
colnames(p3a) <- sub('-1', 'a', colnames(p3a))
colnames(p3a) <- sub('-2', 'b', colnames(p3a))
colnames(p3a) <- sub('-3', 'c', colnames(p3a))
p3a <- select(
  p3a, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p3a <- merge(participants, p3a, by.x = 'Nro USP', by.y = 'NUSP')

colnames(p3c) <- sub('remember', 'Re', colnames(p3c))
colnames(p3c) <- sub('understand', 'Un', colnames(p3c))
colnames(p3c) <- sub('apply', 'Ap', colnames(p3c))
colnames(p3c) <- sub('analyse', 'An', colnames(p3c))
colnames(p3c) <- sub('evaluate', 'Ev', colnames(p3c))
colnames(p3c) <- sub('-unistructural', 'A', colnames(p3c))
colnames(p3c) <- sub('-multistructural', 'B', colnames(p3c))
colnames(p3c) <- sub('-relational', 'C', colnames(p3c))
colnames(p3c) <- sub('-1', '1', colnames(p3c))
colnames(p3c) <- sub('-2', '2', colnames(p3c))
colnames(p3c) <- sub('-3', '3', colnames(p3c))
p3c <- select(
  p3c, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p3c <- merge(participants, p3c, by.x = 'Nro USP', by.y = 'NUSP')

userids <- intersect(p3c$UserID, p3c$UserID)

## get pre TAMs
pre_dat <- merge(p3a, select(vpl_dat, starts_with('UserID'), starts_with('P4')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

preTAMs <- load_and_save_TAMs_to_measure_change(
  pre_dat, column_names = list(Re2=c(NA, 'Re2')
                               , Un2=c(NA, 'Un2')
                               , Ap1=c(NA, 'Ap1'), Ap3=c(NA, 'Ap3')
                               , An3a=c(NA, 'An3a'), An3b=c(NA, 'An3b')
                               , Ev2=c(NA, 'Ev2')
                               , P4=c(NA, 'P4s3', 'P4s2', 'P4s1', 'P4s0'))
  #, url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214720&authkey=ABwrjZPet-L6vo0"
  , itemequals = list(An3=c('An3a', 'An3b'))
  , prefix =  "LearningOutcome4pre", min_columns = 6)
View(preTAMs$information)

## get pos TAMs ???
pos_dat <- merge(p1b, select(vpl_dat, starts_with('UserID'), starts_with('PA'), starts_with('PB')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

posTAMs <- load_and_save_TAMs_to_measure_change(
  pos_dat, column_names = list(PA=c(NA, 'PAs3', 'PAs2', 'PAs1', 'PAs0')
                               , PB=c(NA, 'PBs3', 'PBs2', 'PBs1', 'PBs0')
                               , ReA=c(NA, 'ReA'), ReB=c(NA, 'ReB')
                               , UnA=c(NA, 'UnA'), UnB=c(NA, 'UnB')
                               , ApA=c(NA, 'ApA'), ApB=c(NA, 'ApB'), ApC=c(NA, 'ApC')
                               , AnC=c(NA, 'AnC')
                               , EvA=c(NA, 'EvA'), EvB=c(NA, 'EvB'))
  , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214721&authkey=AONbAbVs_VXG3hs"
  , prefix =  "LearningOutcome2pos", min_columns = 9)
View(posTAMs$information)

## get meassure changes using GPCMs
pre_dat[,'Cr2'] <- pre_dat[,'P1s0']
pos_dat[,'CrA'] <- pos_dat[,'PAs1']
pos_dat[,'CrB'] <- pos_dat[,'PBs2']

tam_models <- NULL
file_result_changes_str <- 'LearningOutcome2result_changes.RData'
if (file.exists(file_result_changes_str)) {
  result_changes <- get(load(file_result_changes_str))
  tam_models <- list(
    pre_mod1 = result_changes$info.verification$pre_mod
    , pos_mod1 = result_changes$info.verification$pos_mod
    , mod2 = result_changes$global.estimation$mod
    , pre_mod3 = result_changes$info.stacking$pre_mod
    , pos_mod3 = result_changes$info.stacking$pos_mod
    , mod4 = result_changes$info.racking$mod)
}
result_changes <- GPCM.measure_change(
  # +Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1         +P1s0
  #     +UnA+UnB+ApA+   +ApC+AnC+EvA+EvB+PAs1+PBs2
  pre_dat = pre_dat, pos_dat = pos_dat, userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Ap1', 'Ap3')
  , same_items.pos = c('UnA', 'ApA', 'ApC')
  , tam_models = tam_models
)
if (!file.exists(file_result_changes_str)) save(result_changes, file = file_result_changes_str)

if (!file.exists('GPCMLearningOutcome02.xlsx')) {
  GPCM.measure_change.saveFile(result_changes, filename = 'GPCMLearningOutcome02.xlsx')
}

## get meassure changes using unify GPCMs
pre_dat_unify <- pre_dat
pos_dat_unify <- pos_dat

pre_dat_unify[,'Ap2'] <- pre_dat[,'Ap2']*12
pos_dat_unify[,'ApB'] <- pos_dat[,'ApB']*1

pre_dat_unify[,'Ev2'] <- pre_dat[,'Ev2']*6
pos_dat_unify[,'EvB'] <- pos_dat[,'EvB']*5

pre_dat_unify[,'Ev1'] <- pre_dat[,'Ev1']*1
pos_dat_unify[,'EvA'] <- pos_dat[,'EvA']*2

pre_dat_unify[,'Un2'] <- pre_dat[,'Un2']*2
pos_dat_unify[,'UnB'] <- pos_dat[,'UnB']*3

pre_dat_unify[,'An3'] <- pre_dat[,'An3']*7
pos_dat_unify[,'AnC'] <- pos_dat[,'AnC']*8

tam_models_unify <- NULL
file_result_changes_unify_str <- 'LearningOutcome2result_changes_unify.RData'
if (file.exists(file_result_changes_unify_str)) {
  result_changes_unify <- get(load(file_result_changes_unify_str))
  tam_models_unify <- list(
    pre_mod1 = result_changes_unify$info.verification$pre_mod
    , pos_mod1 = result_changes_unify$info.verification$pos_mod
    , mod2 = result_changes_unify$global.estimation$mod
    , pre_mod3 = result_changes_unify$info.stacking$pre_mod
    , pos_mod3 = result_changes_unify$info.stacking$pos_mod
    , mod4 = result_changes_unify$info.racking$mod)
}
result_changes_unify <- GPCM.measure_change(
  # +Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1         +P1s0
  #     +UnA+UnB+ApA+   +ApC+AnC+EvA+EvB+PAs1+PBs2
  pre_dat = pre_dat_unify, pos_dat = pos_dat_unify, userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Un2', 'Ap1', 'Ap3', 'An3', 'Ev1')
  , same_items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA')
  , tam_models = tam_models_unify
)
if (!file.exists(file_result_changes_unify_str)) save(result_changes_unify, file = file_result_changes_unify_str)

if (!file.exists('GPCMLearningOutcome02unify.xlsx')) {
  GPCM.measure_change.saveFile(result_changes_unify, filename = 'GPCMLearningOutcome02unify.xlsx')
}

## quick analysis using wilcoxon
rdat <- merge(participants, result_changes$ability.without[,c('UserID','pre.theta','pos.theta')], by = 'UserID')
rownames(rdat) <- rdat$UserID
colnames(rdat) <- c('UserID','NroUSP','Type','CLGroup','CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')

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

## quick analysis using wilcoxon with unify data
rdat_unify <- merge(participants, result_changes_unify$ability.without[,c('UserID','pre.theta','pos.theta')], by = 'UserID')
rownames(rdat_unify) <- rdat_unify$UserID
colnames(rdat_unify) <- c('UserID','NroUSP','Type','CLGroup','CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')

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

##############################################################################


