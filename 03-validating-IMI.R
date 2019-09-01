wants <- c('readr','dplyr','psych','lavaan','ggraph','semPlot','robustHD')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

source('common/reliability-analysis.R')

library(readr)
library(dplyr)
library(psych)
library(lavaan)
library(ggraph)
library(semPlot)

library(MVN)
library(daff)
library(robustHD)

wdat <- read_csv('data/WinsorizedIMI.csv')

############################################################################
## Check Assumptions to Reliability Analysis                              ##
############################################################################

png(filename = "report/validation-IMI/univariate-histogram.png", width = 840, height = 840)
(mvn_mod <- mvn(select(wdat, starts_with("Item")), multivariateOutlierMethod = "adj", univariatePlot = "histogram", showOutliers = T))
dev.off()

estimator_cfa <- "WLSMVS" # for non-normal and ordinal data

## kmo factor adequacy
(kmo_mod <- KMO(cor(select(wdat, starts_with("Item")))))

## factorial analysis
factanal(~Item01+Item02+Item03+Item04+Item05+Item06+Item07+Item08
         +Item09+Item10+Item11+Item12+Item13+Item14+Item15+Item16
         +Item17+Item18+Item19+Item20+Item21+Item22+Item23+Item24
         , factors=4, data=wdat, rotation = "varimax")

factanal(~Item22+Item09+Item12+Item24+Item21+Item01+Item04
         +Item17+Item15+Item06+Item02+Item08+Item19
         +Item16+Item14+Item18+Item11
         +Item13+Item03+Item07
         +Item05+Item10+Item20+Item23
         , factors=4, data=wdat, rotation = "varimax")

# non one item less than < 0.4 loading had been removed

# removing crosloading items with loading less than < 0.2
factanal(~Item22+Item09+Item12+Item24+Item21+Item01+Item04
         +Item17+Item15+Item06+Item02+Item08+Item19
         +Item16+Item14+Item18+Item11
         +Item13+Item03+Item07
         , factors=4, data=wdat, rotation = "varimax")

# first eingenvalue between 3 to 5 then
# we removed items that don't fit by meaning based on consult with psychometrics
factanal(~Item22+Item09+Item12+Item24+Item21+Item01 # IE: Interest/Enjoyment
         +Item17+Item15+Item06+Item02+Item08 # PC: Perceived Competence
         +Item16+Item14+Item18+Item11 # PT: Pressure/Tension
         +Item13+Item03+Item07  # EI: Effort/Importance
         , factors=4, data=wdat, rotation = "varimax")

(fa_mod <- fa(select( 
  wdat
  , starts_with("Item22"), starts_with("Item09"), starts_with("Item12"), starts_with("Item24"), starts_with("Item21"), starts_with("Item01")
  , starts_with("Item17"), starts_with("Item15"), starts_with("Item06"), starts_with("Item02"), starts_with("Item08")
  , starts_with("Item16"), starts_with("Item14"), starts_with("Item18"), starts_with("Item11")
  , starts_with("Item13"), starts_with("Item03"), starts_with("Item07")
), nfactors = 4, rotate = "varimax"))

## validating models where orthogonal means no correlation between factors

multi_mdl <- '
IE =~ Item22+Item09+Item12+Item24+Item21+Item01
PC =~ Item17+Item15+Item06+Item02+Item08
PT =~ Item16+Item14+Item18+Item11
EI =~ Item13+Item03+Item07
'
second_mdl <- '
IE =~ Item22 + Item09 + Item12 + Item24 + Item21 + Item01
PC =~ Item17 + Item15 + Item06 + Item02 + Item08
PT =~ Item16 + Item14 + Item18 + Item11
EI =~ Item13 + Item03 + Item07
IM =~ NA*IE + PC + PT + EI
IM ~~ 1*IM
'
bifactor_mdl <- '
IE =~ a*Item22 + a*Item09 + a*Item12 + a*Item24 + a*Item21 + a*Item01
PC =~ b*Item17 + b*Item15 + b*Item06 + b*Item02 + b*Item08
PT =~ c*Item16 + c*Item14 + c*Item18 + c*Item11
EI =~ d*Item13 + d*Item03 + d*Item07
IM =~ Item22 + Item09 + Item12 + Item24 + Item21 + Item01 +
Item17 + Item15 + Item06 + Item02 + Item08 +
Item16 + Item14 + Item18 + Item11 +
Item13 + Item03 + Item07
'

