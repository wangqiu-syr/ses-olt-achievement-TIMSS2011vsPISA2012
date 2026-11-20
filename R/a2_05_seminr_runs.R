# A2 scripted runs (exploratory): every outcome x OTL measure x ICT model x SES measure, fitted
# in R with seminr using the settings of the user's SmartPLS runs (R/a2_seminr_helpers.R).
# R/a2_04 showed these settings reproduce SmartPLS (estimates within .0003, same verdicts).
# Run from the project root:
#   Rscript R/a2_05_seminr_runs.R
# Environment: NBOOT (default 5000); OUTCOMES and OTLS (comma lists) restrict the grid.
#
# Grid  outcomes  math, print reading, science (paper-based); digital reading, computer-based
#                 math, problem solving (computer-based)
#       OTL       the construct OTL with one of four single indicators: FAMCONC (spec), OTL_PT
#                 (ST73-76 problem types), EXPUREM, EXAPPLM
#       models    M1 (ICT use), M2 (ICT resources); SES composite (primary) or ESCS
# Inputs  data/derived/a2_smartpls_model{1,2}.csv (from a2_01)
# Outputs results/a2_seminr/estimates.csv   one row per run x estimate
#         results/a2_seminr/criteria.csv    M1-M4 per run
#         results/a2_seminr/summary.md      report

source("R/a2_seminr_helpers.R")
nboot <- as.integer(Sys.getenv("NBOOT", "5000"))
seed  <- 20261120
outcomes <- data.frame(
  outcome = c("math", "reading", "science", "digital", "cmat", "cpro"),
  lv      = c("MATH", "READ", "SCIE", "CREA", "CMAT", "CPRO"),
  label   = c("Math", "Print reading", "Science", "Digital reading", "Computer-based math", "Problem solving"),
  mode    = c("paper", "paper", "paper", "computer", "computer", "computer"), stringsAsFactors = FALSE)
otls <- data.frame(
  otl   = c("famconc", "pt", "expurem", "exapplm"),
  col   = c("OTL", "OTL_PT", "EXPUREM", "EXAPPLM"),
  label = c("FAMCONC", "OTL_PT", "EXPUREM", "EXAPPLM"), stringsAsFactors = FALSE)
pick <- function(env, all) { x <- Sys.getenv(env, ""); if (x == "") all else intersect(strsplit(x, ",")[[1]], all) }
grid <- expand.grid(ses = c("primary", "escs"), model = c("M1", "M2"), otl = pick("OTLS", otls$otl),
                    outcome = pick("OUTCOMES", outcomes$outcome), stringsAsFactors = FALSE)[, 4:1]
dir.create("results/a2_seminr", showWarnings = FALSE, recursive = TRUE)

# ---- fit every run -------------------------------------------------------------------
t0 <- Sys.time(); est <- list(); crit <- list()
for (i in seq_len(nrow(grid))) {
  g <- grid[i, ]
  f <- a2_fit_pls(g$model, outcomes$lv[outcomes$outcome == g$outcome],
                  ses_col = if (g$ses == "escs") "ESCS" else "SES",
                  otl_col = otls$col[otls$otl == g$otl], nboot = nboot, seed = seed)
  est[[i]]  <- cbind(g, f$est, row.names = NULL)
  crit[[i]] <- cbind(g, a2_criteria(f), iterations = f$iterations, row.names = NULL)
  cat(sprintf("[%d/%d] %s %s %s %s  %.0f s\n", i, nrow(grid), g$outcome, g$otl, g$model, g$ses,
              as.numeric(difftime(Sys.time(), t0, units = "secs"))))
}
secs <- as.numeric(difftime(Sys.time(), t0, units = "secs"))
est  <- do.call(rbind, est); crit <- do.call(rbind, crit)
est_out <- est; est_out[c("estimate", "se", "p_value", "ci_low", "ci_high")] <-
  lapply(est_out[c("estimate", "se", "p_value", "ci_low", "ci_high")], function(x) signif(x, 6))
utils::write.csv(est_out, "results/a2_seminr/estimates.csv", row.names = FALSE)
utils::write.csv(crit, "results/a2_seminr/criteria.csv", row.names = FALSE)

