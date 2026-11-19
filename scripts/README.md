# scripts/

Numbered, runnable pipeline steps, executed from the project root with
`Rscript scripts/<file>.R`. Planned (not yet written):

- `a1_01_get_timss2011.R`: download (or locate uploaded) TIMSS 2011 files and write the manifest
- `a1_02_prepare_timss2011.R`: build the analysis file
- `a1_03_model_timss2011.R`: replicate Zhang & Wang (2020); write `from_code/a1_timss2011_estimates.csv`
- `a2_00_audit_pisa2012.py`: exploratory audit of the user's PISA .sav against the OTL plan (done; Python); report in `from_code/a2_00_pisa2012_data_audit.md`
- `a2_00_audit_pisa2012.py`: exploratory data audit (written)
- `a2_01_prepare_pisa2012.R`: school-level files for SmartPLS, plus data checks (written)
- `a2_02_parity_pisa2012.R`: fit the same model on both copies; write the parity CSVs (waits on OECD access)
- `a2_03_model_pisa2012.R`: scripted `seminr` cross-check, checked against `docs/spec.md` (waits on CRAN)
- `b_*`: multilevel model (Phase B, after the gate)
