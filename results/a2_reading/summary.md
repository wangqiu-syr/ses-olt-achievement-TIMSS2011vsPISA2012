# A2 reading: SmartPLS results, PISA 2012 (US), school level

Built by `R/a2_02_read_smartpls.R reading` from the user's SmartPLS 4 exports. Math anchor: `results/a2/summary.md`. Spec: `docs/spec.md` (criteria, section 6).

**Exploratory.** The spec covers math only (decision 1). These runs use the math model with the outcome swapped for school means of the five reading PVs (`READ1`–`READ5`).

**OTL here is a proxy.** PISA 2012 has opportunity-to-learn items for math only. OTL is FAMCONC, the familiarity with math concepts, so OTL → Reading reads as how a school's math exposure relates to its reading scores, not as reading OTL.

## Runs received

- Settings for every run: PLS-SEM, path weighting scheme; bootstrap with 5000 samples, percentile bootstrap, fixed seed. The seed value is not in the export.
- Model 1 (ICT use), 146 schools: primary run and ESCS run, each with bootstrap. ICT items: `ICTUSE_ASSIGN`, `ICTUSE_HOMEWK`, `ICTUSE_LESSON`.
- Model 2 (ICT resources), 139 schools: primary run and ESCS run, each with bootstrap. ICT items: `ICTRES_COMP`, `ICTRES_NET`, `ICTRES_SOFT`. `ICTRES_RATIO` was dropped, as in math.
- All four runs were received (Model 1 and Model 2, primary and ESCS).
- Exports are matched to runs by content (outcome construct, ICT construct, SES indicator, bootstrap or not), not by file name; see `a2_02_exports_manifest.csv`.

## Acceptance criteria (spec section 6, applied unchanged)

| Run | Schools | M1 min loading | M1 | M2 min α/ρc | M2 min AVE | M2 | M3 max HTMT | M3 | M4 max VIF | M4 |
|---|---|---|---|---|---|---|---|---|---|---|
| M1_primary | 146 | 0.643 | TRUE | 0.726 | 0.616 | TRUE | 0.742 | TRUE | 1.595 | TRUE |
| M1_escs | 146 | 0.643 | TRUE | 0.726 | 0.616 | TRUE | 0.712 | TRUE | 1.520 | TRUE |
| M2_primary | 139 | 0.853 | TRUE | 0.859 | 0.780 | TRUE | 0.765 | TRUE | 1.748 | TRUE |
| M2_escs | 139 | 0.853 | TRUE | 0.859 | 0.780 | TRUE | 0.731 | TRUE | 1.592 | TRUE |

All 4 runs pass M1–M4.
Loadings below .70: `ICTUSE_LESSON` 0.64 (M1_primary); `ICTUSE_LESSON` 0.64 (M1_escs). They are kept under the M1 rule because ρc and AVE meet the thresholds, as in math.

## Model 1: ICT use, reading vs. math

Ach. = achievement in the subject named in each column. Significance: \* p < .05, \*\* p < .01, \*\*\* p < .001 (two-tailed, bootstrap).
PISA math is from `results/a2/`; its indirect and total effects are products and sums of its paths, without p values. Reading − math is the difference in point estimates.

| | PISA math | PISA reading | 95% CI | Reading − math | PISA reading, ESCS |
|---|---|---|---|---|---|
| SES → OTL | 0.52*** | 0.52*** | [0.38, 0.64] | 0.00 | 0.47*** |
| SES → Ach. | 0.53*** | 0.46*** | [0.35, 0.58] | -0.07 | 0.43*** |
| OTL → Ach. | 0.37*** | 0.42*** | [0.32, 0.51] | +0.05 | 0.46*** |
| ICT → OTL | 0.12 | 0.13 | [-0.01, 0.27] | 0.00 | 0.14 |
| ICT → Ach. | 0.03 | 0.09 | [-0.01, 0.20] | +0.06 | 0.09 |
| SES × ICT → Ach. | -0.05 | -0.08 | [-0.17, 0.01] | -0.02 | -0.06 |
| SES → OTL → Ach. (indirect) | 0.19 | 0.22*** | [0.15, 0.29] | +0.03 | 0.22*** |
| SES → Ach. (total) | 0.72 | 0.68*** | [0.58, 0.77] | -0.04 | 0.65*** |
| ICT → OTL → Ach. (indirect) | 0.05 | 0.05 | [-0.00, 0.12] | +0.01 | 0.06 |
| ICT → Ach. (total) | 0.08 | 0.14* | [0.03, 0.27] | +0.06 | 0.15* |
| R² Ach. | 0.67*** | 0.69*** |  | +0.01 | 0.67*** |
| R² OTL | 0.33*** | 0.33*** |  | 0.00 | 0.30*** |
| APC | 0.27 | 0.28 |  | +0.01 | 0.27 |
| ARS | 0.50 | 0.51 |  | +0.01 | 0.48 |
| AVIF | 1.28 | 1.28 |  | 0.00 | 1.27 |
| r SES–Ach. | 0.76 | 0.74 |  | -0.02 | 0.71 |
| r OTL–Ach. | 0.68 | 0.71 |  | +0.03 | 0.71 |
| r ICT–Ach. | 0.35 | 0.39 |  | +0.05 | 0.39 |

