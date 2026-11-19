# PISA 2012 (US) data audit vs. TIMSS 2011 paper and OTL plan

Date: 2026-11-19. Sources: Zhang & Wang (2020) pp. 5–10 (data, measures, analysis); `Data to pull out from PISA 2012.docx`; `US_PISA_2012_STSCH.sav`.
Script: `scripts/a2_00_audit_pisa2012.py` (raw output in `from_code/a2_00_pisa2012_data_audit_output.txt`).

## 1. The TIMSS 2011 paper's design
- US grade 8. Students whose teachers use computers in class: math 3,398 students / 183 teachers; science 3,989 / 363.
- Student data aggregated to the teacher level.
- Measures:
  - **Computer as information tool:** 2 teacher items.
  - **Computer as learning tool:** 2 math items, 3 science items. Both computer measures are 4-point and reverse-coded.
  - **OTL:** teacher-reported topic coverage, with each item recoded to covered or not covered. It is the share of items covered in each of 4 topic areas, summed (range 0–4).
  - **SES:** composite of 8 home possessions, parent education and books, then standardized.
  - **Achievement:** 5 PVs.
- Analysis: PLS-SEM in WarpPLS 5.0, fit by APC, ARS and AVIF. Model 1 used the information tool and Model 2 the learning tool. In both, the computer measure moderates SES → achievement.
- Note: the PVs were used as 5 reflective indicators (alpha .99, AVE .99). PISA reviewers would object to this. With PISA, run the model once per PV and pool the results with Rubin's rules.

## 2. The PISA file
- 4,978 students in 162 schools; median 33 students per school.
- Weighted math mean is 481.4, which matches the published US figure. So W_FSTUWT and the PVs are right.
- Mostly grade 10 (73%), so this is an age-15 sample, not grade 8.
- Weights are present: W_FSTUWT, 80 BRR-Fay replicates (W_FSTR1–80) and W_FSCHWT.
- ICC of math is .24, which supports a two-level model.
- Every variable in the plan exists. The policy item is named `cSC40Q01`, with a leading c.

## 3. Problems found

| # | Issue | Evidence | Recommendation |
|---|---|---|---|
| A | **The PISA plan's OTL text and its variable table describe different items.** This is a mismatch inside the PISA plan doc, not a TIMSS-vs-PISA difference. The text (concepts from early primary to advanced secondary; Cogan & Schmidt 2015) describes **ST62**, the familiarity-with-concepts items (FAMCON/FAMCONC). The table lists **ST73–76**, which ask how often students meet 4 problem *types* in lessons and tests. | ST73–76 composite: r = .15 with math and r = .06 with FAMCONC; alpha .57 (lesson items), .58 (test items), .76 (all 8). FAMCONC: r = .49 with math. | Pick one as the PISA OTL measure. Recommended: ST62 (13 concepts, 3 overclaiming foils excluded) or **FAMCONC**, because it is what the plan's text describes. For a TIMSS comparison it is also closer to the paper's topic-coverage OTL. Keep ST73–76 as a secondary "problem-type exposure" measure. |
| B | **Only about two-thirds of students have OTL items.** The student questionnaire was rotated. | ST62/ST73: about 3,200 of 4,978 students. All 8 ST73–76 items + 4 SES parts: 2,985. | Treat it as missing by design: use FIML or MI with all students, not listwise deletion. |
| C | **PISA has no classroom computer-use measure for the US.** The US skipped the ICT questionnaire, so IC01–IC11, USEMATH and USESCH are all empty. | 0 non-missing. | The ICT moderator can only be a **principal-reported school** variable. So it is not the TIMSS "information vs. learning tool" construct. Say this in the paper as a limitation. |
| D | **The 9-item ICT composite mixes different constructs.** | School-level alpha .61. Internet use for work (SC13) has alpha .71. Shortage (SC14) has alpha .84. Raw counts SC11Q02/03 correlate .91 with each other and .38 with grade size. | Split it in two. **ICT use** = SC13Q01–03, with SC13Q01 (lessons) closest to TIMSS. **ICT resources** = SC14 reversed + RATCMP15 (computers per student) instead of raw counts. Keep cSC40Q01 (1 = yes, 25%) as its own dummy. |
| E | **The SES composite nearly duplicates ESCS.** | r = .96 with ESCS. Books are already part of HOMEPOS (r = .59). ESCS has n = 4,915 vs. 4,623 for the composite. | Use **ESCS** as the main measure. Keep the plan composite (books + HISCED + HOMEPOS, closer to TIMSS) as a sensitivity check. |
| F | **No science.** PISA 2012 has no science OTL. | — | The comparison covers math only. Science PVs exist if they are needed. |
| G | **The levels differ.** TIMSS correlations are at teacher level, e.g. SES–math .65. PISA student-level SES–math is .38 to .42. | — | Don't compare coefficient sizes across the two studies directly unless both are run at the same level. |

## 4. Proposed PISA model
- **Level 1 (students):** ESCS → OTL → math, plus ESCS → math. ESCS is group-mean centered and has a random slope.
- **Level 2 (schools):** school-mean ESCS and ICT (use and resources) predict mean math and mean OTL.
- **Cross-level interaction:** ICT × ESCS slope. This is the PISA version of the TIMSS moderation.
- **Estimation:** run once per PV (5 times) and pool with Rubin's rules. Use scaled two-level weights.
- **Software:** Mplus (TWOLEVEL RANDOM, TYPE=IMPUTATION) or R (WeMix/lme4 plus mitools). WarpPLS can't handle weights, PVs or two levels properly.
