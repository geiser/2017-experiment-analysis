# Evaluation of the Ontological Engineering Approach to Gamify Collaborative Learning Scenarios




## Empirical Studies

* [pilot empirical study](pilot-study/)
* [first empirical study](study01/)
* [second empirical study](study02/)
* [third empirical study](study03/)

## Scripts in this folder - path: [/](https://github.com/geiser/phd-thesis-evaluation/)


### R script to extract information from the Moodle platform ([00-processing-mysql.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-mysql.R))

R script to extract information from the MySQL database of the Moodle platform. 

The results obtained by the execution of this R script are:

* List of all students as participants in the pilot empirical study (lines 15-70)<br/>
  _File_: [SignedUpParticipants.csv](pilot-study/data/SignedUpParticipants.csv) ([more info ...](pilot-study/data/))
* List of students with effective participation in the pilot empirical study (lines 72-80)<br/>
  _File_: [EffectiveParticipants.csv](pilot-study/data/EffectiveParticipants.csv) ([more info ...](pilot-study/data/))
* Experiment design for the pilot empirical study (lines 81-114)<br/>
  _File_: [pilot_design.csv](report/pilot_design.csv) ([more info ...](report/))
* Information from the IMI questionnaire - pilot empirical study (lines 120-205)<br/>
  _File_ (legend): [SourceIMILegend.csv](pilot-study/data/SourceIMILegend.csv) ([more info ...](pilot-study/data/))<br/>
  _File_ (responses): [SourceIMIWithCareless.csv](pilot-study/data/SourceIMIWithCareless.csv) ([more info ...](pilot-study/data/))
* List of all students as participants in the first empirical study (lines 210-272)<br/>
  _File_: [SignedUpParticipants.csv](study01/data/SignedUpParticipants.csv) ([more info ...](study01/data/))
* List of all students as participants in the second empirical study (lines 273-325)<br/>
  _File_: [SignedUpParticipants.csv](study02/data/SignedUpParticipants.csv) ([more info ...](study02/data/))
* List of all students as participants in the third empirical study (lines 326-395)<br/>
  _File_: [SignedUpParticipants.csv](study03/data/SignedUpParticipants.csv) ([more info ...](study03/data/))
* List of students with effective participation in the full-scale empirical studies (400-425)<br/>
  _File_ (first empirical study): [EffectiveParticipants.csv](study01/data/EffectiveParticipants.csv) ([more info ...](study01/data/))<br/>
  _File_ (second empirical sudy): [EffectiveParticipants.csv](study02/data/EffectiveParticipants.csv) ([more info ...](study02/data/))<br/>
  _File_ (third empirical study): [EffectiveParticipants.csv](study03/data/EffectiveParticipants.csv) ([more info ...](study03/data/))
* Experiment designs for the full-scale empirical studies (lines 427-508)<br/>
  _File_: [exp_design.csv](report/exp_design.csv) ([more info ...](report/))
* Information from the IMI and IMMS questionnaires - third empirical study (lines 510-620)<br/>
  _File_ (legend): [SourceMotLegend.csv](study03/data/SourceMotLegend.csv) ([more info...](study03/data/))<br/>
  _File_ (responses from the IMI questionnaire): [SourceIMIWithCareless.csv](study03/data/SourceIMIWithCareless.csv) ([more info ...](study03/data/))<br/>
  _File_ (responses from the IMMS questionnaire): [SourceIMMSWithCareless.csv](study03/data/SourceIMMSWithCareless.csv) ([more info ...](study03/data/))


### R script to extract information from AMC questionnaires ([00-processing-amc.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-amc.R)).

R script to extract information from responses of AMC (Auto-Multiple-Choice) questionnaires. Such questionnaires were built to measure the skill/knowledge of students throughout the empirical studies, and they were built using the AMC software - [https://www.auto-multiple-choice.net](https://www.auto-multiple-choice.net).

The results obtained by the execution of this R script are:

* Data with responses from the AMC questionnaire of conditional structures *p1a*. Responses obtained throughout the *pretest* phase of the *first* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PreAMC.csv](study01/data/PreAMC.csv) ([more info ...](study01/data))
* Data with responses from the AMC questionnaire of conditional structures *p1b*. Responses obtained throughout the *posttest* phase of the *first* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PosAMC.csv](study01/data/PosAMC.csv) ([more info ...](study01/data))]
* Data with responses from the AMC questionnaire of conditional structures *p2a*. Responses obtained throughout the *pretest* phase of the *first* empirical study and scored using the *teacher's rule*.<br/>
  _File_: [PreAMCscr.csv](study01/data/PreAMCscr.csv) ([more info ...](study01/data))
* Data with responses from the AMC questionnaire of conditional structures *p2b*. Responses obtained throughout the *posttest* phase of the *first* empirical study and scored using the *teacher's rule*.<br/>
  _File_: [PosAMCscr.csv](study01/data/PosAMCscr.csv) ([more info ...](study01/data))
