# Empirical Study 02

Comparing *ontology-based gamified CL sessions* (**ont-gamified**) against *non-gamified CL sessions* (**non-gamified**)

* **CSCL Script**: CSCL script inspired by Cognitive Apprentice
* **Content-domain**: Loop Structures - Course of Introduction to Computer Science
* **Participants**: 58 undergraduate Brazilian Computer Engineering Students

All materials used in the empirical study are available at ([materials](materials/))

### Research Questions

* **RQ1**: Do the ont-gamified CL sessions have positive impacts on the students' motivation?
* **RQ2**: Do the ont-gamified CL sessions affect on the students' learning outcomes?
* **RQ3**: Are the participants' motivation and learning outcomes linked in those sessions?

## Scripts to answer the RQ1

**RQ1:** `Do the ont-gamified CL sessions have positive impacts on the students' motivation?`


### R script to validate the IMMS questionnaire ([00-reliability-analysis-IMMS.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/00-reliability-analysis-IMMS.R))

R script to validate data gathered in the empirical study through the IMMS questionnaire.

The results obtained by the execution of this R script are:

* PDF-file with the summary of fatorial analysis and reliability test

  _File_: [IMMS-reliability-analysis.pdf](report/latex/IMMS-reliability-analysis.pdf)

* Excel-file with detailed information of measure sampling adequacy, factorial analysis, and reliability test

  _File_: [IMMS.xlsx](report/reliability-analysis/IMMS.xlsx)

* CSV-file with the responses on the IMMS questionnaire with validated items

  _File_: [IMMS.csv](data/IMMS.csv) ([more info ...](data/))

This validation of the IMMS questionnarie was carried out with all the data gathered throughout all empirical studies, and this procedure is detailed in [../report/validation-IMMS/](../report/validation-IMMS/).


### R script to find significant differences on the scores of motivation for all students ([01-scr-motivation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/01-scr-motivation-signedup-analysis.R))