## Model 2: ICT resources, reading vs. math

| | PISA math | PISA reading | 95% CI | Reading − math | PISA reading, ESCS |
|---|---|---|---|---|---|
| SES → OTL | 0.61*** | 0.61*** | [0.51, 0.70] | 0.00 | 0.58*** |
| SES → Ach. | 0.55*** | 0.53*** | [0.42, 0.63] | -0.02 | 0.46*** |
| OTL → Ach. | 0.38*** | 0.41*** | [0.30, 0.52] | +0.03 | 0.46*** |
| ICT → OTL | -0.00 | -0.00 | [-0.14, 0.14] | 0.00 | 0.02 |
| ICT → Ach. | -0.02 | 0.02 | [-0.07, 0.12] | +0.04 | 0.03 |
| SES × ICT → Ach. | 0.03 | 0.08 | [-0.02, 0.17] | +0.05 | 0.03 |
| SES → OTL → Ach. (indirect) | 0.23 | 0.25*** | [0.18, 0.32] | +0.02 | 0.27*** |
| SES → Ach. (total) | 0.78 | 0.78*** | [0.70, 0.84] | 0.00 | 0.73*** |
| ICT → OTL → Ach. (indirect) | -0.00 | -0.00 | [-0.06, 0.06] | 0.00 | 0.01 |
| ICT → Ach. (total) | -0.02 | 0.02 | [-0.08, 0.13] | +0.04 | 0.04 |
| R² Ach. | 0.69*** | 0.70*** |  | +0.01 | 0.68*** |
| R² OTL | 0.38*** | 0.38*** |  | 0.00 | 0.34*** |
| APC | 0.27 | 0.28 |  | +0.01 | 0.26 |
| ARS | 0.53 | 0.54 |  | +0.01 | 0.51 |
| AVIF | 1.27 | 1.26 |  | 0.00 | 1.21 |
| r SES–Ach. | 0.77 | 0.76 |  | -0.01 | 0.73 |
| r OTL–Ach. | 0.71 | 0.73 |  | +0.02 | 0.73 |
| r ICT–Ach. | 0.15 | 0.18 |  | +0.03 | 0.18 |

## What the comparison shows (descriptive; see the last section)

1. **SES is the strongest predictor of reading, as of math.** SES → Reading is .46–.53 (math .53–.55). With the indirect path through OTL, the total SES effect is .68–.78 (math .72–.78).
2. **Math OTL relates to reading about as strongly as to math.** OTL → Reading is .41–.42 (math .37–.38), and the indirect SES → OTL → Reading effect is .22–.25 (math .19–.23). SES → OTL is the same as in math (.52–.61), because its predictors don't change with the outcome.
   - Reading leans a little more on the OTL proxy (+.03 to +.05 vs. math) and a little less on SES directly (-.07 to -.02). Both gaps are well inside the 95% CIs.
3. **ICT use has a small total effect on reading.** In Model 1 neither ICT-use path is significant on its own: direct .09 (p = .096), through OTL .05 (p = .100). Together they give a total effect of .14 (p = .016), 95% CI [.03, .27]. Math's total is .08; its p value needs the math exports rerun.
   - Treat it as a lead, not a finding. It is one of many tests, it is smaller than the |.21| this sample can reliably detect, and the direct path alone is not significant. Digital reading is where an ICT link would be expected first.
   - ICT resources (Model 2) show nothing: ICT → Reading .02 (p = .724), total .02 (p = .748).
4. **No SES × ICT moderation.** Model 1 -.08 (p = .106); Model 2 .08 (p = .098).
5. **R² Reading is .69–.70** (math .67–.69).
6. **ESCS instead of the SES composite:** no path changes significance at .05, and every significant path keeps its sign. SES → Reading drops to .43–.46 and OTL → Reading rises to .46, as in math.

## Reading the comparison

- **Differences between subjects are descriptive.** Every run uses the same schools, the same SES, OTL and ICT measures, and outcomes that are school means of correlated PVs, so similar paths are expected. Testing a reading-vs-math difference needs both outcomes in one model with a shared bootstrap. Overlapping CIs show only that these data can't tell the paths apart.
- With 139–146 schools, paths below about |.21| are unlikely to reach p < .05 (spec D4). Many paths are tested per run, so a single p just under .05 is weak evidence.
- TIMSS 2011 has no reading assessment, so there is no paper column. Digital reading (`CREA`) is in the `seminr` grid: `results/a2_seminr/`.
