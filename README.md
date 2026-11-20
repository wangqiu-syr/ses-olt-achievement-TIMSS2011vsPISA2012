# Opportunity to learn, socioeconomic status and school ICT in US achievement: from TIMSS 2011 to PISA 2012

[Qiu Wang](https://orcid.org/0000-0003-1635-8050) (Syracuse University) and [Yue Zhang](https://orcid.org/0000-0002-9070-9990) (Google) · Version 0.1.0 · November 2026 · **[Read the report](report/report.md)**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.24407221.svg)](https://doi.org/10.5281/zenodo.24407221)

> In 139–146 US schools in PISA 2012, socioeconomic status (SES) is the strongest predictor of mathematics achievement, as in Zhang and Wang's (2020) TIMSS 2011 study. Opportunity to learn (OTL) matters more than in TIMSS and depends more on SES, and school information and communication technology (ICT) has no effect on mathematics.
> An exploratory analysis of 96 model specifications (6 achievement outcomes × 4 OTL measures × 2 ICT measures × 2 SES measures) finds that school internet use relates to print reading, and that OTL's role depends on how OTL is measured.
> ICT resources steepen the SES slope for digital reading, but only borderline and not robustly. Across all outcomes, the interaction's sign follows the kind of ICT: positive for resources and negative for use.

![SES × ICT moderation across 6 outcomes and 4 OTL measures, with 95% bootstrap intervals](report/figures/fig1_moderation_all.png)

*Figure 1 of the report: the SES × ICT path in the 48 primary models (SES composite), for 6 achievement outcomes × 4 OTL measures × 2 ICT measures, with 95% bootstrap intervals. Filled points are p < .05. The 48 other models use ESCS, the PISA index of economic, social and cultural status. Rows give the outcome and the OTL measure: FAMCONC = familiarity with mathematical concepts (confirmatory); OTL_PT = exposure to problem types (student questionnaire items ST73–76); EXPUREM and EXAPPLM = experience with pure and with applied mathematics tasks. Model 1 measures ICT by internet use for schoolwork, Model 2 by ICT resources. The full study, with the confirmatory mathematics results, the discussion and the literature, is in [report/report.md](report/report.md).*

## Overview

This repository holds the report, the code and the results of an analogue of Zhang and Wang (2020) on PISA 2012 for the United States (A2). It is laid out as a replication package. The code builds school-level files from the PISA 2012 student and school questionnaires. It then re-estimates the confirmatory SmartPLS models in R, fits the 96 exploratory model specifications, and draws the report's figures. One script, [R/run_all.R](R/run_all.R), runs every automated step and the tests in about 35 minutes on 4 cores. The only manual step, estimating the models in SmartPLS 4, is optional: its outputs are committed.

A replication of the paper itself on the TIMSS 2011 files (A1) is planned and waits for the data. The paper's 120 reported values are already in [results/paper_zhang_wang_2020.csv](results/paper_zhang_wang_2020.csv).

### Repository layout

```
README.md        this file: the replication README
report/          the study
  report.md        question, data and measures, confirmatory mathematics results, exploratory models, moderation, OTL measures, discussion, conclusions
  report.pdf       the same report as a PDF (for the preprint), built from report.md by pdf/build.sh
  figures/         Figure 0 (design flow chart) to Figure 4
  references.bib   the report's references in BibTeX
R/               scripts, and run_all.R, which runs the automated steps in order
docs/            confirmatory spec, exploratory spec, data audit, SmartPLS steps
results/         machine outputs, indexed by results/README.md
data/README.md   data rights, and how to obtain and rebuild the PISA file (the data are not in the repository)
tests/           testthat suite
renv.lock        package versions
CITATION.cff     how to cite (GitHub)
.zenodo.json     metadata for the Zenodo archive (Zenodo reads it instead of CITATION.cff)
CLAUDE.md        rules for Claude Code sessions (commit authorship)
LICENSE          MIT, for the code
LICENSE-report   CC BY 4.0, for the report text and figures
from_code/       working plan and session handoff notes (the project log)
```

## Data availability and provenance statements

### Statement about rights

- [x] The authors have legitimate access to and permission to use the data used in this report.
- [ ] The authors have documented permission to redistribute the data. *Not applicable: the PISA data are not redistributed here. [data/README.md](data/README.md) says how to obtain them.*

### License for data

The PISA 2012 data are © OECD and are used under the OECD's terms. They are not covered by this repository's licences. The 120 values in `results/paper_zhang_wang_2020.csv` are transcribed from Zhang and Wang (2020) for comparison; please cite the paper. The paper's PDF is not included.

### Summary of availability

- [x] All data **are** publicly available.
- [ ] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

### Details on each data source

**PISA 2012, United States (OECD, 2014).** The analysis uses a US extract of the PISA 2012 international database: the student questionnaire file merged with the school questionnaire file by `SCHOOLID`, with 4,978 students in 162 schools. The data are free to download from the PISA 2012 database page on oecd.org. [data/README.md](data/README.md) lists the variables used, how to rebuild the extract, and the checks it must pass (4,978 students, 162 schools, weighted mathematics mean 481.37). The SHA-256 of the file used is in [results/a2/data_manifest.csv](results/a2/data_manifest.csv).

**SmartPLS 4 exports (the authors).** The confirmatory models were estimated by hand in SmartPLS 4, a commercial program (Ringle et al., 2024). Their Excel exports are not in the repository, and their SHA-256 values are in `results/a2*/a2_02_exports_manifest.csv`. The estimates and criteria read from them by `R/a2_02_read_smartpls.R` are committed, so every later step runs without SmartPLS.

**Published values (Zhang & Wang, 2020).** The 120 values reported in Tables 2–3, Figure 2 and section 6.2 of the paper, transcribed by hand: [results/paper_zhang_wang_2020.csv](results/paper_zhang_wang_2020.csv).

**TIMSS 2011 (IEA), for A1.** Not used yet. The A1 replication will download the US Grade 8 files when it runs.

## Dataset list

| Data file | Source | Notes | Provided |
|---|---|---|---|
| `data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav` | OECD PISA 2012, US extract | 4,978 students, 162 schools; 16.7 MB; SHA-256 in `results/a2/data_manifest.csv` | No; see [data/README.md](data/README.md) |
| `data/derived/a2_pisa2012_school.csv`, `a2_smartpls_model1.csv`, `a2_smartpls_model2.csv` | `R/a2_01_prepare_pisa2012.R` | School-level analysis files | No; rebuilt by step 1 |
| `data/raw/smartpls_exports/` | The authors, SmartPLS 4 | Excel exports of the 12 SmartPLS models | No; SHA-256 in `results/a2*/a2_02_exports_manifest.csv` |
| `results/a2*/a2_pisa2012_estimates_user_sav.csv`, `..._sensitivity.csv`, `a2_02_criteria.csv` | `R/a2_02_read_smartpls.R`, from the exports | SmartPLS estimates and criteria | Yes |
| `results/paper_zhang_wang_2020.csv` | Zhang and Wang (2020) | 120 published values, for comparison | Yes |

## Computational requirements

### Software requirements

- **R 4.3.3.** Packages are pinned in [renv.lock](renv.lock), including:
  - haven 2.5.4 and readxl 1.4.3 (reading data);
  - seminr 2.6.0, installed from GitHub at commit `cfc0b30` (Ray et al., 2026);
  - lavaan 0.6-17;
  - ggplot2 3.4.4 and ragg 1.2.7 (figures);
  - testthat 3.2.1.
  
  `Rscript -e 'renv::restore()'` installs them. Where CRAN is blocked, [R/README.md](R/README.md) gives the apt and GitHub route.
- **Inter font**, for the figure labels (rendered by ragg).
- **Optional:**
  - Graphviz, to redraw Figure 0;
  - Python 3 with numpy, pandas and pyreadstat, for the exploratory data audit (`R/a2_00_audit_pisa2012.py`);
  - SmartPLS 4, for the confirmatory models, whose outputs are committed.

### Controlled randomness

- [x] Random seed is set at line 28 of `R/a2_04_seminr_crosscheck.R` and line 20 of `R/a2_05_seminr_runs.R` (20261120). `R/a2_06_moderation_figures.R` uses the same seed through the default in `R/a2_seminr_helpers.R`.
- The SmartPLS models used a fixed seed, but SmartPLS does not export its value.
- The report's results were produced on 4 cores.

### Memory, runtime and storage

- **Runtime:** about 35 minutes on a 4-core Linux machine.
  - Step 1 takes seconds.
  - The cross-checks take about 1 minute each.
  - The 96 exploratory models take about 25 minutes.
  - The figures take about 2 minutes.
- **Storage:** under 25 MB for the PISA file, the derived files and the repository, plus the R package library.
- **Machine:** the code was last run in a 4-core Linux cloud container. Memory use was not measured.

## Description of programs and code

All scripts run from the repository root. [R/README.md](R/README.md) lists them by role and status.

| Program | What it does |
|---|---|
| [R/run_all.R](R/run_all.R) | Runs steps 1–7 below in order |
| [R/a2_01_prepare_pisa2012.R](R/a2_01_prepare_pisa2012.R) | Builds the school-level files and runs data checks D1–D5 |
| [R/a2_02_read_smartpls.R](R/a2_02_read_smartpls.R) | Reads the SmartPLS exports for one outcome, checks criteria M1–M5 and writes its summary (manual step) |
| [R/a2_04_seminr_crosscheck.R](R/a2_04_seminr_crosscheck.R) | Re-estimates the SmartPLS models in R and compares every shared estimate |
| [R/a2_05_seminr_runs.R](R/a2_05_seminr_runs.R) | Fits the 96 exploratory model specifications |
| [R/a2_06_moderation_figures.R](R/a2_06_moderation_figures.R) | Draws Figures 1–4 and computes f², Benjamini–Hochberg q and the simple slopes |
| [R/a2_seminr_helpers.R](R/a2_seminr_helpers.R) | Shared model code, sourced by `a2_04`, `a2_05` and `a2_06` |
| [R/a2_00_audit_pisa2012.py](R/a2_00_audit_pisa2012.py) | Exploratory audit of the PISA file (Python; optional) |
| [report/figures/fig0_design_flowchart.dot](report/figures/fig0_design_flowchart.dot) | Graphviz source of Figure 0 |
| [report/pdf/build.sh](report/pdf/build.sh) | Builds `report/report.pdf` from `report/report.md` (pandoc, then Chromium through Playwright) |
| `tests/testthat/` | Data checks, acceptance criteria, cross-check agreement and completeness of the 96 models |

### License for code

The code is licensed under the MIT License; see [LICENSE](LICENSE). The report text and figures are licensed under CC BY 4.0; see [LICENSE-report](LICENSE-report).

## Instructions to replicators

1. Get the PISA 2012 US extract as described in [data/README.md](data/README.md), and save it as `data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav`.
2. Install R 4.3.3, then run `Rscript -e 'renv::restore()'` from the repository root.
3. Run everything:

   ```bash
   Rscript R/run_all.R
   ```

   - `NBOOT=200 Rscript R/run_all.R` gives a quick check in a few minutes; its numbers are not the report's.
   - `FROM=6 Rscript R/run_all.R` redraws the figures from the committed estimates.
   - `DRY_RUN=1 Rscript R/run_all.R` lists the steps.
4. Optional manual steps:
   - Re-run SmartPLS ([docs/a2_smartpls_steps.md](docs/a2_smartpls_steps.md)), put the exports in `data/raw/smartpls_exports/`, then run `Rscript R/a2_02_read_smartpls.R` with `math`, `reading` or `science`.
   - Redraw Figure 0 with the `dot` commands at the top of [its source](report/figures/fig0_design_flowchart.dot).

| Step in `run_all.R` | Command | Time | Writes |
|---|---|---|---|
| 1. School-level data | `Rscript R/a2_01_prepare_pisa2012.R` | seconds | `data/derived/`; `results/a2/a2_01_*`, `data_manifest.csv` |
| 2–4. R cross-check | `Rscript R/a2_04_seminr_crosscheck.R` with `math`, `reading`, `science` | ~1 min each | `results/a2*/a2_04_*` |
| 5. Exploratory models (96) | `Rscript R/a2_05_seminr_runs.R` | ~25 min on 4 cores | `results/a2_seminr/estimates.csv`, `criteria.csv`, `summary.md` |
| 6. Figures and moderation statistics | `Rscript R/a2_06_moderation_figures.R` | ~2 min | `report/figures/fig1–4`; `results/a2_seminr/moderation_stats.csv`, `simple_slopes.csv` |
| 7. Tests | `Rscript tests/testthat.R` | seconds | none |

The tests skip, rather than fail, where an input does not exist yet (A1, and the OECD parity check).

## List of tables and programs

Numbers refer to [report/report.md](report/report.md).

| Figure or table | Program | Output file | Note |
|---|---|---|---|
| Figure 0 | Graphviz | [report/figures/fig0_design_flowchart.png](report/figures/fig0_design_flowchart.png), `.svg` | Drawn from [fig0_design_flowchart.dot](report/figures/fig0_design_flowchart.dot) |
| Figure 1 | `R/a2_06_moderation_figures.R` | [report/figures/fig1_moderation_all.png](report/figures/fig1_moderation_all.png) | From `results/a2_seminr/estimates.csv` |
| Figure 2 | `R/a2_06_moderation_figures.R` | [report/figures/fig2_simple_slopes.png](report/figures/fig2_simple_slopes.png) | Values in `results/a2_seminr/simple_slopes.csv` |
| Figure 3 | `R/a2_06_moderation_figures.R` | [report/figures/fig3_moderation_robustness.png](report/figures/fig3_moderation_robustness.png) | |
| Figure 4 | `R/a2_06_moderation_figures.R` | [report/figures/fig4_otl_by_measure.png](report/figures/fig4_otl_by_measure.png) | |
| Table 1 | `R/a2_01_prepare_pisa2012.R` builds the measures | [docs/spec.md](docs/spec.md) §3; [docs/spec_exploratory.md](docs/spec_exploratory.md) §2 | Descriptive |
| Table 2 | – | [docs/spec.md](docs/spec.md) §7 | Descriptive |
| Tables 3–4 | `R/a2_02_read_smartpls.R` | [results/a2/summary.md](results/a2/summary.md); `results/a2/a2_pisa2012_estimates_user_sav.csv`, `..._sensitivity.csv` | TIMSS column from `results/paper_zhang_wang_2020.csv` |
| Table 5 | `R/a2_05_seminr_runs.R`, `R/a2_06_moderation_figures.R` | `results/a2_seminr/moderation_stats.csv`; ESCS column from `estimates.csv` | |
| Table 6 | `R/a2_05_seminr_runs.R` | `results/a2_seminr/estimates.csv` (`path_SESxICT_ACH`) | |
| Table 7 | `R/a2_05_seminr_runs.R` | [results/a2_seminr/summary.md](results/a2_seminr/summary.md), "How much the OTL measure matters" | |
| §2.1, data checks | `R/a2_01_prepare_pisa2012.R` | [results/a2/a2_01_checks.csv](results/a2/a2_01_checks.csv) | |
| §3.3, R cross-check | `R/a2_04_seminr_crosscheck.R` | [results/a2/a2_04_seminr_crosscheck.md](results/a2/a2_04_seminr_crosscheck.md), and the same in `a2_reading/`, `a2_science/` | |
| §6.3, power | by hand | – | Inverse square root rule (Kock & Hadaya, 2018) |

[results/README.md](results/README.md) explains the result folders and the `estimate_id` scheme.

## Status

- **A2 (PISA 2012):** the confirmatory mathematics analysis, the R cross-check and the 96 exploratory models are done. Still to do:
  - the parity check against an independent OECD download;
  - pooling across the five plausible values, and a weighted analysis (`R/a2_07`);
  - optional consistent-PLS (PLSc) models.
- **A1 (TIMSS 2011 replication):** waits for the TIMSS 2011 US Grade 8 files.
- **Phase B (multilevel model):** after A1 and A2. Student-level models with cross-level SES × ICT terms are the natural test of the exploratory moderation (report, §8.7).

## References

- Becker, J.-M., Ringle, C. M., & Sarstedt, M. (2018). Estimating moderating effects in PLS-SEM and PLSc-SEM: Interaction term generation × data treatment. *Journal of Applied Structural Equation Modeling, 2*(2), 1–21. https://epub.ub.uni-muenchen.de/96102/
- Kock, N., & Hadaya, P. (2018). Minimum sample size estimation in PLS-SEM: The inverse square root and gamma-exponential methods. *Information Systems Journal, 28*(1), 227–261. https://doi.org/10.1111/isj.12131
- OECD. (2013). *PISA 2012 results: What students know and can do (Volume I)*. OECD Publishing. https://doi.org/10.1787/9789264201118-en
- OECD. (2014). *PISA 2012 technical report*. OECD Publishing. https://www.oecd.org/content/dam/oecd/en/about/programmes/edu/pisa/publications/technical-report/PISA-2012-technical-report-final.pdf
- R Core Team. (2024). *R: A language and environment for statistical computing* (Version 4.3.3). R Foundation for Statistical Computing. https://www.R-project.org/
- Ray, S., Danks, N. P., & Calero Valdez, A. (2026). *seminr: Building and estimating structural equation models* (Version 2.6.0) [R package]. https://github.com/sem-in-r/seminr
- Ringle, C. M., Wende, S., & Becker, J.-M. (2024). *SmartPLS 4*. SmartPLS. https://www.smartpls.com
- Wickham, H. (2016). *ggplot2: Elegant graphics for data analysis*. Springer-Verlag New York. https://ggplot2.tidyverse.org
- Zhang, Y., & Wang, Q. (2020). Content learning opportunities, computer-based instruction, and students' mathematics and science achievement. *International Journal of Mathematical Education in Science and Technology*. https://doi.org/10.1080/0020739X.2020.1717659

The report has the full reference list, also as [BibTeX](report/references.bib).

## Acknowledgements

The data come from the OECD's Programme for International Student Assessment (PISA) 2012. The code and drafts of the report were written with assistance from Claude Code (Anthropic).

## How to cite

Use the metadata in [CITATION.cff](CITATION.cff) (GitHub's "Cite this repository" button), and please also cite Zhang and Wang (2020). The release is archived on Zenodo: [doi:10.5281/zenodo.24407221](https://doi.org/10.5281/zenodo.24407221).

> Wang, Q., & Zhang, Y. (2026). *Opportunity to learn, socioeconomic status and school ICT in US achievement: From TIMSS 2011 to PISA 2012* (Version 0.1.0) [Computer software and report]. Zenodo. https://doi.org/10.5281/zenodo.24407221

Questions and issues: please open a GitHub issue.

## License

Code: MIT ([LICENSE](LICENSE)). Report text and figures: CC BY 4.0 ([LICENSE-report](LICENSE-report)). Data: © OECD, not redistributed.
