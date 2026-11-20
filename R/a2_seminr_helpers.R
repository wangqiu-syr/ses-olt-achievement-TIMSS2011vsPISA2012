# Shared seminr fit for the A2 school-level PLS-SEM model. Sourced by a2_04 (cross-check
# against SmartPLS) and a2_05 (scripted runs); not run on its own.
#
# The model is the paper's (spec section 4): SES -> OTL, ICT -> OTL; SES, ICT, OTL and SES x ICT
# -> achievement. Settings follow the user's SmartPLS 4 runs: PLS-SEM (not PLSc), path weighting,
# mode A, standardized, up to 3000 iterations, stop criterion 1e-7, two-stage interaction,
# percentile bootstrap, two-tailed p from t with nboot - 1 df.

suppressMessages(library(seminr))

a2_ict_items <- list(M1 = c("ICTUSE_LESSON", "ICTUSE_HOMEWK", "ICTUSE_ASSIGN"),
                     M2 = c("ICTRES_COMP", "ICTRES_NET", "ICTRES_SOFT"))  # ICTRES_RATIO dropped, as in SmartPLS
a2_key <- function(x) sub("^SES\\*ICT$", "SESxICT", x)

# Fit one run. model: "M1" or "M2"; lv: outcome prefix (MATH, READ, ...); ses_col: "SES" or
# "ESCS"; otl_col: the OTL indicator column (OTL = FAMCONC, OTL_PT, EXPUREM, EXAPPLM).
# Returns list(est = data.frame(id, estimate, se, p_value, ci_low, ci_high), fl_ok, iterations, n),
# plus boot (the seminr bootstrap object, for draws) when return_boot = TRUE.
# Build the data, measurement and structural model for one run (interaction = FALSE drops SES x ICT).
a2_build <- function(model, lv, ses_col = "SES", otl_col = "OTL", interaction = TRUE) {
  dat <- utils::read.csv(sprintf("data/derived/a2_smartpls_model%s.csv", substr(model, 2, 2)))
  # Single items get their own names so they don't clash with the construct names.
  dat$ses_item <- dat[[ses_col]]
  dat$otl_item <- dat[[otl_col]]
  ach <- paste0(lv, 1:5)
  items <- a2_ict_items[[model]]
  dat <- dat[, c("ses_item", "otl_item", items, ach)]
  cons <- list(
    composite("SES", single_item("ses_item")),
    composite("OTL", single_item("otl_item")),
    # Mode A composites = SmartPLS's plain PLS-SEM. seminr's reflective() would switch to PLSc.
    composite("ICT", items, weights = mode_A),
    composite("ACH", ach, weights = mode_A))
  if (interaction) cons <- c(cons, list(interaction_term(iv = "SES", moderator = "ICT", method = two_stage)))
  mm <- do.call(constructs, cons)
  sm <- relationships(
    paths(from = c("SES", "ICT"), to = "OTL"),
    paths(from = c("SES", "ICT", "OTL", if (interaction) "SES*ICT"), to = "ACH"))
  list(dat = dat, mm = mm, sm = sm, items = items)
}

# Point estimates only (no bootstrap), e.g. for R-square with and without the interaction (f-square).
a2_estimate <- function(model, lv, ses_col = "SES", otl_col = "OTL", interaction = TRUE) {
  m <- a2_build(model, lv, ses_col, otl_col, interaction)
  estimate_pls(m$dat, m$mm, m$sm, inner_weights = path_weighting, maxIt = 3000, stopCriterion = 7)
}

