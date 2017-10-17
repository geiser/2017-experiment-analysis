
#install.packages('dplyr')
#install.packages('RMySQL')
#install.packages('reshape')

library(readr)
library(dplyr)
library(RMySQL)
library(reshape)

con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")


## CaseStudy01 : 2016-Experiment01
##########################################################################

participants <- dbGetQuery(
  con,
  "SELECT u.id as `UserID`
  , (CASE oj1.name
  WHEN 'Intervention' THEN 'ont-gamified'
  ELSE 'non-gamified'
  END) AS `Type`
  , oj2.name AS `Group`
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
participants <- dplyr::mutate(participants, Group = iconv(participants$Group, from = "latin1", to = "UTF-8"))

write_csv(participants, path = "Participant01.csv") # write csv




##########################################################################

## get legends for IMI
legendIMI  <- data.frame(t(matrix(c(
  "Item01", 109, "Item02", 110, "Item03", 111, "Item04", 112, "Item05", 113,
  "Item06", 114, "Item07", 115, "Item08", 116, "Item09", 117, "Item10", 118,
  "Item11", 119, "Item12", 120, "Item13", 121, "Item14", 122, "Item15", 123,
  "Item16", 124, "Item17", 125, "Item18", 126, "Item19", 127, "Item20", 128,
  "Item21", 129, "Item22", 130, "Item23", 131, "Item24", 132), nrow = 2)))
colnames(legendIMI) <- c("Item", "ID")

legendIMI <- merge(
  legendIMI,
  dbGetQuery(
    con,
    "SELECT qqc.id AS `ID`
    , qqc.content AS `content`
    FROM `mdl_course_modules` cm
    INNER JOIN `mdl_questionnaire` q ON cm.instance = q.id
    INNER JOIN `mdl_questionnaire_question` qq ON qq.survey_id = q.id
    INNER JOIN `mdl_questionnaire_quest_choice` qqc ON qqc.question_id = qq.id
    WHERE cm.id=394"), by = "ID")
legendIMI <- dplyr::mutate(
  legendIMI, content = iconv(legendIMI$content, from = "latin1", to = "UTF-8"))

write_csv(legendIMI, path = "2016-LegendIMI01.csv") # write csv

## get responses from IMI
respIMI <- dbGetQuery(
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
respIMI <- cast(respIMI, UserID ~ item)

careless(select(respIMI, -starts_with("UserID")), append=FALSE)
respIMI <- respIMI[-c(2,14),] # outliers

respIMI <- mutate(respIMI
                  , Item01=0+respIMI$`109` #r
                  , Item02=0+respIMI$`110` #r
                  , Item03=0+respIMI$`111`
                  , Item04=0+respIMI$`112`
                  , Item05=0+respIMI$`113`
                  , Item06=0+respIMI$`114` #r
                  , Item07=0+respIMI$`115` #r
                  , Item08=0+respIMI$`116` #r
                  , Item09=0+respIMI$`117`
                  , Item10=0+respIMI$`118`
                  , Item11=0+respIMI$`119` #r
                  , Item12=0+respIMI$`120`
                  , Item13=0+respIMI$`121` #r
                  , Item14=0+respIMI$`122`
                  , Item15=0+respIMI$`123` #r
                  , Item16=0+respIMI$`124`
                  , Item17=0+respIMI$`125` #r
                  , Item18=0+respIMI$`126`
                  , Item19=0+respIMI$`127` #r
                  , Item20=0+respIMI$`128` #r
                  , Item21=0+respIMI$`129`
                  , Item22=0+respIMI$`130`
                  , Item23=0+respIMI$`131`
                  , Item24=0+respIMI$`132`
)

write_csv(select(respIMI, starts_with("UserID"), starts_with("Item"))
          , path = "2016-IMI01.csv") # write csv




dbDisconnect(con)

