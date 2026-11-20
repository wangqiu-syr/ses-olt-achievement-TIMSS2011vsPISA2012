# Opportunity to learn, family SES and computer use in mathematics achievement: Zhang and Wang (2020) on TIMSS 2011, and an analogue on PISA 2012

In progress · November 2026

## Key findings

Zhang and Wang (2020) modelled US Grade 8 mathematics and science achievement in TIMSS 2011 at teacher level. Their model has three parts: content coverage as opportunity to learn (OTL), family socioeconomic status (SES), and in-class computer use as a moderator of SES. This project replicates that model (A1) and fits an analogue on PISA 2012 (A2). **A2 is done. A1 is waiting for the TIMSS files.**

- **SES dominates in both studies.** In PISA 2012 (US, 139–146 schools), SES → math is .53–.55, against .64–.65 in the paper's TIMSS results.
- **OTL matters more in PISA, and depends more on SES.** OTL → math is .37–.38, against .20–.21 in TIMSS. SES → OTL is .52–.61, against .12–.13. Part of SES's association with math runs through OTL (indirect effect .19 in Model 1).
- **No computer-use effect in PISA.** No ICT path is significant, and ICT does not moderate SES → math. In TIMSS, computer use was linked to math OTL. The PISA ICT measures are principal reports on internet use and resources, not classroom computer use, so the two results are not like for like.
- **Reading and science look like math (exploratory).** The same model with PISA reading or science as the outcome gives SES → achievement .46–.59 and OTL → achievement .33–.42, within .07 of math on every path. Here OTL is math concept familiarity, a proxy (PISA 2012 has no reading or science OTL). The one new signal is a total ICT-use effect on reading of .14 (p = .016), which is a lead to check in digital reading, not a finding.
- **The results reproduce in R.** Re-estimating every SmartPLS run (math, reading, science; 12 runs) with `seminr` gives the same estimates (largest gap .0003, on the interaction path). It also gives the same significance verdict on every path and every total and indirect effect.
- **The measures pass.** All four SmartPLS runs (two models, each also with ESCS instead of the SES composite) meet the pre-set reliability, validity and collinearity criteria. Swapping ESCS for the SES composite changes no conclusion.

