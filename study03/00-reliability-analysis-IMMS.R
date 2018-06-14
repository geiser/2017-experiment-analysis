library(readr)
library(dplyr)
library(psych)
library(lavaan)
library(ggraph)
library(semPlot)

library(MVN)
library(daff)
library(robustHD)

sdat <- read_csv('../data/IMMS.csv')
sdat <- sdat[which(sdat$Study == 'third'),]
sdat$Study <- NULL

participants <- read_csv('data/SignedUpParticipants.csv')
sdat <- merge(participants, sdat, by = 'UserID')

############################################################################
## Check Assumptions to Reliability Analysis                              ##
############################################################################

png(filename = "report/reliability-analysis/univariate-histogram-IMMS.png", width = 840, height = 840)
(mvn_mod <- mvn(select(sdat, starts_with("Item")), multivariateOutlierMethod = "adj", univariatePlot = "histogram", showOutliers = T))
dev.off()

estimator_cfa <- "WLSMVS" # for non-normal and ordinal data

## kmo factor adequacy
(kmo_mod <- KMO(cor(select(sdat, starts_with("Item")))))

## factorial analysis
(fa_mod <- fa(select( 
  sdat
  , starts_with("Item12A"), starts_with("Item19A"), starts_with("Item04A"), starts_with("Item20A"), starts_with("Item16A"), starts_with("Item01A")
  , starts_with("Item15R"), starts_with("Item21R"), starts_with("Item10R"), starts_with("Item08R")
  , starts_with("Item13S"), starts_with("Item14S"), starts_with("Item17S")
), nfactors = 4, rotate = "varimax"))

## validating models where orthogonal means no correlation between factors
bifactor_mdl <- '
A =~ a*Item12A + a*Item19A + a*Item04A + a*Item20A + a*Item16A + a*Item01A
R =~ b*Item15R + b*Item21R + b*Item10R + b*Item08R
S =~ c*Item13S + c*Item14S + c*Item17S
LM =~ Item12A + Item19A + Item04A + Item20A + Item16A + Item01A +
Item15R + Item21R + Item10R + Item08R +
Item13S + Item14S + Item17S
'

# select second-order model to measure intrinsic motivation
(cfa_mod <- cfa(bifactor_mdl, data = sdat, std.lv = T, estimator = estimator_cfa))

############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

inv_keys <- c("Item15R", "Item21R", "Item10R", "Item08R")
(alpha_mod <- psych::alpha(select(sdat, starts_with("Item")), keys = inv_keys))

rdat <- sdat # non-one item needs to be removed
if (!file.exists('data/IMMS.csv')) {
  write_csv(rdat, path = 'data/IMMS.csv')
}

# calculating alphas
alpha_mods <- lapply(
  list(
    "LM" = list(
      id = "LM",
      dat = select(rdat, starts_with("Type"), starts_with("Item")),
      lbl = "Level of Motivation",
      inv_keys = c("Item15R", "Item21R", "Item10R", "Item08R")),
    "A" = list(
      id = "A",
      dat = select(rdat, starts_with("Type"), ends_with("A")),
      lbl = "Attention",
      inv_keys = c()),
    "R" = list(
      id = "R",
      dat = select(rdat, starts_with("Type"), ends_with("R")),
      lbl = "Relevance",
      inv_keys = c()),
    "S" = list(
      id = "S",
      dat = select(rdat, starts_with("Type"), ends_with("S")),
      lbl = "Satisfaction",
      inv_keys = c())
  )
  , FUN = function(x) {
    alpha_mod <- psych::alpha(select(x$dat, starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    alpha_ont_mod <- psych::alpha(select(x$dat[x$dat$Type=="ont-gamified",], starts_with("Item")), keys = x$inv_keys)
    alpha_wo_mod <- psych::alpha(select(x$dat[x$dat$Type=="w/o-gamified",], starts_with("Item")), keys = x$inv_keys)
    
    cat("\n... ", x$lbl, " ...\n"); summary(alpha_mod)
    cat("\n... ", x$lbl," >> ", "ont-gamified", " ...\n"); summary(alpha_ont_mod)
    cat("\n... ", x$lbl," >> ", "w/o-gamified", " ...\n"); summary(alpha_wo_mod)
    
    return(list(id = x$id, lbl = x$lbl, all = alpha_mod, ont = alpha_ont_mod, wo = alpha_wo_mod))
  })

## Write results in an Excel Workbook
filename <- "report/reliability-analysis/IMMS.xlsx"
if (!file.exists(filename)) {
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  lapply(alpha_mods, FUN = function(mod){
    write_alpha_in_workbook(mod$all, wb, mod$lbl, mod$id)
    write_alpha_in_workbook(mod$ont, wb, paste(mod$lbl, "in Ont-Gamified CL Sessions"), paste(mod$id, "ont-gamified"))
    write_alpha_in_workbook(mod$wo, wb, paste(mod$lbl, "in CL Sessions that had been gamified without using Ontologies"), paste(mod$id, "wo-gamified"))
  })
  
  xlsx::saveWorkbook(wb, filename)
}

# Export summaries in latex format
filename <- "report/latex/IMMS-reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese IMMS"
    , filename = filename
    , key_labels = list('Global'='all', 'Ont-Gamified'='ont','W/O-Gamified'='wo')
    , robust = T
  )
}

