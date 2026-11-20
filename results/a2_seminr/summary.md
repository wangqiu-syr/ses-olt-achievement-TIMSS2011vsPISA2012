# A2 scripted runs (seminr): six outcomes × four OTL measures

Built by `R/a2_05_seminr_runs.R`. **Exploratory.** The spec (`docs/spec.md`) covers math with OTL = FAMCONC; every other cell here extends it.

- **Model:** the paper's, as in the SmartPLS runs: SES → OTL, ICT → OTL; SES, ICT, OTL and SES × ICT → achievement. Model 1 uses ICT use, Model 2 ICT resources. School level, 146 / 139 schools.
- **OTL:** the construct `OTL` with one single indicator:
  - **FAMCONC**, familiarity with math concepts (the spec);
  - **OTL_PT**, how often students meet four problem types (ST73–76);
  - **EXPUREM** and **EXAPPLM**, experience with pure- and applied-math tasks.
  All four are about math; PISA 2012 has no reading or science OTL.
- **Estimation:** seminr 2.6.0 with the SmartPLS settings (`R/a2_seminr_helpers.R`), 5000 bootstrap samples, seed 20261120. `R/a2_04` showed these settings reproduce SmartPLS: estimates within .0003, every significance verdict the same.
- 96 runs (6 outcomes × 4 OTL measures × 2 ICT models × SES composite or ESCS), 25 minutes. All estimates: `estimates.csv`; criteria: `criteria.csv`.

## Acceptance criteria (spec section 6)

All 96 runs pass M1–M4. The lowest ICT loading is .51 (`ICTUSE_LESSON`, kept under the M1 rule as in math); the largest HTMT is .78; the largest inner VIF is 1.75.

## What the grid shows (primary runs; descriptive)

1. **What OTL does depends on the measure.** OTL → Ach. is .23 to .42 with FAMCONC but .02 to .13 with OTL_PT (EXPUREM .19 to .33, EXAPPLM .00 to .11). With a weaker OTL, SES's direct path takes over: SES → Ach. is .40 to .59 with FAMCONC and .54 to .78 with OTL_PT. The A2 finding that OTL matters more in PISA than in TIMSS rests on FAMCONC.
2. **ICT.** An ICT path or effect reaches p < .05 in: Print reading, Model 1 (4 of 4 OTL measures); Digital reading, Model 2 (1 of 4 OTL measures).
3. **Moderation.** SES × ICT reaches p < .05 in: Digital reading, Model 2 (3 of 4 OTL measures); Print reading, Model 2 (1 of 4 OTL measures).
4. **Computer-based outcomes are explained less well.** With FAMCONC, R² Ach. averages .68 for the paper-based outcomes and .50 for the computer-based ones (see Cautions).

Details for every significant result are in the section after the tables.

## How much the OTL measure matters (primary runs, all outcomes and both models)

| OTL measure | OTL → Ach. | SES → OTL | SES → Ach. (direct) | R² Ach. |
|---|---|---|---|---|
| FAMCONC | .23 to .42 | .52 to .61 | .40 to .59 | .40 to .70 |
| OTL_PT | .02 to .13 | .25 to .26 | .54 to .78 | .38 to .62 |
| EXPUREM | .19 to .33 | .30 to .38 | .49 to .68 | .42 to .70 |
| EXAPPLM | .00 to .11 | .30 to .32 | .55 to .77 | .37 to .62 |

## Model 1: ICT use (primary runs, SES composite)

Ach. = achievement in the row's outcome. \* p < .05, \*\* p < .01, \*\*\* p < .001 (two-tailed, bootstrap). SES → OTL → Ach. is the indirect effect; ICT total = direct + via OTL.

