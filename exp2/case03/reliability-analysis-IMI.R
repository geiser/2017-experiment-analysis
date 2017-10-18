
library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)

## read data
datIMI <- read_csv("data/IMI.csv")

## validating sampling adequacy
(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item")))))

## factorial analysis with nfactor=4
(fa_mod <- fa(select(datIMI, starts_with("Item")), nfactors = 4))

## cfa to verify if relability analysis can be done
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
'
# removing items falling in wrong category
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)

(fa_mod <- fa(select(
  datIMI
  , starts_with("Item08"), starts_with("Item09"), starts_with("Item11"), starts_with("Item12"), starts_with("Item21"), starts_with("Item24")
  , starts_with("Item03"), starts_with("Item05"), starts_with("Item13"), starts_with("Item18"), starts_with("Item20")
  , starts_with("Item02"), starts_with("Item04"), starts_with("Item06"), starts_with("Item23")
  , starts_with("Item01"), starts_with("Item14"), starts_with("Item19"), starts_with("Item22")
), nfactors = 4))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMI <- select(
  datIMI, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))
rdatIMI["Item08IE"] <- datIMI["Item08"]
rdatIMI["Item09IE"] <- datIMI["Item09"]
rdatIMI["Item11IE"] <- datIMI["Item11"]
rdatIMI["Item12IE"] <- datIMI["Item12"]
rdatIMI["Item21IE"] <- datIMI["Item21"]
rdatIMI["Item24IE"] <- datIMI["Item24"]

rdatIMI["Item03PC"] <- datIMI["Item03"]
rdatIMI["Item05PC"] <- datIMI["Item05"]
rdatIMI["Item13PC"] <- datIMI["Item13"]
rdatIMI["Item18PC"] <- datIMI["Item18"]
rdatIMI["Item20PC"] <- datIMI["Item20"]

rdatIMI["Item02PT"] <- datIMI["Item02"]
rdatIMI["Item04PT"] <- datIMI["Item04"]
rdatIMI["Item06PT"] <- datIMI["Item06"]
rdatIMI["Item23PT"] <- datIMI["Item23"]

rdatIMI["Item01EI"] <- datIMI["Item01"]
rdatIMI["Item14EI"] <- datIMI["Item14"]
rdatIMI["Item19EI"] <- datIMI["Item19"]
rdatIMI["Item22EI"] <- datIMI["Item22"]

if (!file.exists('data/StdIMI.csv')) write_csv(rdatIMI, path = 'data/StdIMI.csv')

alpha_mods <- list()

inv_keys <- c("Item05PC", "Item20PC", "Item18PC", "Item13PC", "Item03PC"
              , "Item02PT",  "Item06PT", "Item04PT", "Item01EI",  "Item19EI")
## Intrinsic Motivation
alpha_mod <- alpha(select(rdatIMI, starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IM"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Interest/Enjoyment
alpha_mod <- alpha(select(rdatIMI, ends_with("IE")))
cat("\n... Interest/Enjoyment", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IE"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## reliability analysis - Perceived Choice
alpha_mod <- alpha(select(rdatIMI, ends_with("PC")))
cat("\n... Perceived Choice", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("PC")))
cat("\n... Perceived Choice", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PC")))
cat("\n... Perceived Choice", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PC"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c("Item23PT")
## reliability analysis - Pressure/Tension
alpha_mod <- alpha(select(rdatIMI, ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PT"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c("Item01EI", "Item19EI")
## reliability analysis - Effort/Importance
alpha_mod <- alpha(select(rdatIMI, ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["EI"]] <- list(all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/RelAnalysisIMI.xlsx")) {
  filename <- "report/RelAnalysisIMI.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  
  write_alpha_in_workbook(alpha_mods$IM$all, wb, "Intrinsic Motivation", "IM")
  write_alpha_in_workbook(alpha_mods$IM$wo, wb, "Intrinsic Motivation in Gamified CL Sessions Without Ontologies", "IM wo-gamified")
  write_alpha_in_workbook(alpha_mods$IM$ont, wb, "Intrinsic Motivation in Gamified CL Sessions Using Ontologies", "IM ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$IE$all, wb, "Interest/Enjoyment", "IE")
  write_alpha_in_workbook(alpha_mods$IE$wo, wb, "Interest/Enjoyment in Gamified CL Sessions Without Ontologies", "IE wo-gamified")
  write_alpha_in_workbook(alpha_mods$IE$ont, wb, "Interest/Enjoyment in Gamified CL Sessions Using Ontologies", "IE ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$PC$all, wb, "Perceived Choice", "PC")
  write_alpha_in_workbook(alpha_mods$PC$wo, wb, "Perceived Choice in Gamified CL Sessions Without Ontologies", "PC wo-gamified")
  write_alpha_in_workbook(alpha_mods$PC$ont, wb, "Perceived Choice in Gamified CL Sessions Using Ontologies", "PC ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$PT$all, wb, "Pressure/Tension", "PT")
  write_alpha_in_workbook(alpha_mods$PT$wo, wb, "Pressure/Tension in Gamified CL Sessions Without Ontologies", "PT wo-gamified")
  write_alpha_in_workbook(alpha_mods$PT$ont, wb, "Pressure/Tension in Gamified CL Sessions Using Ontologies", "PT ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$EI$all, wb, "Effort/Importance", "EI")
  write_alpha_in_workbook(alpha_mods$EI$wo, wb, "Effort/Importance in Gamified CL Sessions Without Ontologies", "EI wo-gamified")
  write_alpha_in_workbook(alpha_mods$EI$ont, wb, "Effort/Importance in Gamified CL Sessions Using Ontologies", "EI ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}
