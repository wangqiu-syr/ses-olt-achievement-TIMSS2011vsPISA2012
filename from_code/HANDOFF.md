# Handoff — PISA 2012 OTL replication (session 1)

**Done**
- Read Zhang & Wang (2020): data, measures and analysis sections.
- Read the PISA plan doc.
- Audited `US_PISA_2012_STSCH.sav`. Report: `from_code/01_pisa_data_audit.md`. Script: `code/00_data_audit.py`.

**Open decisions (answers needed from Qiu)**
1. OTL measure: ST62/FAMCONC (recommended) or ST73–76 (as in the plan table)?
2. SES measure: ESCS (recommended) or the plan composite?
3. ICT: split into use (SC13) + resources (SC14, RATCMP15) + policy dummy, or keep one 9-item composite?
4. Method and software: two-level model with PVs and weights (Mplus or R), or PLS-SEM to mirror the TIMSS paper?
5. Goal: replicate the model in PISA, or write a formal TIMSS-vs-PISA comparison? A comparison also needs the TIMSS 2011 analysis files.

**Next step**
Once the decisions above are made: build the analysis file with recodes, then run descriptives and the model, with outputs going to `from_code/`.

**Note:** the raw .sav and the PDF are git-ignored. Re-upload them in a new session.
