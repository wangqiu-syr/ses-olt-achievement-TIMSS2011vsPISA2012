# EdArXiv submission: form answers (2026-11-20)

Copy these into osf.io → EdArXiv → Add a preprint. The user settled the judgement calls on 2026-11-20.

## File
`report/report.pdf` (19 pages, US Letter, fonts embedded). Rebuild it with `bash report/pdf/build.sh` after any change to `report/report.md`. Its links to repository files point to tag `v0.1.0`.

## Title
Opportunity to learn, socioeconomic status and school ICT in US achievement: from TIMSS 2011 to PISA 2012

## Abstract
Zhang and Wang (2020) modeled US Grade 8 achievement in TIMSS 2011 with three parts: content coverage as opportunity to learn (OTL), family socioeconomic status (SES), and classroom computer use, a form of information and communication technology (ICT), as a moderator of SES. We fit an analogue of their model to PISA 2012 for the United States, at school level (139–146 schools). In the confirmatory mathematics analysis, SES stays the strongest predictor (.53–.55, against .64–.65 in TIMSS). OTL matters more than in TIMSS (.37–.38 against .20–.21) and depends more on SES (.52–.61 against .12–.13). School ICT has no effect on mathematics and does not moderate SES. Every model meets the pre-set measurement criteria, and an independent re-estimation in R reproduces all 12 SmartPLS models. An exploratory analysis then fits 96 model specifications: 6 achievement outcomes × 4 OTL measures × 2 ICT measures × 2 SES measures. School internet use for schoolwork relates to print reading. ICT resources steepen the SES slope for digital reading (.11–.13), but only borderline, and not robustly. Across all outcomes, the sign of the SES × ICT interaction follows the kind of ICT: positive for resources and negative for use. We offer this as a hypothesis for better-powered designs. Finally, OTL's role depends on how OTL is measured.

## Authors (in this order, both bibliographic)
1. Qiu Wang, Syracuse University, ORCID 0000-0003-1635-8050 (the submitter).
2. Yue Zhang, Google, ORCID 0000-0002-9070-9990. Add Yue by OSF user search, or as an unregistered contributor with an email address. OSF then emails an invitation.

## Subjects
Pick from the EdArXiv list. This session couldn't load the list, so the names below may differ slightly; choose the closest match:
- Education → Educational Assessment, Evaluation, and Research
- Education → Science and Mathematics Education
- Education → Educational Technology
- a quantitative-methods subject, if the list has one (e.g. under Social and Behavioral Sciences)

## Tags (same as the keywords in `CITATION.cff` and `.zenodo.json`)
opportunity to learn · socioeconomic status · ICT · moderation · PISA 2012 · TIMSS 2011 · PLS-SEM · achievement · digital reading · STEM

(The user dropped "replication" and added the last three on 2026-11-20.)

## Licence
CC BY 4.0 (CC-By Attribution 4.0 International), matching `LICENSE-report`.

## Links and author assertions
- **Data and code:** Zenodo DOI 10.5281/zenodo.24407221 (the v0.1.0 archive, which the report matches) and https://github.com/wangqiu-syr/ses-olt-achievement-TIMSS2011vsPISA2012.
- **Public data:** suggested answer "Available", with the two links above. Suggested description: "Code, estimates and figures are archived on Zenodo and GitHub. The PISA 2012 data are © OECD and public, but not redistributed. data/README.md in the repository says how to obtain and rebuild the extract."
- **Preregistration:** No (the user's decision). The confirmatory plan (`docs/spec.md`) was written before the results were read but not registered.
- **Conflict of interest:** None (the user's decision). There is no funding, and the study evaluates no product.
- **Published in a journal?** No.

## Citations

### OSF fields "Publication DOI" and "Publication citation"
These fields are for a version already published elsewhere, usually a peer-reviewed journal article, and OSF shows them on the preprint page as that published version. **Recommended: leave both empty.** The report has no journal version yet, and the Zenodo archive is already linked as data and code.

When a journal publishes the paper, edit the preprint on OSF and fill in both fields with the journal's DOI and citation.

If you still want to point to the Zenodo archive here, use the same citation as the README:

> Wang, Q., & Zhang, Y. (2026). *Opportunity to learn, socioeconomic status and school ICT in US achievement: From TIMSS 2011 to PISA 2012* (Version 0.1.0) [Computer software and report]. Zenodo. https://doi.org/10.5281/zenodo.24407221

### Citation of the preprint itself
OSF generates APA, MLA and Chicago citations on the preprint page from the form, so enter the names as "Qiu Wang" and "Yue Zhang" and the title exactly as above. Once moderation gives the DOI (EdArXiv DOIs start `10.35542/osf.io/`), the citation is:

> Wang, Q., & Zhang, Y. (2026). *Opportunity to learn, socioeconomic status and school ICT in US achievement: From TIMSS 2011 to PISA 2012* [Preprint]. EdArXiv. https://doi.org/10.35542/osf.io/XXXXX

```bibtex
@misc{wang2026otl,
  author    = {Wang, Qiu and Zhang, Yue},
  title     = {Opportunity to learn, socioeconomic status and school {ICT} in {US} achievement: From {TIMSS} 2011 to {PISA} 2012},
  year      = {2026},
  publisher = {EdArXiv},
  note      = {Preprint},
  doi       = {10.35542/osf.io/XXXXX}
}
```

Replace `XXXXX` with the real identifier, keeping any version suffix such as `_v1`. The README's "How to cite" will then give two citations: the preprint for the report, and Zenodo for the code and results.

## After moderation (a day or two)
Send the preprint DOI to a Code session. It will:
- add the DOI to the README ("How to cite", with the preprint citation above), the report's byline and "Data and code availability", and `CITATION.cff`/`.zenodo.json` as a related identifier;
- rebuild the PDF.

Then on Zenodo, edit the record's metadata and add the preprint DOI under "Related works" (e.g. "Is supplement to"). Editing metadata does not need a new version.
