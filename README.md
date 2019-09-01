# Evaluation of the Ontological Engineering Approach to Gamify Collaborative Learning Scenarios




## Empirical Studies

* [pilot empirical study](pilot-study/)
* [first empirical study](study01/)
* [second empirical study](study02/)
* [third empirical study](study03/)

## Scripts in this folder - path: [/](https://github.com/geiser/phd-thesis-evaluation/)
 

 * R script to extract information from Moodle platform ([00-processing-mysql.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-mysql.R))
   - List of all participants in the pilot empirical study (lines 15-70)<br/> _Result_: [SignedUpParticipants.csv](pilot-study/data/SignedUpParticipants.csv) ([more info ...](pilot-study/data/))
   - List of participants with effective participation in the pilot empirical study (lines 72-80)<br/> _Result_: [EffectiveParticipants.csv](pilot-study/data/EffectiveParticipants.csv) ([more info ...](pilot-study/data/))
   - Experiment design for the pilot empirical study (lines 81-114)<br/> _Result_: [pilot_design.csv](report/pilot_design.csv) ([more info ...](report/))
   - Information from the web-based version of the IMI questionnaire - pilot empirical study (lines 120-205).
     - _Result_: Legend of items: [SourceIMILegend.csv](pilot-study/data/SourceIMILegend.csv) ([more info ...](pilot-study/data/))
     - _Result_: Responses from the questionnaire: [SourceIMIWithCareless.csv](pilot-study/data/SourceIMIWithCareless.csv) ([more info ...](pilot-study/data/))
   - List of all participants in the first empirical study (lines 210-272)<br/> _Result_: [SignedUpParticipants.csv](study01/data/SignedUpParticipants.csv) ([more info ...](study01/data/))
   - List of all participants in the second empirical study (lines 273-325)<br/> _Result_: [SignedUpParticipants.csv](study02/data/SignedUpParticipants.csv) ([more info ...](study02/data/))
   - List of all participants in the third empirical study (lines 326-395)<br/> _Result_: [SignedUpParticipants.csv](study03/data/SignedUpParticipants.csv) ([more info ...](study03/data/))
   - List of participants with effective participation in the first, second and third empirical studies (400-425).
     - Participants with effective participation in the first empirical study<br/> _Result_: [EffectiveParticipants.csv](study01/data/EffectiveParticipants.csv) ([more info ...](study01/data/))
     - Participants with effective participation in the second empirical study<br/> _Result_: [EffectiveParticipants.csv](study02/data/EffectiveParticipants.csv) ([more info ...](study02/data/))
     - Participants with effective participation in the third empirical study<br/> _Result_: [EffectiveParticipants.csv](study03/data/EffectiveParticipants.csv) ([more info ...](study03/data/))
   - Experiment designs for the first, second and third empirical studies (lines 427-508)<br/> _Result_: [exp_design.csv](report/exp_design.csv) ([more info ...](report/))
   - Information from the IMI and IMMS questionnaires - third empirical study (lines 510-620).
     - _Result_: Legend of items: [SourceMotLegend.csv](study03/data/SourceMotLegend.csv) ([more info...](study03/data/))
     - _Result_: Responses from the IMI questionnaire: [SourceIMIWithCareless.csv](study03/data/SourceIMIWithCareless.csv) ([more info ...](study03/data/))
     - _Result_: Responses from the IMMS questionnaire: [SourceIMMSWithCareless.csv](study03/data/SourceIMMSWithCareless.csv) ([more info ...](study03/data/))

