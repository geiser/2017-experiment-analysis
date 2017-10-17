
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

participants <- dplyr::mutate(participants, Group = iconv(participants$Group, from = "latin1", to = "UTF-8"))

###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################



###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMI <- dplyr::mutate(rdatIMI
, `Interest/Enjoyment` = (rdatIMI$Item08
                          +rdatIMI$Item09
                          +rdatIMI$Item11
                          +rdatIMI$Item12
                          +rdatIMI$Item21
                          +rdatIMI$Item24)/6
, `Perceived Choice` = (40-(rdatIMI$Item03
                            +rdatIMI$Item05
                            +rdatIMI$Item13
                            +rdatIMI$Item18
                            +rdatIMI$Item20))/5
, `Pressure/Tension` = (rdatIMI$Item02
                        +rdatIMI$Item04
                        +rdatIMI$Item06
                        +8-rdatIMI$Item23)/4
, `Effort/Importance` = (rdatIMI$Item14
                         +rdatIMI$Item22
                         +16-(rdatIMI$Item01
                              +rdatIMI$Item19))/4
)

rdatIMI <- dplyr::mutate(rdatIMI
, `Intrinsic Motivation` = (6*rdatIMI$`Interest/Enjoyment`
                            +5*rdatIMI$`Perceived Choice`
                            +4*rdatIMI$`Effort/Importance`
                            +32-4*rdatIMI$`Pressure/Tension`)/19
)

## performing tests in each factor IMI
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Interest/Enjoyment`
, alternative = "greater", title = "Interest/Enjoyment", inv.col = TRUE)
cat("Interest/Enjoyment", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Perceived Choice`
, alternative = "greater", title = "Perceived Choice", inv.col = TRUE)
cat("Perceived Choice", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Pressure/Tension`
, alternative = "less", title = "Pressure/Tension", inv.col = TRUE)
cat("Pressure/Tension", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Effort/Importance`
, alternative = "greater", title = "Effort/Importance", inv.col = TRUE)
cat("Effort/Importance", "\n"); wt

wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Intrinsic Motivation`
, alternative = "greater", title = "Intrinsic Motivation", inv.col = TRUE)
cat("Intrinsic Motivation", "\n"); wt

###############################################################
## ARCS IMMS                                                 ##
###############################################################


respIMMS <- select(respIMMS, starts_with("UserID"), starts_with("Item"))

## gather data from csv files
activities <- read_csv('2017-CLActivity03.csv')

## combine data for analysis
datIMMS <- merge(
  select(participants
         , starts_with("UserID")
         , starts_with("Type")
         , starts_with("CLRole")
         , starts_with("PlayerRole")
  ),
  select(activities
         , starts_with("UserID")
         , starts_with("ParticipationLevel")
  ), by = "UserID")
datIMMS <- merge(datIMMS, select(respIMMS, starts_with("UserID"), starts_with("Item")), by = "UserID")


###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################

library(psych)

## validating sampling adequacy
KMO(cor(select(datIMMS, starts_with("Item"))))

## factorial analysis with nfactor=3
fa(select(datIMMS, starts_with("Item")), nfactors = 3)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item10")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")), nfactors = 3)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item12")
          , -starts_with("Item19")
          , -starts_with("Item10")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")), nfactors = 3)

## cfa
model <- '
f1 =~ Item04+Item07+Item08+Item11+Item13+Item14+Item18+Item20+Item25
f2 =~ Item01+Item02+Item05+Item17+Item24
f3 =~ Item03+Item06+Item09+Item21+Item23
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item04+Item07+Item08+Item11+Item13+Item14+Item18+Item20+Item25
         +Item01+Item02+Item05+Item17+Item24
         +Item03+Item06+Item09+Item21+Item23
         , factors=3, data=datIMMS)

factanal(~Item01+Item02+Item05+Item08+Item17+Item24
         +Item11+Item18+Item20+Item25
         +Item03+Item06+Item09+Item21+Item23
         , factors=3, data=datIMMS)

model <- '
f1 =~ Item01+Item02+Item05+Item08+Item17+Item24
f2 =~ Item11+Item18+Item20+Item25
f3 =~ Item03+Item06+Item09+Item21+Item23
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

factanal(~Item01+Item02+Item05+Item08+Item17+Item24
         +Item03+Item06+Item09+Item21+Item23
         +Item18+Item25
         , factors=3, data=datIMMS)

model <- '
f1 =~ Item01+Item02+Item05+Item08+Item17+Item24
f2 =~ Item03+Item06+Item09+Item21+Item23
f3 =~ Item18+Item25
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

## factorial analysis with nfactor=2
fa(select(datIMMS, starts_with("Item")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item06")
          , -starts_with("Item19")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

fa(select(datIMMS, starts_with("Item")
          , -starts_with("Item17")
          , -starts_with("Item06")
          , -starts_with("Item19")
          , -starts_with("Item09")
          , -starts_with("Item14")
          , -starts_with("Item15")
          , -starts_with("Item16")
          , -starts_with("Item22")
          , -starts_with("Item03")
          , -starts_with("Item11")
          , -starts_with("Item12")
          , -starts_with("Item23")), nfactors = 2)

## cfa
model <- '
f1 =~ Item18+Item25+Item20+Item07+Item13+Item04+Item10+Item08
f2 =~ Item01+Item02+Item05+Item21+Item24
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item07+Item13+Item04+Item10+Item08
         +Item01+Item02+Item05+Item21+Item24
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item08
f2 =~ Item01+Item02+Item05+Item21
'
fit <- cfa(model, data=datIMMS, group = "Type", std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item08
         +Item01+Item02+Item05+Item21
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item07
f2 =~ Item01+Item02+Item05+Item21
'
fit <- cfa(model, data=datIMMS, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item18+Item25+Item20+Item07
         +Item01+Item02+Item05+Item21
         , factors=2, data=datIMMS)

model <- '
f1 =~ Item18+Item25+Item20+Item07+Item13
f2 =~ Item01+Item02+Item05+Item21
' # removing relevance items
fit <- cfa(model, data=datIMMS, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

fa(select(datIMMS
          , starts_with("Item18")
          , starts_with("Item25")
          , starts_with("Item20")
          , starts_with("Item07")
          , starts_with("Item13")
          , starts_with("Item01")
          , starts_with("Item02")
          , starts_with("Item05")
          , starts_with("Item21")), nfactors = 2)

##
rdatIMMS <- select(datIMMS
, starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
, starts_with("ParticipationLevel"), starts_with("PlayerRole")
, starts_with("Item18")
, starts_with("Item25")
, starts_with("Item20")
, starts_with("Item07")
, starts_with("Item13")
, starts_with("Item01")
, starts_with("Item02")
, starts_with("Item05")
, starts_with("Item21")
)

## reliability analysis - Level of Motivation
inv_keys = c("Item21")
alpha <- alpha(select(rdatIMMS, starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("Level of Motivation", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Attention
inv_keys = c()
alpha <- alpha(select(rdatIMMS
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",]
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",]
                      , starts_with("Item18"), starts_with("Item25")
                      , starts_with("Item20"), starts_with("Item07")
                      , starts_with("Item13")), keys = inv_keys)
cat("Attention", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Satisfaction
inv_keys = c("Item21")
alpha <- alpha(select(rdatIMMS
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",]
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",]
                      , starts_with("Item01"), starts_with("Item02")
                      , starts_with("Item05"), starts_with("Item21")), keys = inv_keys)
cat("Satisfaction", ">>", "w/o-gamified", "\n"); alpha$total

###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Attention` = (rdatIMMS$Item18
                                           +rdatIMMS$Item25
                                           +rdatIMMS$Item20
                                           +rdatIMMS$Item07
                                           +rdatIMMS$Item13)/5
                          , `Satisfaction` = (rdatIMMS$Item01
                                              +rdatIMMS$Item02
                                              +rdatIMMS$Item05
                                              +8-rdatIMMS$Item21)/4
)
rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Level of Motivation` = (rdatIMMS$Attention*5
                                                     +rdatIMMS$Satisfaction*4)/9
)

## performing tests in each factor
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Attention`
                      , alternative = "less", title = "Attention", inv.col = T)
cat("Attention", "\n"); wt
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Satisfaction`
                      , alternative = "greater", title = "Satisfaction", inv.col = T)
cat("Satisfaction", "\n"); wt

wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Level of Motivation`
                      , alternative = "greater", title = "Level of Motivation", inv.col = T)
cat("Level of Motivation", "\n"); wt