(fitMeasures_df <- do.call(rbind, lapply(
  list(
    "Global sample" = list(
      dat = wdat,
      mdls = list(
        "Multidimensional model" = list(mdl = multi_mdl, plotFile = "multidimensional-model.png")
        , "Second-order model" = list(dat = wdat, mdl = second_mdl, plotFile = "second-order-factor-model.png")
        , "Bi-factor model" = list(dat = wdat, mdl = bifactor_mdl, plotFile = "bi-factor-model.png")))
    , "Pilot-study" = list(
      dat = wdat[which(wdat$Study=="pilot"),],
      mdls = list(
        "Multidimensional model" = list(mdl = multi_mdl)
        , "Second-order model" = list(mdl = second_mdl)
        , "Bi-factor model" = list(mdl = bifactor_mdl)))
    , "First study" = list(
      dat = wdat[which(wdat$Study=="first"),],
      mdls = list(
        "Multidimensional model" = list(mdl = multi_mdl)
        , "Second-order model" = list(mdl = second_mdl)
        , "Bi-factor model" = list(mdl = bifactor_mdl)))
    , "Third study" = list(
      dat = wdat[which(wdat$Study=="third"),],
      mdls = list(
        "Multidimensional model" = list(mdl = multi_mdl)
        , "Second-order model" = list(mdl = second_mdl)
        , "Bi-factor model" = list(mdl = bifactor_mdl)))
  )
  , FUN = function(s) {
    fit_df <- do.call(rbind, lapply(
      s$mdls
      , FUN = function(x) {
        return(get_fitMeasures(dat = s$dat, mdl = x$mdl, estimator = estimator_cfa))
      }
    ))
    return(rbind(c(NA), fit_df))
  }))
)

# select second-order model to measure intrinsic motivation
(cfa_mod <- cfa(second_mdl, data = wdat, std.lv = T, estimator = estimator_cfa))


############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdat <- select(wdat, starts_with("Study"), starts_with("UserID"))
rdat["Item22IE"] <- wdat["Item22"]
rdat["Item09IE"] <- wdat["Item09"]
rdat["Item12IE"] <- wdat["Item12"]
rdat["Item24IE"] <- wdat["Item24"]
rdat["Item21IE"] <- wdat["Item21"]
rdat["Item01IE"] <- wdat["Item01"]

rdat["Item17PC"] <- wdat["Item17"]
rdat["Item15PC"] <- wdat["Item15"]
rdat["Item06PC"] <- wdat["Item06"]
rdat["Item02PC"] <- wdat["Item02"]
rdat["Item08PC"] <- wdat["Item08"]

rdat["Item16PT"] <- wdat["Item16"]
rdat["Item14PT"] <- wdat["Item14"]
rdat["Item18PT"] <- wdat["Item18"]
rdat["Item11PT"] <- wdat["Item11"]

rdat["Item13EI"] <- wdat["Item13"]
rdat["Item03EI"] <- wdat["Item03"]
rdat["Item07EI"] <- wdat["Item07"]

rdat <- dplyr::mutate(
  rdat
  , `Interest/Enjoyment` = (rdat$Item22IE+rdat$Item09IE+rdat$Item12IE+rdat$Item24IE+rdat$Item21IE+rdat$Item01IE)/6
  , `Perceived Choice` = (40-(rdat$Item17PC+rdat$Item15PC+rdat$Item06PC+rdat$Item02PC+rdat$Item08PC))/5
  , `Pressure/Tension` = (rdat$Item16PT+rdat$Item14PT+rdat$Item18PT+8-rdat$Item11PT)/4
  , `Effort/Importance` = (rdat$Item03EI+16-(rdat$Item13EI+rdat$Item07EI))/3
)
rdat <- dplyr::mutate(
  rdat
  , `Intrinsic Motivation` = (rdat$`Interest/Enjoyment`
                              +rdat$`Perceived Choice`
                              +rdat$`Effort/Importance`
                              +8-(rdat$`Pressure/Tension`))/4
)
if (!file.exists('data/IMI.csv')) {
  write_csv(rdat, path = 'data/IMI.csv')
}

