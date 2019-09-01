# Data Employed in the Statistical Analysis of the Pilot Empirical Study

### [SignedUpParticipants.csv](SignedUpParticipants.csv)

CSV-file with the list of all students enrolled as participants in the pilot empirical study.
- On-line visualization: [SignedUpParticipants.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/SignedUpParticipants.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |


### [CLActivity.csv](CLActivity.csv)

CSV-file with information related to the execution of CL sessions in the pilot empirical study.
- On-line visualization: [CLActivity.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/CLActivity.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| ParticipationLevel | Participation level of students in the CL sessions |
| NroNecessaryInteractions | Number of necessary interactions performed by the students with *UserID* |
| NroDesiredInteractions | Number of desired interactions performed by the students with *UserID* |
| NroTotalInteractions | Number of necessary and desired interactions performed by the students with *UserID* |
| NroSolutionReviewed (Apprentice) | Number of solutions sent by the apprentice student with *UserID* and reviewed for a master student |
| NroSolutionReviewed (Master) | Number of solutions reviewed by the master student with *UserID* |
| NroSolutionWithoutReviewed (Apprentice) | Number of solutions without review sent by the apprentice student with *UserID* but without review for a master student |
| NroSolutionWithoutReviewed (Master) | Number of solutions sent to the master student with *UserID* and with pending review | 
| (n) ... | Number of necessary interactions with the identificador (*n*) carried out by the student with *UserID* |
| (x) ... | Number of desired interactions with the identificador (*x*) carried out by the student with *UserID* |

The possible values for the column *ParticipationLevel* are:
* _none_ is the participation level in which the students did not interact with other members in the CL sessions.
* _incomplete_ is the participation level in which the students interacted in the CL sessions, but they did not complete all the necessary interactions.
* _semicomplete_ is the participation level in which the students interacted in the CL sessions performing all the necessary interactions, but that they did not respond all the requests made by other members of the CL group.
* _complete_ is the participation level in which the students interacted in CL sessions performing all the necessary interactions, and they answered all the requests made by other members of the CL group.


### [EffectiveParticipants.csv](EffectiveParticipants.csv)

CSV-file with the list of students with *effective* participation in the pilot empirical study.
- On-line visualization: [EffectiveParticipants.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/EffectiveParticipants.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |

*effective*: A student with effective participation is a student that, at least one time, interacted with other member
of the CL group by following the necessary interactions indicated in the CSCL script. It is a students who had a complete,
semicomplete or incomplete participation level in the CL session.


## Data Related to the Students' Motivation

### [SourceIMILegend.csv](SourceIMILegend.csv)

CSV-file with the legend of IMI questionnaire applied in pilot empirical study.
- On-line visualization: [SourceIMILegend.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/SourceIMILegend.csv)

| Column | Description |
|--------|----------|
| ID | Integer as identification to differentiate the item in the Moodle questionnaire |
| QID | Integer as identification of the Moodle questionnaire |
| Item | Identification used to refer to the item in the data related to the students motivation |
| Content | Description of the item with identification *ID* |


### [SourceIMIWithCareless.csv](SourceIMIWithCareless.csv)

CSV-file with responses of the IMI questionnaire gathered throughout the pilot empirical study.
These responses included careless responses.
- On-line visualization: [SourceIMIWithCareless.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/SourceIMIWithCareless.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| ItemX | Value for the 7 point Likert scale with the identification *ItemX*  |


### [SourceIMI.csv](SourceIMI.csv)

CSV-file with responses of the IMI questionnaire gathered throughout the pilot empirical study.
Careless responses were removed from the data using the R script: [01-removing-careless-motivation.R](../../01-removing-careless-motivation.R).
- On-line visualization: [SourceIMI.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/SourceIMI.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| ItemX | Value from a 7 point Likert scale for the item with identification *ItemX* |


### [IMI.csv](IMI.csv)

CSV-file with the validated responses gathered throughout the pilot empirical study.
These response were winsorized, and they only included validated items through the factorial analysis and reliability test ([validation-IMI](../../report/validation-IMI)).
- On-line visualization: [IMI.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/pilot-study/data/IMI.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| ItemX | Value from a 7 point Likert scale for the item with identification *ItemX* |
| Interest/Enjoyment | Mean of values in the items related to the Interest/Enjoyment. This v is calculate as `IE = (Item22IE + Item09IE + Item12IE + Item24IE + Item21IE +  Item01IE)/6` |
| Perceived Choice | Mean of values in the items related to the *Perceived Choice*. This value is calculate as `PC = (40-(Item17PC + Item15PC + Item06PC + Item02PC + Item08PC))/5` |
| Pressure/Tension | Mean of values in the items related to the *Pressure/Tension*. This value is calculate as `PT = (Item16PT + Item14PT + Item18PT + 8-Item11PT)/4` |
| Effort/Importance | Mean of values in the items related to the *Effort/Importance*. This value is calculate as `EI = (Item03EI + 16-(Item13EI + Item07EI))/3` |
| Intrinsic Motivation | Mean of values in the items related to the *Intrinsic Motivation*. This value is calculate as `IM = (IE + PC + EI + 8-PT)/4` |