* Data with responses from the AMC questionnaire of loop structures *p2a*. Responses obtained throughout the *pretest* phase of thr *second* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PreAMC.csv](study02/data/PreAMC.csv) ([more info ...](study02/data))
* Data with responses from the AMC questionnaire of loop structures *p2b*. Responses obtained throughout the *posttest* phase of the *second* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PosAMC.csv](study02/data/PosAMC.csv) ([more info ...](study02/data))
* Data with responses from the AMC questionnaire of loop structures *p2a*. Responses obtained throughout the *pretest* phase of the *second* empirical study and and scored using the *teacher's rule*.<br/>
  _File_: [PreAMCscr.csv](study02/data/PreAMCscr.csv) ([more info ...](study02/data))
* Data with responses from the AMC questionnaire of loop structures *p2b*. Responses obtained throughout the *posttest* phase of the *second* empirical study and scored using the *teacher's rule*.<br/>
  _File_: [PosAMCscr.csv](study02/data/PosAMCscr.csv) ([more info ...](study02/data))
* Data with responses from the AMC questionnaire of recursion *p3a*. Responses obtained throughout the *pretest* phase of the *third* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PreAMC.csv](study03/data/PreAMC.csv) ([more info ...](study03/data))
* Data with responses from the AMC questionnaire of recursion *p3c*. Responses obtained throughout the *posttest* phase of the *third* empirical study and scored using the *GPCM-based rule*.<br/>
  _File_: [PosAMC.csv](study03/data/PosAMC.csv) ([more info ...](study03/data))
* Data with responses from the AMC questionnaire of recursion *p3a*. Responses obtained throughout the *pretest* phase of the *third* empirical study and scored using the *teacher's rule*.<br/>
  _File_: [PreAMCscr.csv](study03/data/PreAMCscr.csv) ([more info ...](study03/data))
* Data with responses from the AMC questionnaire of recursion *p3c*. Responses obtained throughout the *posttest* phase of the *third* empirical study and scored using the *teacher's rule*.<br/>
  _File_: [PosAMCscr.csv](study03/data/PosAMCscr.csv) ([more info ...](study03/data))


### R script to extract information related to the VPL Moodle plugin ([00-processing-vpl.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-vpl.R))

R script to extract information related to the adapted version of VPL (Virtual-Programming-Lab) Moodle plugin. This adapted VPL Moodle plugin with code recording log can be download from: [https://github.com/geiser/moodle-mod_vpl](https://github.com/geiser/moodle-mod_vpl/).

The results obtained by the execution of this R script are: 

* Information of the programming problem tasks solved throughout the *pretest* phase of the *pilot* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PreGuttmanVPL.csv](pilot-study/data/PreGuttmanVPL.csv) ([more info ...](pilot-study/data))
* Information of the programming problem tasks solved throughout the *posttest* phase of the *pilot* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PosGuttmanVPL.csv](pilot-study/data/PosGuttmanVPL.csv) ([more info ...](pilot-study/data))
* Information of the programming problem tasks solved throughout the *pretest* phase of the *first* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PreGuttmanVPL.csv](study01/data/PreGuttmanVPL.csv) ([more info ...](study01/data))
* Information of the programming problem tasks solved throughout the *pretest* phase of the *first* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PosGuttmanVPL.csv](study01/data/PosGuttmanVPL.csv) ([more info ...](study01/data))
* Information of the programming problem tasks solved throughout the *pretest* phase of *second* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PreGuttmanVPL.csv](study02/data/PreGuttmanVPL.csv) ([more info ...](study02/data))
* Information of the programming problem tasks solved throughout the *pretest* phase of *second* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PosGuttmanVPL.csv](study02/data/PosGuttmanVPL.csv) ([more info ...](study02/data))
* Information of the programming problem tasks solved throughout the *pretest* phase of *third* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PreGuttmanVPL.csv](study03/data/PreGuttmanVPL.csv) ([more info ...](study03/data))
* Information of the programming problem tasks obtained throughout the *pretest* phase of *third* empirical study, and scored with *Guttman-based rules*.<br/>
  _File_: [PosGuttmanVPL.csv](study03/data/PosGuttmanVPL.csv) ([more info ...](study03/data))


### R script to remove careless responses ([01-removing-careless-motivation.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/01-removing-careless-motivation.R))

R script to remove careless responses on the data gathered by the IMI and IMMS questionnaires. A careless response is defined as a response in which the length of uninterrupted identical values for the items is greater than half of the items in the questionnaire.

The results obtained by the execution of this R script are:

* Careless responses identified on the IMI questionnaire with data gathered throughout the pilot empirical study.<br/>
  _File_: [careless-IMI-pilot-study.pdf](report/latex/careless-IMI-pilot-study.pdf) ([more info ...](pilot-study/data))
* Responses of the IMI questionnaire with data gathered throughout the pilot empirical study and without careless responses.<br/>
  _File_: [SourceIMI.csv](pilot-study/data/SourceIMI.csv) ([more info ...](pilot-study/data))

* Careless responses identified on the IMI questionnaire with data gathered throughout the first empirical study.<br/>
  _File_: [careless-IMI-pilot-study.pdf](report/latex/careless-IMI-pilot-study.pdf) ([more info ...](pilot-study/data))