These comparisons are descriptive. The two studies differ in unit (schools vs. teachers), population (15-year-olds vs. Grade 8) and measures; see [What differed](#what-differed).

## Why this project

The paper's TIMSS findings concern US Grade 8 classrooms in one year. Two questions follow: does the same OTL–SES–achievement structure appear in PISA 2012, which measures OTL differently, and does the paper's own analysis reproduce from the public TIMSS data? A2 answers the first. A1 will answer the second and check the pipeline against the published numbers.

## Background

The paper builds on the OTL–SES–performance model of Schmidt et al. (2011, 2015; cited in the paper). SES relates to achievement directly and through OTL. Computer use in class relates to OTL and to achievement, and may moderate the SES–achievement link.

The data are TIMSS 2011, US Grade 8: math 3,398 students and 183 teachers; science 3,989 students and 363 teachers. Only classes whose teachers use computers are included. Student data are aggregated to teacher level.

The model is fitted with factor-based PLS-SEM in WarpPLS 5.0. Model 1 uses the computer as an information tool and Model 2 as a learning tool.

## Design

- **A1 (TIMSS 2011, pending).** The same sample, measures and model as the paper. The paper's 120 reported values are transcribed in [results/paper_zhang_wang_2020.csv](results/paper_zhang_wang_2020.csv). The A1 test checks against them once the tolerances are set.
- **A2 (PISA 2012, done).** US students aggregated to schools, math only. [docs/spec.md](docs/spec.md) records the decisions and the acceptance criteria.
  - SES: books, parent education and home possessions, as in TIMSS. ESCS is a sensitivity check.
  - OTL: FAMCONC.
  - Achievement: 5 plausible values.
  - ICT: use (Model 1) or resources (Model 2).
  - Estimation: PLS-SEM in SmartPLS 4 with 5,000 bootstrap samples, run by the author. Code builds the data and reads the results.
- **A2 reading and science (exploratory, branch `claude/pisa-reading`).** The math model with the outcome swapped for reading or science (5 PVs each), same schools, same criteria. OTL stays FAMCONC as a stated proxy. Digital reading (`CREA1`–`5`) is in the school files for the next run.

## What differed

| | TIMSS 2011 (paper) | PISA 2012 (A2) |
|---|---|---|
| Unit | Teachers (students aggregated) | Schools (students aggregated; PISA has no teacher link) |
| Population | Grade 8 | 15-year-olds, mostly Grade 10 |
| OTL | Teacher-reported topic coverage this year | Student-reported familiarity with 13 concepts (cumulative) |
| Computer use | Teacher-reported classroom use | Principal-reported internet use for schoolwork (M1) or ICT resources (M2) |
| Subjects | Math and science | Math (spec). Reading and science are exploratory, with math OTL as a proxy: PISA 2012 has no reading or science OTL, and the US skipped the ICT questionnaire |
| Software | WarpPLS 5.0, factor-based PLS | SmartPLS 4, PLS-SEM |

One more caution: some paper paths don't follow from its own correlations (e.g. math SES–OTL r = .02, but the path is .12). This suggests WarpPLS's nonlinear algorithm, so an exact A1 match is unlikely.

## Results

A2, math, primary runs (TIMSS values from the paper's Figure 2):

| Path | TIMSS M1 | PISA M1 (ICT use) | TIMSS M2 | PISA M2 (ICT resources) |
|---|---|---|---|---|
| SES → OTL | .12* | .52*** | .13* | .61*** |
| SES → Math | .65** | .53*** | .64** | .55*** |
| OTL → Math | .20** | .37*** | .21** | .38*** |
| ICT → OTL | .29** | .12 | .17** | .00 |
| ICT → Math | .08 | .03 | .08 | −.02 |
| SES × ICT → Math | .04 | −.05 | .03 | .03 |
| R² Math | .50 | .67 | .50 | .69 |

\* p < .05, \*\* p < .01, \*\*\* p < .001. [results/a2/summary.md](results/a2/summary.md) has the full tables: confidence intervals, fit, correlations, the ESCS runs and the criteria.

Reading and science (exploratory) set each subject beside PISA math, with indirect and total effects: [results/a2_reading/summary.md](results/a2_reading/summary.md) and [results/a2_science/summary.md](results/a2_science/summary.md). The science report also has the paper's TIMSS science column.

## Reproduce

From the repository root (R 4.3; packages haven, readxl and testthat, pinned in `renv.lock`). Raw data are not in the repo; [data/README.md](data/README.md) says where each file goes.

| Step | Command | Notes |
|---|---|---|
| 0. Packages | `renv::restore()` | Where CRAN is blocked (Claude Code sandbox): `apt-get install r-base-core r-cran-renv r-cran-haven r-cran-readxl r-cran-testthat`, then `renv::hydrate()` |
| 1. A2 school-level data | `Rscript R/a2_01_prepare_pisa2012.R` | Needs `data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav`; seconds |
| 2. A2 models | SmartPLS 4, by hand | Steps in [docs/a2_smartpls_steps.md](docs/a2_smartpls_steps.md); exports go in `data/raw/smartpls_exports/` |
| 3. A2 results and criteria | `Rscript R/a2_02_read_smartpls.R` (math), then `... reading` and `... science` | seconds each; exports are matched to runs by content, so file names don't matter |
| 3b. R cross-check | `Rscript R/a2_04_seminr_crosscheck.R` (math), then `... reading` and `... science` | about 1 minute each; needs `seminr` (see `R/README.md`) |
| 4. Tests | `Rscript tests/testthat.R` | 36 pass; 2 skip until A1 and the PISA parity check exist |

## Files

### Start here

This README gives the overview. [results/a2/summary.md](results/a2/summary.md) sets the PISA results beside the paper's, and [docs/spec.md](docs/spec.md) records every A2 decision.

### Design and decisions

- [docs/spec.md](docs/spec.md): A2 decisions, measures, model, estimation, acceptance criteria and known differences.
- [docs/a2_data_audit.md](docs/a2_data_audit.md): the audit of the PISA file against the paper and the variable plan, which led to the measure choices.
- [docs/a2_smartpls_steps.md](docs/a2_smartpls_steps.md): the SmartPLS runs.

### Code

Scripts are in `R/` and run from the repository root; [R/README.md](R/README.md) lists them by role.
- [R/a2_01_prepare_pisa2012.R](R/a2_01_prepare_pisa2012.R) builds the school files and data checks.
- [R/a2_02_read_smartpls.R](R/a2_02_read_smartpls.R) reads the SmartPLS exports for one outcome (math, reading or science), checks the criteria and writes the report.
- [R/a2_00_audit_pisa2012.py](R/a2_00_audit_pisa2012.py) is the exploratory audit, in Python.
- Tests are in `tests/testthat/`.

### Results

[results/a2/summary.md](results/a2/summary.md) is the A2 report. [results/a2_reading/](results/a2_reading/summary.md) and [results/a2_science/](results/a2_science/summary.md) hold the exploratory reading and science runs, with the same file set (estimates, criteria, exports manifest, summary, seminr cross-check).

<details>
<summary>A2 CSVs and records (11 files)</summary>

- **Estimates:**
  - [results/a2/a2_pisa2012_estimates_user_sav.csv](results/a2/a2_pisa2012_estimates_user_sav.csv): primary runs, with SE, p and 95% CI;
  - [results/a2/a2_pisa2012_estimates_sensitivity.csv](results/a2/a2_pisa2012_estimates_sensitivity.csv): ESCS runs.
- **Criteria:**
  - [results/a2/a2_02_criteria.csv](results/a2/a2_02_criteria.csv): model criteria M1–M4 per run;
  - [results/a2/a2_01_checks.csv](results/a2/a2_01_checks.csv): data checks D1–D5.
- **R cross-check:** [results/a2/a2_04_seminr_crosscheck.md](results/a2/a2_04_seminr_crosscheck.md) (report) and [results/a2/a2_04_seminr_vs_smartpls.csv](results/a2/a2_04_seminr_vs_smartpls.csv): seminr vs. SmartPLS, every shared estimate.
- **Data report:** [results/a2/a2_01_pisa2012_school_data.md](results/a2/a2_01_pisa2012_school_data.md): samples, descriptives, correlations, reliabilities.
- **Audit output:** [results/a2/a2_00_pisa2012_data_audit_output.txt](results/a2/a2_00_pisa2012_data_audit_output.txt).
- **Provenance:**
  - [results/a2/data_manifest.csv](results/a2/data_manifest.csv): raw files;
  - [results/a2/a2_02_exports_manifest.csv](results/a2/a2_02_exports_manifest.csv): SmartPLS exports, with SHA-256.

</details>

### Published values

[results/paper_zhang_wang_2020.csv](results/paper_zhang_wang_2020.csv) holds the 120 values transcribed from the paper: Tables 2–3, Figure 2 and section 6.2. They are for comparison only, and the paper's PDF is not included.

### Project files

- [LICENSE](LICENSE) (MIT), [CITATION.cff](CITATION.cff) (placeholder) and [.gitignore](.gitignore) (keeps data, PDFs and Word files out).
- `renv.lock` and `renv/`: package versions.
- `from_code/`: the working plan and session handoff notes.

## Status

- **A1:** waiting for the TIMSS 2011 US Grade 8 files. Tolerances are to be set in the spec, given WarpPLS.
- **Still to come for A2:**
  - the PISA parity check (needs the OECD download);
  - the R cross-check is done for math, reading and science (`results/a2*/a2_04_seminr_crosscheck.md`); per-PV pooling and a weighted run are still to do;
  - optional PLSc runs.
- **Reading and science (exploratory):** done for print reading and science. Next are digital reading (`CREA`), computer-based math (`CMAT`), problem solving (`CPRO`), and OTL without FAMCONC (`OTL_PT` from ST73–76, `EXPUREM`, `EXAPPLM`). The school files carry all of these; the user runs SmartPLS.
- **Phase B (multilevel model):** after the gate review of A1 and A2.

## AI assistance

The code was written with assistance from Claude Code (Anthropic).

## References

- Kock, N., & Hadaya, P. (2018). Minimum sample size estimation in PLS-SEM: The inverse square root and gamma-exponential methods. *Information Systems Journal, 28*(1), 227–261. https://doi.org/10.1111/isj.12131
- OECD. (2013). *PISA 2012 results: What students know and can do (Volume I)*. OECD Publishing. https://doi.org/10.1787/9789264201118-en
- Ringle, C. M., Wende, S., & Becker, J.-M. (2024). *SmartPLS 4*. SmartPLS. https://www.smartpls.com
- Zhang, Y., & Wang, Q. (2020). Content learning opportunities, computer-based instruction, and students' mathematics and science achievement. *International Journal of Mathematical Education in Science and Technology*. https://doi.org/10.1080/0020739X.2020.1717659

## How to cite

Citation metadata will be in [CITATION.cff](CITATION.cff) (currently a placeholder). Please also cite the original paper.

## License

MIT (see `LICENSE`).
