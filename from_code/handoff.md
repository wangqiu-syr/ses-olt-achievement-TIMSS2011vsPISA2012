# Handoff

## Session 2 (2026-11-19): PISA 2012 data audit (A2, step 0)

### Done
- Read Zhang & Wang (2020), pp. 5–12 (data, measures, analysis, results).
  - This settles scaffold open items 2 and 3: the paper uses **US only**, **Grade 8**, math and science.
  - The reported numbers are in Table 2 (reliability, correlations), Table 3 (fit) and Figure 2 (paths).
- Audited the user's PISA .sav against the user's plan `Data to pull out from PISA 2012.docx`.
  - Report: `from_code/a2_00_pisa2012_data_audit.md`
  - Script: `scripts/a2_00_audit_pisa2012.py` (Python, exploratory)
- Merged the scaffold (PR #1) into this branch and moved the audit files into its layout.

### Open: decisions needed from the user (details in the audit report, section 3)
1. OTL measure: ST62/FAMCONC (recommended), or ST73–76 as listed in the plan table?
2. SES measure: ESCS (recommended), or the plan's composite?
3. ICT: split into use (SC13), resources (SC14 + RATCMP15) and a policy dummy, or keep one 9-item composite?
4. Method: a two-level model with PVs and weights (R), or PLS-SEM to mirror the paper?
5. Goal: replicate the model in PISA, or a formal TIMSS-vs-PISA comparison (A1 + A2)?

### Next step
After the decisions above:
1. Write `docs/spec.md`.
2. Enter the paper's numbers in `tests/reference/zhang_wang_2020_reported.csv`.
3. Start `scripts/a2_02`/`a2_03` in R.

A1 still needs the TIMSS 2011 USA files (list in `plan.md`; `<cnt>` = `usa`).

### Re-supply each session
Copy the .sav to `data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav` (gitignored). The paper's PDF is also gitignored.

## Session 1 (2026-11-19): scaffold

### Done
- Scaffolded `R/`, `scripts/`, `docs/`, `from_code/`, `tests/` and `data/`.
  - `data/` is gitignored, except its README.
- Added `README.md`, `.gitignore` and a placeholder `CITATION.cff`.
- Set up renv: R 4.3.3, renv 1.0.3, testthat 3.2.1.
- Wrote the testthat skeleton: 4 tests pass, 3 skip (they wait on inputs).
  - `tests/reference/zhang_wang_2020_reported.csv` is a header-only template.
  - The A1 test compares `from_code/a1_timss2011_estimates.csv` against it.
  - The A2 tests check that the two PISA copies give the same estimates, and check the `docs/spec.md` criteria.
- Network test (recorded in `plan.md`): TIMSS (bc.edu, iea.nl), OECD and CRAN are **blocked**. apt and GitHub are reachable.

### Still open from session 1
1. Data access: allowlist timssandpirls.bc.edu, www.iea.nl, www.oecd.org, webfs.oecd.org and cloud.r-project.org, or upload the files listed in `plan.md`.
2. `docs/spec.md` (A2 acceptance criteria) is not written yet.
3. Each new sandbox needs R reinstalled: `apt-get install -y r-base-core r-cran-renv r-cran-testthat`, plus the `r-cran-*` model packages.
