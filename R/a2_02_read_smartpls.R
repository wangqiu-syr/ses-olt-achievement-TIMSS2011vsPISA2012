# A2 step 2: read the user's SmartPLS 4 exports for one outcome, check criteria M1-M4
# (docs/spec.md section 6), and write the estimates and a report. Run from the project root:
#   Rscript R/a2_02_read_smartpls.R            # math (default)  -> results/a2/
#   Rscript R/a2_02_read_smartpls.R reading    # print reading   -> results/a2_reading/
#   Rscript R/a2_02_read_smartpls.R science    # science         -> results/a2_science/
#   Rscript R/a2_02_read_smartpls.R digital    # digital reading -> results/a2_digital/
#
# Exports are found by content, not by file name. Every .xlsx under data/raw/smartpls_exports/
# (subfolders included) is classified by:
#   outcome  the construct the paths end in: MATH, READ, SCIE or CREA
#   model    ICTUSE_ construct = M1 (ICT use); ICTRES_ = M2 (ICT resources)
#   run      SES indicator: the SES composite = primary, ESCS = escs
#   kind     bootstrap if the export has a "Samples" setting, else algorithm
#
# Inputs  data/raw/smartpls_exports/**/*.xlsx              (user uploads, gitignored)
#         data/derived/a2_smartpls_model2.csv              (from a2_01; RATCMP15 check, skipped if absent)
#         results/paper_zhang_wang_2020.csv
#         results/a2/a2_pisa2012_estimates_*.csv           (reading/science: the math anchor)
# Outputs <dir>/a2_pisa2012_estimates_user_sav.csv    primary runs (spec M5)
#         <dir>/a2_pisa2012_estimates_sensitivity.csv ESCS runs
#         <dir>/a2_02_criteria.csv                    M1-M4 per run
#         <dir>/a2_02_exports_manifest.csv            the exports used, with SHA-256 and classification
#         <dir>/summary.md                            report
# where <dir> is results/a2 (math), results/a2_reading, results/a2_science or results/a2_digital.

suppressMessages(library(readxl))
args    <- commandArgs(trailingOnly = TRUE)
outcome <- if (length(args)) tolower(args[1]) else "math"
cfg <- list(  # tag = the reference CSV's subject key; lv = the outcome construct in SmartPLS
  math    = list(tag = "math", lv = "MATH", label = "Math",    dir = "results/a2"),
  reading = list(tag = "read", lv = "READ", label = "Reading", dir = "results/a2_reading"),
  science = list(tag = "sci",  lv = "SCIE", label = "Science", dir = "results/a2_science"),
  digital = list(tag = "dig",  lv = "CREA", label = "Digital reading", dir = "results/a2_digital")
)
if (!outcome %in% names(cfg)) stop("Outcome must be one of: ", toString(names(cfg)))
oc   <- cfg[[outcome]]
xdir <- "data/raw/smartpls_exports"

# ---- sheet helpers ---------------------------------------------------------
read_sheet <- function(path) {
  m <- as.matrix(read_excel(path, sheet = "complete", col_names = FALSE, .name_repair = "minimal"))
  m[is.na(m)] <- ""; m
}
blank   <- function(m, i) all(m[i, ] == "")
# Rows from `from` until the next blank row.
block   <- function(m, from) { to <- from; while (to <= nrow(m) && !blank(m, to)) to <- to + 1; if (to == from) integer(0) else from:(to - 1) }
find1   <- function(m, col1, after = 1, col2 = NULL) {
  i <- which(m[, 1] == col1 & seq_len(nrow(m)) >= after)
  if (!is.null(col2)) i <- i[m[i, 2] == col2]
  if (!length(i)) stop("Not found: ", col1); i[1]
}
# List header: title in column 2 with an empty column 1 (SmartPLS export layout).
find2   <- function(m, col2, after = 1) {
  i <- which(m[, 1] == "" & m[, 2] == col2 & seq_len(nrow(m)) >= after)
  if (!length(i)) stop("Not found: ", col2); i[1]
}
# Table whose column-header row has `hdr2` in column 2 (first such row after `after`).
table_after <- function(m, hdr2, after = 1, hdr3 = NULL) {
  i <- which(m[, 2] == hdr2 & seq_len(nrow(m)) >= after & m[, 1] == "")
  if (!is.null(hdr3)) i <- i[m[i, 3] == hdr3]
  i <- i[1]; rows <- block(m, i + 1)
  out <- m[rows, , drop = FALSE]; colnames(out) <- m[i, ]; colnames(out)[1] <- "name"; out
}
num <- function(x) suppressWarnings(as.numeric(x))

# Construct names -> paper keys.
key <- function(x) {
  x <- trimws(x)
  x <- gsub("^ICT[A-Z]*_? x (SES|ESCS)$", "SESxICT", x)
  x <- gsub("^ICT[A-Z]*_?$", "ICT", x)
  x <- gsub("^ESCS$", "SES", x)
  gsub("^(MATH|READ|SCIE|CREA)$", "ACH", x)
}
path_id <- function(p) { ab <- strsplit(p, " -> ", fixed = TRUE)[[1]]; paste0("path_", key(ab[1]), "_", key(ab[2])) }

