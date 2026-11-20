# Phase B brief: multilevel test of SES × school ICT (start a new chat from this)

Written 2026-11-20 from the report (`report/report.md` §6, §8.7, §9) and `from_code/handoff.md`. Before this brief, Phase B was only a one-line plan (`plan.md`); no specification exists yet.

## Read first
1. `CLAUDE.md`, then `from_code/handoff.md` ("Start here").
2. This brief.
3. `report/report.md` §6 (moderation) and `docs/spec.md` (A2 measures).

## Why Phase B
A2 (school-level PLS-SEM, 139–146 schools) found:
- **Lead:** ICT resources (SC14Q07–09, reversed) × SES → digital reading, b = .11–.13 across all 4 OTL measures.
- **Not robust:** with ESCS, b = .08–.10 (n.s.); after BH correction across 48 tests, q ≥ .36.
- **Direction:** the sign follows the ICT measure. ICT resources gives positive estimates in all 24 models; ICT use (SC13) gives negative ones in all 24.
- **Mathematics:** no ICT effect and no moderation.
- **Power:** about 25% for β = .11; 80% would need about 510 schools. The report (§8.7) names student-level models with a cross-level SES × ICT term as the proper test.

## Draft model (to be fixed in `docs/spec_phase_b.md` before fitting)
- **Level 1 (students *i* in school *j*):** achievement = β0j + β1j·SES_ij (group-mean centred) [+ OTL_ij] + e_ij
- **Level 2:**
  - β0j = γ00 + γ01·ICT_j + γ02·meanSES_j [+ γ03·meanOTL_j] + u0j
  - β1j = γ10 + **γ11·ICT_j** + u1j

  γ11 is the cross-level test. γ02 − γ10 is the contextual SES effect.
- **ICT_j:** resources (SC14) as the primary measure; use (SC13) as the second, testing the sign pattern.
- **Outcomes:** digital reading (primary, from the lead); print reading; mathematics (the Zhang & Wang analogue, with OTL as mediator: SES → OTL → math).
- **SES:** the composite (books + HISCED + HOMEPOS) and ESCS. Report both.
- **Plausible values:** fit once per PV (5) and pool with Rubin's rules.
- **Weights:** two-level weights. School weight `W_FSCHWT`; within-school weight `W_FSTUWT / W_FSCHWT`, scaled. Check this against the PISA 2012 Technical Report.
- **Missing data:** OTL items were rotated (about 2/3 of students). Use FIML (Mplus) or MI. The SES × ICT test can also run without OTL on all students.

## Known issues to settle
1. **Computer-based PVs.** `FORMID` (the computer-based assessment form) is present for only 2,572 of 4,978 students. Digital reading PVs for the rest likely come from the conditioning model, which includes SES. This can bias the SES slope. Verify in the Technical Report, and consider restricting digital-reading models to CBA takers.
2. **Not an independent test.** The data are the same US PISA 2012 students that produced the lead. Call it a multilevel re-test. A real test needs new data: a later PISA cycle (2015 onward tests all students on computer) or other countries.
3. **Software.** WeMix (R) or Mplus (TWOLEVEL RANDOM, TYPE = IMPUTATION), both on the user's laptop. In the cloud, CRAN is blocked and Mplus is unavailable, so Code writes the inputs and the user runs them. Alternatively, run Claude Code locally in a clone.
4. **TIMSS side:** students within classes, once the TIMSS 2011 USA files arrive (A1 is still open).

## Decisions for the user (answer in one message)
1. **Preregister** on OSF (secondary-data template, declaring what A2 already showed) before fitting? Recommended: yes.
2. **Primary outcome:** digital reading only, or digital + print reading + mathematics?
3. **Digital reading sample:** all students, or CBA takers only (n ≈ 2,572)?
4. **OTL:** in the model (FIML, about 2/3 of students have it), or left out of the SES × ICT test?
5. **Software:** WeMix, Mplus, or both as a cross-check?
6. **Scope:** PISA 2012 US only, or add a later PISA cycle or other countries for an independent test?

## Deliverables (prefix `b_`)
- `docs/spec_phase_b.md`: the frozen specification; it doubles as the preregistration text.
- `R/b_01_prepare.R`: the student-level file with centring, weights and PVs. It runs in the cloud with the `.sav`.
- `R/b_02_wemix.R` and/or `mplus/b_*.inp`: run on the laptop.
- `results/b/`: pooled estimates, a cross-level interaction table, simple slopes, and a summary.
- `tests/testthat/test-b-*.R`.
