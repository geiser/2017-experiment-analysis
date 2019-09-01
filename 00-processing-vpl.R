wants <- c('readr', 'dplyr', 'readxl')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(readr)
library(dplyr)
library(readxl)

source('common/misc.R')

##########################################################################
## PreTest and PosTest for Pilot-Study                                  ##
##########################################################################

participants_pilot <- read_csv("pilot-study/data/SignedUpParticipants.csv")
participants_first <- read_csv("study01/data/SignedUpParticipants.csv")
participants_second <- read_csv("study02/data/SignedUpParticipants.csv")
participants_third <- read_csv("study03/data/SignedUpParticipants.csv")

lapply(list(
  "pilot-pre" = list(
    participants = participants_pilot
    , filename = "data/PilotStudy-SourceMoodle-VPL.xlsx"
    , sheet = "PretestData"
    , corr_str = "corr", nview_str = "nview", apxt_str = "apxt"
    , keys = c("P1","P2","P3","P4")
    , csv = "pilot-study/data/PreGuttmanVPL.csv"
  )
  , "pilot-pos" = list(
    participants = participants_pilot
    , filename = "data/PilotStudy-SourceMoodle-VPL.xlsx"
    , sheet = "PostestData"
    , corr_str = "corr", nview_str = "nview", apxt_str = "apxt"
    , keys = c("PA","PB","PC","PD")
    , csv = "pilot-study/data/PosGuttmanVPL.csv"
  )
  , "first-pre" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("P1")
    , csv = "study01/data/PreGuttmanVPL.csv"
  )
  , "first-pos" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("PA","PB")
    , csv = "study01/data/PosGuttmanVPL.csv"
  )
  , "second-pre" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("P2","P3")
    , csv = "study02/data/PreGuttmanVPL.csv"
  )
  , "second-pos" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("PC","PD","PE")
    , csv = "study02/data/PosGuttmanVPL.csv"
  )
  , "third-pre" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("P4")
    , csv = "study03/data/PreGuttmanVPL.csv"
  )
  , "third-pos" = list(
    participants = participants_first
    , filename = "data/FullScaleStudies-SourcePrePostData.xlsx"
    , sheet = "VPLData"
    , corr_str = "corr", nview_str = "start", apxt_str = "exat"
    , keys = c("PF","PG","PH")
    , csv = "study03/data/PosGuttmanVPL.csv"
  )
), FUN = function(src) {
  dat <- score_programming_tasks(
    dat = read_excel(src$filename, sheet = src$sheet, col_types = "numeric")
    , keys = src$keys, corr_str = src$corr_str
    , nview_str = src$nview_str, apxt_str = src$apxt_str)
  scores <- do.call(cbind, lapply(src$keys, FUN = function(key) {
    dplyr::select(dat, starts_with(key))
  }))
  idx <- !do.call(c, lapply(1:nrow(scores), FUN = function(i) all(is.na(scores[i,]))))
  dat <- cbind("UserID" = dat[["UserID"]][idx], scores[idx,])
  write_csv(merge(src$participants[,c("UserID")], dat, by = "UserID"), src$csv)
})
