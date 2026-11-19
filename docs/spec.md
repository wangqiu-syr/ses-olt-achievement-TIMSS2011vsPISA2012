# Spec: A2, PISA 2012 (US) analogue of Zhang & Wang (2020)

Status: draft, 2026-11-19. Sections 1–5 record decisions the user approved. Section 6, the acceptance criteria, is **proposed, awaiting user confirmation**.

## 1. Scope and decisions
| # | Decision | Adopted |
|---|---|---|
| 1 | Subject | **Math only.** PISA 2012 has no science OTL and no US classroom computer-use data (audit items C, F). Science is reported as a limitation. |
| 2 | Unit of analysis | **School** (PISA has no teacher link). Students are aggregated to schools, as the paper aggregated to teachers. |
| 3 | Measures | OTL = FAMCONC. SES = TIMSS-style composite, with ESCS as a sensitivity check. ICT: Model 1 = use, Model 2 = resources (section 3). |
| 4 | Estimation | PLS-SEM. The user runs it in SmartPLS 4 (`from_code/a2_smartpls_steps.md`); Code prepares data and checks results. A scripted R `seminr` cross-check follows when CRAN is reachable. |
| 5 | Order | A2 runs before A1, while the TIMSS files are pending. The parity check (user `.sav` vs. OECD download) is deferred until OECD is reachable. |

## 2. Data
1. Source: `data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav` (4,978 students, 162 schools; SHA-256 in `from_code/data_manifest.csv`).
2. Aggregation: within-school means weighted by `W_FSTUWT`, using the students with data on each variable.
3. Inclusion: schools with **≥ 10 students with FAMCONC** (the questionnaire was rotated, so about 2/3 of students have it), and complete data on every indicator in the model. No imputation at school level.
4. The paper kept only classes whose teachers use computers. No analogue is applied, because every US school with data reports computers (RATCMP15 > 0).
5. Primary runs are unweighted, as in the paper. `sum_stu_wt`, the school's summed student weight, is in the files for a later weighted sensitivity run.

## 3. Measures (paper construct → PISA)
| Construct | TIMSS 2011 (paper) | PISA 2012 (A2) | Indicators in the SmartPLS file |
|---|---|---|---|
| SES | Composite: 8 home possessions, parent education, books; standardized | Weighted z-scores of ST28Q01 (books), HISCED, HOMEPOS; mean of available parts if ≥ 2 of 3; re-standardized; school mean. HISEI is left out to mirror TIMSS (it is in ESCS). | `SES` (single indicator) |
| SES, sensitivity | – | ESCS, school mean | `ESCS` (single indicator) |
| OTL | Teacher-reported topic coverage, 0–4 | FAMCONC (familiarity with 13 math concepts, corrected for overclaiming), school mean | `OTL` (single indicator) |
| Achievement | 5 PVs as reflective indicators | PV1–PV5MATH school means as reflective indicators | `MATH1`–`MATH5` |
| ICT, Model 1 | Computer as information tool (2 teacher items) | **ICT use**: share of schoolwork needing the internet, SC13Q01–03 (1 = <10% … 5 = >75%) | `ICTUSE_LESSON`, `ICTUSE_HOMEWK`, `ICTUSE_ASSIGN` |
| ICT, Model 2 | Computer as learning tool (2 math items) | **ICT resources**: SC14Q07–09 reversed (higher = fewer shortages) + RATCMP15 (computers per student) | `ICTRES_COMP`, `ICTRES_NET`, `ICTRES_SOFT`, `ICTRES_RATIO` |

The school math-policy dummy (cSC40Q01) is kept as `MATHPOL` in `data/derived/a2_pisa2012_school.csv`. It is not in the models.

## 4. Structural model (both models, as in the paper's Figure 1)
SES → OTL; SES → MATH; OTL → MATH; ICT → OTL; ICT → MATH; SES × ICT → MATH.
The interaction uses SmartPLS's two-stage approach with standardized product terms.

## 5. Estimation
1. **Primary:** SmartPLS 4, standard PLS-SEM algorithm, path weighting scheme, default stop criterion. Bootstrapping: 5,000 subsamples, percentile CIs, two-tailed, α = .05, fixed seed.
2. **Sensitivity** (same settings, one change each):
   - (a) consistent PLS (PLSc), which is closer to WarpPLS's factor-based PLS;
   - (b) ESCS in place of SES.
3. **Deferred to the R cross-check:**
   - run once per PV and pool (Rubin's rules);
   - school-weighted run;
   - parity of the user `.sav` vs. the OECD download.
4. Fit summaries in the paper's terms: APC = mean |path|, ARS = mean R² (OTL, MATH), AVIF = mean inner VIF.

## 6. Acceptance criteria (proposed: user to confirm)
**Data**: `from_code/a2_01_checks.csv`, enforced by `tests/testthat/test-a2-pisa2012-data.R`.
- **D1:** 4,978 students and 162 schools.
- **D2:** weighted math mean is 481 ± 1 (the OECD-published US value).
- **D3:** school variables are constant within each school.
- **D5:** school-level r(SES composite, ESCS) ≥ .90.
- **Reported, not pass/fail:** schools per model (D4) and the minimum detectable |β| at 80% power, using the inverse square root rule.

**Model** (each SmartPLS run):
- **M1:** reflective outer loadings ≥ .70. An indicator with a loading < .40 is dropped. One between .40 and .70 is dropped only if that raises CR/AVE to the thresholds. Every drop is logged.
- **M2:** Cronbach's α and composite reliability (ρ_A or ρ_C) ≥ .70; AVE ≥ .50.
- **M3:** discriminant validity: HTMT < .85, and Fornell–Larcker (the paper's criterion).
- **M4:** collinearity: inner VIF < 3.3 (the paper's AVIF threshold).
- **M5:** complete results are delivered in `from_code/a2_pisa2012_estimates_user_sav.csv`, using the reference CSV's `estimate_id` scheme with `math` as the subject, plus `p_value` and CI columns.

A run that fails M1–M4 is reported as is, with the failure named. Constructs are not quietly respecified. Matching the paper's TIMSS values is **not** an A2 criterion: A2 is an analogue with a different design. The TIMSS-vs-PISA comparison is descriptive.

## 7. Known differences from the paper (to report)
- School level, not teacher level. Achievement covers 15-year-olds (mostly grade 10), not Grade 8.
- OTL is student-reported, cumulative concept familiarity, not teacher-reported coverage within the year.
- ICT comes from the principal and concerns internet use and resources, not classroom computer use.
- The PISA analysis has 139–146 schools, against 183 math teachers in the paper.