# ---- find and classify the exports -----------------------------------------
classify <- function(m) {
  x  <- m[, 1]
  lv <- unique(sub("^.* -> ", "", grep(" -> (MATH|READ|SCIE|CREA)$", x, value = TRUE)))
  data.frame(lv    = if (length(lv) == 1) lv else NA_character_,
             model = if (any(grepl("^ICTUSE", x))) "M1" else if (any(grepl("^ICTRES", x))) "M2" else NA_character_,
             run   = if (any(grepl("^ESCS <- ", x))) "escs" else "primary",
             kind  = if (any(x == "Samples")) "boot" else "algo",
             stringsAsFactors = FALSE)
}
files  <- sort(list.files(xdir, pattern = "\\.xlsx$", recursive = TRUE, full.names = TRUE, ignore.case = TRUE))
sheets <- lapply(files, read_sheet)
cls    <- cbind(file = files, do.call(rbind, lapply(sheets, classify)), stringsAsFactors = FALSE)
use    <- which(cls$lv %in% oc$lv)
if (!length(use)) stop("No SmartPLS exports for ", outcome, " under ", xdir)
dup <- duplicated(cls[use, c("model", "run", "kind")])
if (any(dup)) stop("Two exports classify as the same run: ", toString(cls$file[use][dup]))
pick <- function(model, run, kind) {
  i <- use[cls$model[use] == model & cls$run[use] == run & cls$kind[use] == kind]
  if (length(i)) i else NA_integer_
}
runs <- expand.grid(run = c("primary", "escs"), model = c("M1", "M2"), stringsAsFactors = FALSE)[, 2:1]
runs$algo <- mapply(pick, runs$model, runs$run, "algo")
runs$boot <- mapply(pick, runs$model, runs$run, "boot")
missing_runs <- paste(runs$model, runs$run, sep = "_")[is.na(runs$algo) | is.na(runs$boot)]
runs <- runs[!is.na(runs$algo) & !is.na(runs$boot), ]
if (!nrow(runs)) stop("No complete run (algorithm + bootstrap) for ", outcome)
dir.create(oc$dir, showWarnings = FALSE, recursive = TRUE)

# ---- extract one run ---------------------------------------------------------
extract <- function(r) {
  a <- sheets[[r$algo]]; b <- sheets[[r$boot]]
  pre <- paste0(r$model, "_", oc$tag, "_")
  rows <- list()
  add <- function(id, est, se = NA, p = NA, lo = NA, hi = NA)
    rows[[length(rows) + 1]] <<- data.frame(estimate_id = paste0(pre, id), estimate = est,
                                            se = se, p_value = p, ci_low = lo, ci_high = hi)
  # paths (bootstrap table carries O, STDEV, p; CI table carries 2.5/97.5%)
  pt <- table_after(b, "Original sample (O)", find1(b, "Path coefficients"), "Sample mean (M)")
  ci <- table_after(b, "Original sample (O)", find1(b, "Confidence intervals"), "Sample mean (M)")
  for (k in seq_len(nrow(pt))) {
    j <- match(pt[k, "name"], ci[, "name"])
    add(path_id(pt[k, "name"]), num(pt[k, 2]), num(pt[k, "Standard deviation (STDEV)"]),
        num(pt[k, "P values"]), num(ci[j, "2.5%"]), num(ci[j, "97.5%"]))
  }
  paths <- do.call(rbind, rows)$estimate
  # specific indirect effects (via OTL) and total effects of SES and ICT on the outcome
  effects <- function(title, prefix, keep) {
    if (!any(b[, 1] == title)) return(invisible())
    s  <- find1(b, title)
    et <- table_after(b, "Original sample (O)", s, "Sample mean (M)")
    ec <- table_after(b, "Original sample (O)", find1(b, "Confidence intervals", s), "Sample mean (M)")
    for (k in seq_len(nrow(et))) {
      id <- paste0(prefix, paste(key(strsplit(et[k, "name"], " -> ", fixed = TRUE)[[1]]), collapse = "_"))
      if (!id %in% keep) next
      j <- match(et[k, "name"], ec[, "name"])
      add(id, num(et[k, 2]), num(et[k, "Standard deviation (STDEV)"]), num(et[k, "P values"]),
          num(ec[j, "2.5%"]), num(ec[j, "97.5%"]))
    }
  }
  effects("Specific indirect effects", "ind_", c("ind_SES_OTL_ACH", "ind_ICT_OTL_ACH"))
  effects("Total effects", "tot_", c("tot_SES_ACH", "tot_ICT_ACH"))
  # R-square (algorithm) + bootstrap p
  r2 <- table_after(a, "R-square", 1, "R-square adjusted")
  r2b <- table_after(b, "Original sample (O)", find1(b, "R-square", find1(b, "Quality criteria")), "Sample mean (M)")
  for (k in seq_len(nrow(r2))) add(paste0("r2_", key(r2[k, "name"])), num(r2[k, 2]),
                                   p = num(r2b[match(r2[k, "name"], r2b[, "name"]), "P values"]))
  # reliability / validity (reflective, multi-item constructs only)
  rel <- table_after(a, "Cronbach's alpha")
  for (k in seq_len(nrow(rel))) { c0 <- key(rel[k, "name"])
    add(paste0("alpha_", c0), num(rel[k, "Cronbach's alpha"]))
    add(paste0("rhoa_", c0),  num(rel[k, "Composite reliability (rho_a)"]))
    add(paste0("rhoc_", c0),  num(rel[k, "Composite reliability (rho_c)"]))
    add(paste0("ave_", c0),   num(rel[k, "Average variance extracted (AVE)"])) }
  # outer loadings
  ol <- a[block(a, find2(a, "Outer loadings", find1(a, "List", find1(a, "Outer loadings"))) + 1), , drop = FALSE]
  for (k in seq_len(nrow(ol))) { nm <- strsplit(ol[k, 1], " <- | -> ")[[1]][1]
    if (grepl("^ICT", nm) && !grepl(" x ", nm)) add(paste0("loading_", nm), num(ol[k, 2])) }
  # HTMT list
  ht <- a[block(a, find2(a, "Heterotrait-monotrait ratio (HTMT)", find1(a, "Heterotrait-monotrait ratio (HTMT) - List")) + 1), , drop = FALSE]
  for (k in seq_len(nrow(ht))) { ab <- key(strsplit(ht[k, 1], " <-> ", fixed = TRUE)[[1]])
    add(paste0("htmt_", paste(sort(ab), collapse = "_")), num(ht[k, 2])) }
  # Fornell-Larcker: diagonal sqrt(AVE) vs. off-diagonal latent correlations
  fl_i <- find1(a, "Fornell-Larcker criterion") + 2
  fl <- a[block(a, fl_i + 1), , drop = FALSE]
  fl_ok <- TRUE
  for (k in seq_len(nrow(fl))) for (j in 2:(k + 1)) {
    v <- num(fl[k, j]); if (is.na(v)) next
    if (j - 1 == k) next
    dk <- num(fl[k, k + 1]); dj <- num(fl[j - 1, j])
    if (abs(v) >= dk || abs(v) >= dj) fl_ok <- FALSE
  }
  # inner VIF list
  vf <- a[block(a, find2(a, "VIF", find1(a, "Inner model - List")) + 1), , drop = FALSE]
  vifs <- num(vf[, 2])
  for (k in seq_len(nrow(vf))) add(paste0("vif_", sub("^path_", "", path_id(vf[k, 1]))), vifs[k])
  # latent variable correlations (paper Table 2 analogue)
  lc_i <- find1(a, "Correlations", find1(a, "Latent variables"))
  lc_h <- a[lc_i + 2, ]; lc <- a[block(a, lc_i + 3), , drop = FALSE]
  pairs <- list(c("SES", "OTL"), c("SES", "ICT"), c("SES", "ACH"), c("OTL", "ICT"), c("OTL", "ACH"), c("ICT", "ACH"))
  hk <- key(lc_h); rk <- key(lc[, 1])
  for (p in pairs) add(paste0("cor_", p[1], "_", p[2]), num(lc[match(p[1], rk), match(p[2], hk)]))
  # fit: SRMR (estimated model) and the paper's APC / ARS / AVIF
  sr <- which(a[, 1] == "SRMR")[1]
  add("fit_SRMR", num(a[sr, 3]))
  add("fit_APC",  mean(abs(paths)))
  add("fit_ARS",  mean(num(r2[, 2])))
  add("fit_AVIF", mean(vifs))
  # latent scores (for the RATCMP15 cross-loading check)
  sc_i <- find1(a, "Scores", find1(a, "Latent variables")) + 2
  sc <- a[block(a, sc_i + 1), , drop = FALSE]; colnames(sc) <- key(a[sc_i, ])
  settings <- c(data = a[which(a[, 1] == "Data file")[2], 2],
                weighting = a[which(a[, 1] == "Weighting vector")[1], 2],
                scheme = a[which(a[, 1] == "Weighting scheme")[1], 2],
                ci = b[which(b[, 1] == "Confidence interval method")[1], 2],
                samples = b[which(b[, 1] == "Samples")[1], 2],
                seed = b[which(b[, 1] == "Seed")[1], 2],
                ses_indicator = if (any(grepl("^ESCS <- ", a[, 1]))) "ESCS" else "SES")
  list(est = do.call(rbind, rows), fl_ok = fl_ok, scores = sc, settings = settings, n = nrow(sc))
}