alpha_mods <- lapply(
  list(
    "IM" = list(
      id = "IM",
      dat = select(rdat, starts_with("Study"), starts_with("Item")),
      lbl = "Intrinsic Motivation",
      inv_keys = c("Item17PC", "Item15PC", "Item06PC", "Item02PC", "Item08PC"
                   , "Item16PT", "Item14PT", "Item18PT"
                   , "Item13EI", "Item07EI")),
    "IE" = list(
      id = "IE",
      dat = select(rdat, starts_with("Study"), ends_with("IE")),
      lbl = "Interest/Enjoyment",
      inv_keys = c()),
    "PC" = list(
      id = "PC",
      dat = select(rdat, starts_with("Study"), ends_with("PC")),
      lbl = "Perceived Choice",
      inv_keys = c()),
    "PT" = list(
      id = "PT",
      dat = select(rdat, starts_with("Study"), ends_with("PT")),
      lbl = "Pressure/Tension",
      inv_keys = c("Item11PT")),
    "EI" = list(
      id = "EI",
      dat = select(rdat, starts_with("Study"), ends_with("EI")),
      lbl = "Effort/Importance",
      inv_keys = c("Item13EI", "Item07EI"))
    )
  , FUN = function(x) {
    alpha_mod <- psych::alpha(select(x$dat, starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    alpha_pilot_mod <- psych::alpha(select(x$dat[x$dat$Study=="pilot",], starts_with("Item")), keys = x$inv_keys, check.keys=T)
    alpha_first_mod <- psych::alpha(select(x$dat[x$dat$Study=="first",], starts_with("Item")), keys = x$inv_keys, check.keys=T)
    alpha_third_mod <- psych::alpha(select(x$dat[x$dat$Study=="third",], starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    cat("\n... ", x$lbl, " ...\n"); summary(alpha_mod)
    cat("\n... ", x$lbl," >> ", "pilot", " ...\n"); summary(alpha_pilot_mod)
    cat("\n... ", x$lbl," >> ", "first", " ...\n"); summary(alpha_first_mod)
    cat("\n... ", x$lbl," >> ", "third", " ...\n"); summary(alpha_third_mod)
    
    return(list(id = x$id, lbl = x$lbl, all = alpha_mod, pilot = alpha_pilot_mod, first = alpha_first_mod, third = alpha_third_mod))
  })

## Write results in an Excel Workbook
if (!file.exists("report/validation-IMI/RelAnalysis.xlsx")) {
  filename <- "report/validation-IMI/RelAnalysis.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  lapply(alpha_mods, FUN = function(mod){
    write_alpha_in_workbook(mod$all, wb, mod$lbl, mod$id)
    write_alpha_in_workbook(mod$pilot, wb, paste(mod$lbl, "in Pilot Study"), paste(mod$id, "pilot study"))
    write_alpha_in_workbook(mod$first, wb, paste(mod$lbl, "in First Empirical Study"), paste(mod$id, "first study"))
    write_alpha_in_workbook(mod$third, wb, paste(mod$lbl, "in Third Empirical Study"), paste(mod$id, "third study"))
  })
  
  xlsx::saveWorkbook(wb, filename)
}

# Export summaries in latex format
write_cfa_model_fits_in_latex(
  fitMeasures_df
  , in_title = "in the validation of the adapted Portuguese IMI"
  , filename = "report/validation-IMI/cfa-model-fit.tex")

filename <- "report/validation-IMI/reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese IMI"
    , filename = filename
    , key_labels = list('Global'='all', 'Pilot Study'='pilot'
                        ,'First Study'='first', 'Third Study'='third')
    , robust = T
  )
}

