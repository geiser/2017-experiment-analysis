library(readr)
library(dplyr)

## read data from csv and score programming tasks
pre_csv <- read_csv("2016-CS01-PretestData.csv")
pre_dat <- pre_csv[which(pre_csv$nviewP1>0 | pre_csv$nviewP2>0 | pre_csv$nviewP3>0 | pre_csv$nviewP4>0),]
pre_dat <- score_programming_tasks(pre_dat, keys = c("P1", "P2", "P3", "P4"))

pos_csv <- read_csv("2016-CS01-PostestData.csv")
pos_dat <- pos_csv[which(pos_csv$nviewPA>0 | pos_csv$nviewPA>0 | pos_csv$nviewPA>0 | pos_csv$nviewPA>0),]
pos_dat <- score_programming_tasks(pos_dat, keys = c("PA", "PC", "PB", "PD"))

userids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[pre_dat$UserID %in% userids,]
pos_dat <- pos_dat[pos_dat$UserID %in% userids,]

## get test analyse modules (TAMs) for programming modules
preTAMs <- get_TAMs_for_programming_tasks(
  pre_dat, list(P1=c(NA, "P1s3", "P1s2", "P1s1", "P1s0")
                , P2=c(NA, "P2s3", "P2s2", "P2s1", "P2s0")
                , P3=c(NA, "P3s0")
                , P4=c(NA, "P4s0")))

posTAMs <- get_TAMs_for_programming_tasks(
  pos_dat, list(P1=c(NA, "PAs3", "PAs2", "PAs1", "PAs0")
                , P2=c(NA, "PBs3", "PBs2", "PBs1", "PBs0")
                , P3=c(NA, "PCs3", "PCs2", "PCs1", "PCs0")
                , P4=c(NA, "PDs1", "PDs0")))

View(preTAMs$information)
View(posTAMs$information)

pre_mod <- preTAMs$unidimensional$`P1s2+P2s0+P3s0+P4s0` 
pos_mod <- posTAMs$unidimensional$`PAs0+PBs0+PCs0+PDs1`

## get information of test for unidimensionality and task model fit
pre_uni <- test_unidimensionality(pre_mod)
fitMeasures(pre_uni$lav_mod)
pre_uni$detect_mod$detect.summary
tam.fit(pre_mod)

pos_uni <- test_unidimensionality(pos_mod)
fitMeasures(pos_uni$lav_mod)
pos_uni$detect_mod$detect.summary
tam.fit(pos_mod)

## Meassure changes using GPCMs
result_changes <- GPCM.measure_change(
  pre_dat = pre_dat, pos_dat = pos_dat, userid = "UserID"
  , items.pre = c("P1s2", "P2s0", "P3s0", "P4s0")
  , items.pos = c("PAs0", "PBs0", "PCs0", "PDs1")
  , same_items.pre = c("P2s0","P3s0"), same_items.pos = c("PBs0","PCs0"))

GPCM.measure_change.saveFile(result_changes, filename = '2016-gpcm-measure-01.xlsx')

IRT.WrightMap(result_changes$info.stacking$pre_mod, type='PV'
              , dim.color = 'gray'
              , thr.sym.col.fg = 'black'
              , thr.sym.col.bg = 'black'
              , thr.sym.pch = matrix(c(rep(16, 12), rep(17, 12), rep(18, 16)), byrow = TRUE, ncol = 4)
              , main='Wright Map for Pre-test')
grid()

IRT.WrightMap(result_changes$info.stacking$pos_mod, type='PV'
              , dim.color = 'gray'
              , thr.sym.col.fg = 'black'
              , thr.sym.col.bg = 'black'
              , thr.sym.pch = matrix(c(rep(16, 12), rep(17, 12), rep(18, 16)), byrow = TRUE, ncol = 4)
              , main='Wright Map for Post-test')
grid()

plot(result_changes$info.stacking$pre_mod, type = 'items')
plot(result_changes$info.stacking$pre_mod, type = 'expected')

plot(result_changes$info.stacking$pos_mod, type = 'items')
plot(result_changes$info.stacking$pos_mod, type = 'expected')

write_csv(result_changes$ability, path = '2016-Ability01-with-outliers.csv')
write_csv(result_changes$ability.without, path = '2016-Ability01.csv')

## get information from cvs files to statistic analysis
ability <- read_csv('2016-Ability01.csv')
participants <- read_csv('2016-Participant01.csv')
activities <- read_csv('2016-CLActivity01.csv')

rdat <- merge(participants, ability[,c('UserID','pre.theta','pos.theta')], by = 'UserID')
rownames(rdat) <- rdat$UserID
colnames(rdat) <- c('UserID','Type','CLGroup','CLRole', 'PlayerRole', 'PreSkill',  'PostSkill')


## test assumptions for parametric test
test_z <- test_min_size(rdat, between = c('Type', 'CLRole')) 
if (test_z$fail) {
  print(test_z$table.frequency)
  print(test_z$fails_warnings)
}

rdat4test <- rdat[rdat$CLRole != 'Master',]
test_z <- test_min_size(rdat4test, between = c('Type', 'CLRole')) 
print(test_z$table.frequency)
print(test_z$fails_warnings)

## perform parametric and non-parametric test
print(wt <- wilcox_analysis(
  rdat4test$Type
  , rdat4test$PostSkill-rdat4test$PreSkill
  , title = 'Programming Performance Skill'
  , alternative = 'less'
  , ylab = 'Difference of Pre- and Post-test in Logits'))

## correlation analysis and linear regression 
library(psych)
library(PerformanceAnalytics) # install.packages('PerformanceAnalytics')

