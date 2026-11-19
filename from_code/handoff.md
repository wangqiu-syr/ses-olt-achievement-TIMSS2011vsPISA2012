# Handoff

## Next task: PISA reading and digital reading, as a branch here (planned 2026-11-19, not started)

**User's plan for new repos:**
1. Multilevel runs (WeMix and R-called Mplus), done on the user's laptop later.
2. PISA reading and digital reading: **first as a branch here**, then its own repo.
3. Computer-based math (`PVxCMAT`) and problem solving (`PVxCPRO`).
4. The math subscales: content `MACC/MACQ/MACS/MACU` and process `MAPE/MAPF/MAPI`.

Code can't create repos; the user creates them empty on GitHub. Suggestion to put to the user: items 2 and 3 are both paper-vs-computer contrasts and might share one repo.

**Data check (2026-11-19).** All these PVs exist for all 4,978 students in 162 schools. Weighted PV1 means, with OECD's published US figures:

| Domain | PV1 mean | Published |
|---|---|---|
| Print reading | 497.0 | 498 |
| Digital reading | 510.8 | 511 |
| Computer-based math | 497.8 | 498 |
| Problem solving | 507.2 | 508 |

- r(PV1READ, PV1CREA) = .86; r(PV1MATH, PV1CMAT) = .85.
- **To verify** in the PISA 2012 technical report: whether only a subsample sat the computer-based test. If so, the other students' computer-based PVs come from the conditioning model.
- `ICTRES` (student home ICT resources) has n = 4,927. It's part of HOMEPOS, so it overlaps with SES.

