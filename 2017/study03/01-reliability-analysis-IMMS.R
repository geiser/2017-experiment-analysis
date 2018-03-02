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
datIMMS <- read_csv("data/SourceIMMS.csv")

## validating sampling adequacy and removing unaceptable sampling adequacy < 0.5
print(kmo_mod <- KMO(cor(select(datIMMS, starts_with("Item")))))
print(kmo_mod <- KMO(cor(select(datIMMS, starts_with("Item")
                                , -starts_with("Item03")
                                , -starts_with("Item11")
                                , -starts_with("Item21")))))

datIMMS <- select(datIMMS, starts_with("UserID"), starts_with("Type")
                 , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole")
                 , starts_with("Item")
                 , -starts_with("Item03"), -starts_with("Item11"), -starts_with("Item21"))

## inverted negative items and factors to simplify analysis using lavaan 
factanal(~Item01+Item05+Item08+Item09+Item16+Item18+Item20+Item23+Item25
         +Item04+Item06+Item10+Item12+Item15+Item19+Item24
         +Item02+Item07+Item13+Item14+Item17+Item22
         , factors=3, data=datIMMS)


## cfa to verify if relability analysis can be done
model <- '
f1 =~ Item01+Item05+Item08+Item09+Item16+Item18+Item20+Item23+Item25
f2 =~ Item04+Item06+Item10+Item12+Item15+Item19+Item24
f3 =~ Item02+Item07+Item13+Item14+Item17+Item22
'
cfa_mod <- cfa(model, data=datIMMS, std.lv=T, orthogonal=F, missing="fiml")
summary(cfa_mod, fit.measures=T, standardized=T)

factanal(~Item01+Item05+Item08+Item09+Item16+Item18+Item20+Item23+Item25
         +Item04+Item06+Item10+Item12+Item15+Item19+Item24
         +Item02+Item07+Item13+Item14+Item17+Item22
         , factors=3, data=datIMMS)

# removing items with loading < 0.4
factanal(~Item01+Item05+Item08+Item09+Item16+Item18+Item20+Item25
         +Item04+Item06+Item10+Item12+Item15+Item19+Item24
         +Item02+Item07+Item13+Item14+Item17+Item22
         , factors=3, data=datIMMS)

# removing cross loading items with a difference less than 0.2
factanal(~Item01+Item09+Item16+Item18+Item20+Item25
         +Item04+Item06+Item12
         +Item02+Item07+Item13
         , factors=3, data=datIMMS)

factanal(~Item20+Item25+Item18+Item07+Item13+Item04
         +Item02+Item01
         +Item09+Item06+Item12
         , factors=3, data=datIMMS) # sort according loading

# removing items doesn't fit by meaning and consulting with psychometrics
factanal(~Item20+Item25+Item18+Item07+Item04
         +Item02+Item01
         +Item09+Item06+Item12
         , factors=3, data=datIMMS) 

model <- '
f1 =~ Item20+Item25+Item18+Item07+Item04
f2 =~ Item02+Item01
f3 =~ Item09+Item06+Item12
' # f1=attention, f2=satisfaction, f3=relevance
cfa_mod <- cfa(model, data=datIMMS, std.lv=T, orthogonal=F, missing="fiml")
summary(cfa_mod, fit.measures=T, standardized=T)

datIMMS <- select(
  datIMMS, starts_with("UserID"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole")
  , starts_with("Item20"), starts_with("Item25"), starts_with("Item18"), starts_with("Item07"), starts_with("Item04")
  , starts_with("Item01"), starts_with("Item02")
  , starts_with("Item09"), starts_with("Item06"), starts_with("Item12")
)

## factorial analysis with nfactor=3
(fa_mod <- fa(select(datIMMS, starts_with("Item")), nfactors = 3, rotate = "varimax"))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdatIMMS <- select(
  datIMMS, starts_with("UserID"), starts_with("NroUSP"), starts_with("Type")
  , starts_with("CLGroup"), starts_with("CLRole"), starts_with("PlayerRole"))
rdatIMMS["Item20A"] <- datIMMS["Item20"]
rdatIMMS["Item25A"] <- datIMMS["Item25"]
rdatIMMS["Item18A"] <- datIMMS["Item18"]
rdatIMMS["Item07A"] <- datIMMS["Item07"]
rdatIMMS["Item04A"] <- datIMMS["Item04"]

rdatIMMS["Item01S"] <- datIMMS["Item01"]
rdatIMMS["Item02S"] <- datIMMS["Item02"]

rdatIMMS["Item09R"] <- datIMMS["Item09"]
rdatIMMS["Item06R"] <- datIMMS["Item06"]
rdatIMMS["Item12R"] <- datIMMS["Item12"]

if (!file.exists('data/IMMS.csv')) {
  write_csv(rdatIMMS, path = 'data/IMMS.csv')
}
alpha_mods <- list()

inv_keys <- c("Item09R","Item06R")
## Level of Motivation
alpha_mod <- alpha(select(rdatIMMS, starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], starts_with("Item")), keys = inv_keys)
cat("\n... Level of Motivation", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["LM"]] <- list(lbl = 'Level of Motivation', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c()
## Attention
alpha_mod <- alpha(select(rdatIMMS, ends_with("A")))
cat("\n... Attention", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("A")))
cat("\n... Attention", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["A"]] <- list(lbl = 'Attention', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c()
## Satisfaction
alpha_mod <- alpha(select(rdatIMMS, ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("S")), keys = inv_keys)
cat("\n... Satisfaction", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["S"]] <- list(lbl = 'Satisfaction', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

inv_keys = c("Item09R","Item06R")
## Relevance
alpha_mod <- alpha(select(rdatIMMS, ends_with("R")), keys = inv_keys)
cat("\n... Relevance", " ...\n"); summary(alpha_mod)
alpha_wo_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="w/o-gamified",], ends_with("R")), keys = inv_keys)
cat("\n... Relevance", " >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
alpha_ont_mod <- alpha(select(rdatIMMS[rdatIMMS$Type=="ont-gamified",], ends_with("R")), keys = inv_keys)
cat("\n... Relevance", " >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)

alpha_mods[["R"]] <- list(lbl = 'Relevance', all = alpha_mod, wo = alpha_wo_mod, ont = alpha_ont_mod)

## Write results in an Excel Workbook
if (!file.exists("report/reliability-analysis/IMMS.xlsx")) {
  filename <- "report/reliability-analysis/IMMS.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_cfa_in_workbook(cfa_mod, wb)
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
  
  write_alpha_in_workbook(alpha_mods$R$all, wb, "Relevance", "R")
  write_alpha_in_workbook(alpha_mods$R$wo, wb, "Relevance in Gamified CL Sessions Without Ontologies", "R wo-gamified")
  write_alpha_in_workbook(alpha_mods$R$ont, wb, "Relevance in Gamified CL Sessions Using Ontologies", "R ont-gamified")
  
  xlsx::saveWorkbook(wb, filename)
}

# Export summary in latex format
filename <- "report/latex/IMMS-reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese version of IMMS questionnaire"
    , filename = filename
    , key_labels = list('Total' = 'all', 'Ont-Gamified' = 'ont', 'W/O-Gamified'='wo')
  )
}

