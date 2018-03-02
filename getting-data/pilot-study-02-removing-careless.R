library(readr)
library(dplyr)
library(careless)

##########################################################################
## Motivation Questionnaire for Case01                                  ##
##########################################################################

participant <- read_csv("case01/data/Participant.csv")
resp <- read_csv('case01/data/SourceIMIWithCareless.csv')

print(careless_info <- careless(select(resp, -starts_with("UserID")), append=FALSE))
resp_wo <- resp[!(careless_info$longString > 12),] # 8,21,34,55

respIMI <- mutate(resp_wo
                  , Item01=0+resp_wo$`109`
                  , Item02=0+resp_wo$`110`
                  , Item03=0+resp_wo$`111`
                  , Item04=0+resp_wo$`112`
                  , Item05=0+resp_wo$`113`
                  , Item06=0+resp_wo$`114`
                  , Item07=0+resp_wo$`115`
                  , Item08=0+resp_wo$`116`
                  , Item09=0+resp_wo$`117`
                  , Item10=0+resp_wo$`118`
                  , Item11=0+resp_wo$`119`
                  , Item12=0+resp_wo$`120`
                  , Item13=0+resp_wo$`121`
                  , Item14=0+resp_wo$`122`
                  , Item15=0+resp_wo$`123`
                  , Item16=0+resp_wo$`124`
                  , Item17=0+resp_wo$`125`
                  , Item18=0+resp_wo$`126`
                  , Item19=0+resp_wo$`127`
                  , Item20=0+resp_wo$`128`
                  , Item21=0+resp_wo$`129`
                  , Item22=0+resp_wo$`130`
                  , Item23=0+resp_wo$`131`
                  , Item24=0+resp_wo$`132`
)
respIMI <- select(respIMI, starts_with("UserID"), starts_with("Item"))
IMI <- merge(participant, respIMI, by="UserID")
if (!file.exists('case01/data/SourceIMI.csv')) {
  write_csv(IMI, 'case01/data/SourceIMI.csv')
}
