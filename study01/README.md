# Empirical Study 01

Comparing ontology-based gamified CL sessions (ont-gamified) against non-gamified CL sessions (non-gamified CL sessions).

* CSCL Script: CSCL script inspired by Cognitive Apprentice
* Content-domain: Conditional Structures - Course of Introduction to Computer Science
* Participants: 62 undergraduate Brazilian Computer Science students

All materials used in the empirical study are available at ([materials](materials/))

### Research Questions (RQs)

1. Do the ont-gamified CL sessions have positive impacts on the students' motivation?
2. Do the ont-gamified CL sessions affect on the students' learning outcomes?
3. Are the participants' motivation and learning outcomes linked in those sessions?

## Scripts to answer the RQ1

**RQ1:** `Do the ont-gamified CL sessions have positive impacts on the students' motivation?`


### R script to validate the IMI questionnaire ([00-reliability-analysis-IMI.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/00-reliability-analysis-IMI.R))

R script to validate data gathered in the empirical study through the IMI questionnaire.

The results obtained by the execution of this R script are:

* PDF-file with the summary of fatorial analysis and reliability test

  _File_: [IMI-reliability-analysis.pdf](report/latex/IMI-reliability-analysis.pdf)

* Excel-file with detailed information of measure sampling adequacy, factorial analysis, and reliability test

  _File_: [IMI.xlsx](report/reliability-analysis/IMI.xlsx)

* CSV-file with the responses on the IMI questionnaire with validated items

  _File_: [IMI.csv](data/IMI.csv) ([more info ...](data/))

This validation of the IMI questionnarie was carried out with all the data gathered throughout all empirical studies, and this procedure is detailed in [../report/validation-IMI/](../report/validation-IMI/).


### R script to find significant differences on the scores of motivation for all students ([01-scr-motivation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/01-scr-motivation-signedup-analysis.R))

