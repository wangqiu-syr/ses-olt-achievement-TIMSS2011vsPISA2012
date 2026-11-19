# scripts/

Numbered, runnable pipeline steps, executed from the project root with
`Rscript scripts/<file>.R`. Planned (not yet written):

- `a1_01_get_timss2011.R`: download (or locate uploaded) TIMSS 2011 files and write the manifest
- `a1_02_prepare_timss2011.R`: build the analysis file
- `a1_03_model_timss2011.R`: replicate Zhang & Wang (2020); write `from_code/a1_timss2011_estimates.csv`
- `a2_01_get_pisa2012.R`: download PISA 2012 from OECD and locate the user's .sav
- `a2_02_parity_pisa2012.R`: fit the same model on both copies; write the parity CSVs
- `a2_03_model_pisa2012.R`: analogous model, checked against `docs/spec.md`
- `b_*`: multilevel model (Phase B, after the gate)
