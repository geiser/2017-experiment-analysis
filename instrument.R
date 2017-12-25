
pos_csv <- read_csv("PostestData.csv")
pos_dat <- pos_csv[which(pos_csv$nviewPA>0 | pos_csv$nviewPB>0 | pos_csv$nviewPC>0 | pos_csv$nviewPD>0),]
pos_dat <- score_programming_tasks(pos_dat, keys = c("PA", "PB", "PC", "PD"))

user_ids <- intersect(pre_dat$UserID, pos_dat$UserID)
pre_dat <- pre_dat[which(pre_dat$UserID %in% user_ids),]
pos_dat <- pos_dat[which(pos_dat$UserID %in% user_ids),]
  
# get test analyse modules (TAMs) for programming modules
pos_resp <- get_TAMs_for_programming_tasks(
  pos_dat, list(PA=c("PAs3", "PAs2", "PAs1", "PAs0")
                , PB=c("PBs3", "PBs2", "PBs1", "PBs0")
                , PC=c("PCs3", "PCs2", "PCs1", "PCs0")
                , PD=c("PDs1", "PDs0")))

pre_tam <- pre_resp$unidimensional$`P1s0+P2s2+P3s0` # removing the P4 question with 
pos_tam <- pos_resp$unidimensional$`PAs0+PBs2+PCs0+PDs1`

View(pre_resp$information)
View(pos_resp$information)

unidim_models_pre <- filter_by_test_unidimensionality(all_models_pre$tam_models, step = 0.05)
fitting_models_pre <- filter_by_test_task_model_fit(unidim_models_pre$unidimensional_models, strict = TRUE)

tam_mod_pre <- fitting_models_pre$taskfit_models$`P1s3+P2s3+P3s0+P4s0`
wle_mod_pre <- tam.mml.wle(tam_mod_pre)
dat_theta_pre <- data.frame(UserID=dat_pre$UserID, Gamified=dat_pre$Gamified, tam_mod_pre$resp, ptheta = wle_mod_pre$theta, pscore = wle_mod_pre$PersonScores)
quantiles_pre <- quantile(wle_mod_pre$theta, c(.33, .5, .67))

# for beginner
dat_beginner_pre <- dat_theta_pre[which(dat_theta_pre$ptheta <= quantiles_pre[1]),]
tam_mod_beginner_pre <- tam.mml.2pl(select(dat_beginner_pre, starts_with("P")), xsi.fixed = tam_mod_pre$xsi.fixed.estimated)
wle_mod_beginner_pre <- tam.mml.wle(tam_mod_beginner_pre)

#for advanced
dat_advanced_pre <- dat_theta_pre[which(dat_theta_pre$ptheta >= quantiles_pre[3]),]
tam_mod_advanced_pre <- tam.mml.2pl(select(dat_advanced_pre, starts_with("P")), xsi.fixed = tam_mod_pre$xsi.fixed.estimated)
wle_mod_advanced_pre <- tam.mml.wle(tam_mod_advanced_pre)
View(cbind(dat_advanced_pre, wle_mod_advanced_pre$theta))

## PosTest ##

unidim_models_pos <- filter_by_test_unidimensionality(all_models_pos$tam_models, task_model_fit = TRUE)
fitting_models_pos <- filter_by_test_task_model_fit(unidim_models_pos$unidimensional_models, strict = TRUE)

tam_mod_pos <- fitting_models_pos$taskfit_models$`PAs3+PBs2+PCs0+PDs0`
wle_mod_pos <- tam.mml.wle(tam_mod_pos)
dat_theta_pos <- data.frame(UserID=dat_pos$UserID, Gamified=dat_pos$Gamified, tam_mod_pos$resp, ptheta = wle_mod_pos$theta, pscore = wle_mod_pos$PersonScores)
quantiles_pos <- quantile(wle_mod_pos$theta, c(.33, .5, .67))

# ids for 3 groups
beginner_ids <- dat_theta_pre$UserID[which(dat_theta_pre$ptheta <= quantiles_pre[1])]
intermediate_ids <- dat_theta_pre$UserID[which(dat_theta_pre$ptheta > quantiles_pre[1] & dat_theta_pre$ptheta < quantiles_pre[3])]
advanced_ids <- dat_theta_pre$UserID[which(dat_theta_pre$ptheta >= quantiles_pre[3])]

# for beginners
dat_beginner_pos <- dat_theta_pos[which(dat_theta_pos$UserID %in% beginner_ids),]
tam_mod_beginner_pos <- tam.mml.2pl(select(dat_beginner_pos, starts_with("P", ignore.case = FALSE)), xsi.fixed = tam_mod_pos$xsi.fixed.estimated)
wle_mod_beginner_pos <- tam.mml.wle(tam_mod_beginner_pos)
View(cbind(dat_beginner_pos, wle_mod_beginner_pos$theta))

# for intermediate
dat_intermediate_pos <- dat_theta_pos[which(dat_theta_pos$UserID %in% intermediate_ids),]

# for advanced
dat_advanced_pos <- dat_theta_pos[which(dat_theta_pos$UserID %in% advanced_ids),]
tam_mod_advanced_pos <- tam.mml.2pl(select(dat_advanced_pos, starts_with("P", ignore.case = FALSE), -starts_with("PD", ignore.case = FALSE))
                                    , xsi.fixed = tam_mod_pos$xsi.fixed.estimated[-which(rownames(tam_mod_pos$xsi.fixed.estimated) %in% "PDs0_Cat1"),])
