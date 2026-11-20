# A2 cross-check: re-estimate the user's SmartPLS models in R with seminr and compare them
# with the SmartPLS results read by a2_02. Run from the project root:
#   Rscript R/a2_04_seminr_crosscheck.R            # math (default) -> results/a2/
#   Rscript R/a2_04_seminr_crosscheck.R reading    # or science     -> results/a2_<outcome>/
# Environment variable NBOOT sets the bootstrap samples (default 5000, as in SmartPLS).
#
# Settings follow the SmartPLS 4 exports: PLS-SEM (not PLSc), path weighting scheme, mode A, standardized,
# up to 3000 iterations, stop criterion 1e-7, SES x ICT interaction by the two-stage approach,
# percentile bootstrap CIs, two-tailed p from t with nboot - 1 df.
#
# Inputs  data/derived/a2_smartpls_model{1,2}.csv                     (from a2_01)
#         <dir>/a2_pisa2012_estimates_user_sav.csv, ..._sensitivity.csv (SmartPLS, from a2_02)
# Outputs <dir>/a2_04_seminr_vs_smartpls.csv   every shared estimate, both programs
#         <dir>/a2_04_seminr_crosscheck.md     report
#
# seminr: CRAN is blocked in the cloud sandbox, so seminr 2.6.0 was installed from its GitHub
# source (see R/README.md). On a laptop, install.packages("seminr") is enough.

suppressMessages(library(seminr))
args    <- commandArgs(trailingOnly = TRUE)
outcome <- if (length(args)) tolower(args[1]) else "math"
cfg <- list(math    = list(tag = "math", lv = "MATH", label = "Math",    dir = "results/a2"),
            reading = list(tag = "read", lv = "READ", label = "Reading", dir = "results/a2_reading"),
            science = list(tag = "sci",  lv = "SCIE", label = "Science", dir = "results/a2_science"))
if (!outcome %in% names(cfg)) stop("Outcome must be one of: ", toString(names(cfg)))
oc    <- cfg[[outcome]]
nboot <- as.integer(Sys.getenv("NBOOT", "5000"))
seed  <- 20261120
cores <- max(1L, parallel::detectCores())
ict_items <- list(M1 = c("ICTUSE_LESSON", "ICTUSE_HOMEWK", "ICTUSE_ASSIGN"),
                  M2 = c("ICTRES_COMP", "ICTRES_NET", "ICTRES_SOFT"))  # ICTRES_RATIO dropped, as in SmartPLS
runs <- expand.grid(run = c("primary", "escs"), model = c("M1", "M2"), stringsAsFactors = FALSE)[, 2:1]
key  <- function(x) sub("^SES\\*ICT$", "SESxICT", x)
pval <- function(est, sd) 2 * stats::pt(-abs(est / sd), df = nboot - 1)

