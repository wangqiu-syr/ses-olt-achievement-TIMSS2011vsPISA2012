# Handoff: scaffold session (2026-11-19)

## Done
- Scaffolded `R/`, `scripts/`, `docs/`, `from_code/` and `tests/`, plus `data/`, which is gitignored from the first commit except `data/README.md`.
- Added `README.md`, `.gitignore` and a placeholder `CITATION.cff`. The MIT `LICENSE` already existed and is unchanged.
- Set up renv: `.Rprofile`, `renv/activate.R` and `renv.lock` (R 4.3.3, renv 1.0.3, testthat 3.2.1 and its dependencies).
- Wrote the testthat skeleton, which runs with `Rscript tests/testthat.R`: 4 pass, 3 skip (waiting on inputs).
  - `tests/reference/zhang_wang_2020_reported.csv` is a template (header only).
  - The A1 test compares `from_code/a1_timss2011_estimates.csv` against it, within printed precision.
  - The A2 tests check parity between the two PISA copies, and hold a placeholder for the `docs/spec.md` criteria.
- Network test, recorded in `from_code/plan.md`: the TIMSS (bc.edu, iea.nl), OECD and CRAN hosts are all **blocked**. apt and GitHub are reachable.

## Open
1. Data access. Either allowlist timssandpirls.bc.edu, www.iea.nl, www.oecd.org, webfs.oecd.org and cloud.r-project.org in Network access, or upload the files listed in `plan.md`.
2. Zhang & Wang (2020): the paper (PDF or full reference) is needed for the countries, variables, model and reported numbers. `CITATION.cff` has TODOs for it.
3. Confirm TIMSS Grade 8 (assumed, to pair with PISA's 15-year-olds).
4. `docs/spec.md` (A2 acceptance criteria) is not written yet.
5. The user's PISA 2012 `.sav` must be uploaded to `data/raw/pisa2012/user_sav/` for A2.
6. The sandbox is ephemeral. Each new session must reinstall R with
   `apt-get install -y r-base-core r-cran-renv r-cran-testthat`, plus the `r-cran-*` model packages.
   A setup script in the environment would automate this.

## Next step
A1 session: resolve open items 1 and 2. Then enter the paper's numbers in the reference CSV and write `scripts/a1_01_get_timss2011.R`.
