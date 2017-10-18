
library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)

## read data
datIMMS <- read_csv("data/IMMS.csv")

## validating sampling adequacy
(kmo_mod <- KMO(cor(select(datIMMS, starts_with("Item")))))

## factorial analysis with nfactor=3
(fa_mod <- fa(select(datIMMS, starts_with("Item")), nfactors = 3))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
                     , -starts_with("Item10")
                     , -starts_with("Item15")
                     , -starts_with("Item16")
                     , -starts_with("Item22")), nfactors = 3))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
                     , -starts_with("Item12")
                     , -starts_with("Item19")
                     , -starts_with("Item10")
                     , -starts_with("Item15")
                     , -starts_with("Item16")
                     , -starts_with("Item22")), nfactors = 3))

## confirmatory factorial analysis with nfactor=3
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
(fa_mod <- fa(select(datIMMS, starts_with("Item")), nfactors = 2))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
                     , -starts_with("Item03")
                     , -starts_with("Item11")
                     , -starts_with("Item12")
                     , -starts_with("Item23")), nfactors = 2))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
                     , -starts_with("Item09")
                     , -starts_with("Item14")
                     , -starts_with("Item15")
                     , -starts_with("Item16")
                     , -starts_with("Item22")
                     , -starts_with("Item03")
                     , -starts_with("Item11")
                     , -starts_with("Item12")
                     , -starts_with("Item23")), nfactors = 2))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
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
                     , -starts_with("Item23")), nfactors = 2))

(fa_mod <- fa(select(datIMMS, starts_with("Item")
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
                     , -starts_with("Item23")), nfactors = 2))

## confirmatory factorial analysis with nfactor=3
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

(fa_mod <- fa(select(datIMMS
                     , starts_with("Item18")
                     , starts_with("Item25")
                     , starts_with("Item20")
                     , starts_with("Item07")
                     , starts_with("Item13")
                     , starts_with("Item01")
                     , starts_with("Item02")
                     , starts_with("Item05")
                     , starts_with("Item21")), nfactors = 2))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMMS <- select(
  datIMMS, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))

rdatIMMS["Item18A"] <- datIMMS["Item18"]
rdatIMMS["Item25A"] <- datIMMS["Item25"]
rdatIMMS["Item20A"] <- datIMMS["Item20"]
rdatIMMS["Item07A"] <- datIMMS["Item07"]
rdatIMMS["Item13A"] <- datIMMS["Item13"]

rdatIMMS["Item01S"] <- datIMMS["Item01"]
rdatIMMS["Item02S"] <- datIMMS["Item02"]
rdatIMMS["Item05S"] <- datIMMS["Item05"]
rdatIMMS["Item21S"] <- datIMMS["Item21"]

if (!file.exists('data/StdIMMS.csv')) write_csv(rdatIMMS, path = 'data/StdIMMS.csv')

alpha_mods <- list()

inv_keys <- c("Item21S")
## Level of Motivation
alpha_mod <- alpha(select(rdatIMMS, starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["LM"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Attention
alpha_mod <- alpha(select(rdatIMMS, ends_with("A")))
cat("\n... Attention", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["A"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c("Item21S")
## Satisfaction
alpha_mod <- alpha(select(rdatIMMS, ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["S"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/RelAnalysisIMMS.xlsx")) {
  filename <- "report/RelAnalysisIMMS.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  
  write_alpha_in_workbook(alpha_mods$LM$all, wb, "Level of Motivation", "LM")
  write_alpha_in_workbook(alpha_mods$LM$wo, wb, "Level of Motivation in Gamified CL Sessions Without Ontologies", "LM wo-gamified")
  write_alpha_in_workbook(alpha_mods$LM$ont, wb, "Level of Motivation in Gamified CL Sessions Using Ontologies", "LM ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$A$all, wb, "Attention", "A")
  write_alpha_in_workbook(alpha_mods$A$wo, wb, "Attention in Gamified CL Sessions Without Ontologies", "A wo-gamified")
  write_alpha_in_workbook(alpha_mods$A$ont, wb, "Attention in Gamified CL Sessions Using Ontologies", "A ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$S$all, wb, "Satisfaction", "S")
  write_alpha_in_workbook(alpha_mods$S$wo, wb, "Satisfaction in Gamified CL Sessions Without Ontologies", "S wo-gamified")
  write_alpha_in_workbook(alpha_mods$S$ont, wb, "Satisfaction in Gamified CL Sessions Using Ontologies", "S ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}