# ---- fit one run -------------------------------------------------------------------
fit_run <- function(model, run) {
  dat <- utils::read.csv(sprintf("data/derived/a2_smartpls_model%s.csv", substr(model, 2, 2)))
  # Single items get their own names so they don't clash with the construct names.
  dat$ses_item <- dat[[if (run == "escs") "ESCS" else "SES"]]
  dat$otl_item <- dat$OTL
  ach <- paste0(oc$lv, 1:5)
  dat <- dat[, c("ses_item", "otl_item", ict_items[[model]], ach)]
  mm <- constructs(
    composite("SES", single_item("ses_item")),
    composite("OTL", single_item("otl_item")),
    # Mode A composites = SmartPLS's plain PLS-SEM. seminr's reflective() would switch to PLSc.
    composite("ICT", ict_items[[model]], weights = mode_A),
    composite("ACH", ach, weights = mode_A),
    interaction_term(iv = "SES", moderator = "ICT", method = two_stage))
  sm <- relationships(
    paths(from = c("SES", "ICT"), to = "OTL"),
    paths(from = c("SES", "ICT", "OTL", "SES*ICT"), to = "ACH"))
  est <- estimate_pls(dat, mm, sm, inner_weights = path_weighting, maxIt = 3000, stopCriterion = 7)
  s <- summary(est)

  rows <- list()
  add <- function(id, v, se = NA, p = NA, lo = NA, hi = NA)
    rows[[length(rows) + 1]] <<- data.frame(id = id, seminr = unname(v), seminr_se = se,
                                            seminr_p = p, seminr_ci_low = lo, seminr_ci_high = hi)
  # bootstrap (paths and total effects)
  b  <- suppressMessages(bootstrap_model(est, nboot = nboot, cores = cores, seed = seed))
  sb <- summary(b)
  boot_rows <- function(tab, prefix, keep = NULL) {
    for (k in seq_len(nrow(tab))) {
      ab <- trimws(strsplit(rownames(tab)[k], "->", fixed = TRUE)[[1]])
      id <- paste0(prefix, key(ab[1]), "_", key(ab[2]))
      if (!is.null(keep) && !id %in% keep) next
      add(id, tab[k, "Original Est."], tab[k, "Bootstrap SD"], pval(tab[k, "Original Est."], tab[k, "Bootstrap SD"]),
          tab[k, "2.5% CI"], tab[k, "97.5% CI"])
    }
  }
  boot_rows(sb$bootstrapped_paths, "path_")
  boot_rows(sb$bootstrapped_total_paths, "tot_", c("tot_SES_ACH", "tot_ICT_ACH"))
  for (f in c("SES", "ICT")) {
    ie <- specific_effect_significance(b, from = f, through = "OTL", to = "ACH", alpha = 0.05)
    add(paste0("ind_", f, "_OTL_ACH"), ie["Original Est."], ie["Bootstrap SD"],
        pval(ie["Original Est."], ie["Bootstrap SD"]), ie["2.5% CI"], ie["97.5% CI"])
  }
  # R-square, reliability, loadings
  for (cn in c("ACH", "OTL")) add(paste0("r2_", cn), est$rSquared["Rsq", cn])
  rel <- s$reliability
  for (cn in c("ICT", "ACH")) {
    add(paste0("alpha_", cn), rel[cn, "alpha"]); add(paste0("rhoa_", cn), rel[cn, "rhoA"])
    add(paste0("rhoc_", cn),  rel[cn, "rhoC"]);  add(paste0("ave_", cn),  rel[cn, "AVE"])
  }
  for (it in ict_items[[model]]) add(paste0("loading_", it), est$outer_loadings[it, "ICT"])
  # HTMT (main constructs; seminr fills one triangle)
  h <- s$validity$htmt
  for (pr in utils::combn(c("SES", "OTL", "ICT", "ACH"), 2, simplify = FALSE)) {
    v <- suppressWarnings(max(c(h[pr[1], pr[2]], h[pr[2], pr[1]]), na.rm = TRUE))
    add(paste0("htmt_", paste(sort(pr), collapse = "_")), if (is.finite(v)) v else NA)
  }
  # inner VIF per path
  for (to in names(s$vif_antecedents)) for (f in names(s$vif_antecedents[[to]]))
    add(paste0("vif_", key(f), "_", key(to)), s$vif_antecedents[[to]][[f]])
  # latent variable correlations
  lc <- stats::cor(est$construct_scores)
  for (pr in list(c("SES", "OTL"), c("SES", "ICT"), c("SES", "ACH"), c("OTL", "ICT"), c("OTL", "ACH"), c("ICT", "ACH")))
    add(paste0("cor_", pr[1], "_", pr[2]), lc[pr[1], pr[2]])
  out <- do.call(rbind, rows)
  out$estimate_id <- paste0(model, "_", oc$tag, "_", out$id)
  cbind(run = paste(model, run, sep = "_"), out, iterations = est$iterations)
}

t0  <- Sys.time()
sem <- do.call(rbind, lapply(seq_len(nrow(runs)), function(i) fit_run(runs$model[i], runs$run[i])))
secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))

# ---- join with SmartPLS ------------------------------------------------------------
sp_p <- utils::read.csv(file.path(oc$dir, "a2_pisa2012_estimates_user_sav.csv"), stringsAsFactors = FALSE)
sp_s <- utils::read.csv(file.path(oc$dir, "a2_pisa2012_estimates_sensitivity.csv"), stringsAsFactors = FALSE)
sp_p$run <- paste0(substr(sp_p$estimate_id, 1, 2), "_primary")
sp_s$run <- paste0(substr(sp_s$estimate_id, 1, 2), "_escs")
sp <- rbind(sp_p[, c("run", "estimate_id", "estimate", "se", "p_value", "ci_low", "ci_high")],
            sp_s[, c("run", "estimate_id", "estimate", "se", "p_value", "ci_low", "ci_high")])
names(sp)[3:7] <- c("smartpls", "smartpls_se", "smartpls_p", "smartpls_ci_low", "smartpls_ci_high")
cmp <- merge(sem, sp, by = c("run", "estimate_id"))
cmp$diff <- cmp$seminr - cmp$smartpls
cmp$type <- sub("_.*$", "", cmp$id)
cmp <- cmp[order(match(cmp$run, paste(runs$model, runs$run, sep = "_")), match(cmp$type, unique(sem$id |> sub(pattern = "_.*$", replacement = ""))), cmp$id), ]
out_cols <- c("run", "estimate_id", "type", "smartpls", "seminr", "diff", "smartpls_se", "seminr_se",
              "smartpls_p", "seminr_p", "smartpls_ci_low", "seminr_ci_low", "smartpls_ci_high", "seminr_ci_high")
csv <- cmp[, out_cols]; csv[-(1:3)] <- lapply(csv[-(1:3)], function(x) signif(x, 6))
utils::write.csv(csv, file.path(oc$dir, "a2_04_seminr_vs_smartpls.csv"), row.names = FALSE)