| Outcome | OTL | SES → OTL | SES → Ach. | OTL → Ach. | ICT → OTL | ICT → Ach. | SES × ICT | SES → OTL → Ach. | ICT total | R² Ach. |
|---|---|---|---|---|---|---|---|---|---|---|
| **Math** | FAMCONC | .52*** | .53*** | .37*** | .12 | .03 | -.05 | .19*** | .08 | .67 |
|  | OTL_PT | .26*** | .71*** | .04 | .03 | .08 | -.05 | .01 | .08 | .58 |
|  | EXPUREM | .31*** | .63*** | .29*** | .01 | .08 | -.05 | .09*** | .08 | .65 |
|  | EXAPPLM | .32*** | .69*** | .10 | -.10 | .09 | -.03 | .03 | .08 | .59 |
| **Print reading** | FAMCONC | .52*** | .46*** | .42*** | .13 | .09 | -.08 | .22*** | .14* | .69 |
|  | OTL_PT | .26*** | .66*** | .07 | .04 | .14* | -.07 | .02 | .14* | .57 |
|  | EXPUREM | .31*** | .58*** | .33*** | .01 | .15** | -.08 | .10*** | .15* | .67 |
|  | EXAPPLM | .32*** | .66*** | .08 | -.10 | .15* | -.06 | .02 | .14* | .57 |
| **Science** | FAMCONC | .52*** | .55*** | .34*** | .12 | .03 | -.07 | .18*** | .07 | .65 |
|  | OTL_PT | .26*** | .71*** | .05 | .03 | .06 | -.07 | .01 | .06 | .58 |
|  | EXPUREM | .31*** | .62*** | .32*** | .01 | .07 | -.07 | .10*** | .07 | .67 |
|  | EXAPPLM | .31*** | .69*** | .11 | -.09 | .07 | -.05 | .03 | .06 | .59 |
| **Digital reading** | FAMCONC | .52*** | .55*** | .30*** | .13 | .05 | -.04 | .15*** | .08 | .60 |
|  | OTL_PT | .26*** | .69*** | .02 | .03 | .08 | -.04 | .01 | .08 | .54 |
|  | EXPUREM | .31*** | .60*** | .30*** | .02 | .09 | -.04 | .09*** | .09 | .62 |
|  | EXAPPLM | .32*** | .68*** | .05 | -.09 | .09 | -.02 | .02 | .08 | .55 |
| **Computer-based math** | FAMCONC | .52*** | .40*** | .35*** | .13 | .05 | -.02 | .18*** | .09 | .47 |
|  | OTL_PT | .25*** | .57*** | .05 | .04 | .09 | -.02 | .01 | .09 | .39 |
|  | EXPUREM | .31*** | .52*** | .20** | .02 | .10 | -.02 | .06** | .10 | .42 |
|  | EXAPPLM | .32*** | .57*** | .04 | -.10 | .09 | -.01 | .01 | .09 | .39 |
| **Problem solving** | FAMCONC | .52*** | .45*** | .25*** | .13 | .00 | -.11 | .13** | .03 | .40 |
|  | OTL_PT | .25** | .54*** | .12 | .05 | .03 | -.14 | .03 | .04 | .38 |
|  | EXPUREM | .30*** | .49*** | .26*** | .04 | .04 | -.13 | .08** | .05 | .43 |
|  | EXAPPLM | .32*** | .55*** | .07 | -.10 | .04 | -.12 | .02 | .04 | .37 |

## Model 2: ICT resources (primary runs, SES composite)

