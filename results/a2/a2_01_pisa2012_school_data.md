# A2 step 1: PISA 2012 (US) school-level data

Built by `R/a2_01_prepare_pisa2012.R` from `US_PISA_2012_STSCH.sav`. Spec: `docs/spec.md`.

## Checks

Hard checks must pass; report rows inform interpretation (spec section 6).

| Check | Type | Value | Expected | Pass |
|---|---|---|---|---|
| D1_n_students | hard | 4978 | 4978 | TRUE |
| D1_n_schools | hard | 162 | 162 | TRUE |
| D2_weighted_math_mean | hard | 481.37 | 481 +/- 1 | TRUE |
| D3_school_vars_constant | hard | 1 | TRUE | TRUE |
| D4_n_schools_model1 | report | 146 |  |  |
| D4_n_schools_model2 | report | 139 |  |  |
| D4_min_detectable_beta_model1 | report | 0.206 |  |  |
| D4_min_detectable_beta_model2 | report | 0.211 |  |  |
| D5_r_SES_ESCS_school | hard | 0.972 | >= 0.90 | TRUE |
| D5_r_SES_ESCS_student | report | 0.867 |  |  |
| D2_weighted_read_mean | report | 497.58 | 498 (published) |  |
| D2_weighted_scie_mean | report | 497.41 | 497 (published) |  |

D4: with these sample sizes, school-level paths smaller than about |0.21| are unlikely to reach p < .05
(80% power, inverse square root rule). The paper's significant TIMSS paths ranged from 0.09 to 0.69.
D5: the SES composite omits parental occupation (HISEI) to mirror TIMSS, so it tracks ESCS less closely
per student than the audit's 4-part composite (r = .95); at school level, the unit of analysis, r is high.

## Sample

- 4978 students in 162 schools; median 33 students per school.
- 10 schools have fewer than 10 students with OTL (FAMCONC) data and are excluded.
- Model 1 (ICT use): 146 schools. Model 2 (ICT resources): 139 schools (complete cases).
- No restriction like the paper's "teachers use computers": every US school with data reports computers (RATCMP15 > 0).

## School-level descriptives (Model 2 sample)

| Variable | Mean | SD |
|---|---|---|
| SES | 0.04 | 0.52 |
| ESCS | 0.22 | 0.51 |
| OTL | 0.04 | 0.39 |
| MATH1 | 484.55 | 45.74 |
| ICTUSE_LESSON | 1.94 | 0.94 |
| ICTUSE_HOMEWK | 2.17 | 0.91 |
| ICTUSE_ASSIGN | 3.12 | 1.11 |
| ICTRES_COMP | 3.06 | 0.95 |
| ICTRES_NET | 3.39 | 0.86 |
| ICTRES_SOFT | 3.13 | 0.84 |
| ICTRES_RATIO | 0.96 | 0.73 |

## School-level correlations (preview; ICT = mean of standardized items)

**Model 1, ICT use** (n = 146 schools)

| | SES | OTL | ICT | MATH |
|---|---|---|---|---|
| SES | 1.00 | 0.57 | 0.31 | 0.76 |
| OTL | 0.57 | 1.00 | 0.26 | 0.68 |
| ICT | 0.31 | 0.26 | 1.00 | 0.28 |
| MATH | 0.76 | 0.68 | 0.28 | 1.00 |

**Model 2, ICT resources** (n = 139 schools)

| | SES | OTL | ICT | MATH |
|---|---|---|---|---|
| SES | 1.00 | 0.61 | 0.23 | 0.77 |
| OTL | 0.61 | 1.00 | 0.12 | 0.71 |
| ICT | 0.23 | 0.12 | 1.00 | 0.11 |
| MATH | 0.77 | 0.71 | 0.11 | 1.00 |

## Cronbach's alpha, school level

- ICT use (3 items, Model 1 sample): 0.72
- ICT resources (3 shortage items + RATCMP15, Model 2 sample): 0.73
- ICT resources, 3 shortage items only: 0.86
- Math, 5 PV school means: 0.998
- Correlation of RATCMP15 with the shortage composite: 0.11
- RATCMP15 range 0.06 to 5.03 (skewed; watch its loading).