* R script to extract information from responses of multiple-choice knowledge questionnaires ([00-processing-amc.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-amc.R)) <br/> Such questionnaires were built using the AMC (Auto-Multiple-Choice) software - [https://www.auto-multiple-choice.net](https://www.auto-multiple-choice.net) 
   - Getting data to measure the skill/knowledge of participants in the first empirical study (lines 10-45)
     - _Result_: Responses from the multiple-choice knowledge questionnaire of conditional structures *p1a*. Responses obtained throughout the pretest phase and scored using the GPCM-based rule: [PreAMC.csv](study01/data/PreAMC.csv) ([more info ...](study01/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of conditional structures *p1b*. Responses obtained throughout the posttest phase and scored using the GPCM-based rule: [PosAMC.csv](study01/data/PosAMC.csv) ([more info ...](study01/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of conditional structures *p2a*. Responses obtained throughout the pretest phase and scored using the teacher's rule: [PreAMCscr.csv](study01/data/PreAMCscr.csv) ([more info ...](study01/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of conditional structures *p2b*. Responses obtained throughout the posttest phase and scored using the teacher's rule: [PosAMCscr.csv](study01/data/PosAMCscr.csv) ([more info ...](study01/data))
   - Getting data to measure the skill/knowledge of participants in the second empirical study (lines 46-80)
     - _Result_: Responses from the multiple-choice knowledge questionnaire of loop structures *p2a*. Responses obtained throughout the pretest phase and scored using the GPCM-based rule: [PreAMC.csv](study02/data/PreAMC.csv) ([more info ...](study02/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of loop structures *p2b*. Responses obtained throughout the posttest phase and scored using the GPCM-based rule: [PosAMC.csv](study02/data/PosAMC.csv) ([more info ...](study02/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of loop structures *p2a*. Responses obtained throughout the pretest phase and scored using the teacher's rule: [PreAMCscr.csv](study02/data/PreAMCscr.csv) ([more info ...](study02/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of loop structures *p2b*. Responses obtained throughout the posttest phase and scored using the teacher's rule: [PosAMCscr.csv](study02/data/PosAMCscr.csv) ([more info ...](study02/data))
   - Getting data to measure the skill/knowledge of participants in the third empirical study (lines 82-115)
     - _Result_: Responses from the multiple-choice knowledge questionnaire of recursion *p3a*. Responses obtained throughout the pretest phase and scored using the GPCM-based rule: [PreAMC.csv](study03/data/PreAMC.csv) ([more info ...](study03/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of recursion *p3c*. Responses obtained throughout the posttest phase and scored using the GPCM-based rule: [PosAMC.csv](study03/data/PosAMC.csv) ([more info ...](study03/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of recursion *p3a*. Responses obtained throughout the pretest phase and scored using the teacher's rule: [PreAMCscr.csv](study03/data/PreAMCscr.csv) ([more info ...](study03/data))
     - _Result_: Responses from the multiple-choice knowledge questionnaire of recursion *p3c*. Responses obtained throughout the posttest phase and scored using the teacher's rule: [PosAMCscr.csv](study03/data/PosAMCscr.csv) ([more info ...](study03/data))
     
* R script to extract information from the adapted version of VPL (Virtual-Programming-Lab) Moodle plugin ([00-processing-vpl.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/00-processing-vpl.R)) <br/> Such adapted version with code recording log can be downloaad from: [https://github.com/geiser/moodle-mod_vpl](https://github.com/geiser/moodle-mod_vpl/) 
   - _Result_ from programming problem tasks obtained throughout the pretest phase of pilot empirical study, and scored with Guttman-based rules: [PreGuttmanVPL.csv](pilot-study/data/PreGuttmanVPL.csv) ([more info ...](pilot-study/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of pilot empirical study, and scored with Guttman-based rules: [PosGuttmanVPL.csv](pilot-study/data/PosGuttmanVPL.csv) ([more info ...](pilot-study/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of first empirical study, and scored with Guttman-based rules: [PreGuttmanVPL.csv](study01/data/PreGuttmanVPL.csv) ([more info ...](study01/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of first empirical study, and scored with Guttman-based rules: [PosGuttmanVPL.csv](study01/data/PosGuttmanVPL.csv) ([more info ...](study01/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of second empirical study, and scored with Guttman-based rules: [PreGuttmanVPL.csv](study02/data/PreGuttmanVPL.csv) ([more info ...](study02/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of second empirical study, and scored with Guttman-based rules: [PosGuttmanVPL.csv](study02/data/PosGuttmanVPL.csv) ([more info ...](study02/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of third empirical study, and scored with Guttman-based rules: [PreGuttmanVPL.csv](study03/data/PreGuttmanVPL.csv) ([more info ...](study03/data))
   - _Result_ from programming problem tasks obtained throughout the pretest phase of third empirical study, and scored with Guttman-based rules: [PosGuttmanVPL.csv](study03/data/PosGuttmanVPL.csv) ([more info ...](study03/data))

* R script to remove careless responses on the data gathered through the IMI and IMMS questionnaires ([01-removing-careless-motivation.R](https://github.com/geiser/phd-thesis-evaluation/blob/master/01-removing-careless-motivation.R)) <br/> A careless response is defined as a response in which the length of uninterrupted identical values for the items is greater than half of the items in the questionnaire.
  - In reference to the pilot empirical study,
    - _Result_: Responses of IMI questionnaire without careless responses : [SourceIMI.csv](pilot-study/data/SourceIMI.csv) ([more info ...](pilot-study/data))
    - _Result_: Careless responses identified on the data gathered from IMI questionnaire: [careless-IMI-pilot-study.pdf](report/latex/careless-IMI-pilot-study.pdf)
  - In reference to the first empirical study,
    - _Result_: Responses of IMI questionnaire without careless responses : [SourceIMI.csv](study01/data/SourceIMI.csv) ([more info ...](study01/data))
    - _Result_: Careless responses identified on the data gathered from IMI questionnaire: [careless-IMI-study01.pdf](report/latex/careless-IMI-study01.pdf)
  - In reference to the second empirical study,
    - _Result_: Responses of IMMS questionnaire without careless responses : [SourceIMMS.csv](study02/data/SourceIMMS.csv) ([more info ...](study02/data))
    - _Result_: Careless responses identified on the data gathered from IMMS questionnaire: [careless-IMMS-study02.pdf](report/latex/careless-IMMS-study02.pdf)
  - In reference to the third empirical study,
    - _Result_: Responses of IMI questionnaire without careless responses : [SourceIMI.csv](study03/data/SourceIMI.csv) ([more info ...](study03/data))
    - _Result_: Careless responses identified on the data gathered from IMI questionnaire: [careless-IMI-study03.pdf](report/latex/careless-IMI-study03.pdf)
    - _Result_: Responses of IMMS questionnaire without careless responses : [SourceIMMS.csv](study03/data/SourceIMMS.csv) ([more info ...](study03/data))
    - _Result_: Careless responses identified on the data gathered from IMMS questionnaire: [careless-IMMS-study03.pdf](report/latex/careless-IMMS-study03.pdf)

