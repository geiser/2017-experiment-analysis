
#install.packages('dplyr')
#install.packages('RMySQL')
#install.packages('reshape')
#install.packages("devtools")
#devtools::install_github("mattsigal/careless")

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)
library(careless)

## gather data from MySQL
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

participants <- dbGetQuery(con, "
SELECT u.id as `UserID`
  , CAST(uid.data AS UNSIGNED) as `Nro USP`
  , (CASE oj1.name
      WHEN 'Intervention2' THEN 'ont-gamified'
      WHEN 'Control2' THEN 'non-gamified'
      ELSE ''
    END) AS `Type`
  , oj2.name AS `Group`
  , (CASE oj3.name
      WHEN 'Mestre2' THEN 'Master'
      WHEN 'Aprendiz2' THEN 'Apprentice'
      ELSE ''
    END) AS `CLRole`
  , (CASE oj4.name
      WHEN 'Achiever2' THEN 'Yee Achiever'
      WHEN 'Socializer2' THEN 'Yee Socializer'
      ELSE ''
    END) AS `PlayerRole`
FROM mdl_user u
INNER JOIN mdl_user_info_data uid ON uid.userid = u.id
INNER JOIN mdl_user_enrolments ue ON ue.userid = u.id
INNER JOIN mdl_enrol e ON e.id = ue.enrolid
INNER JOIN (SELECT gm1.userid, g1.name
            FROM mdl_groups_members gm1
            INNER JOIN mdl_groups g1 ON g1.id = gm1.groupid
            WHERE g1.name IN ('Control2', 'Intervention2')) oj1 ON oj1.userid = u.id
INNER JOIN (SELECT gm2.userid, g2.name
            FROM mdl_groups_members gm2
            INNER JOIN mdl_groups g2 ON g2.id = gm2.groupid
            INNER JOIN mdl_groupings_groups grg2 ON grg2.groupid = g2.id
            INNER JOIN mdl_groupings gr2 ON gr2.id = grg2.groupingid
            WHERE gr2.name IN ('Grouping2')) oj2 ON oj2.userid = u.id
INNER JOIN (SELECT gm3.userid, g3.name
            FROM mdl_groups_members gm3
            INNER JOIN mdl_groups g3 ON g3.id = gm3.groupid
            INNER JOIN mdl_groupings_groups grg3 ON grg3.groupid = g3.id
            INNER JOIN mdl_groupings gr3 ON gr3.id = grg3.groupingid
            WHERE gr3.name IN ('CL Roles2')) oj3 ON oj3.userid = u.id
LEFT JOIN (SELECT gm4.userid, g4.name
            FROM mdl_groups_members gm4
            INNER JOIN mdl_groups g4 ON g4.id = gm4.groupid
            INNER JOIN mdl_groupings_groups grg4 ON grg4.groupid = g4.id
            INNER JOIN mdl_groupings gr4 ON gr4.id = grg4.groupingid
            WHERE gr4.name IN ('CL Player Roles2') AND g4.name IN ('Achiever2', 'Socializer2')) oj4 ON oj4.userid = u.id
WHERE e.courseid = 8")
participants <- dplyr::mutate(participants, Group = iconv(participants$Group, from = "latin1", to = "UTF-8"))

dbDisconnect(con)

## gather data from csv files
respIMI <- read_csv('2017-RespMotivation02.csv')

careless(select(respIMI, starts_with("Item")), append=FALSE) 
respIMI <- respIMI[-c(22,47,53,59,63),]
respIMI <- respIMI[-c(25,60),]

activities <- read_csv('2017-CLActivity02.csv')

## combine data for analysis
dat <- merge(
select(participants
       , starts_with("UserID")
       , starts_with("Type")
       , starts_with("CLRole")
),
select(activities
       , starts_with("UserID")
       , starts_with("ParticipationLevel")
), by = "UserID")
dat <- merge(dat, select(respIMI, starts_with("UserID"), starts_with("Item")), by = "UserID")

###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################

library(psych)
library(lavaan)

## validating sampling adequacy
KMO(cor(select(dat, starts_with("Item"))))

## factorial analysis with nfactor=3
fa(select(dat, starts_with("Item")), nfactors = 3)
fa(select(dat, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item08")
          , -starts_with("Item10")), nfactors = 3)

## cfa 
model <- '
f1 =~ Item01+Item04+Item12+Item20+Item23
f2 =~ Item06+Item11+Item18+Item25
f3 =~ Item02+Item09+Item14+Item24+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item12+Item20+Item23
         +Item06+Item11+Item18+Item25
         +Item02+Item09+Item14+Item24+Item26
         , factors=3, data=dat)

