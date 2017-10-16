
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

careless(select(respIMI, starts_with("Item")), append=FALSE) 
respIMI <- respIMI[-c(22,47,53,59,63),]
respIMI <- respIMI[-c(25,60),]

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
fa(select(dat, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item08")
          , -starts_with("Item10")), nfactors = 3)

## cfa 
model <- '
f1 =~ Item01+Item04+Item12+Item20+Item23
f2 =~ Item06+Item11+Item18+Item25
f3 =~ Item02+Item09+Item14+Item24+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item12+Item20+Item23
         +Item06+Item11+Item18+Item25
         +Item02+Item09+Item14+Item24+Item26
         , factors=3, data=dat)

model <- '
f1 =~ Item01+Item04+Item12+Item20
f2 =~ Item06+Item11+Item25
f3 =~ Item02+Item09+Item14+Item24+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item12+Item20
         +Item06+Item11+Item25
         +Item02+Item09+Item14+Item24+Item26
         , factors=3, data=dat)


## factorial analysis with nfactor=2
fa(select(dat, starts_with("Item")), nfactors = 2)
fa(select(dat, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

fa(select(dat, starts_with("Item")
          # remove Attention items falling into Satisfaction
          , -starts_with("Item07")
          , -starts_with("Item08")
          , -starts_with("Item13")
          , -starts_with("Item15")
          , -starts_with("Item17")
          , -starts_with("Item21")
          # remove unloading items
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

fa(select(dat, starts_with("Item")
          # remove Relevance items falling into Satisfaction
          , -starts_with("Item02")
          , -starts_with("Item06")
          # remove Relevance items falling into Attention
          , -starts_with("Item16")
          , -starts_with("Item22")
          # remove Attention items falling into Satisfaction
          , -starts_with("Item07")
          , -starts_with("Item08")
          , -starts_with("Item13")
          , -starts_with("Item15")
          , -starts_with("Item17")
          , -starts_with("Item21")
          # remove unloading items
          , -starts_with("Item03")
          , -starts_with("Item10")
          , -starts_with("Item18")
          , -starts_with("Item23")), nfactors = 2)

## cfa 
model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25+Item26
         , factors=2, data=dat)

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

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25
         , factors=2, data=dat)

fa(select(dat
, starts_with("Item01"), starts_with("Item04")
, starts_with("Item05"), starts_with("Item12")
, starts_with("Item19"), starts_with("Item20")
, starts_with("Item09"), starts_with("Item11")
, starts_with("Item14"), starts_with("Item24")
, starts_with("Item25")
), nfactors = 2)

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
                      , `Attention` = (rdat$Item12
                                       +rdat$Item20
                                       +rdat$Item19
                                       +rdat$Item01
                                       +rdat$Item05
                                       +rdat$Item04)/6
                      , `Satisfaction` = (rdat$Item14
                                          +rdat$Item24
                                          +rdat$Item11
                                          +rdat$Item25
                                          +rdat$Item09)/5
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