res <- lapply(seq_len(nrow(runs)), function(i) extract(runs[i, ]))
names(res) <- paste(runs$model, runs$run, sep = "_")

# ---- criteria M1-M4 per run ----------------------------------------------------
get <- function(e, pat) e$estimate[grepl(pat, e$estimate_id)]
crit <- do.call(rbind, lapply(names(res), function(nm) {
  e <- res[[nm]]$est
  ld <- get(e, "_loading_"); rel <- c(get(e, "_alpha_"), get(e, "_rhoc_"))
  data.frame(run = nm, n_schools = res[[nm]]$n,
    M1_min_loading = round(min(ld), 3),
    M1_pass = all(ld >= .70) || (all(ld >= .40) && all(get(e, "_rhoc_") >= .70) && all(get(e, "_ave_") >= .50)),
    M2_min_alpha_rhoc = round(min(rel), 3), M2_min_ave = round(min(get(e, "_ave_")), 3),
    M2_pass = all(rel >= .70) && all(get(e, "_ave_") >= .50),
    M3_max_htmt = round(max(get(e, "_htmt_")), 3), M3_fornell_larcker = res[[nm]]$fl_ok,
    M3_pass = all(get(e, "_htmt_") < .85) && res[[nm]]$fl_ok,
    M4_max_inner_vif = round(max(get(e, "_vif_")), 3), M4_pass = all(get(e, "_vif_") < 3.3))
}))
utils::write.csv(crit, file.path(oc$dir, "a2_02_criteria.csv"), row.names = FALSE)

# ---- estimate files (spec M5) --------------------------------------------------
rnd <- function(df) { df[-1] <- lapply(df[-1], function(x) signif(x, 6)); df }
prim <- do.call(rbind, lapply(res[runs$run == "primary"], `[[`, "est"))
sens <- do.call(rbind, lapply(names(res)[runs$run == "escs"], function(nm) cbind(run = "escs", res[[nm]]$est)))
utils::write.csv(rnd(prim), file.path(oc$dir, "a2_pisa2012_estimates_user_sav.csv"), row.names = FALSE)
if (!is.null(sens)) {
  sens[-(1:2)] <- lapply(sens[-(1:2)], function(x) signif(x, 6))
  utils::write.csv(sens, file.path(oc$dir, "a2_pisa2012_estimates_sensitivity.csv"), row.names = FALSE)
}

