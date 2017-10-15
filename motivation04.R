
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
      WHEN 'Intervention3' THEN 'ont-gamified'
      WHEN 'Control3' THEN 'w/o-gamified'
      ELSE ''
    END) AS `Type`
  , oj2.name AS `Group`
  , (CASE oj3.name
      WHEN 'Mestre3' THEN 'Master'
      WHEN 'Aprendiz3' THEN 'Apprentice'
      ELSE ''
    END) AS `CLRole`
  , (CASE oj4.name
      WHEN 'Achiever3' THEN 'Yes'
      ELSE ''
    END) AS `Achiever`
  , (CASE oj5.name
      WHEN 'Socializer3' THEN 'Yes'
      ELSE ''
    END) AS `Socializer`
FROM mdl_user u
INNER JOIN mdl_user_info_data uid ON uid.userid = u.id
INNER JOIN mdl_user_enrolments ue ON ue.userid = u.id
INNER JOIN mdl_enrol e ON e.id = ue.enrolid
INNER JOIN (SELECT gm1.userid, g1.name
            FROM mdl_groups_members gm1
            INNER JOIN mdl_groups g1 ON g1.id = gm1.groupid
            WHERE g1.name IN ('Control3', 'Intervention3')) oj1 ON oj1.userid = u.id
INNER JOIN (SELECT gm2.userid, g2.name
            FROM mdl_groups_members gm2
            INNER JOIN mdl_groups g2 ON g2.id = gm2.groupid
            INNER JOIN mdl_groupings_groups grg2 ON grg2.groupid = g2.id
            INNER JOIN mdl_groupings gr2 ON gr2.id = grg2.groupingid
            WHERE gr2.name IN ('Grouping3')) oj2 ON oj2.userid = u.id
INNER JOIN (SELECT gm3.userid, g3.name
            FROM mdl_groups_members gm3
            INNER JOIN mdl_groups g3 ON g3.id = gm3.groupid
            INNER JOIN mdl_groupings_groups grg3 ON grg3.groupid = g3.id
            INNER JOIN mdl_groupings gr3 ON gr3.id = grg3.groupingid
            WHERE gr3.name IN ('CL Roles3')) oj3 ON oj3.userid = u.id
LEFT JOIN (SELECT gm4.userid, g4.name
            FROM mdl_groups_members gm4
            INNER JOIN mdl_groups g4 ON g4.id = gm4.groupid
            INNER JOIN mdl_groupings_groups grg4 ON grg4.groupid = g4.id
            INNER JOIN mdl_groupings gr4 ON gr4.id = grg4.groupingid
            WHERE g4.name IN ('Achiever3')) oj4 ON oj4.userid = u.id
LEFT JOIN (SELECT gm5.userid, g5.name
            FROM mdl_groups_members gm5
            INNER JOIN mdl_groups g5 ON g5.id = gm5.groupid
            INNER JOIN mdl_groupings_groups grg5 ON grg5.groupid = g5.id
            INNER JOIN mdl_groupings gr5 ON gr5.id = grg5.groupingid
            WHERE g5.name IN ('Socializer3')) oj5 ON oj5.userid = u.id
WHERE e.courseid = 8")
participants <- dplyr::mutate(participants, Group = iconv(participants$Group, from = "latin1", to = "UTF-8"))
participants <- dplyr::mutate(participants, PlayerRole = if_else(
  participants$Achiever == "Yes" & participants$Socializer == "Yes"
  , true = "Social Achiever"
  , false = if_else(participants$Achiever == "Yes"
                    , true = "Yee Achiever"
                    , false = if_else(participants$Socializer == "Yes"
                                      , true = "Yee Socializer"
                                      , false = ""))))

