# Spec addendum: exploratory extension of A2 (other outcomes, other OTL measures)

Status: exploratory, 2026-11-20. The A2 spec (`spec.md`) covers **math with OTL = FAMCONC** and stays the confirmatory analysis. This addendum records what was added around it, so the extra results are read as exploration, not as tests of the spec.

## 1. Why
- **Other outcomes.** PISA 2012 assessed print reading and science on paper, and digital reading, computer-based math and problem solving on computer. The paper (Zhang & Wang, 2020) covered math and science. A digital outcome is where an ICT effect, or an SES × ICT moderation, would be expected first.
- **Other OTL measures.** The A2 finding that OTL matters more in PISA than in TIMSS could depend on FAMCONC, which is familiarity with math concepts. The user's original variable plan listed ST73–76, which measure problem-type exposure, so the grid re-runs every model with OTL measured without FAMCONC.

## 2. Design
| Element | Choice |
|---|---|
| Outcomes | School means of 5 PVs each: `MATH`, `READ` (print reading), `SCIE`, `CREA` (digital reading), `CMAT` (computer-based math), `CPRO` (problem solving) |
| OTL | The construct `OTL` with one single indicator, a school mean: `OTL` = FAMCONC (spec); `OTL_PT` = mean of ST73–76 (8 items: algebraic word problems, procedural tasks, pure and applied reasoning, each in lessons and in tests; 1–4 reversed so higher = more often; at least 6 of 8 answered); `EXPUREM` and `EXAPPLM` = PISA indices of experience with pure- and applied-math tasks (ST61) |
| Model | Unchanged from spec section 4: SES → OTL, ICT → OTL; SES, ICT, OTL and SES × ICT → achievement. Model 1 = ICT use, Model 2 = ICT resources (`ICTRES_RATIO` dropped, as in the SmartPLS runs). SES composite (primary) and ESCS (sensitivity). |
| Samples | Unchanged: 146 schools (Model 1), 139 (Model 2). Every added column is complete in both samples. |
| Estimation | `seminr` in R (`R/a2_seminr_helpers.R`), with the settings of the user's SmartPLS runs: PLS-SEM, mode A, path weighting, two-stage interaction, 5,000-sample percentile bootstrap, p from t with 4,999 df. `R/a2_04` showed these settings reproduce all 12 SmartPLS runs (estimates within .0003, every significance verdict the same). |
| Grid | 6 outcomes × 4 OTL measures × 2 ICT models × 2 SES measures = 96 runs (`R/a2_05_seminr_runs.R`) |
| Criteria | Spec section 6, M1–M4, unchanged, applied to every run |

## 3. How to read the results
- **The OTL measures are all about math.** For reading, science and problem solving, OTL is a proxy for a school's mathematical press, not subject-specific opportunity to learn.
- **The grid holds many tests**: 96 runs, each with 6 paths and 4 effects. At α = .05, some results reach significance by chance. A result counts as a pattern only if it holds across OTL measures *and* with ESCS. A single significant cell is a lead.
- **Computer-based outcomes may carry extra noise.** At school level, their PVs correlate only .78–.83 with their paper counterparts, below the student-level .86. Check the PISA 2012 computer-based assessment design before interpreting paper-vs-computer contrasts. The report, [§8.4](../report/report.md#84-why-moderation-is-not-significant-elsewhere), point 6, gives the source.
- Comparisons between outcomes and OTL measures are descriptive: same schools, correlated outcomes, no joint test.