wle_mod_advanced_pos <- tam.mml.wle(tam_mod_advanced_pos)
View(cbind(dat_advanced_pos, wle_mod_advanced_pos$theta))


dat_theta_pre[which(dat_theta_pre$ptheta <= quantiles_pre[1]),]

dat_beginner_pos <- dat_theta_pos[which(dat_theta_pre$ptheta <= quantiles_pre[1]),]

tam_mod_beginner_pre <- tam.mml.2pl(select(dat_beginner_pre, starts_with("P")), xsi.fixed = tam_mod_pre$xsi.fixed.estimated)
wle_mod_beginner_pre <- tam.mml.wle(tam_mod_beginner_pre)


#####################################################################################################
user_ids <- intersect(dat_theta_pos$UserID, dat_theta_pre$UserID)
dat_ancova_pos <- dat_theta_pos[which(dat_theta_pos$UserID %in% user_ids),]
dat_ancova_pre <- dat_theta_pre[which(dat_theta_pre$UserID %in% user_ids),]

## Stage I: Independent Time 1 & 2 Analyses

# abilities
t.test((dat_ancova_pos$ptheta - dat_ancova_pre$ptheta)~dat_ancova_pos$Gamified, alternative = "two.sided")
abil_lm <- lm(dat_ancova_pos$ptheta ~ dat_ancova_pos$Gamified + dat_ancova_pre$ptheta)
summary(abil_lm)

plot(dat_ancova_pre$ptheta, dat_ancova_pos$ptheta, ask=FALSE)
abline(lm(dat_ancova_pos$ptheta ~ dat_ancova_pre$ptheta))

# difficulties non applicable items are not same
#tam_mod_pre$item$xsi.item 
#tam_mod_beginner_pos$item$xsi.item

# scores
t.test((dat_ancova_pos$pscore - dat_ancova_pre$pscore)~dat_ancova_pos$Gamified, alternative = "two.sided")
scor_lm <- lm(dat_ancova_pos$pscore ~ dat_ancova_pos$Gamified + dat_ancova_pre$pscore)
summary(scor_lm)

plot(dat_ancova_pre$pscore, dat_ancova_pos$pscore, ask=FALSE)
abline(lm(dat_ancova_pos$pscore ~ dat_ancova_pre$pscore))


## Stage II: Stack: Item Global, Person Time 1 & 2 Analyses
dat_ancova_glob <- bind_rows(dat_ancova_pre, dat_ancova_pos, .id ="Time")
tam_mod_glob <- tam.mml.2pl(select(dat_ancova_glob, starts_with("P", ignore.case = FALSE)))
wle_mod_glob <- tam.mml.wle(tam_mod_glob)
plot(tam_mod_glob, ask = FALSE)

# abilities
theta_pre <- wle_mod_glob$theta[which(dat_ancova_glob$Time == 1)]
theta_pos <- wle_mod_glob$theta[which(dat_ancova_glob$Time == 2)]

t.test((theta_pos - theta_pre)~dat_ancova_glob$Gamified[1:length(theta_pre)], alternative = "two.sided")
s2_abil_lm <- lm(theta_pos ~ dat_ancova_glob$Gamified[1:length(theta_pre)] + theta_pre)
summary(s2_abil_lm) # plot(s2_abil_lm, ask = FALSE)

plot(theta_pre, theta_pos, ask=FALSE)
abline(lm(theta_pos ~ theta_pre)) # abline(lm(theta_pre ~ theta_pos))


## Stage III: Time 2 Persons in Time 1 Frame of Reference
  
tam_mod_s3_pre <- tam.mml.2pl(select(dat_ancova_glob[which(dat_ancova_glob$Time == 1),]
                                     , matches("P[1-4]", ignore.case = FALSE))
                              , B.fixed = tam_mod_glob$B.fixed.estimated[1:20,])
wle_mod_s3_pre <- tam.mml.wle(tam_mod_s3_pre, WLE = FALSE)
plot(tam_mod_s3_pre, ask = FALSE)

tam_mod_s3_pos <- tam.mml.2pl(select(dat_ancova_glob[which(dat_ancova_glob$Time == 2),]
                                     , matches("P[A-D]", ignore.case = FALSE))
                              , B.fixed = cbind(tam_mod_glob$B.fixed.estimated[21:40,1]-4
                                                , tam_mod_glob$B.fixed.estimated[21:40,2:4]))
wle_mod_s3_pos <- tam.mml.wle(tam_mod_s3_pos, WLE = FALSE)
plot(tam_mod_s3_pos, ask = FALSE)


# abilities
theta_pre <- wle_mod_s3_pre$theta
theta_pos <- wle_mod_s3_pos$theta
gamified <- as.vector(base::split(dat_ancova_glob$Gamified, c(1,2))[[1]])

t.test((theta_pos - theta_pre)~gamified, alternative = "less")
s3_abil_lm <- lm(theta_pos ~ gamified + theta_pre)
summary(s3_abil_lm) # plot(s2_abil_lm, ask = FALSE)

plot(theta_pre, theta_pos, ask=FALSE)
abline(lm(theta_pos ~ theta_pre)) # abline(lm(theta_pre ~ theta_pos))


View(tam_mod_glob$B.fixed.estimated)
View(tam_mod_glob$B)


View(cbind(wle_mod_glob$PersonScores, wle_mod_s3_pre$PersonScores))

View(bind_cols(tam_mod_s3_pre$person, tam_mod_glob$person[1:29,]))
