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

wdat <- read_csv('data/WinsorizedIMMS.csv')

############################################################################
## Check Assumptions to Reliability Analysis                              ##
############################################################################

png(filename = "report/validation-IMMS/univariate-histogram.png", width = 840, height = 840)
(mvn_mod <- mvn(select(wdat, starts_with("Item")), multivariateOutlierMethod = "adj", univariatePlot = "histogram", showOutliers = T))
dev.off()

estimator_cfa <- "WLSMVS" # for non-normal and ordinal data

## kmo factor adequacy
(kmo_mod <- KMO(cor(select(wdat, starts_with("Item")))))

## factorial analysis
factanal(~Item01+Item02+Item03+Item04+Item06+Item07+Item08+Item09
         +Item10+Item11+Item12+Item13+Item14+Item15+Item16+Item17
         +Item18+Item19+Item20+Item21+Item22+Item23+Item24+Item25+Item26
         , factors=3, data=wdat, rotation = "varimax")

# removing items with loading less than < 0.4 
factanal(~Item01+Item02+Item03+Item04+Item06+Item07+Item08+Item09
         +Item10+Item11+Item12+Item13+Item14+Item15+Item16+Item17
         +Item19+Item20+Item21+Item22+Item24+Item25+Item26
         , factors=3, data=wdat, rotation = "varimax")

# removing crosloading items with loading less than < 0.2
factanal(~Item01+Item04+Item08
         +Item10+Item12+Item13+Item14+Item15+Item16+Item17
         +Item19+Item20+Item21
         , factors=3, data=wdat, rotation = "varimax")

factanal(~Item12+Item19+Item04+Item20+Item16+Item01
         +Item15+Item21+Item10+Item08
         +Item13+Item14+Item17
         , factors=3, data=wdat, rotation = "varimax")

# first eingenvalue between 3 to 5 then
# we removed items that don't fit with the help of psychometrics
factanal(~Item12+Item19+Item04+Item20+Item16+Item01 # A: Attention
         +Item15+Item21+Item10+Item08 # R: relevance
         +Item13+Item14+Item17 # S: satisfaction
         , factors=3, data=wdat, rotation = "varimax")

(fa_mod <- fa(select( 
  wdat
  , starts_with("Item12"), starts_with("Item19"), starts_with("Item04"), starts_with("Item20"), starts_with("Item16"), starts_with("Item01")
  , starts_with("Item15"), starts_with("Item21"), starts_with("Item10"), starts_with("Item08")
  , starts_with("Item13"), starts_with("Item14"), starts_with("Item17")
), nfactors = 3, rotate = "varimax"))

## validating models where orthogonal means no correlation between factors

multi_mdl <- '
A =~ Item12 + Item19 + Item04 + Item20 + Item16 + Item01
R =~ Item15 + Item21 + Item10 + Item08
S =~ Item13 + Item14 + Item17
'
second_mdl <- '
A =~ Item12 + Item19 + Item04 + Item20 + Item16 + Item01
R =~ Item15 + Item21 + Item10 + Item08
S =~ Item13 + Item14 + Item17
LM =~ NA*A + R + S
LM ~~ 1*LM
'
bifactor_mdl <- '
A =~ a*Item12 + a*Item19 + a*Item04 + a*Item20 + a*Item16 + a*Item01
R =~ b*Item15 + b*Item21 + b*Item10 + b*Item08
S =~ c*Item13 + c*Item14 + c*Item17
LM =~ Item12 + Item19 + Item04 + Item20 + Item16 + Item01 +
Item15 + Item21 + Item10 + Item08 +
Item13 + Item14 + Item17
'

(fitMeasures_df <- do.call(rbind, lapply(
  list(
    "Global sample" = list(
      dat = wdat,
      mdls = list(
        "Multidimensional model" = list(mdl = multi_mdl, plotFile = "report/validation-IMMS/multidimensional-model.png")
        , "Second-order model" = list(dat = wdat, mdl = second_mdl, plotFile = "report/validation-IMMS/second-order-factor-model.png")
        , "Bi-factor model" = list(dat = wdat, mdl = bifactor_mdl, plotFile = "report/validation-IMMS/bi-factor-model.png")))
    , "Second study" = list(
      dat = wdat[which(wdat$Study=="second"),],
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
        return(
          get_fitMeasures(dat = s$dat, mdl = x$mdl
                          , estimator = estimator_cfa, plotFile = x$plotFile)
          )
      }
    ))
    return(rbind(c(NA), fit_df))
  }))
)

# select bi-factor model to measure the level of motivation
(cfa_mod <- cfa(bifactor_mdl, data = wdat, std.lv = T, estimator = estimator_cfa))


############################################################################
## Reliability Analysis Using Cronbach's alpha                            ##
############################################################################

