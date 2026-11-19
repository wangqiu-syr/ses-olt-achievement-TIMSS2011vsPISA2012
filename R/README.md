# R/

All project code. Run each script from the repository root, e.g. `Rscript R/a2_01_prepare_pisa2012.R`.
Prefixes give the phase (`a1_` TIMSS 2011, `a2_` PISA 2012, `b_` multilevel) and the step order.

| Script | Role | Status |
|---|---|---|
| `a2_00_audit_pisa2012.py` | Exploratory audit of the PISA file against the paper and the variable plan (Python, the only non-R file) | done |
| `a2_01_prepare_pisa2012.R` | Builds the school-level SmartPLS files (`data/derived/`) and data checks D1–D5 (`results/a2/`) | done |
| `a2_02_read_smartpls.R` | Reads the SmartPLS exports, checks criteria M1–M5 and writes `results/a2/summary.md` | done |
| `a2_03_parity_pisa2012.R` | Same model on the user's `.sav` and the OECD download; writes the parity CSVs | waits on OECD access |
| `a2_04_model_pisa2012.R` | Scripted `seminr` cross-check, per-PV pooling and weighted run | waits on CRAN |
| `a1_*` | Get TIMSS 2011, build the teacher-level file, replicate the paper; writes `results/a1/` | waits on TIMSS files |
| `b_*` | Multilevel model (Phase B) | after the gate |