a2_fit_pls <- function(model, lv, ses_col = "SES", otl_col = "OTL", nboot = 5000, seed = 20261120,
                       cores = max(1L, parallel::detectCores()), return_boot = FALSE) {
  m <- a2_build(model, lv, ses_col, otl_col)
  dat <- m$dat; items <- m$items
  est <- estimate_pls(dat, m$mm, m$sm, inner_weights = path_weighting, maxIt = 3000, stopCriterion = 7)
  s <- summary(est)
  pval <- function(e, sd) 2 * stats::pt(-abs(e / sd), df = nboot - 1)

  rows <- list()
  add <- function(id, v, se = NA, p = NA, lo = NA, hi = NA)
    rows[[length(rows) + 1]] <<- data.frame(id = id, estimate = unname(v), se = unname(se),
                                            p_value = unname(p), ci_low = unname(lo), ci_high = unname(hi))
  # bootstrap: paths, total effects, indirect effects via OTL
  b  <- suppressMessages(bootstrap_model(est, nboot = nboot, cores = cores, seed = seed))
  sb <- summary(b)
  boot_rows <- function(tab, prefix, keep = NULL) {
    for (k in seq_len(nrow(tab))) {
      ab <- trimws(strsplit(rownames(tab)[k], "->", fixed = TRUE)[[1]])
      id <- paste0(prefix, a2_key(ab[1]), "_", a2_key(ab[2]))
      if (!is.null(keep) && !id %in% keep) next
      add(id, tab[k, "Original Est."], tab[k, "Bootstrap SD"], pval(tab[k, "Original Est."], tab[k, "Bootstrap SD"]),
          tab[k, "2.5% CI"], tab[k, "97.5% CI"])
    }
  }
  boot_rows(sb$bootstrapped_paths, "path_")
  boot_rows(sb$bootstrapped_total_paths, "tot_", c("tot_SES_ACH", "tot_ICT_ACH"))
  for (f in c("SES", "ICT")) {
    ie <- specific_effect_significance(b, from = f, through = "OTL", to = "ACH", alpha = 0.05)  # 1-row table
    add(paste0("ind_", f, "_OTL_ACH"), ie[1, "Original Est."], ie[1, "Bootstrap SD"],
        pval(ie[1, "Original Est."], ie[1, "Bootstrap SD"]), ie[1, "2.5% CI"], ie[1, "97.5% CI"])
  }
  # R-square, reliability, loadings
  for (cn in c("ACH", "OTL")) add(paste0("r2_", cn), est$rSquared["Rsq", cn])
  rel <- s$reliability
  for (cn in c("ICT", "ACH")) {
    add(paste0("alpha_", cn), rel[cn, "alpha"]); add(paste0("rhoa_", cn), rel[cn, "rhoA"])
    add(paste0("rhoc_", cn),  rel[cn, "rhoC"]);  add(paste0("ave_", cn),  rel[cn, "AVE"])
  }
  for (it in items) add(paste0("loading_", it), est$outer_loadings[it, "ICT"])
  # HTMT (main constructs; seminr fills one triangle)
  h <- s$validity$htmt
  for (pr in utils::combn(c("SES", "OTL", "ICT", "ACH"), 2, simplify = FALSE)) {
    v <- suppressWarnings(max(c(h[pr[1], pr[2]], h[pr[2], pr[1]]), na.rm = TRUE))
    add(paste0("htmt_", paste(sort(pr), collapse = "_")), if (is.finite(v)) v else NA)
  }
  # inner VIF per path
  for (to in names(s$vif_antecedents)) for (f in names(s$vif_antecedents[[to]]))
    add(paste0("vif_", a2_key(f), "_", a2_key(to)), s$vif_antecedents[[to]][[f]])
  # latent variable correlations, and Fornell-Larcker (|r| below both sqrt(AVE); single items AVE = 1)
  lc <- stats::cor(est$construct_scores)
  for (pr in list(c("SES", "OTL"), c("SES", "ICT"), c("SES", "ACH"), c("OTL", "ICT"), c("OTL", "ACH"), c("ICT", "ACH")))
    add(paste0("cor_", pr[1], "_", pr[2]), lc[pr[1], pr[2]])
  sq <- sqrt(c(SES = 1, OTL = 1, ICT = rel["ICT", "AVE"], ACH = rel["ACH", "AVE"]))
  fl_ok <- all(vapply(utils::combn(names(sq), 2, simplify = FALSE),
                      function(pr) abs(lc[pr[1], pr[2]]) < min(sq[pr]), logical(1)))
  out <- list(est = do.call(rbind, rows), fl_ok = fl_ok, iterations = est$iterations, n = nrow(dat))
  if (return_boot) out$boot <- b
  out
}

# Criteria M1-M4 (spec section 6) for one fitted run, as in R/a2_02.
a2_criteria <- function(f) {
  e <- f$est; g <- function(pat) e$estimate[grepl(pat, e$id)]
  ld <- g("^loading_"); rel <- c(g("^alpha_"), g("^rhoc_")); ave <- g("^ave_")
  data.frame(n_schools = f$n,
    M1_min_loading = round(min(ld), 3),
    M1_pass = all(ld >= .70) || (all(ld >= .40) && all(g("^rhoc_") >= .70) && all(ave >= .50)),
    M2_min_alpha_rhoc = round(min(rel), 3), M2_min_ave = round(min(ave), 3),
    M2_pass = all(rel >= .70) && all(ave >= .50),
    M3_max_htmt = round(max(g("^htmt_")), 3), M3_fornell_larcker = f$fl_ok,
    M3_pass = all(g("^htmt_") < .85) && f$fl_ok,
    M4_max_inner_vif = round(max(g("^vif_")), 3), M4_pass = all(g("^vif_") < 3.3))
}
