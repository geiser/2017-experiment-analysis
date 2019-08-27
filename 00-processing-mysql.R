wants <- c('readr', 'dplyr', 'RMySQL', 'reshape')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

##########################################################################
## Participants for Pilot-Study                                         ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## Pilot-Experiment
participants <- dbGetQuery(
  con,
  "SELECT u.id as `UserID`
  , (CASE oj1.name
  WHEN 'Intervention' THEN 'ont-gamified'
  WHEN 'Control' THEN 'non-gamified'
  ELSE ''
  END) AS `Type`
  , oj2.name AS `CLGroup`
  , (CASE oj3.name
  WHEN 'Mestre' THEN 'Master'
  WHEN 'Aprendiz' THEN 'Apprentice'
  ELSE ''
  END) AS `CLRole`
  , (CASE oj4.name
  WHEN 'Competidor' THEN 'Yee Achiever'
  WHEN 'Socializador' THEN 'Yee Socializer'
  ELSE ''
  END) AS `PlayerRole`
  FROM mdl_user u
  INNER JOIN mdl_user_enrolments ue ON ue.userid = u.id
  INNER JOIN mdl_enrol e ON e.id = ue.enrolid
  INNER JOIN (SELECT gm1.userid, g1.name
  FROM mdl_groups_members gm1
  INNER JOIN mdl_groups g1 ON g1.id = gm1.groupid
  WHERE g1.name IN ('Control', 'Intervention')) oj1 ON oj1.userid = u.id
  INNER JOIN (SELECT gm2.userid, g2.name
  FROM mdl_groups_members gm2
  INNER JOIN mdl_groups g2 ON g2.id = gm2.groupid
  INNER JOIN mdl_groupings_groups grg2 ON grg2.groupid = g2.id
  INNER JOIN mdl_groupings gr2 ON gr2.id = grg2.groupingid
  WHERE gr2.name IN ('Grouping')) oj2 ON oj2.userid = u.id
  INNER JOIN (SELECT gm3.userid, g3.name
  FROM mdl_groups_members gm3
  INNER JOIN mdl_groups g3 ON g3.id = gm3.groupid
  INNER JOIN mdl_groupings_groups grg3 ON grg3.groupid = g3.id
  INNER JOIN mdl_groupings gr3 ON gr3.id = grg3.groupingid
  WHERE gr3.name IN ('CLRoles')) oj3 ON oj3.userid = u.id
  LEFT JOIN (SELECT gm4.userid, g4.name
  FROM mdl_groups_members gm4
  INNER JOIN mdl_groups g4 ON g4.id = gm4.groupid
  INNER JOIN mdl_groupings_groups grg4 ON grg4.groupid = g4.id
  INNER JOIN mdl_groupings gr4 ON gr4.id = grg4.groupingid
  WHERE gr4.name IN ('PlayerRoles') AND g4.name IN ('Socializador', 'Competidor')) oj4 ON oj4.userid = u.id
  WHERE e.courseid = 5")
participants <- dplyr::mutate(participants, CLGroup = iconv(participants$CLGroup, from = "latin1", to = "UTF-8"))
if (!file.exists('pilot-study/data/SignedUpParticipants.csv')) {
  write_csv(participants, path = "pilot-study/data/SignedUpParticipants.csv")
}

# close connection
dbDisconnect(con)

# effective participants for the pilot-study
a01 <- read_csv('pilot-study/data/CLActivity.csv')
userids <- subset(a01, a01$ParticipationLevel != "none")$UserID # participated
p01 <- read_csv('pilot-study/data/SignedUpParticipants.csv')
p01 <- p01[p01$UserID %in% userids,]
if (!file.exists('pilot-study/data/EffectiveParticipants.csv'))  {
  write_csv(p01, path = "pilot-study/data/EffectiveParticipants.csv")
}

# print design_summary
ep01 <- read_csv('pilot-study/data/EffectiveParticipants.csv')

print(design_summary_df <- data.frame(
  'Type.of.CL.session'=c('Pilot-Study', 'ont-gamified', 'non-gamified')
  , 'Master' = c(
    NA
    , paste0(
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep01, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep01, Type == "non-gamified" & CLRole == "Master"))
      , ")"))
  , 'Apprentice' = c(
    NA
    , paste0(
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep01, Type == "non-gamified" & CLRole == "Apprentice"))
      , ")")
  )
))
if (!file.exists('report/pilot_design.csv'))  {
  write_csv(design_summary_df, 'report/pilot_design.csv')
}

