wants <- c('readr', 'dplyr', 'readxl')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(readr)
library(dplyr)
library(readxl)


##########################################################################
## PreTest and PosTest for Study01                                      ##
##########################################################################

participants <- read_csv('study01/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha1a-cond-part1"
  , type = "pre", other_sheet = "provinha1a-cond-part2")
pos_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha1b-cond-part1"
  , type = "pos", other_sheet = "provinha1b-cond-part2")

if (!file.exists('study01/data/PreAMC.csv')) {
  write_csv(pre_dat, path = 'study01/data/PreAMC.csv')
}
if (!file.exists('study01/data/PosAMC.csv')) {
  write_csv(pos_dat, path = 'study01/data/PosAMC.csv')
}

##########################################################################
## PreTest and PosTest for Study02                                      ##
##########################################################################

participants <- read_csv('study02/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha2a-loops"
  , type = "pre")
pos_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha2b-loops"
  , type = "pos")

if (!file.exists('study02/data/PreAMC.csv')) {
  write_csv(pre_dat, path = 'study02/data/PreAMC.csv')
}
if (!file.exists('study02/data/PosAMC.csv')) {
  write_csv(pos_dat, path = 'study02/data/PosAMC.csv')
}

##########################################################################
## PreTest and PosTest for Study03                                      ##
##########################################################################

participants <- read_csv('study03/data/SignedUpParticipants.csv')
pre_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha3a-recurs"
  , type = "pre")
pos_dat <- get_amc_test_info(
  participants, source = "data/FullScaleStudies-SourcePrePostData.xlsx", sheet = "provinha3c-recurs"
  , type = "pos")

if (!file.exists('study03/data/PreAMC.csv')) {
  write_csv(pre_dat, path = 'study03/data/PreAMC.csv')
}
if (!file.exists('study03/data/PosAMC.csv')) {
  write_csv(pos_dat, path = 'study03/data/PosAMC.csv')
}