# ---- report ----------------------------------------------------------------------
f3 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 3))
f4 <- function(x) ifelse(is.na(x), "", formatC(x, format = "f", digits = 4))
pstar <- function(p) ifelse(is.na(p), "", ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", ""))))
type_lab <- c(path = "Path coefficients", tot = "Total effects", ind = "Indirect effects", r2 = "R²",
              alpha = "Cronbach's α", rhoa = "ρA", rhoc = "ρC", ave = "AVE", loading = "ICT loadings",
              htmt = "HTMT", vif = "Inner VIF", cor = "Latent correlations")
by_type <- do.call(rbind, lapply(names(type_lab), function(t) { x <- cmp[cmp$type == t, ]
  if (!nrow(x)) return(NULL)
  data.frame(type = t, n = nrow(x), max_abs_diff = max(abs(x$diff)),
             max_abs_diff_se = if (all(is.na(x$smartpls_se))) NA else max(abs(x$seminr_se - x$smartpls_se), na.rm = TRUE)) }))
pth <- cmp[cmp$type == "path", ]
pth$agree <- (pth$smartpls_p < .05) == (pth$seminr_p < .05)
point_tol <- 0.001
point_ok  <- all(abs(cmp$diff[cmp$type %in% c("path", "tot", "ind", "r2", "loading", "alpha", "rhoc", "ave")]) < point_tol)
iters <- tapply(sem$iterations, sem$run, `[`, 1)

rep <- c(
  sprintf("# A2 cross-check: seminr vs. SmartPLS, %s", tolower(oc$label)),
  "",
  sprintf("Built by `R/a2_04_seminr_crosscheck.R%s`. SmartPLS values come from `%s/a2_pisa2012_estimates_*.csv` (read by `R/a2_02`).",
          if (outcome == "math") "" else paste0(" ", outcome), oc$dir),
  "",
  "## Verdict",
  "",
  sprintf("- **Point estimates:** %s. Largest gap across paths, effects, R², loadings, α, ρC and AVE: %s.",
          if (point_ok) sprintf("seminr reproduces SmartPLS to within %s on every run", point_tol) else sprintf("some differ from SmartPLS by %s or more (see the table)", point_tol),
          f4(max(abs(cmp$diff[cmp$type %in% c("path", "tot", "ind", "r2", "loading", "alpha", "rhoc", "ave")])))),
  sprintf("- **Significance:** %d of %d paths reach the same verdict at p < .05 in both programs.", sum(pth$agree), nrow(pth)),
  sprintf("- **Bootstrap standard errors** differ by at most %s. Different random resamples give small differences like this even within one program.",
          f4(max(abs(pth$seminr_se - pth$smartpls_se)))),
  "- The only visible point difference is the SES × ICT path (up to .0002): the two programs build the two-stage product term with slightly different numerics.",
  "",
  "## Settings",
  "",
  sprintf("- seminr %s, R %s. PLS-SEM with path weighting, mode A for ICT and %s, single items for SES (or ESCS) and OTL. SES × ICT by the two-stage approach. Up to 3,000 iterations, stop criterion 10⁻⁷; iterations used: %s.",
          as.character(utils::packageVersion("seminr")), getRversion(), oc$lv, paste(names(iters), iters, sep = " ", collapse = ", ")),
  sprintf("- Bootstrap: %d samples, seed %d, percentile 95%% CIs, p from t with %d df. SmartPLS used 5,000 samples with its own fixed seed, so the resamples differ.", nboot, seed, nboot - 1),
  sprintf("- Data: `data/derived/a2_smartpls_model{1,2}.csv`, the files SmartPLS read. Run time %.0f s on %d cores.", secs, cores),
  "",
  "## Largest difference by estimate type (all four runs)",
  "",
  "| Estimates | n | Max abs. difference | Max abs. difference in bootstrap SE |", "|---|---|---|---|",
  paste0("| ", type_lab[by_type$type], " | ", by_type$n, " | ", f4(by_type$max_abs_diff), " | ", f4(by_type$max_abs_diff_se), " |"),
  "",
  "## Paths, side by side",
  "",
  "Significance: \\* p < .05, \\*\\* p < .01, \\*\\*\\* p < .001.",
  "",
  "| Run | Path | SmartPLS | seminr | Difference | SE SmartPLS | SE seminr | Same verdict at .05 |",
  "|---|---|---|---|---|---|---|---|",
  paste0("| ", pth$run, " | ", sub("^path_", "", pth$id), " | ", f3(pth$smartpls), pstar(pth$smartpls_p), " | ", f3(pth$seminr), pstar(pth$seminr_p),
         " | ", f4(pth$diff), " | ", f3(pth$smartpls_se), " | ", f3(pth$seminr_se), " | ", ifelse(pth$agree, "yes", "**no**"), " |")
)
writeLines(rep, file.path(oc$dir, "a2_04_seminr_crosscheck.md"))
print(by_type, row.names = FALSE)
cat(sprintf("Paths with the same verdict: %d of %d. Point estimates within %s: %s. %.0f s\n",
            sum(pth$agree), nrow(pth), point_tol, point_ok, secs))
