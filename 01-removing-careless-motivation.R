wants <- c('readr', 'dplyr', 'devtools')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])
if (!any(rownames(installed.packages()) %in% c('careless'))) {
  devtools::install_github('ryentes/careless')
}

library(daff)
library(readr)
library(dplyr)
library(careless)

##########################################################################
## Removing Careless in Motivation Survey Data of Pilot-Study           ##
##########################################################################

resp <- read_csv('pilot-study/data/SourceIMIWithCareless.csv')

(careless_info <- careless::longstring(select(resp, -starts_with("UserID")), na=T))
respIMI <- resp[careless_info <= 12 & complete.cases(resp),]

filename <- 'pilot-study/data/SourceIMI.csv'
if (!file.exists(filename)) {
  participants <- read_csv("pilot-study/data/SignedUpParticipants.csv")
  write_csv(merge(participants
                  , select(respIMI, starts_with("UserID"), starts_with("Item"))
                  , by="UserID"), filename)
}

## write in latex
render_diff(ddIMI <- diff_data(resp, respIMI))
filename <- 'report/latex/careless-IMI-pilot-study.tex'
write_careless_in_latex(
  ddIMI, filename, in_title = "in the IMI data collected over the pilot empirical study")



##########################################################################
## Removing Careless in Motivation Survey Data of Study01               ##                  ##
##########################################################################

library(readr)
library(dplyr)
library(careless)

resp <- read_csv('study01/data/SourceIMIWithCareless.csv')

(careless_info <- careless::longstring(select(resp, -starts_with("UserID")), na=T))
respIMI <- resp[careless_info <= 12 & complete.cases(resp),]

filename <- 'study01/data/SourceIMI.csv'
if (!file.exists(filename)) {
  participants <- read_csv("study01/data/SignedUpParticipants.csv")
  write_csv(merge(participants
                  , select(respIMI, starts_with("UserID"), starts_with("Item"))
                  , by="UserID"), filename)
}

## write in latex
render_diff(ddIMI <- diff_data(select(resp, starts_with("UserID"), starts_with("Item"))
                               , select(respIMI, starts_with("UserID"), starts_with("Item"))))
filename <- 'report/latex/careless-IMI-study01.tex'
write_careless_in_latex(
  ddIMI, filename
  , in_title = "in the IMI data collected over the first empirical study")

##########################################################################
## Removing Careless in Motivation Survey Data of Study02               ##
##########################################################################

resp <- read_csv('study02/data/SourceIMMSWithCareless.csv')

(careless_info <- careless::longstring(select(resp, -starts_with("UserID")), na=T))
respIMMS <- resp[careless_info <= 12 & complete.cases(resp),]

filename <- 'study02/data/SourceIMMS.csv'
if (!file.exists(filename)) {
  participants <- read_csv("study02/data/SignedUpParticipants.csv")
  write_csv(merge(participants
                  , select(respIMMS, starts_with("UserID"), starts_with("Item"))
                  , by="UserID"), filename)
}

## write in latex
render_diff(ddIMMS <- diff_data(select(resp, starts_with("UserID"), starts_with("Item"))
                                , select(respIMMS, starts_with("UserID"), starts_with("Item"))))
filename <- 'report/latex/careless-IMMS-study02.tex'
write_careless_in_latex(
  ddIMMS, filename
  , in_title = "in the IMMS data collected over the second empirical study")

##########################################################################
## Removing Careless in Motivation Survey Data of Study03               ##
##########################################################################

resp <- read_csv('study03/data/SourceIMIWithCareless.csv')

(careless_info <- careless::longstring(select(resp, -starts_with("UserID")), na=T))
respIMI <- resp[careless_info <= 12 & complete.cases(resp),]

filename <- 'study03/data/SourceIMI.csv'
if (!file.exists(filename)) {
  participants <- read_csv("study03/data/SignedUpParticipants.csv")
  write_csv(merge(participants
                  , select(respIMI, starts_with("UserID"), starts_with("Item"))
                  , by="UserID"), filename)
}

## write in latex
render_diff(ddIMI <- diff_data(select(resp, starts_with("UserID"), starts_with("Item"))
                               , select(respIMI, starts_with("UserID"), starts_with("Item"))))
filename <- 'report/latex/careless-IMI-study03.tex'
write_careless_in_latex(
  ddIMI, filename
  , in_title = "in the IMI data collected over the third empirical study")

##

resp <- read_csv('study03/data/SourceIMMSWithCareless.csv')

(careless_info <- careless::longstring(select(resp, -starts_with("UserID")), na=T))
respIMMS <- resp[careless_info <= 12 & complete.cases(resp),]

filename <- 'study03/data/SourceIMMS.csv'
if (!file.exists(filename)) {
  participants <- read_csv("study03/data/SignedUpParticipants.csv")
  write_csv(merge(participants
                  , select(respIMMS, starts_with("UserID"), starts_with("Item"))
                  , by="UserID"), filename)
}

## write in latex
render_diff(ddIMMS <- diff_data(select(resp, starts_with("UserID"), starts_with("Item"))
                                , select(respIMMS, starts_with("UserID"), starts_with("Item"))))
filename <- 'report/latex/careless-IMMS-study03.tex'
write_careless_in_latex(
  ddIMMS, filename
  , in_title = "in the IMMS data collected over the third empirical study")


