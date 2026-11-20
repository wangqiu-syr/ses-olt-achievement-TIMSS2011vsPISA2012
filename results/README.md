# results/

Machine outputs. Every file here is written by a script in `R/` and is reproducible from the raw data (see the main README, *Instructions to replicators*), except `paper_zhang_wang_2020.csv`, which is transcribed. Raw and derived data are not in the repository. The study itself is [report/report.md](../report/report.md), and its figures are in `report/figures/`.

| Folder or file | What it holds | Written by |
|---|---|---|
| `paper_zhang_wang_2020.csv` | The 120 values reported in Zhang & Wang (2020), for comparison | transcribed by hand |
| `a2/` | **A2, the confirmatory analysis:** PISA 2012 math, OTL = FAMCONC. SmartPLS estimates, criteria, data checks, and the `seminr` cross-check. Report: `a2/summary.md` | `a2_01`, `a2_02`, `a2_04` |
| `a2_reading/`, `a2_science/` | Exploratory: the user's SmartPLS runs for print reading and science, each compared with math, plus their `seminr` cross-checks. Reports: `summary.md` in each | `a2_02`, `a2_04` |
| `a2_seminr/` | Exploratory: the 96-run `seminr` grid (6 outcomes × 4 OTL measures × 2 ICT models × SES or ESCS). Report: `summary.md` (all runs). `moderation_stats.csv` and `simple_slopes.csv` feed the report's §6; `moderation_report.md` now points to the report | `a2_05`, `a2_06` |
| `a1/` | A1, the replication of the paper on TIMSS 2011. Not yet produced; waits on the TIMSS files | `a1_*` (to come) |

## File conventions
- **Estimates:** one row per estimate, keyed by `estimate_id` = `<model>_<subject>_<quantity>`, e.g. `M1_math_path_SES_ACH`. Subjects are `math`, `read`, `sci`, `dig`, `cmat` and `cpro`. Quantities include:
  - `path_`: path coefficient;
  - `ind_`: indirect effect via OTL;
  - `tot_`: total effect;
  - `r2_`, `alpha_`, `rhoa_`, `rhoc_`, `ave_`, `loading_`, `htmt_`, `vif_`, `cor_`.
- **Columns:** `estimate`, `se` (bootstrap SD), `p_value` (two-tailed, t with nboot − 1 df), `ci_low` and `ci_high` (95% percentile bootstrap).
- **Criteria files** give M1–M4 from `docs/spec.md` section 6, per run.
- **Manifests** record the SHA-256 of every raw input.
