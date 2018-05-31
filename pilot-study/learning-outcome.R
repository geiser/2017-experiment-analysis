library(readr)
library(dplyr)



########################
## Continue from here ##
########################

## read data from csv and score programming tasks
pre_csv <- read_csv("data/PreTest.csv")
pre_dat <- pre_csv[which(pre_csv$nviewP1>0 | pre_csv$nviewP2>0 | pre_csv$nviewP3>0 | pre_csv$nviewP4>0),]
pre_dat <- score_programming_tasks(pre_dat, keys = c("P1", "P2", "P3", "P4"))

pos_csv <- read_csv("data/PosTest.csv")
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
result_changes <- TAM.measure_change(
  pre_dat, pos_dat
  , items.pre = c("P1s2", "P2s0", "P3s0", "P4s0")
  , items.pos = c("PAs0", "PBs0", "PCs0", "PDs1")
  , same_items.pre = c("P2s0","P3s0")
  , same_items.pos = c("PBs0","PCs0")
  , userid = "UserID", verify = T, plotting = F, remove_outlier = T
  , tam_models = NULL, irtmodel = "GPCM")


participants <- as.data.frame(read_csv("data/SignedUpParticipants.csv"))
abilities_info <- result_changes$ability.without

dat <- merge(participants, abilities_info[,c("UserID","pre.theta","pos.theta")])
colnames(dat) <- c(colnames(participants), c("PreTheta", "PostTheta"))
dat <- dplyr::mutate(dat, `DiffTheta` = dat$PostTheta-dat$PreTheta)
rownames(dat) <- dat$UserID


#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
result <- do_nonparametric_test(dat, wid = 'UserID', dv = "DiffTheta", iv = "Type", between = c("Type", "CLRole"))

write_plots_for_nonparametric_test(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , path = "report/learning-outcome/signedup-participants/nonparametric-analysis-plots/"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)
write_nonparametric_test_report(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , filename = "report/learning-outcome/signedup-participants/NonParametricAnalysis.xlsx"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)

###########################

participants <- as.data.frame(read_csv("data/EffectiveParticipants.csv"))
abilities_info <- result_changes$ability.without

dat <- merge(participants, abilities_info[,c("UserID","pre.theta","pos.theta")])
colnames(dat) <- c(colnames(participants), c("PreTheta", "PostTheta"))
dat <- dplyr::mutate(dat, `DiffTheta` = dat$PostTheta-dat$PreTheta)
rownames(dat) <- dat$UserID


#############################################################################
## Non-Parametric Statistic Analysis                                       ##
#############################################################################
result <- do_nonparametric_test(dat, wid = 'UserID', dv = "DiffTheta", iv = "Type", between = c("Type", "CLRole"))

write_plots_for_nonparametric_test(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , path = "report/learning-outcome/effective-participants/nonparametric-analysis-plots/"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)
write_nonparametric_test_report(
  result, ylab = "logits", title = "Gain in Skills and Knowledge - Loop"
  , filename = "report/learning-outcome/effective-participants/NonParametricAnalysis.xlsx"
  , override = T
  , ylim = NULL, levels = c('non-gamified','ont-gamified')
)