R script to find significant differences on the motivation scores obtained through the IMMS questionnaire, and for all the students signed-up as participants in the CL sessions.
These differences were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-scr-analysis.pdf](report/latex/motivation-signedup/summary-scr-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Attention*

  _File_: [nonparametric-attention-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-attention-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Attention*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/attention/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Relevance*

  _File_: [nonparametric-relevance-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-relevance-scr-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Relevance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/relevance/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Satisfaction*

  _File_: [nonparametric-satisfaction-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-satisfaction-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Satisfaction*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/satisfaction/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Level of Motivation*

  _File_: [nonparametric-level-of-motivation-scr-analysis.pdf](report/latex/motivation-signedup/nonparametric-level-of-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Level of Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/level-of-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-scr-level-of-motivation.pdf](report/latex/motivation-signedup/wisorized-scr-level-of-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Attention*

  _File_: [parametric-attention-scr-analysis.pdf](report/latex/motivation-signedup/parametric-attention-scr-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Attention*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/attention/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Relevance*

  _File_: [parametric-relevance-scr-analysis.pdf](report/latex/motivation-signedup/parametric-relevance-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Relevance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/relevance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Satisfaction*

  _File_: [parametric-satisfaction-scr-analysis.pdf](report/latex/motivation-signedup/parametric-satisfaction-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Satisfaction*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/satisfaction/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Level of Motivation*

  _File_: [parametric-level-of-motivation-scr-analysis.pdf](report/latex/motivation-signedup/parametric-level-of-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Level of Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-signedup-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to find significant differences on the scores of motivation for students with effective participation ([01-scr-motivation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/01-scr-motivation-effective-analysis.R))

R script to find significant differences on the motivation scores obtained through the IMMS questionnaire, and for the students with effective participation in the CL sessions.
These differences were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-scr-analysis.pdf](report/latex/motivation-effective/summary-scr-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Attention*

  _File_: [nonparametric-attention-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-attention-scr-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Attention*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/attention/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Relevance*

  _File_: [nonparametric-relevance-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-relevance-scr-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Relevance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/relevance/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Satisfaction*

  _File_: [nonparametric-satisfaction-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-satisfaction-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Satisfaction*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/satisfaction/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Level of Motivation*

  _File_: [nonparametric-level-of-motivation-scr-analysis.pdf](report/latex/motivation-effective/nonparametric-level-of-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Level of Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/scr-effective-participants/level-of-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-scr-level-of-motivation.pdf](report/latex/motivation-effective/wisorized-scr-level-of-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Attention*

  _File_: [parametric-attention-scr-analysis.pdf](report/latex/motivation-effective/parametric-attention-scr-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Attention*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/attention/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Relevance*

  _File_: [parametric-relevance-scr-analysis.pdf](report/latex/motivation-effective/parametric-relevance-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Relevance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/relevance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Satisfaction*

  _File_: [parametric-satisfaction-scr-analysis.pdf](report/latex/motivation-effective/parametric-satisfaction-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Satisfaction*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/satisfaction/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Level of Motivation*

  _File_: [parametric-level-of-motivation-scr-analysis.pdf](report/latex/motivation-effective/parametric-level-of-motivation-scr-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Level of Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/scr-effective-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to calculate the IRT-based estimates of students' motivation ([00-rsm-motivation-measurement-building.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/00-rsm-motivation-measurement-building.R))

R script to calculate the IRT-based estimates of students' motivations through the building of RMS-based measurement instruments. These estimates were calculated based on the *Item Response Theory* (IRT) and *Rating Scale Model* (RSM), and through the process detailed in the file: [irt-instruments.pdf](../report/irt-instruments.pdf). 

The results obtained by the execution of this R script are:
 
* PDF-file with the summary of the IRT-based instruments to estimate the students' motivation

  _File_: [rsm-motivation.pdf](report/latex/rsm-motivation.pdf)

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Attention*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/attention/MeasurementModel.xlsx)

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Relevance*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/relevance/MeasurementModel.xlsx)

* Excel-file with the report of the IRT-based instrument to calculate the estimates of *Satisfaction*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/satisfaction/MeasurementModel.xlsx)

* Excel-file with the report of the IRT-based instrument to calculate the estimates of the *Level of Motivation*.
  
  _File_: [MeasurementModel.xlsx](report/irt-motivation/level-of-motivation/MeasurementModel.xlsx)

* CSV-file with the IRT-based estimates of *Attention*:

  _File_: [Attention.csv](data/Attention.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Relevance*:

  _File_: [Relevance.csv](data/Relevance.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Satisfaction*:

  _File_: [Satisfaction.csv](data/Satisfaction.csv) ([more info ...](data/))

* CSV-file with the IRT-based estimates of *Level of Motivation*:

  _File_: [LevelofMotivation.csv](data/LevelofMotivation.csv) ([more info ...](data/))


### R script to find significant differences on the IRT-based estimates of motivation for all students ([01-rsm-motivation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/01-rsm-motivation-signedup-analysis.R))

R script to find significant differences on the IRT-based estimates of motivation obtained through the RSM-based measurment instrument of motivation built from the IMI questionnaire.
These differences were find on the estimates of motivation for all the students signed-up as participants in the CL sessions, and they were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-analysis.pdf](report/latex/motivation-signedup/summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Attention*

  _File_: [nonparametric-attention-analysis.pdf](report/latex/motivation-signedup/nonparametric-attention-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Attention*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/attention/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Relevance*

  _File_: [nonparametric-relevance-analysis.pdf](report/latex/motivation-signedup/nonparametric-relevance-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Relevance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/relevance/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Satisfaction*

  _File_: [nonparametric-satisfaction-analysis.pdf](report/latex/motivation-signedup/nonparametric-satisfaction-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Satisfaction*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/satisfaction/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Level of Motivation*

  _File_: [nonparametric-level-of-motivation-analysis.pdf](report/latex/motivation-signedup/nonparametric-level-of-motivation-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Level of Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/signedup-participants/level-of-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-level-motivation.pdf](report/latex/motivation-signedup/wisorized-level-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Attention*

  _File_: [parametric-attention-analysis.pdf](report/latex/motivation-signedup/parametric-attention-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Attention*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/attention/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Relevance*

  _File_: [parametric-relevance-analysis.pdf](report/latex/motivation-signedup/parametric-relevance-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Relevance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/relevance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Satisfaction*

  _File_: [parametric-satisfaction-analysis.pdf](report/latex/motivation-signedup/parametric-satisfaction-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Satisfaction*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/satisfaction/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Level of Motivation*

  _File_: [parametric-level-of-motivation-analysis.pdf](report/latex/motivation-signedup/parametric-level-of-motivation-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Level of Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/signedup-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx)


### R script to find significant differences on the IRT-based estimates of motivation for students with effective participation ([01-rsm-motivation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/01-rsm-motivation-effective-analysis.R))

R script to find significant differences on the IRT-based estimates of motivation obtained through the RSM-based measurment instrument of motivation built from the IMI questionnaire.
These differences were finding on the estimates of motivation for students with effectie participantion in the CL sessions, and they were firstly finding by using the nonparametric statistical tests as the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, by using the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found on the students' motivation.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [summary-analysis.pdf](report/latex/motivation-effective/summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis on the *Attention*

  _File_: [nonparametric-attention-analysis.pdf](report/latex/motivation-effective/nonparametric-attention-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis on the *Attention*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/attention/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Relevance*

  _File_: [nonparametric-relevance-analysis.pdf](report/latex/motivation-effective/nonparametric-relevance-analysis.pdf)  

* Excel-file with the detailed information of nonparametric analysis on the *Relevance*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/relevance/by-Type/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of nonparametric analysis on the *Satisfaction*

  _File_: [nonparametric-satisfaction-analysis.pdf](report/latex/motivation-effective/nonparametric-satisfaction-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Satisfaction*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/satisfaction/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of nonparametric analysis on the *Level of Motivation*

  _File_: [nonparametric-level-of-motivation-analysis.pdf](report/latex/motivation-effective/nonparametric-level-of-motivation-analysis.pdf)

* Excel-file with the detailed information of nonparametric analysis on the *Level of Motivation*

  _File_: [NonParametricAnalysis.xlsx](report/motivation/effective-participants/level-of-motivation/by-Type/NonParametricAnalysis.xlsx)

* PDF-file with the summary of winsorization applied to perform the parametric analysis

  _File_: [wisorized-level-motivation.pdf](report/latex/motivation-effective/wisorized-level-motivation.pdf)

* PDF-file with the summary of parametric analysis on the *Attention*

  _File_: [parametric-attention-analysis.pdf](report/latex/motivation-effective/parametric-attention-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis on the *Attention*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/attention/by-Type/ParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis on the *Relevance*

  _File_: [parametric-relevance-analysis.pdf](report/latex/motivation-effective/parametric-relevance-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Relevance*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/relevance/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Satisfaction*

  _File_: [parametric-satisfaction-analysis.pdf](report/latex/motivation-effective/parametric-satisfaction-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Satisfaction*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/satisfaction/by-Type/ParametricAnalysis.xlsx)

* PDF-file with the summary of parametric analysis on the *Level of Motivation*

  _File_: [parametric-level-of-motivation-analysis.pdf](report/latex/motivation-effective/parametric-level-of-motivation-analysis.pdf)

* Excel-file with the detailed information of parametric analysis on the *Level of Motivation*

  _File_: [ParametricAnalysis.xlsx](report/motivation/effective-participants/level-of-motivation/by-Type/ParametricAnalysis.xlsx)


## Scripts to answer the RQ2

**RQ2:** `Do the ont-gamified CL sessions affect on the students' learning outcomes?`


### R script to find significant differences on the gain scores of academic performance tests for all students ([02-scr-learning-outcomes-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/02-scr-learning-outcomes-signedup-analysis.R))

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


### R script to find significant differences on the gain scores of academic performance tests for students with effective participation ([02-scr-learning-outcomes-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/02-scr-learning-outcomes-effective-analysis.R))

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
  

### R script to calculate the IRT-based estimates of learning outcomes ([00-gpcm-learning-outcomes-measurement-building.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/00-gpcm-learning-outcomes-measurement-building.R))

R script to calculate the IRT-based estimates of the students' gains in skill/knowledge.
These estimates were calculated using the stacking process based on the *General-Partial Credit Model* (GPCM), and this process is detailed in the file: [irt-instruments.pdf](../report/irt-instruments.pdf). 

The results obtained by the execution of this R script are:
 
* PDF-file with the summary of the GPCM-based instruments to estimate the students' skill/knowledge during the pretest and posttest phases 

  _File_: [gpcm-learning-outcomes.pdf](report/latex/gpcm-learning-outcomes.pdf)

* Excel-file with the report of the stacking process using the GPCM-based instruments to estimate the gains of students' skill/knowledge
  
  _File_: [MeasurementChangeModel.xlsx](report/learning-outcomes/MeasurementChangeModel.xlsx)

* CSV-file with the IRT-based estimates of *Gain in Skill/Knowledge* of students

  _File_: [GainSkillsKnowledge.csv](data/GainSkillsKnowledge.csv) ([more info ...](data/))


### R script to find significant differences on the estimates of skill/knowledge gains for all students ([02-gpcm-learning-outcomes-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/02-gpcm-learning-outcomes-signedup-analysis.R))

R script to find statistical significant differences on the estimates of skill/knowledge gains (`posttest - pretest`) obtained through the AMC questionnaires and solving-programming problem tasks.
This statistical analysis was carried out with data gathered from the responses of all the students signed-up as participants in the CL sessions.
Firstly, a nonparametric analysis was carried out by using the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, through the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found by the nonparametric analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [signedup-participants-summary-analysis.pdf](report/latex/learning-outcomes/signedup-participants-summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis

  _File_: [nonparametric-signedup-participants-analysis.pdf](report/latex/learning-outcomes/nonparametric-signedup-participants-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis

  _File_: [NonParametricAnalysis.xlsx](report/learning-outcomes/signedup-participants/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis

  _File_: [parametric-signedup-participants-analysis.pdf](report/latex/learning-outcomes/parametric-signedup-participants-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis

  _File_: [ParametricAnalysis.xlsx](report/learning-outcomes/signedup-participants/ParametricAnalysis.xlsx)


### R script to find significant differences on the estimates of skill/knowledge gains for students with effective participation ([02-gpcm-learning-outcomes-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/02-gpcm-learning-outcomes-effective-analysis.R))

R script to find statistical significant differences on the estimates of skill/knowledge gains (`posttest - pretest`) obtained through the AMC questionnaires and solving-programming problem tasks.
This statistical analysis was carried out with data gathered from the responses of students with effective participation in the CL sessions.
Firstly, a nonparametric analysis was carried out by using the Scheirer-Ray-Hare test and the pair-wilcoxon test.
After this, through the parametric tests of ANOVA and Tukey post-hoc, we confirmed the statistical significant differences found by the nonparametric analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of nonparametric and parametric tests

  _File_: [effective-participants-summary-analysis.pdf](report/latex/learning-outcomes/effective-participants-summary-analysis.pdf)

* PDF-file with the summary of nonparametric analysis

  _File_: [nonparametric-effective-participants-analysis.pdf](report/latex/learning-outcomes/nonparametric-effective-participants-analysis.pdf) 

* Excel-file with the detailed information of nonparametric analysis

  _File_: [NonParametricAnalysis.xlsx](report/learning-outcomes/effective-participants/NonParametricAnalysis.xlsx)
  
* PDF-file with the summary of parametric analysis

  _File_: [parametric-effective-participants-analysis.pdf](report/latex/learning-outcomes/parametric-effective-participants-analysis.pdf) 

* Excel-file with the detailed information of parametric analysis

  _File_: [ParametricAnalysis.xlsx](report/learning-outcomes/effective-participants/ParametricAnalysis.xlsx)
  

## Scripts to answer the RQ3

**RQ3:** `Are the participants' motivation and learning outcomes linked in ont-gamified and non-gamified CL sessions?`


### R script to find significant correlations between motivation scores and gain scores on academic performance tests for all the students ([03-scr-correlation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/03-scr-correlation-signedup-analysis.R))

R script to statistically find significant correlations between students' motivation and their gains of skill/knowledge during the empirical study.
The students' motivation for this correlation analysis was carried out employing the motivation scores calculated through the IMI questionnaires, and for all the students signed-up as participants in the CL sessions.
The students' gains of skill/knowledge were calculated by teacher-based rules on the AMC questionnaires and programming problem tasks. Spearman's Rank method was also used for this correlation analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of Sperman's Rank correlation tests

  _File_: [correlation-scr-signedup-analysis.pdf](report/latex/correlation-scr-signedup-analysis.pdf)
  
* Excel-file with detailed information of the Spearman's Rank correlation

  _File_: [CorrMatrixAnalysis.xlsx](report/correlation/scr-signedup-participants/CorrMatrixAnalysis.xlsx)

* Excel-file with detailed information of the Spearman's Rank weak correlation

  _File_: [SimpleCorrPairAnalysis-weak.xlsx](report/correlation/scr-signedup-participants/SimpleCorrPairAnalysis-weak.xlsx)

* Excel-file with detailed information of the Spearman's Rank moderate correlation

  _File_: [SimpleCorrPairAnalysis-moderate.xlsx](report/correlation/scr-signedup-participants/SimpleCorrPairAnalysis-moderate.xlsx)

* Excel-file with detailed information of the the Spearman's Rank strong correlation

  _File_: [SimpleCorrPairAnalysis-strong.xlsx](report/correlation/scr-signedup-participants/SimpleCorrPairAnalysis-strong.xlsx)


### R script to find significant correlations between motivation scores and gain scores on academic performance tests for students with effective participation ([03-scr-correlation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/03-scr-correlation-effective-analysis.R))

R script to statistically find significant correlations between students' motivation and their gains of skill/knowledge during the empirical study.
The students' motivation for this correlation analysis was carried out employing the motivation scores calculated through the IMI questionnaires, and for students with effective participation in the CL sessions.
The students' gains of skill/knowledge were calculated by teacher-based rules on the AMC questionnaires and programming problem tasks. Spearman's Rank method was also used for this correlation analysis.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of Sperman's Rank correlation tests

  _File_: [correlation-scr-effective-analysis.pdf](report/latex/correlation-scr-effective-analysis.pdf)
  
* Excel-file with detailed information of the Spearman's Rank correlation

  _File_: [CorrMatrixAnalysis.xlsx](report/correlation/scr-effective-participants/CorrMatrixAnalysis.xlsx)

* Excel-file with detailed information of the Spearman's Rank weak correlation

  _File_: [SimpleCorrPairAnalysis-weak.xlsx](report/correlation/scr-effective-participants/SimpleCorrPairAnalysis-weak.xlsx)

* Excel-file with detailed information of the Spearman's Rank moderate correlation

  _File_: [SimpleCorrPairAnalysis-moderate.xlsx](report/correlation/scr-effective-participants/SimpleCorrPairAnalysis-moderate.xlsx)

* Excel-file with detailed information of the the Spearman's Rank strong correlation

  _File_: [SimpleCorrPairAnalysis-strong.xlsx](report/correlation/scr-effective-participants/SimpleCorrPairAnalysis-strong.xlsx)



### R script to find significant correlations between the estimates of motivation and the gain of skill/knownedge for all the students ([03-irt-correlation-signedup-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/03-irt-correlation-signedup-analysis.R))

R script to statistically find significant correlations between students' motivation and their gains of skill/knowledge during the empirical study.
The students' motivation for this correlation analysis was carried out employing the IRT-based estimates of motivation calculated through the RSM-based intruments, and for all the students signed-up as participants in the CL sessions.
The students' gains of skill/knowledge were estimated by GPCM-based instruments on the AMC questionnaires and programming problem tasks. Spearman's Rank method was also used for this correlation analysis.

The results obtained by the execution of this R script are:

* PDF-file with the summary of Sperman's Rank correlation tests

  _File_: [correlation-signedup-analysis.pdf](report/latex/correlation-signedup-analysis.pdf)
  
* Excel-file with detailed information of the Spearman's Rank correlation

  _File_: [CorrMatrixAnalysis.xlsx](report/correlation/signedup-participants/CorrMatrixAnalysis.xlsx)

* Excel-file with detailed information of the Spearman's Rank weak correlation

  _File_: [SimpleCorrPairAnalysis-weak.xlsx](report/correlation/signedup-participants/SimpleCorrPairAnalysis-weak.xlsx)

* Excel-file with detailed information of the Spearman's Rank moderate correlation

  _File_: [SimpleCorrPairAnalysis-moderate.xlsx](report/correlation/signedup-participants/SimpleCorrPairAnalysis-moderate.xlsx)

* Excel-file with detailed information of the the Spearman's Rank strong correlation

  _File_: [SimpleCorrPairAnalysis-strong.xlsx](report/correlation/signedup-participants/SimpleCorrPairAnalysis-strong.xlsx)


### R script to find significant correlations between the estimates of motivation and the gain of skill/knownedge for students with effective participation ([03-scr-correlation-effective-analysis.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/study02/03-itr-correlation-effective-analysis.R))

R script to statistically find significant correlations between students' motivation and their gains of skill/knowledge during the empirical study.
The students' motivation for this correlation analysis was carried out employing the IRT-based estimates of motivation calculated through the RSM-based intruments, and for students with effective participantion in the CL sessions.
The students' gains of skill/knowledge were estimated by GPCM-based instruments on the AMC questionnaires and programming problem tasks. Spearman's Rank method was also used for this correlation analysis.

`A student with effective participation is a student that, at least one time, interacted with other member of the CL group by following the necessary interactions indicated in the CSCL script`

The results obtained by the execution of this R script are:

* PDF-file with the summary of Sperman's Rank correlation tests

  _File_: [correlation-effective-analysis.pdf](report/latex/correlation-effective-analysis.pdf)
  
* Excel-file with detailed information of the Spearman's Rank correlation

  _File_: [CorrMatrixAnalysis.xlsx](report/correlation/effective-participants/CorrMatrixAnalysis.xlsx)

* Excel-file with detailed information of the Spearman's Rank weak correlation

  _File_: [SimpleCorrPairAnalysis-weak.xlsx](report/correlation/effective-participants/SimpleCorrPairAnalysis-weak.xlsx)

* Excel-file with detailed information of the Spearman's Rank moderate correlation

  _File_: [SimpleCorrPairAnalysis-moderate.xlsx](report/correlation/effective-participants/SimpleCorrPairAnalysis-moderate.xlsx)

* Excel-file with detailed information of the the Spearman's Rank strong correlation

  _File_: [SimpleCorrPairAnalysis-strong.xlsx](report/correlation/effective-participants/SimpleCorrPairAnalysis-strong.xlsx)

