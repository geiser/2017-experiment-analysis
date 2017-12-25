wants <- c('readr', 'dplyr', 'RMySQL', 'reshape')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

##########################################################################
## Participants for Case01, Case02 and Case03                           ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## Experiment01 - CaseStudy01
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

if (!file.exists('case01/data/Participant.csv')) write_csv(participants, path = "case01/data/Participant.csv")

# close connection
dbDisconnect(con)

##########################################################################
## Motivation Questionnaire for Case01                                  ##
##########################################################################

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)
library(careless)

# open connection
con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

## Experiment01 - CaseStudy01 (Motivation Questionnaire)
participant <- read_csv("case01/data/Participant.csv")

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
if (!file.exists('case01/data/SourceIMILegend.csv')) {
  write_csv(legend, path = 'case01/data/SourceIMILegend.csv')
  legend <- read_csv('case01/data/SourceIMILegend.csv')
  legend <- legend[complete.cases(legend),]
  write_csv(legend, path = 'case01/data/SourceIMILegend.csv')
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
if (!file.exists('case01/data/SourceIMIWithCareless.csv')) {
  write_csv(resp, 'case01/data/SourceIMIWithCareless.csv')
}

# close connection
dbDisconnect(con)