# ---- RATCMP15 check (the with-ratio run was not exported) ----------------------
m2_file <- "data/derived/a2_smartpls_model2.csv"
r_ratio <- NA_real_
if (outcome == "math" && !file.exists(m2_file))  # the math report cites this check
  stop(m2_file, " not found: run R/a2_01_prepare_pisa2012.R first")
if ("M2_primary" %in% names(res) && file.exists(m2_file)) {
  m2 <- utils::read.csv(m2_file)
  ict_score <- num(res$M2_primary$scores[, "ICT"])
  stopifnot(length(ict_score) == nrow(m2))
  r_ratio <- stats::cor(m2$ICTRES_RATIO, ict_score)
}

# ---- report helpers ------------------------------------------------------------
ref <- utils::read.csv("results/paper_zhang_wang_2020.csv", comment.char = "#", stringsAsFactors = FALSE)
f2 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 2))
pstar <- function(p) ifelse(is.na(p), "", ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", ""))))
ref_note <- function(id) { n <- ref$notes[match(id, ref$estimate_id)]
  ifelse(grepl("p<.001", n), "***", ifelse(grepl("p<.01", n), "**", ifelse(grepl("p<.05", n), "*", ""))) }
crit_md <- c("| Run | Schools | M1 min loading | M1 | M2 min α/ρc | M2 min AVE | M2 | M3 max HTMT | M3 | M4 max VIF | M4 |",
             "|---|---|---|---|---|---|---|---|---|---|---|",
             apply(crit, 1, function(z) paste0("| ", paste(z[c("run", "n_schools", "M1_min_loading", "M1_pass",
               "M2_min_alpha_rhoc", "M2_min_ave", "M2_pass", "M3_max_htmt", "M3_pass", "M4_max_inner_vif", "M4_pass")], collapse = " | "), " |")))
s1 <- res[[1]]$settings
lo <- function(nm, it) f2(get(res[[nm]]$est, paste0("_loading_", it, "$")))

if (outcome == "math") {
# ---- report: math (the A2 report) ------------------------------------------------
cmp_rows <- function(model, ids, labels) {
  pid <- paste0(model, "_math_", ids)
  pe <- prim[match(pid, prim$estimate_id), ]
  se <- sens[match(pid, sens$estimate_id), ]
  paste0("| ", labels, " | ", f2(ref$reported[match(pid, ref$estimate_id)]), ref_note(pid),
         " | ", f2(pe$estimate), pstar(pe$p_value),
         " | ", ifelse(is.na(pe$ci_low), "", paste0("[", f2(pe$ci_low), ", ", f2(pe$ci_high), "]")),
         " | ", f2(se$estimate), pstar(se$p_value), " |")
}
ids  <- c("path_SES_OTL", "path_SES_ACH", "path_OTL_ACH", "path_ICT_OTL", "path_ICT_ACH", "path_SESxICT_ACH",
          "r2_ACH", "r2_OTL", "fit_APC", "fit_ARS", "fit_AVIF",
          "cor_SES_OTL", "cor_SES_ACH", "cor_OTL_ACH", "cor_SES_ICT", "cor_OTL_ICT", "cor_ICT_ACH")
labs <- c("SES → OTL", "SES → Math", "OTL → Math", "ICT → OTL", "ICT → Math", "SES × ICT → Math",
          "R² Math", "R² OTL", "APC", "ARS", "AVIF",
          "r SES–OTL", "r SES–Math", "r OTL–Math", "r SES–ICT", "r OTL–ICT", "r ICT–Math")
hdr <- c("| | TIMSS 2011 (paper) | PISA 2012 | 95% CI | PISA, ESCS |", "|---|---|---|---|---|")
slope <- function(model) {
  e <- prim[prim$estimate_id == paste0(model, "_math_path_SESxICT_ACH"), ]
  sprintf("%s (p = %.2f)", f2(e$estimate), e$p_value) }
rep <- c(
  "# A2 step 2: SmartPLS results, PISA 2012 (US), school level",
  "",
  "Built by `R/a2_02_read_smartpls.R` from the user's SmartPLS 4 exports. Spec: `docs/spec.md`.",
  "",
  "## Runs received",
  "",
  sprintf("- Settings for every run: PLS-SEM, %s weighting scheme, no weighting vector; bootstrap with %s samples, %s, %s. The seed value is not in the export.",
          tolower(s1["scheme"]), s1["samples"], tolower(s1["ci"]), tolower(s1["seed"])),
  "- Model 1 (ICT use), 146 schools: primary run and ESCS run, each with bootstrap.",
  "- Model 2 (ICT resources), 139 schools: primary run and ESCS run, each with bootstrap. `ICTRES_RATIO` (computers per student) was dropped in both runs.",
  "- Not received: the Model 2 run that still included `ICTRES_RATIO`, and the PLSc sensitivity runs (spec 5.2a).",
  "",
  sprintf("**The `ICTRES_RATIO` drop is consistent with spec M1.** Its correlation with the 3-item ICT resources score is %s. That is far below the .40 cut, so its loading in a with-ratio model would also fall below it. A with-ratio export would make this exact.", f2(r_ratio)),
  "",
  "## Acceptance criteria (spec section 6)",
  "",
  crit_md,
  "",
  sprintf("All four runs pass M1–M4. One item is below .70: `ICTUSE_LESSON` (%s). It is kept under the M1 rule because ρc and AVE meet the thresholds without dropping it. It is also the item closest to TIMSS classroom use.", lo("M1_primary", "ICTUSE_LESSON")),
  "The outer VIFs of the five math PVs are 77–93. This is expected, because the PVs are near-identical school means. M4 applies to inner VIFs only.",
  "",
  "## Model 1: ICT use (PISA) vs. computer as information tool (TIMSS), math",
  "",
  "Significance: \\* p < .05, \\*\\* p < .01, \\*\\*\\* p < .001 (two-tailed, bootstrap). For TIMSS, stars are as printed in the paper.",
  "",
  hdr, cmp_rows("M1", ids, labs),
  "",
  "## Model 2: ICT resources (PISA) vs. computer as learning tool (TIMSS), math",
  "",
  hdr, cmp_rows("M2", ids, labs),
  "",
  "## What the comparison shows (descriptive; designs differ, see spec section 7)",
  "",
  "1. **SES is the strongest predictor in both studies.** SES → Math is .53–.55 in PISA and .64–.65 in TIMSS.",
  "2. **OTL matters more, and depends more on SES, in PISA.** OTL → Math is .37–.38 in PISA vs. .20–.21 in TIMSS. SES → OTL is .52–.61 vs. .12–.13.",
  "   - A large part of PISA's SES effect runs through OTL: the indirect SES → OTL → Math effect is .19 in Model 1 (SmartPLS export).",
  "   - This fits OTL being cumulative concept familiarity measured at school level, rather than teacher-reported coverage within one year.",
  sprintf("3. **No ICT effect and no moderation in PISA.** ICT → Math and ICT → OTL are not significant. SES × ICT is %s in Model 1 and %s in Model 2.", slope("M1"), slope("M2")),
  "   - With about 140 schools, paths below about |.21| are unlikely to reach significance (spec D4).",
  "   - TIMSS found ICT → OTL significant for math in both models. PISA's ICT measures are principal reports on internet use and resources, not classroom computer use.",
  "4. **Explained variance is higher in PISA** (R² Math .67–.69 vs. .50). This is typical of school-level aggregates.",
  "5. **ESCS instead of the SES composite leaves the conclusions unchanged.** Every significant path keeps its sign and significance. SES → Math is .05–.08 lower and OTL → Math about .05 higher. The near-zero, non-significant Model 2 ICT paths flip sign (last two columns).",
  "",
  "## Not comparable",
  "",
  "- The paper's Table 2 VIFs are WarpPLS full-collinearity VIFs per construct. SmartPLS reports inner VIFs per path, so AVIF here is the mean inner VIF.",
  "- The paper's paths don't follow from its own correlations (e.g. math SES–OTL r = .02 but path .12). This suggests WarpPLS's nonlinear algorithm. PISA results here are linear PLS-SEM."
)
} else {
# ---- report: reading or science, with PISA math as the anchor --------------------
L <- oc$label; l <- tolower(L)
# Math anchor (results/a2). The math CSVs predate the indirect/total rows, so those are
# derived from the math paths (point estimates only) when absent.
with_effects <- function(tab) {
  for (m in c("M1", "M2")) {
    g <- function(id) tab$estimate[match(paste0(m, "_math_", id), tab$estimate_id)]
    ind_ses <- g("path_SES_OTL") * g("path_OTL_ACH"); ind_ict <- g("path_ICT_OTL") * g("path_OTL_ACH")
    new <- data.frame(estimate_id = paste0(m, "_math_", c("ind_SES_OTL_ACH", "ind_ICT_OTL_ACH", "tot_SES_ACH", "tot_ICT_ACH")),
                      estimate = c(ind_ses, ind_ict, g("path_SES_ACH") + ind_ses, g("path_ICT_ACH") + ind_ict),
                      stringsAsFactors = FALSE)
    new <- new[!new$estimate_id %in% tab$estimate_id, , drop = FALSE]
    new[setdiff(names(tab), names(new))] <- NA
    tab <- rbind(tab, new[names(tab)])
  }
  tab
}
mprim <- with_effects(utils::read.csv("results/a2/a2_pisa2012_estimates_user_sav.csv", stringsAsFactors = FALSE))
v <- function(tab, model, tag, id) {
  if (is.null(tab)) return(list(e = NA_real_, p = NA_real_, lo = NA_real_, hi = NA_real_))
  e <- tab[match(paste0(model, "_", tag, "_", id), tab$estimate_id), ]
  list(e = e$estimate, p = e$p_value, lo = e$ci_low, hi = e$ci_high)
}
fs <- function(x) ifelse(is.na(x), "", ifelse(round(x, 2) == 0, "0.00", sprintf("%+.2f", x)))
ids  <- c("path_SES_OTL", "path_SES_ACH", "path_OTL_ACH", "path_ICT_OTL", "path_ICT_ACH", "path_SESxICT_ACH",
          "ind_SES_OTL_ACH", "tot_SES_ACH", "ind_ICT_OTL_ACH", "tot_ICT_ACH",
          "r2_ACH", "r2_OTL", "fit_APC", "fit_ARS", "fit_AVIF", "cor_SES_ACH", "cor_OTL_ACH", "cor_ICT_ACH")
labs <- c("SES → OTL", "SES → Ach.", "OTL → Ach.", "ICT → OTL", "ICT → Ach.", "SES × ICT → Ach.",
          "SES → OTL → Ach. (indirect)", "SES → Ach. (total)", "ICT → OTL → Ach. (indirect)", "ICT → Ach. (total)",
          "R² Ach.", "R² OTL", "APC", "ARS", "AVIF", "r SES–Ach.", "r OTL–Ach.", "r ICT–Ach.")
timss <- outcome == "science"   # the paper reports TIMSS science; it has no reading
dom_rows <- function(model) {
  vapply(seq_along(ids), function(k) {
    id <- ids[k]
    m  <- v(mprim, model, "math", id); d <- v(prim, model, oc$tag, id); s <- v(sens, model, oc$tag, id)
    pid <- paste0(model, "_", oc$tag, "_", id)
    cells <- c(labs[k],
               if (timss) paste0(f2(ref$reported[match(pid, ref$estimate_id)]), ref_note(pid)),
               paste0(f2(m$e), pstar(m$p)), paste0(f2(d$e), pstar(d$p)),
               ifelse(is.na(d$lo), "", paste0("[", f2(d$lo), ", ", f2(d$hi), "]")),
               fs(d$e - m$e), paste0(f2(s$e), pstar(s$p)))
    paste0("| ", paste(cells, collapse = " | "), " |")
  }, "")
}
dom_hdr <- c(paste0("| | ", if (timss) "TIMSS 2011 science (paper) | ", "PISA math | PISA ", l, " | 95% CI | ",
                    L, " − math | PISA ", l, ", ESCS |"),
             paste0("|", strrep("---|", if (timss) 7 else 6)))
pe <- function(model, id) v(prim, model, oc$tag, id)
me <- function(model, id) v(mprim, model, "math", id)
both <- function(fun, id, digits = f2) paste0(digits(fun("M1", id)$e), " (Model 1) and ", digits(fun("M2", id)$e), " (Model 2)")
sig <- function(model, id) { p <- pe(model, id)$p; !is.na(p) && p < .05 }
ptxt <- function(model, id) { x <- pe(model, id); sprintf("%s (p = %.3f)", f2(x$e), x$p) }
sens_flip <- function() {
  if (is.null(sens)) return("no ESCS runs received")
  flips <- small <- character(0)
  for (nm in names(res)[runs$run == "escs"]) {
    model <- sub("_escs$", "", nm)
    for (id in ids[1:6]) {
      a <- pe(model, id); b <- v(sens, model, oc$tag, id)
      if (is.na(a$p) || is.na(b$p)) next
      if ((a$p < .05) != (b$p < .05) || ((a$p < .05) && sign(a$e) != sign(b$e)))
        flips <- c(flips, sprintf("%s %s (%s%s → %s%s)", model, labs[match(id, ids)], f2(a$e), pstar(a$p), f2(b$e), pstar(b$p)))
      else if (sign(round(a$e, 2)) * sign(round(b$e, 2)) < 0)
        small <- c(small, sprintf("%s %s (%s → %s)", model, labs[match(id, ids)], f2(a$e), f2(b$e)))
    }
  }
  if (length(flips)) return(paste0("these paths change significance, or a significant path changes sign: ", paste(flips, collapse = "; ")))
  msg <- "no path changes significance at .05, and every significant path keeps its sign"
  if (length(small)) paste0(msg, ". Near-zero, non-significant paths that flip sign: ", paste(small, collapse = "; ")) else msg
}
recv <- function(model) {
  got <- runs$run[runs$model == model]
  if (!length(got)) return("not received")
  paste0(paste(ifelse(got == "primary", "primary run", "ESCS run"), collapse = " and "), ", each with bootstrap")
}
n_of <- function(model) { nm <- paste0(model, "_primary"); if (nm %in% names(res)) res[[nm]]$n else NA }
ict_items <- function(model) {
  nm <- names(res)[runs$model == model][1]
  sub("^.*_loading_", "", res[[nm]]$est$estimate_id[grepl("_loading_", res[[nm]]$est$estimate_id)])
}
below70 <- unlist(lapply(names(res), function(nm) {
  e <- res[[nm]]$est; ld <- e[grepl("_loading_", e$estimate_id) & e$estimate < .70, ]
  if (nrow(ld)) sprintf("`%s` %s (%s)", sub("^.*_loading_", "", ld$estimate_id), f2(ld$estimate), nm)
}))
all_pass <- all(crit$M1_pass & crit$M2_pass & crit$M3_pass & crit$M4_pass)
fails <- unlist(lapply(c("M1", "M2", "M3", "M4"), function(k) {
  bad <- crit$run[!crit[[paste0(k, "_pass")]]]; if (length(bad)) paste0(k, " fails for ", toString(bad)) }))

# Findings, built from the estimates. nz() drops the leading zero; rng() gives the Model 1-2 range.
nz   <- function(x) sub("^-\\.00$", ".00", sub("^(-?)0\\.", "\\1.", f2(x)))
fp   <- function(p) if (p < .001) "p < .001" else sub("= 0\\.", "= .", sprintf("p = %.3f", p))
rng  <- function(fun, id) { x <- sort(c(fun("M1", id)$e, fun("M2", id)$e))
  if (nz(x[1]) == nz(x[2])) nz(x[1]) else paste0(nz(x[1]), "–", nz(x[2])) }
pv   <- function(model, id) { x <- pe(model, id); sprintf("%s (%s)", nz(x$e), fp(x$p)) }
dlt  <- function(id) { x <- sort(c(pe("M1", id)$e - me("M1", id)$e, pe("M2", id)$e - me("M2", id)$e))
  paste0(sub("([+-])0\\.", "\\1.", fs(x[1])), " to ", sub("([+-])0\\.", "\\1.", fs(x[2]))) }
tv   <- function(model, id) ref$reported[match(paste0(model, "_", oc$tag, "_", id), ref$estimate_id)]
trng <- function(id) { x <- sort(c(tv("M1", id), tv("M2", id)))
  if (nz(x[1]) == nz(x[2])) nz(x[1]) else paste0(nz(x[1]), "–", nz(x[2])) }
ict_sig <- unlist(lapply(c("M1", "M2"), function(m) {
  hit <- c("path_ICT_ACH", "path_ICT_OTL", "ind_ICT_OTL_ACH", "tot_ICT_ACH")
  hit[vapply(hit, function(id) sig(m, id), logical(1))] -> h; if (length(h)) paste(m, h) }))
max_d <- max(abs(unlist(lapply(c("M1", "M2"), function(m)
  vapply(ids[1:6], function(id) pe(m, id)$e - me(m, id)$e, numeric(1))))))
findings <- function() {
  out <- c(
    sprintf("1. **SES is the strongest predictor of %s, as of math.** SES → %s is %s (math %s). With the indirect path through OTL, the total SES effect is %s (math %s).",
            l, L, rng(pe, "path_SES_ACH"), rng(me, "path_SES_ACH"), rng(pe, "tot_SES_ACH"), rng(me, "tot_SES_ACH")),
    sprintf("2. **Math OTL relates to %s about as strongly as to math.** OTL → %s is %s (math %s), and the indirect SES → OTL → %s effect is %s (math %s). SES → OTL is the same as in math (%s), because its predictors don't change with the outcome.",
            l, L, rng(pe, "path_OTL_ACH"), rng(me, "path_OTL_ACH"), L, rng(pe, "ind_SES_OTL_ACH"), rng(me, "ind_SES_OTL_ACH"), rng(pe, "path_SES_OTL")))
  if (outcome == "reading") out <- c(out,
    sprintf("   - Reading leans a little more on the OTL proxy (%s vs. math) and a little less on SES directly (%s). Both gaps are well inside the 95%% CIs.",
            dlt("path_OTL_ACH"), dlt("path_SES_ACH")))
  if (outcome == "science") out <- c(out,
    sprintf("   - Science tracks math closely: no path differs from math by more than %s.", nz(max_d)))
  if (outcome == "reading") {
    tci <- pe("M1", "tot_ICT_ACH")
    out <- c(out,
      sprintf("3. **ICT use has a small total effect on reading.** In Model 1 neither ICT-use path is significant on its own: direct %s, through OTL %s. Together they give a total effect of %s, 95%% CI [%s, %s]. Math's total is %s; its p value needs the math exports rerun.",
              pv("M1", "path_ICT_ACH"), pv("M1", "ind_ICT_OTL_ACH"), pv("M1", "tot_ICT_ACH"), nz(tci$lo), nz(tci$hi), nz(me("M1", "tot_ICT_ACH")$e)),
      "   - Treat it as a lead, not a finding. It is one of many tests, it is smaller than the |.21| this sample can reliably detect, and the direct path alone is not significant. Digital reading is where an ICT link would be expected first.",
      sprintf("   - ICT resources (Model 2) show nothing: ICT → %s %s, total %s.", L, pv("M2", "path_ICT_ACH"), pv("M2", "tot_ICT_ACH")))
  } else {
    out <- c(out, sprintf("3. **No ICT effect in either model.** %s.",
      if (length(ict_sig)) paste("Except:", toString(ict_sig)) else
        sprintf("ICT → %s, ICT → OTL and the total ICT effect all have p > .05. Totals: Model 1 %s, Model 2 %s", L, pv("M1", "tot_ICT_ACH"), pv("M2", "tot_ICT_ACH"))))
  }
  out <- c(out,
    sprintf("4. **%s** Model 1 %s; Model 2 %s.%s",
            if (sig("M1", "path_SESxICT_ACH") || sig("M2", "path_SESxICT_ACH")) "SES × ICT moderation:" else "No SES × ICT moderation.",
            pv("M1", "path_SESxICT_ACH"), pv("M2", "path_SESxICT_ACH"),
            if (timss) sprintf(" TIMSS science found a moderation of %s%s in Model 1.", nz(tv("M1", "path_SESxICT_ACH")), ref_note("M1_sci_path_SESxICT_ACH")) else ""),
    sprintf("5. **R² %s is %s** (math %s).", L, rng(pe, "r2_ACH"), rng(me, "r2_ACH")),
    sprintf("6. **ESCS instead of the SES composite:** %s. SES → %s drops to %s and OTL → %s rises to %s, as in math.",
            sens_flip(), L, rng(function(m, id) v(sens, m, oc$tag, id), "path_SES_ACH"), L, rng(function(m, id) v(sens, m, oc$tag, id), "path_OTL_ACH")))
  if (timss) out <- c(out,
    sprintf("7. **Against TIMSS science, PISA repeats the math contrast.** SES → Science is %s in PISA vs. %s in TIMSS. OTL → Science is %s vs. %s, and SES → OTL %s vs. %s.",
            rng(pe, "path_SES_ACH"), trng("path_SES_ACH"), rng(pe, "path_OTL_ACH"), trng("path_OTL_ACH"), rng(pe, "path_SES_OTL"), trng("path_SES_OTL")),
    "   - TIMSS science OTL is teacher-reported coverage of science topics; PISA's is students' familiarity with math concepts. The larger PISA OTL paths are expected, and they are not a like-for-like science comparison.",
    sprintf("   - TIMSS found ICT → OTL of %s%s in Model 2; PISA science has %s.", nz(tv("M2", "path_ICT_OTL")), ref_note("M2_sci_path_ICT_OTL"), pv("M2", "path_ICT_OTL")),
    sprintf("   - R² Science is %s in PISA vs. %s in TIMSS, typical of school-level aggregates.", rng(pe, "r2_ACH"), trng("r2_ACH")))
  out
}

rep <- c(
  sprintf("# A2 %s: SmartPLS results, PISA 2012 (US), school level", l),
  "",
  sprintf("Built by `R/a2_02_read_smartpls.R %s` from the user's SmartPLS 4 exports. Math anchor: `results/a2/summary.md`. Spec: `docs/spec.md` (criteria, section 6).", outcome),
  "",
  sprintf("**Exploratory.** The spec covers math only (decision 1). These runs use the math model with the outcome swapped for school means of the five %s PVs (`%s1`–`%s5`).", l, oc$lv, oc$lv),
  "",
  sprintf("**OTL here is a proxy.** PISA 2012 has opportunity-to-learn items for math only. OTL is FAMCONC, the familiarity with math concepts, so OTL → %s reads as how a school's math exposure relates to its %s scores, not as %s OTL.", L, l, l),
  "",
  "## Runs received",
  "",
  sprintf("- Settings for every run: PLS-SEM, %s weighting scheme; bootstrap with %s samples, %s, %s. The seed value is not in the export.",
          tolower(s1["scheme"]), s1["samples"], tolower(s1["ci"]), tolower(s1["seed"])),
  sprintf("- Model 1 (ICT use), %s schools: %s. ICT items: %s.", n_of("M1"), recv("M1"), paste0("`", ict_items("M1"), "`", collapse = ", ")),
  sprintf("- Model 2 (ICT resources), %s schools: %s. ICT items: %s. `ICTRES_RATIO` was dropped, as in math.", n_of("M2"), recv("M2"), paste0("`", ict_items("M2"), "`", collapse = ", ")),
  if (length(missing_runs)) sprintf("- Not received: %s.", toString(missing_runs)) else "- All four runs were received (Model 1 and Model 2, primary and ESCS).",
  "- Exports are matched to runs by content (outcome construct, ICT construct, SES indicator, bootstrap or not), not by file name; see `a2_02_exports_manifest.csv`.",
  "",
  "## Acceptance criteria (spec section 6, applied unchanged)",
  "",
  crit_md,
  "",
  if (all_pass) sprintf("All %d runs pass M1–M4.", nrow(crit)) else paste0("**Not all runs pass:** ", paste(fails, collapse = "; "), "."),
  if (length(below70)) sprintf("Loadings below .70: %s. They are kept under the M1 rule because ρc and AVE meet the thresholds, as in math.", paste(below70, collapse = "; ")),
  "",
  sprintf("## Model 1: ICT use, %s vs. math", l),
  "",
  "Ach. = achievement in the subject named in each column. Significance: \\* p < .05, \\*\\* p < .01, \\*\\*\\* p < .001 (two-tailed, bootstrap).",
  sprintf("PISA math is from `results/a2/`; its indirect and total effects are products and sums of its paths, without p values. %s − math is the difference in point estimates.", L),
  if (timss) "TIMSS science is the paper's teacher-level values, with stars as printed (blank where the paper reports none).",
  "",
  dom_hdr, dom_rows("M1"),
  "",
  sprintf("## Model 2: ICT resources, %s vs. math", l),
  "",
  dom_hdr, dom_rows("M2"),
  "",
  sprintf("## What the comparison shows (descriptive; see the last section)"),
  "",
  findings(),
  "",
  "## Reading the comparison",
  "",
  sprintf("- **Differences between subjects are descriptive.** Every run uses the same schools, the same SES, OTL and ICT measures, and outcomes that are school means of correlated PVs, so similar paths are expected. Testing a %s-vs-math difference needs both outcomes in one model with a shared bootstrap. Overlapping CIs show only that these data can't tell the paths apart.", l),
  "- With 139–146 schools, paths below about |.21| are unlikely to reach p < .05 (spec D4). Many paths are tested per run, so a single p just under .05 is weak evidence.",
  if (timss) "- TIMSS-vs-PISA differences in design (teacher vs. school level, Grade 8 vs. age 15, teacher-reported vs. student-reported OTL, classroom vs. principal-reported ICT) are listed in spec section 7. For science, add that PISA's OTL is about math, not science.",
  if (outcome == "reading") "- TIMSS 2011 has no reading assessment, so there is no paper column. Digital reading (`CREA`) is in the `seminr` grid: `results/a2_seminr/`."
)
}
writeLines(rep, file.path(oc$dir, "summary.md"))

# ---- provenance ----------------------------------------------------------------
mf <- cls[use, ]
utils::write.csv(data.frame(file = mf$file, bytes = file.size(mf$file),
  sha256 = vapply(mf$file, function(f) strsplit(system2("sha256sum", shQuote(f), stdout = TRUE), " ")[[1]][1], ""),
  source = "user upload (SmartPLS 4 export)", received = "2026-11-19",
  model = mf$model, run = mf$run, kind = mf$kind),
  file.path(oc$dir, "a2_02_exports_manifest.csv"), row.names = FALSE)
print(crit, row.names = FALSE)
if (length(missing_runs)) cat("Not received:", toString(missing_runs), "\n")
if (!is.na(r_ratio)) cat(sprintf("RATCMP15 vs ICT resources score: r = %.3f\n", r_ratio))
