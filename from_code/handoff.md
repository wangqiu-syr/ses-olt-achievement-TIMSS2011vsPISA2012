# Handoff

## Start here (every new session)
Each cloud session starts as a fresh container with no data and no R. Do this first:
1. **Repo and rules:** the repo is `wangqiu-syr/ses-olt-achievement-TIMSS2011vsPISA2012` (renamed from `ses-olt-math-science-…`); attach the new name to cloud sessions. Follow `CLAUDE.md`:
   - set `git config user.name "QW"` and `user.email "351734548+wangqiu-syr@users.noreply.github.com"`;
   - put no `Co-Authored-By: Claude` or `Claude-Session` lines in commits or PRs;
   - start new work from `main`.
2. **Data** (only for analysis tasks): the user attaches `US_PISA_2012_STSCH.sav`. Copy it to `data/raw/pisa2012/user_sav/` (gitignored). SmartPLS exports go in `data/raw/smartpls_exports/<subject>/`.
3. **R** (CRAN is blocked, so packages come from apt, and renv can't download itself):
   - `apt-get update && apt-get install -y r-base-core r-cran-renv r-cran-testthat r-cran-haven r-cran-readxl r-cran-lavaan r-cran-glue r-cran-ggplot2 r-cran-ragg graphviz`;
   - seed renv into the project library: `lib=$(R_PROFILE_USER=/dev/null Rscript -e 'cat(renv::paths$library())'); mkdir -p "$lib"; cp -r /usr/lib/R/site-library/renv "$lib/"`;
   - then `Rscript -e 'renv::hydrate()'`;
   - install seminr from GitHub as in `R/README.md`, last paragraph.
4. **Check:** `Rscript tests/testthat.R` should give 66 pass, 2 skip (without data). With data: `Rscript R/run_all.R` runs every step in about 35 min; `DRY_RUN=1` lists them.
5. **Cloud limits:** pushes to branches and `main` work, through the old-name redirect. These are refused, so the user does them on GitHub:
   - opening or merging PRs;
   - pushing tags;
   - deleting branches.

   zenodo.org, orcid.org, doi.org and DataCite are blocked.

## Session 7 (2026-11-20): review, release v0.1.0, Zenodo DOI. Done
- **Report and README review:**
  - one title everywhere;
  - figures in order (the OTL-measure section is §7, after moderation; Discussion §8, Limitations §9, Conclusions §10);
  - "96 model specifications" instead of "grid"/"runs";
  - full names in every figure and table note;
  - "mathematics" throughout;
  - every mention of the 2020 paper cited (Zhang & Wang, 2020);
  - Figure 0's model labelled "adapted from Zhang & Wang, 2020, Figure 1";
  - R and ggplot2 added to the references (51).
- **Authors:**
  - Qiu Wang: Syracuse University, ORCID 0000-0003-1635-8050;
  - Yue Zhang: Google, ORCID 0000-0002-9070-9990;
  - recorded in `CITATION.cff`, `.zenodo.json` and the README and report bylines.
- **Licences:**
  - code MIT (`LICENSE`, Qiu Wang);
  - report text and figures CC BY 4.0 (`LICENSE-report`, both authors);
  - no change needed for later papers with other co-authors.
- **Release:**
  - v0.1.0 published on GitHub; tag `v0.1.0` = `9c3c5fe`;
  - the first attempt (`v1.0.0`) failed on Zenodo ("Citation metadata load failed"), and the user deleted it;
  - `.zenodo.json` fixed it;
  - Zenodo DOI **10.5281/zenodo.24407221**, now in the README badge, "How to cite", `CITATION.cff` and the report.
- **Housekeeping:**
  - old branches deleted by the user;
  - `CLAUDE.md` added (commit rules);
  - `main` = `claude/pisa-reading` at the end of the session.

## Next task
**Open for the user (small):**
1. Check on the Zenodo record whether 10.5281/zenodo.24407221 is the "all versions" DOI (sidebar: "Cite all versions?"). If the sidebar shows a different number, switch the README badge and `CITATION.cff` `doi:` to that number. The v0.1.0 DOI can go under `identifiers`.
2. Confirm the README rights box ("legitimate access to the data").
3. Repo visibility: it is the user's choice (it was public for the Zenodo archive). The GitHub release and the Zenodo record are already published.

**Analysis (needs the PISA file):**
- Redraw Figures 1–4 so their image text says "Mathematics" and "primary models" instead of "Math", "primary runs" and "(spec)". Edit the labels in `R/a2_06`, then run `FROM=6 Rscript R/run_all.R`.
- Pooling across the five plausible values, and a weighted analysis (`R/a2_07`).
- A direct test of the digital-vs-print interaction difference.
- Check in the PISA 2012 Technical Report that the computer-based plausible values are imputed for students not sampled.
- A1 when the TIMSS files arrive; then Phase B (multilevel models with cross-level SES × ICT terms).

**At the next release:** bump `version` and `date-released` in `CITATION.cff`, and the version in the README and report bylines. Zenodo will make a new DOI.

**Next step:** a new chat on the renamed repo, starting with "Start here", then item 1 above, or the first analysis item if the PISA file is attached.

## Earlier next task (still open: the user's review on 2026-11-20; paths updated in session 6)
1. **The user reviews:**
   - `report/report.md` (was `results/a2_seminr/moderation_report.md`), with figures in `report/figures/`;
   - the README;
   - `CITATION.cff` (author order, affiliations, ORCIDs).
2. **Release (the user's GitHub actions):**
   - ask Code for a PR from `claude/pisa-reading` to `main`, then merge;
   - make the repo public;
   - optionally delete the merged remote branches `claude/bold-gates-y7az9v`, `claude/charming-tesla-llewy4` and `claude/sweet-davinci-2optvo`;
   - add Yue Zhang as a collaborator if not done;
   - tag `v0.1.0`.
3. **Open analysis items:**
   - per-PV pooling and a weighted run (`R/a2_07`);
   - test the digital-vs-print interaction difference directly (a joint model);
   - confirm in the PISA 2012 Technical Report that digital reading and computer-based math PVs are imputed for students who did not sit the CBA (only inferred so far);
   - A1 when the TIMSS files arrive;
   - Phase B multilevel (cross-level SES × ICT), the proper test of the moderation.
4. The user's SmartPLS evening runs (no-FAMCONC OTL, CREA, CMAT, CPRO) are **superseded** by the seminr grid. If the user still sends exports, `R/a2_02` needs an `otl` field in its classifier and `CMAT`/`CPRO` in its outcome list (see session 5, end).

## Session 5, part 3 (2026-11-20): 96-run grid, moderation report, release prep
- **Grid:**
  - `R/a2_05_seminr_runs.R` runs 6 outcomes × 4 OTL measures × 2 ICT models × SES/ESCS = 96 runs, 5,000 bootstraps each, in 25 min. All 96 pass M1–M4.
  - `R/a2_seminr_helpers.R` holds the shared model code (`a2_build`, `a2_fit_pls`, `a2_estimate`, `a2_criteria`).
- **Findings:** see `results/a2_seminr/moderation_report.md`.
  - **Moderation:** digital reading × ICT resources (M2), SES × ICT .11–.13, p < .05 for 3 of 4 OTL measures; with ESCS .08–.10 (n.s.); BH q ≥ .36; f² .03–.04; power about 25%.
  - **Sign pattern:** the interaction is positive for resources (24/24 cells) and negative for use (24/24).
  - **Robust ICT result:** ICT use → print reading, total .14–.16.
  - **OTL:** OTL → achievement .23–.42 with FAMCONC vs .02–.13 with OTL_PT.
  - **Fit:** R² for the computer-based outcomes is .40–.63, against .66–.70 for paper.
- **Figures:**
  - `R/a2_06_moderation_figures.R`: moderation across the grid, simple slopes with bootstrap CIs, robustness, OTL by measure, plus `moderation_stats.csv` (f², BH) and `simple_slopes.csv`.
  - Needs a UTF-8 locale for the × → labels; the script sets `LC_CTYPE`.
  - Flow chart: `docs/figures/design_flowchart.{dot,png,svg}` (Graphviz), in the README's Design section.
- **Literature:** 57 references verified against publisher, DOI or repository listings by a research agent. Its full notes are not in the repo; the report cites the ones used. Not confirmed: the exact Technical Report page on CBA sub-sampling.
- **Release prep:**
  - `docs/spec_exploratory.md`, `results/README.md`, and the data provenance and rebuild steps in `data/README.md`;
  - `CITATION.cff` filled (to confirm);
  - README rewritten (key findings, results, reproduce, files, status, authors);
  - `renv.lock` adds ggplot2, ragg and seminr;
  - no broken relative links;
  - history scan: no data, PDFs or emails ever committed.
- **Tests:** 44 pass, 0 fail, 2 skip.

## Session 5, part 2 (2026-11-20): R cross-check of the math SmartPLS runs
- **Done:** `R/a2_04_seminr_crosscheck.R` re-estimates the 4 math runs in R with `seminr` 2.6.0, with SmartPLS's settings (PLS-SEM mode A, path weighting, two-stage interaction, 5,000-sample bootstrap). It compares every shared estimate.
  - Every point estimate matches to within .0002. The largest gap is the SES × ICT path; all others are within .00001.
  - All 24 path significance verdicts agree. Bootstrap SEs differ by at most .001.
  - Report: `results/a2/a2_04_seminr_crosscheck.md`. New test `test-a2-seminr.R`. Tests: 30 pass, 4 skip.
- **Gotcha:** `reflective()` in seminr means PLSc. Use `composite(..., weights = mode_A)` to match SmartPLS PLS-SEM.
- **seminr install (CRAN blocked):** `git clone --depth 1 https://github.com/sem-in-r/seminr` (commit `cfc0b30`). Then move DiagrammeR and DiagrammeRsvg from Imports to Suggests in DESCRIPTION, and `apt-get install r-cran-lavaan r-cran-glue`.
  - Then `renv::hydrate(packages = c("lavaan", "glue"))` and `R CMD INSTALL -l renv/library/R-4.3/x86_64-pc-linux-gnu <clone>`.
  - `renv.lock` now records seminr at that GitHub commit, plus 6 dependencies.
- **Reading and science cross-checked too** (OTL = FAMCONC, as the user ran them). Every estimate is within .0003. All 24 paths and all 16 total and indirect effects per subject get the same verdict. The reading lead (M1 ICT-use total effect .145*) holds in seminr. Tests: 36 pass, 2 skip.
  - Fixed on the way: seminr's `specific_effect_significance()` returns a 1-row table, so index it `[1, "Original Est."]`.
- **Next uses:**
  - then, instead of SmartPLS by hand, scripted runs of every subject × OTL version.
  - `a2_05`: per-PV pooling and a weighted run.

## Session 5 (2026-11-19): PISA reading and science read (branch `claude/pisa-reading`, off `main`)

### Done
- The `.sav` was **not** attached, so `a2_01` could not run on real data. R was installed (step 2 above, which needed two fixes).
- 16 SmartPLS exports received: reading and science, 8 each (M1/M2 × primary/ESCS × algorithm/bootstrap). Stored in `data/raw/smartpls_exports/{reading,science}/` (gitignored); SHA-256 in each `results/a2_<subject>/a2_02_exports_manifest.csv`.
- `R/a2_02_read_smartpls.R` now takes an outcome: `math` (default), `reading`, `science` or `digital`.
  - Exports are matched by content, not name (the uploads had names like `RADING_`, `sCIENCE_`).
  - New rows from the bootstrap: indirect (`ind_SES_OTL_ACH`, `ind_ICT_OTL_ACH`) and total (`tot_SES_ACH`, `tot_ICT_ACH`) effects.
  - The math report text is unchanged. Not rerun on real math exports (they're not in this container). A smoke test, reading exports relabelled as math, gave the same IDs, columns, run order and report text. On the next real math rerun, expect 8 extra estimate rows and 3 extra manifest columns (`model`, `run`, `kind`).
- **Reports:** `results/a2_reading/summary.md` and `results/a2_science/summary.md`. All 8 runs pass M1–M4 (`ICTUSE_LESSON` loads .64–.67, kept, as in math).
  - Reading: SES → Read .46–.53 (math .53–.55), OTL → Read .41–.42 (math .37–.38). The Model 1 ICT-use **total** effect is .14 (p = .016), though neither its direct nor its indirect part is significant. Framed as a lead.
  - Science: within .05 of math on every path. Against TIMSS science, it repeats the math contrast. TIMSS's M1 SES × ICT (.09*) and M2 ICT → OTL (−.09*) don't appear in PISA.
  - ESCS changes no significance in either subject.
- `R/a2_01` now adds `CREA1`–`5` (digital reading school means), plus a report check row (published 511). Checked only on a synthetic `.sav`; not run on real data.
- The test now checks the criteria for math, reading and science: 27 pass, 0 fail, 2 skip.
- README, `R/README.md`, `data/README.md` and `docs/a2_smartpls_steps.md` updated.

### Open
1. **OTL in reading and science.** The user's runs keep OTL = FAMCONC (math) as a proxy. The reports say so. Confirm this, or ask for no-OTL runs, and record it as a spec addendum (`docs/spec_reading.md`, planned in session 4).
2. Subject differences are descriptive. A formal test would need both outcomes in one model with a shared bootstrap.
3. Rerun math (`Rscript R/a2_02_read_smartpls.R`) once its exports are back in a container, to add the math indirect and total effects with p values. The reading and science reports currently derive them from the math paths.
4. Merge `claude/pisa-reading` into `main` (PR), when the user asks.

## Plan: PISA reading and digital reading (session 4, part 2; print reading and science done in session 5)

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