* Responses of the IMI questionnaire with data gathered throughout the first empirical study and without careless responses.<br/>
  _File_: [SourceIMI.csv](pilot-study/data/SourceIMI.csv) ([more info ...](pilot-study/data))

* Careless responses identified on the IMI questionnaire with data gathered throughout pilot empirical study<br/>
  _File_: [careless-IMI-pilot-study.pdf](report/latex/careless-IMI-pilot-study.pdf) ([more info ...](pilot-study/data))
* Responses of the IMI questionnaire with data gathered throughout pilot empirical study and without careless responses<br/>
  _File_: [SourceIMI.csv](pilot-study/data/SourceIMI.csv) ([more info ...](pilot-study/data))

* Careless responses identified on the IMI questionnaire with data gathered throughout pilot empirical study<br/>
  _File_: [careless-IMI-pilot-study.pdf](report/latex/careless-IMI-pilot-study.pdf) ([more info ...](pilot-study/data))
* Responses of the IMI questionnaire with data gathered throughout pilot empirical study and without careless responses<br/>
  _File_: [SourceIMI.csv](pilot-study/data/SourceIMI.csv) ([more info ...](pilot-study/data))

* In reference to the first empirical study,
    - _Result_: Careless responses identified on the IMI questionnaire: [careless-IMI-study01.pdf](report/latex/careless-IMI-study01.pdf)
    - _Result_: Responses of IMI questionnaire without careless responses: [SourceIMI.csv](study01/data/SourceIMI.csv) ([more info ...](study01/data))
* In reference to the second empirical study,
    - _Result_: Careless responses identified on the IMMS questionnaire: [careless-IMMS-study02.pdf](report/latex/careless-IMMS-study02.pdf)
    - _Result_: Responses of IMMS questionnaire without careless responses: [SourceIMMS.csv](study02/data/SourceIMMS.csv) ([more info ...](study02/data))
  - In reference to the third empirical study,
    - _Result_: Careless responses identified on the IMI questionnaire: [careless-IMI-study03.pdf](report/latex/careless-IMI-study03.pdf)
    - _Result_: Responses of IMI questionnaire without careless responses: [SourceIMI.csv](study03/data/SourceIMI.csv) ([more info ...](study03/data))
    - _Result_: Careless responses identified on the IMMS questionnaire: [careless-IMMS-study03.pdf](report/latex/careless-IMMS-study03.pdf)
    - _Result_: Responses of IMMS questionnaire without careless responses: [SourceIMMS.csv](study03/data/SourceIMMS.csv) ([more info ...](study03/data))


### R script to winsorize extreme responses ([02-winsorizing-extreme-motivation.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/02-winsorizing-extreme-motivation.R))

R script to winsorize extreme responses from the data gathered through the IMI and IMMS questionnaires. Extreme responses correspond to answers given by participants who have tendency to indicate extreme lower and upper values in questionnaires. Such responses are outliers that affect the assumptions for parametric tests, but that can't simply removed to satisfy these assumptions. To reduce the impact of extreme values, they should be shrunk to the border of the main part of the data through the winsorization method.

The results obtained by the execution of this R script are: 

* Extreme responses identified on the IMI questionnaire.<br/>
  _File_: [winsorized-IMI.pdf](report/latex/winsorized-IMI.pdf) ([more info ...](report/latex))
* Extreme responses identified on the IMMS questionnaire.<br/>
  _File_: [winsorized-IMMS.pdf](report/latex/winsorized-IMMS.pdf) ([more info ...](report/latex))
* Data with winsorized responses to validate the IMI questionnaire.<br/>
  _File_: [WinsorizedIMI.csv](data/WinsorizedIMI.csv) ([more info ...](data))
* Data with winsorized responses to validate the IMMS questionnaire.<br/>
  _File_: [WinsorizedIMMS.csv](data/WinsorizedIMMS.csv) ([more info ...](data))


### R script to validate the IMI questionnaire ([03-validating-IMI.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/03-validating-IMI.R))

R script to validate the adapted Portuguese IMI questionnaire through the exploratory/confirmatory factorial analysis and the reliability test.

The results obtained by the execution of this R script are:

* Validation of univariate distribution for each items.<br/>
  _File_: [univariate-histogram.png](report/validation-IMI/univariate-histogram.png) ([more info ...](report/validation-IMI))
* Goodness of fit statistics for the factorial analysis on the responses of IMI questionnaire.<br/>
  _File_: [cfa-model-fit.pdf](report/validation-IMI/cfa-model-fit.pdf)
* Summary of the factorial analysis and reliability test.<br/>
  _File_: [reliability-analysis.pdf](report/validation-IMI/reliability-analysis.pdf) ([more info ...](report/validation-IMI))
* Report for the measure sampling adequacy, factorial analysis, and reliability test.<br/>
  _File_: [RelAnalysis.xlsx](report/validation-IMI/RelAnalysis.xlsx) ([more info ...](report/validation-IMI))
* Data with the responses of the validated IMI questionnaire.<br/>
  _File_: [IMI.csv](data/IMI.csv) ([more info ...](data))
