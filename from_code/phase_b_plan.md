# Phase B plan: multilevel models (brief for a new chat)

**Source repo:** `wangqiu-syr/ses-olt-achievement-TIMSS2011vsPISA2012`. Phase A is published (report v0.1.0; Zenodo 10.5281/zenodo.24407221).
**Where Phase B runs:** a new repo, on the user's laptop, using Mplus (called from R with MplusAutomation) and R `WeMix`. Use this repo's layout and `CLAUDE.md` rules.

## Why Phase B
- Phase A worked at school level (139–146 schools). ICT had no effect on math.
- Exploratory finding: ICT resources × SES steepened the digital-reading SES slope (.11–.13, p .02–.05). It doesn't survive multiple-testing correction (BH q = .36) and weakens with ESCS.
- Across outcomes, the sign followed the kind of ICT: positive for resources, negative for use.
- The report says a test at school level would need about 510 schools (§8.7). Phase B instead tests the moderation at student level, as a cross-level interaction.

## Preregister first (recommended)
Use the OSF secondary-data template, before any fitting, and state that Phase A results on these data have been seen.
- **H1:** school ICT resources × student SES (group-mean centred) > 0 for digital reading.
- **H2:** this interaction is larger for digital than for print reading.
- **H3 (exploratory, two-sided):** the sign depends on the kind of ICT (resources +, use −) across outcomes.

Control multiple testing with BH across outcome × ICT measure, and report both SES measures.

## Data: `US_PISA_2012_STSCH.sav` (4,978 students, 162 schools; gitignored)
- **Level 1:**
  - SES composite (as in A2: weighted z of ST28Q01, HISCED, HOMEPOS) and ESCS;
  - OTL: FAMCONC, plus OTL_PT, EXPUREM and EXAPPLM as in the A2 grid;
  - 5 PVs each for MATH, READ, CREA, SCIE, CMAT and CPRO.
- **Level 2:**
  - ICT use: SC13Q01–03;
  - ICT resources: SC14Q07–09 reversed (RATCMP15 was dropped in A2);
  - school means of SES and OTL.
- **Weights:** level 2 = W_FSCHWT; level 1 = W_FSTUWT / W_FSCHWT, scaled. In Mplus: `WTSCALE = CLUSTER; BWTSCALE = SAMPLE`.
- **Open from Phase A:** confirm in the PISA 2012 Technical Report whether the computer-based PVs (CREA, CMAT, CPRO) are imputed for students who didn't sit the computer test.

## Models (each outcome; ICT use and ICT resources separately)
- **B0 Null:** the ICC (A2 audit: math ICC = .24).
- **B1 Random intercept:**
  - level 1: SES and OTL, group-mean centred;
  - level 2: school-mean SES, school-mean OTL, ICT.
- **B2 Random SES slope + ICT × SES cross-level interaction:** the focal test.
- **B3 Two-level SEM (Mplus):** SES → OTL → outcome, within and between schools.
- **H2 test:** print and digital reading in one two-level model, with a Wald test of the difference between the two cross-level terms.

## Estimation
- **PVs:** 5 runs, pooled with Rubin's rules (Mplus `TYPE = IMPUTATION`; R `mitools`).
- **Missing OTL:** about 1/3 of students lack it by design (rotated questionnaire). Options:
  - FIML in Mplus;
  - multiple imputation nested with the PVs, needed for WeMix, which drops incomplete cases.
- **Cross-check:** fit B1 and B2 in both Mplus and WeMix; they must agree within a tolerance set in the spec.
- **Report:** unstandardized and standardized estimates, random-slope variance, pseudo-R² and the fraction of missing information.
- **Power:** run an Mplus Monte Carlo before fitting (162 schools, cross-level effect about .10). Report the minimum detectable effect.

## TIMSS 2011 (later, when the files arrive)
Students within classes (teacher link file BST), with teacher computer use and OTL coverage at class level, fitting the same B0–B3. This also fixes the paper's aggregation to teacher level.

## Decisions for the user (before writing `docs/spec_phase_b.md`)
1. Preregister first: yes or no.
2. Outcomes: digital and print reading only (H1, H2), or all six.
3. Missing OTL: FIML in Mplus with WeMix on complete cases as a check, or multiple imputation for both.
4. SES: composite primary and ESCS as sensitivity, as in Phase A.
5. New repo name.

## First steps in the new chat (laptop)
1. Create the new repo with this repo's layout, and reuse `R/a2_01_prepare_pisa2012.R` for the SES, OTL and ICT construction.
2. Put the `.sav` in `data/raw/pisa2012/user_sav/`.
3. Write `docs/spec_phase_b.md` (decisions, models, acceptance criteria) for the user to confirm, then preregister.
4. Run the power simulation, then B0.
5. Outputs:
   - Mplus inputs in `mplus/`;
   - scripts `R/b_*`;
   - results in `results/b/summary.md`.
