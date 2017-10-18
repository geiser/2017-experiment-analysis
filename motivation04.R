
###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMI <- dplyr::mutate(rdatIMI
, `Interest/Enjoyment` = (rdatIMI$Item08
                          +rdatIMI$Item09
                          +rdatIMI$Item11
                          +rdatIMI$Item12
                          +rdatIMI$Item21
                          +rdatIMI$Item24)/6
, `Perceived Choice` = (40-(rdatIMI$Item03
                            +rdatIMI$Item05
                            +rdatIMI$Item13
                            +rdatIMI$Item18
                            +rdatIMI$Item20))/5
, `Pressure/Tension` = (rdatIMI$Item02
                        +rdatIMI$Item04
                        +rdatIMI$Item06
                        +8-rdatIMI$Item23)/4
, `Effort/Importance` = (rdatIMI$Item14
                         +rdatIMI$Item22
                         +16-(rdatIMI$Item01
                              +rdatIMI$Item19))/4
)

rdatIMI <- dplyr::mutate(rdatIMI
, `Intrinsic Motivation` = (6*rdatIMI$`Interest/Enjoyment`
                            +5*rdatIMI$`Perceived Choice`
                            +4*rdatIMI$`Effort/Importance`
                            +32-4*rdatIMI$`Pressure/Tension`)/19
)

## performing tests in each factor IMI
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Interest/Enjoyment`
, alternative = "greater", title = "Interest/Enjoyment", inv.col = TRUE)
cat("Interest/Enjoyment", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Perceived Choice`
, alternative = "greater", title = "Perceived Choice", inv.col = TRUE)
cat("Perceived Choice", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Pressure/Tension`
, alternative = "less", title = "Pressure/Tension", inv.col = TRUE)
cat("Pressure/Tension", "\n"); wt
wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Effort/Importance`
, alternative = "greater", title = "Effort/Importance", inv.col = TRUE)
cat("Effort/Importance", "\n"); wt

wt <- wilcox_analysis(rdatIMI$Type, rdatIMI$`Intrinsic Motivation`
, alternative = "greater", title = "Intrinsic Motivation", inv.col = TRUE)
cat("Intrinsic Motivation", "\n"); wt

###############################################################
## ARCS IMMS                                                 ##
###############################################################


respIMMS <- select(respIMMS, starts_with("UserID"), starts_with("Item"))

## gather data from csv files
activities <- read_csv('2017-CLActivity03.csv')

## combine data for analysis
datIMMS <- merge(
  select(participants
         , starts_with("UserID")
         , starts_with("Type")
         , starts_with("CLRole")
         , starts_with("PlayerRole")
  ),
  select(activities
         , starts_with("UserID")
         , starts_with("ParticipationLevel")
  ), by = "UserID")
datIMMS <- merge(datIMMS, select(respIMMS, starts_with("UserID"), starts_with("Item")), by = "UserID")


###############################################################
## Reliability Analysis via Exploratory Factorial Analysis   ##
###############################################################

library(psych)


###############################################################
## Wilconxon Analysis                                        ##
###############################################################

rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Attention` = (rdatIMMS$Item18
                                           +rdatIMMS$Item25
                                           +rdatIMMS$Item20
                                           +rdatIMMS$Item07
                                           +rdatIMMS$Item13)/5
                          , `Satisfaction` = (rdatIMMS$Item01
                                              +rdatIMMS$Item02
                                              +rdatIMMS$Item05
                                              +8-rdatIMMS$Item21)/4
)
rdatIMMS <- dplyr::mutate(rdatIMMS
                          , `Level of Motivation` = (rdatIMMS$Attention*5
                                                     +rdatIMMS$Satisfaction*4)/9
)

## performing tests in each factor
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Attention`
                      , alternative = "less", title = "Attention", inv.col = T)
cat("Attention", "\n"); wt
wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Satisfaction`
                      , alternative = "greater", title = "Satisfaction", inv.col = T)
cat("Satisfaction", "\n"); wt

wt <- wilcox_analysis(rdatIMMS$Type, rdatIMMS$`Level of Motivation`
                      , alternative = "greater", title = "Level of Motivation", inv.col = T)
cat("Level of Motivation", "\n"); wt

