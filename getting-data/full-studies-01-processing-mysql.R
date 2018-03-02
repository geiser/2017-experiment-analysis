wants <- c('readr', 'dplyr', 'RMySQL', 'reshape')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

##########################################################################
## Participants for Study01, Study02 and Study03                        ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## Experiment01
participants <- dbGetQuery(
  con,
  "SELECT u.id as `UserID`
  , CAST(uid.data AS UNSIGNED) as `NroUSP`
  , (CASE oj1.name
  WHEN 'Intervention1' THEN 'ont-gamified'
  WHEN 'Control1' THEN 'non-gamified'
  ELSE ''
  END) AS `Type`
  , oj2.name AS `CLGroup`
  , (CASE oj3.name
  WHEN 'Mestre1' THEN 'Master'
  WHEN 'Aprendiz1' THEN 'Apprentice'
  ELSE ''
  END) AS `CLRole`
  , (CASE oj4.name
  WHEN 'Achiever1' THEN 'Yee Achiever'
  WHEN 'Socializer1' THEN 'Yee Socializer'
  ELSE ''
  END) AS `PlayerRole`
  FROM mdl_user u
  INNER JOIN mdl_user_info_data uid ON uid.userid = u.id
  INNER JOIN mdl_user_enrolments ue ON ue.userid = u.id
  INNER JOIN mdl_enrol e ON e.id = ue.enrolid
  INNER JOIN (SELECT gm1.userid, g1.name
  FROM mdl_groups_members gm1
  INNER JOIN mdl_groups g1 ON g1.id = gm1.groupid
  WHERE g1.name IN ('Control1', 'Intervention1')) oj1 ON oj1.userid = u.id
  INNER JOIN (SELECT gm2.userid, g2.name
  FROM mdl_groups_members gm2
  INNER JOIN mdl_groups g2 ON g2.id = gm2.groupid
  INNER JOIN mdl_groupings_groups grg2 ON grg2.groupid = g2.id
  INNER JOIN mdl_groupings gr2 ON gr2.id = grg2.groupingid
  WHERE gr2.name IN ('Grouping1')) oj2 ON oj2.userid = u.id
  INNER JOIN (SELECT gm3.userid, g3.name
  FROM mdl_groups_members gm3
  INNER JOIN mdl_groups g3 ON g3.id = gm3.groupid
  INNER JOIN mdl_groupings_groups grg3 ON grg3.groupid = g3.id
  INNER JOIN mdl_groupings gr3 ON gr3.id = grg3.groupingid
  WHERE gr3.name IN ('CL Roles1')) oj3 ON oj3.userid = u.id
  LEFT JOIN (SELECT gm4.userid, g4.name
  FROM mdl_groups_members gm4
  INNER JOIN mdl_groups g4 ON g4.id = gm4.groupid
  INNER JOIN mdl_groupings_groups grg4 ON grg4.groupid = g4.id
  INNER JOIN mdl_groupings gr4 ON gr4.id = grg4.groupingid
  WHERE gr4.name IN ('CL Player Roles1') AND g4.name IN ('Achiever1', 'Socializer1')) oj4 ON oj4.userid = u.id
  WHERE e.courseid = 8")
participants <- dplyr::mutate(participants, CLGroup = iconv(participants$CLGroup, from = "latin1", to = "UTF-8"))
if (!file.exists('study01/data/SignedUpParticipants.csv')) {
  write_csv(participants, path = "study01/data/SignedUpParticipants.csv")
}

## Experiment02 - CaseStudy02
participants <- dbGetQuery(
  con,
  "SELECT u.id as `UserID`
  , CAST(uid.data AS UNSIGNED) as `NroUSP`
  , (CASE oj1.name
  WHEN 'Intervention2' THEN 'ont-gamified'
  WHEN 'Control2' THEN 'non-gamified'
  ELSE ''
  END) AS `Type`
  , oj2.name AS `CLGroup`
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
participants <- dplyr::mutate(participants, CLGroup = iconv(participants$CLGroup, from = "latin1", to = "UTF-8"))
if (!file.exists('study02/data/SignedUpParticipants.csv'))  {
  write_csv(participants, path = "study02/data/SignedUpParticipants.csv")
}

## Experiment02 - CaseStudy03
participants <- dbGetQuery(
  con,
  "SELECT u.id as `UserID`
  , CAST(uid.data AS UNSIGNED) as `NroUSP`
  , (CASE oj1.name
  WHEN 'Intervention3' THEN 'ont-gamified'
  WHEN 'Control3' THEN 'w/o-gamified'
  ELSE ''
  END) AS `Type`
  , oj2.name AS `CLGroup`
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
participants <- dplyr::mutate(participants, CLGroup = iconv(participants$CLGroup, from = "latin1", to = "UTF-8"))
participants <- dplyr::mutate(participants, PlayerRole = if_else(
  participants$Achiever == "Yes" & participants$Socializer == "Yes"
  , true = "Social Achiever"
  , false = if_else(participants$Achiever == "Yes"
                    , true = "Yee Achiever"
                    , false = if_else(participants$Socializer == "Yes"
                                      , true = "Yee Socializer"
                                      , false = ""))))
participants <- participants[c('UserID', 'NroUSP', 'Type', 'CLGroup', 'CLRole', 'PlayerRole')]
if (!file.exists('study03/data/SignedUpParticipants.csv'))  {
  write_csv(participants, path = "study03/data/SignedUpParticipants.csv")
}

# close connection
dbDisconnect(con)

# obtain effective participants
a01 <- read_csv('study01/data/CLActivity.csv')
a02 <- read_csv('study02/data/CLActivity.csv')
a03 <- read_csv('study03/data/CLActivity.csv')

userids01 <- subset(a01, a01$ParticipationLevel != "none")$UserID # participated
userids02 <- subset(a02, a02$ParticipationLevel != "none")$UserID
userids03 <- subset(a03, a03$ParticipationLevel != "none")$UserID
userids <- intersect(intersect(userids01, userids02), userids03)

p01 <- read_csv('study01/data/SignedUpParticipants.csv')
p02 <- read_csv('study02/data/SignedUpParticipants.csv')
p03 <- read_csv('study03/data/SignedUpParticipants.csv')

userids01ont <- intersect(userids, subset(p01,  Type == "ont-gamified")$UserID)
userids01non <- intersect(userids, subset(p01,  Type == "non-gamified")$UserID)
userids02ont <- intersect(userids, subset(p02,  Type == "ont-gamified")$UserID)
userids02non <- intersect(userids, subset(p02,  Type == "non-gamified")$UserID)

userids <- union(intersect(userids01non, userids02ont), # effective users
                 intersect(userids01ont, userids02non))

p01 <- p01[p01$UserID %in% userids,]
p02 <- p02[p02$UserID %in% userids,]
p03 <- p03[p03$UserID %in% userids,]

print(design_summary_df <- data.frame(
  'Type.of.CL.session'=c('Study01', 'ont-gamified', 'non-gamified',
                         'Study02', 'ont-gamified', 'non-gamified',
                         'Study03', 'ont-gamified', 'w/o-gamified')
  , 'Master' = c(
    NA
    , paste0(
      nrow(subset(p01, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(p01, Type == "non-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Master"))
      , ")")
    , NA
    , paste0(
      nrow(subset(p02, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a02, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(p02, Type == "non-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a02, Type == "non-gamified" & CLRole == "Master"))
      , ")")
    , NA
    , paste0(
      nrow(subset(p03, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a03, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(p03, Type == "w/o-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(a03, Type == "w/o-gamified" & CLRole == "Master"))
      , ")"))
  , 'Apprentice' = c(
    NA
    , paste0(
      nrow(subset(p01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(p01, Type == "non-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Apprentice"))
      , ")")
    , NA
    , paste0(
      nrow(subset(p02, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a02, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(p02, Type == "non-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a02, Type == "non-gamified" & CLRole == "Apprentice"))
      , ")")
    , NA
    , paste0(
      nrow(subset(p03, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a03, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(p03, Type == "w/o-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(a03, Type == "w/o-gamified" & CLRole == "Apprentice"))
      , ")")
    )
  ))
if (!file.exists('report/exp_design.txt'))  {
  write_csv(design_summary_df, 'report/exp_design.csv')
}

if (!file.exists('study01/data/EffectiveParticipants.csv'))  {
  write_csv(p01, path = "study01/data/EffectiveParticipants.csv")
}
if (!file.exists('study02/data/EffectiveParticipants.csv'))  {
  write_csv(p02, path = "study02/data/EffectiveParticipants.csv")
}
if (!file.exists('study03/data/EffectiveParticipants.csv'))  {
  write_csv(p03, path = "study03/data/EffectiveParticipants.csv")
}

##########################################################################
## Motivation Questionnaire for Study03                                 ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## Study03 (Motivation Questionnaire)

legend <- dbGetQuery(
  con,
  "SELECT qqc.id AS `ID`, qq.id AS `QID`,
  (CASE qqc.id
  WHEN 345 THEN 'IMI' WHEN 346 THEN 'IMI' WHEN 347 THEN 'IMI' WHEN 348 THEN 'IMI'
  WHEN 349 THEN 'IMI' WHEN 350 THEN 'IMI' WHEN 351 THEN 'IMI' WHEN 352 THEN 'IMI'
  WHEN 353 THEN 'IMI' WHEN 354 THEN 'IMI' WHEN 355 THEN 'IMI'
  WHEN 388 THEN 'IMI'
  WHEN 390 THEN 'IMI' WHEN 391 THEN 'IMI' WHEN 392 THEN 'IMI'
  WHEN 394 THEN 'IMI' WHEN 395 THEN 'IMI' WHEN 396 THEN 'IMI' WHEN 397 THEN 'IMI'
  WHEN 398 THEN 'IMI' WHEN 399 THEN 'IMI' WHEN 400 THEN 'IMI' WHEN 401 THEN 'IMI'
  WHEN 402 THEN 'IMI'
  WHEN 332 THEN 'IMMS' WHEN 333 THEN 'IMMS' WHEN 334 THEN 'IMMS' WHEN 335 THEN 'IMMS'
  WHEN 336 THEN 'IMMS' WHEN 337 THEN 'IMMS' WHEN 338 THEN 'IMMS' WHEN 339 THEN 'IMMS'
  WHEN 340 THEN 'IMMS' WHEN 341 THEN 'IMMS' WHEN 342 THEN 'IMMS' WHEN 343 THEN 'IMMS'
  WHEN 344 THEN 'IMMS'
  WHEN 389 THEN 'IMMS'
  WHEN 393 THEN 'IMMS'
  WHEN 403 THEN 'IMMS' WHEN 404 THEN 'IMMS' WHEN 405 THEN 'IMMS' WHEN 406 THEN 'IMMS'
  WHEN 407 THEN 'IMMS' WHEN 408 THEN 'IMMS' WHEN 409 THEN 'IMMS' WHEN 410 THEN 'IMMS'
  WHEN 411 THEN 'IMMS' WHEN 412 THEN 'IMMS'
  ELSE ''
  END) AS `CLGroup`,
  (CASE qqc.id
  WHEN 345 THEN 'Item01' WHEN 346 THEN 'Item02' WHEN 347 THEN 'Item03' WHEN 348 THEN 'Item04'
  WHEN 349 THEN 'Item05' WHEN 350 THEN 'Item06' WHEN 351 THEN 'Item07' WHEN 352 THEN 'Item08'
  WHEN 353 THEN 'Item09' WHEN 354 THEN 'Item10' WHEN 355 THEN 'Item11'
  WHEN 388 THEN 'Item12'
  WHEN 390 THEN 'Item13' WHEN 391 THEN 'Item14' WHEN 392 THEN 'Item15'
  WHEN 394 THEN 'Item16' WHEN 395 THEN 'Item17' WHEN 396 THEN 'Item18' WHEN 397 THEN 'Item19'
  WHEN 398 THEN 'Item20' WHEN 399 THEN 'Item21' WHEN 400 THEN 'Item22' WHEN 401 THEN 'Item23'
  WHEN 402 THEN 'Item24'
  WHEN 332 THEN 'Item01' WHEN 333 THEN 'Item02' WHEN 334 THEN 'Item03' WHEN 335 THEN 'Item04'
  WHEN 336 THEN 'Item05' WHEN 337 THEN 'Item06' WHEN 338 THEN 'Item07' WHEN 339 THEN 'Item08'
  WHEN 340 THEN 'Item09' WHEN 341 THEN 'Item10' WHEN 342 THEN 'Item11' WHEN 343 THEN 'Item12'
  WHEN 344 THEN 'Item13'
  WHEN 389 THEN 'Item14'
  WHEN 393 THEN 'Item15'
  WHEN 403 THEN 'Item16' WHEN 404 THEN 'Item17' WHEN 405 THEN 'Item18' WHEN 406 THEN 'Item19'
  WHEN 407 THEN 'Item20' WHEN 408 THEN 'Item21' WHEN 409 THEN 'Item22' WHEN 410 THEN 'Item23'
  WHEN 411 THEN 'Item24' WHEN 412 THEN 'Item25'
  ELSE ''
  END) AS `Item`,
  qqc.content AS `Content`
  FROM `mdl_course_modules` cm
  INNER JOIN `mdl_questionnaire` q ON cm.instance = q.id
  INNER JOIN `mdl_questionnaire_question` qq ON qq.survey_id = q.id
  INNER JOIN `mdl_questionnaire_quest_choice` qqc ON qqc.question_id = qq.id
  WHERE cm.id=549")
legend <- dplyr::mutate(legend, Content = iconv(legend$Content, from = "latin1", to = "UTF-8"))
if (!file.exists('study03/data/SourceMotLegend.csv')) {
  write_csv(legend, path = 'study03/data/SourceMotLegend.csv')
  legend <- read_csv('study03/data/SourceMotLegend.csv')
  legend <- legend[complete.cases(legend),]
  write_csv(legend, path = 'study03/data/SourceMotLegend.csv')
}

resp <- dbGetQuery(
  con,
  "SELECT qr.username AS `UserID`
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
if (!file.exists('study03/data/SourceMotQuestWithCareless.csv')) {
  write_csv(resp, 'study03/data/SourceMotQuestWithCareless.csv')
}

# close connection
dbDisconnect(con)