**Proposed design for item 2 (defaults, pending the user's OK):**
- Branch `claude/pisa-reading`, off this branch. Same school samples (146/139), same ICT models (M1 use, M2 resources), same criteria (spec section 6).
- Outcomes: print reading (`READ1`–`5`) and digital reading (`CREA1`–`5`), with math as the anchor.
- Model: SES → reading, ICT → reading, SES × ICT → reading. There's no OTL path, because PISA 2012 OTL is math only. Sensitivity: math OTL (FAMCONC) as a stated proxy.
- Question: do SES and ICT relate differently to digital than to print reading?
- Steps:
  - add `CREA1`–`5` to the school files (`R/a2_01`);
  - write a spec addendum (`docs/spec_reading.md`);
  - add SmartPLS steps;
  - the user runs SmartPLS;
  - read the results with `R/a2_02`, generalized to the outcome.
- Data checks: report rows comparing reading (498) and digital reading (511) with the published means.

## Session 4, part 2 (2026-11-19): notes and reading/science data

### Done
- The user chose to **keep the current layout**. rrtools' `analysis/paper/` (`paper.qmd`, `references.bib`, `.csl`) is to be added when drafting starts.
- Merged PRs #2 and #3.
- The user invited Yue Zhang (the paper's first author) as a repo collaborator. The data stays gitignored, so collaborators get it separately.
- `R/a2_01_prepare_pisa2012.R` now also writes school means of `READ1`–`5` and `SCIE1`–`5` to the SmartPLS files, for exploratory runs.
  - Weighted US means: 497.6 (reading) and 497.4 (science), against the published 498 and 497. These are report rows in `a2_01_checks.csv`.

### Open decisions
1. **Second domain.** PISA 2012 *does* have reading and science scores. What it lacks is OTL for those domains (its OTL items are math only). Options:
   - science, which matches the paper's two subjects;
   - reading, which TIMSS has no counterpart for;
   - or both.

   And for OTL: no OTL, or math OTL as a stated proxy. This changes spec decision 1.
2. **Phase B.** A two-level model (students in schools; ICT at school level; a cross-level ICT × SES slope) on PISA, and on TIMSS (students in classes), once the TIMSS files arrive.
   - Software: Mplus or `WeMix` on the user's laptop. Neither runs here: CRAN is blocked and Mplus is local.
   - Python has no validated weighted multilevel estimator for this design.
3. **Running on the laptop.** No laptop folder is shared with this cloud session (`list_computer_folders` is empty). Either run Claude Code locally on the laptop in a clone of this repo, or Code writes the Mplus and R inputs and the user runs them.

## Session 4 (2026-11-19): repo reorganized on the user's template

### Done
- Followed the layout of `wangqiu-syr/glw2022-matching-replication`:
  - all code is in `R/` (`scripts/` is gone);
  - write-ups are in `docs/`;
  - outputs are in `results/a2/`, with the A2 report at `results/a2/summary.md`;
  - the paper's values are at `results/paper_zhang_wang_2020.csv`.
- `from_code/` now holds only `plan.md` and `handoff.md`.
- Every path in code, tests and docs is updated.
- Both R scripts rerun from `R/` and reproduce their outputs; only the "Built by" path lines changed. Tests: 13 pass, 0 fail, 2 skip.
- Rewrote `README.md` on the template's headings: Key findings, Design, What differed, Results, Reproduce, Files, Status, References.
- Added `R/README.md` (scripts by role) and an updated `docs/README.md`.
- Filled in the paper's reference in `CITATION.cff`; the software authors are still a placeholder.
- Added `*.pdf` and `*.docx` to `.gitignore`.
- **Paths in the older session notes below predate this move.** Use the new layout:
  - outputs go to `results/<phase>/`;
  - scripts go in `R/`.

### Next step
Unchanged from session 3, part 2 below. Start A1 when the TIMSS files arrive (writes to `results/a1/`), or hold the gate review.

## Session 3, part 2 (2026-11-19): SmartPLS results read (A2 step 2)

### Done
- Received 8 SmartPLS exports, stored in `data/raw/smartpls_exports/` (gitignored). SHA-256 in `from_code/a2_02_exports_manifest.csv`.
  - Model 1 and Model 2, each as primary and ESCS runs, each with algorithm and 5,000-sample bootstrap exports.
  - Model 2 drops `ICTRES_RATIO`.
- `scripts/a2_02_read_smartpls.R` extracts the estimates. Outputs:
  - `from_code/a2_pisa2012_estimates_user_sav.csv` (primary runs, spec M5)
  - `from_code/a2_pisa2012_estimates_sensitivity.csv` (ESCS runs)
  - `from_code/a2_02_criteria.csv`
  - **`from_code/a2_02_smartpls_results.md`**, the report with side-by-side TIMSS vs. PISA tables
- **All four runs pass M1–M4.** `ICTUSE_LESSON` loads .65 and is kept under the M1 rule. The `ICTRES_RATIO` drop is supported: it correlates .12 with the 3-item ICT resources score.
- Main results:
  - SES → Math .53–.55 and OTL → Math .37–.38 (TIMSS: .64–.65 and .20–.21).
  - SES → OTL .52–.61 (TIMSS .12–.13).
  - No significant ICT path and no SES × ICT moderation.
  - R² Math .67–.69.
- The criteria test now checks `a2_02_criteria.csv`. Tests: 13 pass, 0 fail, 2 skip (A1 results; parity).

### Open
1. Optional: the Model 2 run with `ICTRES_RATIO` (to record its exact loading), and the PLSc runs (spec 5.2a). Neither was exported.
2. TIMSS 2011 USA files: waiting on the coauthor (list in `plan.md`).
3. A1 tolerances: the paper used WarpPLS's factor-based, likely nonlinear, algorithm. Set them in the spec before A1.
4. Hosts still blocked:
   - CRAN, for the `seminr` cross-check, per-PV pooling and the weighted run;
   - OECD, for the parity check.
5. The gate: the user reviews `a2_02_smartpls_results.md` (and A1, once done) before Phase B.

### Next step
The user reads `from_code/a2_02_smartpls_results.md`. Then either start A1 when the TIMSS files arrive, or review the gate for Phase B. Use a new chat.

## Session 3 (2026-11-19): A2 spec and school-level data (A2 runs before A1)

### Done
- The user approved the five decisions:
  - math only;
  - school level;
  - OTL = FAMCONC; SES = TIMSS-style composite, with ESCS as a sensitivity check;
  - ICT: Model 1 = use, Model 2 = resources;
  - PLS-SEM in SmartPLS (user), with data from Code; parity check deferred.
- Wrote `docs/spec.md`: decisions, measures, model, estimation, proposed acceptance criteria (section 6) and known differences.
- `scripts/a2_01_prepare_pisa2012.R` builds the school files in `data/derived/` (gitignored).
  - Model 1: 146 schools. Model 2: 139 schools.
  - All 5 hard checks pass. The weighted math mean is 481.37, against the published 481.
  - Reports: `from_code/a2_01_pisa2012_school_data.md` and `from_code/a2_01_checks.csv`.
- `from_code/a2_smartpls_steps.md` has step-by-step SmartPLS runs: 2 primary runs and up to 4 sensitivity runs.
- Transcribed the paper's 120 reported numbers into `tests/reference/zhang_wang_2020_reported.csv` (Table 2, Table 3, Figure 2, section 6.2) for A1.
  - Figure and text disagree on one value: M2 math SES×ICT is 0.03 in the figure and 0.02 on p. 12.
- Added `from_code/data_manifest.csv` (SHA-256 of the uploads) and `tests/testthat/test-a2-pisa2012-data.R`.
  - Tests: 6 pass, 0 fail, 3 skip.
- The user confirmed the spec section 6 acceptance criteria.

### Open (superseded by part 2 above)
1. ~~The user runs SmartPLS~~ (done in part 2).
2. TIMSS 2011 USA files: the coauthor is sending them (list in `plan.md`).
3. A1 tolerances. The paper used WarpPLS factor-based PLS, and some paths don't follow from its correlations (e.g. math SES–OTL r = .02, but the path is .12). An exact match is unlikely, so tolerances go in the spec.
4. Hosts are still blocked:
   - CRAN, for the `seminr` cross-check;
   - OECD, for the parity check.

### Next step
Read the SmartPLS exports. Then fill `from_code/a2_pisa2012_estimates_user_sav.csv`, check criteria M1–M5, and write the A2 report.

### Re-supply each session
Put these in place before running anything (all gitignored):
- `US_PISA_2012_STSCH.sav` → `data/raw/pisa2012/user_sav/`
- the paper PDF and the plan .docx → `data/raw/docs/`
- R: `apt-get install -y r-base-core r-cran-renv r-cran-testthat r-cran-haven`

Then run `Rscript scripts/a2_01_prepare_pisa2012.R`.

## Session 2 (2026-11-19): PISA 2012 data audit (A2, step 0)

### Done
- Read Zhang & Wang (2020), pp. 5–12 (data, measures, analysis, results).
  - This settles scaffold open items 2 and 3: the paper uses **US only**, **Grade 8**, math and science.
  - The reported numbers are in Table 2 (reliability, correlations), Table 3 (fit) and Figure 2 (paths).
- Audited the user's PISA .sav against the user's plan `Data to pull out from PISA 2012.docx`.
  - Report: `from_code/a2_00_pisa2012_data_audit.md`
  - Script: `scripts/a2_00_audit_pisa2012.py` (Python, exploratory)
- Merged the scaffold (PR #1) into this branch and moved the audit files into its layout.

### Decisions (resolved in session 3; see `docs/spec.md` section 1)
1. OTL measure: ST62/FAMCONC (recommended), or ST73–76 as listed in the plan table?
2. SES measure: ESCS (recommended), or the plan's composite?
3. ICT: split into use (SC13), resources (SC14 + RATCMP15) and a policy dummy, or keep one 9-item composite?
4. Method: a two-level model with PVs and weights (R), or PLS-SEM to mirror the paper?
5. Goal: replicate the model in PISA, or a formal TIMSS-vs-PISA comparison (A1 + A2)?

### Next step (superseded by session 3)
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
