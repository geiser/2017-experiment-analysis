wants <- c('MVN', 'robustHD', 'daff', 'plyr', 'readr')
has <- wants %in% rownames(installed.packages())
if (any(!has)) install.packages(wants[!has])

library(MVN)
library(daff)
library(plyr)
library(readr)
library(dplyr)
library(robustHD)

############################################################################
## Winsorizing IMI data for validation                                    ##
############################################################################

sdatIMI <- do.call(rbind, lapply(
  list("pilot" = list(src = "pilot-study/data/SourceIMI.csv", name = "pilot")
       , "first" = list(src = "study01/data/SourceIMI.csv", name = "first")
       , "third" = list(src = "study03/data/SourceIMI.csv", name = "third"))
  , FUN = function(x) {
    dat <- as.data.frame(read_csv(x$src))
    rownames(dat) <- dat$UserID
    dat <- cbind("Study" = rep(x$name, nrow(dat)), select(dat, starts_with("UserID"), starts_with("Item")))
    return(dat)
  }))

# winsorize the data
rdatIMI <- sdatIMI
for (cname in colnames(rdatIMI)) {
  if (cname == "Study" || cname == "UserID") next
  rdatIMI[[cname]]  <- round(winsorize(rdatIMI[[cname]]))
}

filename <- 'data/WinsorizedIMI.csv'
if (!file.exists(filename)) {
  write_csv(rdatIMI, filename)
}

## write in latex
render_diff(wdatIMI <- diff_data(sdatIMI, rdatIMI))
filename <- 'report/latex/winsorized-IMI.tex'
write_winsorized_in_latex(
  wdatIMI, filename, in_title = "for the validation of adapted Portuguese IMI")



############################################################################
## Winsorizing IMMS data for validation                                    ##
############################################################################

sdatIMMS <- do.call(rbind.fill, lapply(
  list("second" = list(src = "study02/data/SourceIMMS.csv", name = "second")
       , "third" = list(src = "study03/data/SourceIMMS.csv", name = "third"))
  , FUN = function(x) {
    dat <- as.data.frame(read_csv(x$src))
    rownames(dat) <- dat$UserID
    dat <- cbind("Study" = rep(x$name, nrow(dat)), select(dat, starts_with("UserID"), starts_with("Item"), -starts_with("Item05")))
    return(dat)
  }))

# winsorize the data
rdatIMMS <- sdatIMMS
for (cname in colnames(rdatIMMS)) {
  if (cname == "Study" || cname == "UserID") next
  rdatIMMS[[cname]]  <- round(winsorize(rdatIMMS[[cname]]))
}

filename <- 'data/WinsorizedIMMS.csv'
if (!file.exists(filename)) {
  write_csv(rdatIMMS, filename)
}

## write in latex
render_diff(wdatIMMS <- diff_data(sdatIMMS, rdatIMMS))
filename <- 'report/latex/winsorized-IMMS.tex'
write_winsorized_in_latex(
  wdatIMMS, filename, in_title = "for the validation of adapted Portuguese IMMS")


