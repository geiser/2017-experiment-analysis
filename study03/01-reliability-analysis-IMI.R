############################################################################
## Confirmatory/Explanatory Factorial Analysis                            ##
############################################################################

library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)
library(Hmisc)

## read data
datIMI <- read_csv("data/SourceIMI.csv")

## validating sampling adequacy and removing unaceptable sampling adequacy < 0.5
print(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item")))))
print(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item"), -starts_with("Item23")))))

datIMI <- select(datIMI, starts_with("UserID"), starts_with("Type")
                 , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole")
                 , starts_with("Item"),-starts_with("Item23"))

## cfa to verify if relability analysis can be done
model <- '
f1 =~ Item07+Item08+Item09+Item11+Item17+Item21+Item24
f2 =~ Item03+Item05+Item10+Item13+Item16+Item18+Item20
f3 =~ Item01+Item14+Item15+Item19+Item22
f3 =~ Item02+Item04+Item06+Item12
'
cfa_mod <- cfa(model, data=datIMI, std.lv=T, orthogonal=F, missing="fiml")
summary(cfa_mod, fit.measures=T, standardized=T)

factanal(~Item07+Item08+Item09+Item11+Item17+Item21+Item24
         +Item03+Item05+Item10+Item13+Item16+Item18+Item20
         +Item01+Item14+Item15+Item19+Item22
         +Item02+Item04+Item06+Item12
         , factors=4, data=datIMI)

# removing items with loading < 0.4 # nothing removed

# removing cross loading items with a difference less than 0.2
factanal(~Item07+Item08+Item09+Item11+Item17+Item21+Item24
         +Item03+Item05+Item10+Item13+Item18+Item20
         +Item01+Item14+Item19+Item22
         +Item02+Item04+Item06+Item12
         , factors=4, data=datIMI)

factanal(~Item09+Item21+Item08+Item12+Item11+Item24+Item10
         +Item05+Item20+Item07+Item18+Item13+Item03+Item17
         +Item06+Item02+Item04
         +Item14+Item01+Item19+Item22
         , factors=4, data=datIMI) # sort according loading

# removing items doesn't fit by meaning and consulting with psychometrics
factanal(~Item09+Item21+Item08+Item12+Item11+Item24
         +Item05+Item20+Item18+Item13+Item03
         +Item06+Item02+Item04
         +Item14+Item01+Item19+Item22
         , factors=4, data=datIMI)

model <- '
f1 =~ Item09+Item21+Item08+Item12+Item11+Item24
f2 =~ Item05+Item20+Item18+Item13+Item03
f3 =~ Item06+Item02+Item04
f4 =~ Item01+Item19+Item22
' # f1=Interest/Enjoyment, f2=Perceived Choice, f3=Pressure/Tension, f4=Effort/Importance
cfa_mod <- cfa(model, data=datIMI, std.lv=T, orthogonal=F, missing="fiml")
summary(cfa_mod, fit.measures=T, standardized=T)

datIMI <- select(
  datIMI, starts_with("UserID"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole")
  , starts_with("Item09"), starts_with("Item21"), starts_with("Item08"), starts_with("Item11"), starts_with("Item24"), starts_with("Item12")
  , starts_with("Item05"), starts_with("Item18"), starts_with("Item20"),starts_with("Item13"), starts_with("Item03")
  , starts_with("Item06"), starts_with("Item02"), starts_with("Item04")
  , starts_with("Item19"), starts_with("Item01"), starts_with("Item22")
)

## factorial analysis with nfactor=4
print(fa_mod <- fa(select(datIMI, starts_with("Item")), nfactors = 4, rotate = "varimax"))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMI <- select(
  datIMI, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))
rdatIMI["Item09IE"] <- datIMI["Item09"]
rdatIMI["Item21IE"] <- datIMI["Item21"]
rdatIMI["Item08IE"] <- datIMI["Item08"]
rdatIMI["Item11IE"] <- datIMI["Item11"]
rdatIMI["Item24IE"] <- datIMI["Item24"]
rdatIMI["Item12IE"] <- datIMI["Item12"]

rdatIMI["Item05PC"] <- datIMI["Item05"]
rdatIMI["Item18PC"] <- datIMI["Item18"]
rdatIMI["Item20PC"] <- datIMI["Item20"]
rdatIMI["Item13PC"] <- datIMI["Item13"]
rdatIMI["Item03PC"] <- datIMI["Item03"]

rdatIMI["Item06PT"] <- datIMI["Item06"]
rdatIMI["Item02PT"] <- datIMI["Item02"]
rdatIMI["Item04PT"] <- datIMI["Item04"]

#rdatIMI["Item14EI"] <- datIMI["Item14"]
rdatIMI["Item19EI"] <- datIMI["Item19"]
rdatIMI["Item01EI"] <- datIMI["Item01"]
rdatIMI["Item22EI"] <- datIMI["Item22"]

if (!file.exists('data/IMI.csv')) {
  write_csv(rdatIMI, path = 'data/IMI.csv')
}

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

alpha_mods[["IM"]] <- list(lbl = 'Intrinsic Motivation', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Interest/Enjoyment
alpha_mod <- alpha(select(rdatIMI, ends_with("IE")))
cat("\n... Interest/Enjoyment", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("IE")))
cat("\n... Interest/Enjoyment", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IE"]] <- list(lbl = 'Interest/Enjoyment', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c()
## reliability analysis - Perceived Choice
alpha_mod <- alpha(select(rdatIMI, ends_with("PC")))
cat("\n... Perceived Choice", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("PC")))
cat("\n... Perceived Choice", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PC")))
cat("\n... Perceived Choice", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PC"]] <- list(lbl = 'Perceived Choice', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c()
## reliability analysis - Pressure/Tension
alpha_mod <- alpha(select(rdatIMI, ends_with("PT")))
cat("\n... Pressure/Tension", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("PT")))
cat("\n... Pressure/Tension", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PT")))
cat("\n... Pressure/Tension", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PT"]] <- list(lbl = 'Pressure/Tension', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c("Item01EI", "Item19EI")
## reliability analysis - Effort/Importance
alpha_mod <- alpha(select(rdatIMI, ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMI[rdatIMI$Type=="w/o-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["EI"]] <- list(lbl = 'Effort/Importance', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/reliability-analysis/IMI.xlsx")) {
  filename <- "report/reliability-analysis/IMI.xlsx"
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


# Export summary in latex format
filename <- "report/latex/IMI-reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese version of IMI questionnaire"
    , filename = filename
    , key_labels = list('Total' = 'all', 'Ont-Gamified' = 'ont', 'W/O-Gamified'='wo')
  )
}