rdat <- select(wdat, starts_with("Study"), starts_with("UserID"))
rdat["Item12A"] <- wdat["Item12"]
rdat["Item19A"] <- wdat["Item19"]
rdat["Item04A"] <- wdat["Item04"]
rdat["Item20A"] <- wdat["Item20"]
rdat["Item16A"] <- wdat["Item16"]
rdat["Item01A"] <- wdat["Item01"]

rdat["Item15R"] <- wdat["Item15"] 
rdat["Item21R"] <- wdat["Item21"]
rdat["Item10R"] <- wdat["Item10"]
rdat["Item08R"] <- wdat["Item08"]

rdat["Item13S"] <- wdat["Item13"]
rdat["Item14S"] <- wdat["Item14"]
rdat["Item17S"] <- wdat["Item17"]

rdat <- dplyr::mutate(
  rdat
  , `Attention` = (rdat$Item12A+rdat$Item19A+rdat$Item04A+rdat$Item20A+rdat$Item16A+rdat$Item01A)/6
  , `Relevance` = (32-(rdat$Item15R+rdat$Item21R+rdat$Item10R+rdat$Item08R))/4
  , `Satisfaction` = (rdat$Item13S+rdat$Item14S+rdat$Item17S)/3
)
rdat <- dplyr::mutate(
  rdat
  , `Level of Motivation` = ((6*rdat$Attention)+(4*rdat$Relevance)+(3*rdat$Satisfaction))/13
)
if (!file.exists('data/IMMS.csv')) {
  write_csv(rdat, path = 'data/IMMS.csv')
}

alpha_mods <- lapply(
  list(
    "LM" = list(
      id = "LM",
      dat = select(rdat, starts_with("Study"), starts_with("Item")),
      lbl = "Level of Motivation",
      inv_keys = c("Item15R", "Item21R", "Item10R", "Item08R")),
    "A" = list(
      id = "A",
      dat = select(rdat, starts_with("Study"), ends_with("A")),
      lbl = "Attention",
      inv_keys = c()),
    "R" = list(
      id = "R",
      dat = select(rdat, starts_with("Study"), ends_with("R")),
      lbl = "Relevance",
      inv_keys = c()),
    "S" = list(
      id = "S",
      dat = select(rdat, starts_with("Study"), ends_with("S")),
      lbl = "Satisfaction",
      inv_keys = c())
    )
  , FUN = function(x) {
    alpha_mod <- psych::alpha(select(x$dat, starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    alpha_second_mod <- psych::alpha(select(x$dat[x$dat$Study=="second",], starts_with("Item")), keys = x$inv_keys, check.keys=T)
    alpha_third_mod <- psych::alpha(select(x$dat[x$dat$Study=="third",], starts_with("Item")), keys = x$inv_keys, check.keys=T)
    
    cat("\n... ", x$lbl, " ...\n"); summary(alpha_mod)
    cat("\n... ", x$lbl," >> ", "second", " ...\n"); summary(alpha_second_mod)
    cat("\n... ", x$lbl," >> ", "third", " ...\n"); summary(alpha_third_mod)
    
    return(list(id = x$id, lbl = x$lbl, all = alpha_mod, second = alpha_second_mod, third = alpha_third_mod))
  })

## Write results in an Excel Workbook
if (!file.exists("report/validation-IMMS/RelAnalysis.xlsx")) {
  filename <- "report/validation-IMMS/RelAnalysis.xlsx"
  wb <- createWorkbook(type="xlsx")
  
  write_kmo_in_workbook(kmo_mod, wb)
  write_fa_in_workbook(fa_mod, wb)
  lapply(alpha_mods, FUN = function(mod){
    write_alpha_in_workbook(mod$all, wb, mod$lbl, mod$id)
    write_alpha_in_workbook(mod$second, wb, paste(mod$lbl, "in Second Empirical Study"), paste(mod$id, "second study"))
    write_alpha_in_workbook(mod$third, wb, paste(mod$lbl, "in Third Empirical Study"), paste(mod$id, "third study"))
  })
  
  xlsx::saveWorkbook(wb, filename)
}

# Export summaries in latex format
write_cfa_model_fits_in_latex(
  fitMeasures_df
  , in_title = "in the validation of the adapted Portuguese IMMS"
  , filename = "report/validation-IMMS/cfa-model-fit.tex")

filename <- "report/validation-IMMS/reliability-analysis.tex"
if (!file.exists(filename)) {
  write_rel_analysis_in_latex(
    fa_mod, cfa_mod, alpha_mods
    , in_title = "adapted Portuguese IMMS"
    , filename = filename
    , key_labels = list('Global'='all', 'Second Study'='second', 'Third Study'='third')
    , robust = T
  )
}

