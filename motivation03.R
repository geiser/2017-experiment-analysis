
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

dbDisconnect(con)

## gather data from csv files
respIMI <- read_csv('2017-RespMotivation02.csv')


activities <- read_csv('2017-CLActivity02.csv')

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
library(lavaan)

## validating sampling adequacy
KMO(cor(select(dat, starts_with("Item"))))

## factorial analysis with nfactor=3
fa(select(dat, starts_with("Item")), nfactors = 3)


## factorial analysis with nfactor=2
fa(select(dat, starts_with("Item")), nfactors = 2)




## cfa 


model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item11+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)





##
rdat <- select(dat, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("ParticipationLevel")
, starts_with("Item01"), starts_with("Item04")
, starts_with("Item05"), starts_with("Item12")
, starts_with("Item19"), starts_with("Item20")
, starts_with("Item09"), starts_with("Item11")
, starts_with("Item14"), starts_with("Item24")
, starts_with("Item25")
)

## reliability analysis - Intrinsic Motivation
inv_keys = c()
alpha <- alpha(select(rdat, starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Attention
inv_keys = c()
alpha <- alpha(select(rdat
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",]
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",]
                      , starts_with("Item01"), starts_with("Item04")
                      , starts_with("Item05"), starts_with("Item12")
                      , starts_with("Item19"), starts_with("Item20")), keys = inv_keys)
cat("Attention", ">>", "non-gamified", "\n"); alpha$total

## reliability analysis - Satisfaction
inv_keys = c()
alpha <- alpha(select(rdat
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="ont-gamified",]
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdat[rdat$Type=="non-gamified",]
                      , starts_with("Item09"), starts_with("Item11")
                      , starts_with("Item14"), starts_with("Item24")
                      , starts_with("Item25")), keys = inv_keys)
cat("Satisfaction", ">>", "non-gamified", "\n"); alpha$total


###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdat <- dplyr::mutate(rdat
                      
)
rdat <- dplyr::mutate(rdat
                      , `Level of Motivation` = (rdat$Attention*6
                                                  +rdat$Satisfaction*5)/11
)

## performing tests in each factor
wt <- wilcox_analysis(rdat$Type, rdat$`Attention`, alternative = "less", title = "Attention")
cat("Attention", "\n"); wt
wt <- wilcox_analysis(rdat$Type, rdat$`Satisfaction`, alternative = "less", title = "Satisfaction")
cat("Satisfaction", "\n"); wt

wt <- wilcox_analysis(rdat$Type, rdat$`Level of Motivation`, alternative = "less", title = "Level of Motivation")
cat("Level of Motivation", "\n"); wt