| Outcome | OTL | SES → OTL | SES → Ach. | OTL → Ach. | ICT → OTL | ICT → Ach. | SES × ICT | SES → OTL → Ach. | ICT total | R² Ach. |
|---|---|---|---|---|---|---|---|---|---|---|
| **Math** | FAMCONC | .61*** | .55*** | .38*** | .00 | -.02 | .03 | .23*** | -.02 | .69 |
|  | OTL_PT | .26*** | .78*** | .05 | -.06 | -.01 | .05 | .01 | -.02 | .60 |
|  | EXPUREM | .38*** | .68*** | .29*** | -.12 | .02 | .05 | .11*** | -.02 | .67 |
|  | EXAPPLM | .30*** | .76*** | .09 | -.06 | -.01 | .06 | .03 | -.02 | .61 |
| **Print reading** | FAMCONC | .61*** | .53*** | .41*** | .00 | .02 | .08 | .25*** | .02 | .70 |
|  | OTL_PT | .26*** | .76*** | .08 | -.06 | .02 | .11 | .02 | .02 | .60 |
|  | EXPUREM | .38*** | .66*** | .32*** | -.11 | .05 | .10 | .12*** | .02 | .68 |
|  | EXAPPLM | .30*** | .77*** | .06 | -.05 | .02 | .11* | .02 | .02 | .60 |
| **Science** | FAMCONC | .61*** | .59*** | .33*** | .00 | -.02 | .05 | .20*** | -.02 | .68 |
|  | OTL_PT | .26*** | .78*** | .07 | -.06 | -.01 | .07 | .02 | -.02 | .62 |
|  | EXPUREM | .38*** | .68*** | .31*** | -.11 | .02 | .07 | .12*** | -.02 | .70 |
|  | EXAPPLM | .30*** | .77*** | .10 | -.05 | -.01 | .08 | .03 | -.02 | .62 |
| **Digital reading** | FAMCONC | .61*** | .58*** | .29*** | .00 | .07 | .11* | .18*** | .07 | .63 |
|  | OTL_PT | .26*** | .75*** | .04 | -.06 | .07 | .13* | .01 | .07 | .58 |
|  | EXPUREM | .38*** | .64*** | .30*** | -.12 | .10* | .12 | .12*** | .07 | .65 |
|  | EXAPPLM | .30*** | .75*** | .05 | -.05 | .07 | .13* | .01 | .07 | .58 |
| **Computer-based math** | FAMCONC | .61*** | .44*** | .34*** | .00 | .03 | .05 | .21*** | .03 | .49 |
|  | OTL_PT | .26*** | .63*** | .07 | -.06 | .04 | .07 | .02 | .04 | .43 |
|  | EXPUREM | .38*** | .58*** | .19** | -.11 | .06 | .07 | .07** | .04 | .45 |
|  | EXAPPLM | .31*** | .65*** | .00 | -.07 | .04 | .08 | .00 | .04 | .42 |
| **Problem solving** | FAMCONC | .61*** | .47*** | .23** | .00 | .06 | .07 | .14** | .06 | .41 |
|  | OTL_PT | .26*** | .58*** | .13 | -.06 | .07 | .08 | .03 | .07 | .40 |
|  | EXPUREM | .38*** | .51*** | .27*** | -.12 | .10 | .08 | .10** | .07 | .44 |
|  | EXAPPLM | .30*** | .58*** | .10 | -.06 | .07 | .09 | .03 | .07 | .39 |

## ICT and moderation: every significant result (primary runs)

- Print reading, OTL = FAMCONC, M1: ICT total .14 (p = .013)
- Print reading, OTL = OTL_PT, M1: ICT → Ach. (direct) .14 (p = .016)
- Print reading, OTL = OTL_PT, M1: ICT total .14 (p = .015)
- Print reading, OTL = EXPUREM, M1: ICT → Ach. (direct) .15 (p = .005)
- Print reading, OTL = EXPUREM, M1: ICT total .15 (p = .011)
- Print reading, OTL = EXAPPLM, M1: ICT → Ach. (direct) .15 (p = .011)
- Print reading, OTL = EXAPPLM, M1: ICT total .14 (p = .016)
- Digital reading, OTL = EXPUREM, M2: ICT → Ach. (direct) .10 (p = .040)
- Moderation: Print reading, OTL = EXAPPLM, M2: SES × ICT → Ach. .11 (p = .043); not significant with ESCS
- Moderation: Digital reading, OTL = FAMCONC, M2: SES × ICT → Ach. .11 (p = .037); not significant with ESCS
- Moderation: Digital reading, OTL = OTL_PT, M2: SES × ICT → Ach. .13 (p = .020); not significant with ESCS
- Moderation: Digital reading, OTL = EXAPPLM, M2: SES × ICT → Ach. .13 (p = .017); not significant with ESCS

## ESCS instead of the SES composite

6 of 480 path and effect estimates change their verdict at .05:
- Digital reading, OTL = EXAPPLM, M2, SES × ICT → Ach.: .13* → .10
- Digital reading, OTL = FAMCONC, M2, SES × ICT → Ach.: .11* → .08
- Digital reading, OTL = OTL_PT, M2, SES × ICT → Ach.: .13* → .10
- Print reading, OTL = EXAPPLM, M2, SES × ICT → Ach.: .11* → .05
- Science, OTL = EXAPPLM, M1, OTL → Ach.: .11 → .14*
- Science, OTL = EXAPPLM, M2, OTL → Ach.: .10 → .12*

## Cautions

- All comparisons across outcomes and OTL measures are descriptive. Every run uses the same schools, and the outcomes are correlated school means.
- With 139–146 schools, paths below about |.21| are unlikely to reach p < .05 (spec D4). This grid has many tests, so single results near p = .05 are weak evidence.
- **Computer-based outcomes** (digital reading, computer-based math, problem solving): school means of these PVs correlate only .78–.83 with their paper counterparts, below the student-level .86. Only part of the sample may have sat the computer-based test; check the PISA 2012 technical report before interpreting differences from the paper-based outcomes.
