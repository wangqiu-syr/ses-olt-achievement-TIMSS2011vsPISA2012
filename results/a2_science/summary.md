# A2 science: SmartPLS results, PISA 2012 (US), school level

Built by `R/a2_02_read_smartpls.R science` from the user's SmartPLS 4 exports. Math anchor: `results/a2/summary.md`. Spec: `docs/spec.md` (criteria, section 6).

**Exploratory.** The spec covers math only (decision 1). These runs use the math model with the outcome swapped for school means of the five science PVs (`SCIE1`–`SCIE5`).

**OTL here is a proxy.** PISA 2012 has opportunity-to-learn items for math only. OTL is FAMCONC, the familiarity with math concepts, so OTL → Science reads as how a school's math exposure relates to its science scores, not as science OTL.

## Runs received

- Settings for every run: PLS-SEM, path weighting scheme; bootstrap with 5000 samples, percentile bootstrap, fixed seed. The seed value is not in the export.
- Model 1 (ICT use), 146 schools: primary run and ESCS run, each with bootstrap. ICT items: `ICTUSE_ASSIGN`, `ICTUSE_HOMEWK`, `ICTUSE_LESSON`.
- Model 2 (ICT resources), 139 schools: primary run and ESCS run, each with bootstrap. ICT items: `ICTRES_COMP`, `ICTRES_NET`, `ICTRES_SOFT`. `ICTRES_RATIO` was dropped, as in math.
- All four runs were received (Model 1 and Model 2, primary and ESCS).
- Exports are matched to runs by content (outcome construct, ICT construct, SES indicator, bootstrap or not), not by file name; see `a2_02_exports_manifest.csv`.

## Acceptance criteria (spec section 6, applied unchanged)

| Run | Schools | M1 min loading | M1 | M2 min α/ρc | M2 min AVE | M2 | M3 max HTMT | M3 | M4 max VIF | M4 |
|---|---|---|---|---|---|---|---|---|---|---|
| M1_primary | 146 | 0.668 | TRUE | 0.726 | 0.621 | TRUE | 0.755 | TRUE | 1.591 | TRUE |
| M1_escs | 146 | 0.668 | TRUE | 0.726 | 0.621 | TRUE | 0.708 | TRUE | 1.516 | TRUE |
| M2_primary | 139 | 0.847 | TRUE | 0.859 | 0.779 | TRUE | 0.779 | TRUE | 1.748 | TRUE |
| M2_escs | 139 | 0.847 | TRUE | 0.859 | 0.779 | TRUE | 0.731 | TRUE | 1.592 | TRUE |

All 4 runs pass M1–M4.
Loadings below .70: `ICTUSE_LESSON` 0.67 (M1_primary); `ICTUSE_LESSON` 0.67 (M1_escs). They are kept under the M1 rule because ρc and AVE meet the thresholds, as in math.

## Model 1: ICT use, science vs. math

Ach. = achievement in the subject named in each column. Significance: \* p < .05, \*\* p < .01, \*\*\* p < .001 (two-tailed, bootstrap).
PISA math is from `results/a2/`; its indirect and total effects are products and sums of its paths, without p values. Science − math is the difference in point estimates.
TIMSS science is the paper's teacher-level values, with stars as printed (blank where the paper reports none).

| | TIMSS 2011 science (paper) | PISA math | PISA science | 95% CI | Science − math | PISA science, ESCS |
|---|---|---|---|---|---|---|
| SES → OTL | 0.12* | 0.52*** | 0.52*** | [0.37, 0.64] | 0.00 | 0.48*** |
| SES → Ach. | 0.68*** | 0.53*** | 0.55*** | [0.41, 0.67] | +0.01 | 0.48*** |
| OTL → Ach. | 0.09* | 0.37*** | 0.34*** | [0.22, 0.46] | -0.03 | 0.40*** |
| ICT → OTL | -0.05 | 0.12 | 0.12 | [-0.01, 0.27] | 0.00 | 0.14 |
| ICT → Ach. | 0.02 | 0.03 | 0.03 | [-0.08, 0.15] | -0.01 | 0.03 |
| SES × ICT → Ach. | 0.09* | -0.05 | -0.07 | [-0.18, 0.02] | -0.02 | -0.06 |
| SES → OTL → Ach. (indirect) |  | 0.19 | 0.18*** | [0.11, 0.25] | -0.01 | 0.19*** |
| SES → Ach. (total) |  | 0.72 | 0.72*** | [0.62, 0.81] | 0.00 | 0.67*** |
| ICT → OTL → Ach. (indirect) |  | 0.05 | 0.04 | [-0.00, 0.10] | 0.00 | 0.05 |
| ICT → Ach. (total) |  | 0.08 | 0.07 | [-0.04, 0.19] | -0.01 | 0.08 |
| R² Ach. | 0.48 | 0.67*** | 0.65*** |  | -0.02 | 0.62*** |
| R² OTL |  | 0.33*** | 0.33*** |  | 0.00 | 0.30*** |
| APC | 0.17*** | 0.27 | 0.27 |  | 0.00 | 0.26 |
| ARS | 0.25*** | 0.50 | 0.49 |  | -0.01 | 0.46 |
| AVIF | 1.01 | 1.28 | 1.28 |  | 0.00 | 1.27 |
| r SES–Ach. | 0.67** | 0.76 | 0.75 |  | 0.00 | 0.71 |
| r OTL–Ach. | 0.03 | 0.68 | 0.66 |  | -0.02 | 0.66 |
| r ICT–Ach. | 0.04 | 0.35 | 0.33 |  | -0.02 | 0.33 |