##########################################################################
## Motivation Questionnaire for Pilot-Study                             ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## get legends for IMI
legend <- dbGetQuery(
  con,
  "SELECT qqc.id AS `ID`, qq.id AS `QID`,
  (CASE qqc.id
  WHEN 109 THEN 'Item01' WHEN 110 THEN 'Item02' WHEN 111 THEN 'Item03' WHEN 112 THEN 'Item04'
  WHEN 113 THEN 'Item05' WHEN 114 THEN 'Item06' WHEN 115 THEN 'Item07' WHEN 116 THEN 'Item08'
  WHEN 117 THEN 'Item09' WHEN 118 THEN 'Item10' WHEN 119 THEN 'Item11'
  WHEN 120 THEN 'Item12'
  WHEN 121 THEN 'Item13' WHEN 122 THEN 'Item14' WHEN 123 THEN 'Item15'
  WHEN 124 THEN 'Item16' WHEN 125 THEN 'Item17' WHEN 126 THEN 'Item18' WHEN 127 THEN 'Item19'
  WHEN 128 THEN 'Item20' WHEN 129 THEN 'Item21' WHEN 130 THEN 'Item22' WHEN 131 THEN 'Item23'
  WHEN 132 THEN 'Item24'
  ELSE ''
  END) AS `Item`,
  qqc.content AS `Content`
  FROM `mdl_course_modules` cm
  INNER JOIN `mdl_questionnaire` q ON cm.instance = q.id
  INNER JOIN `mdl_questionnaire_question` qq ON qq.survey_id = q.id
  INNER JOIN `mdl_questionnaire_quest_choice` qqc ON qqc.question_id = qq.id
  WHERE cm.id=394")
legend <- dplyr::mutate(legend, Content = iconv(legend$Content, from = "latin1", to = "UTF-8"))
if (!file.exists('pilot-study/data/SourceIMILegend.csv')) {
  write_csv(legend, path = 'pilot-study/data/SourceIMILegend.csv')
  legend <- read_csv('pilot-study/data/SourceIMILegend.csv')
  legend <- legend[complete.cases(legend),]
  write_csv(legend, path = 'pilot-study/data/SourceIMILegend.csv')
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
  WHERE cm.id=394")
resp <- cast(resp, UserID ~ item)

resp <- mutate(resp
               , Item01=0+resp$`109`
               , Item02=0+resp$`110`
               , Item03=0+resp$`111`
               , Item04=0+resp$`112`
               , Item05=0+resp$`113`
               , Item06=0+resp$`114`
               , Item07=0+resp$`115`
               , Item08=0+resp$`116`
               , Item09=0+resp$`117`
               , Item10=0+resp$`118`
               , Item11=0+resp$`119`
               , Item12=0+resp$`120`
               , Item13=0+resp$`121`
               , Item14=0+resp$`122`
               , Item15=0+resp$`123`
               , Item16=0+resp$`124`
               , Item17=0+resp$`125`
               , Item18=0+resp$`126`
               , Item19=0+resp$`127`
               , Item20=0+resp$`128`
               , Item21=0+resp$`129`
               , Item22=0+resp$`130`
               , Item23=0+resp$`131`
               , Item24=0+resp$`132`
)
resp <- select(resp, starts_with("UserID"), starts_with("Item"))
if (!file.exists('pilot-study/data/SourceIMIWithCareless.csv')) {
  write_csv(resp, 'pilot-study/data/SourceIMIWithCareless.csv')
}

# close connection
dbDisconnect(con)


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

# effective participants for the study 01
a01 <- read_csv('study01/data/CLActivity.csv')
userids <- subset(a01, a01$ParticipationLevel != "none")$UserID # participated
p01 <- read_csv('study01/data/SignedUpParticipants.csv')
p01 <- p01[p01$UserID %in% userids,]
if (!file.exists('study01/data/EffectiveParticipants.csv'))  {
  write_csv(p01, path = "study01/data/EffectiveParticipants.csv")
}

# effective participants for the study 02
a02 <- read_csv('study02/data/CLActivity.csv')
userids <- subset(a02, a02$ParticipationLevel != "none")$UserID # participated
p02 <- read_csv('study02/data/SignedUpParticipants.csv')
p02 <- p02[p02$UserID %in% userids,]
if (!file.exists('study02/data/EffectiveParticipants.csv'))  {
  write_csv(p02, path = "study02/data/EffectiveParticipants.csv")
}

# effective participants for the study 03
a03 <- read_csv('study03/data/CLActivity.csv')
userids <- subset(a03, a03$ParticipationLevel != "none")$UserID # participated
p03 <- read_csv('study03/data/SignedUpParticipants.csv')
p03 <- p03[p03$UserID %in% userids,]
if (!file.exists('study03/data/EffectiveParticipants.csv'))  {
  write_csv(p03, path = "study03/data/EffectiveParticipants.csv")
}

# effective participants for the study 02
#a01 <- read_csv('study01/data/CLActivity.csv')
#a02 <- read_csv('study02/data/CLActivity.csv')

#userids01 <- subset(a01, a01$ParticipationLevel != "none")$UserID
#userids02 <- subset(a02, a02$ParticipationLevel != "none")$UserID
#userids <- intersect(userids01, userids02)

#p01 <- read_csv('study01/data/SignedUpParticipants.csv')
#p02 <- read_csv('study02/data/SignedUpParticipants.csv')

#userids01ont <- intersect(userids, subset(p01,  Type == "ont-gamified")$UserID)
#userids01non <- intersect(userids, subset(p01,  Type == "non-gamified")$UserID)
#userids02ont <- intersect(userids, subset(p02,  Type == "ont-gamified")$UserID)
#userids02non <- intersect(userids, subset(p02,  Type == "non-gamified")$UserID)

#userids <- union(intersect(userids01non, userids02ont), # effective users
#                 intersect(userids01ont, userids02non))

#p02 <- p02[p02$UserID %in% userids,]
#if (!file.exists('study02/data/EffectiveParticipants.csv'))  {
#  write_csv(p02, path = "study02/data/EffectiveParticipants.csv")
#}

# effective participants for the study 03
#a01 <- read_csv('study01/data/CLActivity.csv')
#a02 <- read_csv('study02/data/CLActivity.csv')
#a03 <- read_csv('study03/data/CLActivity.csv')

#userids01 <- subset(a01, a01$ParticipationLevel != "none")$UserID
#userids02 <- subset(a02, a02$ParticipationLevel != "none")$UserID
#userids03 <- subset(a03, a03$ParticipationLevel != "none")$UserID
#userids <- intersect(intersect(userids01, userids02), userids03)

#p01 <- read_csv('study01/data/SignedUpParticipants.csv')
#p02 <- read_csv('study02/data/SignedUpParticipants.csv')
#p03 <- read_csv('study03/data/SignedUpParticipants.csv')

#userids01ont <- intersect(userids, subset(p01,  Type == "ont-gamified")$UserID)
#userids01non <- intersect(userids, subset(p01,  Type == "non-gamified")$UserID)
#userids02ont <- intersect(userids, subset(p02,  Type == "ont-gamified")$UserID)
#userids02non <- intersect(userids, subset(p02,  Type == "non-gamified")$UserID)

#userids <- union(intersect(userids01non, userids02ont), # effective users
#                 intersect(userids01ont, userids02non))

#p03 <- p03[p03$UserID %in% userids,]
#if (!file.exists('study03/data/EffectiveParticipants.csv'))  {
#  write_csv(p03, path = "study03/data/EffectiveParticipants.csv")
#}

# print design_summary
ep01 <- read_csv('study01/data/EffectiveParticipants.csv')
ep02 <- read_csv('study02/data/EffectiveParticipants.csv')
ep03 <- read_csv('study03/data/EffectiveParticipants.csv')

print(design_summary_df <- data.frame(
  'Type.of.CL.session'=c('Study01', 'ont-gamified', 'non-gamified',
                         'Study02', 'ont-gamified', 'non-gamified',
                         'Study03', 'ont-gamified', 'w/o-gamified')
  , 'Master' = c(
    NA
    , paste0(
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep01, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep01, Type == "non-gamified" & CLRole == "Master"))
      , ")")
    , NA
    , paste0(
      nrow(subset(a02, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep02, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(a02, Type == "non-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep02, Type == "non-gamified" & CLRole == "Master"))
      , ")")
    , NA
    , paste0(
      nrow(subset(a03, Type == "ont-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep03, Type == "ont-gamified" & CLRole == "Master"))
      , ")")
    , paste0(
      nrow(subset(a03, Type == "w/o-gamified" & CLRole == "Master"))
      , " (",
      nrow(subset(ep03, Type == "w/o-gamified" & CLRole == "Master"))
      , ")"))
  , 'Apprentice' = c(
    NA
    , paste0(
      nrow(subset(a01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep01, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(a01, Type == "non-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep01, Type == "non-gamified" & CLRole == "Apprentice"))
      , ")")
    , NA
    , paste0(
      nrow(subset(a02, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep02, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(a02, Type == "non-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep02, Type == "non-gamified" & CLRole == "Apprentice"))
      , ")")
    , NA
    , paste0(
      nrow(subset(a03, Type == "ont-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep03, Type == "ont-gamified" & CLRole == "Apprentice"))
      , ")")
    , paste0(
      nrow(subset(a03, Type == "w/o-gamified" & CLRole == "Apprentice"))
      , " (",
      nrow(subset(ep03, Type == "w/o-gamified" & CLRole == "Apprentice"))
      , ")")
  )
))
if (!file.exists('report/exp_design.txt'))  {
  write_csv(design_summary_df, 'report/exp_design.csv')
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
  WHEN 388 THEN 'IMI'
  WHEN 390 THEN 'IMI' WHEN 391 THEN 'IMI' WHEN 392 THEN 'IMI'
  WHEN 394 THEN 'IMI'
  WHEN 396 THEN 'IMI' WHEN 397 THEN 'IMI' WHEN 398 THEN 'IMI' WHEN 399 THEN 'IMI' WHEN 400 THEN 'IMI' WHEN 401 THEN 'IMI' WHEN 402 THEN 'IMI'
  WHEN 345 THEN 'IMI' WHEN 346 THEN 'IMI' WHEN 347 THEN 'IMI' WHEN 348 THEN 'IMI' WHEN 349 THEN 'IMI' WHEN 350 THEN 'IMI' WHEN 351 THEN 'IMI'
  WHEN 395 THEN 'IMI'
  WHEN 352 THEN 'IMI' WHEN 353 THEN 'IMI' WHEN 354 THEN 'IMI' WHEN 355 THEN 'IMI'
  WHEN 403 THEN 'IMMS' WHEN 404 THEN 'IMMS'
  WHEN 393 THEN 'IMMS'
  WHEN 405 THEN 'IMMS' WHEN 406 THEN 'IMMS' WHEN 407 THEN 'IMMS' WHEN 408 THEN 'IMMS' WHEN 409 THEN 'IMMS' WHEN 410 THEN 'IMMS' WHEN 411 THEN 'IMMS' WHEN 412 THEN 'IMMS'
  WHEN 332 THEN 'IMMS' WHEN 333 THEN 'IMMS' WHEN 334 THEN 'IMMS' WHEN 335 THEN 'IMMS' WHEN 336 THEN 'IMMS' WHEN 337 THEN 'IMMS' WHEN 338 THEN 'IMMS' WHEN 339 THEN 'IMMS' WHEN 340 THEN 'IMMS' WHEN 341 THEN 'IMMS' WHEN 342 THEN 'IMMS'
  WHEN 389 THEN 'IMMS'
  WHEN 443 THEN 'IMMS' WHEN 344 THEN 'IMMS'
  ELSE ''
  END) AS `CLGroup`,
  (CASE qqc.id
  WHEN 388 THEN 'Item01'
  WHEN 390 THEN 'Item02' WHEN 391 THEN 'Item03' WHEN 392 THEN 'Item04'
  WHEN 394 THEN 'Item05'
  WHEN 396 THEN 'Item06' WHEN 397 THEN 'Item07' WHEN 398 THEN 'Item08' WHEN 399 THEN 'Item09' WHEN 400 THEN 'Item10' WHEN 401 THEN 'Item11' WHEN 402 THEN 'Item12'
  WHEN 345 THEN 'Item13' WHEN 346 THEN 'Item14' WHEN 347 THEN 'Item15' WHEN 348 THEN 'Item16' WHEN 349 THEN 'Item17' WHEN 350 THEN 'Item18' WHEN 351 THEN 'Item19'
  WHEN 395 THEN 'Item20'
  WHEN 352 THEN 'Item21' WHEN 353 THEN 'Item22' WHEN 354 THEN 'Item23' WHEN 355 THEN 'Item24'
  WHEN 403 THEN 'Item01' WHEN 404 THEN 'Item02'
  WHEN 393 THEN 'Item03'
  WHEN 405 THEN 'Item04' WHEN 406 THEN 'Item06' WHEN 407 THEN 'Item07' WHEN 408 THEN 'Item08' WHEN 409 THEN 'Item09' WHEN 410 THEN 'Item10' WHEN 411 THEN 'Item11' WHEN 412 THEN 'Item12'
  WHEN 332 THEN 'Item13' WHEN 333 THEN 'Item14' WHEN 334 THEN 'Item15' WHEN 335 THEN 'Item16' WHEN 336 THEN 'Item17' WHEN 337 THEN 'Item18' WHEN 338 THEN 'Item19' WHEN 339 THEN 'Item20' WHEN 340 THEN 'Item21' WHEN 341 THEN 'Item22' WHEN 342 THEN 'Item23'
  WHEN 389 THEN 'Item24'
  WHEN 343 THEN 'Item25' WHEN 344 THEN 'Item26'
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
resp <- resp[complete.cases(resp),]

respIMI <- mutate(
  resp
  , Item01=0+resp$`388`
  , Item02=0+resp$`390`, Item03=0+resp$`391`, Item04=0+resp$`392`
  , Item05=0+resp$`394`
  , Item06=0+resp$`396`, Item07=0+resp$`397`, Item08=0+resp$`398`, Item09=0+resp$`399`, Item10=0+resp$`400`, Item11=0+resp$`401`, Item12=0+resp$`402`
  , Item13=0+resp$`345`, Item14=0+resp$`346`, Item15=0+resp$`347`, Item16=0+resp$`348`, Item17=0+resp$`349`, Item18=0+resp$`350`, Item19=0+resp$`351`
  , Item20=0+resp$`395`
  , Item21=0+resp$`352`, Item22=0+resp$`353`, Item23=0+resp$`354`, Item24=0+resp$`355`
)
respIMI <- select(respIMI, starts_with("UserID"), starts_with("Item"))
if (!file.exists('study03/data/SourceIMIWithCareless.csv')) {
  write_csv(respIMI, 'study03/data/SourceIMIWithCareless.csv')
}

respIMMS <- mutate(
  resp
  , Item01=0+resp$`403`, Item02=0+resp$`404`
  , Item03=0+resp$`393`
  , Item04=0+resp$`405`, Item06=0+resp$`406`, Item07=0+resp$`407`, Item08=0+resp$`408`, Item09=0+resp$`409`, Item10=0+resp$`410`, Item11=0+resp$`411`, Item12=0+resp$`412`
  , Item13=0+resp$`332`, Item14=0+resp$`333`, Item15=0+resp$`334`, Item16=0+resp$`335`, Item17=0+resp$`336`, Item18=0+resp$`337`, Item19=0+resp$`338`, Item20=0+resp$`339`, Item21=0+resp$`340`, Item22=0+resp$`341`, Item23=0+resp$`342`
  , Item24=0+resp$`389`
  , Item25=0+resp$`343`, Item26=0+resp$`344`
)
respIMMS <- select(respIMMS, starts_with("UserID"), starts_with("Item"))
if (!file.exists('study03/data/SourceIMMSWithCareless.csv')) {
  write_csv(respIMMS, 'study03/data/SourceIMMSWithCareless.csv')
}

# close connection
dbDisconnect(con)

