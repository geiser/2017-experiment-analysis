
library(dplyr)
library(readr)
library(psych)
library(lavaan)
library(r2excel)

## read data
datIMI <- read_csv("data/SourceIMI.csv")

## validating sampling adequacy
print(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item")))))
print(kmo_mod <- KMO(cor(select(datIMI, starts_with("Item"), -starts_with("Item13")))))

datIMI <- select(datIMI, starts_with("UserID"), starts_with("Type")
                 , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole")
                 , starts_with("Item"), -starts_with("Item13"))

## factorial analysis with nfactor=4
print(fa_mod <- fa(select(datIMI, starts_with("Item")), nfactors = 4))
print(fa_mod <- fa(select(datIMI, starts_with("Item")
                          , -starts_with("Item19")), nfactors = 4))
print(fa_mod <- fa(select(datIMI, starts_with("Item")
          , -starts_with("Item08")
          , -starts_with("Item10")
          , -starts_with("Item11")
          , -starts_with("Item23")
          , -starts_with("Item19")), nfactors = 4))

## cfa to verify if relability analysis can be done
model <- '
f1 =~ Item01+Item09+Item12+Item20+Item21+Item22+Item24
f2 =~ Item02+Item05+Item06+Item15+Item17
f3 =~ Item14+Item16+Item18
f4 =~ Item03+Item04+Item07
'
fit <- cfa(model, data=datIMI, std.lv=TRUE, orthogonal=FALSE)
summary(fit, fit.measures=TRUE, standardized=TRUE)
factanal(~Item01+Item09+Item12+Item20+Item21+Item22+Item24
         +Item02+Item05+Item06+Item15+Item17
         +Item14+Item16+Item18
         +Item03+Item04+Item07
         , factors=4, data=datIMI)

print(fa_mod <- fa(select(
  datIMI
  , starts_with("Item01"), starts_with("Item09"), starts_with("Item12"), starts_with("Item20"), starts_with("Item21"), starts_with("Item22"), starts_with("Item24")
  , starts_with("Item02"), starts_with("Item05"), starts_with("Item06"), starts_with("Item15"), starts_with("Item17")
  , starts_with("Item14"), starts_with("Item16"), starts_with("Item18")
  , starts_with("Item03"), starts_with("Item04"), starts_with("Item07")
), nfactors = 4))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMI <- select(
  datIMI, starts_with("UserID"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))
rdatIMI["Item01IE"] <- datIMI["Item01"]
rdatIMI["Item09IE"] <- datIMI["Item09"]
rdatIMI["Item12IE"] <- datIMI["Item12"]
rdatIMI["Item20IE"] <- datIMI["Item20"]
rdatIMI["Item21IE"] <- datIMI["Item21"]
rdatIMI["Item22IE"] <- datIMI["Item22"]
rdatIMI["Item24IE"] <- datIMI["Item24"]

rdatIMI["Item02PC"] <- datIMI["Item02"]
rdatIMI["Item05PC"] <- datIMI["Item05"]
rdatIMI["Item06PC"] <- datIMI["Item06"]
rdatIMI["Item15PC"] <- datIMI["Item15"]
rdatIMI["Item17PC"] <- datIMI["Item17"]

rdatIMI["Item14PT"] <- datIMI["Item14"]
rdatIMI["Item16PT"] <- datIMI["Item16"]
rdatIMI["Item18PT"] <- datIMI["Item18"]

rdatIMI["Item03EI"] <- datIMI["Item03"]
rdatIMI["Item04EI"] <- datIMI["Item04"]
rdatIMI["Item07EI"] <- datIMI["Item07"]

if (!file.exists('data/IMI.csv')) write_csv(rdatIMI, path = 'data/IMI.csv')

alpha_mods <- list()

## Intrinsic Motivation
inv_keys <- c("Item20IE"
              , "Item02PC", "Item06PC", "Item15PC", "Item17PC"
              , "Item14PT",  "Item16PT",  "Item18PT"
              , "Item07EI")
alpha_mod <- alpha(select(rdatIMI, starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Intrinsic Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IM"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## Interest/Enjoyment
inv_keys <- c("Item20IE")
alpha_mod <- alpha(select(rdatIMI, ends_with("IE")), keys = inv_keys)
cat("\n... Interest/Enjoyment", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("IE")), keys = inv_keys)
cat("\n... Interest/Enjoyment", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("IE")), keys = inv_keys)
cat("\n... Interest/Enjoyment", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["IE"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## reliability analysis - Perceived Choice
inv_keys <- c("Item02PC", "Item06PC", "Item15PC", "Item17PC")
alpha_mod <- alpha(select(rdatIMI, ends_with("PC")))
cat("\n... Perceived Choice", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("PC")), keys = inv_keys)
cat("\n... Perceived Choice", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PC")), keys = inv_keys)
cat("\n... Perceived Choice", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PC"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## reliability analysis - Pressure/Tension
inv_keys = c()
alpha_mod <- alpha(select(rdatIMI, ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("PT")), keys = inv_keys)
cat("\n... Pressure/Tension", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["PT"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

## reliability analysis - Effort/Importance
inv_keys = c("Item07EI")
alpha_mod <- alpha(select(rdatIMI, ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " ...\n"); summary(alpha_mod)
alpha_non_mod <- alpha(select(rdatIMI[rdatIMI$Type=="non-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "w/o-gamified", " ...\n"); summary(alpha_non_mod)
alpha_ont_mod <- alpha(select(rdatIMI[rdatIMI$Type=="ont-gamified",], ends_with("EI")), keys = inv_keys)
cat("\n... Effort/Importance", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["EI"]] <- list(all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod)

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
  
  write_alpha_in_workbook(alpha_mods$EI$all, wb, "Effort/Importance", "EI")
  write_alpha_in_workbook(alpha_mods$EI$non, wb, "Effort/Importance in Non-Gamified CL Sessions", "EI non-gamified")
  write_alpha_in_workbook(alpha_mods$EI$ont, wb, "Effort/Importance in Gamified CL Sessions Using Ontologies", "EI ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}

