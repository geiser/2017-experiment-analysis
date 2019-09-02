# Data Employed in the Statistical Analysis of the First Empirical Study

### File: [CLActivity.csv](CLActivity.csv)

CSV-file with information related to the execution of CL sessions.
- On-line visualization: [CLActivity.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/CLActivity.csv)

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
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


### File: [SignedUpParticipants.csv](SignedUpParticipants.csv)

CSV-file with the list of all students enrolled as participants.
- On-line visualization: [SignedUpParticipants.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/SignedUpParticipants.csv)
- R script used to generate this file: [00-processing-mysql.R](../../00-processing-mysql.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |

### File: [EffectiveParticipants.csv](EffectiveParticipants.csv)

CSV-file with the list of students with *effective* participation.
- On-line visualization: [EffectiveParticipants.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/EffectiveParticipants.csv)
- R script used to generate this file: [00-processing-mysql.R](../../00-processing-mysql.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |

*effective*: A student with effective participation is a student that, at least one time, interacted with other member
of the CL group by following the necessary interactions indicated in the CSCL script. It is a students who had a complete,
semicomplete or incomplete participation level in the CL session.


## Data Related to the Students' Motivation

### File: [SourceIMIWithCareless.csv](SourceIMIWithCareless.csv)

CSV-file with responses of the IMI questionnaire.
These responses included careless responses.
- On-line visualization: [SourceIMIWithCareless.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/SourceIMIWithCareless.csv)
- R script used to generate this file: [00-processing-mysql.R](../../00-processing-mysql.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Gamified | Type of CL session in which the student with *UserID* participated in the empirical study |
| Group | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| ItemX | Value for the 7 point Likert scale with the identification *ItemX*  |


### File: [SourceIMI.csv](SourceIMI.csv)

CSV-file with responses of the IMI questionnaire, and careless responses removed from the data through the process detailed in the file: [outliers-motivation-surveys.pdf](../../report/outliers-motivation-surveys.pdf)
- On-line visualization: [SourceIMI.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/SourceIMI.csv)
- R script used to generate this file: [01-removing-careless-motivation.R](../../01-removing-careless-motivation.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| ItemX | Value from a 7 point Likert scale for the item with identification *ItemX* |


### File: [IMI.csv](IMI.csv)

CSV-file with the validated responses through the factorial analysis and reliability test detailed in the file: [validation-motivation-surveys.pdf](../../report/validation-motivation-surveys.pdf)
- On-line visualization: [IMI.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/IMI.csv)
- R script used to generate this file: [00-reliability-analysis-IMI.R](../00-reliability-analysis-IMI.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
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


### File: [InterestEnjoyment.csv](InterestEnjoyment.csv)

CSV-file with the IRT-based estimates of Interest/Enjoyment.
These estimates were calculated through the building process of RSM-based instruments detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [InterestEnjoyment.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/InterestEnjoyment.csv)
- R script used to generate this file: [00-rsm-motivation-measurement-building.R](../00-rsm-motivation-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| Score | Score calculated as the sum of the items in each record |
| theta | Estimate of the latent trait in logit scale |
| error | Standard error for the estimate of the latent trait *theta* |
| Outfit | outlier-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system.  |
| Infit | inlier-pattern-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system. |


### File: [PerceivedChoice.csv](PerceivedChoice.csv)

CSV-file with the IRT-based estimates of Perceived Choice.
These estimates were calculated through the building process of RSM-based instruments detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [PerceivedChoice.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PerceivedChoice.csv)
- R script used to generate this file: [00-rsm-motivation-measurement-building.R](../00-rsm-motivation-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| Score | Score calculated as the sum of the items in each record |
| theta | Estimate of the latent trait in logit scale |
| error | Standard error for the estimate of the latent trait *theta* |
| Outfit | outlier-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system.  |
| Infit | inlier-pattern-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system. |


### File: [PressureTension.csv](PressureTension.csv)

CSV-file with the IRT-based estimates of Pressure/Tension.
These estimates were calculated through the building process of RSM-based instruments detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [PressureTension.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PressureTension.csv)
- R script used to generate this file: [00-rsm-motivation-measurement-building.R](../00-rsm-motivation-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| Score | Score calculated as the sum of the items in each record |
| theta | Estimate of the latent trait in logit scale |
| error | Standard error for the estimate of the latent trait *theta* |
| Outfit | outlier-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system.  |
| Infit | inlier-pattern-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system. |


### File: [EffortImportance.csv](EffortImportance.csv)

CSV-file with the IRT-based estimates of Effort/Importance.
These estimates were calculated through the building process of RSM-based instruments detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [EffortImportance.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/EffortImportance.csv)
- R script used to generate this file: [00-rsm-motivation-measurement-building.R](../00-rsm-motivation-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| Score | Score calculated as the sum of the items in each record |
| theta | Estimate of the latent trait in logit scale |
| error | Standard error for the estimate of the latent trait *theta* |
| Outfit | outlier-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system.  |
| Infit | inlier-pattern-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system. |


### File: [IntrinsicMotivation.csv](IntrinsicMotivation.csv)

CSV-file with the IRT-based estimates of Intrinsic Motivation.
These estimates were calculated through the building process of RSM-based instruments detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [IntrinsicMotivation.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/IntrinsicMotivation.csv)
- R script used to generate this file: [00-rsm-motivation-measurement-building.R](../00-rsm-motivation-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical study |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| Score | Score calculated as the sum of the items in each record |
| theta | Estimate of the latent trait in logit scale |
| error | Standard error for the estimate of the latent trait *theta* |
| Outfit | outlier-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system.  |
| Infit | inlier-pattern-sensitive fit statistic based on chi-square test. Values greater than `>2` distorts or degraddes the measurement system. |


## Data Related to the Learning Outcomes 

### File: [PreAMCscr.csv](PreAMCscr.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *pretest* phase, and scored using a rule defined by the teacher of course.
- On-line visualization: [PreAMCscr.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PreAMCscr.csv)
- R script used to generate this file: [00-processing-amc.R](../../00-processing-amc.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| *QuX* | Teacher-based score for the AMC question with identification *QuX* |
| score | Score calculated as the sum of scores obtained in all the questions |

Columns with name of *QuX* can have values `Qu = {Re, Un, Ap, An, Ev}` and `X = {1, 2, 3}` to represent questions classified according to the Bloom and SOLO taxonomies. `Qu = Re: Remember level`, `Qu = Un: Understand level`, `Qu = Ap: Apply level`, `Qu = An: Analysing level`, `Qu = Ev: Evaluation level`, `X = 1: unistructural level`, `X = 2: multistructural level`, and `X = 3: relational level`. (more information of these taxonomies in [https://dl.acm.org/citation.cfm?id=1379265](https://dl.acm.org/citation.cfm?id=1379265) and in [https://doi.org/10.1145/2676723.2677311](https://doi.org/10.1145/2676723.2677311))

#### Teacher-based scoring rules for the columns *QuX*

```
score(QuX) = (NBC/NB - NMC/NM) * w(QuX)
```

* *NB*: is the number of correct responses to the question.
* *NBC*: is the count of correct responses which have been checked.
* *NM*: is the number of wrong responses to the question.
* *NMC*: is the count of wrong responses which have been checked.
* *w*(*QuX*): is the weight for the question (*QuX*) whose value is defined by the teacher according to the level of difficulty infered by him/her. These weights are the followings:
  - `w(Re1) = 0.6` for the question with remember-unistructural level
  - `w(Re2) = 0.7` for the question with remember-multistructural level
  - `w(Un1) = 0.8` for the question with understand-unistructural level
  - `w(Un2) = 0.9` for the question with understand-multistructural level
  - `w(Ap1) = 1.0` for the question with apply-unistructural level
  - `w(Ap2) = 1.0` for the question with apply-multistructural level
  - `w(Ap3) = 1.1` for the question with apply-relational level
  - `w(An3) = 1.2` for the question with analyse-relational level
  - `w(Ev1) = 1.3` for the question with evaluate-unistructural level
  - `w(Ev2) = 1.4` for the question with evaluate-unistructural level


### File: [PosAMCscr.csv](PosAMCscr.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *posttest* phase, and scored using a rule defined by the teacher of course.
- On-line visualization: [PosAMCscr.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PosAMCscr.csv)
- R script used to generate this file: [00-processing-amc.R](../../00-processing-amc.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| *QuX* | Teacher-based score for the AMC question with identification *QuX* |
| score | Score calculated as the sum of scores obtained in all the questions |

Columns with name of *QuX* can have values `Qu = {Re, Un, Ap, An, Ev}` and `X = {1, 2, 3}` to represent questions classified according to the Bloom and SOLO taxonomies. `Qu = Re: Remember level`, `Qu = Un: Understand level`, `Qu = Ap: Apply level`, `Qu = An: Analysing level`, `Qu = Ev: Evaluation level`, `X = A: unistructural level`, `X = B: multistructural level`, and `X = C: relational level`. (more information of these taxonomies in [https://dl.acm.org/citation.cfm?id=1379265](https://dl.acm.org/citation.cfm?id=1379265) and in [https://doi.org/10.1145/2676723.2677311](https://doi.org/10.1145/2676723.2677311))

#### Teacher-based scoring rules for the columns *QuX*

```
score(QuX) = (NBC/NB - NMC/NM) * w(QuX)
```

* *NB*: is the number of correct responses to the question.
* *NBC*: is the count of correct responses which have been checked.
* *NM*: is the number of wrong responses to the question.
* *NMC*: is the count of wrong responses which have been checked.
* *w*(*QuX*): is the weight for the question (*QuX*) whose value is defined by the teacher according to the level of difficulty infered by him/her. These weights are the followings:
  - `w(ReA) = 0.6` for the question with remember-unistructural level
  - `w(ReB) = 0.7` for the question with remember-multistructural level
  - `w(UnA) = 0.8` for the question with understand-unistructural level
  - `w(UnB) = 0.9` for the question with understand-multistructural level
  - `w(ApA) = 1.0` for the question with apply-unistructural level
  - `w(ApB) = 1.0` for the question with apply-multistructural level
  - `w(ApC) = 1.1` for the question with apply-relational level
  - `w(AnC) = 1.2` for the question with analyse-relational level
  - `w(EvA) = 1.3` for the question with evaluate-unistructural level
  - `w(EvB) = 1.4` for the question with evaluate-unistructural level


### File: [PreAMC.csv](PreAMC.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *pretest* phase, and scored using the GPCM-based rule detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf) (page 342).
- On-line visualization: [PreAMC.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PreAMC.csv)
- R script used to generate this file: [00-processing-amc.R](../../00-processing-amc.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| *QuX* | GPCM-based score for the AMC question with identification *QuX* |

Columns with name of *QuX* can have values `Qu = {Re, Un, Ap, An, Ev}` and `X = {1, 2, 3}` to represent questions classified according to the Bloom and SOLO taxonomies. `Qu = Re: Remember level`, `Qu = Un: Understand level`, `Qu = Ap: Apply level`, `Qu = An: Analysing level`, `Qu = Ev: Evaluation level`, `X = 1: unistructural level`, `X = 2: multistructural level`, and `X = 3: relational level`. (more information of these taxonomies in [https://dl.acm.org/citation.cfm?id=1379265](https://dl.acm.org/citation.cfm?id=1379265) and in [https://doi.org/10.1145/2676723.2677311](https://doi.org/10.1145/2676723.2677311))

#### GPCM-based scoring rules for the columns *QuX*

Let *NBC* be the number of correct responses which have been checked in the question *QuX*, *NM* be the number of wrong responses; and *NMC* be the number of wrong responses which have been checked in the question *QuX*; then, the GPCM-scoring rule for a n-th question in the multiple choice questionnaire is given by:

```
score(n) = 0 ; if NBC = 0 
score(n) = (NBC * (NM+1)) - NMC; otherwise
``` 


### File: [PosAMC.csv](PosAMC.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *posttest* phase, and scored using the GPCM-based rule detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf) (page 342).
- On-line visualization: [PosAMC.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PosAMC.csv)
- R script used to generate this file: [00-processing-amc.R](../../00-processing-amc.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| NroUSP | Integer as user identification to differentiate students on the school |
| Type | Type of CL session in which the student with *UserID* participated in the empirical study |
| CLGroup | Name for the CL group in which the student with *UserID* is member of |
| CLRole | The CL role assigned for the student with *UserID* |
| PlayerRole | The player role assigned for the student with *UserID* in ont-gamified CL sessions |
| *QuX* | GPCM-based score for the AMC question with identification *QuX* |

Columns with name of *QuX* can have values `Qu = {Re, Un, Ap, An, Ev}` and `X = {1, 2, 3}` to represent questions classified according to the Bloom and SOLO taxonomies. `Qu = Re: Remember level`, `Qu = Un: Understand level`, `Qu = Ap: Apply level`, `Qu = An: Analysing level`, `Qu = Ev: Evaluation level`, `X = A: unistructural level`, `X = B: multistructural level`, and `X = C: relational level`. (more information of these taxonomies in [https://dl.acm.org/citation.cfm?id=1379265](https://dl.acm.org/citation.cfm?id=1379265) and in [https://doi.org/10.1145/2676723.2677311](https://doi.org/10.1145/2676723.2677311))

#### GPCM-based scoring rules for the columns *QuX*

Let *NBC* be the number of correct responses which have been checked in the question *QuX*, *NM* be the number of wrong responses; and *NMC* be the number of wrong responses which have been checked in the question *QuX*; then, the GPCM-scoring rule for a n-th question in the multiple choice questionnaire is given by:

```
score(n) = 0 ; if NBC = 0 
score(n) = (NBC * (NM+1)) - NMC; otherwise
``` 


### File: [PreGuttmanVPL.csv](PreGuttmanVPL.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *pretest* phase, and scored with Guttman-based rules detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf) (pages 342-343).
- On-line visualization: [PreGuttmanVPL.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PreGuttmanVPL.csv)
- R script used to generate this file: [00-processing-vpl.R](../../00-processing-vpl.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| PXs0 | Guttman-based score for the programming problem task with identification *PX* and rule *s0*. |
| PXs1 | Guttman-based score for the programming problem task with identification *PX* and rule *s1*. |
| PXs2 | Guttman-based score for the programming problem task with identification *PX* and rule *s2*. |
| PXs3 | Guttman-based score for the programming problem task with identification *PX* and rule *s3*. |


#### Guttman-structure scoring rules for the columns *PXsY*

rule *s0*: _score_(_Q_)
   - `0`: when the solution is incorrect (`Q = 0`), and the solving time is irrelevant
   - `1`: when the solution is correct (`Q = 1`), and the solving time is irrelevant

rule *s1*: _score_(_Q x T50_)
 - `(0,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T55`)
 - `(1,1) = 2`: when the solution is correct (`Q = 1`) and the solving time is less than the median (`t < T50`)

rule *s2*: _score_(_Q x T66 x T33_)
 - `(0,x,x) = 0`: when the solution is incorrect (`Q =0`) and the solving time is irrelevant
 - `(1,0,x) = 1`: when the solution is correct (`Q =1`) and the solving time is greater than 66-th percentile (`t > T66`)
 - `(1,1,0) = 2`: when the solution is correct (`Q =1`) and the solving time is greater than 33-th percentile (`t > T33`)
 - `(1,1,1) = 3`: when the solution is correct (`Q =1`) and the solving time is less than 33-th percentile (`t < T33`)


rule *s3*: _score_(_Q x T75 x T50 x T25_)
 - `(0,x,x,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0,x,x) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than 75-th percentile (`t > T75`)
 - `(1,1,0,x) = 2`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T50`)
 - `(1,1,1,0) = 3`: when the solution is correct (`Q = 1`) and the solving time is greater than 25-th percentile (`t > T25`)
 - `(1,1,1,1) = 4`: when the solution is correct (`Q = 1`) and the solving time is less than 25-th percentile (`t < T25`)


### File: [PosGuttmanVPL.csv](PosGuttmanVPL.csv)

CSV-file with information from the programming problem tasks solved by the students throughout the *posttest* phase, and scored with Guttman-based rules detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf) (pages 342-343).
- On-line visualization: [PosGuttmanVPL.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/PosGuttmanVPL.csv)
- R script used to generate this file: [00-processing-vpl.R](../../00-processing-vpl.R) ([more info](../../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| PXs0 | Guttman-based score for the programming problem task with identification *PX* and rule *s0*. |
| PXs1 | Guttman-based score for the programming problem task with identification *PX* and rule *s1*. |
| PXs2 | Guttman-based score for the programming problem task with identification *PX* and rule *s2*. |
| PXs3 | Guttman-based score for the programming problem task with identification *PX* and rule *s3*. |

#### Guttman-structure scoring rules for the columns *PXsY*

rule *s0*: _score_(_Q_)
   - `0`: when the solution is incorrect (`Q = 0`), and the solving time is irrelevant
   - `1`: when the solution is correct (`Q = 1`), and the solving time is irrelevant

rule *s1*: _score_(_Q x T50_)
 - `(0,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T55`)
 - `(1,1) = 2`: when the solution is correct (`Q = 1`) and the solving time is less than the median (`t < T50`)

rule *s2*: _score_(_Q x T66 x T33_)
 - `(0,x,x) = 0`: when the solution is incorrect (`Q =0`) and the solving time is irrelevant
 - `(1,0,x) = 1`: when the solution is correct (`Q =1`) and the solving time is greater than 66-th percentile (`t > T66`)
 - `(1,1,0) = 2`: when the solution is correct (`Q =1`) and the solving time is greater than 33-th percentile (`t > T33`)
 - `(1,1,1) = 3`: when the solution is correct (`Q =1`) and the solving time is less than 33-th percentile (`t < T33`)

rule *s3*: _score_(_Q x T75 x T50 x T25_)
 - `(0,x,x,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0,x,x) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than 75-th percentile (`t > T75`)
 - `(1,1,0,x) = 2`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T50`)
 - `(1,1,1,0) = 3`: when the solution is correct (`Q = 1`) and the solving time is greater than 25-th percentile (`t > T25`)
 - `(1,1,1,1) = 4`: when the solution is correct (`Q = 1`) and the solving time is less than 25-th percentile (`t < T25`)


### File: [GainSkillsKnowledge.csv](GainSkillsKnowledge.csv)

CSV-file with the IRT-based estimates of Skill/Knowledge gains.
These estimates were calculated through the stacking process based on the General Partial Credit Model (GPCM), and detailed in the file: [irt-instruments.pdf](../../report/irt-instruments.pdf)
- On-line visualization: [GainSkillsKnowledge.csv](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/data/GainSkillsKnowledge.csv)
- R script used to generate this file: [00-gpcm-learning-outcomes-measurement-building.R](../00-gpcm-learning-outcomes-measurement-building.R) ([more info](../)) 

| Column | Description |
|--------|----------|
| UserID | Integer as user identification to differentiate students on the empirical studies |
| *QuX* | GPCM-based score for the AMC question with identification *QuX* |
| *PXsY* | Guttman-based score for the programming problem task with identification *PX* and rule *sY*. |
| pre.PersonScores | Score calculated as the sum of items used during the *pretest* phase |
| pos.PersonScores | Score calculated as the sum of items used during the *posttest* phase |
| pre.theta | Estimate of the latent trait in logit scale for the *pretest* phase |
| pos.theta | Estimate of the latent trait in logit scale for the *posttest* phase |
| pre.sd.error | Standard error for the estimate of the latent trait *theta* calculated in the *pretest* phase |
| pos.sd.error | Standard error for the estimate of the latent trait *theta* calculated in the *posttest* phase |
| gain.theta | Estimate of the difference of latent traits (`pos.theta - pre.theta`) in logit scale |

Columns with name of *QuX* can have values `Qu = {Re, Un, Ap, An, Ev}` and `X = {1, 2, 3}` to represent questions classified according to the Bloom and SOLO taxonomies. `Qu = Re: Remember level`, `Qu = Un: Understand level`, `Qu = Ap: Apply level`, `Qu = An: Analysing level`, `Qu = Ev: Evaluation level`, `X = 1 or X = A: unistructural level`, `X = 2 or X = B: multistructural level`, and `X = 3 or X = C: relational level`. (more information of these taxonomies in [https://dl.acm.org/citation.cfm?id=1379265](https://dl.acm.org/citation.cfm?id=1379265) and in [https://doi.org/10.1145/2676723.2677311](https://doi.org/10.1145/2676723.2677311))

#### GPCM-based scoring rules for the columns *QuX*

Let *NBC* be the number of correct responses which have been checked in the question *QuX*, *NM* be the number of wrong responses; and *NMC* be the number of wrong responses which have been checked in the question *QuX*; then, the GPCM-scoring rule for a n-th question in the multiple choice questionnaire is given by:

```
score(n) = 0 ; if NBC = 0 
score(n) = (NBC * (NM+1)) - NMC; otherwise
```  

#### Guttman-structure scoring rules for the columns *PXsY*

rule *s0*: _score_(_Q_)
   - `0`: when the solution is incorrect (`Q = 0`), and the solving time is irrelevant
   - `1`: when the solution is correct (`Q = 1`), and the solving time is irrelevant

rule *s1*: _score_(_Q x T50_)
 - `(0,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T55`)
 - `(1,1) = 2`: when the solution is correct (`Q = 1`) and the solving time is less than the median (`t < T50`)

rule *s2*: _score_(_Q x T66 x T33_)
 - `(0,x,x) = 0`: when the solution is incorrect (`Q =0`) and the solving time is irrelevant
 - `(1,0,x) = 1`: when the solution is correct (`Q =1`) and the solving time is greater than 66-th percentile (`t > T66`)
 - `(1,1,0) = 2`: when the solution is correct (`Q =1`) and the solving time is greater than 33-th percentile (`t > T33`)
 - `(1,1,1) = 3`: when the solution is correct (`Q =1`) and the solving time is less than 33-th percentile (`t < T33`)


rule *s3*: _score_(_Q x T75 x T50 x T25_)
 - `(0,x,x,x) = 0`: when the solution is incorrect (`Q = 0`) and the solving time is irrelevant
 - `(1,0,x,x) = 1`: when the solution is correct (`Q = 1`) and the solving time is greater than 75-th percentile (`t > T75`)
 - `(1,1,0,x) = 2`: when the solution is correct (`Q = 1`) and the solving time is greater than the median (`t > T50`)
 - `(1,1,1,0) = 3`: when the solution is correct (`Q = 1`) and the solving time is greater than 25-th percentile (`t > T25`)
 - `(1,1,1,1) = 4`: when the solution is correct (`Q = 1`) and the solving time is less than 25-th percentile (`t < T25`)

