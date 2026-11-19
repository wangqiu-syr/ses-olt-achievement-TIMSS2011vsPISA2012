# Phase A2: PISA 2012.
# Step 1 (parity): the same model fitted on the user's .sav and on Code's own
# OECD download must give the same estimates.
# Step 2: the analogous model must meet the acceptance criteria in docs/spec.md.

user_file <- root_path("results", "a2", "a2_pisa2012_estimates_user_sav.csv")
oecd_file <- root_path("results", "a2", "a2_pisa2012_estimates_oecd.csv")

test_that("A2 parity: user .sav and OECD download give the same estimates", {
  skip_if_not(file.exists(user_file) && file.exists(oecd_file),
              "A2 parity results not produced yet")
  u <- utils::read.csv(user_file, stringsAsFactors = FALSE)
  o <- utils::read.csv(oecd_file, stringsAsFactors = FALSE)
  expect_setequal(u$estimate_id, o$estimate_id)
  m <- merge(u, o, by = "estimate_id", suffixes = c("_user", "_oecd"))
  expect_equal(m$estimate_user, m$estimate_oecd, tolerance = 1e-8)
})

# Math is the A2 model; reading and science are exploratory runs of the same model
# (R/a2_02_read_smartpls.R <outcome>), held to the same criteria.
outcomes <- list(math = c(dir = "a2", tag = "math"), reading = c(dir = "a2_reading", tag = "read"),
                 science = c(dir = "a2_science", tag = "sci"))
for (oc in names(outcomes)) {
  test_that(paste("A2", oc, "model meets the acceptance criteria in docs/spec.md"), {
    dir <- outcomes[[oc]][["dir"]]; tag <- outcomes[[oc]][["tag"]]
    crit_file <- root_path("results", dir, "a2_02_criteria.csv")
    skip_if_not(file.exists(crit_file), paste("SmartPLS results not read yet (R/a2_02_read_smartpls.R", oc, ")"))
    cr <- utils::read.csv(crit_file, stringsAsFactors = FALSE)
    expect_true(all(c("M1_primary", "M2_primary") %in% cr$run))
    for (k in c("M1_pass", "M2_pass", "M3_pass", "M4_pass")) {
      bad <- cr$run[!as.logical(cr[[k]])]
      expect(length(bad) == 0, paste(k, "fails for:", toString(bad)))
    }
    est <- utils::read.csv(root_path("results", dir, "a2_pisa2012_estimates_user_sav.csv"))
    paths <- paste0(rep(c("M1", "M2"), each = 6), "_", tag, "_path_",
                    c("SES_OTL", "SES_ACH", "OTL_ACH", "ICT_OTL", "ICT_ACH", "SESxICT_ACH"))
    expect(all(paths %in% est$estimate_id), "M5: primary path estimates missing")
    expect(all(!is.na(est$p_value[match(paths, est$estimate_id)])), "M5: p values missing")
  })
}
