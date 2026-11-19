# Phase A2: PISA 2012.
# Step 1 (parity): the same model fitted on the user's .sav and on Code's own
# OECD download must give the same estimates.
# Step 2: the analogous model must meet the acceptance criteria in docs/spec.md.

user_file <- root_path("from_code", "a2_pisa2012_estimates_user_sav.csv")
oecd_file <- root_path("from_code", "a2_pisa2012_estimates_oecd.csv")

test_that("A2 parity: user .sav and OECD download give the same estimates", {
  skip_if_not(file.exists(user_file) && file.exists(oecd_file),
              "A2 parity results not produced yet")
  u <- utils::read.csv(user_file, stringsAsFactors = FALSE)
  o <- utils::read.csv(oecd_file, stringsAsFactors = FALSE)
  expect_setequal(u$estimate_id, o$estimate_id)
  m <- merge(u, o, by = "estimate_id", suffixes = c("_user", "_oecd"))
  expect_equal(m$estimate_user, m$estimate_oecd, tolerance = 1e-8)
})

test_that("A2 model meets the acceptance criteria in docs/spec.md", {
  skip_if_not(file.exists(root_path("docs", "spec.md")),
              "docs/spec.md (A2 acceptance criteria) not written yet")
  skip("Criteria checks to be written once docs/spec.md defines them")
})
