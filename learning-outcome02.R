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
participants <- read_csv('Participant02.csv')

## get p1a and p1b information (provinha1-a and provinha1-b)
p1a_part1_dat <- read_excel(
  "LearningData02.xlsx", sheet = "provinha1a-cond-part1", col_types = "numeric")
p1a_part1_dat <- select(
  p1a_part1_dat, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('evaluate'))
p1a_part1_dat <- p1a_part1_dat[complete.cases(p1a_part1_dat),]

p1b_part1_dat <- read_excel(
  "LearningData02.xlsx", sheet = "provinha1b-cond-part1", col_types = "numeric")
p1b_part1_dat <- select(
  p1b_part1_dat, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('evaluate'))
p1b_part1_dat <- p1b_part1_dat[complete.cases(p1b_part1_dat),]

p1a_part2_dat <- read_excel(
  "LearningData02.xlsx", sheet = "provinha1a-cond-part2", col_types = "numeric")
p1a <- merge(p1a_part1_dat, p1a_part2_dat, by='NUSP')
colnames(p1a) <- sub('remember', 'Re', colnames(p1a))
colnames(p1a) <- sub('understand', 'Un', colnames(p1a))
colnames(p1a) <- sub('apply', 'Ap', colnames(p1a))
colnames(p1a) <- sub('analyse', 'An', colnames(p1a))
colnames(p1a) <- sub('evaluate', 'Ev', colnames(p1a))
colnames(p1a) <- sub('-unistructural', '1', colnames(p1a))
colnames(p1a) <- sub('-multistructural', '2', colnames(p1a))
colnames(p1a) <- sub('-relational', '3', colnames(p1a))
p1a <- select(
  p1a, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p1a <- merge(participants, p1a, by.x = 'NroUSP', by.y = 'NUSP')

p1b_part2_dat <- read_excel(
  "LearningData02.xlsx", sheet = "provinha1b-cond-part2", col_types = "numeric")
p1b <- merge(p1b_part1_dat, p1b_part2_dat, by='NUSP')
colnames(p1b) <- sub('remember', 'Re', colnames(p1b))
colnames(p1b) <- sub('understand', 'Un', colnames(p1b))
colnames(p1b) <- sub('apply', 'Ap', colnames(p1b))
colnames(p1b) <- sub('analyse', 'An', colnames(p1b))
colnames(p1b) <- sub('evaluate', 'Ev', colnames(p1b))
colnames(p1b) <- sub('-unistructural', 'A', colnames(p1b))
colnames(p1b) <- sub('-multistructural', 'B', colnames(p1b))
colnames(p1b) <- sub('-relational', 'C', colnames(p1b))
p1b <- select(
  p1b, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p1b <- merge(participants, p1b, by.x = 'NroUSP', by.y = 'NUSP')

userids <- intersect(p1a$UserID, p1b$UserID)

## get pre TAMs
pre_dat <- merge(p1a, select(vpl_dat, starts_with('UserID'), starts_with('P1')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

preTAMs <- load_and_save_TAMs_to_measure_change(
  pre_dat, column_names = list(P1=c(NA, 'P1s3', 'P1s2', 'P1s1', 'P1s0')
                               , Re1=c(NA, 'Re1'), Re2=c(NA, 'Re2')
                               , Un1=c(NA, 'Un1'), Un2=c(NA, 'Un2')
                               , Ap1=c(NA, 'Ap1'), Ap2=c(NA, 'Ap2'), Ap3=c(NA, 'Ap3')
                               , An3=c(NA, 'An3')
                               , Ev1=c(NA, 'Ev1'), Ev2=c(NA, 'Ev2'))
  , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214720&authkey=ABwrjZPet-L6vo0"
  , prefix =  "LearningOutcome2pre", min_columns = 9)
View(preTAMs$information)

## get pos TAMs
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
save(result_changes, file = file_result_changes_str)

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
save(result_changes_unify, file = file_result_changes_unify_str)

## quick analysis using wilcoxon???????
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


## quick analysis using wilcoxon
rdat_unify <- merge(participants, result_changes_unify$ability.without[,c('UserID','pre.theta','pos.theta')], by = 'UserID')
rownames(rdat_unify) <- rdat_unify$UserID
colnames(rdat_unify) <- c('UserID','NroUSP','Type','CLGroup','CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')

rdat4test_unify <- rdat_unify[rdat_unify$CLRole == 'Master',]
print(wilcox_analysis(
  rdat4test_unify$Type
  , rdat4test_unify$PostSkill-rdat4test_unify$PreSkill
  , title = 'Programming Performance Skill (Master)'
  , sub = 'Quick Analysis Using Wilcox and Unify Data'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

rdat4test_unify <- rdat_unify[rdat_unify$CLRole == 'Apprentice',]
print(wilcox_analysis(
  rdat4test_unify$Type
  , rdat4test_unify$PostSkill-rdat4test_unify$PreSkill
  , title = 'Programming Performance Skill (Apprentice)'
  , sub = 'Quick Analysis Using Wilcox and Unify Data'
  , alternative = 'less'
  , ylab = 'Difference in Logits'))

##############################################################################

GPCM.measure_change.saveFile(result_changes, filename = 'gpcm-measure-02.xlsx')

write_csv(result_changes$ability.without, path = 'Ability02.csv')

## get information from cvs files to statistic analysis
ability <- read_csv('Ability02.csv')
participants <- read_csv('Participant02.csv')
activities <- read_csv('CLActivity02.csv')



## test assumptions for parametric test
test_z <- test_min_size(rdat, between = c('Type', 'CLRole')) 
if (test_z$fail) {
  print(test_z$table.frequency)
  print(test_z$fails_warnings)
}




+Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1+P1s0
+UnA+UnB+ApA+ApC+AnC+EvA+EvB+PAs1+PBs2

"Quien es el guionista del debate y GH ?? vender carpetas cansa, es lo peor!!!"