model <- '
f1 =~ Item01+Item04+Item12+Item20
f2 =~ Item06+Item11+Item25
f3 =~ Item02+Item09+Item14+Item24+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item12+Item20
         +Item06+Item11+Item25
         +Item02+Item09+Item14+Item24+Item26
         , factors=3, data=dat)


## factorial analysis with nfactor=2
fa(select(dat, starts_with("Item")), nfactors = 2)
fa(select(dat, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

fa(select(dat, starts_with("Item")
          # remove Attention items falling into Satisfaction
          , -starts_with("Item07")
          , -starts_with("Item08")
          , -starts_with("Item13")
          , -starts_with("Item15")
          , -starts_with("Item17")
          , -starts_with("Item21")
          # remove unloading items
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

fa(select(dat, starts_with("Item")
          # remove Relevance items falling into Satisfaction
          , -starts_with("Item02")
          , -starts_with("Item06")
          # remove Relevance items falling into Attention
          , -starts_with("Item16")
          , -starts_with("Item22")
          # remove Attention items falling into Satisfaction
          , -starts_with("Item07")
          , -starts_with("Item08")
          , -starts_with("Item13")
          , -starts_with("Item15")
          , -starts_with("Item17")
          , -starts_with("Item21")
          # remove unloading items
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

## cfa 
model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25+Item26
         , factors=2, data=dat)

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item11+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25
         , factors=2, data=dat)

fa(select(dat
, starts_with("Item01"), starts_with("Item04")
, starts_with("Item05"), starts_with("Item12")
, starts_with("Item19"), starts_with("Item20")
, starts_with("Item09"), starts_with("Item11")
, starts_with("Item14"), starts_with("Item24")
, starts_with("Item25")
), nfactors = 2)

##
rdat <- select(dat, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("ParticipationLevel")
, starts_with("Item01"), starts_with("Item04")
, starts_with("Item05"), starts_with("Item12")
, starts_with("Item19"), starts_with("Item20")
, starts_with("Item09"), starts_with("Item11")
, starts_with("Item14"), starts_with("Item24")
, starts_with("Item25")
)

## reliability analysis - Intrinsic Motivation
inv_keys = c()
alpha <- alpha(select(rdat, starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Attention
inv_keys = c()
alpha <- alpha(select(rdat
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",]
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",]
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Satisfaction
inv_keys = c()
alpha <- alpha(select(rdat
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",]
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",]
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", ">>", "non-gamified", "\n"); alpha$total


###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdat <- dplyr::mutate(rdat
                      , `Attention` = (rdat$Item12
                                       +rdat$Item20
                                       +rdat$Item19
                                       +rdat$Item01
                                       +rdat$Item05
                                       +rdat$Item04)/6
                      , `Satisfaction` = (rdat$Item14
                                          +rdat$Item24
                                          +rdat$Item11
                                          +rdat$Item25
                                          +rdat$Item09)/5
)
rdat <- dplyr::mutate(rdat
                      , `Level of Motivation` = (rdat$Attention*6
                                                  +rdat$Satisfaction*5)/11
)

## performing tests in each factor
wt <- wilcox_analysis(rdat$Type, rdat$`Attention`, alternative = "less", title = "Attention")
cat("Attention", "\n"); wt
wt <- wilcox_analysis(rdat$Type, rdat$`Satisfaction`, alternative = "less", title = "Satisfaction")
cat("Satisfaction", "\n"); wt

wt <- wilcox_analysis(rdat$Type, rdat$`Level of Motivation`, alternative = "less", title = "Level of Motivation")
cat("Level of Motivation", "\n"); wt

