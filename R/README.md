# R/

All project code. Run each script from the repository root, e.g. `Rscript R/a2_01_prepare_pisa2012.R`.
Prefixes give the phase (`a1_` TIMSS 2011, `a2_` PISA 2012, `b_` multilevel) and the step order.

| Script | Role | Status |
|---|---|---|
| `a2_00_audit_pisa2012.py` | Exploratory audit of the PISA file against the paper and the variable plan (Python, the only non-R file) | done |
| `a2_01_prepare_pisa2012.R` | Builds the school-level SmartPLS files (`data/derived/`; math, print and digital reading, science, computer-based math and problem-solving PVs) and data checks D1–D5 (`results/a2/`) | done |
| `a2_02_read_smartpls.R` | Reads the SmartPLS exports for one outcome, checks criteria M1–M5 and writes the report: `math` (default) → `results/a2/`, `reading` → `results/a2_reading/`, `science` → `results/a2_science/` | done |
| `a2_03_parity_pisa2012.R` | Same model on the user's `.sav` and the OECD download; writes the parity CSVs | waits on OECD access |
| `a2_04_seminr_crosscheck.R` | Re-estimates the SmartPLS models in R with `seminr` and compares every shared estimate; writes `<dir>/a2_04_seminr_vs_smartpls.csv` and `a2_04_seminr_crosscheck.md`. Takes the outcome like `a2_02` | done for math, reading, science |
| `a2_05_seminr_runs.R` | Scripted grid, exploratory: 6 outcomes (math, print reading, science, digital reading, computer-based math, problem solving) × 4 OTL measures (FAMCONC, OTL_PT, EXPUREM, EXAPPLM) × 2 ICT models × SES or ESCS = 96 runs. Writes `results/a2_seminr/` | done |
| `a2_seminr_helpers.R` | Shared `seminr` model code (fit and criteria), sourced by `a2_04` and `a2_05`; not run on its own | — |
| `a2_06_moderation_figures.R` | Figures for the moderation report: SES × ICT across the grid, simple slopes with bootstrap CIs for the focal cell, robustness, OTL by measure. Writes `results/a2_seminr/figures/` and `simple_slopes.csv` | done |
| `a2_07_*` | Per-PV pooling and a weighted run (`seminr`) | to do |
| `a1_*` | Get TIMSS 2011, build the teacher-level file, replicate the paper; writes `results/a1/` | waits on TIMSS files |
| `b_*` | Multilevel model (Phase B) | after the gate |

`seminr` in the cloud sandbox: CRAN is blocked, so `seminr` 2.6.0 was cloned from GitHub (commit `cfc0b30`) and installed with `R CMD INSTALL`. Its diagram-only imports, DiagrammeR and DiagrammeRsvg, were moved to Suggests; the estimation code is unchanged. `lavaan` and the other dependencies come from apt. `renv.lock` records `seminr` at that GitHub commit, so `renv::restore()` on a laptop installs the same code.
