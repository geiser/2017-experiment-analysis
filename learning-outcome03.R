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

vpl_dat <- score_programming_tasks(
  dat = vpl_dat
  , nview_str = 'start', apxt_str = 'exat', def_non_view_score = -1
  , keys = c("P1","P2","P3","P4","PA","PB","PC","PD","PE","PF","PG","PH"))

## get participants cvs
participants <- read_csv('Participant03.csv')

## get p1a and p1b information (provinha1-a and provinha1-b)
p2a <- read_excel(
  "LearningData02.xlsx", sheet = "provinha2a-loops", col_types = "numeric")
p2a <- select(
  p2a, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
p2a <- p2a[complete.cases(p2a),]

p2b <- read_excel(
  "LearningData02.xlsx", sheet = "provinha2b-loops", col_types = "numeric")
p2b <- select(
  p2b, starts_with('NUSP')
  , starts_with('remember'), starts_with('understand')
  , starts_with('apply'), starts_with('analyse'), starts_with('evaluate'))
p2b <- p2b[complete.cases(p2b),]

colnames(p2a) <- sub('remember', 'Re', colnames(p2a))
colnames(p2a) <- sub('understand', 'Un', colnames(p2a))
colnames(p2a) <- sub('apply', 'Ap', colnames(p2a))
colnames(p2a) <- sub('analyse', 'An', colnames(p2a))
colnames(p2a) <- sub('evaluate', 'Ev', colnames(p2a))
colnames(p2a) <- sub('-unistructural', '1', colnames(p2a))
colnames(p2a) <- sub('-multistructural', '2', colnames(p2a))
colnames(p2a) <- sub('-relational', '3', colnames(p2a))
colnames(p2a) <- sub('-1', 'a', colnames(p2a))
colnames(p2a) <- sub('-2', 'b', colnames(p2a))
colnames(p2a) <- sub('-3', 'c', colnames(p2a))
p2a <- select(
  p2a, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p2a <- merge(participants, p2a, by.x = 'Nro USP', by.y = 'NUSP')

colnames(p2b) <- sub('remember', 'Re', colnames(p2b))
colnames(p2b) <- sub('understand', 'Un', colnames(p2b))
colnames(p2b) <- sub('apply', 'Ap', colnames(p2b))
colnames(p2b) <- sub('analyse', 'An', colnames(p2b))
colnames(p2b) <- sub('evaluate', 'Ev', colnames(p2b))
colnames(p2b) <- sub('-unistructural', 'A', colnames(p2b))
colnames(p2b) <- sub('-multistructural', 'B', colnames(p2b))
colnames(p2b) <- sub('-relational', 'C', colnames(p2b))
colnames(p2b) <- sub('-1', '1', colnames(p2b))
colnames(p2b) <- sub('-2', '2', colnames(p2b))
colnames(p2b) <- sub('-3', '3', colnames(p2b))
p2b <- select(
  p2b, starts_with('NUSP'), starts_with('Re'), starts_with('Un')
  , starts_with('Ap'), starts_with('An'), starts_with('Ev'))
p2b <- merge(participants, p2b, by.x = 'Nro USP', by.y = 'NUSP')

userids <- intersect(p2a$UserID, p2b$UserID)

## get pre TAMs
pre_dat <- merge(p2a, select(vpl_dat, starts_with('UserID'), starts_with('P2'), starts_with('P3')), by='UserID')
rownames(pre_dat) <- pre_dat$UserID
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]

preTAMs <- load_and_save_TAMs_to_measure_change(
  pre_dat, column_names = list(Re1=c(NA, 'Re1')
                               , Un3=c(NA, 'Un3')
                               , Ap2a=c(NA, 'Ap2a'), Ap2b=c(NA, 'Ap2b')
                               , An3a=c(NA, 'An3a'), An3b=c(NA, 'An3b')
                               , Ev2=c(NA, 'Ev2')
                               , P2=c(NA, 'P2s3', 'P2s2', 'P2s1', 'P2s0')
                               , P3=c(NA, 'P3s3', 'P3s2', 'P3s1', 'P3s0'))
  , url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214722&authkey=AGHh9rR2mNuBW44"
  , itemequals = list(Ap2=c('Ap2a','Ap2b'), An3=c('An3a', 'An3b'))
  , prefix =  "LearningOutcome3pre", min_columns = 5)
View(preTAMs$information)

## get pos TAMs
pos_dat <- merge(p2b, select(vpl_dat, starts_with('UserID'), starts_with('PC'), starts_with('PD'), starts_with('PE')), by='UserID')
rownames(pos_dat) <- pos_dat$UserID
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

posTAMs <- load_and_save_TAMs_to_measure_change(
  pos_dat, column_names = list(ReA=c(NA, 'ReA')
                               , UnC=c(NA, 'UnC')
                               , ApB1=c(NA, 'ApB1'), ApB2=c(NA, 'ApB2')
                               , AnC1=c(NA, 'AnC1'), AnC2=c(NA, 'AnC2')
                               , EvB=c(NA, 'EvB')
                               , PC=c(NA, 'PCs3', 'PCs2', 'PCs1', 'PCs0')
                               , PD=c(NA, 'PDs3', 'PDs2', 'PDs1', 'PDs0')
                               , PE=c(NA, 'PEs3', 'PEs2', 'PEs1', 'PEs0'))
  #, url_str = "https://onedrive.live.com/download?cid=C5E009CC5BFDE10C&resid=C5E009CC5BFDE10C%214721&authkey=AONbAbVs_VXG3hs"
  , itemequals = list(ApB=c('ApB1','ApB2'), AnC=c('AnC1', 'AnC2'))
  , prefix =  "LearningOutcome3pos", min_columns = 5)
View(posTAMs$information)

## get meassure changes using GPCMs
# +Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1         +P1s0
#     +UnA+UnB+ApA+   +ApC+AnC+EvA+EvB+PAs1+PBs2
pre_dat[,'Cr2'] <- pre_dat[,'P1s0']
pos_dat[,'CrA'] <- pos_dat[,'PAs1']
pos_dat[,'CrB'] <- pos_dat[,'PBs2']

result_changes <- GPCM.measure_change(
  pre_dat = pre_dat, pos_dat = pos_dat, userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Ap1', 'Ap3')
  , same_items.pos = c('UnA', 'ApA', 'ApC')
)

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

## get meassure changes using unify GPCMs
pre_dat_unify <- pre_dat
pos_dat_unify <- pos_dat

pre_dat_unify[,'An3a'] <- pre_dat[,'An3a']*9
pos_dat_unify[,'AnC1'] <- pos_dat[,'AnC1']*8

pre_dat_unify[,'An3b'] <- pre_dat[,'An3b']*3
pos_dat_unify[,'AnC2'] <- pos_dat[,'AnC2']*2

pre_dat_unify[,'Re1'] <- pre_dat[,'Re1']*12
pos_dat_unify[,'ReA'] <- pos_dat[,'ReA']*13

pre_dat_unify[,'Un3'] <- pre_dat[,'Un3']*13
pos_dat_unify[,'UnC'] <- pos_dat[,'UnC']*10

# +Re2+Un1+Un2+Ap1+Ap2+Ap3+An3+Ev1         +P1s0
#     +UnA+UnB+ApA+   +ApC+AnC+EvA+EvB+PAs1+PBs2
result_changes_unify <- GPCM.measure_change(
  pre_dat = pre_dat_unify, pos_dat = pos_dat_unify, userid = "UserID"
  , items.pre = c('Re2', 'Un1', 'Un2', 'Ap1', 'Ap2', 'Ap3', 'An3', 'Ev1', 'Cr2')
  , items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA', 'EvB', 'CrA', 'CrB')
  , same_items.pre = c('Un1', 'Un2', 'Ap1', 'Ap3', 'An3', 'Ev1')
  , same_items.pos = c('UnA', 'UnB', 'ApA', 'ApC', 'AnC', 'EvA')
)

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