motivation <- read_csv('2016-Result-Motivation01.csv')
motivation <- data.frame(
  UserID = motivation$UserID
  , InterestEnjoyment = motivation$`Interest/Enjoyment`
  , PerceivedChoice = motivation$`Perceived Choice`
  , PressureTension = motivation$`Pressure/Tension`
  , EffortImportance = motivation$`Effort/Importance`
  , IntrinsicMotivation = motivation$`Intrinsic Motivation`
)
 
rdat4corr <- merge(dplyr::mutate(rdat, DifferenceSkill = PostSkill-PreSkill), motivation, by = 'UserID')
rdat4corr <- merge(rdat4corr, activities[c('UserID', 'ParticipationLevel', 'NroNecessaryInteractions', 'NroDesiredInteractions')], by = 'UserID')
rdat4corr <- dplyr::mutate(rdat4corr, NroInteractions = rdat4corr$NroNecessaryInteractions + rdat4corr$NroDesiredInteractions, Participation = if_else(rdat4corr$ParticipationLevel == 'none', 0, if_else(rdat4corr$ParticipationLevel == 'partial', 1, if_else(rdat4corr$ParticipationLevel == 'semicomplete', 2, 3))))
rownames(rdat4corr) <- rdat4corr$UserID
rdat4corr[, 'Type'] <- factor(rdat4corr$Type)

pairs(
  data = rdat4corr
  , as.formula(
    paste('~', 'DifferenceSkill'
          , '+', 'PostSkill'
          , '+', 'IntrinsicMotivation'
          , '+', 'InterestEnjoyment'
          , '+', 'PressureTension'
          , '+', 'PerceivedChoice'
          , '+', 'EffortImportance'
          , '+', 'Participation'
          , '+', 'NroInteractions'
          , '+', 'NroNecessaryInteractions'
          , '+', 'NroDesiredInteractions'
          )
    ))

multiple_corr_test  <- function(data, list_of_combs, method='spearman', plotting = TRUE) {
  result <- list()
  grid_of_combs <- as.matrix(expand.grid(list_of_combs))
  
  for (i in 1:nrow(grid_of_combs)) {
    cnames <- grid_of_combs[i,]
    rdat_num <- data[cnames]
    cnames_str <- paste('~', paste0(cnames, collapse = '+'))
    corr_mod <- corr.test(rdat_num, use = 'pairwise', method = method, adjust = 'none')
    if (plotting & any((abs(corr_mod$r)>0.38) & (abs(corr_mod$r)<0.99))) {
      result[[cnames_str]] <- corr_mod
      chart.Correlation(rdat_num, method = method, histogram = T, pch=16, sub=cnames_str, main='Correlation Matrix Chart')
    }
  }
  
  return(result)
}

resp_mult_corr <- multiple_corr_test(
  rdat4corr
  , list(c('DifferenceSkill', 'PostSkill')
         , c('IntrinsicMotivation', 'InterestEnjoyment', 'PressureTension', 'PerceivedChoice', 'EffortImportance')
         , c('Participation', 'NroInteractions', 'NroNecessaryInteractions', 'NroDesiredInteractions')))

rdat4corr.num <- rdat4corr[
  c('DifferenceSkill', 'PostSkill', 'IntrinsicMotivation'
    #, 'InterestEnjoyment', 'PressureTension', 'PerceivedChoice', 'EffortImportance'
    #, 'Participation'
    , 'NroInteractions', 'NroNecessaryInteractions', 'NroDesiredInteractions')]

chart.Correlation(rdat4corr.num, method='kendall', histogram=T, pch=16, main='Title')
chart.Correlation(rdat4corr.num, method='spearman', histogram=T, pch=16)

corr_mod <- corr.test(rdat4corr.num, use = 'pairwise', method = 'kendall', adjust = 'none')
corr_mod <- corr.test(rdat4corr.num, use = 'pairwise', method = 'spearman', adjust = 'none')

## correlation analysis and linear regression 
rdat4corr2 <- merge(dplyr::mutate(rdat4test, DifferenceSkill = PostSkill-PreSkill), motivation, by = 'UserID')
rownames(rdat4corr2) <- rdat4corr2$UserID
rdat4corr2[, 'Type'] <- factor(rdat4corr2$Type)

rdat4corr2.num <- rdat4corr2[
  c('DifferenceSkill', 'PostSkill', 'IntrinsicMotivation', 'InterestEnjoyment'
    , 'PressureTension', 'PerceivedChoice', 'EffortImportance')]

chart.Correlation(rdat4corr2.num, method='kendall', histogram=T, pch=16)
chart.Correlation(rdat4corr2.num, method='spearman', histogram=T, pch=16)


########################################################################
summary(corr_mod)





test_z <- test_min_size(rdat4cov, between = c('Type', 'CLRole')) 
print(test_z$table.frequency)



aov_mod <- aov(as.formula('Diff ~ IM + Type'), data = rdat4cov)
summary(aov_mod)
plot(aov_mod, ask = F)

rdat4cov <- rdat4cov[!(rdat4cov$UserID %in% c(10122, 10128, 10135, 10148)),]
aov_mod <- aov(as.formula('Diff ~ IM + Type'), data = rdat4cov)
summary(aov_mod)
plot(aov_mod, ask = F)




aov_mod <- aov(as.formula('Diff ~ IM + Type'), data = rdat4cov)
summary(aov_mod)
plot(aov_mod, ask = F)



test_n <- get_aov_mods_for_pre_post_test(
  data = rdat
  , wid = 'UserID', pre.test = 'PreSkill', post.test = 'PostSkill', between = c('Type', 'CLGroup'))

do_statistical_analysis_for_pre_post_test(
  data = data
  , wid = 'UserID'
  , pre.test = 'pre.theta'
  , post.test = 'pos.theta'
  , between = c('Type', 'CLRole')
)


data <- rdat['10141' != rdat$UserID,]
