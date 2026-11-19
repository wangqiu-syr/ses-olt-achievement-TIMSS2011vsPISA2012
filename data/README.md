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

## Provenance

For every raw file it reads, Code records the file name, size, SHA-256 and
source URL (or "user upload") in `results/a2/data_manifest.csv`. That file is
committed, so later runs can show they used identical inputs.

Sandbox sessions are ephemeral, so files placed here are lost when the
container is reclaimed. Re-supply them, or re-run the download scripts, in each
new session.