# ---- report helpers --------------------------------------------------------------------
nz <- function(x) ifelse(is.na(x), "", sub("^-\\.00$", ".00", sub("^(-?)0\\.", "\\1.", formatC(x, format = "f", digits = 2))))
pstar <- function(p) ifelse(is.na(p), "", ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", ""))))
fp <- function(p) if (p < .001) "p < .001" else sub("= 0\\.", "= .", sprintf("p = %.3f", p))
E <- function(outcome, otl, model, id, ses = "primary")
  est[est$outcome == outcome & est$otl == otl & est$model == model & est$ses == ses & est$id == id, ]
cell <- function(...) { x <- E(...); if (!nrow(x)) "" else paste0(nz(x$estimate), pstar(x$p_value)) }
olab <- function(o) outcomes$label[match(o, outcomes$outcome)]
tlab <- function(t) otls$label[match(t, otls$otl)]
rng <- function(v) { v <- range(v); if (nz(v[1]) == nz(v[2])) nz(v[1]) else paste0(nz(v[1]), " to ", nz(v[2])) }
ids  <- c("path_SES_OTL", "path_SES_ACH", "path_OTL_ACH", "path_ICT_OTL", "path_ICT_ACH", "path_SESxICT_ACH",
          "ind_SES_OTL_ACH", "tot_ICT_ACH", "r2_ACH")
labs <- c("SES → OTL", "SES → Ach.", "OTL → Ach.", "ICT → OTL", "ICT → Ach.", "SES × ICT", "SES → OTL → Ach.", "ICT total", "R² Ach.")
grid_tab <- function(model) {
  rows <- unlist(lapply(unique(grid$outcome), function(o) vapply(unique(grid$otl), function(t)
    paste0("| ", if (t == unique(grid$otl)[1]) paste0("**", olab(o), "**") else "", " | ", tlab(t), " | ",
           paste(vapply(ids, function(id) cell(o, t, model, id), ""), collapse = " | "), " |"), "")))
  c(paste0("| Outcome | OTL | ", paste(labs, collapse = " | "), " |"), paste0("|", strrep("---|", length(labs) + 2)), rows)
}
prim <- est[est$ses == "primary", ]
id_lab <- c(path_SES_OTL = "SES → OTL", path_SES_ACH = "SES → Ach.", path_OTL_ACH = "OTL → Ach.",
            path_ICT_OTL = "ICT → OTL", path_ICT_ACH = "ICT → Ach. (direct)", path_SESxICT_ACH = "SES × ICT → Ach.",
            ind_SES_OTL_ACH = "SES → OTL → Ach.", ind_ICT_OTL_ACH = "ICT → OTL → Ach.",
            tot_SES_ACH = "SES total", tot_ICT_ACH = "ICT total")
sig_rows <- function(pat) { x <- prim[grepl(pat, prim$id) & !is.na(prim$p_value) & prim$p_value < .05, ]
  if (!nrow(x)) return(character(0))
  esc <- merge(x, est[est$ses == "escs", c("outcome", "otl", "model", "id", "p_value")],
               by = c("outcome", "otl", "model", "id"), suffixes = c("", "_escs"), sort = FALSE)
  sprintf("%s, OTL = %s, %s: %s %s (%s)%s", olab(esc$outcome), tlab(esc$otl), esc$model,
          id_lab[esc$id], nz(esc$estimate), vapply(esc$p_value, fp, ""),
          ifelse(esc$p_value_escs < .05, "", "; not significant with ESCS")) }
# ESCS vs primary: verdict changes at .05 on paths and effects
pe <- est[grepl("^(path|tot|ind)_", est$id), ]
w  <- merge(pe[pe$ses == "primary", ], pe[pe$ses == "escs", ], by = c("outcome", "otl", "model", "id"), suffixes = c("", "_escs"))
flip <- w[(w$p_value < .05) != (w$p_value_escs < .05), ]
crit_ok <- crit$M1_pass & crit$M2_pass & crit$M3_pass & crit$M4_pass
by_otl <- function(id, t) prim$estimate[prim$id == id & prim$otl == t]

# Findings, computed from the estimates.
sigp <- prim[!is.na(prim$p_value) & prim$p_value < .05, ]
n_otl <- length(unique(grid$otl))
pattern <- function(idset, what) {
  x <- unique(sigp[sigp$id %in% idset, c("outcome", "model", "otl")])
  if (!nrow(x)) return(sprintf("No %s reaches p < .05 in any primary run.", what))
  a <- aggregate(otl ~ outcome + model, data = x, FUN = length)
  a <- a[order(-a$otl), ]
  paste0(sprintf("%s reaches p < .05 in: ", what),
         paste(sprintf("%s, %s (%d of %d OTL measures)", olab(a$outcome), ifelse(a$model == "M1", "Model 1", "Model 2"), a$otl, n_otl), collapse = "; "), ".")
}
r2m <- function(m) mean(prim$estimate[prim$id == "r2_ACH" & prim$otl == "famconc" & prim$outcome %in% outcomes$outcome[outcomes$mode == m]])
findings <- c(
  if (all(c("famconc", "pt") %in% grid$otl)) sprintf(
    "1. **What OTL does depends on the measure.** OTL → Ach. is %s with FAMCONC but %s with OTL_PT (EXPUREM %s, EXAPPLM %s). With a weaker OTL, SES's direct path takes over: SES → Ach. is %s with FAMCONC and %s with OTL_PT. The A2 finding that OTL matters more in PISA than in TIMSS rests on FAMCONC.",
    rng(by_otl("path_OTL_ACH", "famconc")), rng(by_otl("path_OTL_ACH", "pt")),
    if ("expurem" %in% grid$otl) rng(by_otl("path_OTL_ACH", "expurem")) else "not run",
    if ("exapplm" %in% grid$otl) rng(by_otl("path_OTL_ACH", "exapplm")) else "not run",
    rng(by_otl("path_SES_ACH", "famconc")), rng(by_otl("path_SES_ACH", "pt"))),
  paste("2. **ICT.**", pattern(c("path_ICT_OTL", "path_ICT_ACH", "ind_ICT_OTL_ACH", "tot_ICT_ACH"), "An ICT path or effect")),
  paste("3. **Moderation.**", pattern("path_SESxICT_ACH", "SES × ICT")),
  if (all(c("paper", "computer") %in% outcomes$mode[outcomes$outcome %in% grid$outcome]) && "famconc" %in% grid$otl) sprintf(
    "4. **Computer-based outcomes are explained less well.** With FAMCONC, R² Ach. averages %s for the paper-based outcomes and %s for the computer-based ones (see Cautions).",
    nz(r2m("paper")), nz(r2m("computer"))),
  "",
  "Details for every significant result are in the section after the tables."
)

# ---- report ---------------------------------------------------------------------------
otl_lines <- vapply(unique(grid$otl), function(t)
  sprintf("| %s | %s | %s | %s | %s |", tlab(t), rng(by_otl("path_OTL_ACH", t)), rng(by_otl("path_SES_OTL", t)),
          rng(by_otl("path_SES_ACH", t)), rng(by_otl("r2_ACH", t))), "")
rep <- c(
  "# A2 scripted runs (seminr): six outcomes × four OTL measures",
  "",
  "Built by `R/a2_05_seminr_runs.R`. **Exploratory.** The spec (`docs/spec.md`) covers math with OTL = FAMCONC; every other cell here extends it.",
  "",
  "- **Model:** the paper's, as in the SmartPLS runs: SES → OTL, ICT → OTL; SES, ICT, OTL and SES × ICT → achievement. Model 1 uses ICT use, Model 2 ICT resources. School level, 146 / 139 schools.",
  "- **OTL:** the construct `OTL` with one single indicator:",
  "  - **FAMCONC**, familiarity with math concepts (the spec);",
  "  - **OTL_PT**, how often students meet four problem types (ST73–76);",
  "  - **EXPUREM** and **EXAPPLM**, experience with pure- and applied-math tasks.",
  "  All four are about math; PISA 2012 has no reading or science OTL.",
  sprintf("- **Estimation:** seminr %s with the SmartPLS settings (`R/a2_seminr_helpers.R`), %d bootstrap samples, seed %d. `R/a2_04` showed these settings reproduce SmartPLS: estimates within .0003, every significance verdict the same.",
          as.character(utils::packageVersion("seminr")), nboot, seed),
  sprintf("- %d runs (%d outcomes × %d OTL measures × 2 ICT models × SES composite or ESCS), %.0f minutes. All estimates: `estimates.csv`; criteria: `criteria.csv`.",
          nrow(grid), length(unique(grid$outcome)), length(unique(grid$otl)), secs / 60),
  "",
  "## Acceptance criteria (spec section 6)",
  "",
  if (all(crit_ok)) sprintf("All %d runs pass M1–M4. The lowest ICT loading is %s (`ICTUSE_LESSON`, kept under the M1 rule as in math); the largest HTMT is %s; the largest inner VIF is %s.",
                            nrow(crit), nz(min(crit$M1_min_loading)), nz(max(crit$M3_max_htmt)), nz(max(crit$M4_max_inner_vif)))
  else paste0("**Not all runs pass M1–M4.** Failing: ", toString(apply(crit[!crit_ok, c("outcome", "otl", "model", "ses")], 1, paste, collapse = " "))),
  "",
  "## What the grid shows (primary runs; descriptive)",
  "",
  findings,
  "",
  "## How much the OTL measure matters (primary runs, all outcomes and both models)",
  "",
  "| OTL measure | OTL → Ach. | SES → OTL | SES → Ach. (direct) | R² Ach. |", "|---|---|---|---|---|",
  otl_lines,
  "",
  "## Model 1: ICT use (primary runs, SES composite)",
  "",
  "Ach. = achievement in the row's outcome. \\* p < .05, \\*\\* p < .01, \\*\\*\\* p < .001 (two-tailed, bootstrap). SES → OTL → Ach. is the indirect effect; ICT total = direct + via OTL.",
  "",
  grid_tab("M1"),
  "",
  "## Model 2: ICT resources (primary runs, SES composite)",
  "",
  grid_tab("M2"),
  "",
  "## ICT and moderation: every significant result (primary runs)",
  "",
  { s <- sig_rows("^(path_ICT|tot_ICT|ind_ICT)"); if (length(s)) paste0("- ", s) else "- No ICT path or effect reaches p < .05 in any primary run." },
  { s <- sig_rows("^path_SESxICT"); if (length(s)) paste0("- Moderation: ", s) else "- No SES × ICT moderation reaches p < .05 in any primary run." },
  "",
  "## ESCS instead of the SES composite",
  "",
  if (!nrow(flip)) sprintf("Across all %d run pairs, no path or effect changes its verdict at .05.", nrow(grid) / 2)
  else c(sprintf("%d of %d path and effect estimates change their verdict at .05:", nrow(flip), nrow(w)),
         sprintf("- %s, OTL = %s, %s, %s: %s%s → %s%s", olab(flip$outcome), tlab(flip$otl), flip$model, id_lab[flip$id],
                 nz(flip$estimate), pstar(flip$p_value), nz(flip$estimate_escs), pstar(flip$p_value_escs))),
  "",
  "## Cautions",
  "",
  "- All comparisons across outcomes and OTL measures are descriptive. Every run uses the same schools, and the outcomes are correlated school means.",
  "- With 139–146 schools, paths below about |.21| are unlikely to reach p < .05 (spec D4). This grid has many tests, so single results near p = .05 are weak evidence.",
  "- **Computer-based outcomes** (digital reading, computer-based math, problem solving): school means of these PVs correlate only .78–.83 with their paper counterparts, below the student-level .86. Only part of the sample may have sat the computer-based test; check the PISA 2012 technical report before interpreting differences from the paper-based outcomes."
)
writeLines(rep, "results/a2_seminr/summary.md")
cat(sprintf("Done: %d runs, %.0f s. Criteria pass: %d of %d. ESCS verdict changes: %d\n",
            nrow(grid), secs, sum(crit_ok), nrow(crit), nrow(flip)))
