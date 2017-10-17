
library(dplyr)
library(readr)
library(psych)
library(lavaan)

datIMI <- read_csv("data/IMI.csv")

## validating sampling adequacy
KMO(cor(select(datIMI, starts_with("Item"))))

## factorial analysis with nfactor=4
fa(select(datIMI, starts_with("Item")), nfactors = 4)

## cfa 
model <- '
f1 =~ Item08+Item09+Item10+Item11+Item12+Item15+Item16+Item21+Item24
f2 =~ Item03+Item05+Item07+Item13+Item17+Item18+Item20
f3 =~ Item02+Item04+Item06+Item23
f4 =~ Item01+Item14+Item19+Item22
'
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item08+Item09+Item10+Item11+Item12+Item15+Item16+Item21+Item24
         +Item03+Item05+Item07+Item13+Item17+Item18+Item20
         +Item02+Item04+Item06+Item23
         +Item01+Item14+Item19+Item22
         , factors=4, data=datIMI)

model <- '
f1 =~ Item08+Item09+Item11+Item12+Item21+Item24
f2 =~ Item03+Item05+Item13+Item18+Item20
f3 =~ Item02+Item04+Item06+Item23
f4 =~ Item01+Item14+Item19+Item22
' # removing items falling in wrong category
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

fa(select(datIMI
          , starts_with("Item08"), starts_with("Item09"), starts_with("Item11"), starts_with("Item12"), starts_with("Item21"), starts_with("Item24")
          , starts_with("Item03"), starts_with("Item05"), starts_with("Item13"), starts_with("Item18"), starts_with("Item20")
          , starts_with("Item02"), starts_with("Item04"), starts_with("Item06"), starts_with("Item23")
          , starts_with("Item01"), starts_with("Item14"), starts_with("Item19"), starts_with("Item22")
), nfactors = 4)

##
rdatIMI <- select(datIMI
                  , starts_with("UserID"), starts_with("Type"), starts_with("CLRole")
                  , starts_with("PlayerRole")
                  , starts_with("ParticipationLevel")
                  , starts_with("Item08"), starts_with("Item09"), starts_with("Item11"), starts_with("Item12"), starts_with("Item21"), starts_with("Item24")
                  , starts_with("Item03"), starts_with("Item05"), starts_with("Item13"), starts_with("Item18"), starts_with("Item20")
                  , starts_with("Item02"), starts_with("Item04"), starts_with("Item06"), starts_with("Item23")
                  , starts_with("Item01"), starts_with("Item14"), starts_with("Item19"), starts_with("Item22")
)

## reliability analysis - Intrinsic Motivation
inv_keys = c(
  "Item05", "Item20", "Item18", "Item13", "Item03"
  , "Item02",  "Item06", "Item04"
  , "Item01",  "Item19")
alpha <- alpha(select(rdatIMI, starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("Intrinsic Motivation", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Interest/Enjoyment
inv_keys = c()
alpha <- alpha(select(rdatIMI
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item08"), starts_with("Item09")
                      , starts_with("Item11"), starts_with("Item12")
                      , starts_with("Item21"), starts_with("Item24")
), keys = inv_keys)
cat("Interest/Enjoyment", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Perceived Choice
inv_keys = c()
alpha <- alpha(select(rdatIMI
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item05"), starts_with("Item20")
                      , starts_with("Item18"), starts_with("Item13"), starts_with("Item03")
), keys = inv_keys)
cat("Perceived Choice", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Pressure/Tension
inv_keys = c("Item23")
alpha <- alpha(select(rdatIMI
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item02"), starts_with("Item06")
                      , starts_with("Item04"), starts_with("Item23")
), keys = inv_keys)
cat("Pressure/Tension", ">>", "w/o-gamified", "\n"); alpha$total

## reliability analysis - Effort/Importance
inv_keys = c("Item01", "Item19")
alpha <- alpha(select(rdatIMI
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",]
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", ">>", "ont-gamified", "\n"); alpha$total
alpha <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",]
                      , starts_with("Item14"), starts_with("Item01")
                      , starts_with("Item19"), starts_with("Item22")
), keys = inv_keys)
cat("Effort/Importance", ">>", "w/o-gamified", "\n"); alpha$total