# A2 step 2: SmartPLS results, PISA 2012 (US), school level

Built by `R/a2_02_read_smartpls.R` from the user's SmartPLS 4 exports. Spec: `docs/spec.md`.

## Runs received

- Settings for every run: PLS-SEM, path weighting scheme, no weighting vector; bootstrap with 5000 samples, percentile bootstrap, fixed seed. The seed value is not in the export.
- Model 1 (ICT use), 146 schools: primary run and ESCS run, each with bootstrap.
- Model 2 (ICT resources), 139 schools: primary run and ESCS run, each with bootstrap. `ICTRES_RATIO` (computers per student) was dropped in both runs.
- Not received: the Model 2 run that still included `ICTRES_RATIO`, and the PLSc sensitivity runs (spec 5.2a).

**The `ICTRES_RATIO` drop is consistent with spec M1.** Its correlation with the 3-item ICT resources score is 0.12. That is far below the .40 cut, so its loading in a with-ratio model would also fall below it. A with-ratio export would make this exact.

## Acceptance criteria (spec section 6)

| Run | Schools | M1 min loading | M1 | M2 min α/ρc | M2 min AVE | M2 | M3 max HTMT | M3 | M4 max VIF | M4 |
|---|---|---|---|---|---|---|---|---|---|---|
| M1_primary | 146 | 0.652 | TRUE | 0.726 | 0.618 | TRUE | 0.758 | TRUE | 1.594 | TRUE |
| M1_escs | 146 | 0.652 | TRUE | 0.726 | 0.618 | TRUE | 0.716 | TRUE | 1.519 | TRUE |
| M2_primary | 139 | 0.847 | TRUE | 0.859 | 0.779 | TRUE | 0.774 | TRUE | 1.750 | TRUE |
| M2_escs | 139 | 0.847 | TRUE | 0.859 | 0.779 | TRUE | 0.730 | TRUE | 1.592 | TRUE |

All four runs pass M1–M4. One item is below .70: `ICTUSE_LESSON` (0.65). It is kept under the M1 rule because ρc and AVE meet the thresholds without dropping it. It is also the item closest to TIMSS classroom use.
The outer VIFs of the five math PVs are 77–93. This is expected, because the PVs are near-identical school means. M4 applies to inner VIFs only.

## Model 1: ICT use (PISA) vs. computer as information tool (TIMSS), math

Significance: \* p < .05, \*\* p < .01, \*\*\* p < .001 (two-tailed, bootstrap). For TIMSS, stars are as printed in the paper.

| | TIMSS 2011 (paper) | PISA 2012 | 95% CI | PISA, ESCS |
|---|---|---|---|---|
| SES → OTL | 0.12* | 0.52*** | [0.37, 0.64] | 0.48*** |
| SES → Math | 0.65** | 0.53*** | [0.41, 0.66] | 0.48*** |
| OTL → Math | 0.20** | 0.37*** | [0.25, 0.48] | 0.42*** |
| ICT → OTL | 0.29** | 0.12 | [-0.01, 0.27] | 0.14 |
| ICT → Math | 0.08 | 0.03 | [-0.08, 0.15] | 0.04 |
| SES × ICT → Math | 0.04 | -0.05 | [-0.16, 0.04] | -0.05 |
| R² Math | 0.50 | 0.67*** |  | 0.64*** |
| R² OTL |  | 0.33*** |  | 0.30*** |
| APC | 0.23*** | 0.27 |  | 0.27 |
| ARS | 0.30*** | 0.50 |  | 0.47 |
| AVIF | 1.05 | 1.28 |  | 1.27 |
| r SES–OTL | 0.02 | 0.57 |  | 0.53 |
| r SES–Math | 0.65** | 0.76 |  | 0.72 |
| r OTL–Math | 0.20* | 0.68 |  | 0.68 |
| r SES–ICT | 0.04 | 0.38 |  | 0.39 |
| r OTL–ICT | 0.12 | 0.32 |  | 0.32 |
| r ICT–Math | 0.15* | 0.35 |  | 0.35 |

## Model 2: ICT resources (PISA) vs. computer as learning tool (TIMSS), math

| | TIMSS 2011 (paper) | PISA 2012 | 95% CI | PISA, ESCS |
|---|---|---|---|---|
| SES → OTL | 0.13* | 0.61*** | [0.51, 0.70] | 0.58*** |
| SES → Math | 0.64** | 0.55*** | [0.43, 0.67] | 0.47*** |
| OTL → Math | 0.21** | 0.38*** | [0.25, 0.49] | 0.43*** |
| ICT → OTL | 0.17** | -0.00 | [-0.14, 0.14] | 0.02 |
| ICT → Math | 0.08 | -0.02 | [-0.11, 0.09] | -0.00 |
| SES × ICT → Math | 0.03 | 0.03 | [-0.07, 0.11] | -0.02 |
| R² Math | 0.50 | 0.69*** |  | 0.66*** |
| R² OTL |  | 0.38*** |  | 0.34*** |
| APC | 0.21*** | 0.27 |  | 0.25 |
| ARS | 0.27*** | 0.53 |  | 0.50 |
| AVIF | 1.04 | 1.27 |  | 1.21 |
| r SES–OTL | 0.02 | 0.61 |  | 0.58 |
| r SES–Math | 0.65** | 0.77 |  | 0.73 |
| r OTL–Math | 0.20* | 0.71 |  | 0.71 |
| r SES–ICT | 0.06 | 0.22 |  | 0.20 |
| r OTL–ICT | 0.18* | 0.13 |  | 0.13 |
| r ICT–Math | 0.15* | 0.15 |  | 0.15 |

## What the comparison shows (descriptive; designs differ, see spec section 7)

1. **SES is the strongest predictor in both studies.** SES → Math is .53–.55 in PISA and .64–.65 in TIMSS.
2. **OTL matters more, and depends more on SES, in PISA.** OTL → Math is .37–.38 in PISA vs. .20–.21 in TIMSS. SES → OTL is .52–.61 vs. .12–.13.
   - A large part of PISA's SES effect runs through OTL: the indirect SES → OTL → Math effect is .19 in Model 1 (SmartPLS export).
   - This fits OTL being cumulative concept familiarity measured at school level, rather than teacher-reported coverage within one year.
3. **No ICT effect and no moderation in PISA.** ICT → Math and ICT → OTL are not significant. SES × ICT is -0.05 (p = 0.29) in Model 1 and 0.03 (p = 0.56) in Model 2.
   - With about 140 schools, paths below about |.21| are unlikely to reach significance (spec D4).
   - TIMSS found ICT → OTL significant for math in both models. PISA's ICT measures are principal reports on internet use and resources, not classroom computer use.
4. **Explained variance is higher in PISA** (R² Math .67–.69 vs. .50). This is typical of school-level aggregates.
5. **ESCS instead of the SES composite leaves the conclusions unchanged.** Every significant path keeps its sign and significance. SES → Math is .05–.08 lower and OTL → Math about .05 higher. The near-zero, non-significant Model 2 ICT paths flip sign (last two columns).

## Not comparable

- The paper's Table 2 VIFs are WarpPLS full-collinearity VIFs per construct. SmartPLS reports inner VIFs per path, so AVIF here is the mean inner VIF.
- The paper's paths don't follow from its own correlations (e.g. math SES–OTL r = .02 but path .12). This suggests WarpPLS's nonlinear algorithm. PISA results here are linear PLS-SEM.