## Model 2: ICT resources, science vs. math

| | TIMSS 2011 science (paper) | PISA math | PISA science | 95% CI | Science − math | PISA science, ESCS |
|---|---|---|---|---|---|---|
| SES → OTL | 0.11* | 0.61*** | 0.61*** | [0.51, 0.70] | 0.00 | 0.58*** |
| SES → Ach. | 0.69*** | 0.55*** | 0.59*** | [0.46, 0.72] | +0.04 | 0.50*** |
| OTL → Ach. | 0.10* | 0.38*** | 0.33*** | [0.20, 0.46] | -0.05 | 0.40*** |
| ICT → OTL | -0.09* | -0.00 | -0.00 | [-0.14, 0.14] | 0.00 | 0.02 |
| ICT → Ach. | 0.05 | -0.02 | -0.02 | [-0.11, 0.09] | 0.00 | -0.00 |
| SES × ICT → Ach. | -0.02 | 0.03 | 0.05 | [-0.05, 0.14] | +0.03 | -0.01 |
| SES → OTL → Ach. (indirect) |  | 0.23 | 0.20*** | [0.13, 0.28] | -0.03 | 0.23*** |
| SES → Ach. (total) |  | 0.78 | 0.79*** | [0.71, 0.86] | +0.01 | 0.73*** |
| ICT → OTL → Ach. (indirect) |  | -0.00 | -0.00 | [-0.05, 0.05] | 0.00 | 0.01 |
| ICT → Ach. (total) |  | -0.02 | -0.02 | [-0.11, 0.10] | 0.00 | 0.01 |
| R² Ach. | 0.48 | 0.69*** | 0.68*** |  | -0.01 | 0.64*** |
| R² OTL |  | 0.38*** | 0.38*** |  | 0.00 | 0.34*** |
| APC | 0.18*** | 0.27 | 0.27 |  | 0.00 | 0.25 |
| ARS | 0.25*** | 0.53 | 0.53 |  | -0.01 | 0.49 |
| AVIF | 1.10 | 1.27 | 1.27 |  | 0.00 | 1.21 |
| r SES–Ach. | 0.67** | 0.77 | 0.78 |  | +0.01 | 0.73 |
| r OTL–Ach. | 0.03 | 0.71 | 0.69 |  | -0.03 | 0.69 |
| r ICT–Ach. | 0.05 | 0.15 | 0.15 |  | 0.00 | 0.15 |

## What the comparison shows (descriptive; see the last section)

1. **SES is the strongest predictor of science, as of math.** SES → Science is .55–.59 (math .53–.55). With the indirect path through OTL, the total SES effect is .72–.79 (math .72–.78).
2. **Math OTL relates to science about as strongly as to math.** OTL → Science is .33–.34 (math .37–.38), and the indirect SES → OTL → Science effect is .18–.20 (math .19–.23). SES → OTL is the same as in math (.52–.61), because its predictors don't change with the outcome.
   - Science tracks math closely: no path differs from math by more than .05.
3. **No ICT effect in either model.** ICT → Science, ICT → OTL and the total ICT effect all have p > .05. Totals: Model 1 .07 (p = .244), Model 2 -.02 (p = .746).
4. **No SES × ICT moderation.** Model 1 -.07 (p = .150); Model 2 .05 (p = .258). TIMSS science found a moderation of .09* in Model 1.
5. **R² Science is .65–.68** (math .67–.69).
6. **ESCS instead of the SES composite:** no path changes significance at .05, and every significant path keeps its sign. Near-zero, non-significant paths that flip sign: M2 SES × ICT → Ach. (0.05 → -0.01). SES → Science drops to .48–.50 and OTL → Science rises to .40, as in math.
7. **Against TIMSS science, PISA repeats the math contrast.** SES → Science is .55–.59 in PISA vs. .68–.69 in TIMSS. OTL → Science is .33–.34 vs. .09–.10, and SES → OTL .52–.61 vs. .11–.12.
   - TIMSS science OTL is teacher-reported coverage of science topics; PISA's is students' familiarity with math concepts. The larger PISA OTL paths are expected, and they are not a like-for-like science comparison.
   - TIMSS found ICT → OTL of -.09* in Model 2; PISA science has .00 (p = .993).
   - R² Science is .65–.68 in PISA vs. .48 in TIMSS, typical of school-level aggregates.

## Reading the comparison

- **Differences between subjects are descriptive.** Every run uses the same schools, the same SES, OTL and ICT measures, and outcomes that are school means of correlated PVs, so similar paths are expected. Testing a science-vs-math difference needs both outcomes in one model with a shared bootstrap. Overlapping CIs show only that these data can't tell the paths apart.
- With 139–146 schools, paths below about |.21| are unlikely to reach p < .05 (spec D4). Many paths are tested per run, so a single p just under .05 is weak evidence.
- TIMSS-vs-PISA differences in design (teacher vs. school level, Grade 8 vs. age 15, teacher-reported vs. student-reported OTL, classroom vs. principal-reported ICT) are listed in spec section 7. For science, add that PISA's OTL is about math, not science.
