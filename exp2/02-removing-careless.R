library(readr)
library(dplyr)
library(careless)

##########################################################################
## Motivation Questionnaire for Case01                                  ##
##########################################################################

participant <- read_csv("case01/data/Participant.csv")
resp <- read_csv('case01/data/SourceIMIWithCareless.csv')

print(careless_info <- careless(select(resp, starts_with("Item")), append=FALSE))
resp_wo <- resp[!is.na(careless_info$longString),]
print(careless_info <- careless(select(resp_wo, starts_with("Item")), append=FALSE))
resp_wo <- resp_wo[!(careless_info$longString > 12),] #62,63

IMI <- merge(participant, select(resp_wo, starts_with("UserID"), starts_with("Item")), by="UserID")
if (!file.exists('case01/data/SourceIMI.csv')) write_csv(IMI, 'case01/data/SourceIMI.csv')

##########################################################################
## Motivation Questionnaire for Case02                                  ##
##########################################################################

participant <- read_csv("case02/data/Participant.csv")
resp <- read_csv('case02/data/SourceIMMSWithCareless.csv')

print(careless_info <- careless(select(resp, starts_with("Item")), append=FALSE))
resp_wo <- resp[!is.na(careless_info$longString),]
print(careless_info <- careless(select(resp_wo, starts_with("Item")), append=FALSE))
resp_wo <- resp_wo[!(careless_info$longString > 12),] #62,63

IMMS <- merge(participant, select(resp_wo, starts_with("UserID"), starts_with("Item")), by="UserID")

if (!file.exists('case02/data/SourceIMMS.csv')) write_csv(IMMS, 'case02/data/SourceIMMS.csv')

##########################################################################
## Motivation Questionnaire for Case03                                  ##
##########################################################################

participant <- read_csv("case03/data/Participant.csv")
resp <- read_csv('case03/data/SourceMotQuestWithCareless.csv')

print(careless_info <- careless(select(resp, -starts_with("UserID")), append=FALSE))
resp_wo <- resp[!(careless_info$longString > 24),] # 8,21,34,55

Quest <- merge(participant, resp_wo, by="UserID")
if (!file.exists('case03/data/SourceMotQuest.csv')) write_csv(Quest, 'case03/data/SourceMotQuest.csv')

respIMI <- mutate(resp_wo
                  , Item01=0+resp_wo$`345`
                  , Item02=0+resp_wo$`346`
                  , Item03=0+resp_wo$`347`
                  , Item04=0+resp_wo$`348`
                  , Item05=0+resp_wo$`349`
                  , Item06=0+resp_wo$`350`
                  , Item07=0+resp_wo$`351`
                  , Item08=0+resp_wo$`352`
                  , Item09=0+resp_wo$`353`
                  , Item10=0+resp_wo$`354`
                  , Item11=0+resp_wo$`355`
                  , Item12=0+resp_wo$`388`
                  , Item13=0+resp_wo$`390`
                  , Item14=0+resp_wo$`391`
                  , Item15=0+resp_wo$`392`
                  , Item16=0+resp_wo$`394`
                  , Item17=0+resp_wo$`395`
                  , Item18=0+resp_wo$`396`
                  , Item19=0+resp_wo$`397`
                  , Item20=0+resp_wo$`398`
                  , Item21=0+resp_wo$`399`
                  , Item22=0+resp_wo$`400`
                  , Item23=0+resp_wo$`401`
                  , Item24=0+resp_wo$`402`
)
respIMI <- select(respIMI, starts_with("UserID"), starts_with("Item"))
IMI <- merge(participant, respIMI, by="UserID")
if (!file.exists('case03/data/SourceIMI.csv')) write_csv(IMI, 'case03/data/SourceIMI.csv')

respIMMS <- mutate(resp_wo
                   , Item01=0+resp_wo$`332`
                   , Item02=0+resp_wo$`333`
                   , Item03=0+resp_wo$`334`
                   , Item04=0+resp_wo$`335`
                   , Item05=0+resp_wo$`336`
                   , Item06=0+resp_wo$`337`
                   , Item07=0+resp_wo$`338`
                   , Item08=0+resp_wo$`339`
                   , Item09=0+resp_wo$`340`
                   , Item10=0+resp_wo$`341`
                   , Item11=0+resp_wo$`342`
                   , Item12=0+resp_wo$`343`
                   , Item13=0+resp_wo$`344`
                   , Item14=0+resp_wo$`389`
                   , Item15=0+resp_wo$`393`
                   , Item16=0+resp_wo$`403`
                   , Item17=0+resp_wo$`404`
                   , Item18=0+resp_wo$`405`
                   , Item19=0+resp_wo$`406`
                   , Item20=0+resp_wo$`407`
                   , Item21=0+resp_wo$`408`
                   , Item22=0+resp_wo$`409`
                   , Item23=0+resp_wo$`410`
                   , Item24=0+resp_wo$`411`
                   , Item25=0+resp_wo$`412`
)
respIMMS <- select(respIMMS, starts_with("UserID"), starts_with("Item"))
IMMS <- merge(participant, respIMMS, by="UserID")
if (!file.exists('case03/data/SourceIMMS.csv')) write_csv(IMMS, 'case03/data/SourceIMMS.csv')

