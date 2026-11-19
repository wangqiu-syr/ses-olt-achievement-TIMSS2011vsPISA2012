# A2: SmartPLS 4 steps (user runs these; spec: `docs/spec.md` sections 4–5)

Input files (Code sends them to you; they are not in git):
- `a2_smartpls_model1.csv`: 146 schools
- `a2_smartpls_model2.csv`: 139 schools

The files have no missing values. Menu names may differ slightly between SmartPLS versions.

## Model 1: ICT use
1. New project → import `a2_smartpls_model1.csv` with **Delimiter: Comma**, Escape: Double quotes, Locale: US. Check that it reads 146 rows and that `SCHOOLID` is treated as an ID or ignored.
2. New PLS-SEM model. Draw four constructs and assign indicators (all reflective):
   - **SES** ← `SES`
   - **OTL** ← `OTL`
   - **ICT** ← `ICTUSE_LESSON`, `ICTUSE_HOMEWK`, `ICTUSE_ASSIGN`
   - **MATH** ← `MATH1`–`MATH5`
3. Draw the paths: SES → OTL, SES → MATH, OTL → MATH, ICT → OTL, ICT → MATH.
4. Add the moderating effect on SES → MATH, with ICT as moderator. Use the two-stage approach and standardized product terms.
5. Run the **PLS-SEM algorithm**: path weighting scheme, default iterations and stop criterion.
6. Run **Bootstrapping**: 5,000 subsamples, percentile, two-tailed, significance 0.05, fixed seed (write the seed down).
7. Export both reports (algorithm and bootstrap) to Excel.

## Model 2: ICT resources
Repeat steps 1–7 with `a2_smartpls_model2.csv` (139 rows). Here **ICT** ← `ICTRES_COMP`, `ICTRES_NET`, `ICTRES_SOFT`, `ICTRES_RATIO`.

Expect `ICTRES_RATIO` to load weakly: it correlates only .11 with the shortage items. If its loading is < .40, drop it, rerun steps 5–7, and note it (spec M1).

## Sensitivity runs
Copy each model and change one thing at a time, running steps 5–7 each time:
- **(a)** Algorithm: consistent PLS (PLSc), with consistent bootstrapping. If SmartPLS won't combine PLSc with the interaction term, note it and skip.
- **(b)** SES indicator replaced by `ESCS`.

## Send back
Attach the Excel exports here: 2 primary runs plus up to 4 sensitivity runs. Name each file `M1_primary`, `M2_PLSc`, and so on. Include the bootstrap seed.

Code then:
- fills `from_code/a2_pisa2012_estimates_user_sav.csv`;
- checks criteria M1–M5;
- writes the A2 report with a side-by-side table against the paper's TIMSS values.
