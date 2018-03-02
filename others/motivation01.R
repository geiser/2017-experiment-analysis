
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

## gather data from csv files
participants <- read_csv('2016-Participant01.csv')
respIMI <- read_csv('2016-IMI01.csv')
activities <- read_csv('2016-CLActivity01.csv')

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

## validating sampling adequacy
KMO(cor(select(dat, starts_with("Item"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item10"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item13"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item03"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item15"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item17"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item05"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item14"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item06"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item02"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item19"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item01"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item07"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item04"))))
KMO(cor(select(dat, starts_with("Item"), -starts_with("Item16"))))

dat <- select(dat, -starts_with("Item13"))
KMO(cor(select(dat, starts_with("Item"))))

## factorial analysis with nfactor=4
fa(select(dat, starts_with("Item")), nfactors = 4)
fa(select(dat, starts_with("Item")
, -starts_with("Item19")), nfactors = 4)
fa(select(dat, starts_with("Item")
, -starts_with("Item08")
, -starts_with("Item10")
, -starts_with("Item11")
, -starts_with("Item23")
, -starts_with("Item19")), nfactors = 4)

##
rdat <- select(dat, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("ParticipationLevel"), starts_with("Item")
, -starts_with("Item08")
, -starts_with("Item10")
, -starts_with("Item11")
, -starts_with("Item23")
, -starts_with("Item19"))

## reliability analysis - Intrinsic Motivation
inv_keys = c("Item20"
, "Item02", "Item06", "Item15", "Item17"
, "Item14",  "Item16",  "Item18"
, "Item07")
alpha <- psych::alpha(select(rdat, starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="non-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Interest/Enjoyment
inv_keys = c("Item20")
alpha <- psych::alpha(select(rdat
, starts_with("Item01"), starts_with("Item09")
, starts_with("Item12"), starts_with("Item20"), starts_with("Item21")
, starts_with("Item22"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="ont-gamified",]
, starts_with("Item01"), starts_with("Item09")
, starts_with("Item12"), starts_with("Item20"), starts_with("Item21")
, starts_with("Item22"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "ont-gamified", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="non-gamified",]
, starts_with("Item01"), starts_with("Item09")
, starts_with("Item12"), starts_with("Item20"), starts_with("Item21")
, starts_with("Item22"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Perceived Choice
inv_keys = c("Item02", "Item06", "Item15", "Item17")
alpha <- psych::alpha(select(rdat
, starts_with("Item02"), starts_with("Item05")
, starts_with("Item06"), starts_with("Item15"), starts_with("Item17")
), keys = inv_keys)
cat("Perceived Choice", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="ont-gamified",]
, starts_with("Item02"), starts_with("Item05")
, starts_with("Item06"), starts_with("Item15"), starts_with("Item17")
), keys = inv_keys)
cat("Perceived Choice", ">>", "ont-gamified", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="non-gamified",]
, starts_with("Item02"), starts_with("Item05")
, starts_with("Item06"), starts_with("Item15"), starts_with("Item17")
), keys = inv_keys)
cat("Perceived Choice", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Pressure/Tension
inv_keys = c()
alpha <- psych::alpha(select(rdat
, starts_with("Item14")
, starts_with("Item16"), starts_with("Item18")
), keys = inv_keys)
cat("Pressure/Tension", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="ont-gamified",]
, starts_with("Item14")
, starts_with("Item16"), starts_with("Item18")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "ont-gamified", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="non-gamified",]
, starts_with("Item14")
, starts_with("Item16"), starts_with("Item18")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Effort/Importance
inv_keys = c("Item07")
alpha <- psych::alpha(select(rdat, starts_with("Item03")
, starts_with("Item04"), starts_with("Item07")
), keys = inv_keys)
cat("Effort/Importance", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="ont-gamified",]
, starts_with("Item03")
, starts_with("Item04"), starts_with("Item07")
), keys = inv_keys)
cat("Effort/Importance", ">>", "ont-gamified", "\n"); alpha$total
alpha <- psych::alpha(select(rdat[rdat$Type=="non-gamified",]
, starts_with("Item03")
, starts_with("Item04"), starts_with("Item07")
), keys = inv_keys)
cat("Effort/Importance", ">>", "non-gamified", "\n"); alpha$total

###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdat <- dplyr::mutate(rdat
, `Interest/Enjoyment` = (rdat$Item01
                          +rdat$Item09
                          +rdat$Item12
                          +rdat$Item21
                          +rdat$Item22
                          +rdat$Item24
                          +8-rdat$Item20)/7
, `Perceived Choice` = (rdat$Item05
                        +32-(rdat$Item02
                             +rdat$Item06
                             +rdat$Item15
                             +rdat$Item17))/5
, `Pressure/Tension` = (rdat$Item14
                        +rdat$Item16
                        +rdat$Item18)/3
, `Effort/Importance` = (rdat$Item03
                         +rdat$Item04
                         +8-rdat$Item07)/3
)
rdat <- dplyr::mutate(rdat
, `Intrinsic Motivation` = (7*rdat$`Interest/Enjoyment`
                            +5*rdat$`Perceived Choice`
                            +3*rdat$`Effort/Importance`
                            +24-3*rdat$`Pressure/Tension`)/18
)
write_csv(rdat, path = '2016-Result-Motivation01.csv')

## performing tests in each factor
wt <- wilcox_analysis(rdat$Type, rdat$`Interest/Enjoyment`, alternative = "less", title = "Interest/Enjoyment")
cat("Interest/Enjoyment", "\n"); wt
wt <- wilcox_analysis(rdat$Type, rdat$`Perceived Choice`, alternative = "less", title = "Perceived Choice")
cat("Perceived Choice", "\n"); wt
wt <- wilcox_analysis(rdat$Type, rdat$`Pressure/Tension`, alternative = "greater", title = "Pressure/Tension")
cat("Pressure/Tension", "\n"); wt
wt <- wilcox_analysis(rdat$Type, rdat$`Effort/Importance`, alternative = "less", title = "Effort/Importance")
cat("Effort/Importance", "\n"); wt

wt <- wilcox_analysis(rdat$Type, rdat$`Intrinsic Motivation`, alternative = "less", title = "Intrinsic Motivation")
cat("Intrinsic Motivation", "\n"); wt

