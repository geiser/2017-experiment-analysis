
library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)

## read data
dat <- read_csv("data/SourceIMMS.csv")

## validating sampling adequacy
(kmo_mod <- KMO(cor(select(dat, starts_with("Item")))))

## factorial analysis with nfactor=3
(fa_mod <- fa(select(dat, starts_with("Item")), nfactors = 3))

(fa_mod <- fa(select(dat, starts_with("Item")
                     , -starts_with("Item03")
                     , -starts_with("Item08")
                     , -starts_with("Item10")), nfactors = 3))

## cfa 
model <- '
f1 =~ Item02+Item06+Item07+Item09+Item11+Item13+Item14+Item15+Item17+Item18+Item21+Item24+Item25+Item26
f2 =~ Item01+Item04+Item05+Item12+Item16+Item19+Item20+Item22
f3 =~ Item23
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item02+Item06+Item07+Item09+Item11+Item13+Item14+Item15+Item17+Item18+Item21+Item24+Item25+Item26
         +Item01+Item04+Item05+Item12+Item16+Item19+Item20+Item22
         +Item23
         , factors=3, data=dat)

## factorial analysis with nfactor=2
(fa_mod <- fa(select(dat, starts_with("Item")), nfactors = 2))

(fa_mod <- fa(select(dat, starts_with("Item")
                     , -starts_with("Item03")
                     , -starts_with("Item10")
                     , -starts_with("Item18")
                     , -starts_with("Item23")), nfactors = 2))

(fa_mod <- fa(select(dat, starts_with("Item")
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
                     , -starts_with("Item23")), nfactors = 2))

(fa_mod <- fa(select(dat, starts_with("Item")
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
                     , -starts_with("Item23")), nfactors = 2))

## cfa with nfactor=2
model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25+Item26
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25+Item26
         , factors=2, data=dat)

model <- '
f1 =~ Item01+Item04+Item05+Item12+Item19+Item20
f3 =~ Item09+Item11+Item14+Item24+Item25
'
fit <- cfa(model, data=dat, std.lv=TRUE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item01+Item04+Item05+Item12+Item19+Item20
         +Item09+Item11+Item14+Item24+Item25
         , factors=2, data=dat)


(fa_mod <- fa(select(
  dat
  , starts_with("Item01"), starts_with("Item04")
  , starts_with("Item05"), starts_with("Item12")
  , starts_with("Item19"), starts_with("Item20")
  , starts_with("Item09"), starts_with("Item11")
  , starts_with("Item14"), starts_with("Item24")
  , starts_with("Item25"), starts_with("Item26")), nfactors = 2))

(fa_mod <- fa(select(
  dat
  , starts_with("Item01"), starts_with("Item04")
  , starts_with("Item05"), starts_with("Item12")
  , starts_with("Item19"), starts_with("Item20")
  , starts_with("Item09"), starts_with("Item11")
  , starts_with("Item14"), starts_with("Item24")
  , starts_with("Item25")), nfactors = 2))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMMS <- select(
  dat, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))

rdatIMMS["Item01A"] <- dat["Item01"]
rdatIMMS["Item04A"] <- dat["Item04"]
rdatIMMS["Item05A"] <- dat["Item05"]
rdatIMMS["Item12A"] <- dat["Item12"]
rdatIMMS["Item19A"] <- dat["Item19"]
rdatIMMS["Item20A"] <- dat["Item20"]

rdatIMMS["Item09S"] <- dat["Item09"]
rdatIMMS["Item11S"] <- dat["Item11"]
rdatIMMS["Item14S"] <- dat["Item14"]
rdatIMMS["Item24S"] <- dat["Item24"]
rdatIMMS["Item25S"] <- dat["Item25"]
#rdatIMMS["Item26S"] <- dat["Item26"]

if (!file.exists('data/IMMS.csv')) write_csv(rdatIMMS, path = 'data/IMMS.csv')

alpha_mods <- list()

inv_keys <- c()
## Level of Motivation
alpha_mod <- alpha(select(rdatIMMS, starts_with("Item")))
cat("\n... Level of Motivation", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="non-gamified",], starts_with("Item")))
cat("\n... Level of Motivation", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], starts_with("Item")))
cat("\n... Level of Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["LM"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## Attention
alpha_mod <- alpha(select(rdatIMMS, ends_with("A")))
cat("\n... Attention", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="non-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["A"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

inv_keys = c()
## Satisfaction
alpha_mod <- alpha(select(rdatIMMS, ends_with("S")))
cat("\n... Satisfaction", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="non-gamified",], ends_with("S")))
cat("\n... Satisfaction", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("S")))
cat("\n... Satisfaction", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["S"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/RelAnalysisIMMS.xlsx")) {
  filename <- "report/RelAnalysisIMMS.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  
  write_alpha_in_workbook(alpha_mods$LM$all, wb, "Level of Motivation", "LM")
  write_alpha_in_workbook(alpha_mods$LM$non, wb, "Level of Motivation in Non-Gamified CL Sessions", "LM non-gamified")
  write_alpha_in_workbook(alpha_mods$LM$ont, wb, "Level of Motivation in Gamified CL Sessions Using Ontologies", "LM ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$A$all, wb, "Attention", "A")
  write_alpha_in_workbook(alpha_mods$A$non, wb, "Attention in Non-Gamified CL Sessions", "A non-gamified")
  write_alpha_in_workbook(alpha_mods$A$ont, wb, "Attention in Gamified CL Sessions Using Ontologies", "A ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$S$all, wb, "Satisfaction", "S")
  write_alpha_in_workbook(alpha_mods$S$non, wb, "Satisfaction in Non-Gamified CL Sessions", "S non-gamified")
  write_alpha_in_workbook(alpha_mods$S$ont, wb, "Satisfaction in Gamified CL Sessions Using Ontologies", "S ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}