resp <- dbGetQuery(con, "
SELECT qr.username AS `UserID`
, qrr.rank+1 AS `value`
, qrr.choice_id AS `item`
FROM `mdl_course_modules` cm
INNER JOIN `mdl_questionnaire` q ON cm.instance = q.id
INNER JOIN `mdl_questionnaire_question` qq ON qq.survey_id = q.id
INNER JOIN `mdl_questionnaire_quest_choice` qqc ON qqc.question_id = qq.id
INNER JOIN `mdl_questionnaire_response_rank` qrr ON qrr.choice_id = qqc.id
INNER JOIN `mdl_questionnaire_response` qr ON qr.id = qrr.response_id
WHERE cm.id=549")
resp <- cast(resp, UserID ~ item)
careless(select(resp, -starts_with("UserID")), append=FALSE) 
resp <- resp[-c(8,21,34,55),] # careless >24

legend <- dbGetQuery(con, "
SELECT qqc.id AS `ID`
, qq.id AS `qid`
, qqc.content AS `content`
FROM `mdl_course_modules` cm
INNER JOIN `mdl_questionnaire` q ON cm.instance = q.id
INNER JOIN `mdl_questionnaire_question` qq ON qq.survey_id = q.id
INNER JOIN `mdl_questionnaire_quest_choice` qqc ON qqc.question_id = qq.id
WHERE cm.id=549")
legend <- dplyr::mutate(legend, content = iconv(legend$content, from = "latin1", to = "UTF-8"))

dbDisconnect(con)

respIMI <- mutate(resp
                  , Item01=0+resp$`345`
                  , Item02=0+resp$`346`
                  , Item03=0+resp$`347`
                  , Item04=0+resp$`348`
                  , Item05=0+resp$`349`
                  , Item06=0+resp$`350`
                  , Item07=0+resp$`351`
                  , Item08=0+resp$`352`
                  , Item09=0+resp$`353`
                  , Item10=0+resp$`354`
                  , Item11=0+resp$`355`
                  , Item12=0+resp$`388`
                  , Item13=0+resp$`390`
                  , Item14=0+resp$`391`
                  , Item15=0+resp$`392`
                  , Item16=0+resp$`394`
                  , Item17=0+resp$`395`
                  , Item18=0+resp$`396`
                  , Item19=0+resp$`397`
                  , Item20=0+resp$`398`
                  , Item21=0+resp$`399`
                  , Item22=0+resp$`400`
                  , Item23=0+resp$`401`
                  , Item24=0+resp$`402`
)
respIMI <- select(respIMI, starts_with("UserID"), starts_with("Item"))

## gather data from csv files
activities <- read_csv('2017-CLActivity03.csv')

## combine data for analysis
datIMI <- merge(
  select(participants
         , starts_with("UserID")
         , starts_with("Type")
         , starts_with("CLRole")
         , starts_with("PlayerRole")
  ),
  select(activities
         , starts_with("UserID")
         , starts_with("ParticipationLevel")
  ), by = "UserID")
datIMI <- merge(datIMI, select(respIMI, starts_with("UserID"), starts_with("Item")), by = "UserID")

###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################

library(psych)

## validating sampling adequacy
KMO(cor(select(datIMI, starts_with("Item"))))

## factorial analysis with nfactor=4
fa(select(datIMI, starts_with("Item")), nfactors = 4)

## cfa 
model <- '
f1 =~ Item08+Item09+Item10+Item11+Item12+Item15+Item16+Item21+Item24
f2 =~ Item03+Item05+Item07+Item13+Item17+Item18+Item20
f3 =~ Item02+Item04+Item06+Item23
f4 =~ Item01+Item14+Item19+Item22
'
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item08+Item09+Item10+Item11+Item12+Item15+Item16+Item21+Item24
         +Item03+Item05+Item07+Item13+Item17+Item18+Item20
         +Item02+Item04+Item06+Item23
         +Item01+Item14+Item19+Item22
         , factors=4, data=datIMI)

model <- '
f1 =~ Item08+Item09+Item11+Item12+Item21+Item24
f2 =~ Item03+Item05+Item13+Item18+Item20
f3 =~ Item02+Item04+Item06+Item23
f4 =~ Item01+Item14+Item19+Item22
' # removing items falling in wrong category
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

fa(select(datIMI
, starts_with("Item08"), starts_with("Item09"), starts_with("Item11"), starts_with("Item12"), starts_with("Item21"), starts_with("Item24")
, starts_with("Item03"), starts_with("Item05"), starts_with("Item13"), starts_with("Item18"), starts_with("Item20")
, starts_with("Item02"), starts_with("Item04"), starts_with("Item06"), starts_with("Item23")
, starts_with("Item01"), starts_with("Item14"), starts_with("Item19"), starts_with("Item22")
), nfactors = 4)

##
rdatIMI <- select(datIMI
, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("PlayerRole")
, starts_with("ParticipationLevel")
, starts_with("Item08"), starts_with("Item09"), starts_with("Item11"), starts_with("Item12"), starts_with("Item21"), starts_with("Item24")
, starts_with("Item03"), starts_with("Item05"), starts_with("Item13"), starts_with("Item18"), starts_with("Item20")
, starts_with("Item02"), starts_with("Item04"), starts_with("Item06"), starts_with("Item23")
, starts_with("Item01"), starts_with("Item14"), starts_with("Item19"), starts_with("Item22")
)

## reliability analysis - Intrinsic Motivation
inv_keys = c(
  "Item05", "Item20", "Item18", "Item13", "Item03"
  , "Item02",  "Item06", "Item04"
  , "Item01",  "Item19")
alpha <- alpha(select(rdatIMI, starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Interest/Enjoyment
inv_keys = c()
alpha <- alpha(select(rdatIMI
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Perceived Choice
inv_keys = c()
alpha <- alpha(select(rdatIMI
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Pressure/Tension
inv_keys = c("Item23")
alpha <- alpha(select(rdatIMI
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Effort/Importance
inv_keys = c("Item01", "Item19")
alpha <- alpha(select(rdatIMI
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", ">>", "w/o-gamified", "\n"); alpha$total

###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMI <- dplyr::mutate(rdatIMI
, `Interest/Enjoyment` = (rdatIMI$Item08
                          +rdatIMI$Item09
                          +rdatIMI$Item11
                          +rdatIMI$Item12
                          +rdatIMI$Item21
                          +rdatIMI$Item24)/6
, `Perceived Choice` = (40-(rdatIMI$Item03
                            +rdatIMI$Item05
                            +rdatIMI$Item13
                            +rdatIMI$Item18
                            +rdatIMI$Item20))/5
, `Pressure/Tension` = (rdatIMI$Item02
                        +rdatIMI$Item04
                        +rdatIMI$Item06
                        +8-rdatIMI$Item23)/4
, `Effort/Importance` = (rdatIMI$Item14
                         +rdatIMI$Item22
                         +16-(rdatIMI$Item01
                              +rdatIMI$Item19))/4
)

rdatIMI <- dplyr::mutate(rdatIMI
, `Intrinsic Motivation` = (6*rdatIMI$`Interest/Enjoyment`
                            +5*rdatIMI$`Perceived Choice`
                            +4*rdatIMI$`Effort/Importance`
                            +32-4*rdatIMI$`Pressure/Tension`)/19
)

## performing tests in each factor IMI
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Interest/Enjoyment`
, alternative = "greater", title = "Interest/Enjoyment", inv.col = TRUE)
cat("Interest/Enjoyment", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Perceived Choice`
, alternative = "greater", title = "Perceived Choice", inv.col = TRUE)
cat("Perceived Choice", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Pressure/Tension`
, alternative = "less", title = "Pressure/Tension", inv.col = TRUE)
cat("Pressure/Tension", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Effort/Importance`
, alternative = "greater", title = "Effort/Importance", inv.col = TRUE)
cat("Effort/Importance", "\n"); wt

wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Intrinsic Motivation`
, alternative = "greater", title = "Intrinsic Motivation", inv.col = TRUE)
cat("Intrinsic Motivation", "\n"); wt

###############################################################
## ARCS IMMS                                                 ##
###############################################################

respIMMS <- mutate(resp
                   , Item01=0+resp$`332`
                   , Item02=0+resp$`333`
                   , Item03=0+resp$`334`
                   , Item04=0+resp$`335`
                   , Item05=0+resp$`336`
                   , Item06=0+resp$`337`
                   , Item07=0+resp$`338`
                   , Item08=0+resp$`339`
                   , Item09=0+resp$`340`
                   , Item10=0+resp$`341`
                   , Item11=0+resp$`342`
                   , Item12=0+resp$`343`
                   , Item13=0+resp$`344`
                   , Item14=0+resp$`389`
                   , Item15=0+resp$`393`
                   , Item16=0+resp$`403`
                   , Item17=0+resp$`404`
                   , Item18=0+resp$`405`
                   , Item19=0+resp$`406`
                   , Item20=0+resp$`407`
                   , Item21=0+resp$`408`
                   , Item22=0+resp$`409`
                   , Item23=0+resp$`410`
                   , Item24=0+resp$`411`
                   , Item25=0+resp$`412`
)
respIMMS <- select(respIMMS, starts_with("UserID"), starts_with("Item"))

## gather data from csv files
activities <- read_csv('2017-CLActivity03.csv')

## combine data for analysis
datIMMS <- merge(
  select(participants
         , starts_with("UserID")
         , starts_with("Type")
         , starts_with("CLRole")
         , starts_with("PlayerRole")
  ),
  select(activities
         , starts_with("UserID")
         , starts_with("ParticipationLevel")
  ), by = "UserID")
datIMMS <- merge(datIMMS, select(respIMMS, starts_with("UserID"), starts_with("Item")), by = "UserID")


###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################

library(psych)

## validating sampling adequacy
KMO(cor(select(datIMMS, starts_with("Item"))))

## factorial analysis with nfactor=3
fa(select(datIMMS, starts_with("Item")), nfactors = 3)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item10")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")), nfactors = 3)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item12")
          , -starts_with("Item19")
          , -starts_with("Item10")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")), nfactors = 3)

## cfa
model <- '
f1 =~ Item04+Item07+Item08+Item11+Item13+Item14+Item18+Item20+Item25
f2 =~ Item01+Item02+Item05+Item17+Item24
f3 =~ Item03+Item06+Item09+Item21+Item23
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item04+Item07+Item08+Item11+Item13+Item14+Item18+Item20+Item25
         +Item01+Item02+Item05+Item17+Item24
         +Item03+Item06+Item09+Item21+Item23
         , factors=3, data=datIMMS)

factanal(~Item01+Item02+Item05+Item08+Item17+Item24
         +Item11+Item18+Item20+Item25
         +Item03+Item06+Item09+Item21+Item23
         , factors=3, data=datIMMS)

model <- '
f1 =~ Item01+Item02+Item05+Item08+Item17+Item24
f2 =~ Item11+Item18+Item20+Item25
f3 =~ Item03+Item06+Item09+Item21+Item23
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

factanal(~Item01+Item02+Item05+Item08+Item17+Item24
         +Item03+Item06+Item09+Item21+Item23
         +Item18+Item25
         , factors=3, data=datIMMS)

model <- '
f1 =~ Item01+Item02+Item05+Item08+Item17+Item24
f2 =~ Item03+Item06+Item09+Item21+Item23
f3 =~ Item18+Item25
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

## factorial analysis with nfactor=2
fa(select(datIMMS, starts_with("Item")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item06")
          , -starts_with("Item19")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item17")
          , -starts_with("Item06")
          , -starts_with("Item19")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

## cfa
model <- '
f1 =~ Item18+Item25+Item20+Item07+Item13+Item04+Item10+Item08
f2 =~ Item01+Item02+Item05+Item21+Item24
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item07+Item13+Item04+Item10+Item08
         +Item01+Item02+Item05+Item21+Item24
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item08
f2 =~ Item01+Item02+Item05+Item21
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item08
         +Item01+Item02+Item05+Item21
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item07
f2 =~ Item01+Item02+Item05+Item21
'
fit <- cfa(model, data=datIMMS, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item07
         +Item01+Item02+Item05+Item21
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item07+Item13
f2 =~ Item01+Item02+Item05+Item21
' # removing relevance items
fit <- cfa(model, data=datIMMS, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

fa(select(datIMMS
          , starts_with("Item18")
          , starts_with("Item25")
          , starts_with("Item20")
          , starts_with("Item07")
          , starts_with("Item13")
          , starts_with("Item01")
          , starts_with("Item02")
          , starts_with("Item05")
          , starts_with("Item21")), nfactors = 2)

##
rdatIMMS <- select(datIMMS
, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("ParticipationLevel"), starts_with("PlayerRole")
, starts_with("Item18")
, starts_with("Item25")
, starts_with("Item20")
, starts_with("Item07")
, starts_with("Item13")
, starts_with("Item01")
, starts_with("Item02")
, starts_with("Item05")
, starts_with("Item21")
)

## reliability analysis - Level of Motivation
inv_keys = c("Item21")
alpha <- alpha(select(rdatIMMS, starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Attention
inv_keys = c()
alpha <- alpha(select(rdatIMMS
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",]
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",]
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Satisfaction
inv_keys = c("Item21")
alpha <- alpha(select(rdatIMMS
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",]
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",]
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", ">>", "w/o-gamified", "\n"); alpha$total

###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Attention` = (rdatIMMS$Item18
                                           +rdatIMMS$Item25
                                           +rdatIMMS$Item20
                                           +rdatIMMS$Item07
                                           +rdatIMMS$Item13)/5
                          , `Satisfaction` = (rdatIMMS$Item01
                                              +rdatIMMS$Item02
                                              +rdatIMMS$Item05
                                              +8-rdatIMMS$Item21)/4
)
rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Level of Motivation` = (rdatIMMS$Attention*5
                                                     +rdatIMMS$Satisfaction*4)/9
)

## performing tests in each factor
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Attention`
                      , alternative = "less", title = "Attention", inv.col = T)
cat("Attention", "\n"); wt
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Satisfaction`
                      , alternative = "greater", title = "Satisfaction", inv.col = T)
cat("Satisfaction", "\n"); wt

wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Level of Motivation`
                      , alternative = "greater", title = "Level of Motivation", inv.col = T)
cat("Level of Motivation", "\n"); wt

