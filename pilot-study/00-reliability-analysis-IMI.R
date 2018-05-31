library(readr)
library(dplyr)
library(psych)
library(lavaan)
library(ggraph)
library(semPlot)

library(MVN)
library(daff)
library(robustHD)

sdat <- read_csv('../data/IMI.csv')
sdat <- sdat[which(sdat$Study == 'pilot'),]
sdat$Study <- NULL

participants <- read_csv('data/SignedUpParticipants.csv')
sdat <- merge(participants, sdat, by = 'UserID')

############################################################################
## Check Assumptions to Reliability Analysis                              ##
############################################################################

png(filename = "report/reliability-analysis/univariate-histogram.png", width = 840, height = 840)
(mvn_mod <- mvn(select(sdat, starts_with("Item")), multivariateOutlierMethod = "adj", univariatePlot = "histogram", showOutliers = T))
dev.off()

estimator_cfa <- "WLSMVS" # for non-normal and ordinal data

## kmo factor adequacy
(kmo_mod <- KMO(cor(select(sdat, starts_with("Item")))))

## factorial analysis
(fa_mod <- fa(select( 
  sdat
  , starts_with("Item22"), starts_with("Item09"), starts_with("Item12"), starts_with("Item24"), starts_with("Item21"), starts_with("Item01")
  , starts_with("Item17"), starts_with("Item15"), starts_with("Item06"), starts_with("Item02"), starts_with("Item08")
  , starts_with("Item16"), starts_with("Item14"), starts_with("Item18"), starts_with("Item11")
  , starts_with("Item13"), starts_with("Item03"), starts_with("Item07")
), nfactors = 4, rotate = "varimax"))

## validating models where orthogonal means no correlation between factors
second_mdl <- '
IE =~ Item22IE + Item09IE + Item12IE + Item24IE + Item21IE + Item01IE
PC =~ Item17PC + Item15PC + Item06PC + Item02PC + Item08PC
PT =~ Item16PT + Item14PT + Item18PT + Item11PT
EI =~ Item13EI + Item03EI + Item07EI
IM =~ NA*IE + PC + PT + EI
IM ~~ 1*IM
'

# select second-order model to measure intrinsic motivation
(cfa_mod <- cfa(second_mdl, data = sdat, std.lv = T, estimator = estimator_cfa))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

inv_keys <- c("Item17PC", "Item15PC", "Item06PC", "Item02PC", "Item08PC"
             , "Item16PT", "Item14PT", "Item18PT"
             , "Item13EI", "Item07EI")
(alpha_mod <- psych::alpha(select(sdat, starts_with("Item")), keys = inv_keys))

rdat <- sdat # non-one item needs to be removed
if (!file.exists('data/IMI.csv')) {
  write_csv(rdat, path = 'data/IMI.csv')
}

# calculating alphas
alpha_mods <- lapply(
  list(
    "IM" = list(
      id = "IM",
      dat = select(rdat, starts_with("Type"), starts_with("Item")),
      lbl = "Intrinsic Motivation",
      inv_keys = c("Item17PC", "Item15PC", "Item06PC", "Item02PC", "Item08PC"
                   , "Item16PT", "Item14PT", "Item18PT"
                   , "Item13EI", "Item07EI")),
    "IE" = list(
      id = "IE",
      dat = select(rdat, starts_with("Type"), ends_with("IE")),
      lbl = "Interest/Enjoyment",
      inv_keys = c()),
    "PC" = list(
      id = "PC",
      dat = select(rdat, starts_with("Type"), ends_with("PC")),
      lbl = "Perceived Choice",
      inv_keys = c()),
    "PT" = list(
      id = "PT",
      dat = select(rdat, starts_with("Type"), ends_with("PT")),
      lbl = "Pressure/Tension",
      inv_keys = c("Item11PT")),
    "EI" = list(
      id = "EI",
      dat = select(rdat, starts_with("Type"), ends_with("EI")),
      lbl = "Effort/Importance",
      inv_keys = c("Item13EI", "Item07EI"))
  )
  , FUN = function(x) {
    alpha_mod <- psych::alpha(select(x$dat, starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    alpha_non_mod <- psych::alpha(select(x$dat[x$dat$Type=="non-gamified",], starts_with("Item")), keys = x$inv_keys)
    alpha_ont_mod <- psych::alpha(select(x$dat[x$dat$Type=="ont-gamified",], starts_with("Item")), keys = x$inv_keys)
    
    cat("\n... ", x$lbl, " ...\n"); summary(alpha_mod)
    cat("\n... ", x$lbl," >> ", "non-gamified", " ...\n"); summary(alpha_non_mod)
    cat("\n... ", x$lbl," >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)
    
    return(list(id = x$id, lbl = x$lbl, all = alpha_mod, non = alpha_non_mod, ont = alpha_ont_mod))
  })

## Write results in an Excel Workbook
filename <- "report/reliability-analysis/IMI.xlsx"
if (!file.exists(filename)) {
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  lapply(alpha_mods, FUN = function(mod){
    write_alpha_in_workbook(mod$all, wb, mod$lbl, mod$id)
    write_alpha_in_workbook(mod$non, wb, paste(mod$lbl, "in Non-Gamified CL Sessions"), paste(mod$id, "non-gamified"))
    write_alpha_in_workbook(mod$ont, wb, paste(mod$lbl, "in Ont-Gamified CL Sessions"), paste(mod$id, "ont-gamified"))
  })
  
  xlsx::saveWorkbook(wb, filename)
}

# Export summaries in latex format
filename <- "report/latex/IMI-reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese IMI"
    , filename = filename
    , key_labels = list('Global'='all', 'Non-Gamified'='non','Ont-Gamified'='ont')
    , robust = T
  )
}
