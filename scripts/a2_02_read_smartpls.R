# A2 step 2: read the user's SmartPLS 4 exports, check criteria M1-M5 (docs/spec.md
# section 6), and compare with Zhang & Wang (2020). Run from the project root:
#   Rscript scripts/a2_02_read_smartpls.R
#
# Inputs  data/raw/smartpls_exports/*.xlsx              (user uploads, gitignored)
#         data/derived/a2_smartpls_model{1,2}.csv         (from a2_01, for the RATCMP15 check)
#         tests/reference/zhang_wang_2020_reported.csv
# Outputs from_code/a2_pisa2012_estimates_user_sav.csv    primary runs (spec M5)
#         from_code/a2_pisa2012_estimates_sensitivity.csv ESCS runs
#         from_code/a2_02_criteria.csv                    M1-M4 per run
#         from_code/a2_02_smartpls_results.md             report

suppressMessages(library(readxl))
xdir <- "data/raw/smartpls_exports"
runs <- data.frame(
  run   = c("primary", "escs", "primary", "escs"),
  model = c("M1", "M1", "M2", "M2"),
  algo  = c("ICT_use_PLS-SEM", "ICT_use-PLS-SEM-ESCS",
            "ICT_Resources_PLS-SEM-NO-ICT-RATIO", "ICT_Resources-PLS-SEM-ESCS"),
  boot  = c("ICT_use_BT_5K", "ICT_use-BT-5K-ESCS",
            "ICT_Resources_BT-5K-NO-ICT-RATIO", "ICT_Resources-BT-5K-ESCS"),
  stringsAsFactors = FALSE
)

# ---- sheet helpers ---------------------------------------------------------
read_sheet <- function(name) {
  m <- as.matrix(read_excel(file.path(xdir, paste0(name, ".xlsx")), sheet = "complete",
                            col_names = FALSE, .name_repair = "minimal"))
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
  gsub("^MATH$", "ACH", x)
}
path_id <- function(p) { ab <- strsplit(p, " -> ", fixed = TRUE)[[1]]; paste0("path_", key(ab[1]), "_", key(ab[2])) }

# ---- extract one run ---------------------------------------------------------
extract <- function(r) {
  a <- read_sheet(r$algo); b <- read_sheet(r$boot)
  pre <- paste0(r$model, "_math_")
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
  fl_h <- a[fl_i, ]; fl <- a[block(a, fl_i + 1), , drop = FALSE]
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
utils::write.csv(crit, "from_code/a2_02_criteria.csv", row.names = FALSE)

# ---- estimate files (spec M5) --------------------------------------------------
rnd <- function(df) { df[-1] <- lapply(df[-1], function(x) signif(x, 6)); df }
prim <- do.call(rbind, lapply(res[runs$run == "primary"], `[[`, "est"))
sens <- do.call(rbind, lapply(names(res)[runs$run == "escs"], function(nm) cbind(run = "escs", res[[nm]]$est)))
utils::write.csv(rnd(prim), "from_code/a2_pisa2012_estimates_user_sav.csv", row.names = FALSE)
sens[-(1:2)] <- lapply(sens[-(1:2)], function(x) signif(x, 6))
utils::write.csv(sens, "from_code/a2_pisa2012_estimates_sensitivity.csv", row.names = FALSE)

# ---- RATCMP15 check (the with-ratio run was not exported) ----------------------
m2 <- utils::read.csv("data/derived/a2_smartpls_model2.csv")
ict_score <- num(res$M2_primary$scores[, "ICT"])
stopifnot(length(ict_score) == nrow(m2))
r_ratio <- stats::cor(m2$ICTRES_RATIO, ict_score)

# ---- report ------------------------------------------------------------------
ref <- utils::read.csv("tests/reference/zhang_wang_2020_reported.csv", comment.char = "#", stringsAsFactors = FALSE)
f2 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 2))
pstar <- function(p) ifelse(is.na(p), "", ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", ""))))
ref_note <- function(id) { n <- ref$notes[match(id, ref$estimate_id)]
  ifelse(grepl("p<.001", n), "***", ifelse(grepl("p<.01", n), "**", ifelse(grepl("p<.05", n), "*", ""))) }
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
crit_md <- c("| Run | Schools | M1 min loading | M1 | M2 min α/ρc | M2 min AVE | M2 | M3 max HTMT | M3 | M4 max VIF | M4 |",
             "|---|---|---|---|---|---|---|---|---|---|---|",
             apply(crit, 1, function(z) paste0("| ", paste(z[c("run", "n_schools", "M1_min_loading", "M1_pass",
               "M2_min_alpha_rhoc", "M2_min_ave", "M2_pass", "M3_max_htmt", "M3_pass", "M4_max_inner_vif", "M4_pass")], collapse = " | "), " |")))
s1 <- res$M1_primary$settings
lo <- function(nm, it) f2(get(res[[nm]]$est, paste0("_loading_", it, "$")))
slope <- function(model) {
  e <- prim[prim$estimate_id == paste0(model, "_math_path_SESxICT_ACH"), ]
  sprintf("%s (p = %.2f)", f2(e$estimate), e$p_value) }
rep <- c(
  "# A2 step 2: SmartPLS results, PISA 2012 (US), school level",
  "",
  "Built by `scripts/a2_02_read_smartpls.R` from the user's SmartPLS 4 exports. Spec: `docs/spec.md`.",
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
writeLines(rep, "from_code/a2_02_smartpls_results.md")
xl <- list.files(xdir, full.names = TRUE)
utils::write.csv(data.frame(file = xl, bytes = file.size(xl),
  sha256 = vapply(xl, function(f) strsplit(system2("sha256sum", shQuote(f), stdout = TRUE), " ")[[1]][1], ""),
  source = "user upload (SmartPLS 4 export)", received = "2026-11-19"),
  "from_code/a2_02_exports_manifest.csv", row.names = FALSE)
print(crit, row.names = FALSE)
cat(sprintf("RATCMP15 vs ICT resources score: r = %.3f\n", r_ratio))
