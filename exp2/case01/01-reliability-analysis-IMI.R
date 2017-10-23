
library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)

## read data
datIMI <- read_csv("data/SourceIMI.csv")

## validating sampling adequacy
print(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item")))))

## factorial analysis with nfactor=3
(fa_mod <- fa(select(datIMI, starts_with("Item")), nfactors = 4))

(fa_mod <- fa(select(datIMI, starts_with("Item")
                     , -starts_with("Item04")
                     , -starts_with("Item07")
                     , -starts_with("Item13")
                     , -starts_with("Item19")), nfactors = 4))

(fa_mod <- fa(select(datIMI, starts_with("Item")
          , -starts_with("Item03")
          , -starts_with("Item05")
          , -starts_with("Item04")
          , -starts_with("Item07")
          , -starts_with("Item13")
          , -starts_with("Item19")), nfactors = 4))##

## confirmatory factorial analysis with nfactor=4
model <- '
f1 =~ Item02+Item06+Item08+Item15+Item17+Item20
f2 =~ Item10+Item11+Item14+Item16+Item18
f3 =~ Item01+Item09+Item12+Item24
f4 =~ Item21+Item22+Item23
'
fit <- cfa(model, data=datIMI, group = "Type", std.lv=TRUE, missing="fiml")
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item02+Item06+Item08+Item15+Item17+Item20
         +Item10+Item11+Item14+Item16+Item18
         +Item01+Item09+Item12+Item24
         +Item21+Item22+Item23
         , factors=4, data=datIMI)

model <- '
f1 =~ Item02+Item06+Item08+Item15+Item17+Item20
f2 =~ Item11+Item14+Item16+Item18
f3 =~ Item01+Item09+Item12+Item24
f4 =~ Item22
'
fit <- cfa(model, data=datIMI, group = "Type", std.lv=TRUE, missing="fiml")
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item02+Item06+Item08+Item15+Item17+Item20
         +Item11+Item14+Item16+Item18
         +Item01+Item09+Item12+Item24
         +Item22
         , factors=4, data=datIMI)

## factorial analysis with nfactor=3
(fa_mod <- fa(select(datIMI, starts_with("Item")), nfactors = 3))

(fa_mod <- fa(select(datIMI, starts_with("Item")
                     , -starts_with("Item04")
                     , -starts_with("Item07")
                     , -starts_with("Item13")), nfactors = 3))

(fa_mod <- fa(select(datIMI, starts_with("Item")
                     , -starts_with("Item03")
                     , -starts_with("Item10")
                     , -starts_with("Item04")
                     , -starts_with("Item07")
                     , -starts_with("Item13")), nfactors = 3))



## confirmatory factorial analysis with nfactor=3
model <- '
f1 =~ Item02+Item05+Item06+Item08+Item15+Item17+Item19+Item20+Item23
f2 =~ Item01+Item09+Item12+Item21+Item22+Item24
f3 =~ Item11+Item14+Item16+Item18
'
fit <- cfa(model, data=datIMI, group = "Type", std.lv=TRUE, missing="fiml")
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~Item02+Item05+Item06+Item08+Item15+Item17+Item19+Item20+Item23
         +Item01+Item09+Item12+Item21+Item22+Item24
         +Item11+Item14+Item16+Item18
         , factors=3, data=datIMI)

model <- '
f1 =~ Item02+Item05+Item06+Item08+Item15+Item17+Item20+Item23
f2 =~ Item01+Item09+Item12+Item21+Item22+Item24
f3 =~ Item11+Item14+Item16+Item18
'
fit <- cfa(model, data=datIMI, group = "Type", std.lv=TRUE, missing="fiml")
summary(fit, fit.measures=TRUE, standardized=TRUE)
fitMeasures(fit)
factanal(~ Item02+Item05+Item06+Item08+Item15+Item17+Item20+Item23
         +Item01+Item09+Item12+Item21+Item22+Item24
         +Item11+Item14+Item16+Item18
         , factors=3, data=datIMI)

(fa_mod <- fa(select(datIMI, starts_with("Item")
                     , -starts_with("Item19")
                     , -starts_with("Item03")
                     , -starts_with("Item10")
                     , -starts_with("Item04")
                     , -starts_with("Item07")
                     , -starts_with("Item13")), nfactors = 3))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMI <- select(
  datIMI, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))

