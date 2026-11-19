# Plan: SES/OTL and math/science achievement, TIMSS 2011 vs PISA 2012
Each phase ends with a report in `results/` and green tests (`Rscript tests/testthat.R`).

**A1: Replicate Zhang & Wang (2020) on TIMSS 2011.** Code downloads the data (no user copy exists).
Enter the paper's numbers in `results/paper_zhang_wang_2020.csv`, then fit the model.
Done when `results/a1/a1_timss2011_estimates.csv` passes the A1 test.

**A2: Analogous model on PISA 2012.**
1. Parity: fit the same model on the user's raw `.sav` and on Code's own OECD download. Estimates must match (A2 parity test).
2. Run the model against the acceptance criteria in `docs/spec.md` (section 6).

Order changed 2026-11-19: A2 runs first while the TIMSS files are pending; the parity check waits for OECD access (`docs/spec.md`, section 1).
**Gate.** The user reviews the A1 and A2 reports and approves before Phase B starts.

**Phase B: Multilevel model.** Choose the specification (levels, weights, plausible values), record the choice in `docs/spec.md`, run it, report.

## Sandbox network test (2026-11-19)
| Host | Result |
|---|---|
| timssandpirls.bc.edu (TIMSS 2011 IDB) | **blocked** (proxy 403) |
| www.iea.nl (IEA Data Repository) | **blocked** (proxy 403) |
| www.oecd.org, webfs.oecd.org (PISA 2012) | **blocked** (proxy 403) |
| cloud.r-project.org, packagemanager.posit.co (CRAN) | **blocked** (proxy 403) |
| archive.ubuntu.com (apt), github.com | reachable |

Fix option 1: allowlist these hosts under the environment's Network access (https://code.claude.com/docs/en/cloud-environments#network-access); Code then downloads itself. Until then, R packages come from apt (`r-cran-*`, R 4.3.3).

## Option 2: files the user must upload (TIMSS blocked)
Into `data/raw/timss2011/`. TIMSS 2011 **Grade 8** International Database, SPSS format.
`<cnt>` = lowercase 3-letter code (e.g. `usa`) for each country in Zhang & Wang (2020):
- `bsg<cnt>m5.sav`: student background, with plausible values and weights
- `bst<cnt>m5.sav`: student-teacher linkage
- `btm<cnt>m5.sav`: mathematics teacher background (OTL topic coverage)
- `bts<cnt>m5.sav`: science teacher background (OTL topic coverage)
- `bcg<cnt>m5.sav`: school background
- Recommended: the TIMSS 2011 IDB User Guide, Supplement 1 (questionnaires) and Supplement 3 (derived variables), as PDFs. Or upload the full Grade 8 SPSS zip(s) as downloaded.

PISA 2012 (A2 parity) is also blocked. Either allowlist the OECD hosts, or upload the OECD originals into `data/raw/pisa2012/oecd/`.
That means the student file `INT_STU12_DEC03.zip` and its SPSS control file, and `INT_SCQ12_DEC03.zip` if school variables are needed. Confirm the names on the OECD page.
