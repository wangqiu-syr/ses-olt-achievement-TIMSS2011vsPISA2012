# data/

Everything in this folder except this README is gitignored (see `/.gitignore`).
Raw survey files are never committed. They are licensed by IEA and OECD and are
too large for git.

## Expected layout

```
data/
  raw/
    timss2011/            TIMSS 2011 Grade 8 international database, SPSS (.sav)
    pisa2012/
      user_sav/           the user's own PISA 2012 .sav file(s)
      oecd/               PISA 2012 files downloaded by Code from OECD
    docs/                 the paper PDF and the user's PISA plan (.docx)
    smartpls_exports/     the user's SmartPLS 4 Excel exports (A2); any subfolders, e.g. reading/, science/.
                          R/a2_02 matches exports to runs by content, not file name.
  derived/                analysis files written by the R/ scripts (rebuildable)
```

## How raw data are supplied

| Source | Supplied by | How |
|---|---|---|
| TIMSS 2011 (A1) | Code | An `R/` script downloads from timssandpirls.bc.edu or the IEA Data Repository. If the sandbox blocks those hosts, the user uploads the files listed in `from_code/plan.md`. No user copy exists. |
| PISA 2012, user copy (A2) | User | Upload the raw `.sav` into `data/raw/pisa2012/user_sav/`. |
| PISA 2012, independent copy (A2) | Code | An `R/` script downloads from oecd.org into `data/raw/pisa2012/oecd/`. If blocked, the user uploads the OECD originals (see plan.md). |

## The PISA 2012 file used here

`data/raw/pisa2012/user_sav/US_PISA_2012_STSCH.sav` is a **US extract of the PISA 2012 international database**: the student questionnaire file merged with the school questionnaire file by `SCHOOLID`, with 4,978 students in 162 schools. The project uses these variables:
- student: `W_FSTUWT`, `ST28Q01`, `HISCED`, `HOMEPOS`, `ESCS`, `FAMCONC`, `EXPUREM`, `EXAPPLM`, `ST73Q01`–`ST76Q02`, and the PVs for `MATH`, `READ`, `SCIE`, `CREA`, `CMAT`, `CPRO`;
- school: `SC13Q01`–`03`, `SC14Q07`–`09`, `RATCMP15`, `cSC40Q01`, `W_FSCHWT`.

Its SHA-256 is in `results/a2/data_manifest.csv`.

**To rebuild it**, download the PISA 2012 student and school questionnaire data files from the OECD PISA 2012 database page. Keep `CNT == "USA"`, merge school onto student records by `SCHOOLID`, and save as SPSS. Then check it against `results/a2/a2_01_checks.csv`: `R/a2_01` must report 4,978 students, 162 schools and a weighted math mean of 481.37. The data are © OECD and used under the OECD terms; they are not redistributed here.

## Provenance

For every raw file it reads, Code records the file name, size, SHA-256 and
source URL (or "user upload") in `results/a2/data_manifest.csv`. That file is
committed, so later runs can show they used identical inputs.

Sandbox sessions are ephemeral, so files placed here are lost when the
container is reclaimed. Re-supply them, or re-run the download scripts, in each
new session.