R script to find significant differences on the motivation scores obtained through the IMI questionnaire, and for all the students signed-up as participants in the CL sessions.
These differences were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-scr-analysis.pdf](report/latex/motivation-signedup/summary-scr-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [nonparametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-interest-enjoyment-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Perceived Choice*

  _File_: [nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-perceived-choice-scr-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Perceived Choice*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Pressure/Tension*

  _File_: [nonparametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-pressure-tension-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Pressure/Tension*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Effort/Importance*

  _File_: [nonparametric-effort-importance-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-effort-importance-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Effort/Importance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [nonparametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-intrinsic-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-scr-intrinsic-motivation.pdf](report/latex/motivation-signedup/wisorized-scr-intrinsic-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Interest/Enjoyment*

  _File_: [parametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-signedup/parametric-interest-enjoyment-scr-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Interest/Enjoyment*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Perceived Choice*

  _File_: [parametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-signedup/parametric-perceived-choice-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Perceived Choice*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Pressure/Tension*

  _File_: [parametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-signedup/parametric-pressure-tension-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Pressure/Tension*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Effort/Importance*

  _File_: [parametric-effort-importance-scr-analysis.pdf](report/latex/motivation-signedup/parametric-effort-importance-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Effort/Importance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/effort-importance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Intrinsic Motivation*

  _File_: [parametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-signedup/parametric-intrinsic-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Intrinsic Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to find significant differences on the scores of motivation for students with effective participation ([01-scr-motivation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/01-scr-motivation-effective-analysis.R))

R script to find significant differences on the motivation scores obtained through the IMI questionnaire, and for the students with effective participation in the CL sessions.
These differences were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-scr-analysis.pdf](report/latex/motivation-effective/summary-scr-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [nonparametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-interest-enjoyment-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Perceived Choice*

  _File_: [nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-perceived-choice-scr-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Perceived Choice*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Pressure/Tension*

  _File_: [nonparametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-pressure-tension-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Pressure/Tension*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Effort/Importance*

  _File_: [nonparametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-effort-importance-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Effort/Importance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [nonparametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-intrinsic-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-scr-intrinsic-motivation.pdf](report/latex/motivation-effective/wisorized-scr-intrinsic-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Interest/Enjoyment*

  _File_: [parametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/parametric-interest-enjoyment-scr-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Interest/Enjoyment*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Perceived Choice*

  _File_: [parametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/parametric-perceived-choice-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Perceived Choice*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Pressure/Tension*

  _File_: [parametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-effective/parametric-pressure-tension-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Pressure/Tension*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Effort/Importance*

  _File_: [parametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/parametric-effort-importance-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Effort/Importance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Intrinsic Motivation*

  _File_: [parametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-effective/parametric-intrinsic-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Intrinsic Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to calculate the IRT-based estimates of students' motivation ([00-rsm-motivation-measurement-building.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/00-rsm-motivation-measurement-building.R))

R script to calculate the IRT-based estimates of students' motivations through the building of RMS-based measurement instruments. These estimates were calculated based on the *Item Response Theory* (IRT) and *Rating Scale Model* (RSM), and through the process detailed in the file: [irt-instruments.pdf](../report/irt-instruments.pdf). 

The results obtained by the execution of this R script are:
 
* PDF-file with the summary of the IRT-based instruments to estimate the students' motivation

  _File_: [rsm-motivation.pdf](report/latex/rsm-motivation.pdf) ([more info ...](report/latex/))

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Interest/Enjoyment*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/interest-enjoyment/MeasurementModel.xlsx) ([more info ...](report/irt-motivation/interest-enjoyment/))

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Perceived Choice*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/perceived-choice/MeasurementModel.xlsx) ([more info ...](report/irt-motivation/perceived-choice/))

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Pressure/Tension*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/pressure-tension/MeasurementModel.xlsx) ([more info ...](report/irt-motivation/pressure-tension/))

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Effort/Importance*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/effort-importance/MeasurementModel.xlsx) ([more info ...](report/irt-motivation/effort-importance/))

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Intrinsic Motivation*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/intrinsic-motivation/MeasurementModel.xlsx) ([more info ...](report/irt-motivation/intrinsic-motivation/))

* CSV-file with the IRT-based estimates of *Interest/Enjoyment*:

  _File_: [InterestEnjoyment.csv](data/InterestEnjoyment.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Perceived Choice*:

  _File_: [PerceivedChoice.csv](data/PerceivedChoice.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Pressure/Tension*:

  _File_: [PressureTension.csv](data/PressureTension.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Effort/Importance*:

  _File_: [EffortImportance.csv](data/EffortImportance.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Intrinsic Motivation*:

  _File_: [IntrinsicMotivation.csv](data/IntrinsicMotivation.csv) ([more info ...](data/))


### R script to find significant differences on the IRT-based estimates of motivation for all students ([01-rsm-motivation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/01-rsm-motivation-signedup-analysis.R))

R script to find significant differences on the IRT-based estimates of motivation obtained through the RSM-based measurment instrument of motivation built from the IMI questionnaire.
These differences were find on the estimates of motivation for all the students signed-up as participants in the CL sessions, and they were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-analysis.pdf](report/latex/motivation-signedup/summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [nonparametric-interest-enjoyment-analysis.pdf](report/latex/motivation-signedup/nonparametric-interest-enjoyment-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Perceived Choice*

  _File_: [nonparametric-perceived-choice-analysis.pdf](report/latex/motivation-signedup/nonparametric-perceived-choice-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Perceived Choice*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Pressure/Tension*

  _File_: [nonparametric-pressure-tension-analysis.pdf](report/latex/motivation-signedup/nonparametric-pressure-tension-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Pressure/Tension*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Effort/Importance*

  _File_: [nonparametric-effort-importance-analysis.pdf](report/latex/motivation-signedup/nonparametric-effort-importance-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Effort/Importance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [nonparametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-signedup/nonparametric-intrinsic-motivation-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-intrinsic-motivation.pdf](report/latex/motivation-signedup/wisorized-intrinsic-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Interest/Enjoyment*

  _File_: [parametric-interest-enjoyment-analysis.pdf](report/latex/motivation-signedup/parametric-interest-enjoyment-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Interest/Enjoyment*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Perceived Choice*

  _File_: [parametric-perceived-choice-analysis.pdf](report/latex/motivation-signedup/parametric-perceived-choice-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Perceived Choice*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Pressure/Tension*

  _File_: [parametric-pressure-tension-analysis.pdf](report/latex/motivation-signedup/parametric-pressure-tension-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Pressure/Tension*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Effort/Importance*

  _File_: [parametric-effort-importance-analysis.pdf](report/latex/motivation-signedup/parametric-effort-importance-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Effort/Importance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/effort-importance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Intrinsic Motivation*

  _File_: [parametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-signedup/parametric-intrinsic-motivation-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Intrinsic Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to find significant differences on the IRT-based estimates of motivation for students with effective participation ([01-rsm-motivation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/01-rsm-motivation-effective-analysis.R))

R script to find significant differences on the IRT-based estimates of motivation obtained through the RSM-based measurment instrument of motivation built from the IMI questionnaire.
These differences were finding on the estimates of motivation for students with effectie participantion in the CL sessions, and they were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-analysis.pdf](report/latex/motivation-effective/summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [nonparametric-interest-enjoyment-analysis.pdf](report/latex/motivation-effective/nonparametric-interest-enjoyment-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Interest/Enjoyment*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Perceived Choice*

  _File_: [nonparametric-perceived-choice-analysis.pdf](report/latex/motivation-effective/nonparametric-perceived-choice-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Perceived Choice*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Pressure/Tension*

  _File_: [nonparametric-pressure-tension-analysis.pdf](report/latex/motivation-effective/nonparametric-pressure-tension-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Pressure/Tension*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Effort/Importance*

  _File_: [nonparametric-effort-importance-analysis.pdf](report/latex/motivation-effective/nonparametric-effort-importance-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Effort/Importance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [nonparametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-effective/nonparametric-intrinsic-motivation-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Intrinsic Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-intrinsic-motivation.pdf](report/latex/motivation-effective/wisorized-intrinsic-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Interest/Enjoyment*

  _File_: [parametric-interest-enjoyment-analysis.pdf](report/latex/motivation-effective/parametric-interest-enjoyment-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Interest/Enjoyment*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Perceived Choice*

  _File_: [parametric-perceived-choice-analysis.pdf](report/latex/motivation-effective/parametric-perceived-choice-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Perceived Choice*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Pressure/Tension*

  _File_: [parametric-pressure-tension-analysis.pdf](report/latex/motivation-effective/parametric-pressure-tension-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Pressure/Tension*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Effort/Importance*

  _File_: [parametric-effort-importance-analysis.pdf](report/latex/motivation-effective/parametric-effort-importance-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Effort/Importance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/effort-importance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Intrinsic Motivation*

  _File_: [parametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-effective/parametric-intrinsic-motivation-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Intrinsic Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx)



## Scripts to answer the RQ2

**RQ2:** `Do the ont-gamified CL sessions affect on the students' learning outcomes?`


### R script to find significant differences on the gain scores of academic performance tests for all students ([02-scr-learning-outcomes-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/02-scr-learning-outcomes-signedup-analysis.R))

R script to find statistical significant differences on the gain scores (`posttest - pretest`) obtained through the AMC questionnaires and solving-programming problem tasks.
This statistical analysis was carried out with data gathered from the responses of all the students signed-up as participants in the CL sessions.
Firstly, a nonparametric analysis was carried out by using the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, through the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found by the nonparametric analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [scr-signedup-participants-summary-analysis.pdf](report/latex/learning-outcomes/scr-signedup-participants-summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis

  _File_: [nonparametric-scr-signedup-participants-scr-analysis.pdf](report/latex/learning-outcomes/nonparametric-scr-signedup-participants-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis

  _File_: [NonParametricAnalysis.xlsx](report/learning-outcomes/scr-signedup-participants/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis

  _File_: [parametric-scr-signedup-participants-analysis.pdf](report/latex/learning-outcomes/parametric-scr-signedup-participants-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis

  _File_: [ParametricAnalysis.xlsx](report/learning-outcomes/scr-signedup-participants/ParametricAnalysis.xlsx)


### R script to find significant differences on the gain scores of academic performance tests for students with effective participation ([02-scr-learning-outcomes-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/02-scr-learning-outcomes-effective-analysis.R))

R script to find statistical significant differences on the gain scores (`posttest - pretest`) obtained through the AMC questionnaires and solving-programming problem tasks.
This statistical analysis was carried out with data gathered from the responses of students with effective participation in the CL sessions.
Firstly, a nonparametric analysis was carried out by using the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, through the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found by the nonparametric analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [scr-effective-participants-summary-analysis.pdf](report/latex/learning-outcomes/scr-effective-participants-summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis

  _File_: [nonparametric-scr-effective-participants-scr-analysis.pdf](report/latex/learning-outcomes/nonparametric-scr-effective-participants-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis

  _File_: [NonParametricAnalysis.xlsx](report/learning-outcomes/scr-effective-participants/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis

  _File_: [parametric-scr-effective-participants-analysis.pdf](report/latex/learning-outcomes/parametric-scr-effective-participants-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis

  _File_: [ParametricAnalysis.xlsx](report/learning-outcomes/scr-effective-participants/ParametricAnalysis.xlsx)
  




# Significant Differences on Learning Outcomes

## Finding significant differences based on the estimates of IRT-based models for all students (signed-up students)

* Summary of Nonparametric and Parametric tests ([summary-analysis.pdf](report/latex/motivation-signedup/summary-analysis.pdf))

* Nonparametric tests of Intrinsic Motivation ([nonparametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-signedup/nonparametric-intrinsic-motivation-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Intrinsic Motivation ([parametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-signedup/parametric-intrinsic-motivation-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/signedup-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Interest/Enjoyment ([nonparametric-interest-enjoyment-analysis.pdf](report/latex/motivation-signedup/nonparametric-interest-enjoyment-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Interest/Enjoyment ([parametric-interest-enjoyment-analysis.pdf](report/latex/motivation-signedup/parametric-interest-enjoyment-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/signedup-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Perceived Choice ([nonparametric-perceived-choice-analysis.pdf](report/latex/motivation-signedup/nonparametric-perceived-choice-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Perceived Choice ([parametric-perceived-choice-analysis.pdf](report/latex/motivation-signedup/parametric-perceived-choice-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/signedup-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Pressure/Tension ([nonparametric-perceived-choice-analysis.pdf](report/latex/motivation-signedup/nonparametric-pressure-tension-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Pressure/Tension ([parametric-pressure-tension-analysis.pdf](report/latex/motivation-signedup/parametric-pressure-tension-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/signedup-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Effort/Importance ([nonparametric-effort-importance-analysis.pdf](report/latex/motivation-signedup/nonparametric-effort-importance-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Effort/Importance ([parametric-effort-importance-analysis.pdf](report/latex/motivation-signedup/parametric-effort-importance-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/signedup-participants/effort-importance/by-Type/ParametricAnalysis.xlsx) with normality test)

## Finding significant differences based on the estimates of IRT-based models for students with effective participation (effective students)

* Summary of Nonparametric and Parametric tests ([summary-analysis.pdf](report/latex/motivation-effective/summary-analysis.pdf))

* Nonparametric tests of Intrinsic Motivation ([nonparametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-effective/nonparametric-intrinsic-motivation-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/effective-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Intrinsic Motivation ([parametric-intrinsic-motivation-analysis.pdf](report/latex/motivation-effective/parametric-intrinsic-motivation-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/effective-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Interest/Enjoyment ([nonparametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-interest-enjoyment-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Interest/Enjoyment ([parametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/parametric-interest-enjoyment-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Perceived Choice ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-perceived-choice-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Perceived Choice ([parametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/parametric-perceived-choice-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Pressure/Tension ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-pressure-tension-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Pressure/Tension ([parametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-effective/parametric-pressure-tension-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Effort/Importance ([nonparametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-effort-importance-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Effort/Importance ([parametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/parametric-effort-importance-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/ParametricAnalysis.xlsx) with normality test)

