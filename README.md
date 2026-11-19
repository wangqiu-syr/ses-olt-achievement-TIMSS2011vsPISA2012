# SES, opportunity to learn, and math/science achievement: TIMSS 2011 vs PISA 2012

Replication and extension code, in R.

- **A1:** replicate Zhang & Wang (2020) on TIMSS 2011.
- **A2:** fit the analogous model on PISA 2012.
- **Phase B:** choose and run the multilevel model (after a gate review).

See `from_code/plan.md` for the plan and `from_code/handoff.md` for current status.
**Status:** scaffold only; no analysis yet.

## Layout

| Path | Contents |
|---|---|
| `R/` | reusable functions |
| `scripts/` | numbered pipeline steps (`Rscript scripts/<file>.R`) |
| `docs/` | documentation; `docs/spec.md` will hold the A2 acceptance criteria |
| `from_code/` | reports, results tables, plan and handoff notes written by Code |
| `tests/` | testthat suite comparing replication results with the paper's numbers |
| `data/` | raw and derived data. Gitignored; see `data/README.md` |
| `renv.lock`, `renv/`, `.Rprofile` | pinned R package environment |

## Setup

```r
# From the project root. .Rprofile activates renv automatically.
renv::restore()
```

The lockfile was created with R 4.3.3. Inside the Claude Code sandbox, CRAN is
currently blocked. There, R and packages come from Ubuntu apt (`r-base-core`,
`r-cran-*`), and `renv::hydrate()` copies them into the project library.

## Data

Raw TIMSS and PISA files are never committed. `data/README.md` explains how
they are supplied and where they go.

## Tests

```sh
Rscript tests/testthat.R
```

`tests/reference/zhang_wang_2020_reported.csv` holds the values reported in the
paper, one row per number (still empty). The A1 test compares
`from_code/a1_timss2011_estimates.csv` against it, within the precision the
paper printed. The A2 tests check that the user's PISA `.sav` and the OECD
download give the same estimates, then check the criteria in `docs/spec.md`.
Each test skips until its inputs exist.

## License

MIT (see `LICENSE`). Citation metadata: `CITATION.cff` (placeholder).
