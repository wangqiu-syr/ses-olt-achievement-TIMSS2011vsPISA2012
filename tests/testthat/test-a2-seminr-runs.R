# A2 scripted runs (R/a2_05_seminr_runs.R): the grid must be complete, every run must meet the
# spec's criteria M1-M4, and its math/FAMCONC cells must reproduce the SmartPLS math runs.

test_that("seminr run grid is complete, passes M1-M4 and is anchored to SmartPLS", {
  crit_file <- root_path("results", "a2_seminr", "criteria.csv")
  skip_if_not(file.exists(crit_file), "seminr runs not done yet (R/a2_05_seminr_runs.R)")
  cr  <- utils::read.csv(crit_file, stringsAsFactors = FALSE)
  est <- utils::read.csv(root_path("results", "a2_seminr", "estimates.csv"), stringsAsFactors = FALSE)
  expect_equal(nrow(unique(cr[, c("outcome", "otl", "model", "ses")])), 96)
  for (k in c("M1_pass", "M2_pass", "M3_pass", "M4_pass")) {
    bad <- with(cr[!as.logical(cr[[k]]), ], paste(outcome, otl, model, ses))
    expect(length(bad) == 0, paste(k, "fails for:", toString(bad)))
  }
  paths <- est[grepl("^path_", est$id), ]
  expect(all(!is.na(paths$estimate) & !is.na(paths$p_value)), "missing path estimates or p values")
  # anchor: math with OTL = FAMCONC equals the SmartPLS math runs (R/a2_02)
  sp <- utils::read.csv(root_path("results", "a2", "a2_pisa2012_estimates_user_sav.csv"), stringsAsFactors = FALSE)
  m  <- paths[paths$outcome == "math" & paths$otl == "famconc" & paths$ses == "primary", ]
  sp_est <- sp$estimate[match(paste0(m$model, "_math_", m$id), sp$estimate_id)]
  expect(all(!is.na(sp_est)), "SmartPLS math paths not found")
  expect_lt(max(abs(m$estimate - sp_est)), 0.001)
})