rdatIMI["Item01IE"] <- datIMI["Item01"]
rdatIMI["Item09IE"] <- datIMI["Item09"]
rdatIMI["Item12IE"] <- datIMI["Item12"]
rdatIMI["Item21IE"] <- datIMI["Item21"]
rdatIMI["Item22IE"] <- datIMI["Item22"]
rdatIMI["Item24IE"] <- datIMI["Item24"]

rdatIMI["Item02PC"] <- datIMI["Item02"]
rdatIMI["Item05PC"] <- datIMI["Item05"]
rdatIMI["Item06PC"] <- datIMI["Item06"]
rdatIMI["Item08PC"] <- datIMI["Item08"]
rdatIMI["Item15PC"] <- datIMI["Item15"]
rdatIMI["Item17PC"] <- datIMI["Item17"]
rdatIMI["Item20PC"] <- datIMI["Item20"]
rdatIMI["Item23PC"] <- datIMI["Item23"]

rdatIMI["Item11PT"] <- datIMI["Item11"]
rdatIMI["Item14PT"] <- datIMI["Item14"]
rdatIMI["Item16PT"] <- datIMI["Item16"]
rdatIMI["Item18PT"] <- datIMI["Item18"]

if (!file.exists('data/IMI.csv')) write_csv(rdatIMI, path = 'data/IMI.csv')

alpha_mods <- list()

inv_keys <- c("Item17PC", "Item15PC", "Item08PC", "Item02PC", "Item06PC", "Item20PC", "Item16PT",  "Item14PT",  "Item18PT")
## Intrinsic Motivation
alpha_mod <- alpha(select(rdatIMI, starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IM"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

inv_keys <- c()
## Interest/Enjoyment
alpha_mod <- alpha(select(rdatIMI, ends_with("IE")))
cat("\n... Interest/Enjoyment", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IE"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

inv_keys <- c("Item17PC", "Item15PC", "Item08PC", "Item02PC", "Item06PC", "Item20PC")
## Perceived Choice
alpha_mod <- alpha(select(rdatIMI, ends_with("PC")), keys = inv_keys)
cat("\n... Perceived Choice", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("PC")), keys = inv_keys)
cat("\n... Perceived Choice", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PC")), keys = inv_keys)
cat("\n... Perceived Choice", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PC"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

inv_keys <- c("Item11PT")
## Pressure/Tension
alpha_mod <- alpha(select(rdatIMI, ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PT"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/RelAnalysisIMI.xlsx")) {
  filename <- "report/RelAnalysisIMI.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  
  write_alpha_in_workbook(alpha_mods$IM$all, wb, "Intrinsic Motivation", "IM")
  write_alpha_in_workbook(alpha_mods$IM$non, wb, "Intrinsic Motivation in Non-Gamified CL Sessions", "IM non-gamified")
  write_alpha_in_workbook(alpha_mods$IM$ont, wb, "Intrinsic Motivation in Gamified CL Sessions Using Ontologies", "IM ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$IE$all, wb, "Interest/Enjoyment", "IE")
  write_alpha_in_workbook(alpha_mods$IE$non, wb, "Interest/Enjoyment in Non-Gamified CL Sessions", "IE non-gamified")
  write_alpha_in_workbook(alpha_mods$IE$ont, wb, "Interest/Enjoyment in Gamified CL Sessions Using Ontologies", "IE ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$PC$all, wb, "Perceived Choice", "PC")
  write_alpha_in_workbook(alpha_mods$PC$non, wb, "Perceived Choice in Non-Gamified CL Sessions", "PC non-gamified")
  write_alpha_in_workbook(alpha_mods$PC$ont, wb, "Perceived Choice in Gamified CL Sessions Using Ontologies", "PC ont-gamified")
  
  write_alpha_in_workbook(alpha_mods$PT$all, wb, "Pressure/Tension", "PT")
  write_alpha_in_workbook(alpha_mods$PT$non, wb, "Pressure/Tension in Non-Gamified CL Sessions", "PT non-gamified")
  write_alpha_in_workbook(alpha_mods$PT$ont, wb, "Pressure/Tension in Gamified CL Sessions Using Ontologies", "PT ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}

