library(dplyr)
library(RMySQL)
library(reshape)
#install.packages('dplyr')
#install.packages('RMySQL')
#install.packages('reshape')

con <- dbConnect(RMySQL::MySQL(), user = "root" , password = "qaz123456"
                 , dbname = "caede741_geiser_moodle", host = "localhost")

res1 <- dbGetQuery(con, "
SELECT u.id as `UserID`
  , (CASE oj1.name
          WHEN 'Intervention' THEN 'yes'
          ELSE 'no'
          END) AS `Gamified`
  , oj2.name AS `Group`
  , oj3.name AS `CLRole`
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
WHERE e.courseid = 5")
res1 <- dplyr::mutate(res1, Group = iconv(res1$Group, from = "latin1", to = "UTF-8"))

res2 <- dbGetQuery(con, "
SELECT l.userid, FLOOR((l.timecreated - 1478905200)/86400)+1 AS day, COUNT(*) AS num
FROM mdl_logstore_standard_log l
WHERE l.userid IN (SELECT u.id
    FROM mdl_user u
    INNER JOIN mdl_user_enrolments ue ON ue.userid = u.id
    INNER JOIN mdl_enrol e ON e.id = ue.enrolid
    WHERE e.courseid = 5)    
AND l.timecreated > 1478905200 AND l.timecreated < 1480719600
AND l.courseid = 5 AND l.anonymous = 0
GROUP BY l.userid, day")

View(cast(res2, userid ~ day))


dbDisconnect(con)


