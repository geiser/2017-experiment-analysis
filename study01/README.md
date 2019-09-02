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


### R script to find significant differences on the students' motivation ([01-scr-motivation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study01/01-scr-motivation-signedup-analysis.R))

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


## Scripts in this folder - path: [/study01/](https://github.com/geiser/phd-thesis-evaluation/tree/master/study01)

For answering these Research Questions (RQs), the R scripts should be executed as follows:


# Validation of IMI

Validation Procedure of Motivation Surveys ([validation-motivation-surveys.pdf](../report/validation-motivation-surveys.pdf) - the results of validation is also summarized in this file) 

## Validation for the global sample gathered through all empirical studies:

* Goodness of fit statistics of factorial structure for the adapted Portuguese IMI ([cfa-model-fit.pdf](../report/validation-IMI/cfa-model-fit.pdf))
* CFA analysis and a reliability test of the adapted Portuguese IMI ([reliability-analysis.pdf](../report/validation-IMI/reliability-analysis.pdf) or [RelAnalysis.xlsx](../report/validation-IMI/RelAnalysis.xlsx))

## Validation for the sample gathered in the first empirical study

* CFA analysis and a reliability test of the adapted Portuguese IMI ([IMI-reliability-analysis.pdf](report/latex/IMI-reliability-analysis.pdf) or [IMI.xlsx](report/reliability-analysis/IMI.xlsx))


# Significant Differences on Students' Motivation

## Finding significant differences based on the mean scores for all students (signed-up students)

* Summary of Nonparametric and Parametric tests ([summary-scr-analysis.pdf](report/latex/motivation-signedup/summary-scr-analysis.pdf))

* Nonparametric tests of Intrinsic Motivation ([nonparametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-intrinsic-motivation-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Intrinsic Motivation ([parametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-signedup/parametric-intrinsic-motivation-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Interest/Enjoyment ([nonparametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-interest-enjoyment-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Interest/Enjoyment ([parametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-signedup/parametric-interest-enjoyment-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Perceived Choice ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-perceived-choice-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Perceived Choice ([parametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-signedup/parametric-perceived-choice-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Pressure/Tension ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-pressure-tension-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Pressure/Tension ([parametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-signedup/parametric-pressure-tension-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Effort/Importance ([nonparametric-effort-importance-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-effort-importance-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Effort/Importance ([parametric-effort-importance-scr-analysis.pdf](report/latex/motivation-signedup/parametric-effort-importance-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/effort-importance/by-Type/ParametricAnalysis.xlsx) with normality test)

## Finding significant differences based on the mean scores for students with effective participation (effective students)

* Summary of Nonparametric and Parametric tests ([summary-scr-analysis.pdf](report/latex/motivation-effective/summary-scr-analysis.pdf))

* Nonparametric tests of Intrinsic Motivation ([nonparametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-intrinsic-motivation-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/intrinsic-motivation/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Intrinsic Motivation ([parametric-intrinsic-motivation-scr-analysis.pdf](report/latex/motivation-effective/parametric-intrinsic-motivation-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/intrinsic-motivation/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Interest/Enjoyment ([nonparametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-interest-enjoyment-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Interest/Enjoyment ([parametric-interest-enjoyment-scr-analysis.pdf](report/latex/motivation-effective/parametric-interest-enjoyment-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/interest-enjoyment/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Perceived Choice ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-perceived-choice-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Perceived Choice ([parametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/parametric-perceived-choice-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/perceived-choice/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Pressure/Tension ([nonparametric-perceived-choice-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-pressure-tension-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Pressure/Tension ([parametric-pressure-tension-scr-analysis.pdf](report/latex/motivation-effective/parametric-pressure-tension-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/pressure-tension/by-Type/ParametricAnalysis.xlsx) with normality test)

* Nonparametric tests of Effort/Importance ([nonparametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-effort-importance-scr-analysis.pdf), [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/NonParametricAnalysis.xlsx))
* Parametric tests of Effort/Importance ([parametric-effort-importance-scr-analysis.pdf](report/latex/motivation-effective/parametric-effort-importance-scr-analysis.pdf), [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/effort-importance/by-Type/ParametricAnalysis.xlsx) with normality test)

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

